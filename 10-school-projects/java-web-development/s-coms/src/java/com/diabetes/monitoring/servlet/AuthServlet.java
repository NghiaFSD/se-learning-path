package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.dao.UserDAO;
import com.diabetes.monitoring.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.logging.Logger;

public class AuthServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AuthServlet.class.getName());
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String rememberMe = request.getParameter("rememberMe");

        User user = userDAO.validateLogin(email, password, role);
        if (user == null) {
            LOGGER.fine("Login failed with selected role; trying account email fallback");
            user = userDAO.validateLogin(email, password);
        }

        if (user != null) {
            if (user.getStatus() != null && !"active".equals(user.getStatus())) {
                String status = user.getStatus();
                String message;
                if ("locked".equals(status)) {
                    message = "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ quản trị viên để biết lý do.";
                } else if ("banned".equals(status)) {
                    message = "Tài khoản của bạn đã bị cấm. Vui lòng liên hệ quản trị viên.";
                } else {
                    message = "Tài khoản của bạn đang bị tạm ngưng. Vui lòng liên hệ quản trị viên.";
                }
                request.setAttribute("loginError", message);
                request.getRequestDispatcher("login.jsp").forward(request, response);
                return;
            }

            // Mitigate session fixation: invalidate existing session and create a new one
            HttpSession oldSession = request.getSession(false);
            if (oldSession != null) {
                try {
                    oldSession.invalidate();
                } catch (IllegalStateException ignored) {}
            }
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            String actualRole = user.getRole();
            if ("patient".equalsIgnoreCase(actualRole)) {
                response.sendRedirect(request.getContextPath() + "/patient/dashboard.jsp");
            } else if ("admin".equalsIgnoreCase(actualRole)) {
                response.sendRedirect(request.getContextPath() + "/admin");
            } else {
                response.sendRedirect(request.getContextPath() + "/index.jsp");
            }
        } else {
            request.setAttribute("loginError", "Invalid credentials. Please try again.");
            request.getRequestDispatcher("login.jsp").forward(request, response);
        }
    }
}
