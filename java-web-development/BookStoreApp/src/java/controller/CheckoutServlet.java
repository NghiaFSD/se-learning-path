package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.Map;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.CartItem;

@WebServlet(name = "CheckoutServlet", urlPatterns = { "/checkout" })
/**
 * Xu ly nghiep vu thanh toan:
 * - GET: hien thi trang checkout + tong tien
 * - POST: validate thong tin giao hang, tao don, xoa gio hang
 */
public class CheckoutServlet extends HttpServlet {

    private static final Pattern PHONE_PATTERN = Pattern
            .compile("^(0|\\+84)(3[2-9]|5[6|8|9]|7[0|6-9]|8[1-5|8|9]|9[0-9])\\d{7}$");

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Kiem tra dang nhap va gio hang truoc khi vao trang thanh toan.
        HttpSession session = request.getSession();

        Account acc = (Account) session.getAttribute("user");
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

        if (acc == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        double total = 0;
        BookDAO dao = new BookDAO();
        // Kiem tra ton kho real-time va tinh tong tien.
        for (CartItem item : cart.values()) {
            int bid = item.getBook().getId();
            int quantity = item.getQuantity();
            if (!dao.isStockAvailable(bid, quantity)) {
                session.setAttribute("stockMessage", "Sản phẩm '" + item.getBook().getTitle() + "' chỉ còn "
                        + dao.getBookStock(bid) + " sản phẩm. Vui lòng điều chỉnh.");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }
            total += item.getBook().getPrice() * item.getQuantity();
        }

        request.setAttribute("total", total);
        request.getRequestDispatcher("/views/user/checkout.jsp").forward(request, response);
    }

    @Override
    @SuppressWarnings("unchecked")
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lay thong tin nguoi dung + gio hang hien tai.
        HttpSession session = request.getSession();

        Account acc = (Account) session.getAttribute("user");
        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

        if (acc == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if (cart == null || cart.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        boolean hasError = false;

        // Validate SĐT theo pattern Viet Nam.
        if (phone == null || phone.trim().isEmpty()) {
            request.setAttribute("phoneError", "Số điện thoại không được để trống");
            hasError = true;
        } else if (!PHONE_PATTERN.matcher(phone.trim()).matches()) {
            request.setAttribute("phoneError", "SĐT không hợp lệ. Ví dụ: 0912345678 hoặc +84912345678");
            hasError = true;
        }

        // Validate dia chi giao hang.
        if (address == null || address.trim().isEmpty()) {
            request.setAttribute("addressError", "Địa chỉ giao hàng không được để trống");
            hasError = true;
        } else if (address.trim().length() < 10) {
            request.setAttribute("addressError", "Địa chỉ nên đầy đủ, tối thiểu 10 ký tự");
            hasError = true;
        }

        double total = 0;
        BookDAO dao = new BookDAO();
        for (CartItem item : cart.values()) {
            total += item.getBook().getPrice() * item.getQuantity();
        }
        request.setAttribute("total", total);

        if (hasError) {
            // Neu loi validate, giu lai du lieu da nhap de hien thi lai form.
            request.setAttribute("phone", phone);
            request.setAttribute("address", address);
            request.getRequestDispatcher("/views/user/checkout.jsp").forward(request, response);
            return;
        }

        // Kiểm tra tồn kho lại trước khi chọn thanh toán
        for (CartItem item : cart.values()) {
            int bid = item.getBook().getId();
            int quantity = item.getQuantity();
            if (!dao.isStockAvailable(bid, quantity)) {
                session.setAttribute("stockMessage", "Sản phẩm '" + item.getBook().getTitle() + "' chỉ còn "
                        + dao.getBookStock(bid) + " sản phẩm. Vui lòng điều chỉnh.");
                response.sendRedirect(request.getContextPath() + "/cart");
                return;
            }
        }

        boolean ok = dao.insertOrder(acc, cart, total, phone.trim(), address.trim());
        if (!ok) {
            session.setAttribute("stockMessage",
                    "Không thể thanh toán vì tồn kho không đủ cho một hoặc nhiều sản phẩm. Vui lòng điều chỉnh số lượng.");
            response.sendRedirect(request.getContextPath() + "/cart");
            return;
        }

        session.removeAttribute("cart");

        request.setAttribute("total", total);
        request.setAttribute("phone", phone);
        request.setAttribute("address", address);

        request.getRequestDispatcher("/views/user/invoice.jsp").forward(request, response);
    }
}
