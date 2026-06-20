package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.List;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;

/**
 * Trang doanh thu cho admin:
 * - Loc don hang theo ngay/thang/nam
 * - Tong hop doanh thu thuc te va doanh thu du kien theo bo loc
 */
@WebServlet(name = "AdminRevenueServlet", urlPatterns = { "/admin/revenue" })
public class AdminRevenueServlet extends HttpServlet {

    /**
     * Chi cho phep tai khoan role=1 truy cap khu vuc admin.
     */
    private boolean isAdmin(HttpSession session) {
        Account user = (Account) session.getAttribute("user");
        return user != null && user.getRole() == 1;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        if (!isAdmin(session)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String yearStr = request.getParameter("year");
        String monthStr = request.getParameter("month");
        String dayStr = request.getParameter("day");

        Integer year = null;
        Integer month = null;
        Integer day = null;
        try {
            if (yearStr != null && !yearStr.isEmpty()) {
                year = Integer.parseInt(yearStr);
            }
        } catch (NumberFormatException ignored) {
        }
        try {
            if (monthStr != null && !monthStr.isEmpty()) {
                month = Integer.parseInt(monthStr);
            }
        } catch (NumberFormatException ignored) {
        }
        try {
            if (dayStr != null && !dayStr.isEmpty()) {
                day = Integer.parseInt(dayStr);
            }
        } catch (NumberFormatException ignored) {
        }

        BookDAO dao = new BookDAO();
        List<Order> orders = dao.getOrdersByPeriod(day, month, year);
        Map<String, Double> revenueSummary = dao.getRevenueSummary(day, month, year);

        request.setAttribute("orders", orders);
        request.setAttribute("actualRevenue", revenueSummary.get("actualRevenue"));
        request.setAttribute("projectedRevenue", revenueSummary.get("projectedRevenue"));
        request.setAttribute("selectedYear", year);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedDay", day);
        request.getRequestDispatcher("/views/admin/revenue.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
