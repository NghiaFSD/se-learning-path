package controller;

import java.io.IOException;
import java.util.Map;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CartItem;

/**
 * Xoa mot san pham khoi gio hang trong session.
 */
public class RemoveItemServlet extends HttpServlet {

    /**
     * GET /remove-item?id=...
     */
    @Override
    @SuppressWarnings("unchecked")
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idRaw = request.getParameter("id");
        HttpSession session = request.getSession();

        Map<Integer, CartItem> cart = (Map<Integer, CartItem>) session.getAttribute("cart");

        if (cart != null && idRaw != null) {
            try {
                int id = Integer.parseInt(idRaw);
                cart.remove(id);
                session.setAttribute("cart", cart);
            } catch (NumberFormatException e) {
                // id khong hop le -> bo qua.
            }
        }

        response.sendRedirect(request.getContextPath() + "/home");
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
