package utils;

/**
 * Utility class for input validation and data sanitization
 */
public class ValidationUtil {

     public static boolean isValidEmail(String email) {
          if (email == null || email.trim().isEmpty()) {
               return false;
          }
          String emailRegex = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$";
          return email.matches(emailRegex);
     }

     public static boolean isValidUsername(String username) {
          if (username == null || username.trim().isEmpty()) {
               return false;
          }
          String usernameRegex = "^[a-zA-Z0-9_]{3,20}$";
          return username.matches(usernameRegex);
     }

     public static boolean isValidPassword(String password) {
          if (password == null || password.length() < 8) {
               return false;
          }

          boolean hasUpper = password.matches(".*[A-Z].*");
          boolean hasLower = password.matches(".*[a-z].*");
          boolean hasDigit = password.matches(".*\\d.*");

          return hasUpper && hasLower && hasDigit;
     }

     public static boolean isValidPhoneNumber(String phone) {
          if (phone == null || phone.trim().isEmpty()) {
               return false;
          }
          String phoneRegex = "^0[1-9]\\d{8,9}$";
          String cleanPhone = phone.replaceAll("[\\s-]", "");
          return cleanPhone.matches(phoneRegex);
     }

     public static boolean isValidUrl(String url) {
          if (url == null || url.trim().isEmpty()) {
               return false;
          }
          try {
               new java.net.URL(url);
               return true;
          } catch (java.net.MalformedURLException e) {
               return false;
          }
     }

     public static boolean isNumeric(String value) {
          if (value == null || value.trim().isEmpty()) {
               return false;
          }
          try {
               Double.parseDouble(value);
               return true;
          } catch (NumberFormatException e) {
               return false;
          }
     }

     public static boolean isPositiveNumber(String value) {
          if (!isNumeric(value)) {
               return false;
          }
          return Double.parseDouble(value) > 0;
     }

     public static boolean isPositiveInteger(String value) {
          if (value == null || value.trim().isEmpty()) {
               return false;
          }
          try {
               int num = Integer.parseInt(value);
               return num > 0;
          } catch (NumberFormatException e) {
               return false;
          }
     }

     public static boolean isNotEmpty(String input) {
          return input != null && !input.trim().isEmpty();
     }

     public static String sanitizeInput(String input) {
          if (input == null) {
               return "";
          }

          return input
                    .replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'", "&#x27;")
                    .replace("/", "&#x2F;");
     }

     public static String sanitizeSqlInput(String input) {
          if (input == null) {
               return "";
          }

          return input.replace("'", "''")
                    .replace("\\", "\\\\");
     }

     public static String limitLength(String input, int maxLength) {
          if (input == null) {
               return "";
          }

          String trimmed = input.trim();
          if (trimmed.length() > maxLength) {
               return trimmed.substring(0, maxLength);
          }

          return trimmed;
     }

     public static boolean isValidPrice(String price) {
          if (!isPositiveNumber(price)) {
               return false;
          }

          double priceValue = Double.parseDouble(price);
          return priceValue > 0 && priceValue < 1_000_000_000;
     }

     public static boolean isValidQuantity(String quantity) {
          if (!isPositiveInteger(quantity)) {
               return false;
          }

          int qty = Integer.parseInt(quantity);
          return qty >= 1 && qty <= 999;
     }

     public static boolean isValidBookId(String bookId) {
          return isPositiveInteger(bookId);
     }

     public static boolean isValidCategoryId(String categoryId) {
          if (categoryId == null || categoryId.trim().isEmpty()) {
               return false;
          }

          try {
               int id = Integer.parseInt(categoryId);
               return id >= 0;
          } catch (NumberFormatException e) {
               return false;
          }
     }
}
