# Origin

protocol + domain + port

Trình duyệt chặn các request không cùng origin

==> Giải pháp: Server cần phải cho phép Origin

- Origin
- Method
- Credentials

==> NodeJS: Thư viện cors

# Mẹo khi sử dụng các API bên ngoài không cho phép CORS

React/Next ===> Call API ==> Failed

React/Next ==> Proxy (Server Back-End, cho phép CORS) ==> Call API ==> Success
