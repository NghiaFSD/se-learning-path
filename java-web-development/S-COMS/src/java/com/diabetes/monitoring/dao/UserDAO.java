package com.diabetes.monitoring.dao;

import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.DatabaseConnection;
import com.diabetes.monitoring.util.PasswordUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {
    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public enum AssignmentResult {
        SUCCESS,
        REQUIRES_CONFIRMATION,
        RECORD_COMPLETED,
        DOCTOR_UNAVAILABLE,
        RECORD_NOT_FOUND,
        FAILED
    }

    // #region ======= AUTHENTICATION & USER PROFILE =======

    /**
     * Register new patient: create Account + Patient record
     * Returns error message or null if success
     */
    public String registerUser(User user) {
        String sqlAccount = "INSERT INTO Account (full_name, password_hash, email, role, status) VALUES (?, ?, ?, 'patient', 'active')";
        String sqlPatient = "INSERT INTO Patient (full_name, date_of_birth, gender, phone, email, address, account_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        Connection connection = null;
        try {
            connection = DatabaseConnection.getConnection();
            connection.setAutoCommit(false);

            // 1. Insert into Account table and get generated account_id
            int accountId;
            try (PreparedStatement stmtAccount = connection.prepareStatement(sqlAccount, Statement.RETURN_GENERATED_KEYS)) {
                stmtAccount.setString(1, user.getFullName());
                stmtAccount.setString(2, user.getPassword()); // already hashed
                stmtAccount.setString(3, user.getEmail());
                stmtAccount.executeUpdate();
                
                try (ResultSet rs = stmtAccount.getGeneratedKeys()) {
                    if (rs.next()) {
                        accountId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to get generated account_id");
                    }
                }
            }

            // 2. Insert into Patient table with account_id
            try (PreparedStatement stmtPatient = connection.prepareStatement(sqlPatient)) {
                stmtPatient.setString(1, user.getFullName());
                stmtPatient.setString(2, user.getDob());
                stmtPatient.setString(3, user.getGender());
                stmtPatient.setString(4, user.getPhone());
                stmtPatient.setString(5, user.getEmail());
                stmtPatient.setString(6, user.getAddress());
                stmtPatient.setInt(7, accountId);
                stmtPatient.executeUpdate();
            }

            connection.commit();
            return null;
        } catch (SQLException e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback or cleanup failed", ex);
                }
            }
            LOGGER.log(Level.SEVERE, "Operation failed", e);
            return "SQL Error: " + e.getMessage();
        } finally {
            if (connection != null) {
                try {
                    connection.setAutoCommit(true);
                    connection.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Operation failed", e);
                }
            }
        }
    }

    /**
     * Get user by account_id
     */
    public User getUserById(int accountId) {
        String sql = "SELECT account_id, full_name, email, role, status FROM Account WHERE account_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, accountId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    User user = new User();
                    user.setId(resultSet.getInt("account_id"));
                    user.setFullName(resultSet.getString("full_name"));
                    user.setEmail(resultSet.getString("email"));
                    user.setRole(resultSet.getString("role"));
                    user.setStatus(resultSet.getString("status"));
                    return user;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return null;
    }

    /**
     * Validate login using Account table
     * For patients: also fetch patient_id and additional info from Patient table
     */
    public User validateLogin(String email, String password, String role) {
        // Step 1: Check Account table
        String sqlAccount = "SELECT account_id, full_name, email, role, password_hash, status FROM Account WHERE email = ? AND LOWER(role) = LOWER(?)";
        
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sqlAccount)) {
            statement.setString(1, email);
            statement.setString(2, role);
            
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");
                    String status = rs.getString("status");
                    
                    // Check if account is active (allow NULL as active for existing accounts)
                    if (PasswordUtil.matches(password, storedHash)) {
                        int accountId = rs.getInt("account_id");
                        String fullName = rs.getString("full_name");
                        String userRole = rs.getString("role");
                        
                        User user = new User();
                        user.setId(accountId);
                        user.setFullName(fullName);
                        user.setEmail(email);
                        user.setRole(userRole);
                        user.setStatus(status);
                        
                        // For patients, fetch additional info from Patient table
                        if ("patient".equals(role)) {
                            loadPatientDetails(connection, user, accountId);
                        }
                        // For doctors, fetch additional info from Doctor table
                        else if ("doctor".equals(role)) {
                            loadDoctorDetails(connection, user, accountId);
                        }
                        
                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return null;
    }
    
    /**
     * Validate login by email only, ignoring selected role.
     */
    public User validateLogin(String email, String password) {
        String sqlAccount = "SELECT account_id, full_name, email, role, password_hash, status FROM Account WHERE email = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sqlAccount)) {
            statement.setString(1, email);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    String storedHash = rs.getString("password_hash");
                    String status = rs.getString("status");

                    if (PasswordUtil.matches(password, storedHash)) {
                        int accountId = rs.getInt("account_id");
                        String fullName = rs.getString("full_name");
                        String userRole = rs.getString("role");

                        User user = new User();
                        user.setId(accountId);
                        user.setFullName(fullName);
                        user.setEmail(email);
                        user.setRole(userRole);
                        user.setStatus(status);

                        if ("patient".equals(userRole)) {
                            loadPatientDetails(connection, user, accountId);
                        } else if ("doctor".equals(userRole)) {
                            loadDoctorDetails(connection, user, accountId);
                        }

                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return null;
    }
    
    private void loadPatientDetails(Connection connection, User user, int accountId) throws SQLException {
        String sql = "SELECT patient_id, phone, address, date_of_birth, gender FROM Patient WHERE account_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    // Store patient_id in a way that can be used later
                    // For now, using emergencyContact field to store patient_id temporarily
                    // or we could extend User model
                    user.setPhone(rs.getString("phone"));
                    user.setAddress(rs.getString("address"));
                    user.setDob(rs.getString("date_of_birth"));
                    user.setGender(rs.getString("gender"));
                }
            }
        }
    }
    
    private void loadDoctorDetails(Connection connection, User user, int accountId) throws SQLException {
        String sql = "SELECT doctor_id, phone, department FROM Doctor WHERE account_id = ?";
        try (PreparedStatement stmt = connection.prepareStatement(sql)) {
            stmt.setInt(1, accountId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    user.setPhone(rs.getString("phone"));
                    // Store department info if needed
                }
            }
        }
    }
    
    /**
     * Check if email already exists in Account table
     * Returns true if email exists, false otherwise
     */
    public boolean isEmailExists(String email) {
        String sql = "SELECT COUNT(*) FROM Account WHERE LOWER(email) = LOWER(?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return false;
    }
    // #endregion

    // #region ======= ADMIN MODULE FUNCTIONALITIES =======

    /**
     * Get total user count
     */
    public int getTotalUserCount() {
        String sql = "SELECT COUNT(*) FROM Account";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get count by role
     */
    public int getCountByRole(String role) {
        String sql = "SELECT COUNT(*) FROM Account WHERE role = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, role);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get count by status
     */
    public int getCountByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Account WHERE status = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    public int getLockedAccountCount() {
        String sql = "SELECT COUNT(*) FROM Account WHERE status = 'locked'";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get health record counts grouped by status for admin dashboard charts.
     */
    public java.util.Map<String, Integer> getHealthRecordStatusCounts() {
        String sql = "SELECT status, COUNT(*) AS count FROM Healthy_Record GROUP BY status";
        java.util.Map<String, Integer> counts = new java.util.HashMap<>();
        counts.put("pending", 0);
        counts.put("processing", 0);
        counts.put("completed", 0);

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("status");
                if (status != null) {
                    counts.put(status.toLowerCase(), rs.getInt("count"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to count health records by status", e);
        }
        return counts;
    }

    /**
     * Get recent users with limit
     */
    public java.util.List<User> getRecentUsers(int limit) {
        java.util.List<User> users = new java.util.ArrayList<>();
        String sql = "SELECT account_id, full_name, email, role, status, created_at FROM Account " +
                     "WHERE created_at IS NOT NULL " +
                     "ORDER BY created_at DESC OFFSET 0 ROWS FETCH NEXT ? ROWS ONLY";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, limit);
try (ResultSet rs = statement.executeQuery()) {
                int count = 0;
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("account_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    users.add(user);
                    count++;
}
}
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
}
        return users;
    }

    /**
     * Get users with filters and pagination
     */
    public java.util.List<User> getUsersWithFilters(String search, String role, String status, 
                                                     int page, int pageSize) {
        java.util.List<User> users = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT account_id, full_name, email, role, status, created_at FROM Account WHERE 1=1"
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        if (role != null && !role.isEmpty()) {
            sql.append(" AND role = ?");
            params.add(role);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }
        sql.append(" ORDER BY created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            statement.setInt(idx++, (page - 1) * pageSize);
            statement.setInt(idx, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    User user = new User();
                    user.setId(rs.getInt("account_id"));
                    user.setFullName(rs.getString("full_name"));
                    user.setEmail(rs.getString("email"));
                    user.setRole(rs.getString("role"));
                    user.setStatus(rs.getString("status"));
                    user.setCreatedAt(rs.getTimestamp("created_at"));
                    users.add(user);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return users;
    }

    /**
     * Get total count with filters
     */
    public int getTotalCountWithFilters(String search, String role, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM Account WHERE 1=1");
        java.util.List<Object> params = new java.util.ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (full_name LIKE ? OR email LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        if (role != null && !role.isEmpty()) {
            sql.append(" AND role = ?");
            params.add(role);
        }
        if (status != null && !status.isEmpty()) {
            sql.append(" AND status = ?");
            params.add(status);
        }

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Create doctor account
     * Returns error message or null if success
     */
    public String createDoctorAccount(String fullName, String email, String phone, 
                                       String department, String passwordHash) {
        String sqlAccount = "INSERT INTO Account (full_name, password_hash, email, role, status) VALUES (?, ?, ?, 'doctor', 'active')";
        String sqlDoctor = "INSERT INTO Doctor (full_name, phone, email, department, account_id) VALUES (?, ?, ?, ?, ?)";

        Connection connection = null;
        try {
            connection = DatabaseConnection.getConnection();
            connection.setAutoCommit(false);

            // Insert Account
            int accountId;
            try (PreparedStatement stmtAccount = connection.prepareStatement(sqlAccount, 
                    java.sql.Statement.RETURN_GENERATED_KEYS)) {
                stmtAccount.setString(1, fullName);
                stmtAccount.setString(2, passwordHash);
                stmtAccount.setString(3, email);
                stmtAccount.executeUpdate();

                try (ResultSet rs = stmtAccount.getGeneratedKeys()) {
                    if (rs.next()) {
                        accountId = rs.getInt(1);
                    } else {
                        throw new SQLException("Failed to get generated account_id");
                    }
                }
            }

            // Insert Doctor
            try (PreparedStatement stmtDoctor = connection.prepareStatement(sqlDoctor)) {
                stmtDoctor.setString(1, fullName);
                stmtDoctor.setString(2, phone);
                stmtDoctor.setString(3, email);
                stmtDoctor.setString(4, department);
                stmtDoctor.setInt(5, accountId);
                stmtDoctor.executeUpdate();
            }

            connection.commit();
            return null;
        } catch (SQLException e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback or cleanup failed", ex);
                }
            }
            LOGGER.log(Level.SEVERE, "Operation failed", e);
            return "SQL Error: " + e.getMessage();
        } finally {
            if (connection != null) {
                try {
                    connection.setAutoCommit(true);
                    connection.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Operation failed", e);
                }
            }
        }
    }

    /**
     * Update user password
     */
    public boolean updatePassword(int userId, String passwordHash) {
        String sql = "UPDATE Account SET password_hash = ? WHERE account_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            if (connection == null) {
return false;
            }
            statement.setString(1, passwordHash);
            statement.setInt(2, userId);
            int rowsAffected = statement.executeUpdate();
return rowsAffected > 0;
        } catch (SQLException e) {
LOGGER.log(Level.SEVERE, "Operation failed", e);
        } catch (Exception e) {
LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return false;
    }

    /**
     * Update account status (active, locked, banned)
     */
    public boolean updateAccountStatus(int userId, String status) {
        String sql = "UPDATE Account SET status = ? WHERE account_id = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, userId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return false;
    }

    /**
     * Ban account safely. If the account belongs to a doctor, release all
     * in-progress health records back to the pending queue in the same
     * transaction so patients are not stuck with an unavailable doctor.
     */
    public boolean banAccount(int accountId) {
        String findDoctorSql = "SELECT doctor_id FROM Doctor WHERE account_id = ?";
        String banAccountSql = "UPDATE Account SET status = 'banned' WHERE account_id = ?";
        String releaseRecordsSql = "UPDATE Healthy_Record SET status = 'pending', doctor_id = NULL "
                + "WHERE doctor_id = ? AND status = 'processing'";

        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                Integer doctorId = null;
                try (PreparedStatement statement = connection.prepareStatement(findDoctorSql)) {
                    statement.setInt(1, accountId);
                    try (ResultSet rs = statement.executeQuery()) {
                        if (rs.next()) {
                            doctorId = rs.getInt("doctor_id");
                        }
                    }
                }

                int updatedRows;
                try (PreparedStatement statement = connection.prepareStatement(banAccountSql)) {
                    statement.setInt(1, accountId);
                    updatedRows = statement.executeUpdate();
                }

                if (updatedRows <= 0) {
                    connection.rollback();
                    return false;
                }

                if (doctorId != null) {
                    try (PreparedStatement statement = connection.prepareStatement(releaseRecordsSql)) {
                        statement.setInt(1, doctorId);
                        statement.executeUpdate();
                    }
                }

                connection.commit();
                return true;
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to ban account and release assigned records", e);
        }
        return false;
    }

    public int getDoctorProcessingWorkload(int doctorId) {
        String sql = "SELECT COUNT(*) FROM Healthy_Record WHERE doctor_id = ? AND status = 'processing'";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, doctorId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to count doctor processing workload", e);
        }
        return Integer.MAX_VALUE;
    }

    public Integer findAvailableDoctorInDepartment(String department, int excludedDoctorId, int maxProcessingRecords) {
        if (department == null || department.trim().isEmpty()) {
            return null;
        }

        String sql =
            "SELECT TOP 1 d.doctor_id, COUNT(hr.health_record_id) AS processing_count " +
            "FROM Doctor d " +
            "JOIN Account a ON d.account_id = a.account_id " +
            "LEFT JOIN Healthy_Record hr ON d.doctor_id = hr.doctor_id AND hr.status = 'processing' " +
            "WHERE a.status = 'active' AND d.department = ? AND d.doctor_id <> ? " +
            "GROUP BY d.doctor_id " +
            "HAVING COUNT(hr.health_record_id) < ? " +
            "ORDER BY processing_count ASC, d.doctor_id ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, department);
            statement.setInt(2, excludedDoctorId);
            statement.setInt(3, maxProcessingRecords);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("doctor_id");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to find available doctor in same department", e);
        }
        return null;
    }

    // #region ======= ADMIN HEALTH RECORD ASSIGNMENT =======

    /**
     * Get pending health records with patient info
     */
    public java.util.List<com.diabetes.monitoring.model.HealthRecord> getPendingHealthRecords(
            String search, int page, int pageSize) {
        java.util.List<com.diabetes.monitoring.model.HealthRecord> records = new java.util.ArrayList<>();
        // Sửa query để lấy cả status NULL và 'pending'
        StringBuilder sql = new StringBuilder(
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.weight, hr.height, " +
            "hr.other_information, hr.status, hr.doctor_id, hr.created_at, " +
            "p.full_name as patient_name, d.full_name as doctor_name " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE (hr.status = 'pending' OR hr.status IS NULL)"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        
        sql.append(" ORDER BY hr.created_at ASC, hr.health_record_id ASC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            statement.setInt(idx++, (page - 1) * pageSize);
            statement.setInt(idx, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    com.diabetes.monitoring.model.HealthRecord record = new com.diabetes.monitoring.model.HealthRecord();
                    record.setHealthRecordId(rs.getInt("health_record_id"));
                    record.setUrea(rs.getDouble("urea"));
                    record.setCr(rs.getDouble("cr"));
                    record.setHba1c(rs.getDouble("hba1c"));
                    record.setChol(rs.getDouble("chol"));
                    record.setTg(rs.getDouble("tg"));
                    record.setHdl(rs.getDouble("hdl"));
                    record.setLdl(rs.getDouble("ldl"));
                    record.setVldl(rs.getDouble("vldl"));
                    record.setBmi(rs.getDouble("bmi"));
                    record.setPatientId(rs.getInt("patient_id"));
                    record.setPatientName(rs.getString("patient_name"));
                    record.setWeight(rs.getDouble("weight"));
                    record.setHeight(rs.getDouble("height"));
                    record.setOtherInformation(rs.getString("other_information"));
                    record.setStatus(rs.getString("status"));
                    record.setDoctorId(rs.getObject("doctor_id") != null ? rs.getInt("doctor_id") : null);
                    record.setDoctorName(rs.getString("doctor_name"));
                    record.setCreatedAt(rs.getTimestamp("created_at"));
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Get processing health records (already assigned to doctors)
     */
    public java.util.List<com.diabetes.monitoring.model.HealthRecord> getProcessingHealthRecords(
            String search, int page, int pageSize) {
        java.util.List<com.diabetes.monitoring.model.HealthRecord> records = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.weight, hr.height, " +
            "hr.other_information, hr.status, hr.doctor_id, hr.created_at, " +
            "p.full_name as patient_name, d.full_name as doctor_name " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.status = 'processing'"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR d.full_name LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        
        sql.append(" ORDER BY hr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            statement.setInt(idx++, (page - 1) * pageSize);
            statement.setInt(idx, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    com.diabetes.monitoring.model.HealthRecord record = new com.diabetes.monitoring.model.HealthRecord();
                    record.setHealthRecordId(rs.getInt("health_record_id"));
                    record.setUrea(rs.getDouble("urea"));
                    record.setCr(rs.getDouble("cr"));
                    record.setHba1c(rs.getDouble("hba1c"));
                    record.setChol(rs.getDouble("chol"));
                    record.setTg(rs.getDouble("tg"));
                    record.setHdl(rs.getDouble("hdl"));
                    record.setLdl(rs.getDouble("ldl"));
                    record.setVldl(rs.getDouble("vldl"));
                    record.setBmi(rs.getDouble("bmi"));
                    record.setPatientId(rs.getInt("patient_id"));
                    record.setPatientName(rs.getString("patient_name"));
                    record.setWeight(rs.getDouble("weight"));
                    record.setHeight(rs.getDouble("height"));
                    record.setOtherInformation(rs.getString("other_information"));
                    record.setStatus(rs.getString("status"));
                    record.setDoctorId(rs.getObject("doctor_id") != null ? rs.getInt("doctor_id") : null);
                    record.setDoctorName(rs.getString("doctor_name"));
                    record.setCreatedAt(rs.getTimestamp("created_at"));
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    private String getHealthRecordSpamFilterClause() {
        return " AND (hr.other_information IS NULL OR NOT (" +
               "LOWER(hr.other_information) LIKE ? OR " +
               "LOWER(hr.other_information) LIKE ? OR " +
               "LOWER(hr.other_information) LIKE ? OR " +
               "LOWER(hr.other_information) LIKE ? OR " +
               "LOWER(hr.other_information) LIKE ?))";
    }

    private void addHealthRecordSpamFilterParams(java.util.List<Object> params) {
        params.add("%spam%");
        params.add("%hack%");
        params.add("%malicious%");
        params.add("%bot%");
        params.add("%asdasd%");
    }

    /**
     * Get count of processing health records
     */
    public int getProcessingHealthRecordCount(String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.status = 'processing'"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR d.full_name LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get completed health records
     */
    public java.util.List<com.diabetes.monitoring.model.HealthRecord> getCompletedHealthRecords(
            String search, int page, int pageSize) {
        java.util.List<com.diabetes.monitoring.model.HealthRecord> records = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.weight, hr.height, " +
            "hr.other_information, hr.status, hr.doctor_id, hr.created_at, " +
            "p.full_name as patient_name, d.full_name as doctor_name " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.status = 'completed'"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR d.full_name LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        
        sql.append(" ORDER BY hr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            statement.setInt(idx++, (page - 1) * pageSize);
            statement.setInt(idx, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    com.diabetes.monitoring.model.HealthRecord record = new com.diabetes.monitoring.model.HealthRecord();
                    record.setHealthRecordId(rs.getInt("health_record_id"));
                    record.setUrea(rs.getDouble("urea"));
                    record.setCr(rs.getDouble("cr"));
                    record.setHba1c(rs.getDouble("hba1c"));
                    record.setChol(rs.getDouble("chol"));
                    record.setTg(rs.getDouble("tg"));
                    record.setHdl(rs.getDouble("hdl"));
                    record.setLdl(rs.getDouble("ldl"));
                    record.setVldl(rs.getDouble("vldl"));
                    record.setBmi(rs.getDouble("bmi"));
                    record.setPatientId(rs.getInt("patient_id"));
                    record.setPatientName(rs.getString("patient_name"));
                    record.setWeight(rs.getDouble("weight"));
                    record.setHeight(rs.getDouble("height"));
                    record.setOtherInformation(rs.getString("other_information"));
                    record.setStatus(rs.getString("status"));
                    record.setDoctorId(rs.getObject("doctor_id") != null ? rs.getInt("doctor_id") : null);
                    record.setDoctorName(rs.getString("doctor_name"));
                    record.setCreatedAt(rs.getTimestamp("created_at"));
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Get count of completed health records
     */
    public int getCompletedHealthRecordCount(String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.status = 'completed'"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR d.full_name LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get all health records (any status)
     */
    public java.util.List<com.diabetes.monitoring.model.HealthRecord> getAllHealthRecords(
            String search, int page, int pageSize) {
        java.util.List<com.diabetes.monitoring.model.HealthRecord> records = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.weight, hr.height, " +
            "hr.other_information, hr.status, hr.doctor_id, hr.created_at, " +
            "p.full_name as patient_name, d.full_name as doctor_name " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE 1=1"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR d.full_name LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        
        sql.append(" ORDER BY hr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            statement.setInt(idx++, (page - 1) * pageSize);
            statement.setInt(idx, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    com.diabetes.monitoring.model.HealthRecord record = new com.diabetes.monitoring.model.HealthRecord();
                    record.setHealthRecordId(rs.getInt("health_record_id"));
                    record.setUrea(rs.getDouble("urea"));
                    record.setCr(rs.getDouble("cr"));
                    record.setHba1c(rs.getDouble("hba1c"));
                    record.setChol(rs.getDouble("chol"));
                    record.setTg(rs.getDouble("tg"));
                    record.setHdl(rs.getDouble("hdl"));
                    record.setLdl(rs.getDouble("ldl"));
                    record.setVldl(rs.getDouble("vldl"));
                    record.setBmi(rs.getDouble("bmi"));
                    record.setPatientId(rs.getInt("patient_id"));
                    record.setPatientName(rs.getString("patient_name"));
                    record.setWeight(rs.getDouble("weight"));
                    record.setHeight(rs.getDouble("height"));
                    record.setOtherInformation(rs.getString("other_information"));
                    record.setStatus(rs.getString("status"));
                    record.setDoctorId(rs.getObject("doctor_id") != null ? rs.getInt("doctor_id") : null);
                    record.setDoctorName(rs.getString("doctor_name"));
                    record.setCreatedAt(rs.getTimestamp("created_at"));
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Get count of all health records
     */
    public int getAllHealthRecordCount(String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE 1=1"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR d.full_name LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get health records by doctor
     */
    public java.util.List<com.diabetes.monitoring.model.HealthRecord> getHealthRecordsByDoctor(
            int doctorId, String search, int page, int pageSize) {
        java.util.List<com.diabetes.monitoring.model.HealthRecord> records = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.weight, hr.height, " +
            "hr.other_information, hr.status, hr.doctor_id, hr.created_at, " +
            "p.full_name as patient_name, d.full_name as doctor_name " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.doctor_id = ?"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(doctorId);
        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        sql.append(" ORDER BY hr.created_at DESC OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            statement.setInt(idx++, (page - 1) * pageSize);
            statement.setInt(idx, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    com.diabetes.monitoring.model.HealthRecord record = new com.diabetes.monitoring.model.HealthRecord();
                    record.setHealthRecordId(rs.getInt("health_record_id"));
                    record.setUrea(rs.getDouble("urea"));
                    record.setCr(rs.getDouble("cr"));
                    record.setHba1c(rs.getDouble("hba1c"));
                    record.setChol(rs.getDouble("chol"));
                    record.setTg(rs.getDouble("tg"));
                    record.setHdl(rs.getDouble("hdl"));
                    record.setLdl(rs.getDouble("ldl"));
                    record.setVldl(rs.getDouble("vldl"));
                    record.setBmi(rs.getDouble("bmi"));
                    record.setPatientId(rs.getInt("patient_id"));
                    record.setPatientName(rs.getString("patient_name"));
                    record.setWeight(rs.getDouble("weight"));
                    record.setHeight(rs.getDouble("height"));
                    record.setOtherInformation(rs.getString("other_information"));
                    record.setStatus(rs.getString("status"));
                    record.setDoctorId(rs.getObject("doctor_id") != null ? rs.getInt("doctor_id") : null);
                    record.setDoctorName(rs.getString("doctor_name"));
                    record.setCreatedAt(rs.getTimestamp("created_at"));
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Get count of health records by doctor
     */
    public int getHealthRecordsByDoctorCount(int doctorId, String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "WHERE hr.doctor_id = ?"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();
        params.add(doctorId);
        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get count of pending health records
     */
    public int getPendingHealthRecordCount(String search) {
        StringBuilder sql = new StringBuilder(
            "SELECT COUNT(*) FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "WHERE (hr.status = 'pending' OR hr.status IS NULL)"
            + getHealthRecordSpamFilterClause()
        );
        java.util.List<Object> params = new java.util.ArrayList<>();

        addHealthRecordSpamFilterParams(params);

        if (search != null && !search.trim().isEmpty()) {
            sql.append(" AND (p.full_name LIKE ? OR p.email LIKE ? OR CAST(hr.patient_id AS VARCHAR) LIKE ?)");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
            params.add("%" + search + "%");
        }
        

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return 0;
    }

    /**
     * Get all doctors with their current workload (for assignment)
     */
    public java.util.List<java.util.Map<String, Object>> getAllDoctorsWithWorkload() {
        java.util.List<java.util.Map<String, Object>> doctors = new java.util.ArrayList<>();
        String sql =
            "SELECT d.doctor_id, d.full_name, d.department, d.email, a.status as account_status, " +
            "COUNT(hr.health_record_id) as assigned_count " +
            "FROM Doctor d " +
            "LEFT JOIN Healthy_Record hr ON d.doctor_id = hr.doctor_id AND hr.status = 'processing' " +
            "JOIN Account a ON d.account_id = a.account_id " +
            "GROUP BY d.doctor_id, d.full_name, d.department, d.email, a.status " +
            "ORDER BY assigned_count ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> doctor = new java.util.HashMap<>();
                doctor.put("doctorId", rs.getInt("doctor_id"));
                doctor.put("fullName", rs.getString("full_name"));
                doctor.put("department", rs.getString("department"));
                doctor.put("email", rs.getString("email"));
                doctor.put("accountStatus", rs.getString("account_status"));
                doctor.put("assignedCount", rs.getInt("assigned_count"));
                doctors.add(doctor);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return doctors;
    }

    /**
     * Get only active doctors (for auto-assign)
     */
    public java.util.List<java.util.Map<String, Object>> getActiveDoctorsWithWorkload() {
        java.util.List<java.util.Map<String, Object>> doctors = new java.util.ArrayList<>();
        String sql =
            "SELECT d.doctor_id, d.full_name, d.department, d.email, " +
            "COUNT(hr.health_record_id) as assigned_count " +
            "FROM Doctor d " +
            "LEFT JOIN Healthy_Record hr ON d.doctor_id = hr.doctor_id AND hr.status = 'processing' " +
            "JOIN Account a ON d.account_id = a.account_id " +
            "WHERE a.status = 'active' " +
            "GROUP BY d.doctor_id, d.full_name, d.department, d.email " +
            "ORDER BY assigned_count ASC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> doctor = new java.util.HashMap<>();
                doctor.put("doctorId", rs.getInt("doctor_id"));
                doctor.put("fullName", rs.getString("full_name"));
                doctor.put("department", rs.getString("department"));
                doctor.put("email", rs.getString("email"));
                doctor.put("assignedCount", rs.getInt("assigned_count"));
                doctors.add(doctor);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return doctors;
    }

    /**
     * Assign health record to a doctor
     */
    public AssignmentResult assignHealthRecord(int healthRecordId, int doctorId, boolean confirmReassignment) {
        String recordSql = "SELECT status, doctor_id FROM Healthy_Record WHERE health_record_id = ?";
        String doctorSql = "SELECT a.status FROM Doctor d JOIN Account a ON d.account_id = a.account_id WHERE d.doctor_id = ?";
        String updateSql = "UPDATE Healthy_Record SET doctor_id = ?, status = 'processing' "
                + "WHERE health_record_id = ? AND status <> 'completed'";

        try (Connection connection = DatabaseConnection.getConnection()) {
            connection.setAutoCommit(false);
            try {
                String recordStatus;
                Integer currentDoctorId;
                try (PreparedStatement statement = connection.prepareStatement(recordSql)) {
                    statement.setInt(1, healthRecordId);
                    try (ResultSet rs = statement.executeQuery()) {
                        if (!rs.next()) {
                            return AssignmentResult.RECORD_NOT_FOUND;
                        }
                        recordStatus = rs.getString("status");
                        currentDoctorId = rs.getObject("doctor_id") == null ? null : rs.getInt("doctor_id");
                    }
                }

                if ("completed".equals(recordStatus)) {
                    return AssignmentResult.RECORD_COMPLETED;
                }
                if (currentDoctorId != null && currentDoctorId != doctorId && !confirmReassignment) {
                    return AssignmentResult.REQUIRES_CONFIRMATION;
                }

                try (PreparedStatement statement = connection.prepareStatement(doctorSql)) {
                    statement.setInt(1, doctorId);
                    try (ResultSet rs = statement.executeQuery()) {
                        if (!rs.next() || !"active".equals(rs.getString("status"))) {
                            return AssignmentResult.DOCTOR_UNAVAILABLE;
                        }
                    }
                }

                try (PreparedStatement statement = connection.prepareStatement(updateSql)) {
                    statement.setInt(1, doctorId);
                    statement.setInt(2, healthRecordId);
                    AssignmentResult result = statement.executeUpdate() > 0
                            ? AssignmentResult.SUCCESS : AssignmentResult.FAILED;
                    connection.commit();
                    return result;
                }
            } catch (SQLException e) {
                connection.rollback();
                throw e;
            } finally {
                connection.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to assign health record " + healthRecordId, e);
        }
        return AssignmentResult.FAILED;
    }

    /**
     * Mark health record as completed from admin workflow
     */
    public boolean completeHealthRecord(int healthRecordId) {
        String sql = "UPDATE Healthy_Record SET status = 'completed' WHERE health_record_id = ?";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, healthRecordId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to complete health record " + healthRecordId, e);
        }
        return false;
    }

    /**
     * Auto assign pending records to doctors evenly
     */
    public int autoAssignPendingRecords() {
        int assignedCount = 0;
        Connection connection = null;
        try {
            connection = DatabaseConnection.getConnection();
            connection.setAutoCommit(false);

            // Get all pending records without doctor
            String sqlPending = "SELECT health_record_id FROM Healthy_Record "
                    + "WHERE status = 'pending' AND doctor_id IS NULL "
                    + "ORDER BY created_at ASC, health_record_id ASC";
            java.util.List<Integer> pendingRecords = new java.util.ArrayList<>();
            try (PreparedStatement stmt = connection.prepareStatement(sqlPending);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    pendingRecords.add(rs.getInt("health_record_id"));
                }
            }

            if (pendingRecords.isEmpty()) {
                return 0;
            }

            // Get active doctors ordered by current workload
            String sqlDoctors =
                "SELECT d.doctor_id, COUNT(hr.health_record_id) as workload " +
                "FROM Doctor d " +
                "LEFT JOIN Healthy_Record hr ON d.doctor_id = hr.doctor_id AND hr.status = 'processing' " +
                "JOIN Account a ON d.account_id = a.account_id " +
                "WHERE a.status = 'active' " +
                "GROUP BY d.doctor_id " +
                "ORDER BY workload ASC";
            java.util.List<Integer> doctorIds = new java.util.ArrayList<>();
            try (PreparedStatement stmt = connection.prepareStatement(sqlDoctors);
                 ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    doctorIds.add(rs.getInt("doctor_id"));
                }
            }

            if (doctorIds.isEmpty()) {
                return 0;
            }

            // Assign records evenly
            String sqlAssign = "UPDATE Healthy_Record SET doctor_id = ?, status = 'processing' WHERE health_record_id = ?";
            try (PreparedStatement stmt = connection.prepareStatement(sqlAssign)) {
                int doctorIndex = 0;
                for (int recordId : pendingRecords) {
                    int doctorId = doctorIds.get(doctorIndex % doctorIds.size());
                    stmt.setInt(1, doctorId);
                    stmt.setInt(2, recordId);
                    stmt.addBatch();
                    assignedCount++;
                    doctorIndex++;
                }
                stmt.executeBatch();
            }

            connection.commit();
        } catch (SQLException e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Rollback or cleanup failed", ex);
                }
            }
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        } finally {
            if (connection != null) {
                try {
                    connection.setAutoCommit(true);
                    connection.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Operation failed", e);
                }
            }
        }
        return assignedCount;
    }

    /**
     * Get health record statistics
     */
    public java.util.Map<String, Integer> getHealthRecordStats() {
        java.util.Map<String, Integer> stats = new java.util.HashMap<>();
        String sql =
            "SELECT " +
            "COUNT(*) as total, " +
            "SUM(CASE WHEN status = 'pending' OR status IS NULL THEN 1 ELSE 0 END) as pending, " +
            "SUM(CASE WHEN status = 'processing' THEN 1 ELSE 0 END) as processing, " +
            "SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed, " +
            "SUM(CASE WHEN (status = 'pending' OR status IS NULL) AND doctor_id IS NULL THEN 1 ELSE 0 END) as unassigned " +
            "FROM Healthy_Record hr " +
            "WHERE 1 = 1" + getHealthRecordSpamFilterClause();

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            java.util.List<Object> params = new java.util.ArrayList<>();
            addHealthRecordSpamFilterParams(params);
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
            if (rs.next()) {
                stats.put("total", rs.getInt("total"));
                stats.put("pending", rs.getInt("pending"));
                stats.put("processing", rs.getInt("processing"));
                stats.put("completed", rs.getInt("completed"));
                stats.put("unassigned", rs.getInt("unassigned"));
}
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return stats;
    }

    /**
     * Lấy thông tin chi tiết hồ sơ sức khỏe kèm tên bệnh nhân (cho AI Recommendation)
     */
    public java.util.Map<String, Object> getHealthRecordRecommendationContext(int recordId) {
        java.util.Map<String, Object> record = new java.util.HashMap<>();
        String sql =
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.weight, hr.height, " +
            "hr.other_information, hr.status, hr.doctor_id, hr.created_at, " +
            "p.full_name as patient_name, " +
            "ai.diabetes_probability, ai.pre_diabetes_probability, ai.normal_probability " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor_AI ai ON hr.health_record_id = ai.health_record_id " +
            "WHERE hr.health_record_id = ?";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, recordId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    record.put("health_record_id", rs.getInt("health_record_id"));
                    record.put("urea", rs.getDouble("urea"));
                    record.put("cr", rs.getDouble("cr"));
                    record.put("hba1c", rs.getDouble("hba1c"));
                    record.put("chol", rs.getDouble("chol"));
                    record.put("tg", rs.getDouble("tg"));
                    record.put("hdl", rs.getDouble("hdl"));
                    record.put("ldl", rs.getDouble("ldl"));
                    record.put("vldl", rs.getDouble("vldl"));
                    record.put("bmi", rs.getDouble("bmi"));
                    record.put("patient_id", rs.getInt("patient_id"));
                    record.put("patient_name", rs.getString("patient_name"));
                    record.put("weight", rs.getDouble("weight"));
                    record.put("height", rs.getDouble("height"));
                    record.put("other_information", rs.getString("other_information"));
                    record.put("status", rs.getString("status"));
                    record.put("doctor_id", rs.getInt("doctor_id"));
                    record.put("created_at", rs.getTimestamp("created_at"));

                    double diabetesProbability = rs.getDouble("diabetes_probability");
                    if (!rs.wasNull()) {
                        record.put("diabetes_probability", diabetesProbability);
                        record.put("pre_diabetes_probability", rs.getDouble("pre_diabetes_probability"));
                        record.put("normal_probability", rs.getDouble("normal_probability"));
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load recommendation context for record " + recordId, e);
            return null;
        }
        return record.isEmpty() ? null : record;
    }

    /**
     * Lấy thông tin chi tiết hồ sơ sức khỏe kèm tên bệnh nhân (cho AI Recommendation)
     */
    public java.util.Map<String, Object> getHealthRecordWithDetails(int recordId) {
        java.util.Map<String, Object> record = new java.util.HashMap<>();
        String sql =
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.weight, hr.height, " +
            "hr.other_information, hr.status, hr.doctor_id, hr.created_at, " +
            "p.full_name as patient_name " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "WHERE hr.health_record_id = ?";
        
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, recordId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    record.put("health_record_id", rs.getInt("health_record_id"));
                    record.put("urea", rs.getDouble("urea"));
                    record.put("cr", rs.getDouble("cr"));
                    record.put("hba1c", rs.getDouble("hba1c"));
                    record.put("chol", rs.getDouble("chol"));
                    record.put("tg", rs.getDouble("tg"));
                    record.put("hdl", rs.getDouble("hdl"));
                    record.put("ldl", rs.getDouble("ldl"));
                    record.put("vldl", rs.getDouble("vldl"));
                    record.put("bmi", rs.getDouble("bmi"));
                    record.put("patient_id", rs.getInt("patient_id"));
                    record.put("patient_name", rs.getString("patient_name"));
                    record.put("weight", rs.getDouble("weight"));
                    record.put("height", rs.getDouble("height"));
                    record.put("other_information", rs.getString("other_information"));
                    record.put("status", rs.getString("status"));
                    record.put("doctor_id", rs.getInt("doctor_id"));
                    record.put("created_at", rs.getTimestamp("created_at"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return record.isEmpty() ? null : record;
    }

    /**
     * Lấy kết quả phân tích AI từ bảng Doctor_AI (kết quả từ AI Python)
     */
    public java.util.Map<String, Object> getAIAnalysisForRecord(int recordId) {
        java.util.Map<String, Object> analysis = new java.util.HashMap<>();
        String sql =
            "SELECT diabetes_probability, pre_diabetes_probability, normal_probability " +
            "FROM Doctor_AI " +
            "WHERE health_record_id = ?";
        
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, recordId);
            try (ResultSet rs = statement.executeQuery()) {
                if (rs.next()) {
                    analysis.put("diabetes_probability", rs.getDouble("diabetes_probability"));
                    analysis.put("pre_diabetes_probability", rs.getDouble("pre_diabetes_probability"));
                    analysis.put("normal_probability", rs.getDouble("normal_probability"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to load AI analysis for record " + recordId, e);
            return null;
        }
        return analysis.isEmpty() ? null : analysis;
    }

    /**
     * Lưu kết quả phân tích AI vào bảng Doctor_AI
     */
    public boolean saveAIAnalysis(int healthRecordId, int doctorId,
                                  double diabetesProb, double preDiabetesProb, double normalProb) {
        String sql =
            "INSERT INTO Doctor_AI (health_record_id, doctor_id, " +
            "diabetes_probability, pre_diabetes_probability, normal_probability) " +
            "VALUES (?, ?, ?, ?, ?)";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, healthRecordId);
            statement.setInt(2, doctorId);
            statement.setDouble(3, diabetesProb);
            statement.setDouble(4, preDiabetesProb);
            statement.setDouble(5, normalProb);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to save AI analysis for record " + healthRecordId, e);
            return false;
        }
    }

    /**
     * Lấy danh sách bác sĩ active kèm khoa và số hồ sơ đang quản lý (cho AI Recommendation)
     */
    public java.util.List<java.util.Map<String, Object>> getActiveDoctorsWithDepartment() {
        java.util.List<java.util.Map<String, Object>> doctors = new java.util.ArrayList<>();
        String sql =
            "SELECT d.doctor_id, d.full_name, d.department, d.email, " +
            "a.status as account_status, COALESCE(hr_stats.assigned_count, 0) as assigned_count " +
            "FROM Doctor d " +
            "JOIN Account a ON d.account_id = a.account_id " +
            "LEFT JOIN (" +
            "    SELECT doctor_id, COUNT(*) as assigned_count " +
            "    FROM Healthy_Record " +
            "    WHERE status IN ('processing', 'pending') AND doctor_id IS NOT NULL " +
            "    GROUP BY doctor_id" +
            ") hr_stats ON hr_stats.doctor_id = d.doctor_id " +
            "WHERE a.status = 'active' " +
            "ORDER BY d.department, d.full_name";
        
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> doctor = new java.util.HashMap<>();
                doctor.put("doctor_id", rs.getInt("doctor_id"));
                doctor.put("full_name", rs.getString("full_name"));
                doctor.put("department", rs.getString("department"));
                doctor.put("email", rs.getString("email"));
                doctor.put("account_status", rs.getString("account_status"));
                doctor.put("assigned_count", rs.getInt("assigned_count"));
                doctors.add(doctor);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return doctors;
    }

    /**
     * Lấy danh sách hồ sơ đang chờ phân bổ kèm thông tin chi tiết (cho AI Auto Assign)
     * LƯU Ý: Không filter spam vì AI cần phân tích tất cả hồ sơ để phát hiện gian lận
     */
    public java.util.List<java.util.Map<String, Object>> getPendingHealthRecordsWithDetails() {
        java.util.List<java.util.Map<String, Object>> records = new java.util.ArrayList<>();
        String sql =
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.other_information, " +
            "p.full_name as patient_name, COALESCE(a.email, p.email) as patient_email, " +
            "ai.diabetes_probability, ai.pre_diabetes_probability, ai.normal_probability " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Account a ON p.account_id = a.account_id " +
            "LEFT JOIN Doctor_AI ai ON hr.health_record_id = ai.health_record_id " +
            "WHERE hr.status = 'pending' AND hr.doctor_id IS NULL " +
            getHealthRecordSpamFilterClause() + " " +
            "ORDER BY hr.created_at ASC, hr.health_record_id ASC";
        
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            java.util.List<Object> params = new java.util.ArrayList<>();
            addHealthRecordSpamFilterParams(params);
            int idx = 1;
            for (Object param : params) {
                statement.setObject(idx++, param);
            }
            try (ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> record = new java.util.HashMap<>();
                int healthRecordId = rs.getInt("health_record_id");
                record.put("health_record_id", healthRecordId);
                record.put("urea", rs.getDouble("urea"));
                record.put("cr", rs.getDouble("cr"));
                record.put("hba1c", rs.getDouble("hba1c"));
                record.put("chol", rs.getDouble("chol"));
                record.put("tg", rs.getDouble("tg"));
                record.put("hdl", rs.getDouble("hdl"));
                record.put("ldl", rs.getDouble("ldl"));
                record.put("vldl", rs.getDouble("vldl"));
                record.put("bmi", rs.getDouble("bmi"));
                int patientId = rs.getInt("patient_id");
                if (rs.wasNull()) {
                    patientId = 0;
                }
                String patientName = rs.getString("patient_name");
                if (patientName == null || patientName.trim().isEmpty()) {
                    // Nếu không có tên, dùng ID để hiển thị
                    if (patientId > 0) {
                        patientName = "Bệnh nhân #" + patientId;
                    } else {
                        patientName = "Hồ sơ #" + healthRecordId;
                    }
                }
                record.put("patient_id", patientId);
                record.put("patient_name", patientName);
                record.put("patient_email", rs.getString("patient_email"));
                record.put("other_information", rs.getString("other_information"));
                double diabetesProbability = rs.getDouble("diabetes_probability");
                if (!rs.wasNull()) {
                    record.put("diabetes_probability", diabetesProbability);
                    record.put("pre_diabetes_probability", rs.getDouble("pre_diabetes_probability"));
                    record.put("normal_probability", rs.getDouble("normal_probability"));
                }
                records.add(record);
            }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Lấy danh sách hồ sơ cảnh báo gian lận / spam dữ liệu cho Dashboard
     */
    public java.util.List<java.util.Map<String, Object>> getFraudAlertHealthRecords() {
        java.util.List<java.util.Map<String, Object>> records = new java.util.ArrayList<>();
        String sql =
            "SELECT hr.health_record_id, hr.other_information, hr.hba1c, hr.bmi, " +
            "p.full_name as patient_name, COALESCE(a.email, p.email) as patient_email, p.patient_id " +
            "FROM Healthy_Record hr " +
            "INNER JOIN Patient p ON hr.patient_id = p.patient_id " +
            "INNER JOIN Account a ON p.account_id = a.account_id " +
            "WHERE hr.other_information IS NOT NULL AND (" +
            "LOWER(hr.other_information) LIKE ? OR " +
            "LOWER(hr.other_information) LIKE ? OR " +
            "LOWER(hr.other_information) LIKE ? OR " +
            "LOWER(hr.other_information) LIKE ? OR " +
            "LOWER(hr.other_information) LIKE ?) " +
            "ORDER BY hr.created_at DESC";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, "%spam%");
            statement.setString(2, "%hack%");
            statement.setString(3, "%malicious%");
            statement.setString(4, "%bot%");
            statement.setString(5, "%asdasd%");

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> record = new java.util.HashMap<>();
                    int healthRecordId = rs.getInt("health_record_id");
                    record.put("health_record_id", healthRecordId);
                    record.put("patient_name", rs.getString("patient_name"));
                    record.put("patient_id", rs.getInt("patient_id"));
                    record.put("patient_email", rs.getString("patient_email"));
                    record.put("hba1c", rs.getDouble("hba1c"));
                    record.put("bmi", rs.getDouble("bmi"));
                    record.put("other_information", rs.getString("other_information"));
                    record.put("risk_level", "Cao");
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Lấy danh sách hồ sơ đang xử lý kèm thông tin chi tiết bệnh nhân và bác sĩ
     */
    public java.util.List<java.util.Map<String, Object>> getProcessingHealthRecordsWithDetails() {
        java.util.List<java.util.Map<String, Object>> records = new java.util.ArrayList<>();
        String sql =
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, " +
            "hr.doctor_id, d.full_name as doctor_name, " +
            "p.full_name as patient_name, p.email as patient_email, " +
            "hr.created_at " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.status = 'processing' " +
            "ORDER BY hr.health_record_id";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> record = new java.util.HashMap<>();
                int healthRecordId = rs.getInt("health_record_id");
                record.put("health_record_id", healthRecordId);
                record.put("urea", rs.getDouble("urea"));
                record.put("cr", rs.getDouble("cr"));
                record.put("hba1c", rs.getDouble("hba1c"));
                record.put("chol", rs.getDouble("chol"));
                record.put("tg", rs.getDouble("tg"));
                record.put("hdl", rs.getDouble("hdl"));
                record.put("ldl", rs.getDouble("ldl"));
                record.put("vldl", rs.getDouble("vldl"));
                record.put("bmi", rs.getDouble("bmi"));
                int patientId = rs.getInt("patient_id");
                if (rs.wasNull()) {
                    patientId = 0;
                }
                String patientName = rs.getString("patient_name");
                if (patientName == null || patientName.trim().isEmpty()) {
                    if (patientId > 0) {
                        patientName = "Bệnh nhân #" + patientId;
                    } else {
                        patientName = "Hồ sơ #" + healthRecordId;
                    }
                }
                record.put("patient_id", patientId);
                record.put("patient_name", patientName);
                record.put("patient_email", rs.getString("patient_email"));
                record.put("doctor_id", rs.getInt("doctor_id"));
                record.put("doctor_name", rs.getString("doctor_name"));
                record.put("created_at", rs.getTimestamp("created_at"));
                records.add(record);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Lấy danh sách hồ sơ đã hoàn thành kèm thông tin chi tiết bệnh nhân và bác sĩ
     */
    public java.util.List<java.util.Map<String, Object>> getCompletedHealthRecordsWithDetails() {
        java.util.List<java.util.Map<String, Object>> records = new java.util.ArrayList<>();
        String sql =
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, " +
            "hr.doctor_id, d.full_name as doctor_name, " +
            "p.full_name as patient_name, p.email as patient_email, " +
            "hr.created_at " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.status = 'completed' " +
            "ORDER BY hr.health_record_id";

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet rs = statement.executeQuery()) {
            while (rs.next()) {
                java.util.Map<String, Object> record = new java.util.HashMap<>();
                int healthRecordId = rs.getInt("health_record_id");
                record.put("health_record_id", healthRecordId);
                record.put("urea", rs.getDouble("urea"));
                record.put("cr", rs.getDouble("cr"));
                record.put("hba1c", rs.getDouble("hba1c"));
                record.put("chol", rs.getDouble("chol"));
                record.put("tg", rs.getDouble("tg"));
                record.put("hdl", rs.getDouble("hdl"));
                record.put("ldl", rs.getDouble("ldl"));
                record.put("vldl", rs.getDouble("vldl"));
                record.put("bmi", rs.getDouble("bmi"));
                int patientId = rs.getInt("patient_id");
                if (rs.wasNull()) {
                    patientId = 0;
                }
                String patientName = rs.getString("patient_name");
                if (patientName == null || patientName.trim().isEmpty()) {
                    if (patientId > 0) {
                        patientName = "Bệnh nhân #" + patientId;
                    } else {
                        patientName = "Hồ sơ #" + healthRecordId;
                    }
                }
                record.put("patient_id", patientId);
                record.put("patient_name", patientName);
                record.put("patient_email", rs.getString("patient_email"));
                record.put("doctor_id", rs.getInt("doctor_id"));
                record.put("doctor_name", rs.getString("doctor_name"));
                record.put("created_at", rs.getTimestamp("created_at"));
                records.add(record);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Lấy tất cả hồ sơ kèm thông tin chi tiết (trả về Map thay vì HealthRecord object)
     */
    public java.util.List<java.util.Map<String, Object>> getAllHealthRecordsWithDetails(
            String search, int page, int pageSize) {
        java.util.List<java.util.Map<String, Object>> records = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.status, " +
            "hr.doctor_id, d.full_name as doctor_name, " +
            "p.full_name as patient_name, p.email as patient_email, " +
            "hr.created_at " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append("WHERE p.full_name LIKE ? OR p.email LIKE ? OR CAST(hr.health_record_id AS VARCHAR) LIKE ? ");
        }
        sql.append("ORDER BY hr.health_record_id ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (search != null && !search.trim().isEmpty()) {
                String searchParam = "%" + search.trim() + "%";
                statement.setString(paramIndex++, searchParam);
                statement.setString(paramIndex++, searchParam);
                statement.setString(paramIndex++, searchParam);
            }
            statement.setInt(paramIndex++, (page - 1) * pageSize);
            statement.setInt(paramIndex, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> record = createHealthRecordMapFromResultSet(rs);
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Lấy hồ sơ theo bác sĩ kèm thông tin chi tiết (trả về Map)
     */
    public java.util.List<java.util.Map<String, Object>> getHealthRecordsByDoctorWithDetails(
            int doctorId, String search, int page, int pageSize) {
        java.util.List<java.util.Map<String, Object>> records = new java.util.ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT hr.health_record_id, hr.urea, hr.cr, hr.hba1c, hr.chol, hr.tg, " +
            "hr.hdl, hr.ldl, hr.vldl, hr.bmi, hr.patient_id, hr.status, " +
            "hr.doctor_id, d.full_name as doctor_name, " +
            "p.full_name as patient_name, p.email as patient_email, " +
            "hr.created_at " +
            "FROM Healthy_Record hr " +
            "LEFT JOIN Patient p ON hr.patient_id = p.patient_id " +
            "LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id " +
            "WHERE hr.doctor_id = ? "
        );

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (p.full_name LIKE ? OR p.email LIKE ? OR CAST(hr.health_record_id AS VARCHAR) LIKE ?) ");
        }
        sql.append("ORDER BY hr.health_record_id ");
        sql.append("OFFSET ? ROWS FETCH NEXT ? ROWS ONLY");

        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            statement.setInt(paramIndex++, doctorId);
            if (search != null && !search.trim().isEmpty()) {
                String searchParam = "%" + search.trim() + "%";
                statement.setString(paramIndex++, searchParam);
                statement.setString(paramIndex++, searchParam);
                statement.setString(paramIndex++, searchParam);
            }
            statement.setInt(paramIndex++, (page - 1) * pageSize);
            statement.setInt(paramIndex, pageSize);

            try (ResultSet rs = statement.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> record = createHealthRecordMapFromResultSet(rs);
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }

    /**
     * Helper method to create Map from ResultSet
     */
    private java.util.Map<String, Object> createHealthRecordMapFromResultSet(ResultSet rs) throws SQLException {
        java.util.Map<String, Object> record = new java.util.HashMap<>();
        int healthRecordId = rs.getInt("health_record_id");
        record.put("health_record_id", healthRecordId);
        record.put("healthRecordId", healthRecordId); // camelCase cho JSP
        record.put("urea", rs.getDouble("urea"));
        record.put("cr", rs.getDouble("cr"));
        record.put("hba1c", rs.getDouble("hba1c"));
        record.put("chol", rs.getDouble("chol"));
        record.put("tg", rs.getDouble("tg"));
        record.put("hdl", rs.getDouble("hdl"));
        record.put("ldl", rs.getDouble("ldl"));
        record.put("vldl", rs.getDouble("vldl"));
        record.put("bmi", rs.getDouble("bmi"));
        record.put("status", rs.getString("status"));

        int patientId = rs.getInt("patient_id");
        if (rs.wasNull()) {
            patientId = 0;
        }
        String patientName = rs.getString("patient_name");
        if (patientName == null || patientName.trim().isEmpty()) {
            if (patientId > 0) {
                patientName = "Bệnh nhân #" + patientId;
            } else {
                patientName = "Hồ sơ #" + healthRecordId;
            }
        }
        record.put("patient_id", patientId);
        record.put("patientId", patientId); // camelCase cho JSP
        record.put("patient_name", patientName);
        record.put("patientName", patientName); // camelCase cho JSP
        record.put("patient_email", rs.getString("patient_email"));
        record.put("patientEmail", rs.getString("patient_email")); // camelCase cho JSP
        record.put("doctor_id", rs.getInt("doctor_id"));
        record.put("doctorId", rs.getInt("doctor_id")); // camelCase cho JSP
        record.put("doctor_name", rs.getString("doctor_name"));
        record.put("doctorName", rs.getString("doctor_name")); // camelCase cho JSP
        record.put("created_at", rs.getTimestamp("created_at"));
        record.put("createdAt", rs.getTimestamp("created_at")); // camelCase cho JSP
        return record;
    }
    // #endregion
    // #endregion
}




