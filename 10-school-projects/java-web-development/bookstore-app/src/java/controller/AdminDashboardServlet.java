package controller;

import dal.BookDAO;
import java.io.IOException;
import java.time.LocalDate;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Account;

/**
 * Servlet cho trang dashboard admin tai /admin/dashboard. Chi admin (role == 1)
 * moi duoc truy cap.
 */
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        Account user = (Account) request.getSession().getAttribute("user");
        if (user == null || user.getRole() != 1) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        BookDAO dao = new BookDAO();
        Map<String, Object> stats = dao.getDashboardStats();

        request.setAttribute("pendingOrders", stats.get("pendingOrders"));
        request.setAttribute("todayOrders", stats.get("todayOrders"));
        request.setAttribute("todayRevenue", stats.get("todayRevenue"));
        request.setAttribute("lowStockCount", stats.get("lowStockCount"));

        LocalDate today = LocalDate.now();
        request.setAttribute("todayDay", today.getDayOfMonth());
        request.setAttribute("todayMonth", today.getMonthValue());
        request.setAttribute("todayYear", today.getYear());

        request.getRequestDispatcher("/views/admin/admin-dashboard.jsp").forward(request, response);
    }
}
