# Authentication

- Mật khẩu phải được mã hóa (1 chiều)
- 2 cách:

* encrypt: md5, sha1 --> Không an toàn
* hash: bcrypt --> An toàn hơn

## Session-Based

- Verify email và password
- Lấy thông tin user
- Lưu vào session

## Token-Based

==> Học ở phần API

- Verify email và password
- Lấy thông tin user
- Lưu vào token (JWT)

# Đăng nhập mạng xã hội

## Database

users

- id
- name
- email
- password
- provider_id

providers

- id
- name: facebook|google|email|github

## Flow

- OpenId hoặc OAuth

# JWT Authentication

## Logout

- Body: access token
- Hành động: Đưa access token vào blacklist

Giải pháp lưu blacklist:

- Tạo table trong database
- Tạo file: Module fs trong NodeJS
- Redis Server

## Cronjob

- Phần mềm chạy trên hệ điều hành Linux
- Lập lịch chạy các câu lệnh CLI --> Chương trình

Triển khai các tính năng lập lịch trên ứng dụng (Task Scheduler)

- Xây dựng code: Gửi email, dọn rác,...
- Build CLI trên ứng dụng để thực thi các đoạn code trên
- Đưa câu lệnh CLI vào cronjob trên Server
