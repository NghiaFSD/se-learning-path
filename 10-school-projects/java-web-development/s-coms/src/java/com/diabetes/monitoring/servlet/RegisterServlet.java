package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.dao.UserDAO;
import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.regex.Pattern;

public class RegisterServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    
    // Email validation regex pattern
    private static final Pattern EMAIL_PATTERN = Pattern.compile(
        "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
    );
    
    // Minimum password length
    private static final int MIN_PASSWORD_LENGTH = 6;

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String gender = request.getParameter("gender");
        String dob = request.getParameter("dob");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        // Validate required fields
        String validationError = validateRequiredFields(fullName, email, password, confirmPassword);
        if (validationError != null) {
            request.setAttribute("registerError", validationError);
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate email format
        if (!isValidEmail(email)) {
            request.setAttribute("registerError", "Email không đúng định dạng. Vui lòng kiểm tra lại.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        if (userDAO.isEmailExists(email)) {
            request.setAttribute("registerError", "Email này đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate password match
        if (!password.equals(confirmPassword)) {
            request.setAttribute("registerError", "Mật khẩu xác nhận không khớp. Vui lòng nhập lại.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        // Validate password length
        if (password.length() < MIN_PASSWORD_LENGTH) {
            request.setAttribute("registerError", "Mật khẩu phải có ít nhất " + MIN_PASSWORD_LENGTH + " ký tự.");
            request.getRequestDispatcher("register.jsp").forward(request, response);
            return;
        }

        String hashedPassword = PasswordUtil.hashPassword(password);
        User user = new User(fullName, email, hashedPassword, "patient", gender, dob, phone, address, null, null);
        String errorMsg = userDAO.registerUser(user);
        if (errorMsg == null) {
            request.getSession().setAttribute("currentUser", user);
            response.sendRedirect(request.getContextPath() + "/patient/dashboard.jsp");
        } else {
            request.setAttribute("registerError", "Đăng ký thất bại: " + errorMsg);
            request.getRequestDispatcher("register.jsp").forward(request, response);
        }
    }
    
    /**
     * Validate required fields
     * Returns error message if validation fails, null if all valid
     */
    private String validateRequiredFields(String fullName, String email, String password, String confirmPassword) {
        if (isNullOrEmpty(fullName)) {
            return "Họ tên là bắt buộc. Vui lòng nhập họ tên của bạn.";
        }
        if (isNullOrEmpty(email)) {
            return "Email là bắt buộc. Vui lòng nhập email của bạn.";
        }
        if (isNullOrEmpty(password)) {
            return "Mật khẩu là bắt buộc. Vui lòng nhập mật khẩu.";
        }
        if (isNullOrEmpty(confirmPassword)) {
            return "Vui lòng xác nhận mật khẩu.";
        }
        return null;
    }
    
    /**
     * Check if string is null or empty/whitespace only
     */
    private boolean isNullOrEmpty(String value) {
        return value == null || value.trim().isEmpty();
    }
    
    /**
     * Validate email format using regex
     */
    private boolean isValidEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            return false;
        }
        return EMAIL_PATTERN.matcher(email).matches();
    }
}
