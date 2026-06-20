package controller;

import dal.BookDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Book;

/**
 * Hien thi chi tiet 1 sach theo id.
 */
public class DetailServlet extends HttpServlet {

    /**
     * GET /detail?id=...
     * Lay thong tin sach tu DB va forward sang detail.jsp.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idRaw = request.getParameter("id");

        try {
            int id = Integer.parseInt(idRaw);
            BookDAO dao = new BookDAO();
            Book book = dao.getBookById(id);

            request.setAttribute("book", book);
            request.getRequestDispatcher("/views/user/detail.jsp").forward(request, response);
        } catch (Exception e) {
            // id khong hop le hoac loi truy van -> quay lai trang home.
            response.sendRedirect(request.getContextPath() + "/home");
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
