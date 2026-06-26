# Vấn đề

- Chia sẻ dữ liệu giữa các Component với nhau -> render props + state của component cha
- Dữ liệu dùng chung cho các component -> Thông tin user sau khi đăng nhập,...

# Giải pháp

- Local State -> Dùng useState
- Global State: Context API + useReducer, Thư viện bên ngoài: Redux

# Muốn lấy dữ liệu từ context:

- Import đối tượng context
- Import Hook useContext

=> Gom thành 1 hook mới -> Tạo 1 hàm bắt đầu từ khóa use (React sẽ hiểu là React hook)
