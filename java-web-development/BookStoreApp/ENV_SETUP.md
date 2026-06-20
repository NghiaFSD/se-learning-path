# Hướng dẫn cấu hình môi trường

## 1. Database Configuration

Set các environment variables để kết nối SQL Server:

### Windows (Command Prompt)

```batch
setx DB_SERVER localhost
setx DB_PORT 1433
setx DB_NAME BookStoreDB
setx DB_USER sa
setx DB_PASSWORD 123
```

### Windows (PowerShell)

```powershell
$env:DB_SERVER = "localhost"
$env:DB_PORT = "1433"
$env:DB_NAME = "BookStoreDB"
$env:DB_USER = "sa"
$env:DB_PASSWORD = "123"
```

### Linux / macOS

```bash
export DB_SERVER=localhost
export DB_PORT=1433
export DB_NAME=BookStoreDB
export DB_USER=sa
export DB_PASSWORD=123
```

---

## 2. Google Gemini API Key

Set environment variable để sử dụng chatbot feature:

### Windows (Command Prompt)

```batch
setx GEMINI_API_KEY your_api_key_here
```

### Windows (PowerShell)

```powershell
$env:GEMINI_API_KEY = "your_api_key_here"
```

### Linux / macOS

```bash
export GEMINI_API_KEY=your_api_key_here
```

**Lấy API Key:**

1. Đi tới [Google AI Studio](https://aistudio.google.com)
2. Click "Get API Key"
3. Tạo API key mới
4. Copy và set vào environment variable

---

## 3. NetBeans Configuration

### Cách 1: Qua Run Configuration

1. Right-click project → Properties
2. Run tab → Set Properties
3. Add custom properties:
   ```
   DB_SERVER=localhost
   DB_PORT=1433
   DB_NAME=BookStoreDB
   DB_USER=sa
   DB_PASSWORD=123
   GEMINI_API_KEY=your_api_key_here
   ```

### Cách 2: Qua catalina.properties (Tomcat)

1. Tìm file: `TOMCAT_HOME/conf/catalina.properties`
2. Thêm vào cuối file:
   ```
   DB_SERVER=localhost
   DB_PORT=1433
   DB_NAME=BookStoreDB
   DB_USER=sa
   DB_PASSWORD=123
   GEMINI_API_KEY=your_api_key_here
   ```

### Cách 3: Qua setenv.bat/setenv.sh (Tomcat)

1. Tạo file `TOMCAT_HOME/bin/setenv.bat` (Windows) hoặc `setenv.sh` (Linux)
2. Thêm nội dung:

**setenv.bat (Windows):**

```batch
@echo off
set DB_SERVER=localhost
set DB_PORT=1433
set DB_NAME=BookStoreDB
set DB_USER=sa
set DB_PASSWORD=123
set GEMINI_API_KEY=your_api_key_here
```

**setenv.sh (Linux/macOS):**

```bash
#!/bin/bash
export DB_SERVER=localhost
export DB_PORT=1433
export DB_NAME=BookStoreDB
export DB_USER=sa
export DB_PASSWORD=123
export GEMINI_API_KEY=your_api_key_here
```

---

## 4. Verification

### Kiểm tra xem config được load đúng:

**Phương pháp 1:** Xem logs khi startup Tomcat

```
Logs sẽ hiện thị kết nối đến: jdbc:sqlserver://localhost:1433;...
```

**Phương pháp 2:** Kiểm tra kết nối database

1. Truy cập `/home` page
2. Nếu thấy danh sách sách → Database config OK
3. Nếu có error → Kiểm tra credentials

**Phương pháp 3:** Kiểm tra Gemini API

1. Truy cập `/chatbot` page
2. Nếu input form hiện ra → API config OK ✅
3. Nếu có error message → Kiểm tra API key

---

## 5. Bảo Mật (Security Best Practices)

Không được làm:

```
- Commit .env file lên GitHub
- Để API key trong source code
- Để database password trong comments
- Share credentials công khai
```

Nên làm:

```
- Sử dụng environment variables
- Thêm .env, config.properties vào .gitignore
- Rotate API keys thường xuyên
- Sử dụng strong passwords
- Hạn chế database user permissions
```

---

## 6. Production Deployment

Khi deploy lên production:

1. **Thay đổi DB_USER và DB_PASSWORD** - Không dùng `sa` account
2. **Tạo database user riêng** với permissions tối thiểu
3. **Sử dụng managed secrets** (AWS Secrets Manager, Azure Key Vault, etc.)
4. **Enable database encryption** - Sử dụng SSL/TLS
5. **Rotate API keys** - Thay đổi định kỳ

---

## 7. Troubleshooting

### "Cannot connect to database"

- ✓ Kiểm tra SQL Server đang chạy
- ✓ Kiểm tra DB_SERVER, DB_PORT
- ✓ Kiểm tra DB_USER, DB_PASSWORD

### "Chatbot không hoạt động"

- ✓ Kiểm tra GEMINI_API_KEY được set
- ✓ Kiểm tra API key hợp lệ
- ✓ Kiểm tra API quota không vượt

### "Environment variable không load"

- ✓ Restart IDE/Tomcat sau khi set
- ✓ Kiểm tra xem dùng đúng tên biến
- ✓ Dùng `System.getenv("VARIABLE_NAME")` để verify

---

**Liên Hệ:** Nếu có vấn đề, kiểm tra logs hoặc tham khảo phần Troubleshooting.
