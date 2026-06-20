# Layout

- Header
- Body --> View
- Footer

# Cách làm việc với Request - Response theo cơ chế Server Side (MVC)

- View chỉ được vào Method GET
- Logic: Viết ở post, put, patch, delete --> redirect về GET để trình duyệt hiển thị giao diện
  Lưu ý: Tuyệt đối không được gọi giao diện vào các phương thức trên

Có 2 cách để gửi message giữa các request

- Cách 1: Dùng search params
- Cách 2: Dùng session (Flash session)
