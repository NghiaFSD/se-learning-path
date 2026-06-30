package com.diabetes.monitoring.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DatabaseConnection {
    private static final Logger LOGGER = Logger.getLogger(DatabaseConnection.class.getName());
    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        java.util.Properties props = new java.util.Properties();
        // Try to load from classpath first
        java.io.InputStream in = DatabaseConnection.class.getClassLoader().getResourceAsStream("db.properties");
        if (in != null) {
            try (java.io.InputStream is = in) {
                props.load(is);
            } catch (java.io.IOException e) {
                LOGGER.log(Level.SEVERE, "Failed to load db.properties from classpath", e);
                throw new IllegalStateException("Unable to load db.properties from classpath", e);
            }
        } else {
            // Fallback: try to read from filesystem (project src/ or project root)
            java.io.File f1 = new java.io.File("src/db.properties");
            java.io.File f2 = new java.io.File("db.properties");
            java.io.File found = null;
            if (f1.exists() && f1.isFile()) found = f1;
            else if (f2.exists() && f2.isFile()) found = f2;

            if (found != null) {
                try (java.io.FileInputStream fis = new java.io.FileInputStream(found)) {
                    props.load(fis);
                    LOGGER.log(Level.INFO, "Loaded db.properties from file system: {0}", found.getAbsolutePath());
                } catch (java.io.IOException e) {
                    LOGGER.log(Level.SEVERE, "Failed to load db.properties from file system", e);
                    throw new IllegalStateException("Unable to load db.properties from file system", e);
                }
            } else {
                LOGGER.log(Level.SEVERE, "db.properties not found on classpath or filesystem. Looked in classpath, src/db.properties and db.properties.");
                throw new IllegalStateException("db.properties not found on classpath or filesystem");
            }
        }

        String url = props.getProperty("db.url");
        String user = props.getProperty("db.user");
        String password = props.getProperty("db.password");

        if (url == null || url.isBlank() || user == null || user.isBlank()) {
            LOGGER.log(Level.SEVERE, "db.url or db.user not set in db.properties");
            throw new IllegalStateException("db.url and db.user must be set in db.properties");
        }

        URL = url;
        USER = user;
        PASSWORD = password == null ? "" : password;

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "SQL Server JDBC driver is unavailable", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
