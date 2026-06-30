package com.diabetes.monitoring.admin.scheduling;

import com.diabetes.monitoring.admin.common.AdminRepository;

import java.sql.Date;
import java.util.List;
import java.util.Map;

/**
 * Facade over manual and AI scheduling persistence operations.
 */
public class AdminSchedulingDAO {
    private final AdminScheduleDAO scheduleDAO = new AdminScheduleDAO();
    private final AdminAiSchedulingDAO aiSchedulingDAO = new AdminAiSchedulingDAO();

    /**
     * Gets doctors for schedule for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorsForSchedule() { return scheduleDAO.getDoctorsForSchedule(); }
    /**
     * Gets schedule departments for the Admin module.
     *
     * @return the operation result
     */
    public List<String> getScheduleDepartments() { return scheduleDAO.getScheduleDepartments(); }
    /**
     * Gets doctor schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorSchedules(String department, String doctorName, Date workDate) { return scheduleDAO.getDoctorSchedules(department, doctorName, workDate); }
    /**
     * Gets doctor schedule by id for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getDoctorScheduleById(int scheduleId) { return scheduleDAO.getDoctorScheduleById(scheduleId); }
    /**
     * Gets appointments by schedule for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAppointmentsBySchedule(int scheduleId) { return scheduleDAO.getAppointmentsBySchedule(scheduleId); }
    /**
     * Creates doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean createDoctorSchedule(int doctorId, Date workDate, String timeSlot, int maxPatients, Integer onlineQuota, String status) { return scheduleDAO.createDoctorSchedule(doctorId, workDate, timeSlot, maxPatients, onlineQuota, status); }
    /**
     * Updates doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateDoctorSchedule(int scheduleId, int doctorId, String timeSlot, int maxPatients, String status) { return scheduleDAO.updateDoctorSchedule(scheduleId, doctorId, timeSlot, maxPatients, status); }
    /**
     * Updates online quota for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateOnlineQuota(int scheduleId, int onlineQuota) { return scheduleDAO.updateOnlineQuota(scheduleId, onlineQuota); }
    /**
     * Deletes doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteDoctorSchedule(int scheduleId) { return scheduleDAO.deleteDoctorSchedule(scheduleId); }
    /**
     * Handles cancel doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean cancelDoctorSchedule(int scheduleId) { return scheduleDAO.cancelDoctorSchedule(scheduleId); }
    /**
     * Handles transfer doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean transferDoctorSchedule(int scheduleId, int targetDoctorId) { return scheduleDAO.transferDoctorSchedule(scheduleId, targetDoctorId); }
    /**
     * Handles refresh doctor schedule status from appointments for the Admin module.
     *
     * @return the operation result
     */
    public int refreshDoctorScheduleStatusFromAppointments() { return scheduleDAO.refreshDoctorScheduleStatusFromAppointments(); }
    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     */
    public void markLateWaitingAppointmentsAsNoShow() { scheduleDAO.markLateWaitingAppointmentsAsNoShow(); }
    /**
     * Normalizes future completed appointments for consistent Admin processing.
     */
    public void normalizeFutureCompletedAppointments() { scheduleDAO.normalizeFutureCompletedAppointments(); }
    /**
     * Handles auto advance appointment workflow demo for the Admin module.
     */
    public void autoAdvanceAppointmentWorkflowDemo() { scheduleDAO.autoAdvanceAppointmentWorkflowDemo(); }
    /**
     * Handles consume schedule validation message for the Admin module.
     *
     * @return the operation result
     */
    public String consumeScheduleValidationMessage() { return scheduleDAO.consumeScheduleValidationMessage(); }
    /**
     * Gets available doctors for emergency for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAvailableDoctorsForEmergency(String department, Integer excludeDoctorId) { return scheduleDAO.getAvailableDoctorsForEmergency(department, excludeDoctorId); }
    /**
     * Gets all active doctors for emergency for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAllActiveDoctorsForEmergency(Integer excludeDoctorId) { return scheduleDAO.getAllActiveDoctorsForEmergency(excludeDoctorId); }

    /**
     * Gets doctors for ai scheduling for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorsForAiScheduling(Date startDate, Date endDate) { return aiSchedulingDAO.getDoctorsForAiScheduling(startDate, endDate); }
    /**
     * Creates gemini schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> createGeminiSchedules(List<Map<String, Object>> assignments, int maxPatients, int maxSchedules) { return aiSchedulingDAO.createGeminiSchedules(assignments, maxPatients, maxSchedules); }
    /**
     * Creates ai optimized schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> createAiOptimizedSchedules(List<Date> targetDates, List<Map<String, String>> shiftsPerDay, String department, int maxPatients, int maxSchedules) { return aiSchedulingDAO.createAiOptimizedSchedules(targetDates, shiftsPerDay, department, maxPatients, maxSchedules); }
    /**
     * Creates doctor schedule from ai for the Admin module.
     *
     * @return the operation result
     */
    public boolean createDoctorScheduleFromAi(int doctorId, Date workDate, String timeSlot, int maxPatients, Integer onlineQuota, String status) { return aiSchedulingDAO.createDoctorSchedule(doctorId, workDate, timeSlot, maxPatients, onlineQuota, status); }
}

