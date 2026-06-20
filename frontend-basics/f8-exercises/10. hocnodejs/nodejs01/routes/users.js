import express from "express";
import routerOrders from "./orders.js";
import userController from "../controllers/user.controller.js";
import roleMiddleware from "../middlewares/role.middleware.js";
const router = express.Router();
//HTTP GET

router.get("/", userController.index);

router.get("/add", userController.add);

router.get("/edit/:id", userController.edit);

//Order Router
router.use(roleMiddleware);
router.use("/orders", routerOrders);

export default router;
