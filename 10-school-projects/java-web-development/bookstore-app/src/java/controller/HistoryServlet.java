package controller;

import dal.BookDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;

/**
 * Hien thi lich su don hang cua user dang dang nhap.
 */
public class HistoryServlet extends HttpServlet {

    /**
     * GET /history
     * Neu chua dang nhap -> ve login.jsp.
     * Neu da dang nhap -> lay lich su don va forward history.jsp.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account acc = (Account) session.getAttribute("user");

        if (acc == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        BookDAO dao = new BookDAO();
        request.setAttribute("history", dao.getHistory(acc.getUsername()));
        request.getRequestDispatcher("/views/user/history.jsp").forward(request, response);
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
