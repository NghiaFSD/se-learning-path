package com.diabetes.monitoring.admin.management;

import com.diabetes.monitoring.admin.common.AdminRepository;
import com.diabetes.monitoring.model.User;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Facade over account and medical service persistence operations.
 */
public class AdminManagementDAO {
    private final AdminAccountDAO accountDAO = new AdminAccountDAO();
    private final AdminMedicalServiceDAO medicalServiceDAO = new AdminMedicalServiceDAO();

    /**
     * Gets accounts for the Admin module.
     *
     * @return the operation result
     */
    public List<User> getAccounts(String search, String role, String status) { return accountDAO.getAccounts(search, role, status); }
    /**
     * Creates account for the Admin module.
     *
     * @return the operation result
     */
    public boolean createAccount(String fullName, String email, String passwordHash, String role, String status) { return accountDAO.createAccount(fullName, email, passwordHash, role, status); }
    /**
     * Handles is account email exists for the Admin module.
     *
     * @return the operation result
     */
    public boolean isAccountEmailExists(String email) { return accountDAO.isAccountEmailExists(email); }
    /**
     * Updates account role for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountRole(int accountId, String role) { return accountDAO.updateAccountRole(accountId, role); }
    /**
     * Updates account status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountStatus(int accountId, String status) { return accountDAO.updateAccountStatus(accountId, status); }
    /**
     * Deletes account for admin for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteAccountForAdmin(int accountId) { return accountDAO.deleteAccountForAdmin(accountId); }
    /**
     * Gets account profile for admin edit for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getAccountProfileForAdminEdit(int accountId) { return accountDAO.getAccountProfileForAdminEdit(accountId); }
    /**
     * Updates account profile by role for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountProfileByRole(int accountId, String fullName, String email, String phone, String address, String department) { return accountDAO.updateAccountProfileByRole(accountId, fullName, email, phone, address, department); }
    /**
     * Gets staff accounts quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getStaffAccountsQuick(String status, int limit) { return accountDAO.getStaffAccountsQuick(status, limit); }

    /**
     * Gets medical services for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getMedicalServices(String search, String serviceType, String status) { return medicalServiceDAO.getMedicalServices(search, serviceType, status); }
    /**
     * Creates medical service for the Admin module.
     *
     * @return the operation result
     */
    public boolean createMedicalService(String serviceName, BigDecimal price, String serviceType, String status) { return medicalServiceDAO.createMedicalService(serviceName, price, serviceType, status); }
    /**
     * Updates medical service for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateMedicalService(int serviceId, String serviceName, BigDecimal price, String serviceType, String status) { return medicalServiceDAO.updateMedicalService(serviceId, serviceName, price, serviceType, status); }
    /**
     * Deletes medical service for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteMedicalService(int serviceId) { return medicalServiceDAO.deleteMedicalService(serviceId); }
    /**
     * Updates medical service status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateMedicalServiceStatus(int serviceId, String status) { return medicalServiceDAO.updateMedicalServiceStatus(serviceId, status); }
    /**
     * Gets count total services for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalServices() { return medicalServiceDAO.getCountTotalServices(); }
}

/**
 * Loads and mutates account data through the shared Admin repository.
 */
class AdminAccountDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Gets accounts for the Admin module.
     *
     * @return the operation result
     */
    public List<User> getAccounts(String search, String role, String status) {
        return repository.getAccounts(search, role, status);
    }

    /**
     * Creates account for the Admin module.
     *
     * @return the operation result
     */
    public boolean createAccount(String fullName, String email, String passwordHash, String role, String status) {
        return repository.createAccount(fullName, email, passwordHash, role, status);
    }

    /**
     * Handles is account email exists for the Admin module.
     *
     * @return the operation result
     */
    public boolean isAccountEmailExists(String email) {
        return repository.isAccountEmailExists(email);
    }

    /**
     * Updates account role for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountRole(int accountId, String role) {
        return repository.updateAccountRole(accountId, role);
    }

    /**
     * Updates account status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountStatus(int accountId, String status) {
        return repository.updateAccountStatus(accountId, status);
    }

    /**
     * Deletes account for admin for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteAccountForAdmin(int accountId) {
        return repository.deleteAccountForAdmin(accountId);
    }

    /**
     * Gets account profile for admin edit for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getAccountProfileForAdminEdit(int accountId) {
        return repository.getAccountProfileForAdminEdit(accountId);
    }

    /**
     * Updates account profile by role for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountProfileByRole(int accountId,
            String fullName,
            String email,
            String phone,
            String address,
            String department) {
        return repository.updateAccountProfileByRole(accountId, fullName, email, phone, address, department);
    }

    /**
     * Gets staff accounts quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getStaffAccountsQuick(String status, int limit) {
        return repository.getStaffAccountsQuick(status, limit);
    }
}

/**
 * Loads and mutates medical service data through the shared Admin repository.
 */
class AdminMedicalServiceDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Gets medical services for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getMedicalServices(String search, String serviceType, String status) {
        return repository.getMedicalServices(search, serviceType, status);
    }

    /**
     * Creates medical service for the Admin module.
     *
     * @return the operation result
     */
    public boolean createMedicalService(String serviceName, BigDecimal price, String serviceType, String status) {
        return repository.createMedicalService(serviceName, price, serviceType, status);
    }

    /**
     * Updates medical service for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateMedicalService(int serviceId, String serviceName, BigDecimal price, String serviceType, String status) {
        return repository.updateMedicalService(serviceId, serviceName, price, serviceType, status);
    }

    /**
     * Deletes medical service for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteMedicalService(int serviceId) {
        return repository.deleteMedicalService(serviceId);
    }

    /**
     * Updates medical service status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateMedicalServiceStatus(int serviceId, String status) {
        return repository.updateMedicalServiceStatus(serviceId, status);
    }

    /**
     * Gets count total services for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalServices() {
        return repository.getCountTotalServices();
    }
}
