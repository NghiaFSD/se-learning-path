package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.dao.AdminDAO;
import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.CsrfUtil;
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
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class AdminServlet extends HttpServlet {
    private final AdminDAO adminDAO = new AdminDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");

        if (currentUser == null || !"admin".equalsIgnoreCase(currentUser.getRole())) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        CsrfUtil.getOrCreateToken(session);
        String action = request.getParameter("action");
        if (action == null || action.isBlank()) {
            loadDashboard(request, response);
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
            case "createAccount":
                createAccount(request, response);
                break;
            case "updateAccountRole":
                updateAccountRole(request, response);
                break;
            case "lockAccount":
                updateAccountStatus(request, response, "locked");
                break;
            case "reactivateAccount":
                updateAccountStatus(request, response, "active");
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
            case "updateSchedule":
                updateSchedule(request, response);
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

    private void loadDashboard(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        int totalAccounts = adminDAO.getCountTotalAccounts();
        int activeAccounts = adminDAO.getCountActiveAccounts();
        int lockedAccounts = adminDAO.getCountLockedAccounts();
        int totalServices = adminDAO.getCountTotalServices();
        BigDecimal totalRevenuePaid = adminDAO.getSumPaidRevenue();
        int completedAppointments = adminDAO.getCountCompletedAppointments();
        List<Map<String, Object>> todayQueueStatus = adminDAO.getTodayClinicQueueStatus();
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
        request.setAttribute("totalWaitingToday", totalWaitingToday);
        request.setAttribute("totalVisitsToday", totalVisitsToday);
        request.setAttribute("waitingPatientsToday", waitingPatientsToday);
        request.setAttribute("availableBedsToday", availableBedsToday);
        request.setAttribute("todayPatientFlowJson", toJsonSimpleRows(todayPatientFlow));
        request.setAttribute("todayRevenueByServiceJson", toJsonSimpleRows(todayRevenueByService));
        request.setAttribute("todayStatusDistributionJson", toJsonSimpleRows(todayStatusDistribution));
        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }

    private void loadDashboardChartData(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String granularity = request.getParameter("granularity");
        if (granularity == null || granularity.isBlank()) {
            granularity = "month";
        }

        List<Map<String, Object>> revenueSeries = adminDAO.getDashboardRevenueSeries(granularity);
        List<Map<String, Object>> visitSeries = adminDAO.getDashboardVisitSeries(granularity);

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"granularity\":\"");
            out.print(escapeJson(granularity.toLowerCase()));
            out.print("\",\"revenue\":");
            out.print(toJsonSeries(revenueSeries));
            out.print(",\"visits\":");
            out.print(toJsonSeries(visitSeries));
            out.print("}");
        }
    }

    private void loadReportDetailByPeriod(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String period = request.getParameter("period");
        if (period == null || period.isBlank()) {
            response.setContentType("application/json;charset=UTF-8");
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"invoices\":[],\"appointments\":[]}");
            }
            return;
        }

        Map<String, Object> result = adminDAO.getReportDetailByPeriod(period);

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"invoices\":");
            out.print(toJsonInvoices((List<Map<String, Object>>) result.get("invoices")));
            out.print(",\"appointments\":");
            out.print(toJsonAppointments((List<Map<String, Object>>) result.get("appointments")));
            out.print("}");
        }
    }

    private void loadInvoiceItems(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String invoiceId = request.getParameter("invoiceId");
        List<Map<String, Object>> items = adminDAO.getInvoiceItemsByInvoiceId(invoiceId);

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"invoiceId\":\"");
            out.print(escapeJson(invoiceId == null ? "" : invoiceId));
            out.print("\",\"items\":");
            out.print(toJsonInvoiceItems(items));
            out.print("}");
        }
    }

    private void loadQuickAccountsData(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String filter = request.getParameter("filter");
        String status = (filter == null || filter.isBlank() || "all".equalsIgnoreCase(filter)) ? null : filter;
        List<Map<String, Object>> items = adminDAO.getStaffAccountsQuick(status, 12);

        response.setContentType("application/json;charset=UTF-8");
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
    }

    private void loadQuickRevenueData(HttpServletResponse response) throws IOException {
        List<Map<String, Object>> items = adminDAO.getRecentPaidInvoicesToday(10);
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"items\":");
            out.print(toJsonSimpleRows(items));
            out.print("}");
        }
    }

    private void loadQuickServicesData(HttpServletResponse response) throws IOException {
        List<Map<String, Object>> items = adminDAO.getMedicalServices(null, null, null);
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"summary\":{\"activeServices\":");
            out.print(adminDAO.getCountTotalServices());
            out.print("},\"items\":");
            out.print(toJsonSimpleRows(items));
            out.print("}");
        }
    }

    private void loadQuickAppointmentsData(HttpServletResponse response) throws IOException {
        List<Map<String, Object>> items = adminDAO.getCompletedAppointmentsTodayQuick(10);
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"items\":");
            out.print(toJsonSimpleRows(items));
            out.print("}");
        }
    }

    private void loadDoctorQueueDetail(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int doctorId = parseInt(request.getParameter("doctorId"), -1);
        List<Map<String, Object>> items = doctorId > 0
                ? adminDAO.getDoctorQueueDetailToday(doctorId)
                : new ArrayList<>();

        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"items\":");
            out.print(toJsonSimpleRows(items));
            out.print("}");
        }
    }

    private void loadTodayAppointments(HttpServletResponse response) throws IOException {
        List<Map<String, Object>> items = adminDAO.getTodayAppointments();
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"items\":");
            out.print(toJsonSimpleRows(items));
            out.print("}");
        }
    }

    private void loadTodayWaiting(HttpServletResponse response) throws IOException {
        List<Map<String, Object>> items = adminDAO.getTodayWaitingDetails();
        response.setContentType("application/json;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            out.print("{\"items\":");
            out.print(toJsonSimpleRows(items));
            out.print("}");
        }
    }

    private void loadAccounts(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String search = request.getParameter("search");
        String role = request.getParameter("role");
        String status = request.getParameter("status");

        request.setAttribute("users", adminDAO.getAccounts(search, role, status));
        request.getRequestDispatcher("/admin/users.jsp").forward(request, response);
    }

    private void createAccount(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String fullName = request.getParameter("fullName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        if (!adminDAO.isAllowedRole(role)) {
            request.getSession().setAttribute("errorMessage", "Vai trò không hợp lệ theo FR-ADM-02");
            response.sendRedirect(request.getContextPath() + "/admin?action=listUsers");
            return;
        }

        boolean created = adminDAO.createAccount(fullName, email, PasswordUtil.hashPassword(password), role, "active");
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

    private void loadSchedules(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        adminDAO.refreshDoctorScheduleStatusFromAppointments();

        String department = request.getParameter("department");
        String doctorName = request.getParameter("doctorName");
        Date workDate = nullableDate(request.getParameter("workDate"));

        request.setAttribute("doctors", adminDAO.getDoctorsForSchedule());
        request.setAttribute("departments", adminDAO.getScheduleDepartments());
        request.setAttribute("selectedDepartment", department == null ? "" : department);
        request.setAttribute("doctorNameFilter", doctorName == null ? "" : doctorName);
        request.setAttribute("selectedWorkDate", request.getParameter("workDate"));

        List<Map<String, Object>> rawSchedules = adminDAO.getDoctorSchedules(department, doctorName, workDate);
        for (Map<String, Object> row : rawSchedules) {
            row.put("activeAppointments", row.get("activeCount"));
            boolean isFull = Boolean.TRUE.equals(row.get("isFull"));
            String configured = String.valueOf(row.get("status"));
            row.put("effectiveStatus", isFull ? "Full" : configured);
        }
        request.setAttribute("schedules", rawSchedules);
        request.getRequestDispatcher("/admin/schedule-management.jsp").forward(request, response);
    }

    private void createSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int doctorId = parseInt(request.getParameter("doctorId"), -1);
        Date workDate = nullableDate(request.getParameter("workDate"));
        String timeSlot = request.getParameter("timeSlot");
        int maxPatients = parseInt(request.getParameter("maxPatients"), 0);

        boolean ok = doctorId > 0 && workDate != null
                && adminDAO.createDoctorSchedule(doctorId, workDate, timeSlot, maxPatients, "Available");
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã tạo ca trực bác sĩ" : "Không thể tạo ca trực");
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
    }

    private void updateSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        Date workDate = nullableDate(request.getParameter("workDate"));
        String timeSlot = request.getParameter("timeSlot");
        int maxPatients = parseInt(request.getParameter("maxPatients"), 0);
        String status = request.getParameter("status");

        boolean ok = scheduleId > 0 && workDate != null
                && adminDAO.updateDoctorSchedule(scheduleId, workDate, timeSlot, maxPatients, status);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã cập nhật ca trực" : "Không thể cập nhật ca trực");
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
    }

    private void deleteSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        boolean ok = scheduleId > 0 && adminDAO.deleteDoctorSchedule(scheduleId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
                ok ? "Đã xóa lịch trực" : "Không thể xóa lịch trực");
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
        }

        private void cancelSchedule(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int scheduleId = parseInt(request.getParameter("scheduleId"), -1);
        boolean ok = scheduleId > 0 && adminDAO.cancelDoctorSchedule(scheduleId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
            ok ? "Đã hủy ca trực" : "Không thể hủy ca trực");
        response.sendRedirect(request.getContextPath() + "/admin?action=schedule");
        }

        private void emergencyReassign(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int appointmentId = parseInt(request.getParameter("appointmentId"), -1);
        int targetDoctorId = parseInt(request.getParameter("targetDoctorId"), -1);

        boolean ok = appointmentId > 0 && targetDoctorId > 0
            && adminDAO.reassignAppointmentToDoctor(appointmentId, targetDoctorId);
        request.getSession().setAttribute(ok ? "successMessage" : "errorMessage",
            ok ? "Đã tái điều phối khẩn cấp thành công" : "Không thể tái điều phối khẩn cấp");
        response.sendRedirect(request.getContextPath() + "/admin?action=exception");
    }

    private void loadReports(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String granularity = request.getParameter("granularity");
        if (granularity == null || granularity.isBlank()) {
            granularity = "month";
        }
        Integer year = nullableInt(request.getParameter("year"));
        Integer month = nullableInt(request.getParameter("month"));
        Integer day = nullableInt(request.getParameter("day"));

        List<Map<String, Object>> revenueSeries = normalizeReportSeries(adminDAO.getRevenueReport(granularity, year, month, day));
        List<Map<String, Object>> visitSeries = normalizeReportSeries(adminDAO.getVisitReport(granularity, year, month, day));

        request.setAttribute("granularity", granularity);
        request.setAttribute("year", year);
        request.setAttribute("month", month);
        request.setAttribute("day", day);
        request.setAttribute("revenueSeries", revenueSeries);
        request.setAttribute("visitSeries", visitSeries);
        request.setAttribute("revenueJson", toJsonSeries(revenueSeries));
        request.setAttribute("visitJson", toJsonSeries(visitSeries));

        request.getRequestDispatcher("/admin/reports.jsp").forward(request, response);
    }

    private void loadExceptionRouting(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        Integer doctorId = nullableInt(request.getParameter("doctorId"));
        List<Map<String, Object>> queueItems = adminDAO.getExceptionQueue(doctorId);

        Integer selectedAppointmentId = nullableInt(request.getParameter("appointmentId"));
        List<Map<String, Object>> candidateDoctors = new ArrayList<>();
        if (selectedAppointmentId != null) {
            for (Map<String, Object> item : queueItems) {
                Integer aid = nullableInt(String.valueOf(item.get("appointmentId")));
                if (aid != null && aid.equals(selectedAppointmentId)) {
                    String department = item.get("department") == null ? null : String.valueOf(item.get("department"));
                    Integer currentDoctorId = nullableInt(String.valueOf(item.get("currentDoctorId")));
                    candidateDoctors = adminDAO.getAvailableDoctorsForEmergency(department, currentDoctorId);
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
