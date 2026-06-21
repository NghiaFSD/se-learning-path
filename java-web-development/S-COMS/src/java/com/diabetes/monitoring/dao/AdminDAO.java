package com.diabetes.monitoring.dao;

import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AdminDAO {
    private static final Logger LOGGER = Logger.getLogger(AdminDAO.class.getName());

    private static final Set<String> ALLOWED_ROLES = new HashSet<>();
    private static final Set<String> ALLOWED_ACCOUNT_STATUS = new HashSet<>();
    private static final Set<String> ALLOWED_SERVICE_TYPES = new HashSet<>();
    private static final Set<String> ALLOWED_SERVICE_STATUS = new HashSet<>();
    private static final Set<String> ALLOWED_SCHEDULE_STATUS = new HashSet<>();

    static {
        ALLOWED_ROLES.add("patient");
        ALLOWED_ROLES.add("doctor");
        ALLOWED_ROLES.add("receptionist");
        ALLOWED_ROLES.add("admin");

        ALLOWED_ACCOUNT_STATUS.add("active");
        ALLOWED_ACCOUNT_STATUS.add("locked");

        ALLOWED_SERVICE_TYPES.add("Examination");
        ALLOWED_SERVICE_TYPES.add("Lab_Test");

        ALLOWED_SERVICE_STATUS.add("Active");
        ALLOWED_SERVICE_STATUS.add("Inactive");

        ALLOWED_SCHEDULE_STATUS.add("Available");
        ALLOWED_SCHEDULE_STATUS.add("Full");
        ALLOWED_SCHEDULE_STATUS.add("Cancelled");
    }

    public boolean isAllowedRole(String role) {
        return ALLOWED_ROLES.contains(normalizeRole(role));
    }

    public boolean isAllowedAccountStatus(String status) {
        return ALLOWED_ACCOUNT_STATUS.contains(normalizeAccountStatus(status));
    }

    public int getCountTotalAccounts() {
        return executeCount("SELECT COUNT(*) FROM Account");
    }

    public int getCountActiveAccounts() {
        return executeCount("SELECT COUNT(*) FROM Account WHERE status = 'Active'");
    }

    public int getCountLockedAccounts() {
        return executeCount("SELECT COUNT(*) FROM Account WHERE status = 'Locked'");
    }

    public int getCountTotalServices() {
        return executeCount("SELECT COUNT(*) FROM Medical_Service WHERE status = 'Active'");
    }

    public BigDecimal getSumPaidRevenue() {
        return executeBigDecimal("SELECT ISNULL(SUM(final_amount), 0) FROM Invoice WHERE status = 'Paid'");
    }

    public int getCountCompletedAppointments() {
        return executeCount("SELECT COUNT(*) FROM Appointment WHERE status = 'Completed'");
    }

    public List<Map<String, Object>> getDashboardRevenueSeries(String granularity) {
        return getDashboardSeries("Invoice", "created_at", "final_amount", "status", "Paid", true, granularity);
    }

    public List<Map<String, Object>> getDashboardVisitSeries(String granularity) {
        String timeColumn = hasColumn("Appointment", "created_at") ? "created_at" : "appointment_time";
        return getDashboardSeries("Appointment", timeColumn, "appointment_id", "status", "Completed", false, granularity);
    }

    public List<Map<String, Object>> getTodayClinicQueueStatus() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT d.doctor_id, d.full_name AS doctor_name, d.department, "
                + "COUNT(a.appointment_id) AS waiting_count "
                + "FROM Doctor_Schedule ds "
                + "JOIN Doctor d ON d.doctor_id = ds.doctor_id "
                + "LEFT JOIN Appointment a ON a.schedule_id = ds.schedule_id AND LOWER(a.status) = 'waiting' "
                + "WHERE ds.work_date = CAST(GETDATE() AS DATE) "
                + "AND LOWER(ds.status) <> 'cancelled' "
                + "GROUP BY d.doctor_id, d.full_name, d.department "
                + "ORDER BY waiting_count DESC, d.full_name ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("doctorId", rs.getInt("doctor_id"));
                row.put("doctorName", rs.getString("doctor_name"));
                row.put("department", rs.getString("department"));
                row.put("waitingCount", rs.getInt("waiting_count"));
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load today clinic queue status", e);
        }

        return rows;
    }

    public List<Map<String, Object>> getDoctorQueueDetailToday(int doctorId) {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT a.appointment_id, p.full_name, "
                + "FORMAT(a.appointment_time, 'HH:mm') AS appointment_time, a.status "
                + "FROM Appointment a "
                + "JOIN Patient p ON a.patient_id = p.patient_id "
                + "WHERE a.doctor_id = ? "
                + "AND a.status = 'Waiting' "
                + "AND CAST(a.created_at AS DATE) = CAST(GETDATE() AS DATE) "
                + "ORDER BY a.appointment_time ASC, a.appointment_id ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, doctorId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("appointmentId", rs.getInt("appointment_id"));
                    row.put("patientName", rs.getString("full_name"));
                    row.put("appointmentTime", rs.getString("appointment_time"));
                    row.put("status", rs.getString("status"));
                    rows.add(row);
                }
            }
            return rows;
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Primary queue-detail query failed; fallback to Account join", e);
        }

        String fallbackSql = "SELECT a.appointment_id, acc.full_name, "
                + "FORMAT(a.appointment_time, 'HH:mm') AS appointment_time, a.status "
                + "FROM Appointment a "
                + "JOIN Account acc ON a.patient_id = acc.account_id "
                + "WHERE a.doctor_id = ? "
                + "AND a.status = 'Waiting' "
                + "AND CAST(a.created_at AS DATE) = CAST(GETDATE() AS DATE) "
                + "ORDER BY a.appointment_time ASC, a.appointment_id ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(fallbackSql)) {
            statement.setInt(1, doctorId);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("appointmentId", rs.getInt("appointment_id"));
                    row.put("patientName", rs.getString("full_name"));
                    row.put("appointmentTime", rs.getString("appointment_time"));
                    row.put("status", rs.getString("status"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load queue detail for doctorId=" + doctorId, e);
        }

        return rows;
    }

    public int getTodayTotalVisits() {
        return executeCount("SELECT COUNT(*) FROM Appointment WHERE CAST(appointment_time AS DATE) = CAST(GETDATE() AS DATE)");
    }

    public int getTodayWaitingPatients() {
        return executeCount("SELECT COUNT(*) FROM Appointment WHERE LOWER(status) = 'waiting' AND CAST(appointment_time AS DATE) = CAST(GETDATE() AS DATE)");
    }

    public List<Map<String, Object>> getTodayAppointments() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT a.appointment_id, "
                + "COALESCE(p.full_name, acc.full_name, N'Chưa xác định') AS patient_name, "
                + "COALESCE(d.full_name, N'Chưa phân công') AS doctor_name, "
                + "FORMAT(a.appointment_time, 'HH:mm') AS appointment_time, "
                + "a.status "
                + "FROM Appointment a "
                + "LEFT JOIN Patient p ON p.patient_id = a.patient_id "
                + "LEFT JOIN Account acc ON acc.account_id = a.patient_id "
                + "LEFT JOIN Doctor d ON d.doctor_id = a.doctor_id "
                + "WHERE CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE) "
                + "ORDER BY a.appointment_time ASC, a.appointment_id ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("appointmentId", rs.getInt("appointment_id"));
                row.put("patientName", rs.getString("patient_name"));
                row.put("doctorName", rs.getString("doctor_name"));
                row.put("appointmentTime", rs.getString("appointment_time"));
                row.put("status", rs.getString("status"));
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load today appointments", e);
        }

        return rows;
    }

    public List<Map<String, Object>> getTodayWaitingDetails() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT a.appointment_id, "
                + "COALESCE(p.full_name, acc.full_name, N'Chưa xác định') AS patient_name, "
                + "COALESCE(d.department, dsd.department, N'Chưa xác định') AS department, "
                + "FORMAT(a.appointment_time, 'HH:mm') AS appointment_time, "
            + "a.status, "
                + "CASE WHEN DATEDIFF(MINUTE, a.appointment_time, GETDATE()) < 0 THEN 0 "
                + "ELSE DATEDIFF(MINUTE, a.appointment_time, GETDATE()) END AS waiting_minutes "
                + "FROM Appointment a "
                + "LEFT JOIN Patient p ON p.patient_id = a.patient_id "
                + "LEFT JOIN Account acc ON acc.account_id = a.patient_id "
                + "LEFT JOIN Doctor d ON d.doctor_id = a.doctor_id "
                + "LEFT JOIN Doctor_Schedule ds ON ds.schedule_id = a.schedule_id "
                + "LEFT JOIN Doctor dsd ON dsd.doctor_id = ds.doctor_id "
                + "WHERE LOWER(a.status) = 'waiting' "
                + "AND CAST(a.appointment_time AS DATE) = CAST(GETDATE() AS DATE) "
                + "ORDER BY a.appointment_time ASC, a.appointment_id ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("appointmentId", rs.getInt("appointment_id"));
                row.put("patientName", rs.getString("patient_name"));
                row.put("department", rs.getString("department"));
                row.put("appointmentTime", rs.getString("appointment_time"));
                row.put("status", rs.getString("status"));
                row.put("waitingMinutes", rs.getInt("waiting_minutes"));
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load today waiting details", e);
        }

        return rows;
    }

    public List<Map<String, Object>> getTodayPatientFlowByTimeSlot() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT ds.time_slot, COUNT(ap.appointment_id) AS visit_count "
                + "FROM Appointment ap "
                + "JOIN Doctor_Schedule ds ON ds.schedule_id = ap.schedule_id "
                + "WHERE CAST(ap.appointment_time AS DATE) = CAST(GETDATE() AS DATE) "
                + "GROUP BY ds.time_slot "
                + "ORDER BY ds.time_slot";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("timeSlot", rs.getString("time_slot"));
                row.put("visitCount", rs.getInt("visit_count"));
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load today patient flow by time slot", e);
        }

        return rows;
    }

    public List<Map<String, Object>> getTodayRevenueByServiceType() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT "
                + "COALESCE(SUM(CASE WHEN ms.service_type = 'Examination' THEN id.quantity * id.price ELSE 0 END), 0) AS exam_revenue, "
                + "COALESCE(SUM(CASE WHEN ms.service_type = 'Lab_Test' THEN id.quantity * id.price ELSE 0 END), 0) AS lab_revenue "
                + "FROM Invoice i "
                + "JOIN Invoice_Detail id ON id.invoice_id = i.invoice_id "
                + "JOIN Medical_Service ms ON ms.service_id = id.service_id "
                + "WHERE LOWER(i.status) = 'paid' "
                + "AND CAST(i.created_at AS DATE) = CAST(GETDATE() AS DATE)";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                Map<String, Object> exam = new HashMap<>();
                exam.put("serviceType", "Examination");
                exam.put("totalRevenue", rs.getBigDecimal("exam_revenue"));
                rows.add(exam);

                Map<String, Object> lab = new HashMap<>();
                lab.put("serviceType", "Lab_Test");
                lab.put("totalRevenue", rs.getBigDecimal("lab_revenue"));
                rows.add(lab);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load today revenue by service type", e);
        }

        return rows;
    }

    public List<Map<String, Object>> getTodayAppointmentStatusDistribution() {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT ap.status, COUNT(ap.appointment_id) AS total_count "
                + "FROM Appointment ap "
                + "WHERE CAST(ap.appointment_time AS DATE) = CAST(GETDATE() AS DATE) "
                + "AND LOWER(ap.status) IN ('waiting', 'in_progress', 'completed') "
                + "GROUP BY ap.status";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("status", rs.getString("status"));
                row.put("totalCount", rs.getInt("total_count"));
                rows.add(row);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load today appointment status distribution", e);
        }

        return rows;
    }

    public Map<String, Object> getDashboardSummary() {
        Map<String, Object> summary = new HashMap<>();
        summary.put("totalAccounts", 0);
        summary.put("activeAccounts", 0);
        summary.put("lockedAccounts", 0);
        summary.put("totalServices", 0);
        summary.put("activeServices", 0);
        summary.put("totalSchedules", 0);
        summary.put("fullSchedules", 0);
        summary.put("totalRevenuePaid", BigDecimal.ZERO);
        summary.put("completedVisits", 0);

        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM Account) AS total_accounts, "
                + "(SELECT COUNT(*) FROM Account WHERE LOWER(status) = 'active') AS active_accounts, "
                + "(SELECT COUNT(*) FROM Account WHERE LOWER(status) = 'locked') AS locked_accounts, "
                + "(SELECT COUNT(*) FROM Medical_Service) AS total_services, "
                + "(SELECT COUNT(*) FROM Medical_Service WHERE LOWER(status) = 'active') AS active_services, "
                + "(SELECT COUNT(*) FROM Doctor_Schedule) AS total_schedules, "
                + "(SELECT COUNT(*) FROM Doctor_Schedule WHERE LOWER(status) = 'full') AS full_schedules, "
                + "(SELECT COALESCE(SUM(final_amount), 0) FROM Invoice WHERE LOWER(status) = 'paid') AS total_revenue, "
                + "(SELECT COUNT(*) FROM Appointment WHERE LOWER(status) = 'completed') AS completed_visits";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                summary.put("totalAccounts", rs.getInt("total_accounts"));
                summary.put("activeAccounts", rs.getInt("active_accounts"));
                summary.put("lockedAccounts", rs.getInt("locked_accounts"));
                summary.put("totalServices", rs.getInt("total_services"));
                summary.put("activeServices", rs.getInt("active_services"));
                summary.put("totalSchedules", rs.getInt("total_schedules"));
                summary.put("fullSchedules", rs.getInt("full_schedules"));
                summary.put("totalRevenuePaid", rs.getBigDecimal("total_revenue"));
                summary.put("completedVisits", rs.getInt("completed_visits"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load admin dashboard summary", e);
        }
        return summary;
    }

    public List<Map<String, Object>> getMonthlyRevenueAndVisitsSeries(int monthBackInclusive) {
        List<Map<String, Object>> rows = new ArrayList<>();

        String sql = "WITH month_base AS ("
                + "    SELECT FORMAT(DATEADD(MONTH, -v.num, GETDATE()), 'yyyy-MM') AS month_key "
                + "    FROM (SELECT TOP (?) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS num FROM sys.all_objects) v"
                + "), revenue AS ("
                + "    SELECT FORMAT(created_at, 'yyyy-MM') AS month_key, SUM(final_amount) AS total_revenue "
                + "    FROM Invoice WHERE LOWER(status) = 'paid' "
                + "    GROUP BY FORMAT(created_at, 'yyyy-MM')"
                + "), visits AS ("
                + "    SELECT FORMAT(appointment_time, 'yyyy-MM') AS month_key, COUNT(appointment_id) AS completed_visits "
                + "    FROM Appointment WHERE LOWER(status) = 'completed' "
                + "    GROUP BY FORMAT(appointment_time, 'yyyy-MM')"
                + ") "
                + "SELECT mb.month_key, "
                + "       COALESCE(r.total_revenue, 0) AS total_revenue, "
                + "       COALESCE(v.completed_visits, 0) AS completed_visits "
                + "FROM month_base mb "
                + "LEFT JOIN revenue r ON r.month_key = mb.month_key "
                + "LEFT JOIN visits v ON v.month_key = mb.month_key "
                + "ORDER BY mb.month_key";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, Math.max(monthBackInclusive, 1));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("month", rs.getString("month_key"));
                    row.put("revenue", rs.getBigDecimal("total_revenue"));
                    row.put("visits", rs.getInt("completed_visits"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load monthly series", e);
        }

        return rows;
    }

    public List<User> getAccounts(String search, String role, String status) {
        List<User> users = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT account_id, full_name, email, role, status, created_at FROM Account WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ?)");
            params.add("%" + search.trim() + "%");
            params.add("%" + search.trim() + "%");
        }

        String normalizedRole = normalizeRole(role);
        if (normalizedRole != null) {
            sql.append(" AND LOWER(role) = ?");
            params.add(normalizedRole);
        }

        String normalizedStatus = normalizeAccountStatus(status);
        if (normalizedStatus != null) {
            sql.append(" AND LOWER(status) = ?");
            params.add(normalizedStatus);
        }

        sql.append(" ORDER BY created_at DESC, account_id DESC");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("account_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(toTitleCase(rs.getString("role")));
                    user.setStatus(toTitleCase(rs.getString("status")));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    users.add(user);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get admin account list", e);
        }
        return users;
    }

    public boolean createAccount(String fullName, String email, String passwordHash, String role, String status) {
        String normalizedRole = normalizeRole(role);
        String normalizedStatus = normalizeAccountStatus(status);

        if (normalizedRole == null || normalizedStatus == null) {
            return false;
        }

        String sql = "INSERT INTO Account (full_name, email, password_hash, role, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, fullName);
            statement.setString(2, email);
            statement.setString(3, passwordHash);
            statement.setString(4, normalizedRole);
            statement.setString(5, normalizedStatus);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create account", e);
            return false;
        }
    }

    public boolean updateAccountRole(int accountId, String role) {
        String normalizedRole = normalizeRole(role);
        if (normalizedRole == null) {
            return false;
        }

        String sql = "UPDATE Account SET role = ? WHERE account_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, normalizedRole);
            statement.setInt(2, accountId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update account role", e);
            return false;
        }
    }

    public boolean updateAccountStatus(int accountId, String status) {
        String normalizedStatus = normalizeAccountStatus(status);
        if (normalizedStatus == null) {
            return false;
        }

        String sql = "UPDATE Account SET status = ? WHERE account_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, normalizedStatus);
            statement.setInt(2, accountId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update account status", e);
            return false;
        }
    }

    public List<Map<String, Object>> getStaffAccountsQuick(String status, int limit) {
        List<Map<String, Object>> rows = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT TOP (?) account_id, full_name, email, role, status, created_at ")
                .append("FROM Account WHERE LOWER(role) IN ('admin', 'doctor', 'receptionist')");

        String normalizedStatus = normalizeAccountStatus(status);
        if (normalizedStatus != null) {
            sql.append(" AND LOWER(status) = ?");
        }
        sql.append(" ORDER BY created_at DESC, account_id DESC");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int index = 1;
            statement.setInt(index++, Math.max(limit, 1));
            if (normalizedStatus != null) {
                statement.setString(index, normalizedStatus);
            }
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("accountId", rs.getInt("account_id"));
                    row.put("fullName", rs.getString("full_name"));
                    row.put("email", rs.getString("email"));
                    row.put("role", rs.getString("role"));
                    row.put("status", rs.getString("status"));
                    row.put("createdAt", rs.getTimestamp("created_at"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load quick staff accounts", e);
        }
        return rows;
    }

    public List<Map<String, Object>> getRecentPaidInvoicesToday(int limit) {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT TOP (?) i.invoice_id, p.full_name AS patient_name, i.final_amount, "
                + "FORMAT(i.created_at, 'dd/MM/yyyy HH:mm') AS payment_time "
                + "FROM Invoice i "
                + "JOIN Patient p ON p.patient_id = i.patient_id "
                + "WHERE LOWER(i.status) = 'paid' AND CAST(i.created_at AS DATE) = CAST(GETDATE() AS DATE) "
                + "ORDER BY i.created_at DESC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, Math.max(limit, 1));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("invoiceId", rs.getString("invoice_id"));
                    row.put("patientName", rs.getString("patient_name"));
                    row.put("finalAmount", rs.getBigDecimal("final_amount"));
                    row.put("payment_time", rs.getString("payment_time"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load recent paid invoices for today", e);
        }
        return rows;
    }

    public List<Map<String, Object>> getCompletedAppointmentsTodayQuick(int limit) {
        List<Map<String, Object>> rows = new ArrayList<>();
        String sql = "SELECT TOP (?) ap.appointment_id, p.full_name AS patient_name, d.full_name AS doctor_name, "
                + "FORMAT(ap.appointment_time, 'HH:mm') AS appointment_time_label, "
                + "FORMAT(ap.appointment_time, 'yyyy-MM-dd') AS appointment_date "
                + "FROM Appointment ap "
                + "JOIN Account p ON p.account_id = ap.patient_id "
                + "LEFT JOIN Doctor d ON d.doctor_id = ap.doctor_id "
                + "WHERE LOWER(ap.status) = 'completed' AND CAST(ap.appointment_time AS DATE) = CAST(GETDATE() AS DATE) "
                + "ORDER BY ap.appointment_time DESC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, Math.max(limit, 1));
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("appointmentId", rs.getString("appointment_id"));
                    row.put("patientName", rs.getString("patient_name"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("appointmentTime", rs.getString("appointment_time_label"));
                    row.put("appointmentDate", rs.getString("appointment_date"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load completed appointments for today", e);
        }
        return rows;
    }

    public List<Map<String, Object>> getMedicalServices(String search, String serviceType, String status) {
        List<Map<String, Object>> rows = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT service_id, service_name, price, service_type, status FROM Medical_Service WHERE 1=1");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND service_name LIKE ?");
            params.add("%" + search.trim() + "%");
        }

        if (serviceType != null && !serviceType.trim().isEmpty()) {
            sql.append(" AND LOWER(service_type) = LOWER(?)");
            params.add(serviceType.trim());
        }

        if (status != null && !status.trim().isEmpty()) {
            sql.append(" AND LOWER(status) = LOWER(?)");
            params.add(status.trim());
        }

        sql.append(" ORDER BY service_type, service_name");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("serviceId", rs.getInt("service_id"));
                    row.put("serviceName", rs.getString("service_name"));
                    row.put("price", rs.getBigDecimal("price"));
                    row.put("serviceType", rs.getString("service_type"));
                    row.put("status", rs.getString("status"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to query medical services", e);
        }

        return rows;
    }

    public boolean createMedicalService(String serviceName, BigDecimal price, String serviceType, String status) {
        if (!isAllowedServiceType(serviceType) || !isAllowedServiceStatus(status)) {
            return false;
        }

        String sql = "INSERT INTO Medical_Service (service_name, price, service_type, status) VALUES (?, ?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, serviceName);
            statement.setBigDecimal(2, price);
            statement.setString(3, normalizeServiceType(serviceType));
            statement.setString(4, normalizeServiceStatus(status));
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create medical service", e);
            return false;
        }
    }

    public boolean updateMedicalService(int serviceId, String serviceName, BigDecimal price, String serviceType, String status) {
        if (!isAllowedServiceType(serviceType) || !isAllowedServiceStatus(status)) {
            return false;
        }

        String sql = "UPDATE Medical_Service SET service_name = ?, price = ?, service_type = ?, status = ? WHERE service_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, serviceName);
            statement.setBigDecimal(2, price);
            statement.setString(3, normalizeServiceType(serviceType));
            statement.setString(4, normalizeServiceStatus(status));
            statement.setInt(5, serviceId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update medical service", e);
            return false;
        }
    }

    public boolean deleteMedicalService(int serviceId) {
        String sql = "DELETE FROM Medical_Service WHERE service_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, serviceId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to delete medical service", e);
            return false;
        }
    }

    public boolean updateMedicalServiceStatus(int serviceId, String status) {
        if (!isAllowedServiceStatus(status)) {
            return false;
        }
        String sql = "UPDATE Medical_Service SET status = ? WHERE service_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, normalizeServiceStatus(status));
            statement.setInt(2, serviceId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update service status", e);
            return false;
        }
    }

    public List<Map<String, Object>> getDoctorsForSchedule() {
        List<Map<String, Object>> doctors = new ArrayList<>();
        String sql = "SELECT d.doctor_id, d.full_name, d.department "
                + "FROM Doctor d "
                + "JOIN Account a ON a.account_id = d.account_id "
                + "WHERE LOWER(a.status) = 'active' "
                + "ORDER BY d.full_name";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> doctor = new HashMap<>();
                doctor.put("doctorId", rs.getInt("doctor_id"));
                doctor.put("fullName", rs.getString("full_name"));
                doctor.put("department", rs.getString("department"));
                doctors.add(doctor);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load doctors for schedules", e);
        }

        return doctors;
    }

    public List<String> getScheduleDepartments() {
        List<String> departments = new ArrayList<>();
        String sql = "SELECT DISTINCT d.department "
                + "FROM Doctor d "
                + "WHERE d.department IS NOT NULL AND LTRIM(RTRIM(d.department)) <> '' "
                + "ORDER BY d.department";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                departments.add(rs.getString("department"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load schedule departments", e);
        }
        return departments;
    }

    public List<Map<String, Object>> getDoctorSchedules(String department, String doctorName, Date workDate) {
        List<Map<String, Object>> rows = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT ds.schedule_id, ds.doctor_id, d.full_name AS doctor_name, d.department, "
                + "ds.work_date, ds.time_slot, ds.max_patients, ds.status, "
                + "COALESCE(active_bookings.active_count, 0) AS active_count "
                + "FROM Doctor_Schedule ds "
                + "JOIN Doctor d ON d.doctor_id = ds.doctor_id "
                + "LEFT JOIN ("
                + "   SELECT schedule_id, COUNT(*) AS active_count "
                + "   FROM Appointment "
                + "   WHERE status IN ('Waiting', 'In_Progress') "
                + "   GROUP BY schedule_id"
                + ") active_bookings ON active_bookings.schedule_id = ds.schedule_id "
                + "WHERE 1=1");

        List<Object> params = new ArrayList<>();
        if (department != null && !department.trim().isEmpty()) {
            sql.append(" AND d.department = ?");
            params.add(department.trim());
        }
        if (doctorName != null && !doctorName.trim().isEmpty()) {
            sql.append(" AND d.full_name LIKE ?");
            params.add("%" + doctorName.trim() + "%");
        }
        if (workDate != null) {
            sql.append(" AND ds.work_date = ?");
            params.add(workDate);
        }
        sql.append(" ORDER BY ds.work_date DESC, ds.time_slot ASC");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    int maxPatients = rs.getInt("max_patients");
                    int activeCount = rs.getInt("active_count");
                    row.put("scheduleId", rs.getInt("schedule_id"));
                    row.put("doctorId", rs.getInt("doctor_id"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("department", rs.getString("department"));
                    row.put("workDate", rs.getDate("work_date"));
                    row.put("timeSlot", rs.getString("time_slot"));
                    row.put("maxPatients", maxPatients);
                    row.put("activeCount", activeCount);
                    row.put("status", rs.getString("status"));
                    row.put("isFull", activeCount >= maxPatients);
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to get doctor schedules", e);
        }

        return rows;
    }

    public boolean createDoctorSchedule(int doctorId, Date workDate, String timeSlot, int maxPatients, String status) {
        if (!isAllowedScheduleStatus(status) || maxPatients <= 0) {
            return false;
        }

        String sql = "INSERT INTO Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status) VALUES (?, ?, ?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, doctorId);
            statement.setDate(2, workDate);
            statement.setString(3, timeSlot);
            statement.setInt(4, maxPatients);
            statement.setString(5, normalizeScheduleStatus(status));
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to create doctor schedule", e);
            return false;
        }
    }

    public boolean updateDoctorSchedule(int scheduleId, Date workDate, String timeSlot, int maxPatients, String status) {
        if (!isAllowedScheduleStatus(status) || maxPatients <= 0) {
            return false;
        }

        String sql = "UPDATE Doctor_Schedule SET work_date = ?, time_slot = ?, max_patients = ?, status = ? WHERE schedule_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setDate(1, workDate);
            statement.setString(2, timeSlot);
            statement.setInt(3, maxPatients);
            statement.setString(4, normalizeScheduleStatus(status));
            statement.setInt(5, scheduleId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to update doctor schedule", e);
            return false;
        }
    }

    public boolean deleteDoctorSchedule(int scheduleId) {
        String sql = "DELETE FROM Doctor_Schedule WHERE schedule_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, scheduleId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to delete doctor schedule", e);
            return false;
        }
    }

    public boolean cancelDoctorSchedule(int scheduleId) {
        String sql = "UPDATE Doctor_Schedule SET status = 'Cancelled' WHERE schedule_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, scheduleId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to cancel doctor schedule", e);
            return false;
        }
    }

    public List<Map<String, Object>> getExceptionQueue(Integer doctorId) {
        List<Map<String, Object>> rows = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT a.appointment_id, a.status AS appointment_status, a.appointment_time, "
                        + "a.schedule_id, ds.doctor_id AS current_doctor_id, d.full_name AS current_doctor_name, d.department, "
                        + "p.patient_id, p.full_name AS patient_name "
                        + "FROM Appointment a "
                        + "LEFT JOIN Doctor_Schedule ds ON a.schedule_id = ds.schedule_id "
                        + "LEFT JOIN Doctor d ON ds.doctor_id = d.doctor_id "
                        + "LEFT JOIN Patient p ON a.patient_id = p.patient_id "
                        + "WHERE a.status IN ('Waiting', 'In_Progress')"
        );
        List<Object> params = new ArrayList<>();
        if (doctorId != null) {
            sql.append(" AND ds.doctor_id = ?");
            params.add(doctorId);
        }
        sql.append(" ORDER BY a.appointment_time ASC, a.appointment_id ASC");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("appointmentId", rs.getInt("appointment_id"));
                    row.put("appointmentStatus", rs.getString("appointment_status"));
                    row.put("appointmentTime", rs.getTimestamp("appointment_time"));
                    row.put("scheduleId", rs.getInt("schedule_id"));
                    row.put("currentDoctorId", rs.getInt("current_doctor_id"));
                    row.put("currentDoctorName", rs.getString("current_doctor_name"));
                    row.put("department", rs.getString("department"));
                    row.put("patientId", rs.getInt("patient_id"));
                    row.put("patientName", rs.getString("patient_name"));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load exception queue", e);
        }
        return rows;
    }

    public List<Map<String, Object>> getAvailableDoctorsForEmergency(String department, Integer excludeDoctorId) {
        List<Map<String, Object>> doctors = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT d.doctor_id, d.full_name, d.department "
                        + "FROM Doctor d "
                        + "JOIN Account a ON a.account_id = d.account_id "
                        + "WHERE LOWER(a.status) = 'active'"
        );
        List<Object> params = new ArrayList<>();
        if (department != null && !department.trim().isEmpty()) {
            sql.append(" AND d.department = ?");
            params.add(department.trim());
        }
        if (excludeDoctorId != null) {
            sql.append(" AND d.doctor_id <> ?");
            params.add(excludeDoctorId);
        }
        sql.append(" ORDER BY d.full_name ASC");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("doctorId", rs.getInt("doctor_id"));
                    row.put("fullName", rs.getString("full_name"));
                    row.put("department", rs.getString("department"));
                    doctors.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load available doctors for emergency", e);
        }
        return doctors;
    }

    public boolean reassignAppointmentToDoctor(int appointmentId, int targetDoctorId) {
        String pickScheduleSql = "SELECT TOP 1 ds.schedule_id "
                + "FROM Doctor_Schedule ds "
                + "WHERE ds.doctor_id = ? AND ds.status = 'Available' AND ds.work_date >= CAST(GETDATE() AS DATE) "
                + "ORDER BY ds.work_date ASC, ds.time_slot ASC";
        String updateAppointmentSql = "UPDATE Appointment SET schedule_id = ? WHERE appointment_id = ?";

        try (Connection connection = DatabaseConnection.getConnection()) {
            Integer targetScheduleId = null;
            try (PreparedStatement pick = connection.prepareStatement(pickScheduleSql)) {
                pick.setInt(1, targetDoctorId);
                try (ResultSet rs = pick.executeQuery()) {
                    if (rs.next()) {
                        targetScheduleId = rs.getInt("schedule_id");
                    }
                }
            }

            if (targetScheduleId == null) {
                return false;
            }

            try (PreparedStatement update = connection.prepareStatement(updateAppointmentSql)) {
                update.setInt(1, targetScheduleId);
                update.setInt(2, appointmentId);
                return update.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to reassign appointment in emergency routing", e);
            return false;
        }
    }

    public int refreshDoctorScheduleStatusFromAppointments() {
        String sql = "UPDATE ds SET ds.status = CASE "
                + "WHEN active_count.active_appointments >= ds.max_patients THEN 'Full' "
                + "ELSE 'Available' END "
                + "FROM Doctor_Schedule ds "
                + "OUTER APPLY ("
                + "   SELECT COUNT(*) AS active_appointments "
                + "   FROM Appointment ap "
                + "   WHERE ap.schedule_id = ds.schedule_id AND ap.status IN ('Waiting', 'In_Progress')"
                + ") active_count "
                + "WHERE ds.status <> 'Cancelled'";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            return statement.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to refresh schedule status", e);
            return 0;
        }
    }

    public List<Map<String, Object>> getRevenueReport(String granularity, Integer year, Integer month, Integer day) {
        return getTimeSeriesReport("Invoice", "created_at", "final_amount", "status", "Paid", "SUM", "revenue_value",
                granularity, year, month, day);
    }

    public List<Map<String, Object>> getVisitReport(String granularity, Integer year, Integer month, Integer day) {
        return getTimeSeriesReport("Appointment", "appointment_time", "appointment_id", "status", "Completed", "COUNT", "visit_value",
                granularity, year, month, day);
    }

    public Map<String, Object> getReportDetailByPeriod(String period) {
        Map<String, Object> result = new HashMap<>();
        List<Map<String, Object>> invoices = new ArrayList<>();
        List<Map<String, Object>> appointments = new ArrayList<>();

        if (period == null || period.isBlank()) {
            result.put("invoices", invoices);
            result.put("appointments", appointments);
            return result;
        }

        // Sanitize period input
        period = period.trim();
        LOGGER.log(Level.INFO, "getReportDetailByPeriod called with period: [" + period + "]");

        // Parse period to build SQL filter
        // period format: "2026-06" (month) or "2026-06-19" (day)
        boolean isDay = period.matches("\\d{4}-\\d{2}-\\d{2}");
        String periodFilter = isDay
                ? "FORMAT(i.created_at, 'yyyy-MM-dd') = ?"
                : "FORMAT(i.created_at, 'yyyy-MM') = ?";

        // SWP.sql uses insurance_deduction. Keep bhytDeduction as the JSP response key.
        boolean hasInsuranceDeduction = hasColumn("Invoice", "insurance_deduction");
        String bhytCol = hasInsuranceDeduction ? "i.insurance_deduction" : "CAST(0 AS DECIMAL(18,2))";
        String invoiceSql = "SELECT i.invoice_id, p.full_name AS patient_name, "
                + "i.total_amount, " + bhytCol + " AS bhyt_deduction, i.final_amount, "
                + "FORMAT(i.created_at, 'yyyy-MM-dd') AS payment_date "
                + "FROM Invoice i "
                + "JOIN Patient p ON p.patient_id = i.patient_id "
                + "WHERE LOWER(i.status) = 'paid' AND " + periodFilter + " "
                + "ORDER BY i.created_at DESC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(invoiceSql)) {
            statement.setString(1, period);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("invoiceId", rs.getString("invoice_id"));
                    row.put("patientName", rs.getString("patient_name"));
                    row.put("totalAmount", rs.getBigDecimal("total_amount"));
                    row.put("bhytDeduction", rs.getBigDecimal("bhyt_deduction"));
                    row.put("finalAmount", rs.getBigDecimal("final_amount"));
                    row.put("paymentDate", rs.getString("payment_date"));
                    invoices.add(row);
                }
            }
            LOGGER.log(Level.INFO, "Loaded " + invoices.size() + " invoices for period [" + period + "]");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load invoice details by period [" + period + "]: " + e.getMessage());
        }

        // Query appointments (completed)
        periodFilter = isDay
                ? "FORMAT(ap.appointment_time, 'yyyy-MM-dd') = ?"
                : "FORMAT(ap.appointment_time, 'yyyy-MM') = ?";

        String appointmentSql = "SELECT ap.appointment_id, a.full_name AS patient_name, "
                + "d.full_name AS doctor_name, ds.time_slot, "
            + "ap.status AS appointment_status, "
                + "FORMAT(ds.work_date, 'yyyy-MM-dd') AS appointment_date "
                + "FROM Appointment ap "
                + "JOIN Account a ON a.account_id = ap.patient_id "
                + "JOIN Doctor_Schedule ds ON ds.schedule_id = ap.schedule_id "
                + "JOIN Doctor d ON d.doctor_id = ds.doctor_id "
                + "WHERE ap.status = 'Completed' AND " + periodFilter + " "
                + "ORDER BY ap.appointment_time DESC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(appointmentSql)) {
            statement.setString(1, period);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("appointmentId", rs.getString("appointment_id"));
                    row.put("patientName", rs.getString("patient_name"));
                    row.put("doctorName", rs.getString("doctor_name"));
                    row.put("timeSlot", rs.getString("time_slot"));
                    row.put("status", rs.getString("appointment_status"));
                    row.put("appointmentDate", rs.getString("appointment_date"));
                    appointments.add(row);
                }
            }
            LOGGER.log(Level.INFO, "Loaded " + appointments.size() + " appointments for period [" + period + "]");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load appointment details by period [" + period + "]: " + e.getMessage());
        }

        result.put("invoices", invoices);
        result.put("appointments", appointments);
        return result;
    }

    public List<Map<String, Object>> getInvoiceItemsByInvoiceId(String invoiceId) {
        List<Map<String, Object>> items = new ArrayList<>();
        if (invoiceId == null || invoiceId.trim().isEmpty()) {
            return items;
        }

        String sql = "SELECT id.invoice_detail_id, id.invoice_id, id.service_id, "
                + "ms.service_name, id.quantity, id.price AS unit_price, "
                + "CAST(id.quantity * id.price AS DECIMAL(18,2)) AS line_total "
                + "FROM Invoice_Detail id "
                + "LEFT JOIN Medical_Service ms ON ms.service_id = id.service_id "
                + "WHERE id.invoice_id = ? "
                + "ORDER BY id.invoice_detail_id ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, invoiceId.trim());
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> item = new HashMap<>();
                    item.put("invoiceDetailId", rs.getInt("invoice_detail_id"));
                    item.put("invoiceId", rs.getString("invoice_id"));
                    item.put("serviceId", rs.getInt("service_id"));
                    item.put("serviceName", rs.getString("service_name"));
                    item.put("quantity", rs.getInt("quantity"));
                    item.put("unitPrice", rs.getBigDecimal("unit_price"));
                    item.put("lineTotal", rs.getBigDecimal("line_total"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load invoice items for invoiceId=" + invoiceId, e);
        }

        return items;
    }

    private List<Map<String, Object>> getTimeSeriesReport(String table,
                                                           String timeColumn,
                                                           String metricColumn,
                                                           String statusColumn,
                                                           String statusValue,
                                                           String aggregateType,
                                                           String metricAlias,
                                                           String granularity,
                                                           Integer year,
                                                           Integer month,
                                                           Integer day) {
        List<Map<String, Object>> rows = new ArrayList<>();
        String normalizedGranularity = normalizeGranularity(granularity);

        String periodExpr;
        if ("DAY".equals(normalizedGranularity)) {
            periodExpr = "FORMAT(" + timeColumn + ", 'yyyy-MM-dd')";
        } else if ("MONTH".equals(normalizedGranularity)) {
            periodExpr = "FORMAT(" + timeColumn + ", 'yyyy-MM')";
        } else {
            periodExpr = "FORMAT(" + timeColumn + ", 'yyyy')";
        }

        String metricExpr = "SUM".equals(aggregateType)
                ? "COALESCE(SUM(" + metricColumn + "), 0)"
                : "COUNT(" + metricColumn + ")";

        StringBuilder sql = new StringBuilder("SELECT " + periodExpr + " AS period_label, "
                + metricExpr + " AS " + metricAlias + " "
                + "FROM " + table + " "
                + "WHERE LOWER(" + statusColumn + ") = LOWER(?)");

        List<Object> params = new ArrayList<>();
        params.add(statusValue);

        if (year != null) {
            sql.append(" AND DATEPART(YEAR, ").append(timeColumn).append(") = ?");
            params.add(year);
        }
        if (month != null) {
            sql.append(" AND DATEPART(MONTH, ").append(timeColumn).append(") = ?");
            params.add(month);
        }
        if (day != null) {
            sql.append(" AND DATEPART(DAY, ").append(timeColumn).append(") = ?");
            params.add(day);
        }

        sql.append(" GROUP BY ").append(periodExpr).append(" ORDER BY period_label ASC");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("periodLabel", rs.getString("period_label"));
                    row.put("metricValue", rs.getBigDecimal(metricAlias));
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to execute report query", e);
        }

        return rows;
    }

    private String normalizeGranularity(String granularity) {
        String value = granularity == null ? "MONTH" : granularity.trim().toUpperCase(Locale.ROOT);
        if (!"DAY".equals(value) && !"MONTH".equals(value) && !"YEAR".equals(value)) {
            return "MONTH";
        }
        return value;
    }

    private int executeCount(String sql) {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to execute count query", e);
        }
        return 0;
    }

    private BigDecimal executeBigDecimal(String sql) {
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                BigDecimal value = rs.getBigDecimal(1);
                return value == null ? BigDecimal.ZERO : value;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to execute decimal query", e);
        }
        return BigDecimal.ZERO;
    }

    private boolean hasColumn(String tableName, String columnName) {
        String sql = "SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ? AND COLUMN_NAME = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, tableName);
            statement.setString(2, columnName);
            try (ResultSet rs = statement.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Failed to check column existence", e);
            return false;
        }
    }

    private List<Map<String, Object>> getDashboardSeries(String table,
                                                          String timeColumn,
                                                          String metricColumn,
                                                          String statusColumn,
                                                          String statusValue,
                                                          boolean isSum,
                                                          String granularity) {
        List<Map<String, Object>> rows = new ArrayList<>();
        String normalizedGranularity = normalizeGranularity(granularity);

        String periodExpr;
        String groupByExpr;
        String orderByExpr;

        if ("DAY".equals(normalizedGranularity)) {
            periodExpr = "CONVERT(varchar(10), CAST(" + timeColumn + " AS DATE), 23)";
            groupByExpr = "CAST(" + timeColumn + " AS DATE)";
            orderByExpr = "CAST(" + timeColumn + " AS DATE)";
        } else if ("MONTH".equals(normalizedGranularity)) {
            periodExpr = "CONCAT(YEAR(" + timeColumn + "), '-', RIGHT('0' + CAST(MONTH(" + timeColumn + ") AS varchar(2)), 2))";
            groupByExpr = "YEAR(" + timeColumn + "), MONTH(" + timeColumn + ")";
            orderByExpr = "YEAR(" + timeColumn + "), MONTH(" + timeColumn + ")";
        } else {
            periodExpr = "CAST(YEAR(" + timeColumn + ") AS varchar(4))";
            groupByExpr = "YEAR(" + timeColumn + ")";
            orderByExpr = "YEAR(" + timeColumn + ")";
        }

        String metricExpr = isSum
                ? "ISNULL(SUM(" + metricColumn + "), 0)"
                : "COUNT(" + metricColumn + ")";

        String sql = "SELECT " + periodExpr + " AS period, "
                + metricExpr + " AS metric_value "
                + "FROM " + table + " "
                + "WHERE " + statusColumn + " = ? "
                + "GROUP BY " + groupByExpr + " "
                + "ORDER BY " + orderByExpr;

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, statusValue);
            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new HashMap<>();
                    row.put("period", rs.getString("period"));
                    BigDecimal metric = rs.getBigDecimal("metric_value");
                    row.put("value", metric == null ? BigDecimal.ZERO : metric);
                    rows.add(row);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load dashboard series", e);
        }

        return rows;
    }

    private String normalizeRole(String role) {
        if (role == null) {
            return null;
        }
        String value = role.trim().toLowerCase(Locale.ROOT);
        return value.isEmpty() || !ALLOWED_ROLES.contains(value) ? null : value;
    }

    private String normalizeAccountStatus(String status) {
        if (status == null) {
            return null;
        }
        String value = status.trim().toLowerCase(Locale.ROOT);
        return value.isEmpty() || !ALLOWED_ACCOUNT_STATUS.contains(value) ? null : value;
    }

    private String normalizeServiceType(String serviceType) {
        if (serviceType == null) {
            return null;
        }
        String value = serviceType.trim();
        return ALLOWED_SERVICE_TYPES.contains(value) ? value : null;
    }

    private String normalizeServiceStatus(String status) {
        if (status == null) {
            return null;
        }
        String value = status.trim();
        return ALLOWED_SERVICE_STATUS.contains(value) ? value : null;
    }

    private String normalizeScheduleStatus(String status) {
        if (status == null) {
            return null;
        }
        String value = status.trim();
        return ALLOWED_SCHEDULE_STATUS.contains(value) ? value : null;
    }

    private boolean isAllowedServiceType(String serviceType) {
        return normalizeServiceType(serviceType) != null;
    }

    private boolean isAllowedServiceStatus(String status) {
        return normalizeServiceStatus(status) != null;
    }

    private boolean isAllowedScheduleStatus(String status) {
        return normalizeScheduleStatus(status) != null;
    }

    private String toTitleCase(String value) {
        if (value == null || value.isBlank()) {
            return "";
        }
        String lower = value.toLowerCase(Locale.ROOT);
        return Character.toUpperCase(lower.charAt(0)) + lower.substring(1);
    }

    private void bindParams(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            Object param = params.get(i);
            int idx = i + 1;
            if (param instanceof Integer) {
                statement.setInt(idx, (Integer) param);
            } else if (param instanceof BigDecimal) {
                statement.setBigDecimal(idx, (BigDecimal) param);
            } else if (param instanceof Date) {
                statement.setDate(idx, (Date) param);
            } else if (param instanceof Timestamp) {
                statement.setTimestamp(idx, (Timestamp) param);
            } else {
                statement.setString(idx, String.valueOf(param));
            }
        }
    }
}



