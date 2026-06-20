package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Book;
import model.CartItem;

@WebServlet(name = "AddToCartServlet", urlPatterns = { "/add-to-cart" })
/**
 * Xu ly them sach vao gio hang luu trong session.
 */
public class AddToCartServlet extends HttpServlet {

    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // 1. Lấy ID sách từ request
            int id = Integer.parseInt(request.getParameter("id"));

            // 2. Lấy Session
            HttpSession session = request.getSession();

            // 3. Lấy giỏ hàng từ session (dạng Map: id -> món hàng)
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

            // Nếu chưa có giỏ hàng thì tạo mới
            if (cart == null) {
                cart = new HashMap<>();
            }

            // 4. Kiểm tra xem sách đã có trong giỏ chưa và tồn kho
            BookDAO dao = new BookDAO();
            Book b = dao.getBookById(id);
            if (b != null) {
                int currentQty = cart.containsKey(id) ? cart.get(id).getQuantity() : 0;
                if (b.getStock() <= 0) {
                    request.getSession().setAttribute("stockMessage", "Sản phẩm " + b.getTitle() + " đã hết hàng.");
                } else if (currentQty + 1 > b.getStock()) {
                    request.getSession().setAttribute("stockMessage",
                            "Chỉ còn " + b.getStock() + " sản phẩm " + b.getTitle() + " trong kho.");
                    if (cart.containsKey(id)) {
                        cart.get(id).setQuantity(b.getStock());
                    } else {
                        cart.put(id, new CartItem(b, b.getStock()));
                    }
                } else {
                    if (cart.containsKey(id)) {
                        cart.get(id).setQuantity(currentQty + 1);
                    } else {
                        cart.put(id, new CartItem(b, 1));
                    }
                }
            }

            // 5. Cập nhật lại giỏ hàng vào Session
            session.setAttribute("cart", cart);

            // 6. Quay lại trang danh sách (hoặc trang giỏ hàng)
            response.sendRedirect(request.getContextPath() + "/home");

        } catch (Exception e) {
            // Neu id khong hop le hoac loi bat ky -> quay ve trang danh sach.
            response.sendRedirect(request.getContextPath() + "/home"); // Nếu có lỗi (như ID không phải số) thì quay lại
                                                                       // trang home
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Form POST dung lai luong GET de tranh lap code.
        doGet(request, response);
    }
}