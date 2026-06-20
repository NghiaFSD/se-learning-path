package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Order;

/**
 * Trang admin quan ly tat ca don hang.
 * GET /admin/orders -> hien thi danh sach, loc theo ?status=
 * POST /admin/orders -> cap nhat trang thai 1 don hang
 */
@WebServlet(name = "AdminOrderServlet", urlPatterns = { "/admin/orders" })
public class AdminOrderServlet extends HttpServlet {

    /** Danh sach trang thai hop le de tranh nhan gia tri tuy y tu form. */
    private static final List<String> VALID_STATUSES = Arrays.asList(
            "Chờ xác nhận", "Đang giao", "Hoàn thành", "Đã hủy");

    /**
     * Kiem tra user dang dang nhap co phai admin khong.
     */
    private boolean isAdmin(HttpSession session) {
        Account user = (Account) session.getAttribute("user");
        return user != null && user.getRole() == 1;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request.getSession())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        // Lay bo loc trang thai tu URL, vd: ?status=Dang+giao
        String statusFilter = request.getParameter("status");
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
        List<Order> orders = dao.getAllOrders(statusFilter, day, month, year);

        request.setAttribute("orders", orders);
        request.setAttribute("selectedStatus", statusFilter);
        request.setAttribute("selectedYear", year);
        request.setAttribute("selectedMonth", month);
        request.setAttribute("selectedDay", day);
        request.setAttribute("validStatuses", VALID_STATUSES);
        request.getRequestDispatcher("/views/admin/admin-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (!isAdmin(request.getSession())) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String oidStr = request.getParameter("oid");
        String newStatus = request.getParameter("status");

        // Chi cap nhat neu trang thai nam trong danh sach cho phep.
        if (oidStr != null && VALID_STATUSES.contains(newStatus)) {
            try {
                int oid = Integer.parseInt(oidStr);
                BookDAO dao = new BookDAO();
                dao.updateOrderStatus(oid, newStatus);
            } catch (NumberFormatException ignored) {
            }
        }

        // Quay lai trang quan ly don, giu nguyen bo loc trang thai hien tai.
        String filterStatus = request.getParameter("filterStatus");
        String filterYear = request.getParameter("filterYear");
        String filterMonth = request.getParameter("filterMonth");
        String filterDay = request.getParameter("filterDay");
        StringBuilder redirect = new StringBuilder(request.getContextPath() + "/admin/orders");
        String separator = "?";
        if (filterStatus != null && !filterStatus.trim().isEmpty()) {
            redirect.append(separator)
                    .append("status=")
                    .append(java.net.URLEncoder.encode(filterStatus, "UTF-8"));
            separator = "&";
        }
        if (filterYear != null && !filterYear.trim().isEmpty()) {
            redirect.append(separator).append("year=").append(filterYear);
            separator = "&";
        }
        if (filterMonth != null && !filterMonth.trim().isEmpty()) {
            redirect.append(separator).append("month=").append(filterMonth);
            separator = "&";
        }
        if (filterDay != null && !filterDay.trim().isEmpty()) {
            redirect.append(separator).append("day=").append(filterDay);
        }
        response.sendRedirect(redirect.toString());
    }
}