/**
 * Loads and mutates doctor schedule data through the shared Admin repository.
 */
class AdminScheduleDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Gets doctors for schedule for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorsForSchedule() {
        return repository.getDoctorsForSchedule();
    }

    /**
     * Gets schedule departments for the Admin module.
     *
     * @return the operation result
     */
    public List<String> getScheduleDepartments() {
        return repository.getScheduleDepartments();
    }

    /**
     * Gets doctor schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorSchedules(String department, String doctorName, Date workDate) {
        return repository.getDoctorSchedules(department, doctorName, workDate);
    }

    /**
     * Gets doctor schedule by id for the Admin module.
     *
     * @return the operation result
     */
    public Map<String, Object> getDoctorScheduleById(int scheduleId) {
        return repository.getDoctorScheduleById(scheduleId);
    }

    /**
     * Gets appointments by schedule for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAppointmentsBySchedule(int scheduleId) {
        return repository.getAppointmentsBySchedule(scheduleId);
    }

    /**
     * Creates doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean createDoctorSchedule(int doctorId, Date workDate, String timeSlot, int maxPatients, Integer onlineQuota, String status) {
        return repository.createDoctorSchedule(doctorId, workDate, timeSlot, maxPatients, onlineQuota, status);
    }

    /**
     * Updates doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateDoctorSchedule(int scheduleId, int doctorId, String timeSlot, int maxPatients, String status) {
        return repository.updateDoctorSchedule(scheduleId, doctorId, timeSlot, maxPatients, status);
    }

    /**
     * Updates online quota for the Admin module.
     *
     * @return the operation result
     */
    public boolean updateOnlineQuota(int scheduleId, int onlineQuota) {
        return repository.updateOnlineQuota(scheduleId, onlineQuota);
    }

    /**
     * Deletes doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean deleteDoctorSchedule(int scheduleId) {
        return repository.deleteDoctorSchedule(scheduleId);
    }

    /**
     * Handles cancel doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean cancelDoctorSchedule(int scheduleId) {
        return repository.cancelDoctorSchedule(scheduleId);
    }

    /**
     * Handles transfer doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean transferDoctorSchedule(int scheduleId, int targetDoctorId) {
        return repository.transferDoctorSchedule(scheduleId, targetDoctorId);
    }

    /**
     * Handles refresh doctor schedule status from appointments for the Admin module.
     *
     * @return the operation result
     */
    public int refreshDoctorScheduleStatusFromAppointments() {
        return repository.refreshDoctorScheduleStatusFromAppointments();
    }

    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     */
    public void markLateWaitingAppointmentsAsNoShow() {
        repository.markLateWaitingAppointmentsAsNoShow();
    }

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
     * Handles consume schedule validation message for the Admin module.
     *
     * @return the operation result
     */
    public String consumeScheduleValidationMessage() {
        return repository.consumeScheduleValidationMessage();
    }

    /**
     * Gets available doctors for emergency for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAvailableDoctorsForEmergency(String department, Integer excludeDoctorId) {
        return repository.getAvailableDoctorsForEmergency(department, excludeDoctorId);
    }

    /**
     * Gets all active doctors for emergency for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAllActiveDoctorsForEmergency(Integer excludeDoctorId) {
        return repository.getAllActiveDoctorsForEmergency(excludeDoctorId);
    }
}

/**
 * Persists AI-generated schedule assignments.
 */
class AdminAiSchedulingDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Gets doctors for ai scheduling for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorsForAiScheduling(java.sql.Date startDate, java.sql.Date endDate) {
        return repository.getDoctorsForAiScheduling(startDate, endDate);
    }

    /**
     * Creates gemini schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> createGeminiSchedules(List<Map<String, Object>> assignments, int maxPatients, int maxSchedules) {
        return repository.createGeminiSchedules(assignments, maxPatients, maxSchedules);
    }

    /**
     * Creates ai optimized schedules for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> createAiOptimizedSchedules(List<java.sql.Date> targetDates,
            List<Map<String, String>> shiftsPerDay,
            String department,
            int maxPatients,
            int maxSchedules) {
        return repository.createAiOptimizedSchedules(targetDates, shiftsPerDay, department, maxPatients, maxSchedules);
    }

    /**
     * Creates doctor schedule for the Admin module.
     *
     * @return the operation result
     */
    public boolean createDoctorSchedule(int doctorId, java.sql.Date workDate, String timeSlot, int maxPatients, Integer onlineQuota, String status) {
        return repository.createDoctorSchedule(doctorId, workDate, timeSlot, maxPatients, onlineQuota, status);
    }

    /**
     * Handles consume schedule validation message for the Admin module.
     *
     * @return the operation result
     */
    public String consumeScheduleValidationMessage() {
        return repository.consumeScheduleValidationMessage();
    }
}
