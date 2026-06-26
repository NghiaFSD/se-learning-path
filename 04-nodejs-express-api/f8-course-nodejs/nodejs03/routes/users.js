var express = require("express");
var router = express.Router();
const userController = require("../controllers/user.controller");
const permission = require("../middlewares/permission.middleware");

/* GET users listing. */
router.get("/", permission("users.read"), userController.index);
router.get("/add", permission("users.create"), userController.add);
router.post("/add", permission("users.create"), userController.handleAdd);
router.get("/edit/:id", permission("users.update"), userController.edit);
router.post("/edit/:id", permission("users.update"), userController.handleEdit);
router.post("/delete/:id", permission("users.delete"), userController.delete);
router.get("/permission/:id", userController.permission);
router.post("/permission/:id", userController.handlePermission);

module.exports = router;
