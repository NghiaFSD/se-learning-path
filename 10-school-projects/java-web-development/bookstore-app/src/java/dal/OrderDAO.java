package dal;

import java.sql.*;
import java.util.*;
import model.*;
import config.DBConfig;

/**
 * DAO chuyen trach doc chi tiet don hang (OrderDetail) cho trang xem don.
 */
public class OrderDAO {

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
     * Lay danh sach dong chi tiet cua mot don hang theo oid.
     * Moi dong gom: id chi tiet, thong tin sach, don gia, so luong.
     */
    public List<OrderDetail> getDetailByOrderId(int oid) {
        List<OrderDetail> list = new ArrayList<>();
        String sql = "SELECT d.odid, b.title, b.image, d.price, d.quantity "
                + "FROM OrderDetail d JOIN Book b ON d.bid = b.id "
                + "WHERE d.oid = ?";

        try (Connection conn = getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, oid);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Book b = new Book();
                    b.setTitle(rs.getString(2));
                    b.setImage(rs.getString(3));

                    OrderDetail d = new OrderDetail(
                            rs.getInt(1),
                            b,
                            rs.getInt(5),
                            rs.getDouble(4));
                    list.add(d);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
