package utils;

import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utility class for security operations
 */
public class SecurityUtil {
    
    private static final int SALT_LENGTH = 16;

    /**
     * Generate random salt for hashing
     * @return Random salt as Base64 string
     */
    public static String generateSalt() {
        SecureRandom random = new SecureRandom();
        byte[] salt = new byte[SALT_LENGTH];
        random.nextBytes(salt);
        return Base64.getEncoder().encodeToString(salt);
    }

    /**
     * Generate SHA-256 hash
     * @param input Input string to hash
     * @return SHA-256 hash as hexadecimal string
     */
    public static String hashSHA256(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(input.getBytes());
            return bytesToHex(hash);
        } catch (Exception e) {
            throw new RuntimeException("Error hashing string", e);
        }
    }
    
    /**
     * Generate MD5 hash (not recommended for passwords)
     * @param input Input string to hash
     * @return MD5 hash as hexadecimal string
     */
    public static String hashMD5(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        
        try {
            MessageDigest digest = MessageDigest.getInstance("MD5");
            byte[] hash = digest.digest(input.getBytes());
            return bytesToHex(hash);
        } catch (Exception e) {
            throw new RuntimeException("Error hashing string", e);
        }
    }
    
    /**
     * Convert byte array to hexadecimal string
     * @param bytes Byte array
     * @return Hex string
     */
    private static String bytesToHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder();
        for (byte b : bytes) {
            sb.append(String.format("%02x", b));
        }
        return sb.toString();
    }
    
    /**
     * Generate random token (32 bytes)
     * @return Random token as Base64 string
     */
    public static String generateToken() {
        return generateToken(32);
    }
    
    /**
     * Generate random token
     * @param length Token length in bytes
     * @return Random token as Base64 string
     */
    public static String generateToken(int length) {
        SecureRandom random = new SecureRandom();
        byte[] token = new byte[length];
        random.nextBytes(token);
        return Base64.getEncoder().encodeToString(token).replaceAll("[^a-zA-Z0-9]", "");
    }
    
    /**
     * Generate OTP (One-Time Password) - 6 digits
     * @return OTP string
     */
    public static String generateOTP() {
        return generateOTP(6);
    }
    
    /**
     * Generate OTP (One-Time Password)
     * @param length OTP length
     * @return OTP string
     */
    public static String generateOTP(int length) {
        SecureRandom random = new SecureRandom();
        StringBuilder otp = new StringBuilder();
        
        for (int i = 0; i < length; i++) {
            otp.append(random.nextInt(10));
        }
        
        return otp.toString();
    }
    
    /**
     * Escape HTML to prevent XSS
     * @param input Input string
     * @return Escaped string
     */
    public static String escapeHtml(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        
        return input
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#x27;");
    }
    
    /**
     * Escape JavaScript to prevent XSS
     * @param input Input string
     * @return Escaped string
     */
    public static String escapeJavaScript(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        
        return input
            .replace("\\", "\\\\")
            .replace("\"", "\\\"")
            .replace("'", "\\'")
            .replace("/", "\\/")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");
    }
    
    /**
     * Escape SQL to prevent SQL Injection
     * @param input Input string
     * @return Escaped string
     */
    public static String escapeSql(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        
        return input.replace("'", "''")
                   .replace("\\", "\\\\");
    }
    
    /**
     * Base64 encode string
     * @param input Input string
     * @return Base64 encoded string
     */
    public static String encodeBase64(String input) {
        if (input == null || input.isEmpty()) {
            return "";
        }
        
        return Base64.getEncoder().encodeToString(input.getBytes());
    }
    
    /**
     * Base64 decode string
     * @param encoded Base64 encoded string
     * @return Decoded string
     */
    public static String decodeBase64(String encoded) {
        if (encoded == null || encoded.isEmpty()) {
            return "";
        }
        
        try {
            byte[] decodedBytes = Base64.getDecoder().decode(encoded);
            return new String(decodedBytes);
        } catch (IllegalArgumentException e) {
            return "";
        }
    }
    
    /**
     * Check password complexity
     * @param password Password to check
     * @return true if password meets complexity requirements
     */
    public static boolean isPasswordComplex(String password) {
        if (password == null || password.length() < 8) {
            return false;
        }
        
        boolean hasUppercase = password.matches(".*[A-Z].*");
        boolean hasLowercase = password.matches(".*[a-z].*");
        boolean hasDigit = password.matches(".*\\d.*");
        boolean hasSpecialChar = password.matches(".*[!@#$%^&*()_+\\-=\\[\\]{};':'\",.<>?/].*");
        
        return hasUppercase && hasLowercase && hasDigit && hasSpecialChar;
    }
}
