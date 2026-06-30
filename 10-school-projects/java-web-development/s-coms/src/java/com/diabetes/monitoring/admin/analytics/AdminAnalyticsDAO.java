package com.diabetes.monitoring.admin.analytics;

import com.diabetes.monitoring.admin.common.AdminRepository;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

/**
 * Facade over dashboard and report persistence operations.
 */
public class AdminAnalyticsDAO {
    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();
    private final AdminReportDAO reportDAO = new AdminReportDAO();

    /**
     * Normalizes future completed appointments for consistent Admin processing.
     */
    public void normalizeFutureCompletedAppointments() { dashboardDAO.normalizeFutureCompletedAppointments(); }
    /**
     * Handles auto advance appointment workflow demo for the Admin module.
     */
    public void autoAdvanceAppointmentWorkflowDemo() { dashboardDAO.autoAdvanceAppointmentWorkflowDemo(); }
    /**
     * Gets count total accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalAccounts() { return dashboardDAO.getCountTotalAccounts(); }
    /**
     * Gets count active accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountActiveAccounts() { return dashboardDAO.getCountActiveAccounts(); }
    /**
     * Gets count locked accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountLockedAccounts() { return dashboardDAO.getCountLockedAccounts(); }
    /**
     * Gets count total services for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalServices() { return dashboardDAO.getCountTotalServices(); }
    /**
     * Gets sum paid revenue for the Admin module.
     *
     * @return the operation result
     */
    public BigDecimal getSumPaidRevenue() { return dashboardDAO.getSumPaidRevenue(); }
    /**
     * Gets count completed appointments for the Admin module.
     *
     * @return the operation result
     */
    public int getCountCompletedAppointments() { return dashboardDAO.getCountCompletedAppointments(); }
    /**
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() { return dashboardDAO.getTodayClinicQueueStatus(); }
    /**
     * Gets today schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodaySchedules() { return dashboardDAO.getTodaySchedules(); }
    /**
     * Gets today total visits for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayTotalVisits() { return dashboardDAO.getTodayTotalVisits(); }
    /**
     * Gets today waiting patients for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayWaitingPatients() { return dashboardDAO.getTodayWaitingPatients(); }
    /**
     * Gets today patient flow by time slot for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayPatientFlowByTimeSlot() { return dashboardDAO.getTodayPatientFlowByTimeSlot(); }
    /**
     * Gets today revenue by service type for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayRevenueByServiceType() { return dashboardDAO.getTodayRevenueByServiceType(); }
    /**
     * Gets today appointment status distribution for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointmentStatusDistribution() { return dashboardDAO.getTodayAppointmentStatusDistribution(); }
    /**
     * Gets dashboard revenue series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardRevenueSeries(String granularity) { return dashboardDAO.getDashboardRevenueSeries(granularity); }
    /**
     * Gets dashboard visit series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardVisitSeries(String granularity) { return dashboardDAO.getDashboardVisitSeries(granularity); }
    /**
     * Gets staff accounts quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getStaffAccountsQuick(String status, int limit) { return dashboardDAO.getStaffAccountsQuick(status, limit); }
    /**
     * Gets recent paid invoices today for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getRecentPaidInvoicesToday(int limit) { return dashboardDAO.getRecentPaidInvoicesToday(limit); }
    /**
     * Gets medical services for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getMedicalServices(String keyword, String status, String department) { return dashboardDAO.getMedicalServices(keyword, status, department); }
    /**
     * Gets completed appointments today quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getCompletedAppointmentsTodayQuick(int limit) { return dashboardDAO.getCompletedAppointmentsTodayQuick(limit); }

    /**
     * Gets revenue report for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getRevenueReport(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) { return reportDAO.getRevenueReport(granularity, year, month, day, startDate, endDate); }
    /**
     * Gets visit report for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getVisitReport(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) { return reportDAO.getVisitReport(granularity, year, month, day, startDate, endDate); }
    /**
     * Gets report detail by period for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getReportDetailByPeriod(String period) { return reportDAO.getReportDetailByPeriod(period); }
    /**
     * Gets invoice items by invoice id for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getInvoiceItemsByInvoiceId(String invoiceId) { return reportDAO.getInvoiceItemsByInvoiceId(invoiceId); }
    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     */
    public void markLateWaitingAppointmentsAsNoShow() { reportDAO.markLateWaitingAppointmentsAsNoShow(); }
}

