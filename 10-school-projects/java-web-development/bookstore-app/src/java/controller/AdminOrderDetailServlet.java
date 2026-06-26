package controller;

import dal.BookDAO;
import dal.OrderDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;
import model.OrderDetail;

/**
 * Trang chi tiet don hang cho admin.
 * Hien thi thong tin nguoi dat va cac dong san pham trong don.
 */
@WebServlet(name = "AdminOrderDetailServlet", urlPatterns = { "/admin/order-detail" })
public class AdminOrderDetailServlet extends HttpServlet {

    /**
     * Chi cho phep admin truy cap trang chi tiet don.
     */
    private boolean isAdmin(HttpSession session) {
        Account user = (Account) session.getAttribute("user");
        return user != null && user.getRole() == 1;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Chan truy cap trai phep.
        HttpSession session = request.getSession();
        if (!isAdmin(session)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String oidStr = request.getParameter("oid");
        int oid;
        try {
            oid = Integer.parseInt(oidStr);
        } catch (Exception e) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        BookDAO bookDAO = new BookDAO();
        OrderDAO orderDAO = new OrderDAO();

        Order order = bookDAO.getOrderById(oid);
        List<OrderDetail> details = orderDAO.getDetailByOrderId(oid);

        if (order == null) {
            response.sendRedirect(request.getContextPath() + "/admin/orders");
            return;
        }

        request.setAttribute("order", order);
        request.setAttribute("details", details);
        request.getRequestDispatcher("/views/admin/admin-order-detail.jsp").forward(request, response);
    }
}
