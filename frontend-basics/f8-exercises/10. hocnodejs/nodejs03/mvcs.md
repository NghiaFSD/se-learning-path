# Model - View - Controller - Service

Request ==> Global Middleware => Route ==> Route Middleware ==> Controller
==> Service ==> Model
==> View / Transformer (Lấy từ service)

## Service

- user.service.js

* addUser() --> Có thể gọi nhiều model
* updateUser()
* deleteUser()

## Controller

- Lấy dữ liệu từ Request
- Validate --> Tách ra lớp Request
- Gọi Service kèm theo dữ liệu lấy từ request
- Response

## Repository Design Pattern

Vấn đề:

- Service ==> Gọi các method của Model
- Khi thay đổi Driver Database --> Thay đổi model --> Method thay đổi --> Sửa lại hết service

Giải pháp:

- Tạo tầng Repository ở giữa Service và Model

class BaseRepository --> Định nghĩa các method của model

class UserRepository kế thừa từ BaseRepository --> Gọi vào từng service / controller

## Service - Repository

- Service: Xử lý các Bussiness Logic (Logic nghiệp vụ)
- Repository: Xử lý Database Logic