/**
 * Loads dashboard data from the shared Admin repository.
 */
class AdminDashboardDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Normalizes future completed appointments for consistent Admin processing.
     */
    public void normalizeFutureCompletedAppointments() {
        repository.normalizeFutureCompletedAppointments();
    }

    /**
     * Handles auto advance appointment workflow demo for the Admin module.
     */
    public void autoAdvanceAppointmentWorkflowDemo() {
        repository.autoAdvanceAppointmentWorkflowDemo();
    }

    /**
     * Gets count total accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalAccounts() {
        return repository.getCountTotalAccounts();
    }

    /**
     * Gets count active accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountActiveAccounts() {
        return repository.getCountActiveAccounts();
    }

    /**
     * Gets count locked accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountLockedAccounts() {
        return repository.getCountLockedAccounts();
    }

    /**
     * Gets count total services for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalServices() {
        return repository.getCountTotalServices();
    }

    /**
     * Gets sum paid revenue for the Admin module.
     *
     * @return the operation result
     */
    public BigDecimal getSumPaidRevenue() {
        return repository.getSumPaidRevenue();
    }

    /**
     * Gets count completed appointments for the Admin module.
     *
     * @return the operation result
     */
    public int getCountCompletedAppointments() {
        return repository.getCountCompletedAppointments();
    }

    /**
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() {
        return repository.getTodayClinicQueueStatus();
    }

    /**
     * Gets today schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodaySchedules() {
        return repository.getTodaySchedules();
    }

    /**
     * Gets today total visits for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayTotalVisits() {
        return repository.getTodayTotalVisits();
    }

    /**
     * Gets today waiting patients for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayWaitingPatients() {
        return repository.getTodayWaitingPatients();
    }

    /**
     * Gets today patient flow by time slot for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayPatientFlowByTimeSlot() {
        return repository.getTodayPatientFlowByTimeSlot();
    }

    /**
     * Gets today revenue by service type for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayRevenueByServiceType() {
        return repository.getTodayRevenueByServiceType();
    }

    /**
     * Gets today appointment status distribution for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointmentStatusDistribution() {
        return repository.getTodayAppointmentStatusDistribution();
    }

    /**
     * Gets dashboard revenue series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardRevenueSeries(String granularity) {
        return repository.getDashboardRevenueSeries(granularity);
    }

    /**
     * Gets dashboard visit series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardVisitSeries(String granularity) {
        return repository.getDashboardVisitSeries(granularity);
    }

    /**
     * Gets staff accounts quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getStaffAccountsQuick(String status, int limit) {
        return repository.getStaffAccountsQuick(status, limit);
    }

    /**
     * Gets recent paid invoices today for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getRecentPaidInvoicesToday(int limit) {
        return repository.getRecentPaidInvoicesToday(limit);
    }

    /**
     * Gets medical services for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getMedicalServices(String keyword, String status, String department) {
        return repository.getMedicalServices(keyword, status, department);
    }

    /**
     * Gets completed appointments today quick for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getCompletedAppointmentsTodayQuick(int limit) {
        return repository.getCompletedAppointmentsTodayQuick(limit);
    }
}

/**
 * Loads report data from the shared Admin repository.
 */
class AdminReportDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Gets revenue report for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getRevenueReport(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) {
        return repository.getRevenueReport(granularity, year, month, day, startDate, endDate);
    }

    /**
     * Gets visit report for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getVisitReport(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) {
        return repository.getVisitReport(granularity, year, month, day, startDate, endDate);
    }

    /**
     * Gets report detail by period for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getReportDetailByPeriod(String period) {
        return repository.getReportDetailByPeriod(period);
    }

    /**
     * Gets invoice items by invoice id for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getInvoiceItemsByInvoiceId(String invoiceId) {
        return repository.getInvoiceItemsByInvoiceId(invoiceId);
    }

    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     */
    public void markLateWaitingAppointmentsAsNoShow() {
        repository.markLateWaitingAppointmentsAsNoShow();
    }
}
