package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.dao.AdminDAO;
import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.CsrfUtil;
import com.diabetes.monitoring.util.GeminiSchedulingService;
import com.diabetes.monitoring.util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AdminServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AdminServlet.class.getName());
    private final AdminDAO adminDAO = new AdminDAO();
    private final GeminiSchedulingService geminiSchedulingService = new GeminiSchedulingService();

    // =========================
    // PHÂN KHU ĐIỀU HƯỚNG ADMIN
    // =========================

    // Điều phối request GET cho toàn bộ phân hệ Admin.
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            String xhr = request.getHeader("X-Requested-With");
            String accept = request.getHeader("Accept");
            boolean wantsJson = (xhr != null && "XMLHttpRequest".equalsIgnoreCase(xhr)) || (accept != null && accept.toLowerCase().contains("application/json"));
            if (wantsJson) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"error\":\"session_expired\",\"message\":\"Phiên làm việc đã hết, vui lòng đăng nhập lại.\"}");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/login.jsp");
            }
            return;
        }

        CsrfUtil.getOrCreateToken(session);
        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            loadDashboard(request, response);
            return;
        }

        if ("getTransferCandidates".equals(action)) {
            getTransferCandidates(request, response);
            return;
        }

        if ("dashboardChartData".equals(action)) {
            loadDashboardChartData(request, response);
            return;
        }

        if ("getReportDetail".equals(action)) {
            loadReportDetailByPeriod(request, response);
            return;
        }

        if ("getInvoiceItems".equals(action)) {
            loadInvoiceItems(request, response);
            return;
        }

        if ("quickAccountsData".equals(action)) {
            loadQuickAccountsData(request, response);
            return;
        }

        if ("quickRevenueData".equals(action)) {
            loadQuickRevenueData(response);
            return;
        }

        if ("quickServicesData".equals(action)) {
            loadQuickServicesData(response);
            return;
        }

        if ("quickAppointmentsData".equals(action)) {
            loadQuickAppointmentsData(response);
            return;
        }

        if ("getDoctorQueueDetail".equals(action)) {
            loadDoctorQueueDetail(request, response);
            return;
        }

        if ("getTodayAppointments".equals(action)) {
            loadTodayAppointments(response);
            return;
        }

        if ("getTodayWaiting".equals(action)) {
            loadTodayWaiting(response);
            return;
        }

        if ("scheduleAppointments".equals(action)) {
            loadScheduleAppointments(request, response);
            return;
        }

        if ("getAccountProfile".equals(action)) {
            loadAccountProfile(request, response);
            return;
        }

        switch (action) {
            case "listUsers":
                loadAccounts(request, response);
                break;
            case "manageServices":
                loadMedicalServices(request, response);
                break;
            case "manageSchedules":
            case "schedule":
                loadSchedules(request, response);
                break;
            case "reports":
                loadReports(request, response);
                break;
            case "exception":
            case "viewHealthRecords":
                loadExceptionRouting(request, response);
                break;
            default:
                loadDashboard(request, response);
                break;
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        if (!CsrfUtil.isValid(request)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Invalid CSRF token");
            return;
        }

        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/admin");
            return;
        }

        switch (action) {
            case "getTransferCandidates":
                getTransferCandidates(request, response);
                return;
            case "createAccount":
                createAccount(request, response);
                break;
            case "updateAccountRole":
                request.getSession().setAttribute("errorMessage", "Tính năng thay đổi vai trò đã bị vô hiệu hóa");
                response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
                break;
            case "lockAccount":
                updateAccountStatus(request, response, "locked");
                break;
            case "reactivateAccount":
                updateAccountStatus(request, response, "active");
                break;
            case "deleteAccount":
                deleteAccount(request, response);
                break;
            case "updateAccountProfile":
                updateAccountProfile(request, response);
                break;
            case "createService":
                createService(request, response);
                break;
            case "updateService":
                updateService(request, response);
                break;
            case "updateServiceStatus":
                updateServiceStatus(request, response);
                break;
            case "ajaxToggleAccountStatus":
                ajaxToggleAccountStatus(request, response);
                break;
            case "ajaxToggleServiceStatus":
                ajaxToggleServiceStatus(request, response);
                break;
            case "deleteService":
                deleteService(request, response);
                break;
            case "createSchedule":
                createSchedule(request, response);
                break;
            case "aiCreateSchedules":
                aiCreateSchedules(request, response);
                break;
            case "updateSchedule":
                updateSchedule(request, response);
                break;
            case "transferSchedule":
                transferSchedule(request, response);
                break;
            case "deleteSchedule":
                deleteSchedule(request, response);
                break;
            case "cancelSchedule":
                cancelSchedule(request, response);
                break;
            case "emergencyReassign":
                emergencyReassign(request, response);
                break;
            default:
                session.setAttribute("errorMessage", "Hành động không hợp lệ");
                response.sendRedirect(request.getContextPath() + "/admin");
                break;
        }
    }

    // Trả về danh sách bác sĩ khả dụng để nhận ca (JSON) cho một scheduleId.
    private void getTransferCandidates(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            if (scheduleId <= 0) {
                out.print("{\"currentDoctorId\":null,\"items\":[]}");
                return;
            }
            Map<String, Object> schedule = adminDAO.getDoctorScheduleById(scheduleId);
            if (schedule == null) {
                out.print("{\"currentDoctorId\":null,\"items\":[]}");
                return;
            }
            Integer currentDoctorId = schedule.get("doctorId") instanceof Number ? ((Number) schedule.get("doctorId")).intValue() : null;
            String department = String.valueOf(schedule.get("department"));
            List<Map<String, Object>> candidates = adminDAO.getAvailableDoctorsForEmergency(department, currentDoctorId);
            // Fallback to all active doctors if none in same dept
            if (candidates == null || candidates.isEmpty()) {
                candidates = adminDAO.getAllActiveDoctorsForEmergency(currentDoctorId);
            }
            StringBuilder sb = new StringBuilder();
            sb.append('{');
            sb.append("\"currentDoctorId\":"); sb.append(currentDoctorId == null ? "null" : currentDoctorId);
            sb.append(",\"items\":[");
            boolean first = true;
            for (Map<String, Object> d : candidates) {
                if (!first) sb.append(',');
                first = false;
                sb.append('{');
                sb.append("\"doctorId\":").append(d.get("doctorId")).append(',');
                sb.append("\"fullName\":\"").append(escapeJson(String.valueOf(d.get("fullName")))).append('\"').append(',');
                sb.append("\"department\":\"").append(escapeJson(String.valueOf(d.get("department")))).append('\"');
                sb.append('}');
            }
            sb.append("]}");
            out.print(sb.toString());
        }
    }

    // =========================
    // PHÂN KHU DASHBOARD ADMIN
    // =========================

    // Nạp dashboard tổng quan: KPI, queue, lịch trực hôm nay, dữ liệu biểu đồ.
    private void loadDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        adminDAO.normalizeFutureCompletedAppointments();
        adminDAO.markLateWaitingAppointmentsAsNoShow();
        adminDAO.autoTransitionAppointmentStatuses(); // [DEMO] Auto-transition appointment statuses

        int totalAccounts = adminDAO.getCountTotalAccounts();
        int activeAccounts = adminDAO.getCountActiveAccounts();
        int lockedAccounts = adminDAO.getCountLockedAccounts();
        int totalServices = adminDAO.getCountTotalServices();
        BigDecimal totalRevenuePaid = adminDAO.getSumPaidRevenue();
        int completedAppointments = adminDAO.getCountCompletedAppointments();
        List<Map<String, Object>> todayQueueStatus = adminDAO.getTodayClinicQueueStatus();
        List<Map<String, Object>> todayShiftsList = adminDAO.getTodaySchedules();
        int totalVisitsToday = adminDAO.getTodayTotalVisits();
        int waitingPatientsToday = adminDAO.getTodayWaitingPatients();
        int availableBedsToday = 15;

        List<Map<String, Object>> todayPatientFlow = adminDAO.getTodayPatientFlowByTimeSlot();
        List<Map<String, Object>> todayRevenueByService = adminDAO.getTodayRevenueByServiceType();
        List<Map<String, Object>> todayStatusDistribution = adminDAO.getTodayAppointmentStatusDistribution();

        int totalWaitingToday = 0;
        for (Map<String, Object> row : todayQueueStatus) {
            totalWaitingToday += parseInt(String.valueOf(row.get("waitingCount")), 0);
        }

        request.setAttribute("totalAccounts", totalAccounts);
        request.setAttribute("activeAccounts", activeAccounts);
        request.setAttribute("lockedAccounts", lockedAccounts);
        request.setAttribute("totalServices", totalServices);
        request.setAttribute("sumPaidRevenue", totalRevenuePaid);
        request.setAttribute("completedAppointments", completedAppointments);
        request.setAttribute("todayQueueStatus", todayQueueStatus);
        request.setAttribute("todayShiftsList", todayShiftsList);
        request.setAttribute("todayShiftsCount", todayShiftsList.size());
        request.setAttribute("totalWaitingToday", totalWaitingToday);
        request.setAttribute("totalVisitsToday", totalVisitsToday);
        request.setAttribute("waitingPatientsToday", waitingPatientsToday);
        request.setAttribute("availableBedsToday", availableBedsToday);
        request.setAttribute("todayAppointments", totalVisitsToday);
        request.setAttribute("waitingPatients", waitingPatientsToday);
        request.setAttribute("availableBeds", availableBedsToday);
        request.setAttribute("todayPatientFlowJson", toJsonSimpleRows(todayPatientFlow));
        request.setAttribute("todayRevenueByServiceJson", toJsonSimpleRows(todayRevenueByService));
        request.setAttribute("todayStatusDistributionJson", toJsonSimpleRows(todayStatusDistribution));
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    // API JSON dữ liệu biểu đồ dashboard theo granularity.
    private void loadDashboardChartData(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            String granularity = request.getParameter("granularity");
            if (granularity == null || granularity.isBlank()) {
                granularity = "month";
            }

            List<Map<String, Object>> revenueSeries = adminDAO.getDashboardRevenueSeries(granularity);
            List<Map<String, Object>> visitSeries = adminDAO.getDashboardVisitSeries(granularity);

            try (PrintWriter out = response.getWriter()) {
                out.print("{\"granularity\":\"");
                out.print(escapeJson(granularity.toLowerCase()));
                out.print("\",\"revenue\":");
                out.print(toJsonSeries(revenueSeries));
                out.print(",\"visits\":");
                out.print(toJsonSeries(visitSeries));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadDashboardChartData", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải dữ liệu biểu đồ.\"}" );
            }
        }
    }

    // =========================
    // PHÂN KHU QUICK API DASHBOARD
    // =========================

    // API chi tiết báo cáo theo kỳ (để drill-down từ trang report).
    private void loadReportDetailByPeriod(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            String period = request.getParameter("period");
            if (period == null || period.isBlank()) {
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"invoices\":[],\"appointments\":[]}");
                }
                return;
            }

            Map<String, Object> result = adminDAO.getReportDetailByPeriod(period);

            try (PrintWriter out = response.getWriter()) {
                out.print("{\"invoices\":");
                out.print(toJsonInvoices((List<Map<String, Object>>) result.get("invoices")));
                out.print(",\"appointments\":");
                out.print(toJsonAppointments((List<Map<String, Object>>) result.get("appointments")));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadReportDetailByPeriod", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải chi tiết báo cáo.\"}" );
            }
        }
    }

    // =========================
    // PHÂN KHU TÀI KHOẢN VÀ DỊCH VỤ
    // =========================

    // API lấy danh sách dịch vụ chi tiết của một hóa đơn.
    private void loadInvoiceItems(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            String invoiceId = request.getParameter("invoiceId");
            List<Map<String, Object>> items = adminDAO.getInvoiceItemsByInvoiceId(invoiceId);

            try (PrintWriter out = response.getWriter()) {
                out.print("{\"invoiceId\":\"");
                out.print(escapeJson(invoiceId == null ? "" : invoiceId));
                out.print("\",\"items\":");
                out.print(toJsonInvoiceItems(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadInvoiceItems", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải mét hóa đơn.\"}" );
            }
        }
    }

    private void loadQuickAccountsData(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            String filter = request.getParameter("filter");
            String status = (filter == null || filter.isBlank() || "all".equalsIgnoreCase(filter)) ? null : filter;
            List<Map<String, Object>> items = adminDAO.getStaffAccountsQuick(status, 50);

            try (PrintWriter out = response.getWriter()) {
                out.print("{\"filter\":\"");
                out.print(escapeJson(filter == null ? "all" : filter));
                out.print("\",\"summary\":{");
                out.print("\"totalAccounts\":");
                out.print(adminDAO.getCountTotalAccounts());
                out.print(",\"activeAccounts\":");
                out.print(adminDAO.getCountActiveAccounts());
                out.print(",\"lockedAccounts\":");
                out.print(adminDAO.getCountLockedAccounts());
                out.print("},\"items\":");
                out.print(toJsonSimpleRows(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadQuickAccountsData", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải dữ liệu tài khoản.\"}"  );
            }
        }
    }

    private void loadQuickRevenueData(HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            List<Map<String, Object>> items = adminDAO.getRecentPaidInvoicesToday(10);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"items\":");
                out.print(toJsonSimpleRows(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadQuickRevenueData", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải dữ liệu doanh thu.\"}" );
            }
        }
    }

    private void loadQuickServicesData(HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            List<Map<String, Object>> items = adminDAO.getMedicalServices(null, null, null);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"summary\":{\"activeServices\":");
                out.print(adminDAO.getCountTotalServices());
                out.print("},\"items\":");
                out.print(toJsonSimpleRows(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadQuickServicesData", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải dữ liệu dịch vụ.\"}" );
            }
        }
    }

    private void loadQuickAppointmentsData(HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            List<Map<String, Object>> items = adminDAO.getCompletedAppointmentsTodayQuick(50);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"items\":");
                out.print(toJsonSimpleRows(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadQuickAppointmentsData", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải dữ liệu lượt khám.\"}" );
            }
        }
    }

    private void loadDoctorQueueDetail(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            adminDAO.markLateWaitingAppointmentsAsNoShow();

            int doctorId = parseInt(request.getParameter("doctorId"), -1);
            List<Map<String, Object>> items = doctorId > 0
                    ? adminDAO.getDoctorQueueDetailToday(doctorId)
                    : new ArrayList<>();

            try (PrintWriter out = response.getWriter()) {
                out.print("{\"items\":");
                out.print(toJsonSimpleRows(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadDoctorQueueDetail", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải chi tiết hàng đợi.\"}" );
            }
        }
    }

    private void loadTodayAppointments(HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            adminDAO.markLateWaitingAppointmentsAsNoShow();
            List<Map<String, Object>> items = adminDAO.getTodayAppointments();
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"items\":");
                out.print(toJsonSimpleRows(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadTodayAppointments", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải lịch hẹn hôm nay.\"}" );
            }
        }
    }

    private void loadTodayWaiting(HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            adminDAO.markLateWaitingAppointmentsAsNoShow();
            List<Map<String, Object>> items = adminDAO.getTodayWaitingDetails();
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"items\":");
                out.print(toJsonSimpleRows(items));
                out.print("}");
            }
        } catch (Exception ex) {
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            log("Error in loadTodayWaiting", ex);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"true\",\"message\":\"Không thể tải danh sách chờ.\"}" );
            }
        }
    }

    private void loadScheduleAppointments(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            List<Map<String, Object>> items = scheduleId > 0
                    ? adminDAO.getAppointmentsBySchedule(scheduleId)
                    : new ArrayList<>();

            out.print("{\"scheduleId\":");
            out.print(scheduleId);
            out.print(",\"items\":");
            out.print(toJsonSimpleRows(items));
            out.print("}");
        } catch (Exception ex) {
            // Ensure we always return JSON on error (avoid HTML/stacktrace pages)
            log("Error in loadScheduleAppointments", ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"error\":\"");
                out.print(escapeJson(ex.getMessage()));
                out.print("\"}");
            }
        }
    }

    // =========================
    // PHÂN KHU QUẢN LÝ TÀI KHOẢN
    // =========================

    // Nạp màn quản trị tài khoản và phân quyền.
    private void loadAccounts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String role = request.getParameter("role");
        String status = request.getParameter("status");

        request.setAttribute("selectedSearch", search == null ? "" : search);
        request.setAttribute("selectedRole", role == null ? "" : role);
        request.setAttribute("selectedStatus", status == null ? "" : status);
        request.setAttribute("users", adminDAO.getAccounts(search, role, status));
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void createAccount(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        String normalizedEmail = email == null ? "" : email.trim();

        if (adminDAO.isAccountEmailExists(normalizedEmail)) {
            request.getSession().setAttribute("errorMessage", "Email đã tồn tại, không thể tạo tài khoản trùng");
            response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
            return;
        }

        if (!adminDAO.isAllowedRole(role)) {
            request.getSession().setAttribute("errorMessage", "Vai trò không hợp lệ theo FR-ADM-02");
            response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
            return;
        }

        boolean created = adminDAO.createAccount(fullName, normalizedEmail, PasswordUtil.hashPassword(password), role, "active");
        request.getSession().setAttribute(created ? "successMessage" : "errorMessage",
                created ? "Đã tạo tài khoản thành công" : "Không thể tạo tài khoản");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    private void updateAccountRole(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        String role = request.getParameter("role");

        boolean ok = accountId > 0 && adminDAO.updateAccountRole(accountId, role);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật phân quyền tài khoản" : "Không thể cập nhật phân quyền");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    private void updateAccountStatus(HttpServletRequest request, HttpServletResponse response, String targetStatus) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        boolean ok = accountId > 0 && adminDAO.updateAccountStatus(accountId, targetStatus);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? ("locked".equals(targetStatus) ? "Đã khóa tài khoản" : "Đã kích hoạt lại tài khoản")
                        : "Không thể cập nhật trạng thái tài khoản");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    private void deleteAccount(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        Map<String, Object> profile = accountId > 0
                ? adminDAO.getAccountProfileForAdminEdit(accountId)
                : new HashMap<>();

        String role = String.valueOf(profile.getOrDefault("role", ""));
        if ("Doctor".equals(role)) {
            request.getSession().setAttribute("errorMessage", "Tài khoản bác sĩ chỉ được vô hiệu hóa, không được xóa");
            response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
            return;
        }

        boolean ok = accountId > 0 && adminDAO.deleteAccountForAdmin(accountId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã xóa tài khoản" : "Không thể xóa tài khoản (có thể đang phát sinh dữ liệu liên quan)");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    private void loadAccountProfile(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        Map<String, Object> profile = accountId > 0
                ? adminDAO.getAccountProfileForAdminEdit(accountId)
                : new HashMap<>();

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            if (profile.isEmpty()) {
                out.print("{\"success\":false,\"message\":\"Không tìm thấy tài khoản\"}");
                return;
            }

            out.print("{\"success\":true,\"item\":{");
            out.print("\"accountId\":");
            out.print(parseInt(String.valueOf(profile.get("accountId")), 0));
            out.print(",\"fullName\":\"");
            out.print(escapeJson(String.valueOf(profile.getOrDefault("fullName", ""))));
            out.print("\",\"email\":\"");
            out.print(escapeJson(String.valueOf(profile.getOrDefault("email", ""))));
            out.print("\",\"role\":\"");
            out.print(escapeJson(String.valueOf(profile.getOrDefault("role", ""))));
            out.print("\",\"phone\":\"");
            out.print(escapeJson(String.valueOf(profile.getOrDefault("phone", ""))));
            out.print("\",\"address\":\"");
            out.print(escapeJson(String.valueOf(profile.getOrDefault("address", ""))));
            out.print("\",\"department\":\"");
            out.print(escapeJson(String.valueOf(profile.getOrDefault("department", ""))));
            out.print("\"}}");
        }
    }

    private void updateAccountProfile(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String department = request.getParameter("department");

        boolean ok = accountId > 0 && adminDAO.updateAccountProfileByRole(accountId, fullName, email, phone, address, department);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật hồ sơ tài khoản" : "Không thể cập nhật hồ sơ tài khoản");
        response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
    }

    // =========================
    // PHÂN KHU QUẢN LÝ DỊCH VỤ
    // =========================

    // Nạp màn hình quản trị danh mục dịch vụ y tế.
    private void loadMedicalServices(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String serviceType = request.getParameter("serviceType");
        String status = request.getParameter("status");

        request.setAttribute("services", adminDAO.getMedicalServices(search, serviceType, status));
        request.getRequestDispatcher("/admin/services.jsp").forward(request, response);
    }

    private void createService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String serviceName = request.getParameter("serviceName");
        String serviceType = request.getParameter("serviceType");
        String status = request.getParameter("status");
        BigDecimal price = parseBigDecimal(request.getParameter("price"), BigDecimal.ZERO);

        boolean ok = adminDAO.createMedicalService(serviceName, price, serviceType, status);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã thêm dịch vụ y tế" : "Không thể thêm dịch vụ y tế");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    private void updateService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int serviceId = parseInt(request.getParameter("serviceId"), -1);
        String serviceName = request.getParameter("serviceName");
        String serviceType = request.getParameter("serviceType");
        String status = request.getParameter("status");
        BigDecimal price = parseBigDecimal(request.getParameter("price"), BigDecimal.ZERO);

        boolean ok = serviceId > 0 && adminDAO.updateMedicalService(serviceId, serviceName, price, serviceType, status);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật dịch vụ y tế" : "Không thể cập nhật dịch vụ y tế");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    private void updateServiceStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int serviceId = parseInt(request.getParameter("serviceId"), -1);
        String status = request.getParameter("status");

        boolean ok = serviceId > 0 && adminDAO.updateMedicalServiceStatus(serviceId, status);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật trạng thái dịch vụ" : "Không thể cập nhật trạng thái dịch vụ");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    private void ajaxToggleAccountStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int accountId = parseInt(request.getParameter("accountId"), -1);
        String status = request.getParameter("status");
        boolean ok = accountId > 0 && adminDAO.updateAccountStatus(accountId, status);

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\":");
            out.print(ok);
            out.print(",\"activeAccounts\":");
            out.print(adminDAO.getCountActiveAccounts());
            out.print(",\"lockedAccounts\":");
            out.print(adminDAO.getCountLockedAccounts());
            out.print("}");
        }
    }

    private void ajaxToggleServiceStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int serviceId = parseInt(request.getParameter("serviceId"), -1);
        String status = request.getParameter("status");
        boolean ok = serviceId > 0 && adminDAO.updateMedicalServiceStatus(serviceId, status);

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\":");
            out.print(ok);
            out.print(",\"activeServices\":");
            out.print(adminDAO.getCountTotalServices());
            out.print("}");
        }
    }

    private void deleteService(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int serviceId = parseInt(request.getParameter("serviceId"), -1);
        boolean ok = serviceId > 0 && adminDAO.deleteMedicalService(serviceId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã xóa dịch vụ y tế" : "Không thể xóa dịch vụ y tế");
        response.sendRedirect(request.getContextPath() + "/admin?action=manageServices");
    }

    // =========================
    // PHÂN KHU QUẢN LÝ LỊCH TRỰC
    // =========================

    // Nạp màn hình schedule-management và đồng bộ effectiveStatus.
    private void loadSchedules(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        adminDAO.markLateWaitingAppointmentsAsNoShow();
        adminDAO.refreshDoctorScheduleStatusFromAppointments();

        String department = request.getParameter("department");
        String doctorName = request.getParameter("doctorName");
        Date workDate = nullableDate(request.getParameter("workDate"));
        int transferScheduleId = parseInt(request.getParameter("transferScheduleId"), -1);

        request.setAttribute("doctors", adminDAO.getDoctorsForSchedule());
        request.setAttribute("departments", adminDAO.getScheduleDepartments());
        request.setAttribute("selectedDepartment", department == null ? "" : department);
        request.setAttribute("doctorNameFilter", doctorName == null ? "" : doctorName);
        request.setAttribute("selectedWorkDate", request.getParameter("workDate"));

        Map<String, Object> selectedSchedule = null;
        List<Map<String, Object>> transferCandidates = new ArrayList<>();
        if (transferScheduleId > 0) {
            selectedSchedule = adminDAO.getDoctorScheduleById(transferScheduleId);
            if (selectedSchedule != null) {
                Integer currentDoctorId = selectedSchedule.get("doctorId") instanceof Number
                        ? ((Number) selectedSchedule.get("doctorId")).intValue()
                        : null;
                String sourceDepartment = String.valueOf(selectedSchedule.get("department"));
                transferCandidates = adminDAO.getAvailableDoctorsForEmergency(sourceDepartment, currentDoctorId);
                if (transferCandidates.isEmpty()) {
                    transferCandidates = adminDAO.getAllActiveDoctorsForEmergency(currentDoctorId);
                }
            }
        }
        request.setAttribute("selectedSchedule", selectedSchedule);
        request.setAttribute("transferCandidates", transferCandidates);

        List<Map<String, Object>> rawSchedules = adminDAO.getDoctorSchedules(department, doctorName, workDate);
        for (Map<String, Object> row : rawSchedules) {
            if (!row.containsKey("activeAppointments")) {
                row.put("activeAppointments", row.get("activeCount"));
            }
            if (!row.containsKey("bookedAppointments")) {
                row.put("bookedAppointments", row.get("bookedCount"));
            }
            if (!row.containsKey("bookedCount")) {
                row.put("bookedCount", row.get("bookedAppointments"));
            }
            boolean isFull = Boolean.TRUE.equals(row.get("isFull"));
            String configured = String.valueOf(row.get("status"));
            if ("Expired".equalsIgnoreCase(configured) || "Cancelled".equalsIgnoreCase(configured)) {
                row.put("effectiveStatus", configured);
            } else {
                row.put("effectiveStatus", isFull ? "Full" : configured);
            }
        }
        request.setAttribute("schedules", rawSchedules);
        request.getRequestDispatcher("/admin/schedule-management.jsp").forward(request, response);
    }

    // Tạo ca trực thủ công từ form admin.
    private void createSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int doctorId = parseInt(request.getParameter("doctorId"), -1);
        Date workDate = nullableDate(request.getParameter("workDate"));
        String timeSlot = request.getParameter("timeSlot");
        int maxPatients = parseInt(request.getParameter("maxPatients"), 0);

        boolean ok = doctorId > 0 && workDate != null
                && adminDAO.createDoctorSchedule(doctorId, workDate, timeSlot, maxPatients, "Available");
        String daoMessage = adminDAO.consumeScheduleValidationMessage();
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
            ok ? "Đã tạo ca trực bác sĩ"
                : (daoMessage == null || daoMessage.isBlank() ? "Không thể tạo ca trực" : daoMessage));
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
    }


    // =========================
    // PHÂN KHU AI SCHEDULING VÀ ĐIỀU PHỐI KHẨN
    // =========================

    // Entry-point gọi AI lập lịch, có bọc lỗi runtime để trả JSON an toàn.
    private void aiCreateSchedules(HttpServletRequest request, HttpServletResponse response) throws IOException {
        response.setContentType("application/json;charset=UTF-8");
        try {
            executeAiCreateSchedules(request, response);
        } catch (StackOverflowError error) {
            writeAiScheduleError(response,
                    "Dữ liệu Gemini quá lớn để xử lý. Hệ thống đã chặn lỗi và chưa ghi lịch vào database.");
        } catch (RuntimeException error) {
            writeAiScheduleError(response,
                    "Không thể xử lý lịch AI: " + (error.getMessage() == null ? "Lỗi dữ liệu không xác định." : error.getMessage()));
        }
    }

    // Pipeline AI schedule: validate input -> Gemini -> fallback local -> trả kết quả.
    private void executeAiCreateSchedules(HttpServletRequest request, HttpServletResponse response) throws IOException {
        Date startDate = nullableDate(request.getParameter("startDate"));
        Date endDate = nullableDate(request.getParameter("endDate"));
        String startTime = request.getParameter("startTime");
        String endTime = request.getParameter("endTime");
        int slotMinutes = parseInt(request.getParameter("slotMinutes"), 120);
        int maxPatients = parseInt(request.getParameter("maxPatients"), 20);
        int maxSchedules = parseInt(request.getParameter("maxSchedules"), 12);
        int doctorsPerShift = parseInt(request.getParameter("doctorsPerShift"), 1);
        String department = request.getParameter("department");
        List<Map<String, String>> shiftsPerDay = parseShiftTemplates(request.getParameter("shiftTemplates"));
        List<Integer> selectedWeekdays = parseSelectedWeekdays(request.getParameterValues("selectedWeekdays"));
        List<Date> targetDates = buildSelectedTargetDates(startDate, endDate, selectedWeekdays);

        if (shiftsPerDay.isEmpty()) {
            shiftsPerDay = buildDefaultShiftTemplates(startTime, endTime, slotMinutes, department);
        }
        doctorsPerShift = Math.min(4, Math.max(1, doctorsPerShift));
        int expectedScheduleCount = targetDates.size() * shiftsPerDay.size() * doctorsPerShift;
        shiftsPerDay = expandShiftsForDoctorsPerSlot(shiftsPerDay, doctorsPerShift);
        List<Map<String, Object>> created = new ArrayList<>();
        String message;
        boolean success = false;
        if (startDate == null || endDate == null || startDate.after(endDate)) {
            message = "Khoảng ngày lập lịch không hợp lệ.";
        } else if (selectedWeekdays.isEmpty()) {
            message = "Vui lòng chọn ít nhất một ngày áp dụng trong tuần.";
        } else if (targetDates.isEmpty()) {
            message = "Khoảng thời gian không chứa ngày nào khớp với các thứ đã chọn.";
        } else if (shiftsPerDay.isEmpty()) {
            message = "Khung mẫu ca trực không hợp lệ. Mỗi dòng phải có dạng HH:mm-HH:mm|Chuyên khoa.";
        } else if (maxPatients <= 0 || maxSchedules <= 0) {
            message = "Số bệnh nhân tối đa hoặc số slot bác sĩ cần tạo không hợp lệ.";
        } else if (maxPatients > 50) {
            message = "Số bệnh nhân tối đa không được vượt quá 50 để đảm bảo chất lượng khám.";
        } else {
            maxSchedules = expectedScheduleCount;
            List<Map<String, Object>> doctors = adminDAO.getDoctorsForAiScheduling(startDate, endDate);
            // DEBUG: In ra dữ liệu doctors được gửi cho AI để kiểm định
            LOGGER.log(Level.INFO, "=== DEBUG AI SCHEDULING INPUT ===");
            LOGGER.log(Level.INFO, "Target Dates: " + targetDates);
            LOGGER.log(Level.INFO, "Shifts Per Day: " + shiftsPerDay);
            LOGGER.log(Level.INFO, "Doctors Count: " + doctors.size());
            for (Map<String, Object> doc : doctors) {
                LOGGER.log(Level.INFO, "Doctor: " + doc.get("doctorId") + " | Name: " + doc.get("doctorName")
                    + " | Department: " + doc.get("department") + " | CurrentLoad: " + doc.get("currentLoad")
                    + "% | Status: " + doc.get("status"));
            }
            GeminiSchedulingService.SchedulingResult geminiResult =
                    geminiSchedulingService.generate(targetDates, shiftsPerDay, doctors);
            if (geminiResult.success) {
                created = adminDAO.createGeminiSchedules(geminiResult.assignments, maxPatients, maxSchedules);
            }
            if (created.size() != maxSchedules) {
                created = adminDAO.createAiOptimizedSchedules(
                        targetDates, shiftsPerDay, null, maxPatients, maxSchedules);
            }
            success = created.size() == maxSchedules;
            if (success) {
                boolean usedGemini = created.stream()
                        .anyMatch(row -> "Gemini AI".equals(String.valueOf(row.get("source"))));
                message = usedGemini
                        ? "Gemini AI đã tạo đúng " + created.size()
                                + " slot lịch trực theo target_dates x shifts_per_day x bác sĩ/ca."
                        : "Đã tạo đúng " + created.size()
                                + " slot bằng bộ cân bằng tải dự phòng vì Gemini chưa trả lịch hợp lệ.";
            } else {
                String daoMessage = adminDAO.consumeScheduleValidationMessage();
                if (daoMessage != null && !daoMessage.isBlank()) {
                    message = daoMessage;
                } else {
                    message = "Không thể tạo đủ " + maxSchedules
                            + " slot. Hệ thống đã hủy toàn bộ batch để tránh lịch thiếu hoặc sai chuyên khoa.";
                }
            }
        }

        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\":");
            out.print(success);
            out.print(",\"message\":\"");
            out.print(escapeJson(message));
            out.print("\",\"items\":");
            out.print(toJsonSimpleRows(created));
            out.print("}");
        }
    }

    // Chuẩn hóa response lỗi cho frontend AI modal.
    private void writeAiScheduleError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_OK);
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"success\":false,\"message\":\"");
            out.print(escapeJson(message));
            out.print("\",\"items\":[]}");
        }
    }

    private List<Integer> parseSelectedWeekdays(String[] values) {
        List<Integer> weekdays = new ArrayList<>();
        if (values == null) {
            return weekdays;
        }
        for (String value : values) {
            int day = parseInt(value, -1);
            if (day >= 1 && day <= 7 && !weekdays.contains(day)) {
                weekdays.add(day);
            }
        }
        return weekdays;
    }

    private List<Date> buildSelectedTargetDates(Date startDate, Date endDate, List<Integer> selectedWeekdays) {
        List<Date> dates = new ArrayList<>();
        if (startDate == null || endDate == null || startDate.after(endDate)
                || selectedWeekdays == null || selectedWeekdays.isEmpty()) {
            return dates;
        }
        java.time.LocalDate cursor = startDate.toLocalDate();
        while (!cursor.isAfter(endDate.toLocalDate())) {
            if (selectedWeekdays.contains(cursor.getDayOfWeek().getValue())) {
                dates.add(Date.valueOf(cursor));
            }
            cursor = cursor.plusDays(1);
        }
        return dates;
    }
    // Cập nhật ca trực thủ công.
    private void updateSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        Date workDate = nullableDate(request.getParameter("workDate"));
        String timeSlot = request.getParameter("timeSlot");
        int maxPatients = parseInt(request.getParameter("maxPatients"), 0);
        String status = request.getParameter("status");

        boolean ok = scheduleId > 0 && workDate != null
                && adminDAO.updateDoctorSchedule(scheduleId, workDate, timeSlot, maxPatients, status);
        String daoMessage = adminDAO.consumeScheduleValidationMessage();
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
            ok ? "Đã cập nhật ca trực"
                : (daoMessage == null || daoMessage.isBlank() ? "Không thể cập nhật ca trực" : daoMessage));
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
    }

    // Xóa hẳn một ca trực theo scheduleId.
    private void deleteSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        boolean ok = scheduleId > 0 && adminDAO.deleteDoctorSchedule(scheduleId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã xóa lịch trực" : "Không thể xóa lịch trực");
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
        }

        // Hủy ca trực (không xóa bản ghi lịch sử).
        private void cancelSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        boolean ok = scheduleId > 0 && adminDAO.cancelDoctorSchedule(scheduleId);
        String daoMessage = adminDAO.consumeScheduleValidationMessage();
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
            ok ? "Đã hủy ca trực"
                    : (daoMessage == null || daoMessage.isBlank() ? "Không thể hủy ca trực" : daoMessage));
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
        }

    // Chuyển giao ca trực cho bác sĩ khác khi bác sĩ hiện tại bận hoặc có vấn đề sức khỏe.
    private void transferSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        int targetDoctorId = parseInt(request.getParameter("targetDoctorId"), -1);
        boolean ok = scheduleId > 0 && targetDoctorId > 0
            && adminDAO.transferDoctorSchedule(scheduleId, targetDoctorId);
        String daoMessage = adminDAO.consumeScheduleValidationMessage();

        // If request is AJAX, return JSON with detailed message so frontend can show it inline.
        String xrw = request.getHeader("X-Requested-With");
        boolean isAjax = xrw != null && "XMLHttpRequest".equalsIgnoreCase(xrw)
            || (request.getHeader("Accept") != null && request.getHeader("Accept").contains("application/json"));

        if (isAjax) {
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
            out.print('{');
            out.print("\"success\":");
            out.print(ok);
            out.print(',');
            out.print("\"message\":\"");
            String msg = ok ? "Đã chuyển giao ca trực" : (daoMessage == null || daoMessage.isBlank() ? "Không thể chuyển giao ca trực" : daoMessage);
            out.print(escapeJson(msg));
            out.print('\"');
            if (ok) {
                // include new doctor info for client-side update
                    Map<String, Object> profile = adminDAO.getAccountProfileForAdminEdit(targetDoctorId);
                    String fullName = profile == null ? "" : String.valueOf(profile.getOrDefault("fullName", ""));
                    out.print(',');
                    out.print("\"targetDoctorId\":"); out.print(targetDoctorId);
                    out.print(',');
                    out.print("\"targetDoctorName\":\""); out.print(escapeJson(fullName)); out.print('\"');
                    // include updated schedule snapshot for client to refresh row
                    Map<String, Object> schedule = adminDAO.getDoctorScheduleById(scheduleId);
                    if (schedule != null) {
                        Object bookedObj = schedule.getOrDefault("bookedAppointments", schedule.getOrDefault("bookedCount", 0));
                        Object activeObj = schedule.getOrDefault("activeAppointments", schedule.getOrDefault("activeCount", 0));
                        Object maxObj = schedule.getOrDefault("maxPatients", schedule.getOrDefault("max_patients", 1));
                        int booked = parseInt(String.valueOf(bookedObj), 0);
                        int active = parseInt(String.valueOf(activeObj), 0);
                        int max = parseInt(String.valueOf(maxObj), 1);
                        double loadPct = max > 0 ? Math.min(100.0, (booked * 100.0 / max)) : 0.0;
                        out.print(','); out.print("\"bookedAppointments\":"); out.print(booked);
                        out.print(','); out.print("\"activeAppointments\":"); out.print(active);
                        out.print(','); out.print("\"maxPatients\":"); out.print(max);
                        out.print(','); out.print("\"loadPct\":"); out.print(String.format(java.util.Locale.ROOT, "%.0f", loadPct));
                        out.print(','); out.print("\"timeSlot\":\""); out.print(escapeJson(String.valueOf(schedule.getOrDefault("timeSlot", "")))); out.print('\"');
                        out.print(','); out.print("\"workDate\":\""); out.print(escapeJson(String.valueOf(schedule.getOrDefault("workDate", "")))); out.print('\"');
                    }
            }
            out.print('}');
            }
            return;
        }

        // Non-AJAX fallback: set session message and redirect as before
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
            ok ? "Đã chuyển giao ca trực"
                : (daoMessage == null || daoMessage.isBlank() ? "Không thể chuyển giao ca trực" : daoMessage));
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
    }

        // Điều phối khẩn cấp khi bác sĩ quá tải/vắng đột xuất.
        private void emergencyReassign(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int appointmentId = parseInt(request.getParameter("appointmentId"), -1);
        String[] targetDoctorIds = request.getParameterValues("targetDoctorId");

        if (appointmentId <= 0 || targetDoctorIds == null || targetDoctorIds.length == 0) {
            request.getSession().setAttribute("errorMessage", "Vui lòng chọn ít nhất một bác sĩ tái điều phối");
            response.sendRedirect(request.getContextPath() + "/admin?action=exception");
            return;
        }

        // Tái điều phối cho bác sĩ đầu tiên
        int primaryDoctorId = parseInt(targetDoctorIds[0], -1);
        boolean ok = primaryDoctorId > 0 && adminDAO.reassignAppointmentToDoctor(appointmentId, primaryDoctorId);
        
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
            ok ? "Đã tái điều phối khẩn cấp cho " + targetDoctorIds[0] + " và ghi nhận " + (targetDoctorIds.length - 1) + " bác sĩ dự phòng" 
               : "Không thể tái điều phối khẩn cấp");
        response.sendRedirect(request.getContextPath() + "/admin?action=exception");
    }

    // =========================
    // PHÂN KHU BÁO CÁO VÀ NGOẠI LỆ
    // =========================

    // Nạp trang báo cáo doanh thu/lượt khám với bộ lọc thời gian.
    private void loadReports(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        adminDAO.markLateWaitingAppointmentsAsNoShow();

        String granularity = request.getParameter("granularity");
        if (granularity == null || granularity.isBlank()) {
            granularity = "month";
        }
        String reportStartDateParam = request.getParameter("reportStartDate");
        String reportEndDateParam = request.getParameter("reportEndDate");
        Integer year = nullableInt(request.getParameter("year"));
        Integer month = nullableInt(request.getParameter("month"));
        Integer day = nullableInt(request.getParameter("day"));

        LocalDate reportStartDate = null;
        LocalDate reportEndDate = null;

        if ("day".equalsIgnoreCase(granularity)) {
            try {
                if ((reportStartDateParam == null || reportStartDateParam.isBlank())
                        && (reportEndDateParam == null || reportEndDateParam.isBlank())) {
                    LocalDate now = LocalDate.now();
                    reportStartDate = now.withDayOfMonth(1);
                    reportEndDate = now.withDayOfMonth(now.lengthOfMonth());
                } else {
                    reportStartDate = (reportStartDateParam == null || reportStartDateParam.isBlank())
                            ? null : LocalDate.parse(reportStartDateParam.trim());
                    reportEndDate = (reportEndDateParam == null || reportEndDateParam.isBlank())
                            ? null : LocalDate.parse(reportEndDateParam.trim());

                    if (reportStartDate == null && reportEndDate != null) {
                        reportStartDate = reportEndDate;
                    } else if (reportStartDate != null && reportEndDate == null) {
                        reportEndDate = reportStartDate;
                    }

                    if (reportStartDate != null && reportEndDate != null && reportStartDate.isAfter(reportEndDate)) {
                        LocalDate temp = reportStartDate;
                        reportStartDate = reportEndDate;
                        reportEndDate = temp;
                    }
                }
            } catch (Exception ex) {
                request.setAttribute("errorMessage", "Khoảng ngày lọc không hợp lệ.");
                LocalDate now = LocalDate.now();
                reportStartDate = now.withDayOfMonth(1);
                reportEndDate = now.withDayOfMonth(now.lengthOfMonth());
            }
        }

        List<Map<String, Object>> revenueSeries = normalizeReportSeries(
                adminDAO.getRevenueReport(granularity, year, month, day, reportStartDate, reportEndDate));
        List<Map<String, Object>> visitSeries = normalizeReportSeries(
                adminDAO.getVisitReport(granularity, year, month, day, reportStartDate, reportEndDate));

        request.setAttribute("granularity", granularity);
        request.setAttribute("year", year);
        request.setAttribute("month", month);
        request.setAttribute("day", day);
        request.setAttribute("reportStartDate", reportStartDate == null ? "" : reportStartDate.toString());
        request.setAttribute("reportEndDate", reportEndDate == null ? "" : reportEndDate.toString());
        request.setAttribute("revenueSeries", revenueSeries);
        request.setAttribute("visitSeries", visitSeries);
        request.setAttribute("revenueJson", toJsonSeries(revenueSeries));
        request.setAttribute("visitJson", toJsonSeries(visitSeries));

        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }

    // Nạp trang xử lý ngoại lệ và danh sách bác sĩ có thể điều phối.
    private void loadExceptionRouting(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        adminDAO.markLateWaitingAppointmentsAsNoShow();

        Integer doctorId = nullableInt(request.getParameter("doctorId"));
        List<Map<String, Object>> queueItems = adminDAO.getExceptionQueue(doctorId);

        Integer selectedAppointmentId = nullableInt(request.getParameter("appointmentId"));
        List<Map<String, Object>> candidateDoctors = new ArrayList<>();
        if (selectedAppointmentId != null) {
            for (Map<String, Object> item : queueItems) {
                Integer aid = nullableInt(String.valueOf(item.get("appointmentId")));
                if (aid != null && aid.equals(selectedAppointmentId)) {
                    Integer currentDoctorId = nullableInt(String.valueOf(item.get("currentDoctorId")));
                    // Chỉ lấy bác sĩ có lịch hợp lệ cho ngày của appointment đang xử lý.
                    candidateDoctors = adminDAO.getEmergencyCandidateDoctorsForAppointment(selectedAppointmentId, currentDoctorId);
                    request.setAttribute("selectedQueueItem", item);
                    break;
                }
            }
        }

        request.setAttribute("queueItems", queueItems);
        request.setAttribute("selectedAppointmentId", selectedAppointmentId);
        request.setAttribute("candidateDoctors", candidateDoctors);
        request.getRequestDispatcher("/admin/exception-routing.jsp").forward(request, response);
    }

    // =========================
    // PHÂN KHU HELPER JSON VÀ CHUẨN HÓA
    // =========================

    private List<Map<String, Object>> normalizeReportSeries(List<Map<String, Object>> raw) {
        List<Map<String, Object>> normalized = new ArrayList<>();
        for (Map<String, Object> item : raw) {
            Map<String, Object> row = new HashMap<>();
            Object period = item.containsKey("period") ? item.get("period") : item.get("periodLabel");
            Object value = item.containsKey("value") ? item.get("value") : item.get("metricValue");
            row.put("period", period == null ? "" : String.valueOf(period));
            row.put("value", toBigDecimal(value));
            normalized.add(row);
        }
        return normalized;
    }

    // Serialize dữ liệu dạng period-value cho Chart.js.
    private String toJsonSeries(List<Map<String, Object>> series) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < series.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            Map<String, Object> item = series.get(i);
            sb.append("{\"period\":\"")
                    .append(escapeJson(String.valueOf(item.get("period"))))
                    .append("\",\"value\":")
                    .append(toBigDecimal(item.get("value")).toPlainString())
                    .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String toJsonInvoices(List<Map<String, Object>> invoices) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < invoices.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            Map<String, Object> inv = invoices.get(i);
            sb.append("{")
                    .append("\"invoiceId\":\"").append(escapeJson(String.valueOf(inv.get("invoiceId")))).append("\",")
                    .append("\"patientName\":\"").append(escapeJson(String.valueOf(inv.get("patientName")))).append("\",")
                    .append("\"totalAmount\":").append(toBigDecimal(inv.get("totalAmount")).toPlainString()).append(",")
                    .append("\"bhytDeduction\":").append(toBigDecimal(inv.get("bhytDeduction")).toPlainString()).append(",")
                    .append("\"finalAmount\":").append(toBigDecimal(inv.get("finalAmount")).toPlainString()).append(",")
                    .append("\"paymentDate\":\"").append(escapeJson(String.valueOf(inv.get("paymentDate")))).append("\"")
                    .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String toJsonAppointments(List<Map<String, Object>> appointments) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < appointments.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            Map<String, Object> apt = appointments.get(i);
            sb.append("{")
                    .append("\"appointmentId\":\"").append(escapeJson(String.valueOf(apt.get("appointmentId")))).append("\",")
                    .append("\"patientName\":\"").append(escapeJson(String.valueOf(apt.get("patientName")))).append("\",")
                    .append("\"doctorName\":\"").append(escapeJson(String.valueOf(apt.get("doctorName")))).append("\",")
                    .append("\"timeSlot\":\"").append(escapeJson(String.valueOf(apt.get("timeSlot")))).append("\",")
                    .append("\"status\":\"").append(escapeJson(String.valueOf(apt.get("status")))).append("\",")
                    .append("\"appointmentDate\":\"").append(escapeJson(String.valueOf(apt.get("appointmentDate")))).append("\"")
                    .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String toJsonInvoiceItems(List<Map<String, Object>> items) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            Map<String, Object> item = items.get(i);
            sb.append("{")
                    .append("\"invoiceDetailId\":").append(parseInt(String.valueOf(item.get("invoiceDetailId")), 0)).append(",")
                    .append("\"invoiceId\":\"").append(escapeJson(String.valueOf(item.get("invoiceId")))).append("\",")
                    .append("\"serviceId\":").append(parseInt(String.valueOf(item.get("serviceId")), 0)).append(",")
                    .append("\"serviceName\":\"").append(escapeJson(String.valueOf(item.get("serviceName")))).append("\",")
                    .append("\"quantity\":").append(parseInt(String.valueOf(item.get("quantity")), 0)).append(",")
                    .append("\"unitPrice\":").append(toBigDecimal(item.get("unitPrice")).toPlainString()).append(",")
                    .append("\"lineTotal\":").append(toBigDecimal(item.get("lineTotal")).toPlainString())
                    .append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    // Serialize danh sách Map generic thành JSON an toàn.
    private String toJsonSimpleRows(List<Map<String, Object>> rows) {
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < rows.size(); i++) {
            if (i > 0) {
                sb.append(",");
            }
            Map<String, Object> row = rows.get(i);
            sb.append("{");
            int fieldIndex = 0;
            for (Map.Entry<String, Object> entry : row.entrySet()) {
                if (fieldIndex++ > 0) {
                    sb.append(",");
                }
                sb.append("\"").append(escapeJson(entry.getKey())).append("\":");
                Object value = entry.getValue();
                if (value == null) {
                    sb.append("null");
                } else if (value instanceof Number || value instanceof Boolean) {
                    sb.append(String.valueOf(value));
                } else {
                    sb.append("\"").append(escapeJson(String.valueOf(value))).append("\"");
                }
            }
            sb.append("}");
        }
        sb.append("]");
        return sb.toString();
    }

    private List<Map<String, String>> parseShiftTemplates(String rawTemplates) {
        List<Map<String, String>> shifts = new ArrayList<>();
        if (rawTemplates == null || rawTemplates.isBlank()) {
            return shifts;
        }
        String[] lines = rawTemplates.split("\\r?\\n");
        for (String line : lines) {
            if (line == null || line.trim().isEmpty()) {
                continue;
            }
            String[] parts = line.split("\\|", 2);
            if (parts.length < 2) {
                continue;
            }
            String timeSlot = parts[0].trim();
            String department = normalizeScheduleDepartment(parts[1]);
            if (!timeSlot.matches("\\d{2}:\\d{2}-\\d{2}:\\d{2}") || department.isEmpty()) {
                continue;
            }
            Map<String, String> shift = new HashMap<>();
            shift.put("timeSlot", timeSlot);
            shift.put("department", department);
            shifts.add(shift);
        }
        return shifts;
    }

    private List<Map<String, String>> expandShiftsForDoctorsPerSlot(List<Map<String, String>> baseShifts, int doctorsPerShift) {
        List<Map<String, String>> expanded = new ArrayList<>();
        if (baseShifts == null || baseShifts.isEmpty()) {
            return expanded;
        }
        int multiplier = Math.min(4, Math.max(1, doctorsPerShift));
        for (Map<String, String> shift : baseShifts) {
            for (int i = 0; i < multiplier; i++) {
                Map<String, String> copy = new HashMap<>();
                copy.put("timeSlot", shift.get("timeSlot"));
                copy.put("department", shift.get("department"));
                expanded.add(copy);
            }
        }
        return expanded;
    }

    private List<Map<String, String>> buildDefaultShiftTemplates(String rawStartTime, String rawEndTime, int slotMinutes, String department) {
        List<Map<String, String>> shifts = new ArrayList<>();
        String resolvedDepartment = normalizeScheduleDepartment(
                (department == null || department.isBlank()) ? "Endocrinology" : department);
        for (String timeSlot : buildScheduleTimeSlots(rawStartTime, rawEndTime, slotMinutes)) {
            Map<String, String> shift = new HashMap<>();
            shift.put("timeSlot", timeSlot);
            shift.put("department", resolvedDepartment);
            shifts.add(shift);
        }
        return shifts;
    }

    // Chuẩn hóa tên khoa để đồng nhất giữa UI và AI scheduling.
    private String normalizeScheduleDepartment(String rawDepartment) {
        if (rawDepartment == null) {
            return "";
        }
        String department = rawDepartment.trim();
        if (department.equalsIgnoreCase("Nội tiết")
                || department.equalsIgnoreCase("Nội tiết - Tiểu đường")
                || department.equalsIgnoreCase("Endocrinology")) {
            return "Endocrinology";
        }
        if (department.equalsIgnoreCase("Tim mạch") 
                || department.equalsIgnoreCase("Cardiology")) {
            return "Cardiology";
        }
        if (department.equalsIgnoreCase("Thận học") 
                || department.equalsIgnoreCase("Thận kinh")
                || department.equalsIgnoreCase("Nephrology")) {
            return "Nephrology";
        }
        if (department.equalsIgnoreCase("Tổng quát") 
                || department.equalsIgnoreCase("General")) {
            return "General";
        }
        return department;
    }
    private List<String> buildScheduleTimeSlots(String rawStartTime, String rawEndTime, int slotMinutes) {
        List<String> slots = new ArrayList<>();
        if (slotMinutes < 30 || slotMinutes > 480) {
            return slots;
        }
        try {
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
            LocalTime start = LocalTime.parse(rawStartTime, formatter);
            LocalTime end = LocalTime.parse(rawEndTime, formatter);
            if (!start.isBefore(end)) {
                return slots;
            }
            LocalTime cursor = start;
            while (cursor.plusMinutes(slotMinutes).compareTo(end) <= 0) {
                LocalTime slotEnd = cursor.plusMinutes(slotMinutes);
                slots.add(cursor.format(formatter) + "-" + slotEnd.format(formatter));
                cursor = slotEnd;
            }
        } catch (Exception ex) {
            return new ArrayList<>();
        }
        return slots;
    }
    // Parse int an toàn, fallback khi lỗi định dạng.
    private int parseInt(String raw, int fallback) {
        try {
            return Integer.parseInt(raw);
        } catch (Exception ex) {
            return fallback;
        }
    }

    private Integer nullableInt(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            return Integer.parseInt(raw);
        } catch (Exception ex) {
            return null;
        }
    }

    private Date nullableDate(String raw) {
        if (raw == null || raw.isBlank()) {
            return null;
        }
        try {
            LocalDate date = LocalDate.parse(raw);
            return Date.valueOf(date);
        } catch (Exception ex) {
            return null;
        }
    }

    private BigDecimal parseBigDecimal(String raw, BigDecimal fallback) {
        if (raw == null || raw.isBlank()) {
            return fallback;
        }
        try {
            return new BigDecimal(raw);
        } catch (Exception ex) {
            return fallback;
        }
    }

    private BigDecimal toBigDecimal(Object value) {
        if (value == null) {
            return BigDecimal.ZERO;
        }
        if (value instanceof BigDecimal) {
            return (BigDecimal) value;
        }
        try {
            return new BigDecimal(String.valueOf(value));
        } catch (Exception ex) {
            return BigDecimal.ZERO;
        }
    }

    // Escape chuỗi trước khi đưa vào JSON text.
    private String escapeJson(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "");
    }
}
