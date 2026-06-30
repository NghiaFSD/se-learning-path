package com.diabetes.monitoring.admin.scheduling;

import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

/**
 * Validates Admin schedule constraints before persistence.
 */
public final class AdminScheduleConstraintValidator {
    public static final int MAX_PATIENTS_HARD_CEILING = 50;
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm");

    /**
     * Prevents instantiation of the AdminScheduleConstraintValidator utility class.
     */
    private AdminScheduleConstraintValidator() {
    }

    /**
     * Validates max patients before Admin processing continues.
     *
     * @return the operation result
     */
    public static String validateMaxPatients(int maxPatients) {
        if (maxPatients <= 0) {
            return "max_patients phải lớn hơn 0.";
        }
        if (maxPatients > MAX_PATIENTS_HARD_CEILING) {
            return "max_patients vượt quá giới hạn cho phép.";
        }
        return null;
    }

    /**
     * Validates online quota before Admin processing continues.
     *
     * @return the operation result
     */
    public static String validateOnlineQuota(Integer onlineQuota, int maxPatients) {
        if (onlineQuota == null) {
            return null;
        }
        if (onlineQuota < 0) {
            return "online_quota không được âm.";
        }
        if (onlineQuota > maxPatients) {
            return "online_quota không được vượt quá max_patients.";
        }
        return null;
    }

    /**
     * Validates time slot before Admin processing continues.
     *
     * @return the operation result
     */
    public static String validateTimeSlot(String timeSlot) {
        String normalized = normalizeTimeSlot(timeSlot);
        if (normalized == null) {
            return "time_slot không hợp lệ.";
        }
        return null;
    }

    /**
     * Normalizes time slot for consistent Admin processing.
     *
     * @return the operation result
     */
    public static String normalizeTimeSlot(String timeSlot) {
        if (timeSlot == null || timeSlot.isBlank()) {
            return null;
        }
        String normalized = timeSlot.trim();
        if (!normalized.matches("\\d{2}:\\d{2}-\\d{2}:\\d{2}")) {
            return null;
        }
        try {
            String[] parts = normalized.split("-");
            LocalTime start = LocalTime.parse(parts[0], TIME_FORMATTER);
            LocalTime end = LocalTime.parse(parts[1], TIME_FORMATTER);
            if (!start.isBefore(end)) {
                return null;
            }
            return start.format(TIME_FORMATTER) + "-" + end.format(TIME_FORMATTER);
        } catch (Exception ex) {
            return null;
        }
    }

    /**
     * Validates doctor daily limit before Admin processing continues.
     *
     * @return the operation result
     */
    public static String validateDoctorDailyLimit(int scheduleCountForDay) {
        if (scheduleCountForDay >= 2) {
            return "Bác sĩ không thể có quá 2 ca trong một ngày.";
        }
        return null;
    }

    /**
     * Validates no duplicate schedule before Admin processing continues.
     *
     * @return the operation result
     */
    public static String validateNoDuplicateSchedule(boolean duplicateExists) {
        if (duplicateExists) {
            return "Bác sĩ đã có lịch trực cùng ngày và cùng ca.";
        }
        return null;
    }

    /**
     * Validates no overlap before Admin processing continues.
     *
     * @return the operation result
     */
    public static String validateNoOverlap(boolean overlapExists) {
        if (overlapExists) {
            return "Bác sĩ đã có ca trực trùng thời gian trong ngày.";
        }
        return null;
    }

    /**
     * Validates schedule input before Admin processing continues.
     *
     * @return the operation result
     */
    public static String validateScheduleInput(int maxPatients, Integer onlineQuota, String timeSlot) {
        String message = validateMaxPatients(maxPatients);
        if (message != null) {
            return message;
        }
        message = validateOnlineQuota(onlineQuota, maxPatients);
        if (message != null) {
            return message;
        }
        return validateTimeSlot(timeSlot);
    }
}

