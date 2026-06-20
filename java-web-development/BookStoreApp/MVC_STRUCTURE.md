# Cấu Trúc MVC - FPT Book Store

## Tổng Quan

Project sử dụng mô hình MVC (Model-View-Controller) với Jakarta EE Servlet/JSP.

## Cấu Trúc Thư Mục

### 1. MODEL (src/java/model/)

Chứa các lớp đại diện cho dữ liệu của ứng dụng.

```text
model/
├── Account.java       → Thông tin tài khoản người dùng
├── Book.java          → Thông tin sách (id, title, author, edition, price, etc.)
├── Category.java      → Danh mục sách
├── CartItem.java      → Mục trong giỏ hàng
├── Order.java         → Hóa đơn/Đơn hàng
└── OrderDetail.java   → Chi tiết đơn hàng
```

**Trách nhiệm:**

- Định nghĩa cấu trúc dữ liệu
- Getters/Setters
- Mapping với database

---

### 2. VIEW (web/views/)

Chứa tất cả các trang JSP để hiển thị giao diện.

```text
web/
├── views/
│   ├── common/
│   │   ├── navbar.jsp       → Thanh navigation
│   │   ├── header.jsp       → Header chung
│   │   ├── footer.jsp       → Footer chung
│   │   └── sidebar.jsp      → Sidebar (nếu có)
│   │
│   ├── user/                → Trang người dùng thường
│   │   ├── list.jsp         → Danh sách sách
│   │   ├── detail.jsp       → Chi tiết sách
│   │   ├── cart.jsp         → Giỏ hàng
│   │   ├── checkout.jsp     → Thanh toán
│   │   ├── history.jsp      → Lịch sử đơn hàng
│   │   ├── order-detail.jsp → Chi tiết đơn hàng
│   │   ├── login.jsp        → Đăng nhập
│   │   ├── register.jsp     → Đăng ký
│   │   ├── chatbot.jsp      → Chatbot gợi ý sách
│   │   └── index.html       → Trang chủ
│   │
│   └── admin/               → Trang quản trị viên
│       ├── admin-dashboard.jsp      → Dashboard
│       ├── admin-products.jsp       → Quản lý sách
│       ├── admin-product-form.jsp   → Form thêm/sửa sách
│       ├── admin-orders.jsp         → Quản lý đơn hàng
│       ├── admin-order-detail.jsp   → Chi tiết đơn hàng
│       ├── admin-revenue.jsp        → Báo cáo doanh thu
│       └── invoice.jsp              → Hóa đơn
│
└── assets/                  → Tài nguyên tĩnh
    ├── css/
    │   └── style.css        → CSS tùy chỉnh (Bootstrap từ CDN)
    ├── js/
    │   └── script.js        → JavaScript tùy chỉnh
    └── images/              → Hình ảnh sách, logo, etc.
```

**Trách nhiệm:**

- Hiển thị dữ liệu cho người dùng
- Gửi form đến Controller
- Không chứa logic business

---

### 3. CONTROLLER (src/java/controller/)

Chứa các Servlet xử lý request từ người dùng.

```
controller/
├── ListBookServlet.java          → GET: Hiển thị danh sách sách
├── DetailServlet.java            → GET: Xem chi tiết sách
├── AddToCartServlet.java         → GET/POST: Thêm sách vào giỏ
├── UpdateCartServlet.java        → POST: Cập nhật giỏ hàng
├── RemoveItemServlet.java        → GET: Xóa mục khỏi giỏ
├── CheckoutServlet.java          → GET/POST: Thanh toán
├── LoginServlet.java             → GET/POST: Đăng nhập
├── LogoutServlet.java            → GET: Đăng xuất
├── RegisterServlet.java          → GET/POST: Đăng ký
├── HistoryServlet.java           → GET: Xem lịch sử đơn hàng
├── OrderDetailServlet.java       → GET: Xem chi tiết đơn hàng
├── DeleteOrderServlet.java       → POST: Hủy đơn hàng
├── BookChatbotServlet.java       → GET: Gợi ý sách (AI)
│
├── AdminDashboardServlet.java    → GET: Dashboard quản trị
├── AdminProductServlet.java      → GET/POST: Quản lý sách
├── AdminOrderServlet.java        → GET/POST: Quản lý đơn hàng
├── AdminOrderDetailServlet.java  → GET: Chi tiết đơn hàng (admin)
└── AdminRevenueServlet.java      → GET: Báo cáo doanh thu
```

