import express from "express";
import authController from "../controllers/auth.controller.js";
const router = express.Router();

//HTTP GET
router.get("/dang-nhap", authController.login);

//HTTP POST
router.post("/dang-nhap", authController.handleLogin);

export default router;
