/*
Authentication -> Xác thực
=> Đăng nhập, đăng ký,...

Authorization -> Vai trò, ủy quyền
=> Được làm gì? Quyền hạn như thế nào?

1. Authentication
- Session-based Authentication
- Token-based Authentication

2. Authorization

Logout:
- Call api logout
- Xóa storage

Xử lý khi user thay đổi accessToken -> Verify Server
- Nếu trả về 200 => ok
- Nếu trả về 401 => Xử lý logout

Khi accessToken hết hạn => Xử lý luôn cấp lại accessToken mới => lưu storage => call lại api cần lấy dữ liệu

Ví dụ: 
1. Lấy danh sách sản phẩm -> Lấy được

2. Lấy danh sách bài viết -> accessToken hết hạn -> Không lấy được bài viết
- Call api /refresh -> lấy access mới -> lưu localStorage -> call lại danh sách bài viết

3. Lấy danh sách khóa học
*/

import { config } from "./config.js";
import { client } from "./client.js";

const { SERVER_AUTH_API } = config;

client.setUrl(SERVER_AUTH_API);
const root = document.querySelector("#root");
const getProfile = async () => {
  const token = localStorage.getItem("access_token");
  const { data } = await client.get("/auth/profile", token);
  const nameEl = root.querySelector(".profile .name");
  nameEl.innerText = data.name;
};

const render = () => {
  const loginHtml = `<div class="container py-3">
<h2 class="text-center">Đăng nhập</h2>
<hr>
<form action="" class="login">
  <div class="mb-3">
    <label for="">Email</label>
    <input type="email" class="form-control email" placeholder="Email..." required />
  </div>
  <div class="mb-3">
    <label for="">Password</label>
    <input type="password" class="form-control password" placeholder="Password..." required />
  </div>
  <div class="d-grid">
    <button class="btn btn-primary">Đăng nhập</button>
  </div>
</form>
</div>`;

  const welcomeHtml = `
<div class="container py-3">
    <h2 class="text-center">Chào mừng bạn đã quay trở lại</h2>
    <ul class="profile list-unstyled d-flex gap-2">
        <li>Chào bạn: <b><span class="name"></span></b></li>
        <li><a href="#" class="logout">Đăng xuất</a></li>
    </ul>
</div>`;
  if (localStorage.getItem("access_token")) {
    root.innerHTML = welcomeHtml;
    //Lấy thông tin user
    getProfile();

    const logout = root.querySelector(".profile .logout");
    logout.addEventListener("click", (e) => {
      e.preventDefault();
      localStorage.removeItem("access_token");
      localStorage.removeItem("refresh_token");
      render();
    });
  } else {
    root.innerHTML = loginHtml;
    const loginForm = document.querySelector(".login");
    loginForm.addEventListener("submit", (e) => {
      e.preventDefault();
      const emailEl = e.target.querySelector(".email");
      const passwordEl = e.target.querySelector(".password");

      const email = emailEl.value;
      const password = passwordEl.value;

      handleLogin({ email, password });

      emailEl.value = "";
      passwordEl.value = "";
    });
  }
};

render();

const handleLogin = async (data) => {
  const { data: tokens } = await client.post("/auth/login", data);
  const { access_token, refresh_token } = tokens;

  localStorage.setItem("access_token", access_token);
  localStorage.setItem("refresh_token", refresh_token);

  render();
};

/*
Storage
1. localStorage: Lưu trữ vĩnh viễn
2. sessionStorage: Lưu trữ theo phiên
3. cookie: Lưu trữ có thời hạn

-> Chỉ lưu trữ Text
*/
