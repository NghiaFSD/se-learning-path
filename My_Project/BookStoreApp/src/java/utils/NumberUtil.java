package utils;

/**
 * Utility class for number and currency formatting
 */
public class NumberUtil {
    
    private static final String CURRENCY_SYMBOL = "đ";
    
    /**
     * Format number to currency (Vietnamese Dong)
     * @param amount Amount to format
     * @return Formatted currency string (e.g., "150,000đ")
     */
    public static String formatCurrency(double amount) {
        return String.format("%,.0f%s", amount, CURRENCY_SYMBOL);
    }
    
    /**
     * Format number with thousand separators
     * @param number Number to format
     * @return Formatted string (e.g., "1,234,567")
     */
    public static String formatNumber(long number) {
        return String.format("%,d", number);
    }
    
    /**
     * Format double with thousand separators
     * @param number Number to format
     * @param decimalPlaces Number of decimal places
     * @return Formatted string
     */
    public static String formatDouble(double number, int decimalPlaces) {
        return String.format("%," + decimalPlaces + "f", number);
    }
    
    /**
     * Round number to specified decimal places
     * @param value Number to round
     * @param places Number of decimal places
     * @return Rounded number
     */
    public static double round(double value, int places) {
        if (places < 0) throw new IllegalArgumentException();
        
        long factor = (long) Math.pow(10, places);
        return (double) Math.round(value * factor) / factor;
    }
    
    /**
     * Calculate percentage
     * @param value Current value
     * @param total Total value
     * @return Percentage (0-100)
     */
    public static double calculatePercentage(double value, double total) {
        if (total == 0) {
            return 0;
        }
        return (value / total) * 100;
    }
    
    /**
     * Calculate discount
     * @param originalPrice Original price
     * @param discountPercent Discount percentage (0-100)
     * @return Discount amount
     */
    public static double calculateDiscount(double originalPrice, double discountPercent) {
        return originalPrice * (discountPercent / 100);
    }
    
    /**
     * Calculate final price after discount
     * @param originalPrice Original price
     * @param discountPercent Discount percentage (0-100)
     * @return Final price
     */
    public static double calculateFinalPrice(double originalPrice, double discountPercent) {
        return originalPrice - calculateDiscount(originalPrice, discountPercent);
    }
    
    /**
     * Format large numbers with abbreviation (e.g., 1.5K, 2.3M)
     * @param number Number to format
     * @return Abbreviated number string
     */
    public static String formatShortNumber(long number) {
        if (number < 1000) {
            return String.valueOf(number);
        }
        
        int exp = (int) (Math.log(number) / Math.log(1000));
        char pre = "KMGTPE".charAt(exp - 1);
        return String.format("%.1f%c", number / Math.pow(1000, exp), pre);
    }
    
    /**
     * Check if number is between min and max
     * @param number Number to check
     * @param min Minimum value (inclusive)
     * @param max Maximum value (inclusive)
     * @return true if number is in range
     */
    public static boolean inRange(double number, double min, double max) {
        return number >= min && number <= max;
    }
    
    /**
     * Parse string to double safely
     * @param value String value to parse
     * @param defaultValue Default value if parsing fails
     * @return Parsed double or default value
     */
    public static double parseDouble(String value, double defaultValue) {
        try {
            return Double.parseDouble(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    /**
     * Parse string to integer safely
     * @param value String value to parse
     * @param defaultValue Default value if parsing fails
     * @return Parsed integer or default value
     */
    public static int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
    
    /**
     * Check if number is even
     * @param number Number to check
     * @return true if number is even
     */
    public static boolean isEven(int number) {
        return number % 2 == 0;
    }
    
    /**
     * Check if number is odd
     * @param number Number to check
     * @return true if number is odd
     */
    public static boolean isOdd(int number) {
        return number % 2 != 0;
    }
}
