import express from "express";
import expressLayouts from "express-ejs-layouts";
import bodyParser from "body-parser";
import session from "express-session";
import flash from "connect-flash";
import routerIndex from "./routes/index.js";
import routerUsers from "./routes/users.js";
import routerAuth from "./routes/auth.js";
import authMiddleware from "./middlewares/auth.middleware.js";
const app = express();
const port = 8080;

//Static file
app.use(express.static("public"));

//Setup template engine
app.set("views", "./views");
app.set("view engine", "ejs");
app.use(expressLayouts); //Sử dụng layout
app.set("layout", "layouts/layout.default.ejs"); //Thay đổi đường dẫn layout mặc định

//Parse body
// app.use(
//   bodyParser.urlencoded({
//     extended: false,
//   }),
// ); //Hỗ trợ nhận dữ liệu ở dạng: application/x-www-urlencoded
// app.use(bodyParser.json()); //Hỗ trợ nhận dữ liệu ở dạng: application/json
//Ở phiên express 4.16 trở lên
app.use(express.urlencoded());
app.use(express.json());

//Session
app.use(
  session({
    name: "f8_session_id",
    secret: "f8",
    resave: false,
    saveUninitialized: true,
  }),
);
app.use(flash());

//Routing
app.use(routerAuth);
app.use(authMiddleware);
app.use(routerIndex);
app.use("/users", routerUsers);

//Listener
app.listen(port, () => {
  console.log("Server đang chạy: http://localhost:8080");
});
