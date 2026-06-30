package com.diabetes.monitoring.admin.management;

import com.diabetes.monitoring.model.User;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

/**
 * Provides account and medical service management use cases.
 */
public class AdminManagementService {
    private final AdminAccountService accountService = new AdminAccountService();
    private final AdminMedicalServiceService medicalServiceService = new AdminMedicalServiceService();

    /**
     * Loads accounts data for the Admin UI.
     *
     * @return the operation result
     */
    public List<User> loadAccounts(String search, String role, String status) { return accountService.loadAccounts(search, role, status); }
    /**
     * Handles is account email exists for the Admin module.
     *
     * @return the operation result
     */
    public boolean isAccountEmailExists(String email) { return accountService.isAccountEmailExists(email); }
    /**
     * Creates account for the Admin module.
     *
     * @return the operation result
     */
    public boolean createAccount(String fullName, String email, String passwordHash, String role, String status) { return accountService.createAccount(fullName, email, passwordHash, role, status); }
    /**
     * Updates account role for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountRole(int accountId, String role) { return accountService.updateAccountRole(accountId, role); }
    /**
     * Updates account status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountStatus(int accountId, String status) { return accountService.updateAccountStatus(accountId, status); }
    /**
     * Deletes account for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteAccount(int accountId) { return accountService.deleteAccount(accountId); }
    /**
     * Gets account profile for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getAccountProfile(int accountId) { return accountService.getAccountProfile(accountId); }
    /**
     * Updates account profile by role for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountProfileByRole(int accountId, String fullName, String email, String phone, String address, String department) { return accountService.updateAccountProfileByRole(accountId, fullName, email, phone, address, department); }
    /**
     * Gets staff accounts quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getStaffAccountsQuick(String status, int limit) { return accountService.getStaffAccountsQuick(status, limit); }

    /**
     * Loads services data for the Admin UI.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> loadServices(String search, String serviceType, String status) { return medicalServiceService.loadServices(search, serviceType, status); }
    /**
     * Creates service for the Admin module.
     *
     * @return the operation result
     */
    public boolean createService(String serviceName, BigDecimal price, String serviceType, String status) { return medicalServiceService.createService(serviceName, price, serviceType, status); }
    /**
     * Updates service for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateService(int serviceId, String serviceName, BigDecimal price, String serviceType, String status) { return medicalServiceService.updateService(serviceId, serviceName, price, serviceType, status); }
    /**
     * Deletes service for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteService(int serviceId) { return medicalServiceService.deleteService(serviceId); }
    /**
     * Updates service status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateServiceStatus(int serviceId, String status) { return medicalServiceService.updateServiceStatus(serviceId, status); }
    /**
     * Gets count total services for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalServices() { return medicalServiceService.getTotalServices(); }
}

/**
 * Applies business rules for account management.
 */
class AdminAccountService {
    private final AdminAccountDAO accountDAO = new AdminAccountDAO();

    /**
     * Loads accounts data for the Admin UI.
     *
     * @return the operation result
     */
    public List<User> loadAccounts(String search, String role, String status) {
        return accountDAO.getAccounts(search, role, status);
    }

    /**
     * Handles is account email exists for the Admin module.
     *
     * @return the operation result
     */
    public boolean isAccountEmailExists(String email) {
        return accountDAO.isAccountEmailExists(email);
    }

    /**
     * Creates account for the Admin module.
     *
     * @return the operation result
     */
    public boolean createAccount(String fullName, String email, String passwordHash, String role, String status) {
        return accountDAO.createAccount(fullName, email, passwordHash, role, status);
    }

    /**
     * Updates account role for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountRole(int accountId, String role) {
        return accountDAO.updateAccountRole(accountId, role);
    }

    /**
     * Updates account status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateAccountStatus(int accountId, String status) {
        return accountDAO.updateAccountStatus(accountId, status);
    }

    /**
     * Deletes account for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteAccount(int accountId) {
        return accountDAO.deleteAccountForAdmin(accountId);
    }

    /**
     * Gets account profile for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getAccountProfile(int accountId) {
        return accountDAO.getAccountProfileForAdminEdit(accountId);
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
        return accountDAO.updateAccountProfileByRole(accountId, fullName, email, phone, address, department);
    }

    /**
     * Gets staff accounts quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getStaffAccountsQuick(String status, int limit) {
        return accountDAO.getStaffAccountsQuick(status, limit);
    }
}

/**
 * Applies business rules for the medical service catalog.
 */
class AdminMedicalServiceService {
    private final AdminMedicalServiceDAO medicalServiceDAO = new AdminMedicalServiceDAO();

    /**
     * Loads services data for the Admin UI.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> loadServices(String search, String serviceType, String status) {
        return medicalServiceDAO.getMedicalServices(search, serviceType, status);
    }

    /**
     * Creates service for the Admin module.
     *
     * @return the operation result
     */
    public boolean createService(String serviceName, BigDecimal price, String serviceType, String status) {
        return medicalServiceDAO.createMedicalService(serviceName, price, serviceType, status);
    }

    /**
     * Updates service for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateService(int serviceId, String serviceName, BigDecimal price, String serviceType, String status) {
        return medicalServiceDAO.updateMedicalService(serviceId, serviceName, price, serviceType, status);
    }

    /**
     * Updates service status for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateServiceStatus(int serviceId, String status) {
        return medicalServiceDAO.updateMedicalServiceStatus(serviceId, status);
    }

    /**
     * Deletes service for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteService(int serviceId) {
        return medicalServiceDAO.deleteMedicalService(serviceId);
    }

    /**
     * Gets total services for the Admin module.
     *
     * @return the operation result
     */
    public int getTotalServices() {
        return medicalServiceDAO.getCountTotalServices();
    }
}
