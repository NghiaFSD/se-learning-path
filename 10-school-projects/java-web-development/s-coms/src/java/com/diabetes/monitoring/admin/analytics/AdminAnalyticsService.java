package com.diabetes.monitoring.admin.analytics;

import com.diabetes.monitoring.admin.common.ReportSeriesDTO;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

/**
 * Provides analytics use cases for dashboard and reports.
 */
public class AdminAnalyticsService {
    private final AdminDashboardService dashboardService = new AdminDashboardService();
    private final AdminReportService reportService = new AdminReportService();

    /**
     * Handles prepare dashboard data for the Admin module.
     */
    public void prepareDashboardData() { dashboardService.prepareDashboardData(); }
    /**
     * Gets count total accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalAccounts() { return dashboardService.getCountTotalAccounts(); }
    /**
     * Gets count active accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountActiveAccounts() { return dashboardService.getCountActiveAccounts(); }
    /**
     * Gets count locked accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountLockedAccounts() { return dashboardService.getCountLockedAccounts(); }
    /**
     * Gets count total services for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalServices() { return dashboardService.getCountTotalServices(); }
    /**
     * Gets sum paid revenue for the Admin module.
     *
     * @return the operation result
     */
    public BigDecimal getSumPaidRevenue() { return dashboardService.getSumPaidRevenue(); }
    /**
     * Gets count completed appointments for the Admin module.
     *
     * @return the operation result
     */
    public int getCountCompletedAppointments() { return dashboardService.getCountCompletedAppointments(); }
    /**
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() { return dashboardService.getTodayClinicQueueStatus(); }
    /**
     * Gets today schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodaySchedules() { return dashboardService.getTodaySchedules(); }
    /**
     * Gets today total visits for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayTotalVisits() { return dashboardService.getTodayTotalVisits(); }
    /**
     * Gets today waiting patients for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayWaitingPatients() { return dashboardService.getTodayWaitingPatients(); }
    /**
     * Gets today patient flow by time slot for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayPatientFlowByTimeSlot() { return dashboardService.getTodayPatientFlowByTimeSlot(); }
    /**
     * Gets today revenue by service type for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayRevenueByServiceType() { return dashboardService.getTodayRevenueByServiceType(); }
    /**
     * Gets today appointment status distribution for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointmentStatusDistribution() { return dashboardService.getTodayAppointmentStatusDistribution(); }
    /**
     * Gets dashboard revenue series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardRevenueSeries(String granularity) { return dashboardService.getDashboardRevenueSeries(granularity); }
    /**
     * Gets dashboard visit series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardVisitSeries(String granularity) { return dashboardService.getDashboardVisitSeries(granularity); }
    /**
     * Gets quick accounts for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickAccounts(String filter) { return dashboardService.getQuickAccounts(filter); }
    /**
     * Gets quick revenue for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickRevenue() { return dashboardService.getQuickRevenue(); }
    /**
     * Gets quick services for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickServices() { return dashboardService.getQuickServices(); }
    /**
     * Gets quick appointments for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickAppointments() { return dashboardService.getQuickAppointments(); }

    /**
     * Gets revenue series for the Admin module.
     *
     * @return the operation result
     */
    public List<ReportSeriesDTO> getRevenueSeries(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) { return reportService.getRevenueSeries(granularity, year, month, day, startDate, endDate); }
    /**
     * Gets visit series for the Admin module.
     *
     * @return the operation result
     */
    public List<ReportSeriesDTO> getVisitSeries(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) { return reportService.getVisitSeries(granularity, year, month, day, startDate, endDate); }
    /**
     * Gets report detail by period for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getReportDetailByPeriod(String period) { return reportService.getReportDetailByPeriod(period); }
    /**
     * Gets invoice items by invoice id for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getInvoiceItemsByInvoiceId(String invoiceId) { return reportService.getInvoiceItemsByInvoiceId(invoiceId); }
    /**
     * Handles refresh report read models for the Admin module.
     */
    public void refreshReportReadModels() { reportService.refreshReportReadModels(); }
}

/**
 * Coordinates dashboard data preparation and summary metrics.
 */
class AdminDashboardService {
    private final AdminDashboardDAO dashboardDAO = new AdminDashboardDAO();

    /**
     * Handles prepare dashboard data for the Admin module.
     */
    public void prepareDashboardData() {
        dashboardDAO.normalizeFutureCompletedAppointments();
    }

    /**
     * Gets count total accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalAccounts() {
        return dashboardDAO.getCountTotalAccounts();
    }

    /**
     * Gets count active accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountActiveAccounts() {
        return dashboardDAO.getCountActiveAccounts();
    }

    /**
     * Gets count locked accounts for the Admin module.
     *
     * @return the operation result
     */
    public int getCountLockedAccounts() {
        return dashboardDAO.getCountLockedAccounts();
    }

