const jwt = require("jsonwebtoken");
const bcrypt = require("bcrypt");
const { User, BlacklistToken } = require("../../models/index");
module.exports = {
  login: async (req, res) => {
    //Lấy body
    const { email, password } = req.body;
    //Validate
    const response = {};
    if (!email || !password) {
      Object.assign(response, {
        status: 400,
        message: "Bad Request",
        error: "Vui lòng nhập email và mật khẩu",
      });
    } else {
      //Kiểm tra email có tồn tại trong Database không?
      const user = await User.findOne({
        where: { email },
      });
      if (!user) {
        Object.assign(response, {
          status: 400,
          message: "Bad Request",
          error: "Email hoặc mật khẩu không chính xác",
        });
      } else {
        //Lấy password hash
        const { password: hash } = user;
        console.log(hash);
        //Compare plain password với password hashs
        const result = bcrypt.compareSync(password, hash);
        if (!result) {
          Object.assign(response, {
            status: 400,
            message: "Bad Request",
            error: "Email hoặc mật khẩu không chính xác",
          });
        } else {
          //Tạo Token (JWT)
          const { JWT_SECRET, JWT_EXPIRE, JWT_REFRESH_EXPIRE } = process.env;
          const token = jwt.sign(
            {
              data: user.id,
            },
            JWT_SECRET,
            { expiresIn: JWT_EXPIRE },
          );
          const refresh = jwt.sign(
            {
              data: new Date().getTime() + Math.random(),
            },
            JWT_SECRET,
            { expiresIn: JWT_REFRESH_EXPIRE },
          );
          await User.update(
            {
              refresh_token: refresh,
            },
            {
              where: { id: user.id },
            },
          );
          Object.assign(response, {
            status: 200,
            message: "Success",
            access_token: token,
            refresh_token: refresh,
          });
        }
      }
    }

    res.status(response.status).json(response);
  },
  profile: async (req, res) => {
    res.json({
      status: 200,
      message: "Success",
      data: req.user,
    });
  },
  logout: async (req, res) => {
    const { accessToken } = req.user;
    await BlacklistToken.findOrCreate({
      where: {
        token: accessToken,
      },
      defaults: { token: accessToken },
    });
    res.json({
      status: 200,
      message: "Success",
    });
  },
  refresh: async (req, res) => {
    const { refresh_token: refreshToken } = req.body;
    const response = {};
    //Kiểm tra refresh có hợp lệ hay không?
    if (!refreshToken) {
      Object.assign(response, {
        status: 401,
        message: "Unauthorized",
      });
    } else {
      const { JWT_SECRET, JWT_EXPIRE } = process.env;
      try {
        jwt.verify(refreshToken, JWT_SECRET);
        const user = await User.findOne({
          where: {
            refresh_token: refreshToken,
          },
        });
        if (!user) {
          Object.assign(response, {
            status: 401,
            message: "Unauthorized",
          });
        }
        const accessToken = jwt.sign(
          {
            data: user.id,
          },
          JWT_SECRET,
          { expiresIn: JWT_EXPIRE },
        );

        Object.assign(response, {
          status: 200,
          message: "Success",
          access_token: accessToken,
          refresh_token: refreshToken,
        });
      } catch (e) {
        Object.assign(response, {
          status: 401,
          message: "Unauthorized",
        });
      }
    }
    res.status(response.status).json(response);
  },
};
