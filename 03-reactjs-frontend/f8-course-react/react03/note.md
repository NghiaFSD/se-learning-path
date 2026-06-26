```
Post: State -> Nhận data từ CommentForm -> Lưu vào 1 array -> Truyền array xuống CommentList qua props
    - CommentList
    - CommentForm
        + Render Props -> Đẩy dữ liệu lên Post
```

A => B => C => D
-> Khách hàng bắt nâng cấp

A => D

Context API

- Tạo đối tượng context: React.createContext
- Provider: Component có sẵn của Context, dùng để gửi dữ liệu tới các Component con
- Consumer: Nhận dữ liệu từ Provider (Có thể sử dụng Hook useContext)

Context nâng cao: Xây dựng State Manager kết hợp với useReducer

State:

1. Local State -> State nội bộ trong 1 component

2. Global State -> Kho lưu trữ các state mà các Component có thể sử dụng
