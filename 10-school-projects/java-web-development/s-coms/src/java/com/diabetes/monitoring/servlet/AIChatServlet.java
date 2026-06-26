package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.DatabaseConnection;
import com.diabetes.monitoring.util.GeminiIntegration;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AIChatServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AIChatServlet.class.getName());
    private final GeminiIntegration geminiIntegration = new GeminiIntegration();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String message = request.getParameter("message");
        User currentUser = (User) request.getSession().getAttribute("currentUser");
        String userName = (currentUser != null) ? currentUser.getFullName() : "Guest";
        Integer patientId = findPatientId(currentUser);
        String currentHealthContext = patientId != null ? getCurrentHealthContext(patientId) : "Patient database context: Guest user, no saved patient data.";
        String conversationHistory = patientId != null ? getConversationHistory(patientId) : "";
        String promptWithContext = "User Name: " + userName
                + "\nPatient ID: " + (patientId != null ? patientId : "Unknown")
                + "\nSaved health data:\n" + currentHealthContext
                + "\nPrevious conversation:\n" + conversationHistory
                + "\nCurrent message: " + message
                + "\nInstruction: Continue the conversation using previous information. If lab test indicators are missing, ask for diabetes-related symptoms and return symptoms in healthData.symptoms.";
        String aiReply = geminiIntegration.getChatResponse(promptWithContext);

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        try (PrintWriter out = response.getWriter()) {
            String cleanReply = aiReply.trim();
            String jsonReply;

            if (cleanReply.startsWith("{") && cleanReply.endsWith("}")) {
                jsonReply = cleanReply;
            } else {
                String escapedMsg = cleanReply.replace("\\", "\\\\")
                                             .replace("\"", "\\\"")
                                             .replace("\n", "\\n")
                                             .replace("\r", "");
                jsonReply = "{\"reply\": \"" + escapedMsg + "\", \"healthData\": {\"hba1c\":0, \"bmi\":0, \"tg\":0, \"hdl\":0, \"symptoms\":\"\"}}";
            }
            if (patientId != null) {
                saveAiState(patientId, message, jsonReply);
                jsonReply = mergeHealthSummary(patientId, jsonReply);
            }
            out.print(jsonReply);
        }
    }

    private Integer findPatientId(User user) {
        if (user == null || user.getEmail() == null) return null;
        String sql = "SELECT patient_id FROM Patient WHERE email = ?";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, user.getEmail());
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt("patient_id");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return null;
    }

    private String getCurrentHealthContext(int patientId) {
        StringBuilder context = new StringBuilder();
        String patientSql = "SELECT full_name, date_of_birth, gender, weight, height FROM Patient WHERE patient_id = ?";
        String aiSql = "SELECT TOP 1 symptoms, conversation_history, analysis_time FROM Patient_AI WHERE patient_id = ? ORDER BY analysis_time DESC, patient_ai_id DESC";
        String labSql = "SELECT TOP 1 lt.urea, lt.cr, lt.hba1c, lt.chol, lt.tg, lt.hdl, lt.idl, lt.vldl, lt.bmi, lt.class, mr.visit_date FROM Lab_test lt INNER JOIN Medical_record mr ON lt.record_id = mr.record_id WHERE mr.patient_id = ? ORDER BY mr.visit_date DESC, lt.test_id DESC";
        try (Connection connection = DatabaseConnection.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(patientSql)) {
                statement.setInt(1, patientId);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        context.append("Patient: ").append(nullToEmpty(resultSet.getString("full_name")))
                               .append(", DOB: ").append(nullToEmpty(resultSet.getString("date_of_birth")))
                               .append(", Gender: ").append(nullToEmpty(resultSet.getString("gender")))
                               .append(", Weight: ").append(nullToEmpty(resultSet.getString("weight")))
                               .append(", Height: ").append(nullToEmpty(resultSet.getString("height"))).append("\n");
                    }
                }
            }
            try (PreparedStatement statement = connection.prepareStatement(aiSql)) {
                statement.setInt(1, patientId);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        context.append("Saved AI symptoms: ").append(nullToEmpty(resultSet.getString("symptoms")))
                               .append("\n");
                    }
                }
            }
            try (PreparedStatement statement = connection.prepareStatement(labSql)) {
                statement.setInt(1, patientId);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        context.append("Latest Lab_test: visit_date=").append(nullToEmpty(resultSet.getString("visit_date")))
                               .append(", urea=").append(nullToEmpty(resultSet.getString("urea")))
                               .append(", cr=").append(nullToEmpty(resultSet.getString("cr")))
                               .append(", hba1c=").append(nullToEmpty(resultSet.getString("hba1c")))
                               .append(", chol=").append(nullToEmpty(resultSet.getString("chol")))
                               .append(", tg=").append(nullToEmpty(resultSet.getString("tg")))
                               .append(", hdl=").append(nullToEmpty(resultSet.getString("hdl")))
                               .append(", idl=").append(nullToEmpty(resultSet.getString("idl")))
                               .append(", vldl=").append(nullToEmpty(resultSet.getString("vldl")))
                               .append(", bmi=").append(nullToEmpty(resultSet.getString("bmi")))
                               .append(", class=").append(nullToEmpty(resultSet.getString("class"))).append("\n");
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return context.length() == 0 ? "No saved patient/lab data found." : context.toString();
    }

    private String getConversationHistory(int patientId) {
        String sql = "SELECT TOP 1 conversation_history FROM Patient_AI WHERE patient_id = ? ORDER BY analysis_time DESC, patient_ai_id DESC";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, patientId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    String history = resultSet.getString("conversation_history");
                    if (history != null && history.length() > 3000) {
                        return history.substring(history.length() - 3000);
                    }
                    return nullToEmpty(history);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return "";
    }

    private void saveAiState(int patientId, String userMessage, String aiJson) {
        String oldHistory = getConversationHistory(patientId);
        String reply = extractJsonString(aiJson, "reply");
        String symptoms = extractJsonString(aiJson, "symptoms");
        String newHistory = trimHistory(oldHistory + "\nPatient: " + nullToEmpty(userMessage) + "\nAI: " + reply);
        String sql = "INSERT INTO Patient_AI (patient_id, symptoms, blood_sugar, blood_pressure, conversation_history, analysis_time) VALUES (?, ?, ?, ?, ?, GETDATE())";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, patientId);
            if (symptoms.isEmpty()) statement.setNull(2, java.sql.Types.NVARCHAR); else statement.setString(2, symptoms);
            statement.setNull(3, java.sql.Types.DECIMAL);
            statement.setNull(4, java.sql.Types.VARCHAR);
            statement.setString(5, newHistory);
            statement.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
    }

    private String mergeHealthSummary(int patientId, String aiJson) {
        BigDecimal hba1c = extractJsonDecimal(aiJson, "hba1c");
        BigDecimal bmi = extractJsonDecimal(aiJson, "bmi");
        BigDecimal tg = extractJsonDecimal(aiJson, "tg");
        BigDecimal hdl = extractJsonDecimal(aiJson, "hdl");
        String symptoms = extractJsonString(aiJson, "symptoms");
        String labSql = "SELECT TOP 1 lt.hba1c, lt.bmi, lt.tg, lt.hdl FROM Lab_test lt INNER JOIN Medical_record mr ON lt.record_id = mr.record_id WHERE mr.patient_id = ? ORDER BY mr.visit_date DESC, lt.test_id DESC";
        String aiSql = "SELECT TOP 1 symptoms FROM Patient_AI WHERE patient_id = ? AND symptoms IS NOT NULL AND LTRIM(RTRIM(symptoms)) <> '' ORDER BY analysis_time DESC, patient_ai_id DESC";
        try (Connection connection = DatabaseConnection.getConnection()) {
            try (PreparedStatement statement = connection.prepareStatement(labSql)) {
                statement.setInt(1, patientId);
                try (ResultSet resultSet = statement.executeQuery()) {
                    if (resultSet.next()) {
                        if (isEmptyNumber(hba1c)) hba1c = resultSet.getBigDecimal("hba1c");
                        if (isEmptyNumber(bmi)) bmi = resultSet.getBigDecimal("bmi");
                        if (isEmptyNumber(tg)) tg = resultSet.getBigDecimal("tg");
                        if (isEmptyNumber(hdl)) hdl = resultSet.getBigDecimal("hdl");
                    }
                }
            }
            if (symptoms.isEmpty()) {
                try (PreparedStatement statement = connection.prepareStatement(aiSql)) {
                    statement.setInt(1, patientId);
                    try (ResultSet resultSet = statement.executeQuery()) {
                        if (resultSet.next()) {
                            symptoms = nullToEmpty(resultSet.getString("symptoms"));
                        }
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        String reply = extractJsonString(aiJson, "reply");
        return "{\"reply\":\"" + escapeJson(reply) + "\",\"healthData\":{\"hba1c\":" + numberToJson(hba1c)
                + ",\"bmi\":" + numberToJson(bmi)
                + ",\"tg\":" + numberToJson(tg)
                + ",\"hdl\":" + numberToJson(hdl)
                + ",\"symptoms\":\"" + escapeJson(symptoms) + "\"}}";
    }

    private String extractJsonString(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIndex = json.indexOf(search);
        if (keyIndex == -1) return "";
        int colonIndex = json.indexOf(":", keyIndex);
        int startQuote = json.indexOf("\"", colonIndex + 1);
        if (colonIndex == -1 || startQuote == -1) return "";
        StringBuilder value = new StringBuilder();
        boolean escaped = false;
        for (int i = startQuote + 1; i < json.length(); i++) {
            char c = json.charAt(i);
            if (escaped) {
                value.append(c);
                escaped = false;
            } else if (c == '\\') {
                escaped = true;
            } else if (c == '"') {
                break;
            } else {
                value.append(c);
            }
        }
        return value.toString().trim();
    }

    private BigDecimal extractJsonDecimal(String json, String key) {
        String search = "\"" + key + "\"";
        int keyIndex = json.indexOf(search);
        if (keyIndex == -1) return null;
        int colonIndex = json.indexOf(":", keyIndex);
        if (colonIndex == -1) return null;
        int start = colonIndex + 1;
        while (start < json.length() && Character.isWhitespace(json.charAt(start))) start++;
        int end = start;
        while (end < json.length() && "-0123456789.".indexOf(json.charAt(end)) >= 0) end++;
        try {
            return new BigDecimal(json.substring(start, end));
        } catch (Exception e) {
            return null;
        }
    }

    private String trimHistory(String history) {
        if (history == null) return "";
        return history.length() > 4000 ? history.substring(history.length() - 4000) : history;
    }

    private boolean isEmptyNumber(BigDecimal value) {
        return value == null || value.compareTo(BigDecimal.ZERO) == 0;
    }

    private String numberToJson(BigDecimal value) {
        if (value == null) return "0";
        return value.stripTrailingZeros().toPlainString();
    }

    private String escapeJson(String text) {
        if (text == null) return "";
        return text.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }

    private String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}

