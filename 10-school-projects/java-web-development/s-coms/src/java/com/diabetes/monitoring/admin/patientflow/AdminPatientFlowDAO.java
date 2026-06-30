package com.diabetes.monitoring.admin.patientflow;

import com.diabetes.monitoring.admin.common.AdminRepository;

import java.util.List;
import java.util.Map;

/**
 * Facade over appointment workflow and emergency routing persistence operations.
 */
public class AdminPatientFlowDAO {
    private final AdminAppointmentDAO appointmentDAO = new AdminAppointmentDAO();
    private final AdminEmergencyRoutingDAO emergencyDAO = new AdminEmergencyRoutingDAO();

    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     *
     * @return the operation result
     */
    public int markLateWaitingAppointmentsAsNoShow() { return appointmentDAO.markLateWaitingAppointmentsAsNoShow(); }
    /**
     * Handles check in appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean checkInAppointment(int appointmentId) { return appointmentDAO.checkInAppointment(appointmentId); }
    /**
     * Handles start appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean startAppointment(int appointmentId) { return appointmentDAO.startAppointment(appointmentId); }
    /**
     * Handles complete appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean completeAppointment(int appointmentId) { return appointmentDAO.completeAppointment(appointmentId); }
    /**
     * Gets doctor queue detail today for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorQueueDetailToday(int doctorId) { return appointmentDAO.getDoctorQueueDetailToday(doctorId); }
    /**
     * Gets today appointments for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointments() { return appointmentDAO.getTodayAppointments(); }
    /**
     * Gets today waiting details for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayWaitingDetails() { return appointmentDAO.getTodayWaitingDetails(); }
    /**
     * Gets appointments by schedule for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getAppointmentsBySchedule(int scheduleId) { return appointmentDAO.getAppointmentsBySchedule(scheduleId); }
    /**
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() { return appointmentDAO.getTodayClinicQueueStatus(); }

    /**
     * Gets exception queue for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getExceptionQueue(Integer doctorId) { return emergencyDAO.getExceptionQueue(doctorId); }
    /**
     * Gets emergency candidate doctors for appointment for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getEmergencyCandidateDoctorsForAppointment(int appointmentId, Integer excludeDoctorId) { return emergencyDAO.getEmergencyCandidateDoctorsForAppointment(appointmentId, excludeDoctorId); }
    /**
     * Handles reassign appointment to doctor for the Admin module.
     *
     * @return the operation result
     */
    public boolean reassignAppointmentToDoctor(int appointmentId, int targetDoctorId) { return emergencyDAO.reassignAppointmentToDoctor(appointmentId, targetDoctorId); }
    /**
     * Handles mark late waiting appointments as no show for emergency for the Admin module.
     */
    public void markLateWaitingAppointmentsAsNoShowForEmergency() { emergencyDAO.markLateWaitingAppointmentsAsNoShow(); }
}

/**
 * Loads and mutates appointment workflow data through the shared Admin repository.
 */
class AdminAppointmentDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     *
     * @return the operation result
     */
    public int markLateWaitingAppointmentsAsNoShow() {
        return repository.markLateWaitingAppointmentsAsNoShow();
    }

    /**
     * Handles check in appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean checkInAppointment(int appointmentId) {
        return repository.checkInAppointment(appointmentId);
    }

    /**
     * Handles start appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean startAppointment(int appointmentId) {
        return repository.startAppointment(appointmentId);
    }

    /**
     * Handles complete appointment for the Admin module.
     *
     * @return the operation result
     */
    public boolean completeAppointment(int appointmentId) {
        return repository.completeAppointment(appointmentId);
    }

    /**
     * Gets doctor queue detail today for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getDoctorQueueDetailToday(int doctorId) {
        return repository.getDoctorQueueDetailToday(doctorId);
    }

    /**
     * Gets today appointments for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayAppointments() {
        return repository.getTodayAppointments();
    }

    /**
     * Gets today waiting details for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayWaitingDetails() {
        return repository.getTodayWaitingDetails();
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
     * Gets today clinic queue status for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getTodayClinicQueueStatus() {
        return repository.getTodayClinicQueueStatus();
    }
}

/**
 * Loads and mutates emergency routing data through the shared Admin repository.
 */
class AdminEmergencyRoutingDAO {
    private final AdminRepository repository = new AdminRepository();

    /**
     * Gets exception queue for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getExceptionQueue(Integer doctorId) {
        return repository.getExceptionQueue(doctorId);
    }

    /**
     * Gets emergency candidate doctors for appointment for the Admin module.
     *
     * @return the operation result
     */
    public List<Map<String, Object>> getEmergencyCandidateDoctorsForAppointment(int appointmentId, Integer excludeDoctorId) {
        return repository.getEmergencyCandidateDoctorsForAppointment(appointmentId, excludeDoctorId);
    }

    /**
     * Handles reassign appointment to doctor for the Admin module.
     *
     * @return the operation result
     */
    public boolean reassignAppointmentToDoctor(int appointmentId, int targetDoctorId) {
        return repository.reassignAppointmentToDoctor(appointmentId, targetDoctorId);
    }

    /**
     * Handles mark late waiting appointments as no show for the Admin module.
     */
    public void markLateWaitingAppointmentsAsNoShow() {
        repository.markLateWaitingAppointmentsAsNoShow();
    }
}
