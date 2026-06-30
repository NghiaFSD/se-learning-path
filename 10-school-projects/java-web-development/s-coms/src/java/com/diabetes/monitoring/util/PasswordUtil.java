package com.diabetes.monitoring.util;

import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.spec.InvalidKeySpecException;
import java.util.Base64;

public class PasswordUtil {
    private static final String PBKDF2_ALGORITHM = "PBKDF2WithHmacSHA256";
    private static final int PBKDF2_ITERATIONS = 100_000;
    private static final int SALT_LENGTH = 16; // bytes
    private static final int DERIVED_KEY_LENGTH = 32; // bytes

    private static final SecureRandom RANDOM = new SecureRandom();

    // Format: pbkdf2$iterations$base64(salt)$base64(hash)
    public static String hashPassword(String password) {
        if (password == null) password = "";
        byte[] salt = new byte[SALT_LENGTH];
        RANDOM.nextBytes(salt);
        byte[] derived = pbkdf2(password.toCharArray(), salt, PBKDF2_ITERATIONS, DERIVED_KEY_LENGTH);
        return String.format("pbkdf2$%d$%s$%s",
                PBKDF2_ITERATIONS,
                Base64.getEncoder().encodeToString(salt),
                Base64.getEncoder().encodeToString(derived));
    }

    public static boolean matches(String rawPassword, String storedPassword) {
        if (storedPassword == null) return false;
        if (storedPassword.startsWith("pbkdf2$")) {
            String[] parts = storedPassword.split("\\$", 4);
            if (parts.length != 4) return false;
            int iterations = Integer.parseInt(parts[1]);
            byte[] salt = Base64.getDecoder().decode(parts[2]);
            byte[] hash = Base64.getDecoder().decode(parts[3]);
            byte[] derived = pbkdf2(rawPassword.toCharArray(), salt, iterations, hash.length);
            return constantTimeEquals(hash, derived);
        }
        // Legacy SHA-256 hex (64 chars)
        if (isLegacySha256(storedPassword)) {
            String sha = sha256Hex(rawPassword);
            return sha.equalsIgnoreCase(storedPassword);
        }
        // Fallback: compare plaintext (least secure)
        return rawPassword.equals(storedPassword);
    }

    public static boolean needsRehash(String storedPassword) {
        if (storedPassword == null) return true;
        if (storedPassword.startsWith("pbkdf2$")) {
            String[] parts = storedPassword.split("\\$", 4);
            if (parts.length != 4) return true;
            int iterations = Integer.parseInt(parts[1]);
            return iterations < PBKDF2_ITERATIONS;
        }
        // anything not PBKDF2 should be rehashed
        return true;
    }

    private static byte[] pbkdf2(char[] password, byte[] salt, int iterations, int dkLen) {
        try {
            PBEKeySpec spec = new PBEKeySpec(password, salt, iterations, dkLen * 8);
            SecretKeyFactory skf = SecretKeyFactory.getInstance(PBKDF2_ALGORITHM);
            return skf.generateSecret(spec).getEncoded();
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new RuntimeException("Failed to derive key", e);
        }
    }

    private static boolean constantTimeEquals(byte[] a, byte[] b) {
        if (a.length != b.length) return false;
        int result = 0;
        for (int i = 0; i < a.length; i++) result |= a[i] ^ b[i];
        return result == 0;
    }

    private static String sha256Hex(String input) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] d = md.digest(input.getBytes(java.nio.charset.StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : d) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private static boolean isLegacySha256(String value) {
        return value != null && value.matches("[0-9a-fA-F]{64}");
    }

    public static boolean isPBKDF2(String value) {
        return value != null && value.startsWith("pbkdf2$");
    }
}
