package utils;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.temporal.ChronoUnit;

/**
 * Utility class for date and time operations
 */
public class DateUtil {
    
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy");
    private static final DateTimeFormatter DATETIME_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
    private static final DateTimeFormatter TIME_FORMATTER = DateTimeFormatter.ofPattern("HH:mm:ss");
    
    /**
     * Get current date as LocalDate
     * @return Current date
     */
    public static LocalDate getCurrentDate() {
        return LocalDate.now();
    }
    
    /**
     * Get current date and time as LocalDateTime
     * @return Current date and time
     */
    public static LocalDateTime getCurrentDateTime() {
        return LocalDateTime.now();
    }
    
    /**
     * Format date to Vietnamese format (dd/MM/yyyy)
     * @param date Date to format
     * @return Formatted date string
     */
    public static String formatDate(LocalDate date) {
        if (date == null) {
            return "";
        }
        return date.format(DATE_FORMATTER);
    }
    
    /**
     * Format date and time to Vietnamese format (dd/MM/yyyy HH:mm:ss)
     * @param dateTime DateTime to format
     * @return Formatted date time string
     */
    public static String formatDateTime(LocalDateTime dateTime) {
        if (dateTime == null) {
            return "";
        }
        return dateTime.format(DATETIME_FORMATTER);
    }
    
    /**
     * Format time to HH:mm:ss format
     * @param dateTime DateTime to extract time from
     * @return Formatted time string
     */
    public static String formatTime(LocalDateTime dateTime) {
        if (dateTime == null) {
            return "";
        }
        return dateTime.format(TIME_FORMATTER);
    }
    
    /**
     * Parse date string from Vietnamese format (dd/MM/yyyy)
     * @param dateString Date string in format dd/MM/yyyy
     * @return Parsed LocalDate
     */
    public static LocalDate parseDate(String dateString) {
        if (dateString == null || dateString.trim().isEmpty()) {
            return null;
        }
        try {
            return LocalDate.parse(dateString, DATE_FORMATTER);
        } catch (Exception e) {
            return null;
        }
    }
    
    /**
     * Check if date is today
     * @param date Date to check
     * @return true if date is today
     */
    public static boolean isToday(LocalDate date) {
        if (date == null) {
            return false;
        }
        return date.equals(LocalDate.now());
    }
    
    /**
     * Check if date is in the past
     * @param date Date to check
     * @return true if date is in the past
     */
    public static boolean isPast(LocalDate date) {
        if (date == null) {
            return false;
        }
        return date.isBefore(LocalDate.now());
    }
    
    /**
     * Check if date is in the future
     * @param date Date to check
     * @return true if date is in the future
     */
    public static boolean isFuture(LocalDate date) {
        if (date == null) {
            return false;
        }
        return date.isAfter(LocalDate.now());
    }
    
    /**
     * Get number of days between two dates
     * @param from Start date
     * @param to End date
     * @return Number of days
     */
    public static long daysBetween(LocalDate from, LocalDate to) {
        if (from == null || to == null) {
            return 0;
        }
        return ChronoUnit.DAYS.between(from, to);
    }
    
    /**
     * Add days to a date
     * @param date Base date
     * @param days Number of days to add
     * @return New date
     */
    public static LocalDate addDays(LocalDate date, int days) {
        if (date == null) {
            return null;
        }
        return date.plusDays(days);
    }
    
    /**
     * Subtract days from a date
     * @param date Base date
     * @param days Number of days to subtract
     * @return New date
     */
    public static LocalDate subtractDays(LocalDate date, int days) {
        if (date == null) {
            return null;
        }
        return date.minusDays(days);
    }
    
    /**
     * Get month name in Vietnamese
     * @param monthNumber Month number (1-12)
     * @return Vietnamese month name
     */
    public static String getVietnameseMonthName(int monthNumber) {
        String[] months = {
            "Tháng 1", "Tháng 2", "Tháng 3", "Tháng 4", "Tháng 5", "Tháng 6",
            "Tháng 7", "Tháng 8", "Tháng 9", "Tháng 10", "Tháng 11", "Tháng 12"
        };
        
        if (monthNumber < 1 || monthNumber > 12) {
            return "";
        }
        
        return months[monthNumber - 1];
    }
    
    /**
     * Get relative time string (e.g., "2 hours ago")
     * @param dateTime DateTime to convert
     * @return Relative time string in Vietnamese
     */
    public static String getRelativeTime(LocalDateTime dateTime) {
        if (dateTime == null) {
            return "";
        }
        
        LocalDateTime now = LocalDateTime.now();
        long minutesAgo = ChronoUnit.MINUTES.between(dateTime, now);
        long hoursAgo = ChronoUnit.HOURS.between(dateTime, now);
        long daysAgo = ChronoUnit.DAYS.between(dateTime, now);
        
        if (minutesAgo < 1) {
            return "Vừa xong";
        } else if (minutesAgo < 60) {
            return minutesAgo + " phút trước";
        } else if (hoursAgo < 24) {
            return hoursAgo + " giờ trước";
        } else if (daysAgo < 7) {
            return daysAgo + " ngày trước";
        } else {
            return formatDateTime(dateTime);
        }
    }
}
