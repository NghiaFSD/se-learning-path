package config;

/**
 * Database configuration - separate from source code
 * Load từ environment variables hoặc system properties
 */
public class DBConfig {

    // Database connection parameters
    private static final String DB_SERVER = getEnv("DB_SERVER", "localhost");
    private static final String DB_PORT = getEnv("DB_PORT", "1433");
    private static final String DB_NAME = getEnv("DB_NAME", "BookStoreDB");
    private static final String DB_USER = getEnv("DB_USER", "sa");
    private static final String DB_PASSWORD = getEnv("DB_PASSWORD", "123");

    /**
     * Get JDBC connection string
     */
    public static String getConnectionString() {
        return String.format(
                "jdbc:sqlserver://%s:%s;databaseName=%s;encrypt=true;trustServerCertificate=true",
                DB_SERVER, DB_PORT, DB_NAME);
    }

    /**
     * Get database username
     */
    public static String getUsername() {
        return DB_USER;
    }

    /**
     * Get database password
     */
    public static String getPassword() {
        return DB_PASSWORD;
    }

    /**
     * Helper method to get environment variable with fallback
     */
    private static String getEnv(String key, String defaultValue) {
        String value = System.getenv(key);
        if (value != null && !value.isEmpty()) {
            return value;
        }

        // Fallback to system property
        value = System.getProperty(key);
        if (value != null && !value.isEmpty()) {
            return value;
        }

        return defaultValue;
    }
}
