import { object, string } from "yup";

import { getError } from "../utils/validate.js";

const authController = {
  login: function (req, res) {
    const errors = req.flash("errors");
    res.render("auth/login", {
      layout: "layouts/layout.auth.ejs",
      errors,
      getError,
    });
  },
  handleLogin: async (req, res) => {
    // const { email, password } = req.body;

    // const errors = {};
    // if (!email) {
    //   errors.email = "Email bắt buộc phải nhập";
    // }
    // if (!password) {
    //   errors.password = "Mật khẩu bắt buộc phải nhập";
    // }
    //req.flash("errors", errors);
    const schema = object({
      email: string()
        .required("Email bắt buộc phải nhập")
        .email("Email không đúng định dạng")
        .matches(/[^@gmail\.com]+$/, "Email không được phép ở dạng @gmail.com"),
      password: string()
        .required("Mật khẩu bắt buộc phải nhập")
        .max(6, "Mật khẩu không được quá 6 ký tự")
        .test(
          "password-uppercase",
          "Mật khẩu bắt buộc phải là chữ hoa",
          (value) => {
            return value === value.toUpperCase();
          },
        ),
    });
    try {
      const data = await schema.validate(req.body, {
        abortEarly: false, //Trả về tất cả lỗi
      });
    } catch (e) {
      const errors = Object.fromEntries(
        e.inner.map(({ path, message }) => [path, message]),
      );
      req.flash("errors", errors);
    }
    // return res.send("submit");
    return res.redirect("/dang-nhap");
    // return res.status(404).json(data);
  },
};

export default authController;
