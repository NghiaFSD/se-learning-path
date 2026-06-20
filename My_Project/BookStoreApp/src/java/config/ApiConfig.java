package config;

/**
 * API configuration - load từ environment variables
 * Không lưu sensitive data trong source code
 */
public class ApiConfig {

    /**
     * Get Google Gemini API Key
     * Load từ environment variable GEMINI_API_KEY
     */
    public static String getGeminiApiKey() {
        String key = System.getenv("GEMINI_API_KEY");

        if (key != null && !key.isEmpty()) {
            return key;
        }

        // Fallback to system property
        key = System.getProperty("gemini.api.key");

        if (key != null && !key.isEmpty()) {
            return key;
        }

        // Nếu chưa set, log warning
        System.err.println("WARNING: GEMINI_API_KEY không được set. Chatbot feature sẽ không hoạt động.");
        return "";
    }

    /**
     * Check if Gemini API is configured
     */
    public static boolean isGeminiConfigured() {
        return !getGeminiApiKey().isEmpty();
    }
}
