package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Book;
import model.Category;

/**
 * Trang home: liet ke sach, loc theo danh muc, tim theo tu khoa.
 */
public class ListBookServlet extends HttpServlet {

    /**
     * GET /home?cid=...&txtSearch=...
     * Lay danh sach sach + danh muc va forward sang list.jsp.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String cid = request.getParameter("cid");
        String txtSearch = request.getParameter("txtSearch");
        String priceMin = request.getParameter("priceMin");
        String priceMax = request.getParameter("priceMax");

        String priceError = null;
        Double min = null;
        Double max = null;

        if (priceMin != null && !priceMin.trim().isEmpty()) {
            try {
                min = Double.parseDouble(priceMin);
                if (min < 0) {
                    priceError = "Gia tu phai >= 0";
                }
            } catch (NumberFormatException ex) {
                priceError = "Gia tu khong hop le";
            }
        }

        if (priceError == null && priceMax != null && !priceMax.trim().isEmpty()) {
            try {
                max = Double.parseDouble(priceMax);
                if (max < 0) {
                    priceError = "Gia den phai >= 0";
                }
            } catch (NumberFormatException ex) {
                priceError = "Gia den khong hop le";
            }
        }

        if (priceError == null && min != null && max != null && min > max) {
            priceError = "Khoang gia khong hop le: gia tu phai nho hon hoac bang gia den";
        }

        BookDAO dao = new BookDAO();
        List<Book> books;
        if (priceError != null) {
            books = dao.getAllBooks(cid, txtSearch);
        } else {
            books = dao.getAllBooks(cid, txtSearch, priceMin, priceMax);
        }

        List<Category> categories = dao.getAllCategories();

        request.setAttribute("data", books);
        request.setAttribute("categories", categories);
        request.setAttribute("priceError", priceError);
        request.getRequestDispatcher("/views/user/list.jsp").forward(request, response);
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
