package controller;

import dal.BookDAO;
import dal.OrderDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.List;
import model.Order;
import model.OrderDetail;

/**
 * Hien thi danh sach chi tiet cua mot don hang theo oid.
 */
public class OrderDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Lay ma don hang tu URL, vd: order-detail?oid=12
            int oid = Integer.parseInt(request.getParameter("oid"));

            OrderDAO dao = new OrderDAO();
            // Doc cac dong chi tiet tu CSDL.
            List<OrderDetail> details = dao.getDetailByOrderId(oid);

            // Doc thong tin order (phone, address, total, date) de hien thi cho user.
            BookDAO bookDAO = new BookDAO();
            Order order = bookDAO.getOrderById(oid);

            request.setAttribute("details", details);
            request.setAttribute("order", order);
            request.setAttribute("orderID", oid);
            request.getRequestDispatcher("/views/user/order-detail.jsp").forward(request, response);
        } catch (Exception e) {
            // Neu oid khong hop le thi quay ve trang lich su.
            response.sendRedirect(request.getContextPath() + "/history");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // POST dung lai luong GET.
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet hiển thị chi tiết đơn hàng";
    }
}
