import express from "express";
const router = express.Router();
import userController from "../controllers/user.controller.js";

//HTTP GET
router.get("/", userController.orderList);

router.get("/completed", userController.orderCompleted);

router.get("/cancel", userController.orderCancel);
export default router;