**Trách nhiệm:**

- Nhận request từ người dùng
- Gọi Model để lấy/xử lý dữ liệu
- Chọn View để hiển thị
- Điều hướng luồng ứng dụng

---

### 4. DATA ACCESS LAYER (src/java/dal/)

Chứa class DAO (Data Access Object) để tương tác với database.

```
dal/
└── BookDAO.java
    ├── getConnection()                  → Tạo kết nối CSDL
    ├── getAllBooks()                    → Lấy danh sách sách
    ├── getBookById()                    → Lấy sách theo ID
    ├── insertBook()                     → Thêm sách mới
    ├── updateBook()                     → Cập nhật sách
    ├── deleteBook()                     → Xóa sách
    ├── searchBooks()                    → Tìm kiếm sách
    │
    ├── login()                          → Xác thực đăng nhập
    ├── registerAccount()                → Đăng ký tài khoản
    ├── hashPassword()                   → Mã hóa mật khẩu (BCrypt)
    ├── verifyPassword()                 → Kiểm tra mật khẩu
    │
    ├── getCategories()                  → Lấy danh mục
    ├── insertCategory()                 → Thêm danh mục
    ├── deleteCategory()                 → Xóa danh mục
    │
    ├── getAllOrders()                   → Lấy đơn hàng
    ├── getOrderById()                   → Lấy chi tiết đơn hàng
    ├── getUserOrders()                  → Lấy đơn hàng của user
    ├── insertOrder()                    → Tạo đơn hàng mới
    ├── insertOrderDetail()              → Thêm chi tiết đơn hàng
    ├── updateOrderStatus()              → Cập nhật trạng thái đơn
    ├── deleteOrder()                    → Hủy đơn hàng
    │
    ├── updateCartTotal()                → Cập nhật tổng giỏ hàng
    ├── getCartItems()                   → Lấy items trong giỏ
    ├── updateStockQuantity()            → Cập nhật tồn kho
    ├── getLowStockBooks()               → Sách cạn hàng
    │
    └── getTotalRevenue()                → Tính doanh thu
```

**Trách vụ:**

- Kết nối database
- Thực thi SQL queries
- Mapping ResultSet → Object
- Xử lý ngoại lệ CSDL

---

### 5. UTILITIES (src/java/utils/) - _Tạo thêm_

Chứa các lớp hỗ trợ tiện ích.

```
utils/
├── ValidationUtil.java          → Kiểm tra dữ liệu input
├── DateUtil.java                → Xử lý ngày tháng
├── EmailUtil.java               → Gửi email (nếu cần)
├── PaginationUtil.java          → Phân trang dữ liệu
├── ImageUtil.java               → Xử lý ảnh
└── SecurityUtil.java            → Hàm bảo mật
```

---

## Quy Trình Xử Lý Request (Request-Response Cycle)

```
1. USER (trình duyệt)
   └─> Gửi request đến URL

2. CONTROLLER (Servlet)
   └─> Nhận request
   └─> Xác thực session/cookies
   └─> Xác nhận quyền hạn (admin, user)

3. MODEL (DAO)
   └─> Lấy dữ liệu từ CSDL
   └─> Thực hiện business logic

4. CONTROLLER (tiếp tục)
   └─> Đưa dữ liệu vào request scope/session
   └─> Chọn VIEW thích hợp

5. VIEW (JSP)
   └─> Nhận dữ liệu từ request/session
   └─> Render HTML + dữ liệu
   └─> Gửi về trình duyệt

6. USER (nhìn thấy kết quả)
```

---

## Ví Dụ: Quy Trình Xem Danh Sách Sách

