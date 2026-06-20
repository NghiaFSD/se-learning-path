# BookStoreApp - Ứng dụng bán sách

> Ứng dụng web đầy đủ chức năng để quản lý và bán sách trực tuyến, xây dựng bằng Jakarta EE (Servlet/JSP) và SQL Server

![Java](https://img.shields.io/badge/Java-ED8B00?style=flat&logo=java&logoColor=white)
![Jakarta EE](https://img.shields.io/badge/Jakarta%20EE-6.0-blue)
![SQL Server](https://img.shields.io/badge/SQL%20Server-2019%2B-CC2927)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5.3.0-purple)

## Tổng quan dự án

BookStoreApp là một nền tảng thương mại điện tử minh họa phát triển web chuyên nghiệp sử dụng Jakarta EE (Servlet/JSP). Bao gồm giao diện người dùng và quản trị, CRUD, xác thực an toàn và chatbot AI.

## Tính năng chính

### Tính năng người dùng

- Duyệt sách - Hiển thị danh mục với bộ lọc nâng cao (danh mục, tìm kiếm, khoảng giá)
- Giỏ hàng thông minh - Thêm/loại mục với cập nhật thời gian thực
- Thanh toán an toàn - Quy trình nhiều bước với kiểm tra hợp lệ
- Lịch sử đơn hàng - Theo dõi các đơn hàng trước đó với thông tin chi tiết
- Chatbot AI - Gợi ý sách (Google Gemini)
- Xác thực người dùng - Đăng nhập/Đăng ký an toàn với BCrypt

### Tính năng quản trị

- Bảng điều khiển - Tổng quan phân tích với số liệu bán hàng và tồn kho
- Quản lý sản phẩm - Thêm, sửa, xóa sách với thông tin tác giả và tái bản
- Quản lý đơn hàng - Xem, xử lý và quản lý đơn hàng
- Báo cáo doanh thu - Theo dõi hiệu suất bán và xu hướng sách
- Cảnh báo tồn kho thấp - Thông báo tự động khi tồn kho dưới ngưỡng
- Quản lý người dùng - Phân quyền và quản lý tài khoản quản trị

### Tính năng bảo mật

- Mã hoá mật khẩu (BCrypt) - Chi phí 12, tiêu chuẩn công nghiệp
- Quản lý phiên - Xác thực người dùng an toàn với theo dõi phiên
- Ngăn chặn SQL Injection - Sử dụng PreparedStatement cho các truy vấn
- Hỗ trợ nâng cấp mật khẩu cũ - Tự động nâng cấp hash BCrypt cho mật khẩu cũ

## Công nghệ

| Component          | Technology             | Version     |
| ------------------ | ---------------------- | ----------- |
| Backend Framework  | Jakarta EE Servlet/JSP | 6.0         |
| Database           | SQL Server             | 2019+       |
| JDBC Driver        | SQLServerDriver        | 13.2.0      |
| Frontend Framework | Bootstrap              | 5.3.0 (CDN) |
| Security           | BCrypt                 | 0.9.1       |
| External API       | Google Gemini          | (Chatbot)   |
| Build Tool         | Apache Ant/NetBeans    | -           |
| Server             | Apache Tomcat          | 10+         |

## Cấu trúc dự án (MVC)

```text
BookStoreApp/
├── src/java/
│   ├── controller/        # HTTP Request Handlers (18 Servlets)
│   ├── model/             # Data Models (6 classes)
│   ├── dal/               # Data Access Layer (BookDAO)
│   └── utils/             # Helper Utilities
│
├── web/
│   ├── views/
│   │   ├── user/          # Customer pages
│   │   └── admin/         # Administrator pages
│   ├── assets/            # CSS, JavaScript, Images
│   ├── WEB-INF/
│   │   ├── web.xml        # Deployment descriptor
│   │   └── lib/           # JAR dependencies
│   └── META-INF/
│
├── nbproject/             # NetBeans project config
├── build.xml              # Ant build script
└── README.md
```

## Cơ sở dữ liệu

### Core Tables

- Account - User credentials and profiles
- Category - Book categories/genres
- Book- Book catalog with author, edition, price, stock
- Order - Customer orders
- OrderDetail - Items in each order

### Sample Data

- 37 Books with complete metadata (title, author, edition, price, stock)
- 5 Categories (Literature, Technology, etc.)
- Pre-configured Admin Account

## Bắt đầu

### Yêu cầu

- Java 11+ (JDK)
- SQL Server 2019+ or SQL Express
- Apache Tomcat 10+
- NetBeans IDE (optional, but recommended)
- Git

### Cài đặt

1. **Clone the Repository**

   ```bash
   git clone https://github.com/yourusername/BookStoreApp.git
   cd BookStoreApp
   ```

2. Setup Database

   ```sql
   -- Create database
   CREATE DATABASE BookStoreDB;

   -- Run schema script
   -- (Located in db/ folder or execute via SQL Server Management Studio)
   ```

3. Configure Connection
   - Edit `src/java/dal/BookDAO.java`
   - Update SQL Server connection details:
     ```java
     String url = "jdbc:sqlserver://localhost:1433;databaseName=BookStoreDB";
     String user = "sa";
     String password = "your_password";
     ```

4. Build & Deploy

   ```
   bash
   # Using Ant
   ant clean build

   # Or use NetBeans: Right-click project → Clean and Build
   ```

5. Run Application
   - Deploy to Tomcat
   - Access: `http://localhost:8080/BookStoreApp/home`

### Thông tin đăng nhập mặc định

- Admin User
  - Username: `admin`
  - Password: `admin123`
- Regular User (Create new account on registration page)

## Application Flow

### User Journey

```
Home Page
  ├─→ Browse Books (filter by category, search, price)
  ├─→ View Book Details
  ├─→ Add to Cart
  ├─→ Manage Cart (update quantity, remove items)
  ├─→ Checkout
  ├─→ Order Confirmation
  └─→ View Order History

Authentication
  ├─→ Login (with BCrypt verification)
  ├─→ Register (new account with hashed password)
  └─→ Logout
```

### Admin Workflow

```
Admin Dashboard
  ├─→ View Sales Analytics
  ├─→ Manage Products (CRUD operations)
  ├─→ Manage Orders (process, track, cancel)
  ├─→ View Revenue Reports
  └─→ Check Inventory Alerts
```

## Chi tiết triển khai

### Password Security

- Algorithm: BCrypt with salt
- Cost Factor: 12 (prevents brute-force)
- Legacy Support: Automatic hash upgrade for old passwords

### Database Queries

- SQL Injection Prevention: All queries use `PreparedStatement`
- Performance: Indexed queries with proper pagination
- ACID Compliance: Transaction support for orders

### Session Management

- Authentication: HttpSession with user object
- Role-based Access: Admin vs Regular User privileges
- Timeout: Configurable session expiration

### AI Integration

- Chatbot Service: Google Gemini API integration
- Recommendations: Smart book suggestions based on user preferences
- Natural Language: Conversational book discovery

## Tính năng hiệu năng

Efficient database queries with proper filtering  
 Responsive Bootstrap UI with mobile optimization  
 Pagination for large book catalogs  
 Image caching and CDN delivery (Bootstrap CDN)  
 Session-based cart persistence

## Testing

### Manual Testing Checklist

- [ ] User registration with validation
- [ ] Login with wrong credentials
- [ ] BCrypt password verification
- [ ] Cart operations (add, update, remove)
- [ ] Order placement and confirmation
- [ ] Admin product CRUD
- [ ] Order status updates
- [ ] Search and filter functionality
- [ ] Chatbot recommendations

### Edge Cases Handled

- Empty search results
- Insufficient stock
- Duplicate book entries
- Invalid user input
- Session timeout
- Concurrent cart updates

## Code Quality

- MVC Pattern: Clear separation of concerns
- SOLID Principles: Single responsibility, proper abstraction
- Comments: Javadoc comments on all public methods
- Naming Conventions: Follows Java standards
- Error Handling: Try-catch blocks with meaningful messages

## Git Workflow

```bash
# Create feature branch
git checkout -b feature/new-feature

# Commit changes
git add .
git commit -m "Add new feature description"

# Push to GitHub
git push origin feature/new-feature

# Create Pull Request on GitHub
```

## Documentation

- [MVC_STRUCTURE.md](MVC_STRUCTURE.md) - Detailed project structure explanation
- [SETUP_QUICK.md](SETUP_QUICK.md) - Installation and configuration guide
- Code Comments - Javadoc on all classes and methods

## Contributing

This is a portfolio project. For educational purposes and feedback:

1. Fork the repository
2. Create feature branch (`git checkout -b improvement/feature`)
3. Commit your changes
4. Push to branch
5. Open Pull Request

## License

This project is open source under the **MIT License** - see [LICENSE](LICENSE) file for details.

## Author

LeTrongNghia

- GitHub: [@NghiaFSD](https://github.com/NghiaFSD)
- LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/in/nghiafsd/)
- Email: lenghia211105@gmail.com

## Acknowledgments

- FPT University - PRJ301 Course
- Jakarta EE Documentation
- Bootstrap Framework Team
- Google Gemini API

## Support

For questions or issues: 097-345-7532

1. Check existing GitHub Issues
2. Create a new Issue with detailed description
3. Include environment details (OS, Java version, etc.)

---

Status: Complete & Production Ready

Last Updated: April 2026

Version: 1.0.0
