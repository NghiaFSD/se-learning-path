package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Book;
import model.CartItem;

/**
 * Cap nhat so luong cua 1 san pham trong gio hang.
 */
public class UpdateCartServlet extends HttpServlet {

    /**
     * GET /update-cart?id=...&quantity=...
     * So luong se duoc gioi han theo ton kho hien tai.
     */
    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));

            HttpSession session = request.getSession();
            Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

            if (cart != null && cart.containsKey(id)) {
                BookDAO dao = new BookDAO();
                Book book = dao.getBookById(id);

                if (book != null) {
                    if (quantity > book.getStock()) {
                        quantity = book.getStock();
                        session.setAttribute("stockMessage",
                                "So luong san pham " + book.getTitle() + " da dieu chinh theo ton kho: " + quantity);
                    }

                    if (quantity <= 0) {
                        cart.remove(id);
                    } else {
                        cart.get(id).setQuantity(quantity);
                    }

                    session.setAttribute("cart", cart);
                }
            }
        } catch (Exception e) {
            // Bo qua loi parse de khong lam giat UX.
        }
    }

    /**
     * POST dung lai luong GET.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
