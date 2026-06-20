package controller;

import dal.BookDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Account;

/**
 * Xu ly dang nhap he thong.
 */
public class LoginServlet extends HttpServlet {

    /**
     * GET /login
     * Hien thi trang login.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/views/user/login.jsp").forward(request, response);
    }

    /**
     * POST /login
     * Kiem tra thong tin dang nhap. Thanh cong -> luu user vao session.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("user");
        String password = request.getParameter("pass");

        BookDAO dao = new BookDAO();
        Account acc = dao.login(username, password);

        if (acc != null) {
            request.getSession().setAttribute("user", acc);
            if (acc.getRole() == 1) {
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
            } else {
                response.sendRedirect(request.getContextPath() + "/home");
            }
        } else {
            request.setAttribute("error", "Ten dang nhap hoac mat khau khong dung!");
            request.getRequestDispatcher("/views/user/login.jsp").forward(request, response);
        }
    }
}
