package utils;

/**
 * Utility class for string operations and text processing
 */
public class StringUtil {
    
    /**
     * Check if string is empty or null
     * @param str String to check
     * @return true if string is empty or null
     */
    public static boolean isEmpty(String str) {
        return str == null || str.trim().isEmpty();
    }

    /**
     * Check if string is not empty
     * @param str String to check
     * @return true if string is not empty
     */
    public static boolean isNotEmpty(String str) {
        return str != null && !str.trim().isEmpty();
    }

    /**
     * Truncate string to max length with ellipsis
     * @param str String to truncate
     * @param maxLength Maximum length
     * @return Truncated string
     */
    public static String truncate(String str, int maxLength) {
        if (isEmpty(str)) {
            return "";
        }
        
        if (str.length() <= maxLength) {
            return str;
        }
        
        return str.substring(0, maxLength - 3) + "...";
    }
    
    /**
     * Convert first letter to uppercase
     * @param str String to capitalize
     * @return Capitalized string
     */
    public static String capitalize(String str) {
        if (isEmpty(str)) {
            return "";
        }
        
        return str.substring(0, 1).toUpperCase() + str.substring(1).toLowerCase();
    }
    
    /**
     * Convert to title case (capitalize each word)
     * @param str String to convert
     * @return Title case string
     */
    public static String toTitleCase(String str) {
        if (isEmpty(str)) {
            return "";
        }
        
        StringBuilder result = new StringBuilder();
        String[] words = str.split(" ");
        
        for (String word : words) {
            if (!word.isEmpty()) {
                result.append(word.substring(0, 1).toUpperCase())
                      .append(word.substring(1).toLowerCase())
                      .append(" ");
            }
        }
        
        return result.toString().trim();
    }
    
    /**
     * Remove all whitespace from string
     * @param str String to process
     * @return String without whitespace
     */
    public static String removeWhitespace(String str) {
        if (isEmpty(str)) {
            return "";
        }
        return str.replaceAll("\\s+", "");
    }
    
    /**
     * Replace multiple spaces with single space
     * @param str String to process
     * @return String with single spaces
     */
    public static String normalizeSpaces(String str) {
        if (isEmpty(str)) {
            return "";
        }
        return str.trim().replaceAll(" +", " ");
    }
    
    /**
     * Reverse a string
     * @param str String to reverse
     * @return Reversed string
     */
    public static String reverse(String str) {
        if (isEmpty(str)) {
            return "";
        }
        return new StringBuilder(str).reverse().toString();
    }
    
    /**
     * Extract numbers from string
     * @param str String to process
     * @return String containing only numbers
     */
    public static String extractNumbers(String str) {
        if (isEmpty(str)) {
            return "";
        }
        return str.replaceAll("[^0-9]", "");
    }
    
    /**
     * Extract letters from string
     * @param str String to process
     * @return String containing only letters
     */
    public static String extractLetters(String str) {
        if (isEmpty(str)) {
            return "";
        }
        return str.replaceAll("[^a-zA-ZÀ-Ỿ]", "");
    }
    
    /**
     * Generate slug from string (for URLs)
     * @param str String to slugify
     * @return URL-friendly slug
     */
    public static String toSlug(String str) {
        if (isEmpty(str)) {
            return "";
        }
        
        return str.toLowerCase()
                  .trim()
                  .replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
                  .replaceAll("[èéẹẻẽêềếệểễ]", "e")
                  .replaceAll("[ìíĩịỉ]", "i")
                  .replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
                  .replaceAll("[ùúụủũưừứựửữ]", "u")
                  .replaceAll("[ỳýỵỷỹ]", "y")
                  .replaceAll("[đ]", "d")
                  .replaceAll("[^a-z0-9]+", "-")
                  .replaceAll("-+", "-")
                  .replaceAll("^-|-$", "");
    }
    
    /**
     * Mask sensitive data (e.g., email, phone)
     * @param str String to mask
     * @param visibleChars Number of visible characters from start
     * @return Masked string
     */
    public static String maskSensitiveData(String str, int visibleChars) {
        if (isEmpty(str) || str.length() <= visibleChars) {
            return str;
        }
        
        StringBuilder masked = new StringBuilder();
        masked.append(str.substring(0, visibleChars));
        for (int i = visibleChars; i < str.length(); i++) {
            masked.append("*");
        }
        
        return masked.toString();
    }
    
    /**
     * Join array of strings with separator
     * @param separator Separator string
     * @param strings Strings to join
     * @return Joined string
     */
    public static String join(String separator, String... strings) {
        if (strings == null || strings.length == 0) {
            return "";
        }
        
        return String.join(separator, strings);
    }
}
