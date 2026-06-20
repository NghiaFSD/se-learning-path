package dal;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import java.util.Map;
import model.Account;
import model.Book;
import model.CartItem;
import model.Category;
import model.Order;
import org.mindrot.jbcrypt.BCrypt;
import config.DBConfig;

/**
 * DAO xu ly toan bo thao tac CSDL lien quan den:
 * - Book / Category
 * - Account (login/register)
 * - Order + OrderDetail
 */
public class BookDAO {

    private static final int BCRYPT_COST = 12;

    /**
     * Tao ket noi toi SQL Server.
     * Connection details loaded from DBConfig (environment variables)
     */
    public Connection getConnection() throws Exception {
        String url = DBConfig.getConnectionString();
        String username = DBConfig.getUsername();
        String password = DBConfig.getPassword();

        Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        return DriverManager.getConnection(url, username, password);
    }

    /**
     * Lay danh sach sach theo danh muc va/hoac tu khoa tim kiem, va khoang gia.
     *
     * cid = "0" hoac rong thi lay tat ca danh muc.
     * txtSearch co gia tri thi loc theo tieu de sach.
     * priceMin/priceMax: khoang gia (neu co).
     */
    public List<Book> getAllBooks(String cid, String txtSearch, String priceMin, String priceMax) {
        List<Book> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT id, title, price, image, cid, description, stock, author, edition FROM Book WHERE 1=1");

        if (cid != null && !cid.equals("0") && !cid.isEmpty()) {
            sql.append(" AND cid = ").append(cid);
        }

        if (txtSearch != null && !txtSearch.isEmpty()) {
            sql.append(" AND title LIKE ?");
        }

        if (priceMin != null && !priceMin.isEmpty()) {
            sql.append(" AND price >= ?");
        }

        if (priceMax != null && !priceMax.isEmpty()) {
            sql.append(" AND price <= ?");
        }

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (txtSearch != null && !txtSearch.isEmpty()) {
                ps.setString(paramIndex++, "%" + txtSearch + "%");
            }
            if (priceMin != null && !priceMin.isEmpty()) {
                ps.setDouble(paramIndex++, Double.parseDouble(priceMin));
            }
            if (priceMax != null && !priceMax.isEmpty()) {
                ps.setDouble(paramIndex++, Double.parseDouble(priceMax));
            }

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Book(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getDouble("price"),
                        rs.getString("image"),
                        rs.getInt("cid"),
                        rs.getString("description"),
                        rs.getInt("stock"),
                        rs.getString("author"),
                        rs.getString("edition")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Vu trang thai cu, giu cho cac call site cu van chay duoc.
     */
    public List<Book> getAllBooks(String cid, String txtSearch) {
        return getAllBooks(cid, txtSearch, null, null);
    }

    /**
     * Lay chi tiet 1 sach theo id.
     */
    public Book getBookById(int id) {
        String sql = "SELECT id, title, price, image, cid, description, stock, author, edition FROM Book WHERE id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return new Book(
                        rs.getInt("id"),
                        rs.getString("title"),
                        rs.getDouble("price"),
                        rs.getString("image"),
                        rs.getInt("cid"),
                        rs.getString("description"),
                        rs.getInt("stock"),
                        rs.getString("author"),
                        rs.getString("edition"));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lay toan bo danh muc de hien thi bo loc.
     */
    public List<Category> getAllCategories() {
        List<Category> list = new ArrayList<>();
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement("SELECT * FROM Category");
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Category(rs.getInt(1), rs.getString(2)));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Kiem tra dang nhap bang username + password.
     *
     * Luong moi:
     * - Tai khoan da hash BCrypt: verify bang BCrypt.checkpw.
     * - Tai khoan plain-text cu: cho dang nhap 1 lan, sau do tu dong nang cap len
     * BCrypt.
     */
    public Account login(String u, String p) {
        String sql = "SELECT username, password, displayName, role FROM Account WHERE username = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, u);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String storedPassword = rs.getString("password");
                if (verifyPassword(p, storedPassword)) {
                    if (!isBcryptHash(storedPassword)) {
                        upgradeLegacyPasswordToBcrypt(conn, u, p);
                    }
                    return new Account(
                            rs.getString("username"),
                            "",
                            rs.getString("displayName"),
                            rs.getInt("role"));
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Kiem tra username da ton tai trong he thong chua.
     */
    public boolean isUsernameTaken(String username) {
        String sql = "SELECT COUNT(*) AS cnt FROM Account WHERE username = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("cnt") > 0;
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Dang ky tai khoan moi.
     * Neu username da ton tai thi tra ve false.
     * Mat khau duoc bam BCrypt truoc khi luu DB.
     */
    public boolean registerAccount(String username, String password, String displayName, int role) {
        if (isUsernameTaken(username)) {
            return false;
        }

        String sql = "INSERT INTO Account(username, password, displayName, role) VALUES(?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ps.setString(2, hashPassword(password));
            ps.setString(3, displayName);
            ps.setInt(4, role);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Bam mat khau bang BCrypt voi cost factor BCRYPT_COST.
     * Moi lan goi se sinh salt ngau nhien -> cung password cho ra hash khac nhau.
     */
    private String hashPassword(String rawPassword) {
        return BCrypt.hashpw(rawPassword, BCrypt.gensalt(BCRYPT_COST));
    }

    /**
     * Kiem tra xem chuoi co phai la BCrypt hash hop le khong.
     * BCrypt hash bat dau bang $2a$, $2b$ hoac $2y$.
     */
    private boolean isBcryptHash(String value) {
        if (isBlank(value)) {
            return false;
        }
        return value.startsWith("$2a$") || value.startsWith("$2b$") || value.startsWith("$2y$");
    }

    /**
     * Xac minh mat khau nguoi dung nhap voi mat khau luu trong DB.
     * - Neu DB dang luu BCrypt hash: dung BCrypt.checkpw de so sanh.
     * - Neu DB dang luu plain-text (tai khoan cu): so sanh truc tiep,
     * sau do login() se tu dong nang cap len BCrypt.
     */
    private boolean verifyPassword(String rawPassword, String storedPassword) {
        if (isBlank(rawPassword) || isBlank(storedPassword)) {
            return false;
        }

        if (isBcryptHash(storedPassword)) {
            try {
                return BCrypt.checkpw(rawPassword, storedPassword);
            } catch (IllegalArgumentException e) {
                return false;
            }
        }

        return rawPassword.equals(storedPassword);
    }

    /**
     * Nang cap mat khau plain-text cu cua tai khoan len BCrypt hash.
     * Chi goi khi verifyPassword thanh cong nhung storedPassword chua phai BCrypt.
     * Dung lai Connection cu (cung transaction) de tranh mo them ket noi.
     */
    private void upgradeLegacyPasswordToBcrypt(Connection conn, String username, String rawPassword)
            throws SQLException {
        String sql = "UPDATE Account SET password = ? WHERE username = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, hashPassword(rawPassword));
            ps.setString(2, username);
            ps.executeUpdate();
        }
    }

    /** Tra ve true neu chuoi null hoac chi chua khoang trang. */
    private boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    /**
     * Lay ton kho hien tai cua 1 sach.
     */
    public int getBookStock(int bid) {
        String sql = "SELECT stock FROM Book WHERE id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, bid);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt("stock");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Giam ton kho theo kieu an toan: chi update khi stock >= quantity.
     * Ham nay duoc goi ben trong transaction.
     */
    public boolean reduceBookStock(int bid, int quantity, Connection conn) throws SQLException {
        String sql = "UPDATE Book SET stock = stock - ? WHERE id = ? AND stock >= ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, quantity);
            ps.setInt(2, bid);
            ps.setInt(3, quantity);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Kiem tra ton kho co du cho so luong can mua hay khong.
     */
    public boolean isStockAvailable(int bid, int required) {
        int stock = getBookStock(bid);
        return stock >= required;
    }

    /**
     * Tao don hang moi + chi tiet don + tru ton kho trong 1 transaction.
     *
     * Neu bat ky buoc nao that bai -> rollback va tra ve false.
     */
    public boolean insertOrder(Account acc, Map<Integer, CartItem> cart, double total, String phone, String address) {
        String sqlOrder = "INSERT INTO [Order](username, totalPrice, phone, address) VALUES(?, ?, ?, ?)";
        String sqlDetail = "INSERT INTO OrderDetail(oid, bid, quantity, price) VALUES(?, ?, ?, ?)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);

            // 1) Kiem tra ton kho truoc khi tao don
            for (CartItem item : cart.values()) {
                int bid = item.getBook().getId();
                int qty = item.getQuantity();
                if (!isStockAvailable(bid, qty)) {
                    conn.rollback();
                    return false;
                }
            }

            // 2) Tao ban ghi Order va lay oid vua tao
            try (PreparedStatement ps1 = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                ps1.setString(1, acc.getUsername());
                ps1.setDouble(2, total);
                ps1.setString(3, phone);
                ps1.setString(4, address);
                ps1.executeUpdate();

                try (ResultSet rs = ps1.getGeneratedKeys()) {
                    if (rs.next()) {
                        int oid = rs.getInt(1);

                        // 3) Tao cac dong OrderDetail + giam ton kho
                        try (PreparedStatement ps2 = conn.prepareStatement(sqlDetail)) {
                            for (CartItem item : cart.values()) {
                                int bid = item.getBook().getId();
                                int qty = item.getQuantity();

                                if (!reduceBookStock(bid, qty, conn)) {
                                    conn.rollback();
                                    return false;
                                }

                                ps2.setInt(1, oid);
                                ps2.setInt(2, bid);
                                ps2.setInt(3, qty);
                                ps2.setDouble(4, item.getBook().getPrice());
                                ps2.executeUpdate();
                            }
                        }
                    } else {
                        conn.rollback();
                        return false;
                    }
                }
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lay lich su don hang cua 1 user, sap xep moi nhat truoc.
     */
    public List<Order> getHistory(String username) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT oid, username, totalPrice, orderDate, phone, address, status FROM [Order] WHERE username = ? ORDER BY orderDate DESC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, username);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Order o = new Order(
                        rs.getInt(1),
                        rs.getString(2),
                        rs.getDouble(3),
                        rs.getTimestamp(4),
                        rs.getString(5),
                        rs.getString(6));
                o.setStatus(rs.getString("status"));
                list.add(o);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lay don hang theo moc thoi gian (ngay/thang/nam co the null).
     * Dung cho trang doanh thu admin.
     */
    public List<Order> getOrdersByPeriod(Integer day, Integer month, Integer year) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.oid, o.username, COALESCE(a.displayName, o.username) AS displayName, "
                        + "o.totalPrice, o.orderDate, o.phone, o.address, o.status "
                        + "FROM [Order] o LEFT JOIN Account a ON o.username = a.username WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (year != null) {
            sql.append(" AND YEAR(o.orderDate) = ?");
            params.add(year);
        }
        if (month != null) {
            sql.append(" AND MONTH(o.orderDate) = ?");
            params.add(month);
        }
        if (day != null) {
            sql.append(" AND DAY(o.orderDate) = ?");
            params.add(day);
        }
        sql.append(" ORDER BY o.orderDate DESC");
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order(
                            rs.getInt("oid"), rs.getString("username"), rs.getDouble("totalPrice"),
                            rs.getTimestamp("orderDate"), rs.getString("phone"), rs.getString("address"),
                            rs.getString("displayName"));
                    o.setStatus(rs.getString("status"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tinh tong doanh thu trong moc thoi gian (ngay/thang/nam co the null).
     */
    public Map<String, Double> getRevenueSummary(Integer day, Integer month, Integer year) {
        Map<String, Double> summary = new HashMap<>();
        StringBuilder sql = new StringBuilder(
                "SELECT status, COALESCE(SUM(totalPrice), 0) AS revenue FROM [Order] WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (year != null) {
            sql.append(" AND YEAR(orderDate) = ?");
            params.add(year);
        }
        if (month != null) {
            sql.append(" AND MONTH(orderDate) = ?");
            params.add(month);
        }
        if (day != null) {
            sql.append(" AND DAY(orderDate) = ?");
            params.add(day);
        }
        sql.append(" GROUP BY status");

        double actualRevenue = 0;
        double projectedRevenue = 0;
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String status = rs.getString("status");
                    double revenue = rs.getDouble("revenue");
                    if ("Hoàn thành".equals(status)) {
                        actualRevenue += revenue;
                    } else if ("Chờ xác nhận".equals(status) || "Đang giao".equals(status)) {
                        projectedRevenue += revenue;
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

        summary.put("actualRevenue", actualRevenue);
        summary.put("projectedRevenue", projectedRevenue);
        return summary;
    }

    /**
     * Tinh tong doanh thu trong moc thoi gian (ngay/thang/nam co the null).
     * Chi tinh tren cac don hoan thanh.
     */
    public double getTotalRevenue(Integer day, Integer month, Integer year) {
        return getRevenueSummary(day, month, year).get("actualRevenue");
    }

    /**
     * Lay thong tin 1 don hang theo oid, kem ten hien thi cua khach hang.
     */
    public Order getOrderById(int oid) {
        String sql = "SELECT o.oid, o.username, COALESCE(a.displayName, o.username) AS displayName, "
                + "o.totalPrice, o.orderDate, o.phone, o.address, o.status "
                + "FROM [Order] o LEFT JOIN Account a ON o.username = a.username "
                + "WHERE o.oid = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, oid);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = new Order(
                            rs.getInt("oid"), rs.getString("username"), rs.getDouble("totalPrice"),
                            rs.getTimestamp("orderDate"), rs.getString("phone"), rs.getString("address"),
                            rs.getString("displayName"));
                    o.setStatus(rs.getString("status"));
                    return o;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lay tat ca don hang, tuy chon loc theo trang thai.
     * statusFilter = null hoac rong thi lay tat ca.
     */
    public List<Order> getAllOrders(String statusFilter) {
        return getAllOrders(statusFilter, null, null, null);
    }

    /**
     * Lay tat ca don hang, tuy chon loc theo trang thai va ngay/thang/nam.
     */
    public List<Order> getAllOrders(String statusFilter, Integer day, Integer month, Integer year) {
        List<Order> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT o.oid, o.username, COALESCE(a.displayName, o.username) AS displayName, "
                        + "o.totalPrice, o.orderDate, o.phone, o.address, o.status "
                        + "FROM [Order] o LEFT JOIN Account a ON o.username = a.username WHERE 1=1");
        List<Object> params = new ArrayList<>();
        if (statusFilter != null && !statusFilter.trim().isEmpty()) {
            sql.append(" AND o.status = ?");
            params.add(statusFilter);
        }
        if (year != null) {
            sql.append(" AND YEAR(o.orderDate) = ?");
            params.add(year);
        }
        if (month != null) {
            sql.append(" AND MONTH(o.orderDate) = ?");
            params.add(month);
        }
        if (day != null) {
            sql.append(" AND DAY(o.orderDate) = ?");
            params.add(day);
        }
        sql.append(" ORDER BY o.orderDate DESC");
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = new Order(
                            rs.getInt("oid"), rs.getString("username"), rs.getDouble("totalPrice"),
                            rs.getTimestamp("orderDate"), rs.getString("phone"), rs.getString("address"),
                            rs.getString("displayName"));
                    o.setStatus(rs.getString("status"));
                    list.add(o);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Cap nhat trang thai don hang.
     * Trang thai hop le: Cho xac nhan, Dang giao, Hoan thanh, Da huy.
     */
    public boolean updateOrderStatus(int oid, String status) {
        String sql = "UPDATE [Order] SET status = ? WHERE oid = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, oid);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lay danh sach sach co ton kho <= nguong canh bao.
     * Dung de hien thi canh bao tren trang admin quan ly san pham.
     */
    public List<Book> getLowStockBooks(int threshold) {
        List<Book> list = new ArrayList<>();
        String sql = "SELECT id, title, price, image, cid, description, stock, author, edition FROM Book WHERE stock <= ? ORDER BY stock ASC";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, threshold);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(new Book(
                        rs.getInt("id"), rs.getString("title"), rs.getDouble("price"),
                        rs.getString("image"), rs.getInt("cid"), rs.getString("description"),
                        rs.getInt("stock"), rs.getString("author"), rs.getString("edition")));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Them danh muc moi vao bang Category.
     * Tra ve id vua tao, hoac -1 neu that bai.
     */
    public int insertCategory(String name) {
        String sql = "INSERT INTO Category(name) VALUES(?)";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, name.trim());
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Xoa mot don hang theo oid.
     * Can xoa OrderDetail truoc, sau do moi xoa Order.
     */
    public void deleteOrder(int oid) {
        try (Connection conn = getConnection()) {
            String sqlDetail = "DELETE FROM OrderDetail WHERE oid = ?";
            try (PreparedStatement ps1 = conn.prepareStatement(sqlDetail)) {
                ps1.setInt(1, oid);
                ps1.executeUpdate();
            }

            String sqlOrder = "DELETE FROM [Order] WHERE oid = ?";
            try (PreparedStatement ps2 = conn.prepareStatement(sqlOrder)) {
                ps2.setInt(1, oid);
                ps2.executeUpdate();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * Them sach moi vao kho.
     */
    public boolean insertBook(Book b) {
        String sql = "INSERT INTO Book(title, price, image, cid, description, stock, author, edition) VALUES(?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, b.getTitle());
            ps.setDouble(2, b.getPrice());
            ps.setString(3, b.getImage());
            ps.setInt(4, b.getCid());
            ps.setString(5, b.getDescription());
            ps.setInt(6, b.getStock());
            ps.setString(7, b.getAuthor());
            ps.setString(8, b.getEdition());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cap nhat thong tin sach theo id.
     */
    public boolean updateBook(Book b) {
        String sql = "UPDATE Book SET title = ?, price = ?, image = ?, cid = ?, description = ?, stock = ?, author = ?, edition = ? WHERE id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, b.getTitle());
            ps.setDouble(2, b.getPrice());
            ps.setString(3, b.getImage());
            ps.setInt(4, b.getCid());
            ps.setString(5, b.getDescription());
            ps.setInt(6, b.getStock());
            ps.setString(7, b.getAuthor());
            ps.setString(8, b.getEdition());
            ps.setInt(9, b.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xoa sach theo id.
     */
    public boolean deleteBook(int id) {
        String sql = "DELETE FROM Book WHERE id = ?";
        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lay thong ke tong quan cho dashboard admin:
     * - pendingOrders: so don dang cho xac nhan
     * - todayOrders: so don dat trong ngay hom nay
     * - todayRevenue: doanh thu tong don dat hom nay (tru don da huy)
     * - lowStockCount: so sach co ton kho <= 5
     */
    public Map<String, Object> getDashboardStats() {
        Map<String, Object> stats = new HashMap<>();
        try (Connection conn = getConnection()) {
            // So don cho xac nhan
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM [Order] WHERE status = N'Chờ xác nhận'")) {
                ResultSet rs = ps.executeQuery();
                stats.put("pendingOrders", rs.next() ? rs.getInt(1) : 0);
            }
            // So don dat hom nay
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM [Order] WHERE CAST(orderDate AS DATE) = CAST(GETDATE() AS DATE)")) {
                ResultSet rs = ps.executeQuery();
                stats.put("todayOrders", rs.next() ? rs.getInt(1) : 0);
            }
            // Doanh thu hom nay (bo qua don da huy)
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT ISNULL(SUM(od.quantity * od.price), 0) " +
                            "FROM OrderDetail od JOIN [Order] o ON od.oid = o.oid " +
                            "WHERE CAST(o.orderDate AS DATE) = CAST(GETDATE() AS DATE) " +
                            "AND o.status <> N'Đã hủy'")) {
                ResultSet rs = ps.executeQuery();
                stats.put("todayRevenue", rs.next() ? rs.getDouble(1) : 0.0);
            }
            // So sach ton kho thap
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM Book WHERE stock <= 5")) {
                ResultSet rs = ps.executeQuery();
                stats.put("lowStockCount", rs.next() ? rs.getInt(1) : 0);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return stats;
    }
}
