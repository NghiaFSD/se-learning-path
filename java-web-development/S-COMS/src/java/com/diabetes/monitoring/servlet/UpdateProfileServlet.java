package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UpdateProfileServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(UpdateProfileServlet.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(401);
            response.getWriter().print("{\"error\":\"Not logged in\"}");
            return;
        }
        String email = currentUser.getEmail();
        String sql = "SELECT full_name, email, phone, date_of_birth, address FROM Patient WHERE email = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String fullName  = nullToEmpty(rs.getString("full_name"));
                    String dob       = nullToEmpty(rs.getString("date_of_birth"));
                    String phone     = nullToEmpty(rs.getString("phone"));
                    String address   = nullToEmpty(rs.getString("address"));
                    try (PrintWriter out = response.getWriter()) {
                        out.print("{\"fullName\":\"" + escJson(fullName) + "\","
                                + "\"email\":\""    + escJson(email)    + "\","
                                + "\"phone\":\""    + escJson(phone)    + "\","
                                + "\"dob\":\""      + escJson(dob)      + "\","
                                + "\"address\":\""  + escJson(address)  + "\"}");
                    }
                } else {
                    response.setStatus(404);
                    response.getWriter().print("{\"error\":\"Patient not found\"}");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
            response.setStatus(500);
            response.getWriter().print("{\"error\":\"DB error\"}");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        if (currentUser == null) {
            response.setStatus(401);
            response.getWriter().print("{\"error\":\"Not logged in\"}");
            return;
        }
        String fullName = request.getParameter("fullName");
        String phone    = request.getParameter("phone");
        String dob      = request.getParameter("dob");
        String address  = request.getParameter("address");
        String sql = "UPDATE Patient SET full_name=?, phone=?, date_of_birth=?, address=? WHERE email=?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, fullName);
            if (phone == null || phone.trim().isEmpty()) stmt.setNull(2, java.sql.Types.VARCHAR);
            else stmt.setString(2, phone);
            if (dob == null || dob.trim().isEmpty()) stmt.setNull(3, java.sql.Types.DATE);
            else stmt.setString(3, dob);
            if (address == null || address.trim().isEmpty()) stmt.setNull(4, java.sql.Types.NVARCHAR);
            else stmt.setString(4, address);
            stmt.setString(5, currentUser.getEmail());
            int rows = stmt.executeUpdate();
            if (rows > 0) {
                currentUser.setFullName(fullName);
                currentUser.setPhone(phone);
                currentUser.setDob(dob);
                currentUser.setAddress(address);
                request.getSession().setAttribute("currentUser", currentUser);
                response.getWriter().print("{\"success\":true}");
            } else {
                response.setStatus(404);
                response.getWriter().print("{\"error\":\"Patient not found\"}");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
            response.setStatus(500);
            response.getWriter().print("{\"error\":\"DB error: " + e.getMessage() + "\"}");
        }
    }

    private String nullToEmpty(String v) { return v == null ? "" : v; }

    private String escJson(String v) {
        if (v == null) return "";
        return v.replace("\\", "\\\\").replace("\"", "\\\"")
                .replace("\n", "\\n").replace("\r", "");
    }
}

