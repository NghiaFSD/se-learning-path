const { Role, Permission } = require("../models/index");
const { isPermission } = require("../utils/permissions.utils");
module.exports = {
  index: async (req, res) => {
    const roles = await Role.findAll({
      order: [["id", "desc"]],
    });
    res.render("roles/index", { req, roles });
  },
  add: (req, res) => {
    res.render("roles/add", { req });
  },
  handleAdd: async (req, res) => {
    const body = req.body;
    if (!body.name) {
      //Tên role chưa được nhập
      return res.redirect("/roles/add");
    }

    const role = await Role.create({
      name: body.name,
    });
    if (role && body.permissions) {
      const permissions = Array.isArray(body.permissions)
        ? body.permissions
        : [body.permissions];
      //Biến permissions là 1 mảng chứa các giá trị permissions cần thiết lập
      //Bài toán: Cần lấy 1 mảng chứa tất cả instance của permission cần thêm vào bảng permissions
      const permissionsInstance = await Promise.all(
        permissions.map(async (permission) => {
          //Biến permission là tên của permission khi chọn từ request
          const [result] = await Permission.findOrCreate({
            where: { value: permission.trim() },
            defaults: {
              value: permission.trim(),
            },
          });
          return result;
        }),
      );
      await role.addPermissions(permissionsInstance);
      return res.redirect("/roles");
    }
  },
  edit: async (req, res, next) => {
    const { id } = req.params;
    try {
      const role = await Role.findOne({
        where: { id },
        include: {
          model: Permission,
          as: "permissions",
        },
      });
      if (!role) {
        throw new Error("Role not found");
      }

      res.render("roles/edit", { req, role, isPermission });
    } catch (e) {
      return next(e);
    }
  },
  handleEdit: async (req, res) => {
    const { id } = req.params;
    const body = req.body;
    if (!body.name) {
      //Tên role chưa được nhập
      return res.redirect("/roles/edit/" + id);
    }

    const status = await Role.update(
      {
        name: body.name,
      },
      {
        where: { id },
      },
    );
    if (status && body.permissions) {
      const role = await Role.findByPk(id);
      const permissions = Array.isArray(body.permissions)
        ? body.permissions
        : [body.permissions];
      //Biến permissions là 1 mảng chứa các giá trị permissions cần thiết lập
      //Bài toán: Cần lấy 1 mảng chứa tất cả instance của permission cần thêm vào bảng permissions
      const permissionsInstance = await Promise.all(
        permissions.map(async (permission) => {
          //Biến permission là tên của permission khi chọn từ request
          const [result] = await Permission.findOrCreate({
            where: { value: permission.trim() },
            defaults: {
              value: permission.trim(),
            },
          });
          return result;
        }),
      );
      await role.setPermissions(permissionsInstance);
      return res.redirect("/roles/edit/" + id);
    }
  },
  delete: async (req, res) => {
    const { id } = req.params;
    const role = await Role.findOne({
      where: { id },
      include: {
        model: Permission,
        as: "permissions",
      },
    });
    if (role) {
      //Xóa dữ liệu bảng trung gian
      await role.removePermissions(role.permissions);
      await role.destroy();
      return res.redirect("/roles");
    }
  },
};
