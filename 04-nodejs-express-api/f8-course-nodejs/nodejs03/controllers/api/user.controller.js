const { User } = require("../../models/index");
const { Op } = require("sequelize");
const { object, string } = require("yup");
const bcrypt = require("bcrypt");
const UserTransformer = require("../../transformers/user.transformer");

module.exports = {
  index: async (req, res) => {
    const {
      order = "asc",
      sort = "id",
      status,
      q,
      limit,
      page = 1,
    } = req.query;
    const filters = {};
    if (status === "true" || status === "false") {
      filters.status = status === "true";
    }
    if (q) {
      filters[Op.or] = {
        fullname: {
          [Op.iLike]: `%${q.trim()}%`,
        },
        email: {
          [Op.iLike]: `%${q.trim()}%`,
        },
      };
    }
    const options = {
      order: [[sort, order]],
      attributes: { exclude: ["password"] },
      where: filters,
    };

    if (limit && Number.isInteger(+limit)) {
      const offset = (page - 1) * limit;
      options.limit = limit;
      options.offset = offset;
    }

    const response = {};

    try {
      const { count, rows: users } = await User.findAndCountAll(options);
      response.status = 200;
      response.message = "Success";
      response.data = new UserTransformer(users);
      // response.data = users;
      response.count = count;
    } catch (e) {
      response.status = 500;
      response.message = "Server Error";
    }
    res.status(response.status).json(response);
  },
  find: async (req, res) => {
    const { id } = req.params;
    const response = {};
    try {
      const user = await User.findByPk(id, {
        attributes: { exclude: ["password"] },
      });
      if (!user) {
        Object.assign(response, {
          status: 404,
          message: "Not Found",
        });
      } else {
        Object.assign(response, {
          status: 200,
          message: "Success",
          data: new UserTransformer(user),
        });
      }
    } catch (e) {
      response.status = 500;
      response.message = "Server Error";
    }
    res.status(response.status).json(response);
  },
  store: async (req, res) => {
    const schema = object({
      fullname: string().required("Tên bắt buộc phải nhập"),
      email: string()
        .required("Email bắt buộc phải nhập")
        .email("Email không đúng định dạng"),
      password: string().required("Mật khẩu bắt buộc phải nhập"),
      status: string()
        .required("Trạng thái bắt buộc phải nhập")
        .test("check-boolean", "Trạng thái không hợp lệ", (value) => {
          return value === "true" || value === "false";
        }),
    });
    const response = {};
    //Validate
    try {
      const body = await schema.validate(req.body, {
        abortEarly: false,
      });
      body.status = body.status === "true";
      body.password = bcrypt.hashSync(body.password, bcrypt.genSaltSync(10));
      const user = await User.create(body);
      delete user.dataValues.password;
      Object.assign(response, { status: 201, message: "Success", data: user });
    } catch (e) {
      const errors = Object.fromEntries(
        e.inner.map(({ path, message }) => [path, message]),
      );
      Object.assign(response, {
        status: 400,
        message: "Bad Request",
        errors,
      });
    }
    res.status(response.status).json(response);
  },
  update: async (req, res) => {
    const { id } = req.params;
    const method = req.method;
    const rules = {};
    if (req.body.fullname) {
      rules.fullname = string().min(5, "Tên phải từ 5 ký tự");
    }
    if (req.body.email) {
      rules.email = string().email("Email không đúng định dạng");
    }
    if (req.body.password) {
      rules.password = string().min(6, "Mật khẩu phải từ 6 ký tự");
    }
    if (req.body.status) {
      rules.status = string().test(
        "check-boolean",
        "Trạng thái không hợp lệ",
        (value) => {
          return value === "true" || value === "false";
        },
      );
    }
    const schema = object(rules);
    const response = {};
    //Validate
    try {
      let body = await schema.validate(req.body, {
        abortEarly: false,
      });
      if (body.status === "true" || body.status === "false") {
        body.status = body.status === "true";
      }

      if (body.password) {
        body.password = bcrypt.hashSync(body.password, bcrypt.genSaltSync(10));
      }
      if (method === "PUT") {
        body = Object.assign(
          {
            fullname: null,
            password: null,
            status: null,
          },
          body,
        );
      }
      await User.update(body, {
        where: { id },
      });
      const user = await User.findByPk(id);
      delete user.dataValues.password;
      Object.assign(response, { status: 200, message: "Success", data: user });
    } catch (e) {
      const errors = Object.fromEntries(
        e.inner.map(({ path, message }) => [path, message]),
      );
      Object.assign(response, {
        status: 400,
        message: "Bad Request",
        errors,
      });
    }
    res.status(response.status).json(response);
  },
  delete: async (req, res) => {
    const { id } = req.params;
    await User.destroy({ where: { id } });
    res.status(204).json({
      status: 204,
      message: "Success",
    });
  },
};
