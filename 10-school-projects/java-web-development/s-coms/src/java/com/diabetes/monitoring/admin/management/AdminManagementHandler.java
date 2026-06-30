package com.diabetes.monitoring.admin.management;

import com.diabetes.monitoring.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.Map;

/**
 * Dispatches account and medical service management requests.
 */
public class AdminManagementHandler {
    private final AdminAccountHandler accountHandler = new AdminAccountHandler();
    private final AdminMedicalServiceHandler medicalServiceHandler = new AdminMedicalServiceHandler();

    /**
     * Loads accounts data for the Admin UI.
     */
    public void loadAccounts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { accountHandler.loadAccounts(request, response); }
    /**
     * Creates account for the Admin module.
     */
    public void createAccount(HttpServletRequest request, HttpServletResponse response) throws IOException { accountHandler.createAccount(request, response); }
    /**
     * Updates account role for the Admin module.
     */
    public void updateAccountRole(HttpServletRequest request, HttpServletResponse response) throws IOException { accountHandler.updateAccountRole(request, response); }
    /**
     * Updates account status for the Admin module.
     */
    public void updateAccountStatus(HttpServletRequest request, HttpServletResponse response, String targetStatus) throws IOException { accountHandler.updateAccountStatus(request, response, targetStatus); }
    /**
     * Deletes account for the Admin module.
     */
    public void deleteAccount(HttpServletRequest request, HttpServletResponse response) throws IOException { accountHandler.deleteAccount(request, response); }
    /**
     * Updates account profile for the Admin module.
     */
    public void updateAccountProfile(HttpServletRequest request, HttpServletResponse response) throws IOException { accountHandler.updateAccountProfile(request, response); }
    /**
     * Handles ajax toggle account status for the Admin module.
     */
    public void ajaxToggleAccountStatus(HttpServletRequest request, HttpServletResponse response) throws IOException { accountHandler.ajaxToggleAccountStatus(request, response); }
    /**
     * Loads account profile data for the Admin UI.
     */
    public void loadAccountProfile(HttpServletRequest request, HttpServletResponse response) throws IOException { accountHandler.loadAccountProfile(request, response); }

    /**
     * Loads services data for the Admin UI.
     */
    public void loadServices(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException { medicalServiceHandler.loadServices(request, response); }
    /**
     * Creates service for the Admin module.
     */
    public void createService(HttpServletRequest request, HttpServletResponse response) throws IOException { medicalServiceHandler.createService(request, response); }
    /**
     * Updates service for the Admin module.
     */
    public void updateService(HttpServletRequest request, HttpServletResponse response) throws IOException { medicalServiceHandler.updateService(request, response); }
    /**
     * Updates service status for the Admin module.
     */
    public void updateServiceStatus(HttpServletRequest request, HttpServletResponse response) throws IOException { medicalServiceHandler.updateServiceStatus(request, response); }
    /**
     * Deletes service for the Admin module.
     */
    public void deleteService(HttpServletRequest request, HttpServletResponse response) throws IOException { medicalServiceHandler.deleteService(request, response); }
}

/**
 * Handles Admin account management screens and actions.
 */
class AdminAccountHandler {
    private final AdminAccountService accountService = new AdminAccountService();

