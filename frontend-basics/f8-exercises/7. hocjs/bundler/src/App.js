//Import từ node_modules
import "bootstrap/dist/css/bootstrap.min.css";
import moment from "moment";

//Import từ src
import "./Assets/Styles.css";
import "./Assets/Footer.scss";
import { Header } from "./Components/Header";
import { Footer } from "./Components/Footer";
import image1 from "./Images/image01.jpeg";
import config from "./Config.json";
const { SERVER_API } = config;

console.log(process.env.APP_NAME); //Truy cập vào biến môi trường

export const App = () => {
  return `
  <div class="container">
  ${Header()}
  <main>
    <h1>Trang chủ F8</h1>
    <a href="" class="btn btn-primary">Vào hệ thống</a>
    <hr/>
    ${moment().format("DD/MM/YYYY HH:mm:ss")}
    <hr/>
    <img src="${image1}" width="300"/>
    <hr/>
    Server API: ${SERVER_API}
  </main>
  ${Footer()}
  </div>
  `;
};
