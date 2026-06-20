package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Account;
import model.Book;

@WebServlet(name = "AdminProductServlet", urlPatterns = { "/admin/products" })
/**
 * Trang quan tri san pham cho admin:
 * - GET: list/add/edit/delete
 * - POST: luu them moi hoac cap nhat san pham
 */
public class AdminProductServlet extends HttpServlet {

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
        HttpSession session = request.getSession();
        // Chan truy cap neu khong phai admin.
        if (!isAdmin(session)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String action = request.getParameter("action");
        BookDAO dao = new BookDAO();

        // action=add -> mo form them moi.
        if ("add".equals(action)) {
            request.setAttribute("categories", dao.getAllCategories());
            request.getRequestDispatcher("/views/admin/admin-product-form.jsp").forward(request, response);
            // action=edit -> mo form cap nhat voi du lieu cu.
        } else if ("edit".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    Book book = dao.getBookById(id);
                    if (book != null) {
                        request.setAttribute("book", book);
                        request.setAttribute("categories", dao.getAllCategories());
                        request.getRequestDispatcher("/views/admin/admin-product-form.jsp").forward(request, response);
                        return;
                    }
                } catch (NumberFormatException ignored) {
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/products");
            // action=delete -> xoa san pham theo id.
        } else if ("delete".equals(action)) {
            String idStr = request.getParameter("id");
            if (idStr != null) {
                try {
                    int id = Integer.parseInt(idStr);
                    dao.deleteBook(id);
                } catch (NumberFormatException ignored) {
                }
            }
            response.sendRedirect(request.getContextPath() + "/admin/products");
        } else {
            // Mac dinh: hien thi danh sach tat ca san pham + canh bao ton kho thap.
            List<Book> books = dao.getAllBooks("0", "");
            List<Book> lowStockBooks = dao.getLowStockBooks(5);
            request.setAttribute("books", books);
            request.setAttribute("lowStockBooks", lowStockBooks);
            request.setAttribute("categories", dao.getAllCategories());
            request.getRequestDispatcher("/views/admin/admin-products.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        // Chan truy cap neu khong phai admin.
        if (!isAdmin(session)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String idStr = request.getParameter("id");
        String title = request.getParameter("title");
        String priceStr = request.getParameter("price");
        String image = request.getParameter("image");
        String author = request.getParameter("author");
        String edition = request.getParameter("edition");
        String cidStr = request.getParameter("cid");
        String newCategoryName = request.getParameter("newCategoryName");
        String description = request.getParameter("description");
        String stockStr = request.getParameter("stock");

        boolean isNewCategory = (newCategoryName != null && !newCategoryName.trim().isEmpty());

        // Validate du lieu form dau vao.
        boolean hasError = false;

        if (title == null || title.trim().isEmpty()) {
            request.setAttribute("titleError", "Tiêu đề sách không được để trống");
            hasError = true;
        }
        double price = 0;
        if (priceStr == null || priceStr.trim().isEmpty()) {
            request.setAttribute("priceError", "Giá không được để trống");
            hasError = true;
        } else {
            try {
                price = Double.parseDouble(priceStr);
                if (price <= 0) {
                    request.setAttribute("priceError", "Giá phải lớn hơn 0");
                    hasError = true;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("priceError", "Giá không hợp lệ");
                hasError = true;
            }
        }

        int cid = 0;
        if (!isNewCategory) {
            // Chi bat buoc chon danh muc neu khong co ten danh muc moi.
            if (cidStr == null || cidStr.trim().isEmpty()) {
                request.setAttribute("cidError", "Chọn danh mục hoặc nhập tên danh mục mới");
                hasError = true;
            } else {
                try {
                    cid = Integer.parseInt(cidStr);
                    if (cid <= 0) {
                        request.setAttribute("cidError", "Danh mục không hợp lệ");
                        hasError = true;
                    }
                } catch (NumberFormatException e) {
                    request.setAttribute("cidError", "Danh mục không hợp lệ");
                    hasError = true;
                }
            }
        }

        int stock = -1;
        if (stockStr == null || stockStr.trim().isEmpty()) {
            request.setAttribute("stockError", "Số lượng tồn kho không được để trống");
            hasError = true;
        } else {
            try {
                stock = Integer.parseInt(stockStr);
                if (stock < 0) {
                    request.setAttribute("stockError", "Số lượng phải >= 0");
                    hasError = true;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("stockError", "Số lượng phải là số nguyên");
                hasError = true;
            }
        }

        if (image == null || image.trim().isEmpty()) {
            request.setAttribute("imageError", "URL ảnh không được để trống");
            hasError = true;
        }

        if (description == null || description.trim().isEmpty()) {
            request.setAttribute("descriptionError", "Mô tả không được để trống");
            hasError = true;
        }

        // Validate author and edition length (optional fields)
        String authorTrim = (author != null) ? author.trim() : "";
        String editionTrim = (edition != null) ? edition.trim() : "";
        if (!authorTrim.isEmpty() && authorTrim.length() > 100) {
            request.setAttribute("authorError", "Tên tác giả tối đa 100 ký tự");
            hasError = true;
        }
        if (!editionTrim.isEmpty() && editionTrim.length() > 50) {
            request.setAttribute("editionError", "Tái bản tối đa 50 ký tự");
            hasError = true;
        }

        Book book = new Book();
        // Map du lieu tu form vao entity Book.
        if (idStr != null && !idStr.trim().isEmpty()) {
            try {
                book.setId(Integer.parseInt(idStr));
            } catch (NumberFormatException ignored) {
            }
        }
        book.setTitle(title);
        book.setPrice(price);
        book.setImage(image);
        book.setAuthor(authorTrim);
        book.setEdition(editionTrim);
        book.setCid(cid);
        book.setDescription(description);
        book.setStock(stock);

        request.setAttribute("book", book);
        request.setAttribute("categories", new BookDAO().getAllCategories());

        if (hasError) {
            // Co loi validate -> quay lai form va hien thi thong bao.
            request.setAttribute("newCategoryName", newCategoryName);
            request.getRequestDispatcher("/views/admin/admin-product-form.jsp").forward(request, response);
            return;
        }

        // Neu admin nhap ten danh muc moi, tao danh muc va lay id moi.
        if (isNewCategory) {
            BookDAO catDao = new BookDAO();
            int newCid = catDao.insertCategory(newCategoryName);
            if (newCid < 0) {
                request.setAttribute("cidError", "Không thể tạo danh mục mới, vui lòng thử lại.");
                request.setAttribute("newCategoryName", newCategoryName);
                request.getRequestDispatcher("/views/admin/admin-product-form.jsp").forward(request, response);
                return;
            }
            cid = newCid;
        }

        BookDAO dao = new BookDAO();
        // Co id => update, khong co id => insert moi.
        boolean result;
        if (book.getId() > 0) {
            result = dao.updateBook(book);
        } else {
            result = dao.insertBook(book);
        }

        if (!result) {
            request.setAttribute("formError", "Có lỗi khi lưu sản phẩm, vui lòng thử lại.");
            request.getRequestDispatcher("/views/admin/admin-product-form.jsp").forward(request, response);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/admin/products");
    }
}