    /**
     * Loads accounts data for the Admin UI.
     */
    public void loadAccounts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        request.setAttribute("users", accountService.loadAccounts(search, role, status));
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    /**
     * Creates account for the Admin module.
     */
    public void createAccount(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String normalizedEmail = email == null ? "" : email.trim();

        if (accountService.isAccountEmailExists(normalizedEmail)) {
            request.getSession().setAttribute("errorMessage", "Email đã tồn tại, không thể tạo tài khoản trùng");
            response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
            return;
        }

        if (!isAllowedRole(role)) {
            request.getSession().setAttribute("errorMessage", "Vai trò không hợp lệ theo FR-ADM-02");
            response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
            return;
        }

        boolean created = accountService.createAccount(fullName, normalizedEmail, PasswordUtil.hashPassword(password), role, "active");
        request.getSession().setAttribute(created ? "successMessage" : "errorMessage",
                created ? "Đã tạo tài khoản thành công" : "Không thể tạo tài khoản");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    /**
     * Updates account role for the Admin module.
     */
    public void updateAccountRole(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        String role = request.getParameter("role");
        boolean ok = accountId > 0 && accountService.updateAccountRole(accountId, role);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật phân quyền tài khoản" : "Không thể cập nhật phân quyền");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    /**
     * Updates account status for the Admin module.
     */
    public void updateAccountStatus(HttpServletRequest request, HttpServletResponse response, String targetStatus) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        boolean ok = accountId > 0 && accountService.updateAccountStatus(accountId, targetStatus);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? ("locked".equals(targetStatus) ? "Đã khóa tài khoản" : "Đã kích hoạt lại tài khoản")
                        : "Không thể cập nhật trạng thái tài khoản");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    /**
     * Deletes account for the Admin module.
     */
    public void deleteAccount(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        boolean ok = accountId > 0 && accountService.deleteAccount(accountId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã xóa tài khoản" : "Không thể xóa tài khoản");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    /**
     * Updates account profile for the Admin module.
     */
    public void updateAccountProfile(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String department = request.getParameter("department");

        boolean ok = accountId > 0 && accountService.updateAccountProfileByRole(accountId, fullName, email, phone, address, department);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật hồ sơ tài khoản" : "Không thể cập nhật hồ sơ tài khoản");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    /**
     * Handles ajax toggle account status for the Admin module.
     */
    public void ajaxToggleAccountStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        String status = request.getParameter("status");
        boolean ok = accountId > 0 && accountService.updateAccountStatus(accountId, status);

        response.setContentType("application/json;charset=UTF-8");
        try (java.io.PrintWriter out = response.getWriter()) {
            out.print("{\"success\":");
            out.print(ok);
            out.print(",\"activeAccounts\":");
            out.print(accountService.loadAccounts(null, null, "active").size());
            out.print(",\"lockedAccounts\":");
            out.print(accountService.loadAccounts(null, null, "locked").size());
            out.print("}");
        }
    }

    /**
     * Loads account profile data for the Admin UI.
     */
    public void loadAccountProfile(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        int accountId = parseInt(request.getParameter("accountId"), -1);
        Map<String, Object> profile = accountId > 0 ? accountService.getAccountProfile(accountId) : null;
        try (java.io.PrintWriter out = response.getWriter()) {
            if (profile == null) {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy tài khoản\"}");
                return;
            }
            out.print("{\"success\":true,\"item\":{");
            out.print("\"accountId\":" + profile.getOrDefault("accountId", 0));
            out.print(",\"fullName\":\"" + escape(String.valueOf(profile.getOrDefault("fullName", ""))) + "\"");
            out.print(",\"email\":\"" + escape(String.valueOf(profile.getOrDefault("email", ""))) + "\"");
            out.print(",\"role\":\"" + escape(String.valueOf(profile.getOrDefault("role", ""))) + "\"");
            out.print(",\"phone\":\"" + escape(String.valueOf(profile.getOrDefault("phone", ""))) + "\"");
            out.print(",\"address\":\"" + escape(String.valueOf(profile.getOrDefault("address", ""))) + "\"");
            out.print(",\"department\":\"" + escape(String.valueOf(profile.getOrDefault("department", ""))) + "\"");
            out.print(",\"status\":\"" + escape(String.valueOf(profile.getOrDefault("status", ""))) + "\"");
            out.print("}}");
        }
    }

    /**
     * Handles is allowed role for the Admin module.
     *
     * @return the operation result
     */
    private boolean isAllowedRole(String role) {
        return role != null && ("admin".equalsIgnoreCase(role)
                || "receptionist".equalsIgnoreCase(role)
                || "doctor".equalsIgnoreCase(role)
                || "patient".equalsIgnoreCase(role));
    }

    /**
     * Handles parse int for the Admin module.
     *
     * @return the operation result
     */
    private int parseInt(String raw, int fallback) {
        try {
            return Integer.parseInt(raw);
        } catch (Exception ex) {
            return fallback;
        }
    }

    /**
     * Handles escape for the Admin module.
     *
     * @return the operation result
     */
    private String escape(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}

/**
 * Handles medical service catalog screens and actions.
 */
class AdminMedicalServiceHandler {
    private final AdminMedicalServiceService medicalServiceService = new AdminMedicalServiceService();

    /**
     * Loads services data for the Admin UI.
     */
    public void loadServices(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String serviceType = request.getParameter("serviceType");
        String status = request.getParameter("status");
        request.setAttribute("services", medicalServiceService.loadServices(search, serviceType, status));
        request.getRequestDispatcher("/admin/services.jsp").forward(request, response);
    }

    /**
     * Creates service for the Admin module.
     */
    public void createService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String serviceName = request.getParameter("serviceName");
        String serviceType = request.getParameter("serviceType");
        String status = request.getParameter("status");
        BigDecimal price = parseBigDecimal(request.getParameter("price"));

        boolean ok = medicalServiceService.createService(serviceName, price, serviceType, status);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã thêm dịch vụ y tế" : "Không thể thêm dịch vụ y tế");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    /**
     * Updates service for the Admin module.
     */
    public void updateService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int serviceId = parseInt(request.getParameter("serviceId"), -1);
        String serviceName = request.getParameter("serviceName");
        String serviceType = request.getParameter("serviceType");
        String status = request.getParameter("status");
        BigDecimal price = parseBigDecimal(request.getParameter("price"));

        boolean ok = serviceId > 0 && medicalServiceService.updateService(serviceId, serviceName, price, serviceType, status);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật dịch vụ y tế" : "Không thể cập nhật dịch vụ y tế");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    /**
     * Updates service status for the Admin module.
     */
    public void updateServiceStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int serviceId = parseInt(request.getParameter("serviceId"), -1);
        String status = request.getParameter("status");
        boolean ok = serviceId > 0 && medicalServiceService.updateServiceStatus(serviceId, status);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật trạng thái dịch vụ" : "Không thể cập nhật trạng thái dịch vụ");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    /**
     * Deletes service for the Admin module.
     */
    public void deleteService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int serviceId = parseInt(request.getParameter("serviceId"), -1);
        boolean ok = serviceId > 0 && medicalServiceService.deleteService(serviceId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã xóa dịch vụ y tế" : "Không thể xóa dịch vụ y tế");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    /**
     * Handles parse int for the Admin module.
     *
     * @return the operation result
     */
    private int parseInt(String raw, int fallback) {
        try {
            return Integer.parseInt(raw);
        } catch (Exception ex) {
            return fallback;
        }
    }

    /**
     * Handles parse big decimal for the Admin module.
     *
     * @return the operation result
     */
    private BigDecimal parseBigDecimal(String raw) {
        try {
            return raw == null || raw.isBlank() ? BigDecimal.ZERO : new BigDecimal(raw);
        } catch (Exception ex) {
            return BigDecimal.ZERO;
        }
    }
}