    /**
     * Gets count total services for the Admin module.
     *
     * @return the operation result
     */
    public int getCountTotalServices() {
        return dashboardDAO.getCountTotalServices();
    }

    /**
     * Gets sum paid revenue for the Admin module.
     *
     * @return the operation result
     */
    public BigDecimal getSumPaidRevenue() {
        return dashboardDAO.getSumPaidRevenue();
    }

    /**
     * Gets count completed appointments for the Admin module.
     *
     * @return the operation result
     */
    public int getCountCompletedAppointments() {
        return dashboardDAO.getCountCompletedAppointments();
    }

    /**
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() {
        return dashboardDAO.getTodayClinicQueueStatus();
    }

    /**
     * Gets today schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodaySchedules() {
        return dashboardDAO.getTodaySchedules();
    }

    /**
     * Gets today total visits for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayTotalVisits() {
        return dashboardDAO.getTodayTotalVisits();
    }

    /**
     * Gets today waiting patients for the Admin module.
     *
     * @return the operation result
     */
    public int getTodayWaitingPatients() {
        return dashboardDAO.getTodayWaitingPatients();
    }

    /**
     * Gets today patient flow by time slot for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayPatientFlowByTimeSlot() {
        return dashboardDAO.getTodayPatientFlowByTimeSlot();
    }

    /**
     * Gets today revenue by service type for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayRevenueByServiceType() {
        return dashboardDAO.getTodayRevenueByServiceType();
    }

    /**
     * Gets today appointment status distribution for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointmentStatusDistribution() {
        return dashboardDAO.getTodayAppointmentStatusDistribution();
    }

    /**
     * Gets dashboard revenue series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardRevenueSeries(String granularity) {
        return dashboardDAO.getDashboardRevenueSeries(granularity);
    }

    /**
     * Gets dashboard visit series for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDashboardVisitSeries(String granularity) {
        return dashboardDAO.getDashboardVisitSeries(granularity);
    }

    /**
     * Gets quick accounts for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickAccounts(String filter) {
        String status = (filter == null || filter.isBlank() || "all".equalsIgnoreCase(filter)) ? null : filter;
        return dashboardDAO.getStaffAccountsQuick(status, 50);
    }

    /**
     * Gets quick revenue for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickRevenue() {
        return dashboardDAO.getRecentPaidInvoicesToday(10);
    }

    /**
     * Gets quick services for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickServices() {
        return dashboardDAO.getMedicalServices(null, null, null);
    }

    /**
     * Gets quick appointments for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getQuickAppointments() {
        return dashboardDAO.getCompletedAppointmentsTodayQuick(50);
    }
}

/**
 * Builds report series and report detail models for Admin screens.
 */
class AdminReportService {
    private final AdminReportDAO reportDAO = new AdminReportDAO();

    /**
     * Gets revenue series for the Admin module.
     *
     * @return the operation result
     */
    public List<ReportSeriesDTO> getRevenueSeries(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) {
        return toSeries(reportDAO.getRevenueReport(granularity, year, month, day, startDate, endDate));
    }

    /**
     * Gets visit series for the Admin module.
     *
     * @return the operation result
     */
    public List<ReportSeriesDTO> getVisitSeries(String granularity, Integer year, Integer month, Integer day, LocalDate startDate, LocalDate endDate) {
        return toSeries(reportDAO.getVisitReport(granularity, year, month, day, startDate, endDate));
    }

    /**
     * Gets report detail by period for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getReportDetailByPeriod(String period) {
        return reportDAO.getReportDetailByPeriod(period);
    }

    /**
     * Gets invoice items by invoice id for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getInvoiceItemsByInvoiceId(String invoiceId) {
        return reportDAO.getInvoiceItemsByInvoiceId(invoiceId);
    }

    /**
     * Handles refresh report read models for the Admin module.
     */
    public void refreshReportReadModels() {
        reportDAO.markLateWaitingAppointmentsAsNoShow();
    }

    /**
     * Handles to series for the Admin module.
     *
     * @return the operation result
     */
    private List<ReportSeriesDTO> toSeries(List<Map<String, Object>> rows) {
        List<ReportSeriesDTO> result = new ArrayList<>();
        for (Map<String, Object> row : rows) {
            String period = row.get("periodLabel") == null ? "" : String.valueOf(row.get("periodLabel"));
            Object rawValue = row.get("metricValue");
            BigDecimal value = rawValue instanceof BigDecimal ? (BigDecimal) rawValue : new BigDecimal(String.valueOf(rawValue == null ? 0 : rawValue));
            result.add(new ReportSeriesDTO(period, value));
        }
        return result;
    }
}
