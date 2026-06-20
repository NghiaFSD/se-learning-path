const userModel = require("../models/user.model");
const moment = require("moment");
const { object, string } = require("yup");
module.exports = {
  index: async (req, res) => {
    const { status, keyword } = req.query;
    let statusBool;
    if (status === "active" || status === "inactive") {
      statusBool = status === "active" ? true : false;
    }

    //Đọc dữ liệu từ database
    const users = await userModel.all(statusBool, keyword);
    const msg = req.flash("msg");
    res.render("users/index", { users, moment, status, keyword, msg });
  },
  add: (req, res) => {
    // const errors = req.flash("errors");
    // console.log(errors);
    // console.log(req.errors);
    res.render("users/add", { req });
  },
  handleAdd: async (req, res) => {
    const schema = object({
      name: string().required("Tên bắt buộc phải nhập"),
      email: string()
        .required("Email bắt buộc phải nhập")
        .email("Email không đúng định dạng")
        .test("unique", "Email đã tồn tại trên hệ thống", async (value) => {
          return await userModel.emailUnique(value);
        }),
    });
    try {
      const body = await schema.validate(req.body, { abortEarly: false });
      body.status = body.status === "1" ? true : false;
      await userModel.create(body);
      req.flash("msg", "Thêm người dùng thành công");
      return res.redirect("/users");
    } catch (e) {
      const errors = Object.fromEntries(
        e?.inner.map((item) => [item.path, item.message]),
      );
      req.flash("errors", errors);
      req.flash("old", req.body);
    }
    return res.redirect("/users/add");
  },
  edit: async (req, res, next) => {
    const { id } = req.params;
    req.session.currentId = id;
    const user = await userModel.find(id);
    if (!user.length) {
      //404
      return next(new Error("Không tìm thấy user có id là: " + id));
    }
    user[0].status = user[0].status ? "1" : "0";
    req.old = user[0];
    const msg = req.flash("msg");
    res.render("users/edit", { req, msg });
  },
  handleEdit: async (req, res, next) => {
    const { id } = req.params;
    if (+id !== +req.session.currentId) {
      return next(new Error("404"));
    }
    const schema = object({
      name: string().required("Tên bắt buộc phải nhập"),
      email: string()
        .required("Email bắt buộc phải nhập")
        .email("Email không đúng định dạng")
        .test("unique", "Email đã tồn tại trên hệ thống", async (value) => {
          return await userModel.emailUnique(value, id);
        }),
    });
    try {
      const body = await schema.validate(req.body, { abortEarly: false });
      body.status = body.status === "1" ? true : false;
      await userModel.update(body, id);
      req.flash("msg", "Cập nhật người dùng thành công");
    } catch (e) {
      const errors = Object.fromEntries(
        e?.inner.map((item) => [item.path, item.message]),
      );
      req.flash("errors", errors);
      req.flash("old", req.body);
    }
    return res.redirect("/users/edit/" + id);
  },
  delete: async (req, res, next) => {
    const { id } = req.params;
    const status = await userModel.delete(id);
    if (status) {
      req.flash("msg", "Xóa người dùng thành công");
    } else {
      req.flash("msg", "Xóa người không thành công");
    }
    return res.redirect("/users");
  },
};
