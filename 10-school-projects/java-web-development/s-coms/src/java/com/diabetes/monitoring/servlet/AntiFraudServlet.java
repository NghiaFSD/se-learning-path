package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.util.DatabaseConnection;
import com.diabetes.monitoring.util.CsrfUtil;
import com.diabetes.monitoring.util.GeminiConfigUtil;
import com.diabetes.monitoring.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.SocketTimeoutException;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Anti-Fraud Servlet - AI Giám sát hành vi & Phát hiện gian lận dữ liệu
 * URL Mapping: /admin-anti-fraud
 * 
 * Luồng xử lý:
 * 1. Admin gửi request quét hệ thống
 * 2. Lấy TOP 20 bản ghi mới nhất từ Healthy_Record (PreparedStatement)
 * 3. Gửi dữ liệu qua Gemini AI để phân tích spam/gian lận
 * 4. Trả về JSON: {has_anomaly, anomalies[]}
 * 5. Hỗ trợ ban patient qua action=banPatient
 */
public class AntiFraudServlet extends HttpServlet {
    
    private static final Logger LOGGER = Logger.getLogger(AntiFraudServlet.class.getName());
    private static final int GEMINI_TIMEOUT_MS = 5000;
    private static final int MAX_API_KEYS_TO_TRY = 3;
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        // Kiểm tra quyền admin
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            sendJsonError(response, "Unauthorized access", 403);
            return;
        }

        String action = request.getParameter("action");
        
        // Xử lý action analyzeRecord - phân tích chi tiết một hồ sơ cụ thể
        if ("analyzeRecord".equals(action)) {
            analyzeRecordDetail(request, response);
            return;
        }
        
        try (Connection conn = DatabaseConnection.getConnection()) {
            // Bước 1: Lấy TOP 20 bản ghi mới nhất từ Healthy_Record (PreparedStatement - không cộng chuỗi SQL)
            List<HealthRecordData> records = getLatestRecords(conn);
            
            if (records.isEmpty()) {
                sendJsonResponse(response, "{\"has_anomaly\": false, \"anomalies\": [], \"message\": \"Không có dữ liệu để phân tích\"}");
                return;
            }
            
            LOGGER.log(Level.INFO, "Phân tích {0} bản ghi để phát hiện gian lận", records.size());
            
            // Bước 2: Tạo prompt và gọi Gemini AI
            String prompt = createFraudDetectionPrompt(records);
            String geminiResponse;
            boolean isFallbackMode = false;
            String fallbackMessage = null;
            
            try {
                geminiResponse = callGeminiAPI(prompt);
                geminiResponse = normalizeFraudResponse(records, geminiResponse);
            } catch (IOException e) {
                LOGGER.log(Level.WARNING, "Gemini anti-fraud unavailable, switching to heuristic fallback: {0}", e.getMessage());
                geminiResponse = generateHeuristicFallbackResponse(records, e.getMessage());
                isFallbackMode = true;
                fallbackMessage = buildQuotaExceededMessage(e.getMessage());
            }
            
            // Bước 3: Trả về kết quả JSON cho frontend
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            
            if (isFallbackMode && geminiResponse.endsWith("}")) {
                geminiResponse = geminiResponse.substring(0, geminiResponse.length() - 1) + 
                    ", \"fallback_mode\": true, \"message\": \"" +
                    escapeJson(fallbackMessage != null ? fallbackMessage : buildQuotaExceededMessage(null)) + "\"}";
            }
            
            response.getWriter().write(geminiResponse);
            
            LOGGER.log(Level.INFO, "Hoàn thành quét gian lận" + (isFallbackMode ? " (HEURISTIC FALLBACK)" : ""));
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi database khi quét gian lận", e);
            sendJsonError(response, "Lỗi database: " + e.getMessage(), 500);
        } catch (IOException e) {
            LOGGER.log(Level.SEVERE, "Lỗi API hoặc kết nối", e);
            sendJsonError(response, "Lỗi kết nối API: " + e.getMessage(), 503);
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Lỗi xử lý quét gian lận", e);
            sendJsonError(response, "Lỗi hệ thống: " + e.getMessage(), 500);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        // Kiểm tra quyền admin
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            sendJsonError(response, "Unauthorized access", 403);
            return;
        }

        if (!CsrfUtil.isValid(request)) {
            sendJsonError(response, "Invalid CSRF token", 403);
            return;
        }
        
        String action = request.getParameter("action");
        LOGGER.log(Level.INFO, "doPost called - action: ''{0}'', patientId: ''{1}''", 
            new Object[]{action, request.getParameter("patientId")});

        if ("banPatient".equals(action)) {
            banPatient(request, response);
        } else {
            LOGGER.log(Level.WARNING, "Invalid action received: ''{0}''", action);
            sendJsonError(response, "Invalid action: " + action, 400);
        }
    }
    
    /**
     * Lấy TOP 20 bản ghi mới nhất từ Healthy_Record (PreparedStatement - không cộng chuỗi SQL)
     * Lọc bỏ patient đã bị ban (status = 'banned')
     * Thêm email, hba1c, bmi để hiển thị đầy đủ thông tin
     */
    private List<HealthRecordData> getLatestRecords(Connection conn) throws SQLException {
        List<HealthRecordData> records = new ArrayList<>();

        // JOIN với Patient và Account để lọc bỏ patient bị banned và lấy email
        String sql = "SELECT TOP 20 h.health_record_id, h.patient_id, h.other_information, h.created_at, " +
                     "h.hba1c, h.bmi, a.email " +
                     "FROM Healthy_Record h " +
                     "JOIN Patient p ON h.patient_id = p.patient_id " +
                     "JOIN Account a ON p.account_id = a.account_id " +
                     "WHERE a.status != 'banned' " +
                     "ORDER BY h.created_at DESC";

        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                HealthRecordData record = new HealthRecordData();
                record.healthRecordId = rs.getInt("health_record_id");
                record.patientId = rs.getInt("patient_id");
                record.otherInformation = rs.getString("other_information");
                record.createdAt = rs.getTimestamp("created_at");
                record.hba1c = rs.getDouble("hba1c");
                record.bmi = rs.getDouble("bmi");
                record.email = rs.getString("email");
                records.add(record);
            }
        }

        return records;
    }
    
    /**
     * Tạo prompt cho Gemini AI để phát hiện gian lận/spam
     */
    private String createFraudDetectionPrompt(List<HealthRecordData> records) {
        StringBuilder prompt = new StringBuilder();

        prompt.append("Phat hien gian lan du lieu y te. ");
        prompt.append("Tra ve DUY NHAT JSON hop le theo schema ");
        prompt.append("{\"has_anomaly\":boolean,\"anomalies\":[{\"patient_id\":number,\"record_id\":number,\"reason\":\"string\"}]}. ");
        prompt.append("Khong markdown, khong text thua.\n");
        prompt.append("RECORDS:\n");
        for (HealthRecordData record : records) {
            prompt.append("{\"record_id\":").append(record.healthRecordId)
                  .append(",\"patient_id\":").append(record.patientId)
                  .append(",\"email\":\"").append(record.email != null ? escapeJson(record.email) : "N/A").append("\"")
                  .append(",\"hba1c\":").append(record.hba1c)
                  .append(",\"bmi\":").append(record.bmi)
                  .append(",\"content\":\"").append(escapeJson(record.otherInformation)).append("\"}\n");
        }
        prompt.append("Chi danh dau noi dung spam, vo nghia, pha hoai, keyword nhu asdasd/qwerty/hack/spam/bot/malicious, ");
        prompt.append("hoac chi so 0 kem noi dung bat thuong.");
        
        return prompt.toString();
    }
    
    /**
     * Gọi Gemini API để phân tích gian lận
     */
    private String callGeminiAPI(String prompt) throws IOException {
        String model = GeminiConfigUtil.getAntiFraudModel();
        List<String> apiKeys = limitApiKeys(GeminiConfigUtil.getAntiFraudApiKeys());
        if (apiKeys.isEmpty()) {
            throw new IOException("GEMINI_API_KEY is not configured");
        }

        String escapedPrompt = escapeJson(prompt);
        String requestBody = "{\"contents\":[{\"parts\":[{\"text\":\"" + escapedPrompt + "\"}]}],"
                + "\"generationConfig\":{\"temperature\":0.0,\"maxOutputTokens\":512}}";
        List<String> retryableErrors = new ArrayList<>();
        IOException lastNonQuotaException = null;

        for (int index = 0; index < apiKeys.size(); index++) {
            String apiKey = apiKeys.get(index);
            HttpURLConnection conn = null;
            try {
                URL url = new URL("https://generativelanguage.googleapis.com/v1/models/"
                        + model + ":generateContent?key=" + apiKey);
                conn = (HttpURLConnection) url.openConnection();
                conn.setRequestMethod("POST");
                conn.setRequestProperty("Content-Type", "application/json");
                conn.setRequestProperty("Accept", "application/json");
                conn.setDoOutput(true);
                conn.setConnectTimeout(GEMINI_TIMEOUT_MS);
                conn.setReadTimeout(GEMINI_TIMEOUT_MS);

                try (OutputStream os = conn.getOutputStream()) {
                    byte[] input = requestBody.getBytes(StandardCharsets.UTF_8);
                    os.write(input, 0, input.length);
                }

                int responseCode = conn.getResponseCode();
                if (responseCode == 200) {
                    try (BufferedReader br = new BufferedReader(
                            new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8))) {
                        StringBuilder response = new StringBuilder();
                        String line;
                        while ((line = br.readLine()) != null) {
                            response.append(line);
                        }
                        if (index > 0) {
                            LOGGER.log(Level.INFO, "Gemini anti-fraud succeeded with fallback API key #{0}", index + 1);
                        }
                        return extractJsonFromGeminiResponse(response.toString());
                    }
                }

                String errorBody = readResponseBody(conn);
                if (isRetryableStatus(responseCode)) {
                    retryableErrors.add("HTTP " + responseCode + ": " + compact(errorBody));
                    LOGGER.log(Level.WARNING,
                            "Key số {0} lỗi HTTP {1}, đang tự động chuyển sang thử nghiệm với key dự phòng tiếp theo...",
                            new Object[]{index + 1, responseCode});
                    continue;
                }

                lastNonQuotaException = new IOException("Gemini API error: HTTP " + responseCode + " - " + errorBody);
                LOGGER.log(Level.WARNING, "Gemini anti-fraud failed for key #{0}: HTTP {1}",
                        new Object[]{index + 1, responseCode});
            } catch (SocketTimeoutException e) {
                retryableErrors.add("Timeout after " + GEMINI_TIMEOUT_MS + "ms");
                LOGGER.log(Level.WARNING,
                        "Key số {0} timeout, đang tự động chuyển sang thử nghiệm với key dự phòng tiếp theo...",
                        index + 1);
            } catch (IOException e) {
                lastNonQuotaException = e;
                LOGGER.log(Level.WARNING, "Gemini anti-fraud request failed for key #{0}: {1}",
                        new Object[]{index + 1, e.getMessage()});
            } finally {
                if (conn != null) {
                    conn.disconnect();
                }
            }
        }

        if (!retryableErrors.isEmpty()) {
            throw new IOException(buildRetryableFailureMessage(retryableErrors.get(retryableErrors.size() - 1)));
        }
        if (lastNonQuotaException != null) {
            throw lastNonQuotaException;
        }
        throw new IOException("Gemini anti-fraud service unavailable");
    }

    private String buildQuotaExceededMessage(String rawMessage) {
        String normalized = rawMessage == null ? "" : rawMessage.replaceAll("\\s+", " ").trim();
        if (normalized.contains("limit: 0")) {
            return "Google đang trả quota = 0 cho project của key này trên model "
                    + GeminiConfigUtil.getAntiFraudModel() + ". Hệ thống đang chuyển sang heuristic chống gian lận dự phòng.";
        }
        if (!normalized.isEmpty()) {
            return "Gemini API đang bị giới hạn: " + normalized + " Hệ thống đang chuyển sang heuristic chống gian lận dự phòng.";
        }
        return "Gemini API bị giới hạn (HTTP 429). Hệ thống đang chuyển sang heuristic chống gian lận dự phòng.";
    }

    private String buildRetryableFailureMessage(String rawMessage) {
        String normalized = rawMessage == null ? "" : rawMessage.replaceAll("\\s+", " ").trim().toLowerCase(Locale.ROOT);
        if (normalized.contains("503") || normalized.contains("high demand") || normalized.contains("overloaded")) {
            return "Tất cả API key Gemini anti-fraud đều đang quá tải hoặc trả HTTP 503. Hệ thống đang chuyển sang heuristic chống gian lận dự phòng.";
        }
        if (normalized.contains("429") || normalized.contains("quota") || normalized.contains("limit: 0")) {
            return buildQuotaExceededMessage(rawMessage);
        }
        if (normalized.contains("timeout")) {
            return "Tất cả API key Gemini anti-fraud đều timeout. Hệ thống đang chuyển sang heuristic chống gian lận dự phòng.";
        }
        return "Tất cả API key Gemini anti-fraud đều không khả dụng. Hệ thống đang chuyển sang heuristic chống gian lận dự phòng.";
    }

    private boolean isRetryableStatus(int responseCode) {
        return responseCode == 429 || responseCode == 503;
    }

    private List<String> limitApiKeys(List<String> apiKeys) {
        if (apiKeys == null || apiKeys.isEmpty()) {
            return new ArrayList<>();
        }
        int max = Math.min(apiKeys.size(), MAX_API_KEYS_TO_TRY);
        return new ArrayList<>(apiKeys.subList(0, max));
    }
    
    /**
     * Trích xuất JSON từ response của Gemini
     */
    private String extractJsonFromGeminiResponse(String geminiResponse) {
        try {
            // Tìm text trong response bằng regex
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"text\": \"([^\"]+)");
            java.util.regex.Matcher matcher = pattern.matcher(geminiResponse);
            if (matcher.find()) {
                String text = matcher.group(1)
                    .replace("\\n", "\n")
                    .replace("\\\"", "\"")
                    .replace("\\\\", "\\");
                // Tìm JSON trong text
                int start = text.indexOf("{");
                int end = text.lastIndexOf("}");
                if (start >= 0 && end > start) {
                    return text.substring(start, end + 1);
                }
            }
            
            // Nếu không tìm được theo pattern cũ, thử tìm JSON trực tiếp
            int start = geminiResponse.indexOf("{");
            int end = geminiResponse.lastIndexOf("}");
            if (start >= 0 && end > start) {
                String jsonCandidate = geminiResponse.substring(start, end + 1);
                // Kiểm tra xem có phải JSON hợp lệ không
                if (jsonCandidate.contains("has_anomaly")) {
                    return jsonCandidate;
                }
            }
            
            LOGGER.log(Level.WARNING, "Could not extract JSON from Gemini response");
            return "{\"has_anomaly\": false, \"anomalies\": [], \"error\": \"Không thể phân tích phản hồi từ AI\"}";
            
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Error extracting JSON from Gemini response", e);
            return "{\"has_anomaly\": false, \"anomalies\": [], \"error\": \"Lỗi xử lý phản hồi\"}";
        }
    }
    
    /**
     * Ban patient bằng cách cập nhật status trong bảng Account (PreparedStatement)
     * Lấy account_id từ bảng Patient trước khi update
     */
    private void banPatient(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String patientIdStr = request.getParameter("patientId");
        LOGGER.log(Level.INFO, "Ban patient request received - raw patientId: ''{0}''", patientIdStr);

        if (patientIdStr == null || patientIdStr.isEmpty()) {
            LOGGER.log(Level.WARNING, "Missing patientId parameter");
            sendJsonError(response, "Missing patientId parameter", 400);
            return;
        }

        // Parse patient_id - loại bỏ # và các ký tự không phải số
        String cleanedId = patientIdStr.replaceAll("[^0-9]", "");
        LOGGER.log(Level.INFO, "Cleaned patientId: ''{0}'' (from raw: ''{1}'')", new Object[]{cleanedId, patientIdStr});

        if (cleanedId.isEmpty()) {
            LOGGER.log(Level.WARNING, "Invalid patientId format after cleaning: {0}", patientIdStr);
            sendJsonError(response, "Invalid patientId format: " + patientIdStr, 400);
            return;
        }

        try (Connection conn = DatabaseConnection.getConnection()) {
            int patientId = Integer.parseInt(cleanedId);
            LOGGER.log(Level.INFO, "Parsed patientId: {0}", patientId);

            // Step 1: Lấy account_id từ bảng Patient
            String selectSql = "SELECT account_id FROM Patient WHERE patient_id = ?";
            Integer accountId = null;

            try (PreparedStatement selectStmt = conn.prepareStatement(selectSql)) {
                selectStmt.setInt(1, patientId);
                try (ResultSet rs = selectStmt.executeQuery()) {
                    if (rs.next()) {
                        accountId = rs.getInt("account_id");
                    }
                }
            }

            LOGGER.log(Level.INFO, "Found account_id: {0} for patient_id: {1}", new Object[]{accountId, patientId});

            if (accountId == null || accountId == 0) {
                LOGGER.log(Level.WARNING, "Không tìm thấy patient_id: {0} trong bảng Patient", patientId);
                sendJsonError(response, "Không tìm thấy bệnh nhân với ID " + patientId, 404);
                return;
            }

            // Step 2: Update Account status
            String updateSql = "UPDATE Account SET status = 'banned' WHERE account_id = ?";

            try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                stmt.setInt(1, accountId);
                int rowsAffected = stmt.executeUpdate();

                if (rowsAffected > 0) {
                    LOGGER.log(Level.INFO, "Đã ban patient_id: {0}, account_id: {1}", new Object[]{patientId, accountId});
                    sendJsonResponse(response, "{\"success\": true, \"message\": \"Đã ban bệnh nhân thành công\"}");
                } else {
                    LOGGER.log(Level.WARNING, "Không tìm thấy account_id: {0} trong bảng Account", accountId);
                    sendJsonError(response, "Không tìm thấy tài khoản bệnh nhân", 404);
                }
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Lỗi database khi ban patient", e);
            sendJsonError(response, "Lỗi database: " + e.getMessage(), 500);
        } catch (NumberFormatException e) {
            LOGGER.log(Level.SEVERE, "NumberFormatException for patientId: " + patientIdStr, e);
            sendJsonError(response, "Invalid patientId format: " + patientIdStr, 400);
        }
    }
    
    /**
     * Phân tích chi tiết một hồ sơ cụ thể - gọi từ Modal
     * Trả về lý do phát hiện từ Gemini AI cho một hồ sơ duy nhất
     */
    private void analyzeRecordDetail(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String recordIdStr = request.getParameter("recordId");
        String toxicData = request.getParameter("toxicData");
        
        if (recordIdStr == null || recordIdStr.isEmpty()) {
            sendJsonResponse(response, "{\"reason\": \"Missing recordId parameter\"}");
            return;
        }
        
        // Xây dựng prompt để phân tích chi tiết
        String prompt = buildDetailedAnalysisPrompt(toxicData);
        
        try {
            String geminiResponse = callGeminiAPI(prompt);
            // Trích xuất lý do từ response
            String reason = extractReasonFromResponse(geminiResponse);
            sendJsonResponse(response, "{\"reason\": \"" + escapeJson(reason) + "\"}");
        } catch (IOException e) {
            // Demo mode hoặc fallback
            String defaultReason = generateDefaultAnalysisReason(toxicData);
            sendJsonResponse(response, "{\"reason\": \"" + escapeJson(defaultReason) + "\"}");
        }
    }
    
    /**
     * Xây dựng prompt phân tích chi tiết cho một hồ sơ cụ thể
     */
    private String buildDetailedAnalysisPrompt(String toxicData) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("Hãy phân tích dữ liệu sau để phát hiện liệu đó có phải spam, dữ liệu rác, hoặc hành vi phá hoại.\n\n");
        prompt.append("DỮ LIỆU CẦN PHÂN TÍCH:\n");
        prompt.append("\"").append(toxicData).append("\"\n\n");
        prompt.append("YÊU CẦU:\n");
        prompt.append("- Giải thích bằng tiếng Việt\n");
        prompt.append("- Chỉ ra các dấu hiệu bất thường (ký tự vô nghĩa, từ khóa lạ, pattern lạm dụng)\n");
        prompt.append("- Đánh giá mức độ nguy hiểm\n");
        prompt.append("- Khuyến nghị hành động\n");
        prompt.append("- TRẢ VỀ CHỈNH MỘT ĐOẠN VĂN BẢN (không JSON)\n\n");
        prompt.append("VÍ DỤ RESPONSE:\n");
        prompt.append("'Hệ thống phát hiện chuỗi ký tự vô nghĩa \"asdasd\" lặp lại liên tục, hoàn toàn không mang giá trị lâm sàng...'");
        return prompt.toString();
    }
    
    /**
     * Trích xuất lý do từ response của Gemini
     */
    private String extractReasonFromResponse(String geminiResponse) {
        try {
            // Tìm text trong response
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("\"text\": \"([^\"]+)");
            java.util.regex.Matcher matcher = pattern.matcher(geminiResponse);
            if (matcher.find()) {
                String text = matcher.group(1)
                    .replace("\\n", "\n")
                    .replace("\\\"", "\"")
                    .replace("\\\\", "\\");
                return text.trim();
            }
            
            // Nếu không tìm được, tìm text trực tiếp
            int start = geminiResponse.indexOf("Hệ thống phát hiện");
            if (start >= 0) {
                int end = geminiResponse.indexOf("\"", start + 100);
                if (end > start) {
                    return geminiResponse.substring(start, end).trim();
                }
            }
            
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Error extracting reason from Gemini response", e);
        }
        
        return generateDefaultAnalysisReason("");
    }
    
    /**
     * Tạo lý do phân tích mặc định khi API không khả dụng
     */
    private String generateDefaultAnalysisReason(String toxicData) {
        if (toxicData == null || toxicData.isEmpty()) {
            return "Hệ thống phát hiện dữ liệu bất thường. Khuyến nghị Admin xem xét biện pháp quản lý tài khoản.";
        }
        
        String lowerData = toxicData.toLowerCase();
        
        if (lowerData.contains("asdasd") || lowerData.contains("qwerty")) {
            return "Hệ thống phát hiện chuỗi ký tự vô nghĩa và không có giá trị lâm sàng. Đây là dấu hiệu spam hoặc test. Khuyến nghị thực hiện biện pháp cấm tài khoản vĩnh viễn.";
        }
        
        if (lowerData.contains("hack") || lowerData.contains("destroy")) {
            return "Phát hiện từ khóa tấn công giả lập: 'hack' hoặc 'destroy'. Đây có thể là nội dung phá hoại hệ thống. Khuyến nghị Ban tài khoản ngay lập tức.";
        }
        
        if (lowerData.contains("spam") || lowerData.contains("bot")) {
            return "Phát hiện từ khóa lạm dụng 'spam' hoặc 'bot'. Nội dung này không phù hợp với tiêu chuẩn dữ liệu y tế. Khuyến nghị Ban tài khoản.";
        }
        
        if (toxicData.length() < 5) {
            return "Nội dung quá ngắn (" + toxicData.length() + " ký tự) - không đủ thông tin lâm sàng. Đây có thể là dữ liệu rác hoặc test. Khuyến nghị kiểm tra kỹ.";
        }
        
        return "Hệ thống phát hiện dữ liệu không bình thường: \"" + toxicData + "\". Khuyến nghị Admin xem xét kỹ trước khi quyết định.";
    }
    
    /**
     * Helper: Gửi JSON response
     */
    private void sendJsonResponse(HttpServletResponse response, String json) throws IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.getWriter().write(json);
    }
    
    private String generateHeuristicFallbackResponse(List<HealthRecordData> records, String geminiError) {
        StringBuilder json = new StringBuilder();
        json.append("{\"has_anomaly\": ");
        List<String> anomalies = new ArrayList<>();

        for (HealthRecordData record : records) {
            Suspicion suspicion = analyzeSuspicion(record);
            if (!suspicion.suspicious) {
                continue;
            }
            anomalies.add(buildAnomalyJson(record, suspicion));
        }

        json.append(!anomalies.isEmpty());
        json.append(", \"anomalies\": [");
        for (int i = 0; i < anomalies.size(); i++) {
            if (i > 0) {
                json.append(", ");
            }
            json.append(anomalies.get(i));
        }
        json.append("], \"message\": \"");
        if (anomalies.isEmpty()) {
            json.append(escapeJson("Không phát hiện bản ghi nghi ngờ từ heuristic dự phòng."));
        } else {
            json.append(escapeJson("Phát hiện " + anomalies.size()
                    + " bản ghi bất thường bằng heuristic dự phòng do Gemini không khả dụng."));
        }
        json.append("\", \"heuristic_mode\": true");
        if (geminiError != null && !geminiError.isBlank()) {
            json.append(", \"gemini_error\": \"").append(escapeJson(geminiError)).append("\"");
        }
        json.append("}");

        return json.toString();
    }

    private String normalizeFraudResponse(List<HealthRecordData> records, String geminiResponse) {
        if (geminiResponse == null || geminiResponse.isBlank()) {
            LOGGER.log(Level.WARNING, "Gemini anti-fraud returned empty response, switching to heuristic fallback");
            return generateHeuristicFallbackResponse(records, "Empty Gemini response");
        }

        List<String> heuristicAnomalies = new ArrayList<>();
        for (HealthRecordData record : records) {
            Suspicion suspicion = analyzeSuspicion(record);
            if (suspicion.suspicious) {
                heuristicAnomalies.add(buildAnomalyJson(record, suspicion));
            }
        }

        if (heuristicAnomalies.isEmpty()) {
            return geminiResponse;
        }

        String normalized = geminiResponse.toLowerCase(Locale.ROOT);
        boolean saysNoAnomaly = normalized.contains("\"has_anomaly\": false");
        boolean hasAnomalyArray = normalized.contains("\"anomalies\"");
        boolean containsRecordMarkers = normalized.contains("\"record_id\"") || normalized.contains("\"patient_id\"");

        if (saysNoAnomaly || !hasAnomalyArray || !containsRecordMarkers) {
            LOGGER.log(Level.INFO,
                    "Gemini anti-fraud response did not contain usable anomalies. Using heuristic fallback with {0} suspicious records.",
                    heuristicAnomalies.size());
            return generateHeuristicFallbackResponse(records, "Gemini response missing anomaly details");
        }

        return geminiResponse;
    }

    private Suspicion analyzeSuspicion(HealthRecordData record) {
        Suspicion suspicion = new Suspicion();
        String content = record.otherInformation == null ? "" : record.otherInformation.trim();
        String normalized = content.toLowerCase(Locale.ROOT);
        List<String> reasons = new ArrayList<>();

        if (normalized.isEmpty()) {
            reasons.add("Nội dung hồ sơ trống");
        }
        if (normalized.length() > 0 && normalized.length() < 5) {
            reasons.add("Nội dung quá ngắn, không đủ giá trị lâm sàng");
        }
        if (containsAny(normalized, "asdasd", "qwerty", "hack", "spam", "bot", "malicious", "destroy")) {
            reasons.add("Chứa từ khóa spam/phá hoại hoặc chuỗi vô nghĩa");
        }
        if (hasKeyboardNoise(normalized)) {
            reasons.add("Chuỗi ký tự giống gõ thử bàn phím hoặc lặp vô nghĩa");
        }
        if ((record.hba1c == 0.0 || record.bmi == 0.0) && normalized.length() < 12) {
            reasons.add("Chỉ số lâm sàng bằng 0 kết hợp mô tả bất thường");
        }

        suspicion.suspicious = !reasons.isEmpty();
        suspicion.type = normalized.contains("hack") || normalized.contains("destroy") ? "phá hoại" : "spam";
        suspicion.confidence = reasons.size() >= 3 ? "high" : "medium";
        suspicion.reason = reasons.isEmpty()
                ? "Không phát hiện bất thường rõ rệt"
                : String.join("; ", reasons);
        return suspicion;
    }

    private boolean containsAny(String source, String... keywords) {
        if (source == null || keywords == null) {
            return false;
        }
        for (String keyword : keywords) {
            if (keyword != null && source.contains(keyword)) {
                return true;
            }
        }
        return false;
    }

    private boolean hasKeyboardNoise(String source) {
        if (source == null || source.isEmpty()) {
            return false;
        }
        return source.matches(".*([a-z])\\1{3,}.*")
                || source.matches(".*(1234|abcd|qwer|asdf|zxcv).*")
                || source.replaceAll("[^a-z0-9]", "").length() < source.length() / 2;
    }

    private String buildAnomalyJson(HealthRecordData record, Suspicion suspicion) {
        String originalContent = record.otherInformation == null ? "" : record.otherInformation;
        int previewLength = Math.min(150, originalContent.length());
        String contentPreview = originalContent.substring(0, previewLength);
        if (originalContent.length() > 150) {
            contentPreview += "...";
        }

        return "{\"record_id\": " + record.healthRecordId
                + ", \"patient_id\": " + record.patientId
                + ", \"type\": \"" + escapeJson(suspicion.type) + "\""
                + ", \"content_preview\": \"" + escapeJson(contentPreview) + "\""
                + ", \"reason\": \"" + escapeJson(suspicion.reason) + "\""
                + ", \"email\": \"" + (record.email != null ? escapeJson(record.email) : "N/A") + "\""
                + ", \"hba1c\": " + record.hba1c
                + ", \"bmi\": " + record.bmi
                + ", \"full_content\": \"" + escapeJson(originalContent) + "\""
                + ", \"confidence\": \"" + escapeJson(suspicion.confidence) + "\"}";
    }

    private String readResponseBody(HttpURLConnection conn) {
        if (conn == null || conn.getErrorStream() == null) {
            return "";
        }
        try (BufferedReader br = new BufferedReader(
                new InputStreamReader(conn.getErrorStream(), StandardCharsets.UTF_8))) {
            StringBuilder error = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                error.append(line);
            }
            return error.toString();
        } catch (IOException e) {
            LOGGER.log(Level.FINE, "Failed to read Gemini error body", e);
            return "";
        }
    }

    private String compact(String input) {
        String normalized = input == null ? "" : input.replaceAll("\\s+", " ").trim();
        if (normalized.length() > 220) {
            return normalized.substring(0, 217) + "...";
        }
        return normalized;
    }
    
    /**
     * Helper: Gửi JSON error response - Luôn có has_anomaly để frontend xử lý
     */
    private void sendJsonError(HttpServletResponse response, String message, int statusCode) 
            throws IOException {
        response.setStatus(statusCode);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String jsonError = "{\"has_anomaly\": false, \"anomalies\": [], \"error\":\"" + escapeJson(message) + "\", \"success\": false}";
        response.getWriter().write(jsonError);
    }
    
    /**
     * Escape special characters for JSON string
     */
    private String escapeJson(String input) {
        if (input == null) return "";
        return input.replace("\\", "\\\\")
                   .replace("\"", "\\\"")
                   .replace("\b", "\\b")
                   .replace("\f", "\\f")
                   .replace("\n", "\\n")
                   .replace("\r", "\\r")
                   .replace("\t", "\\t");
    }
    
    /**
     * Inner class đại diện cho dữ liệu Health Record
     */
    public static class HealthRecordData {
        public int healthRecordId;
        public int patientId;
        public String otherInformation;
        public java.sql.Timestamp createdAt;
        public double hba1c;
        public double bmi;
        public String email;
    }

    private static class Suspicion {
        private boolean suspicious;
        private String type;
        private String confidence;
        private String reason;
    }
}
