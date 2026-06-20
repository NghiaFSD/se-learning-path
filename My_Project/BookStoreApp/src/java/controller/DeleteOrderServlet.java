package controller;

import dal.BookDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;

/**
 * Xu ly huy don hang cua user (doi status thanh "Da huy").
 * Khong xoa cung de admin van theo doi duoc don bi huy.
 */
public class DeleteOrderServlet extends HttpServlet {

    /**
     * GET /delete-order?oid=...
     * Doi status don sang "Da huy" va quay lai trang lich su.
     * Chi cho phep user huy don cua chinh minh va khi con o trang thai "Cho xac
     * nhan".
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Account user = (session != null) ? (Account) session.getAttribute("user") : null;

        // Bat buoc phai dang nhap.
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String oidRaw = request.getParameter("oid");
        try {
            int oid = Integer.parseInt(oidRaw);
            BookDAO dao = new BookDAO();

            // Kiem tra don hang co thuoc ve user nay khong.
            Order order = dao.getOrderById(oid);
            if (order == null || !order.getUsername().equals(user.getUsername())) {
                // Don khong ton tai hoac khong phai cua user nay -> tu choi.
                response.sendRedirect(request.getContextPath() + "/history");
                return;
            }

            // Chi cho huy khi con o trang thai "Cho xac nhan".
            if ("Chờ xác nhận".equals(order.getStatus())) {
                dao.updateOrderStatus(oid, "Đã hủy");
            }
        } catch (NumberFormatException e) {
            // oid khong hop le -> bo qua.
        }

        response.sendRedirect(request.getContextPath() + "/history");
    }

    /**
     * POST dung lai luong GET de tranh lap code.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
