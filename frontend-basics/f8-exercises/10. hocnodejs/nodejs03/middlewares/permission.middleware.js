const { User, Role, Permission } = require("../models/index");
module.exports = (value) => {
  return async (req, res, next) => {
    const user = await User.findOne({
      where: { id: req.user.id },
      include: {
        model: Role,
        as: "roles",
        include: {
          model: Permission,
          as: "permissions",
        },
      },
    }); //Thông tin user đã đăng nhập
    const permissions = [];
    if (user?.roles?.length) {
      user.roles.forEach((role) => {
        if (role?.permissions?.length) {
          role.permissions.forEach((item) => {
            !permissions.includes(item.value) && permissions.push(item.value);
          });
        }
      });
    }
    console.log(permissions);
    req.can = (canValue) => {
      return permissions.includes(canValue);
    };

    if (permissions.includes(value)) {
      return next();
    }
    return next(new Error("Bạn không có quyền truy cập trang này"));
  };
};
