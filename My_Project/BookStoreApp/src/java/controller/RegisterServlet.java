package controller;

import dal.BookDAO;
import java.io.IOException;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "RegisterServlet", urlPatterns = { "/register" })
/**
 * Xu ly dang ky tai khoan moi.
 */
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Mo trang form dang ky.
        request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Lay du lieu nguoi dung nhap tu form.
        String usernameRaw = request.getParameter("email");
        String username = usernameRaw != null ? usernameRaw.trim() : "";
        String password = request.getParameter("pass");
        String confirm = request.getParameter("confirmPass");
        String displayName = request.getParameter("displayName");

        int role = 0; // user mặc định, không cho chọn qua form

        if (username.isEmpty() || password == null || password.isEmpty() || displayName == null || displayName.isEmpty()
                || confirm == null || confirm.isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ email, tên hiển thị và mật khẩu.");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        // Validate email dung dinh dang co ban.
        String emailRegex = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
        if (!Pattern.matches(emailRegex, username)) {
            request.setAttribute("error", "Email không hợp lệ. Vui lòng nhập đúng định dạng.");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirm)) {
            request.setAttribute("error", "Mật khẩu và xác nhận mật khẩu không khớp.");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 8) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 8 ký tự.");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        BookDAO dao = new BookDAO();
        // Kiem tra trung username truoc khi insert.
        if (dao.isUsernameTaken(username)) {
            request.setAttribute("error", "Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
            return;
        }

        // Tao tai khoan moi trong CSDL.
        boolean success = dao.registerAccount(username, password, displayName, role);
        if (success) {
            request.setAttribute("message", "Đăng ký thành công. Vui lòng đăng nhập.");
            request.getRequestDispatcher("/views/user/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Đã có lỗi xảy ra khi đăng ký. Vui lòng thử lại.");
            request.getRequestDispatcher("/views/user/register.jsp").forward(request, response);
        }
    }
}
