# Kiến trúc module Admin — S-COMS

Tài liệu này tóm tắt cấu trúc, luồng dữ liệu, và các điểm cần chú ý về phần **Admin** trong dự án S-COMS.

**Mục tiêu**: khi nhìn vào file này bạn sẽ hiểu nhanh nơi chứa view, controller, data access, cấu hình DB, và các thay đổi bảo mật quan trọng.

---

## 1. Tổng quan thành phần

- Giao diện (Views): các trang quản trị nằm trong thư mục `web/admin` (ví dụ: `dashboard.jsp`, `users.jsp`, `reports.jsp`).
  - Đường dẫn: [web/admin](web/admin)
- Controller (Servlets): xử lý request/response, xác thực, ủy quyền.
  - Các servlet chính liên quan tới admin: `AuthServlet`, `AdminServlet`, có trong `src/java/com/diabetes/monitoring/servlet/`.
  - Ví dụ: [src/java/com/diabetes/monitoring/servlet/AuthServlet.java](src/java/com/diabetes/monitoring/servlet/AuthServlet.java#L1)
- Data Access (DAO): truy cập DB cho account, báo cáo, lịch, v.v.
  - Thư mục: `src/java/com/diabetes/monitoring/dao/` (ví dụ `UserDAO.java`, `AdminDAO.java`) — tham chiếu: [src/java/com/diabetes/monitoring/dao](src/java/com/diabetes/monitoring/dao)
- Mô hình (Model): các POJO chứa dữ liệu (User, HealthRecord, ChatMessage)
  - Thư mục: `src/java/com/diabetes/monitoring/model/`
- Tiện ích (Utils): helper cho DB và bảo mật
  - `DatabaseConnection`: quản lý kết nối JDBC và tải cấu hình DB — [src/java/com/diabetes/monitoring/util/DatabaseConnection.java](src/java/com/diabetes/monitoring/util/DatabaseConnection.java#L1)
  - `PasswordUtil`: PBKDF2 hashing, verify, detect legacy SHA-256 — [src/java/com/diabetes/monitoring/util/PasswordUtil.java](src/java/com/diabetes/monitoring/util/PasswordUtil.java#L1)

## 2. Luồng chính (Admin login → trang quản trị)

1. Người dùng gửi POST tới `AuthServlet` với email/password.
2. `AuthServlet` gọi `UserDAO` để lấy password_hash từ DB.
3. `PasswordUtil.matches()` kiểm tra mật khẩu:
   - Nếu stored là `pbkdf2$...` → kiểm tra PBKDF2.
   - Nếu stored là 64-hex → so sánh SHA-256 (legacy).
4. Nếu khớp và `PasswordUtil.needsRehash()` trả true → `UserDAO` cập nhật password_hash mới (PBKDF2) để tự động migrate.
5. Sau login thành công, `AuthServlet` invalidates session cũ và tạo session mới để ngăn session fixation.
6. Truy cập các servlet admin tiếp theo tùy theo role; các servlet kiểm tra role/permissions trước khi trả view.

## 3. Cấu hình DB & cách runtime lấy secrets

- File cấu hình (local dev): `src/db.properties`. Nội dung tối thiểu:
  - `db.url` (ví dụ: `jdbc:sqlserver://host:1433;databaseName=project_SWP;encrypt=true;trustServerCertificate=true;`)
  - `db.user`
  - `db.password`
- Đã thêm `.gitignore` để tránh commit: `src/db.properties` và `db.properties`.
- `DatabaseConnection` cố gắng load theo thứ tự:
  1. classpath resource `db.properties` (ví dụ `WEB-INF/classes/db.properties`)
  2. filesystem: `src/db.properties` hoặc `db.properties`
  3. (fallback) — nếu không tìm thấy thì throw IllegalStateException (fail-fast). Xem file: [src/java/com/diabetes/monitoring/util/DatabaseConnection.java](src/java/com/diabetes/monitoring/util/DatabaseConnection.java#L1)
- Bạn có thể thay thế bằng env vars (`DB_URL`, `DB_USER`, `DB_PASSWORD`) nếu muốn — code hiện tại có hỗ trợ bằng cách chỉnh thêm nếu cần.

## 4. Bảo mật & chuyển đổi mật khẩu

- `PasswordUtil` dùng PBKDF2WithHmacSHA256, iterations = 100000, salt = 16 bytes, dkLen = 32 bytes.
- Format lưu trong DB: `pbkdf2$<iterations>$<base64(salt)>$<base64(hash)>`.
- `UserDAO` đã được chỉnh để tự động rehash khi người dùng đăng nhập bằng mật khẩu cũ (SHA-256 legacy).
- `admin_setup.py` đã được cập nhật để sinh và ghi PBKDF2 hash cho account seed.
  - Đường dẫn: [admin_setup.py](admin_setup.py#L1)

## 5. Frontend admin

- Các trang quản trị chính: `web/admin/*.jsp` (dashboard, users, reports, schedules, services).
- Fragment sidebar: `web/admin/fragments/sidebar.jspf` — dùng chung cho navigation.
- Form thay đổi mật khẩu/ tạo user: gửi trường `password` → backend sẽ hash trước khi lưu.

## 6. Build & Deploy

- Build dùng Ant (NetBeans layout). Main files:
  - `build.xml` (tùy chỉnh): [build.xml](build.xml#L1)
  - `nbproject/build-impl.xml` (generated)
- Tôi đã thêm một target `-post-compile` trong `build.xml` để copy `src/db.properties` vào `${build.classes.dir}` khi build (để file vào `WEB-INF/classes`).
- Nếu không dùng Ant local, bạn có thể:
  - đặt `web/WEB-INF/classes/db.properties` thủ công trước khi start Tomcat, hoặc
  - thiết lập biến môi trường `DB_URL/DB_USER/DB_PASSWORD` và chỉnh `DatabaseConnection` để ưu tiên env vars.

## 7. Vấn đề thường gặp & cách debug

- Lỗi khởi động: `NoClassDefFoundError` hoặc `ExceptionInInitializerError` kèm `IllegalStateException: db.properties not found` → nguyên nhân: `DatabaseConnection` fail-fast khi không tìm cấu hình.
  - Fix nhanh: copy `src/db.properties` vào `web/WEB-INF/classes/` hoặc set env vars.
- Lỗi kết nối SQL Server: kiểm tra driver (`com.microsoft.sqlserver.jdbc.SQLServerDriver`) và chuỗi URL (cần `encrypt=true;trustServerCertificate=true;` cho kết nối TLS).
- Nếu user seed không đăng nhập: chạy `admin_setup.py` sau khi đã cấu hình DB để upsert admin account (script đã dùng PBKDF2).

## 8. Nơi mở rộng/ chỉnh sửa

- Thêm RBAC kiểm tra mạnh hơn: kiểm tra role trong Filter trước khi servlet xử lý.
- Chuyển secrets khỏi file vào Secret Manager hoặc biến môi trường cho môi trường production.
- Giám sát đăng nhập bất thường + lock account khi quá nhiều lần thất bại.

## 9. Tài liệu tham chiếu nhanh (file quan trọng)

- `DatabaseConnection`: [src/java/com/diabetes/monitoring/util/DatabaseConnection.java](src/java/com/diabetes/monitoring/util/DatabaseConnection.java#L1)
- `PasswordUtil`: [src/java/com/diabetes/monitoring/util/PasswordUtil.java](src/java/com/diabetes/monitoring/util/PasswordUtil.java#L1)
- Servlets: [src/java/com/diabetes/monitoring/servlet](src/java/com/diabetes/monitoring/servlet)
- DAOs: [src/java/com/diabetes/monitoring/dao](src/java/com/diabetes/monitoring/dao)
- Admin views: [web/admin](web/admin)
- Admin seed script: [admin_setup.py](admin_setup.py#L1)

---

Nếu bạn muốn, tôi có thể:
- Thêm sơ đồ luồng (mermaid) vào file này, hoặc
- Mở rộng phần "Debug" với các câu lệnh log/stacktrace thực tế, hoặc
- Sinh checklist deploy an toàn (env vars, secrets, migrations).

Chọn bước tiếp theo: sơ đồ/ debug checklist/ deploy checklist.

---

## 10. Sơ đồ luồng (Mermaid)

Dưới đây là sơ đồ luồng chính khi Admin đăng nhập và truy cập dashboard.

```mermaid
flowchart TD
  A[Admin - Login form] -->|POST /auth| B(AuthServlet)
  B --> C{Fetch user row}
  C --> D[UserDAO: SELECT password_hash]
  D --> E[PasswordUtil.matches()]
  E -->|legacy SHA-256| F[Rehash -> UserDAO.updatePassword()]
  E -->|OK| G[Invalidate session, create new session]
  G --> H[Set session attributes (userId, role)]
  H --> I[Redirect to /admin/dashboard]
  I --> J[AdminServlet checks role -> render dashboard.jsp]

  subgraph DB
    D
  end

  style DB fill:#f9f,stroke:#333,stroke-width:1px
```

---

## 11. Mở rộng phần Debug — lỗi thường gặp và cách sửa

- Lỗi: `ExceptionInInitializerError` / `IllegalStateException: db.properties not found on classpath`
  - Nguyên nhân: `DatabaseConnection` fail-fast khi không tìm thấy file cấu hình.
  - Fix nhanh:

```powershell
# Copy config vào classpath của webapp
copy .\src\db.properties .\web\WEB-INF\classes\db.properties

# Hoặc set biến môi trường cho phiên hiện tại
$env:DB_URL = "jdbc:sqlserver://db-host:1433;databaseName=project_SWP;encrypt=true;trustServerCertificate=true;"
$env:DB_USER = "your_user"
$env:DB_PASSWORD = "your_password"

# Build project (nếu có ant)
ant -f build.xml

# Start Tomcat service (nếu service tên Tomcat10)
Start-Service -Name Tomcat10
Get-Service -Name Tomcat10
```

- Lỗi: `com.microsoft.sqlserver.jdbc.SQLServerException: The certificate chain was issued by an authority that is not trusted.`
  - Nguyên nhân: kết nối TLS yêu cầu certificate trust.
  - Fix: đảm bảo chuỗi kết nối có `encrypt=true;trustServerCertificate=true;` trong `db.url`, hoặc cài chứng chỉ CA phù hợp.

- Lỗi: `org.postgresql.util.PSQLException` hoặc driver không tìm thấy
  - Nguyên nhân: driver JDBC không có trong `WEB-INF/lib`.
  - Fix: đảm bảo thư viện JDBC driver có trong `lib/` và được copy vào `WEB-INF/lib` khi build.

### Kiểm tra log startup và stacktrace

- Xem file catalina.out hoặc Windows Event Log (service) để lấy stacktrace đầy đủ.
- Từ stacktrace, tìm lớp lỗi đầu tiên trong mã nguồn của dự án (ví dụ: `com.diabetes.monitoring.util.DatabaseConnection`) — đó thường là nguyên nhân gốc.

### Kiểm tra nhanh bằng lệnh

```powershell
# Hiển thị service Tomcat hiện có
Get-Service | Where-Object { $_.DisplayName -like '*Tomcat*' } | Format-Table Name,DisplayName,Status

# Lấy Path của service (để xác định CATALINA_HOME)
Get-CimInstance -ClassName Win32_Service -Filter "Name='Tomcat10'" | Select-Object Name,PathName

# Kiểm tra file properties trên classpath deploy
Test-Path .\web\WEB-INF\classes\db.properties
Get-Content .\web\WEB-INF\classes\db.properties
```

---

Đã bổ sung sơ đồ và mở rộng hướng debug. Nếu bạn muốn, tôi sẽ (1) cập nhật checklist deploy an toàn hoặc (2) chèn ví dụ stacktrace mẫu và chỉ ra file/line cụ thể trong repo. Chọn 1 hoặc 2.