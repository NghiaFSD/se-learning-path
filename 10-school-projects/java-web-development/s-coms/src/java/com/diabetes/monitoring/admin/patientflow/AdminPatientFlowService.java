package com.diabetes.monitoring.admin.patientflow;

import java.util.List;
import java.util.Map;

/**
 * Provides appointment workflow and emergency routing use cases.
 */
public class AdminPatientFlowService {
    private final AdminAppointmentWorkflowService appointmentService = new AdminAppointmentWorkflowService();
    private final AdminEmergencyRoutingService emergencyService = new AdminEmergencyRoutingService();

    /**
     * Handles check in appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean checkInAppointment(int appointmentId) { return appointmentService.checkIn(appointmentId); }
    /**
     * Handles start appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean startAppointment(int appointmentId) { return appointmentService.start(appointmentId); }
    /**
     * Handles complete appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean completeAppointment(int appointmentId) { return appointmentService.complete(appointmentId); }
    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     *
     * @return the operation result
     */
    public int markLateWaitingAppointmentsAsNoShow() { return appointmentService.refreshWaitingStates(); }
    /**
     * Gets doctor queue detail today for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorQueueDetailToday(int doctorId) { return appointmentService.getDoctorQueueDetailToday(doctorId); }
    /**
     * Gets today appointments for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointments() { return appointmentService.getTodayAppointments(); }
    /**
     * Gets today waiting details for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayWaitingDetails() { return appointmentService.getTodayWaitingDetails(); }
    /**
     * Gets appointments by schedule for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAppointmentsBySchedule(int scheduleId) { return appointmentService.getAppointmentsBySchedule(scheduleId); }
    /**
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() { return appointmentService.getTodayClinicQueueStatus(); }

    /**
     * Handles prepare exception routing for the Admin module.
     */
    public void prepareExceptionRouting() { emergencyService.loadExceptionQueue(null); }
    /**
     * Gets exception queue for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getExceptionQueue(Integer doctorId) { return emergencyService.loadExceptionQueue(doctorId); }
    /**
     * Gets emergency candidate doctors for appointment for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getEmergencyCandidateDoctorsForAppointment(int appointmentId, Integer excludeDoctorId) { return emergencyService.getEmergencyCandidateDoctorsForAppointment(appointmentId, excludeDoctorId); }
    /**
     * Handles reassign appointment to doctor for the Admin module.
     *
     * @return the operation result
     */
    public boolean reassignAppointmentToDoctor(int appointmentId, int targetDoctorId) { return emergencyService.reassignAppointmentToDoctor(appointmentId, targetDoctorId); }
}

/**
 * Applies business rules for appointment state transitions.
 */
class AdminAppointmentWorkflowService {
    private final AdminAppointmentDAO appointmentDAO = new AdminAppointmentDAO();

    /**
     * Handles refresh waiting states for the Admin module.
     *
     * @return the operation result
     */
    public int refreshWaitingStates() {
        return appointmentDAO.markLateWaitingAppointmentsAsNoShow();
    }

    /**
     * Handles check in for the Admin module.
     *
     * @return the operation result
     */
    public boolean checkIn(int appointmentId) {
        return appointmentDAO.checkInAppointment(appointmentId);
    }

    /**
     * Handles start for the Admin module.
     *
     * @return the operation result
     */
    public boolean start(int appointmentId) {
        return appointmentDAO.startAppointment(appointmentId);
    }

    /**
     * Handles complete for the Admin module.
     *
     * @return the operation result
     */
    public boolean complete(int appointmentId) {
        return appointmentDAO.completeAppointment(appointmentId);
    }

    /**
     * Gets doctor queue detail today for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorQueueDetailToday(int doctorId) {
        return appointmentDAO.getDoctorQueueDetailToday(doctorId);
    }

    /**
     * Gets today appointments for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointments() {
        return appointmentDAO.getTodayAppointments();
    }

    /**
     * Gets today waiting details for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayWaitingDetails() {
        return appointmentDAO.getTodayWaitingDetails();
    }

    /**
     * Gets appointments by schedule for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAppointmentsBySchedule(int scheduleId) {
        return appointmentDAO.getAppointmentsBySchedule(scheduleId);
    }

    /**
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() {
        return appointmentDAO.getTodayClinicQueueStatus();
    }
}

/**
 * Applies business rules for emergency doctor reassignment.
 */
class AdminEmergencyRoutingService {
    private final AdminEmergencyRoutingDAO emergencyRoutingDAO = new AdminEmergencyRoutingDAO();

    /**
     * Loads exception queue data for the Admin UI.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> loadExceptionQueue(Integer doctorId) {
        emergencyRoutingDAO.markLateWaitingAppointmentsAsNoShow();
        return emergencyRoutingDAO.getExceptionQueue(doctorId);
    }

    /**
     * Gets emergency candidate doctors for appointment for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getEmergencyCandidateDoctorsForAppointment(int appointmentId, Integer excludeDoctorId) {
        return emergencyRoutingDAO.getEmergencyCandidateDoctorsForAppointment(appointmentId, excludeDoctorId);
    }

    /**
     * Handles reassign appointment to doctor for the Admin module.
     *
     * @return the operation result
     */
    public boolean reassignAppointmentToDoctor(int appointmentId, int targetDoctorId) {
        return emergencyRoutingDAO.reassignAppointmentToDoctor(appointmentId, targetDoctorId);
    }
}