```
User clicks "Home" on navbar
  ↓
ListBookServlet.doGet() is called
  ├─ Get category filter from request
  ├─ Get search keyword from request
  ├─ Call BookDAO.getAllBooks(cid, keyword)
  │   ├─ Connect to database
  │   ├─ Execute SQL SELECT
  │   ├─ Map ResultSet to List<Book>
  │   └─ Return list
  ├─ Call BookDAO.getAllCategories()
  │   └─ Return categories for sidebar
  ├─ Store data in request:
  │   └─ request.setAttribute("data", bookList)
  │   └─ request.setAttribute("categories", catList)
  ├─ Forward to JSP:
  │   └─ request.getRequestDispatcher("views/user/list.jsp").forward(req, res)
  └─ Return HTML page to browser
      ↓
list.jsp receives request with data
  ├─ Extract books from request: ${data}
  ├─ Loop through books and display
  ├─ Include navbar: <jsp:include page="views/common/navbar.jsp">
  ├─ Include footer: <jsp:include page="views/common/footer.jsp">
  └─ Render HTML + CSS + Bootstrap
      ↓
User sees beautiful book listing page
```

---

## Database Schema

```
Account
├── id (PK)
├── username
├── password (BCrypt hash)
├── email
├── fullname
├── isAdmin

Category
├── id (PK)
└── name

Book
├── id (PK)
├── title
├── author          ← Tác giả (NEW)
├── edition         ← Tái bản (NEW)
├── price
├── image
├── cid (FK → Category)
├── description
└── stock

Order
├── id (PK)
├── aid (FK → Account)
├── totalPrice
├── createdDate
└── status

OrderDetail
├── id (PK)
├── oid (FK → Order)
├── bid (FK → Book)
└── quantity
```

---

## Công Nghệ Sử Dụng

| Layer        | Technology    | Version         |
| ------------ | ------------- | --------------- |
| **Backend**  | Jakarta EE    | 6.0             |
| **Servlet**  | HttpServlet   | 6.0             |
| **View**     | JSP           | 3.1             |
| **Database** | SQL Server    | 2019+           |
| **Driver**   | JDBC          | SQLServerDriver |
| **Frontend** | Bootstrap     | 5.3.0 (CDN)     |
| **Security** | BCrypt        | 0.9.1           |
| **API**      | Google Gemini | (Chatbot)       |

---

## Hướng Dẫn Di Chuyển File (Lựa chọn)

Nếu bạn muốn di chuyển JSP sang cấu trúc views/ mới:

1. **User pages:**
   - `web/list.jsp` → `web/views/user/list.jsp`
   - `web/detail.jsp` → `web/views/user/detail.jsp`
   - `web/login.jsp` → `web/views/user/login.jsp`
   - `web/register.jsp` → `web/views/user/register.jsp`
   - `web/cart.jsp` → `web/views/user/cart.jsp`
   - `web/checkout.jsp` → `web/views/user/checkout.jsp`
   - `web/history.jsp` → `web/views/user/history.jsp`
   - `web/order-detail.jsp` → `web/views/user/order-detail.jsp`
   - `web/chatbot.jsp` → `web/views/user/chatbot.jsp`

2. **Admin pages:**
   - `web/admin-dashboard.jsp` → `web/views/admin/dashboard.jsp`
   - `web/admin-products.jsp` → `web/views/admin/products.jsp`
   - `web/admin-product-form.jsp` → `web/views/admin/product-form.jsp`
   - `web/admin-orders.jsp` → `web/views/admin/orders.jsp`
   - `web/admin-order-detail.jsp` → `web/views/admin/order-detail.jsp`
   - `web/admin-revenue.jsp` → `web/views/admin/revenue.jsp`

3. **Update servlet forward paths:**

   ```java
   // Before
   request.getRequestDispatcher("list.jsp").forward(req, res);

   // After
   request.getRequestDispatcher("views/user/list.jsp").forward(req, res);
   ```

---

## Lợi Ích Của Cấu Trúc MVC

✅ **Tách rời:** Model, View, Controller độc lập  
✅ **Dễ bảo trì:** Dễ tìm và sửa lỗi  
✅ **Tái sử dụng:** Code được chia nhỏ, dễ tái sử dụng  
✅ **Testable:** Từng layer có thể test độc lập  
✅ **Scalable:** Dễ mở rộng tính năng mới  
✅ **Chuẩn:** Theo tiêu chuẩn JEE/Servlet

---

**Ghi chú:** Project hiện tại đã tuân theo MVC với cấu trúc:

- `src/java/controller/` → Controllers
- `src/java/model/` → Models
- `src/java/dal/` → Data Access Layer
- `web/` → Views

Cấu trúc mới chỉ là tổ chức tốt hơn cho các JSP và assets!
