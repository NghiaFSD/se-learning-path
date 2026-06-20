# Hướng dẫn cài nhanh

## Bước 1: Clone Project

```bash
git clone https://github.com/YOUR_USERNAME/BookStoreApp.git
cd BookStoreApp
```

## Bước 2: Cấu Hình Environment Variables

### Windows - Command Prompt

```batch
setx DB_SERVER localhost
setx DB_PORT 1433
setx DB_NAME BookStoreDB
setx DB_USER sa
setx DB_PASSWORD 123
setx GEMINI_API_KEY your_api_key_here
```

### Linux/macOS - Bash

```bash
export DB_SERVER=localhost
export DB_PORT=1433
export DB_NAME=BookStoreDB
export DB_USER=sa
export DB_PASSWORD=123
export GEMINI_API_KEY=your_api_key_here
```

Lưu ý: Sau khi set environment variables, khởi động lại IDE/Terminal để load biến mới.

## Bước 3: Setup Database

1. **Mở SQL Server Management Studio (SSMS)**
2. **Tạo database:**
   ```sql
   CREATE DATABASE BookStoreDB;
   ```
3. **Chạy SQL script** để tạo tables và sample data:
   - Mở file `update_book_data.sql`
   - Execute trên database `BookStoreDB`

## Bước 4: Build & Run Project

### Cách 1: Dùng NetBeans

1. Open project in NetBeans
2. Right-click → Build Project
3. Right-click → Run Project
4. Browser sẽ mở tự động tại `http://localhost:8080/BookStoreApp/home`

### Cách 2: Dùng Command Line (Ant)

```bash
cd BookStoreApp
ant build      # Build project
ant run        # Run on Tomcat
```

## Bước 5: Verify Installation

### Kiểm tra Database

- Truy cập `/home` → Nếu thấy danh sách sách

### Kiểm tra Chatbot (Optional)

- Truy cập `/chatbot` → Nếu thấy form chat

### Test Login

- Email: `admin@fpt.com`
- Password: `Admin@123`
- Sau đó bạn sẽ vào được Admin Dashboard

## Bước 6: Customize (Optional)

Edit các constants trong các file này:

- `DBConfig.java` - Default DB values
- `ApiConfig.java` - Default API settings
- `web/assets/css/style.css` - Theme colors

## Troubleshooting

| Vấn Đề                          | Giải Pháp                                               |
| ------------------------------- | ------------------------------------------------------- |
| Cannot connect to database      | Kiểm tra SQL Server đang chạy, DB_USER/DB_PASSWORD đúng |
| Port 8080 đang được dùng        | Đổi port trong Tomcat config: `conf/server.xml`         |
| Environment variable không load | Restart IDE hoặc terminal                               |
| Chatbot lỗi                     | Kiểm tra GEMINI_API_KEY được set đúng                   |

## Tiếp Theo

-  Xem [README.md](README.md) để hiểu project structure
-  Xem [ENV_SETUP.md](ENV_SETUP.md) để setup chi tiết
-  Xem [MVC_STRUCTURE.md](MVC_STRUCTURE.md) để hiểu code organization

---

## Có vấn đề? Kiểm tra logs hoặc xem phần Troubleshooting.
