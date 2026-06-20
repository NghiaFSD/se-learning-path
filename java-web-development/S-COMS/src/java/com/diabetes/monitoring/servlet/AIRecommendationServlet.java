package com.diabetes.monitoring.servlet;

import com.diabetes.monitoring.dao.UserDAO;
import com.diabetes.monitoring.model.User;
import com.diabetes.monitoring.util.GeminiConfigUtil;
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
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * AI Recommendation Servlet - Gợi ý phân bổ hồ sơ cho bác sĩ tối ưu
 * Kết hợp AI Python (phân tích số liệu) và Gemini AI (xử lý ngôn ngữ)
 */
public class AIRecommendationServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(AIRecommendationServlet.class.getName());
    private static final int GEMINI_TIMEOUT_MS = 8000;
    private static final int MAX_API_KEYS_TO_TRY = 5;
    private final UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("currentUser");
        
        // Kiểm tra quyền admin
        if (currentUser == null || !"admin".equals(currentUser.getRole())) {
            sendJsonError(response, "Unauthorized access");
            return;
        }
        
        String recordIdStr = request.getParameter("recordId");
        if (recordIdStr == null || recordIdStr.isEmpty()) {
            sendJsonError(response, "Missing recordId parameter");
            return;
        }
        
        try {
            RecommendationResult result = recommendDoctor(Integer.parseInt(recordIdStr));
            
            // Trả về JSON
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            String jsonResponse = "{\"recommendedDoctorId\":" + result.recommendedDoctorId +
                ", \"doctorName\":\"" + escapeJson(result.doctorName) + "\"" +
                ", \"department\":\"" + escapeJson(result.department) + "\"" +
                ", \"reason\":\"" + escapeJson(result.reason) + "\"" +
                ", \"source\":\"" + escapeJson(result.source) + "\"" +
                ", \"diagnostic\":\"" + escapeJson(result.diagnostic) + "\"}";
            response.getWriter().write(jsonResponse);
            
        } catch (NumberFormatException e) {
            sendJsonError(response, "Invalid recordId format");
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to generate doctor recommendation", e);
            sendJsonError(response, "Error processing request");
        }
    }

    public RecommendationResult recommendDoctor(int recordId) throws IOException {
        Map<String, Object> recommendationContext = userDAO.getHealthRecordRecommendationContext(recordId);
        if (recommendationContext == null) {
            recommendationContext = userDAO.getHealthRecordWithDetails(recordId);
        }

        Map<String, Object> healthRecord = recommendationContext;
        if (healthRecord == null) {
            throw new IOException("Health record not found");
        }

        Map<String, Object> aiAnalysis = extractAIAnalysis(recommendationContext);
        if (aiAnalysis == null) {
            aiAnalysis = userDAO.getAIAnalysisForRecord(recordId);
        }
        if (aiAnalysis == null) {
            aiAnalysis = buildLocalAnalysis(healthRecord);
        }

        List<Map<String, Object>> activeDoctors = userDAO.getActiveDoctorsWithDepartment();
        if (activeDoctors.isEmpty()) {
            throw new IOException("No active doctor available");
        }

        return recommendDoctor(healthRecord, aiAnalysis, activeDoctors);
    }

    public RecommendationResult recommendDoctor(int recordId,
                                                List<Map<String, Object>> activeDoctors) throws IOException {
        Map<String, Object> recommendationContext = userDAO.getHealthRecordRecommendationContext(recordId);
        if (recommendationContext == null) {
            recommendationContext = userDAO.getHealthRecordWithDetails(recordId);
        }

        Map<String, Object> healthRecord = recommendationContext;
        if (healthRecord == null) {
            throw new IOException("Health record not found");
        }

        Map<String, Object> aiAnalysis = extractAIAnalysis(recommendationContext);
        if (aiAnalysis == null) {
            aiAnalysis = userDAO.getAIAnalysisForRecord(recordId);
        }
        if (aiAnalysis == null) {
            aiAnalysis = buildLocalAnalysis(healthRecord);
        }

        if (activeDoctors == null || activeDoctors.isEmpty()) {
            throw new IOException("No active doctor available");
        }

        return recommendDoctor(healthRecord, aiAnalysis, activeDoctors);
    }

    private RecommendationResult recommendDoctor(Map<String, Object> healthRecord,
                                                 Map<String, Object> aiAnalysis,
                                                 List<Map<String, Object>> activeDoctors) throws IOException {
        String prompt = createGeminiPrompt(healthRecord, aiAnalysis, activeDoctors);
        try {
            GeminiInvocationResult invocation = callGeminiAPI(prompt);
            RecommendationResult result = parseGeminiResponse(invocation.jsonResponse, activeDoctors, healthRecord, aiAnalysis);
            if ("Gemini AI".equals(result.source)) {
                result.diagnostic = "Gemini OK | Model: " + invocation.modelUsed + " | Key #" + invocation.keyIndex;
            } else if (result.diagnostic == null || result.diagnostic.isBlank()) {
                result.diagnostic = "Gemini phản hồi thành công nhưng nội dung không dùng được"
                        + " | Model: " + invocation.modelUsed + " | Key #" + invocation.keyIndex;
            } else {
                result.diagnostic = result.diagnostic
                        + " | Model: " + invocation.modelUsed + " | Key #" + invocation.keyIndex;
            }
            return result;
        } catch (IOException e) {
            LOGGER.log(Level.WARNING, "Gemini recommendation unavailable, switching to heuristic fallback: {0}", e.getMessage());
            return buildHeuristicFallbackResult(healthRecord, aiAnalysis, activeDoctors, e.getMessage());
        }
    }
    
    /**
     * Tạo prompt cho Gemini API kết hợp dữ liệu số và chữ
     */
    private String createGeminiPrompt(Map<String, Object> healthRecord, 
                                     Map<String, Object> aiAnalysis,
                                     List<Map<String, Object>> doctors) {
        StringBuilder prompt = new StringBuilder();

        prompt.append("Chon duy nhat 1 bac si phu hop nhat cho ho so benh nhan.\n");
        prompt.append("Chi tra ve DUY NHAT MOT SO NGUYEN la doctor_id hop le trong danh sach VALID_DOCTOR_IDS.\n");
        prompt.append("Khong JSON. Khong markdown. Khong giai thich. Khong chu. Khong ky tu khac ngoai con so.\n");
        prompt.append("Neu khong chac chan, van phai chon 1 doctor_id hop le tu VALID_DOCTOR_IDS.\n");

        prompt.append("BENH_NHAN={");
        prompt.append("\"record_id\":").append(healthRecord.get("health_record_id")).append(",");
        prompt.append("\"patient_name\":\"").append(escapeJson(String.valueOf(healthRecord.get("patient_name")))).append("\",");
        prompt.append("\"symptoms\":\"").append(escapeJson(String.valueOf(healthRecord.get("other_information")))).append("\",");
        prompt.append("\"urea\":").append(healthRecord.get("urea")).append(",");
        prompt.append("\"cr\":").append(healthRecord.get("cr")).append(",");
        prompt.append("\"hba1c\":").append(healthRecord.get("hba1c")).append(",");
        prompt.append("\"bmi\":").append(healthRecord.get("bmi"));

        if (aiAnalysis != null) {
            prompt.append(",\"diabetes_probability\":").append(aiAnalysis.get("diabetes_probability"));
            prompt.append(",\"pre_diabetes_probability\":").append(aiAnalysis.get("pre_diabetes_probability"));
            prompt.append(",\"normal_probability\":").append(aiAnalysis.get("normal_probability"));
        }

        prompt.append("}\n");
        prompt.append("DOCTORS=[");
        boolean firstDoctor = true;
        for (Map<String, Object> doctor : doctors) {
            if (!firstDoctor) {
                prompt.append(",");
            }
            prompt.append("{\"doctor_id\":").append(doctor.get("doctor_id"))
                  .append(",\"full_name\":\"").append(escapeJson(String.valueOf(doctor.get("full_name")))).append("\"")
                  .append(",\"department\":\"").append(escapeJson(String.valueOf(doctor.get("department")))).append("\"")
                  .append(",\"assigned_count\":").append(doctor.get("assigned_count"))
                  .append("}");
            firstDoctor = false;
        }
        prompt.append("]\n");
        prompt.append("VALID_DOCTOR_IDS=[");
        for (int i = 0; i < doctors.size(); i++) {
            if (i > 0) {
                prompt.append(",");
            }
            prompt.append(doctors.get(i).get("doctor_id"));
        }
        prompt.append("]\n");
        prompt.append("Uu tien chuyen khoa phu hop truoc, sau do den tai cong viec thap hon.\n");
        prompt.append("IMPORTANT: output must be exactly one integer from VALID_DOCTOR_IDS.");

        return prompt.toString();
    }
    
    /**
     * Gọi Gemini API
     */
    private GeminiInvocationResult callGeminiAPI(String prompt) throws IOException {
        List<String> modelCandidates = GeminiConfigUtil.getRecommendationModelCandidates();
        List<String> apiKeys = limitApiKeys(GeminiConfigUtil.getRecommendationApiKeys());
        if (apiKeys.isEmpty() || modelCandidates.isEmpty()) {
            throw new IOException("GEMINI_API_KEY is not configured");
        }

        String escapedPrompt = escapeJson(prompt);
        String requestBody = "{\"contents\":[{\"parts\":[{\"text\":\"" + escapedPrompt + "\"}]}],"
                + "\"generationConfig\":{\"temperature\":0.0,\"maxOutputTokens\":512}}";
        List<String> retryableErrors = new ArrayList<>();
        IOException lastNonQuotaException = null;

        for (String model : modelCandidates) {
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
                    conn.setConnectTimeout(GEMINI_TIMEOUT_MS);
                    conn.setReadTimeout(GEMINI_TIMEOUT_MS);
                    conn.setDoOutput(true);

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
                            if (index > 0 || modelCandidates.indexOf(model) > 0) {
                                LOGGER.log(Level.INFO,
                                        "Gemini recommendation succeeded with model {0} and fallback API key #{1}",
                                        new Object[]{model, index + 1});
                            }
                            try {
                                return new GeminiInvocationResult(
                                        extractModelTextFromGeminiResponse(response.toString()),
                                        model,
                                        index + 1);
                            } catch (IOException invalidOutput) {
                                retryableErrors.add("Model " + model + " invalid output: " + compact(invalidOutput.getMessage()));
                                LOGGER.log(Level.WARNING,
                                        "Model {0}, key số {1} trả về nội dung không hợp lệ, đang thử model/key tiếp theo...",
                                        new Object[]{model, index + 1});
                                continue;
                            }
                        }
                    }

                    String errorBody = readResponseBody(conn);
                    if (isRetryableStatus(responseCode) || responseCode == 404) {
                        retryableErrors.add("Model " + model + " / HTTP " + responseCode + ": " + compact(errorBody));
                        LOGGER.log(Level.WARNING,
                                "Model {0}, key số {1} lỗi HTTP {2}, đang thử model/key tiếp theo...",
                                new Object[]{model, index + 1, responseCode});
                        continue;
                    }

                    lastNonQuotaException = new IOException("Gemini API error [" + model + "]: HTTP "
                            + responseCode + " - " + errorBody);
                    LOGGER.log(Level.WARNING, "Gemini recommendation failed for model {0}, key #{1}: HTTP {2}",
                            new Object[]{model, index + 1, responseCode});
                } catch (SocketTimeoutException e) {
                    retryableErrors.add("Model " + model + " timeout after " + GEMINI_TIMEOUT_MS + "ms");
                    LOGGER.log(Level.WARNING,
                            "Model {0}, key số {1} timeout, đang thử model/key tiếp theo...",
                            new Object[]{model, index + 1});
                } catch (IOException e) {
                    lastNonQuotaException = e;
                    LOGGER.log(Level.WARNING, "Gemini recommendation request failed for model {0}, key #{1}: {2}",
                            new Object[]{model, index + 1, e.getMessage()});
                } finally {
                    if (conn != null) {
                        conn.disconnect();
                    }
                }
            }
        }

        if (!retryableErrors.isEmpty()) {
            throw new IOException(buildRetryableFailureMessage(retryableErrors.get(retryableErrors.size() - 1)));
        }
        if (lastNonQuotaException != null) {
            throw lastNonQuotaException;
        }
        throw new IOException("Gemini recommendation service unavailable");
    }
    
    /**
     * Trích xuất phần text trả về từ response của Gemini.
     */
    private String extractModelTextFromGeminiResponse(String geminiResponse) throws IOException {
        try {
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(
                    "\"text\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"");
            java.util.regex.Matcher matcher = pattern.matcher(geminiResponse);
            StringBuilder combinedText = new StringBuilder();
            while (matcher.find()) {
                if (combinedText.length() > 0) {
                    combinedText.append("\n");
                }
                combinedText.append(decodeJsonString(matcher.group(1)));
            }

            String textPayload = combinedText.toString().trim();
            if (!textPayload.isEmpty()) {
                return textPayload;
            }
        } catch (Exception e) {
            LOGGER.log(Level.FINE, "Failed to extract Gemini recommendation text", e);
            throw new IOException("Gemini response parse infrastructure failed: " + compact(e.getMessage()));
        }
        throw new IOException("Gemini response did not contain model text output"
                + " | finishReason=" + extractFinishReason(geminiResponse));
    }
    
    /**
     * Parse doctor_id từ response AI. Nếu AI trả sai định dạng thì chuyển sang fallback.
     */
    private RecommendationResult parseGeminiResponse(String jsonResponse,
                                                     List<Map<String, Object>> doctors,
                                                     Map<String, Object> healthRecord,
                                                     Map<String, Object> aiAnalysis) {
        try {
            int doctorId = extractRecommendedDoctorId(jsonResponse, doctors);
            if (doctorId <= 0) {
                Map<String, Object> doctorByDepartment = findDoctorByDepartmentHint(jsonResponse, "", doctors);
                if (doctorByDepartment != null) {
                    doctorId = ((Number) doctorByDepartment.get("doctor_id")).intValue();
                }
            }
            if (doctorId <= 0) {
                throw new IllegalArgumentException("Missing recommended_doctor_id | payload=" + compact(jsonResponse));
            }
            
            Map<String, Object> selectedDoctor = findDoctorById(doctorId, doctors);
            if (selectedDoctor == null) {
                selectedDoctor = selectFallbackDoctor(healthRecord, aiAnalysis, doctors);
                Integer fallbackDoctorId = selectedDoctor == null ? null : (Integer) selectedDoctor.get("doctor_id");
                doctorId = fallbackDoctorId == null ? 0 : fallbackDoctorId;
                String reason = buildFallbackReason(healthRecord, aiAnalysis, selectedDoctor,
                        "Gemini trả về doctor_id không thuộc danh sách bác sĩ active");

                String fallbackDoctorName = selectedDoctor == null ? "Unknown" : (String) selectedDoctor.get("full_name");
                String fallbackDepartment = selectedDoctor == null ? "Unknown" : (String) selectedDoctor.get("department");
                reason = enrichReasonWithEvidence(reason, healthRecord, aiAnalysis, selectedDoctor);
                return new RecommendationResult(
                        doctorId,
                        fallbackDoctorName,
                        fallbackDepartment,
                        reason,
                        "Local Fallback",
                        "Gemini phản hồi thành công nhưng doctor_id không hợp lệ");
            }

            String doctorName = selectedDoctor == null ? "Unknown" : (String) selectedDoctor.get("full_name");
            String department = selectedDoctor == null ? "Unknown" : (String) selectedDoctor.get("department");
            String reason = buildGeminiAcceptedReason(healthRecord, aiAnalysis, selectedDoctor);
            
            return new RecommendationResult(doctorId, doctorName, department, reason, "Gemini AI", "");
            
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Gemini recommendation response invalid, switching to fallback: {0}", e.getMessage());
            return buildHeuristicFallbackResult(healthRecord, aiAnalysis, doctors,
                    "Gemini response parse failed: " + e.getMessage());
        }
    }

    private Map<String, Object> findDoctorById(int doctorId, List<Map<String, Object>> doctors) {
        for (Map<String, Object> doctor : doctors) {
            Integer currentId = (Integer) doctor.get("doctor_id");
            if (currentId != null && currentId == doctorId) {
                return doctor;
            }
        }
        return null;
    }

    private Map<String, Object> selectFallbackDoctor(Map<String, Object> healthRecord,
                                                     Map<String, Object> aiAnalysis,
                                                     List<Map<String, Object>> doctors) {
        if (doctors == null || doctors.isEmpty()) {
            return null;
        }

        double hba1c = getDouble(healthRecord, "hba1c");
        double bmi = getDouble(healthRecord, "bmi");
        double cr = getDouble(healthRecord, "cr");
        double urea = getDouble(healthRecord, "urea");
        double diabetesProbability = getDouble(aiAnalysis, "diabetes_probability");

        boolean hasKidneyIssue = cr >= 120 || urea >= 7.0;
        boolean diabetesRisk = hba1c >= 6.5 || diabetesProbability >= 0.6;
        boolean obesityRisk = bmi >= 30;

        Map<String, Object> bestMatch = null;
        int bestWorkload = Integer.MAX_VALUE;

        for (Map<String, Object> doctor : doctors) {
            String department = ((String) doctor.getOrDefault("department", "")).toLowerCase();
            int workload = ((Number) doctor.getOrDefault("assigned_count", 0)).intValue();

            boolean kidneySpecialist = department.contains("thận") || department.contains("tiết niệu");
            boolean diabetesSpecialist = department.contains("nội tiết")
                    || department.contains("tiểu đường")
                    || department.contains("đái tháo đường");
            boolean generalSpecialist = department.contains("tổng quát")
                    || department.contains("gia đình")
                    || department.contains("nội khoa");

            boolean matched = (hasKidneyIssue && kidneySpecialist)
                    || (!hasKidneyIssue && (diabetesRisk || obesityRisk) && diabetesSpecialist)
                    || (!hasKidneyIssue && !diabetesRisk && !obesityRisk && generalSpecialist);

            if (matched && workload < bestWorkload) {
                bestMatch = doctor;
                bestWorkload = workload;
            }
        }

        if (bestMatch != null) {
            return bestMatch;
        }

        Map<String, Object> leastBusyDoctor = doctors.get(0);
        for (Map<String, Object> doctor : doctors) {
            int workload = ((Number) doctor.getOrDefault("assigned_count", 0)).intValue();
            int currentLeast = ((Number) leastBusyDoctor.getOrDefault("assigned_count", 0)).intValue();
            if (workload < currentLeast) {
                leastBusyDoctor = doctor;
            }
        }
        return leastBusyDoctor;
    }

    private double getDouble(Map<String, Object> source, String key) {
        if (source == null) {
            return 0.0;
        }
        Object value = source.get(key);
        if (value instanceof Number) {
            return ((Number) value).doubleValue();
        }
        return 0.0;
    }

    private Map<String, Object> extractAIAnalysis(Map<String, Object> recommendationContext) {
        if (recommendationContext == null || !recommendationContext.containsKey("diabetes_probability")) {
            return null;
        }

        Map<String, Object> aiAnalysis = new java.util.HashMap<>();
        aiAnalysis.put("diabetes_probability", getDouble(recommendationContext, "diabetes_probability"));
        aiAnalysis.put("pre_diabetes_probability", getDouble(recommendationContext, "pre_diabetes_probability"));
        aiAnalysis.put("normal_probability", getDouble(recommendationContext, "normal_probability"));
        return aiAnalysis;
    }

    private String sanitizeReason(String reason) {
        if (reason == null) {
            return "";
        }
        return reason.replaceAll("\\s+", " ").trim();
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

    private String buildQuotaExceededMessage(String errorBody) {
        String normalized = sanitizeReason(errorBody);
        if (normalized.contains("limit: 0")) {
                    return "Google đang trả quota = 0 cho project của key này trên model " + GeminiConfigUtil.getRecommendationModel() + ". "
                    + "Đây là lỗi cấu hình plan/billing/quota phía Google, không phải lỗi cú pháp API key. "
                    + "Hệ thống tự chuyển sang thuật toán phân bổ dự phòng.";
        }
        if (!normalized.isEmpty()) {
            return "Gemini API đang từ chối yêu cầu: " + normalized
                    + " Hệ thống tự chuyển sang thuật toán phân bổ dự phòng.";
        }
        return "Gemini API bị giới hạn (HTTP 429). Hệ thống tự chuyển sang thuật toán phân bổ dự phòng.";
    }

    private String buildRetryableFailureMessage(String errorBody) {
        String compactError = compact(errorBody);
        String normalized = sanitizeReason(errorBody).toLowerCase();
        if (normalized.contains("503") || normalized.contains("high demand") || normalized.contains("overloaded")) {
            return "Tất cả API key Gemini recommendation đều đang quá tải hoặc trả HTTP 503. Chi tiết cuối: " + compactError;
        }
        if (normalized.contains("429") || normalized.contains("quota") || normalized.contains("limit: 0")) {
            return buildQuotaExceededMessage(errorBody);
        }
        if (normalized.contains("404") || normalized.contains("not found") || normalized.contains("not supported")) {
            return "Các model Gemini recommendation đang không phản hồi hợp lệ cho project này. Chi tiết cuối: " + compactError;
        }
        if (normalized.contains("timeout")) {
            return "Tất cả API key Gemini recommendation đều timeout. Chi tiết cuối: " + compactError;
        }
        if (!compactError.isBlank()) {
            return compactError;
        }
        return "Tất cả API key Gemini recommendation đều không khả dụng. Hệ thống tự chuyển sang thuật toán phân bổ dự phòng.";
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

    private RecommendationResult buildHeuristicFallbackResult(Map<String, Object> healthRecord,
                                                              Map<String, Object> aiAnalysis,
                                                              List<Map<String, Object>> doctors,
                                                              String geminiError) {
        Map<String, Object> fallbackDoctor = selectFallbackDoctor(healthRecord, aiAnalysis, doctors);
        if (fallbackDoctor == null) {
            return new RecommendationResult(0, "Unknown", "Unknown",
                    "Gemini không khả dụng và không tìm thấy bác sĩ phù hợp để phân bổ dự phòng.",
                    "Local Fallback",
                    buildDiagnosticMessage(geminiError));
        }

        String reason = buildFallbackReason(healthRecord, aiAnalysis, fallbackDoctor, geminiError);
        return new RecommendationResult(
                (Integer) fallbackDoctor.get("doctor_id"),
                (String) fallbackDoctor.get("full_name"),
                (String) fallbackDoctor.get("department"),
                reason,
                "Local Fallback",
                buildDiagnosticMessage(geminiError)
        );
    }

    private String buildFallbackReason(Map<String, Object> healthRecord,
                                       Map<String, Object> aiAnalysis,
                                       Map<String, Object> doctor,
                                       String geminiError) {
        double hba1c = getDouble(healthRecord, "hba1c");
        double cr = getDouble(healthRecord, "cr");
        double urea = getDouble(healthRecord, "urea");
        double bmi = getDouble(healthRecord, "bmi");
        double diabetesProbability = getDouble(aiAnalysis, "diabetes_probability");
        String department = doctor == null ? "" : (String) doctor.getOrDefault("department", "");

        List<String> reasons = new ArrayList<>();
        String trigger = normalizeFallbackTrigger(geminiError, false);
        if (!trigger.isBlank()) {
            reasons.add(trigger);
        }
        if (cr >= 120 || urea >= 7.0) {
            reasons.add(String.format(
                    "Urea %.1f và Cr %.1f vượt ngưỡng tham chiếu, ưu tiên chuyên khoa %s",
                    urea, cr, department));
        } else if (hba1c >= 6.5 && diabetesProbability >= 0.6) {
            reasons.add(String.format(
                    "HbA1c %.1f%% và xác suất tiểu đường %.0f%% đều ở mức cao, ưu tiên chuyên khoa %s",
                    hba1c, diabetesProbability * 100, department));
        } else if (hba1c >= 6.5) {
            reasons.add(String.format(
                    "HbA1c %.1f%% ở mức cao, ưu tiên chuyên khoa %s",
                    hba1c, department));
        } else if (diabetesProbability >= 0.6) {
            reasons.add(String.format(
                    "Xác suất tiểu đường %.0f%% ở mức cao, ưu tiên chuyên khoa %s",
                    diabetesProbability * 100, department));
        } else if (bmi >= 30) {
            reasons.add(String.format(
                    "BMI %.1f ở mức cao, ưu tiên bác sĩ đúng chuyên môn và tải thấp",
                    bmi));
        } else {
            reasons.add(String.format(
                    "Chưa có tín hiệu nguy cơ mạnh (HbA1c %.1f%%, BMI %.1f), cân bằng theo tải công việc hiện tại",
                    hba1c, bmi));
        }

        int workload = ((Number) doctor.getOrDefault("assigned_count", 0)).intValue();
        reasons.add("Bác sĩ đang quản lý " + workload + " hồ sơ");
        return String.join(". ", reasons) + ".";
    }

    private String normalizeFallbackTrigger(String message, boolean appendFallbackSuffix) {
        String normalized = sanitizeReason(message);
        String friendly;

        if (normalized.isEmpty()) {
            friendly = "AI tạm thời không đưa ra được khuyến nghị";
        } else {
            String lower = normalized.toLowerCase();
            if (lower.contains("http 503") || lower.contains("\"code\": 503")
                    || lower.contains("high demand") || lower.contains("overloaded")) {
                friendly = "AI đang quá tải tạm thời";
            } else if (lower.contains("http 429") || lower.contains("\"code\": 429")
                    || lower.contains("quota") || lower.contains("rate limit")
                    || lower.contains("limit: 0")) {
                friendly = "AI đang bị giới hạn quota";
            } else if (lower.contains("http 404") || lower.contains("\"code\": 404")
                    || lower.contains("not found") || lower.contains("not supported")) {
                friendly = "Model AI hiện tại không khả dụng";
            } else if (lower.contains("http 400")
                    || lower.contains("\"code\": 400")
                    || lower.contains("invalid json payload")
                    || lower.contains("invalid argument")
                    || lower.contains("unknown name")) {
                friendly = "Request gửi tới Gemini chưa đúng định dạng";
            } else if (lower.contains("timeout") || lower.contains("timed out")) {
                friendly = "Gemini kết nối quá chậm hoặc bị timeout";
            } else if (lower.contains("unable to resolve host")
                    || lower.contains("connection reset")
                    || lower.contains("connection refused")) {
                friendly = "Gemini đang lỗi kết nối mạng";
            } else if (lower.contains("lỗi phân tích response")
                    || lower.contains("lỗi phân tích")
                    || lower.contains("parse ai response")
                    || lower.contains("parsing")
                    || lower.contains("missing recommended_doctor_id")
                    || lower.contains("did not contain valid json")
                    || lower.contains("invalid output")) {
                friendly = "Gemini không trả đủ dữ liệu để chốt phân bổ tự động";
            } else if (lower.contains("gemini_api_key is not configured")) {
                friendly = "AI chưa được cấu hình API key";
            } else {
                friendly = "AI tạm thời không khả dụng";
            }
        }

        if (!appendFallbackSuffix) {
            return friendly;
        }
        return friendly + ". Hệ thống chuyển sang phân bổ dự phòng theo chuyên khoa và tải công việc.";
    }

    private String enrichReasonWithEvidence(String reason,
                                            Map<String, Object> healthRecord,
                                            Map<String, Object> aiAnalysis,
                                            Map<String, Object> doctor) {
        String normalizedReason = sanitizeReason(reason);
        if (doctor == null) {
            return normalizedReason;
        }

        double hba1c = getDouble(healthRecord, "hba1c");
        double bmi = getDouble(healthRecord, "bmi");
        double urea = getDouble(healthRecord, "urea");
        double cr = getDouble(healthRecord, "cr");
        double diabetesProbability = getDouble(aiAnalysis, "diabetes_probability");
        int workload = ((Number) doctor.getOrDefault("assigned_count", 0)).intValue();

        String evidence = String.format(
                "Số liệu: HbA1c %.1f%%, BMI %.1f, Urea %.1f, Cr %.1f, nguy cơ tiểu đường %.0f%%, tải bác sĩ %d hồ sơ.",
                hba1c, bmi, urea, cr, diabetesProbability * 100, workload);

        if (normalizedReason.isBlank()) {
            return evidence;
        }
        String lowerReason = normalizedReason.toLowerCase();
        if (lowerReason.contains("hba1c") && lowerReason.contains("tải bác sĩ")) {
            return normalizedReason;
        }
        if (normalizedReason.contains("Số liệu:")) {
            return normalizedReason;
        }
        if (normalizedReason.matches(".*\\d.*")) {
            return normalizedReason + " " + evidence;
        }
        return normalizedReason + ". " + evidence;
    }

    private Map<String, Object> buildLocalAnalysis(Map<String, Object> healthRecord) {
        Map<String, Object> analysis = new java.util.HashMap<>();
        double hba1c = getDouble(healthRecord, "hba1c");
        double bmi = getDouble(healthRecord, "bmi");
        double urea = getDouble(healthRecord, "urea");
        double cr = getDouble(healthRecord, "cr");
        String symptoms = healthRecord == null ? "" : String.valueOf(healthRecord.getOrDefault("other_information", ""));

        double diabetesProbability = 0.05;
        double preDiabetesProbability = 0.15;
        double normalProbability = 0.80;

        if (hba1c >= 6.5) {
            diabetesProbability = 0.70 + Math.min(0.25, (hba1c - 6.5) * 0.08);
            preDiabetesProbability = 0.20;
            normalProbability = Math.max(0.01, 1.0 - diabetesProbability - preDiabetesProbability);
        } else if (hba1c >= 5.7) {
            preDiabetesProbability = 0.55 + Math.min(0.20, (hba1c - 5.7) * 0.12);
            diabetesProbability = 0.08 + Math.max(0.0, (hba1c - 5.7) * 0.08);
            normalProbability = Math.max(0.05, 1.0 - diabetesProbability - preDiabetesProbability);
        }

        if (bmi >= 30) {
            diabetesProbability += 0.08;
            preDiabetesProbability += 0.04;
        } else if (bmi >= 25) {
            preDiabetesProbability += 0.04;
        }

        if (urea > 7.0 || cr > 120) {
            diabetesProbability += 0.05;
        }

        String symptomText = symptoms == null ? "" : symptoms.toLowerCase();
        if (symptomText.contains("khát")
                || symptomText.contains("tiểu nhiều")
                || symptomText.contains("mệt")
                || symptomText.contains("sụt cân")) {
            diabetesProbability += 0.05;
            preDiabetesProbability += 0.03;
        }

        double total = diabetesProbability + preDiabetesProbability + normalProbability;
        if (total <= 0) {
            total = 1.0;
        }
        diabetesProbability = Math.max(0.0, Math.min(1.0, diabetesProbability / total));
        preDiabetesProbability = Math.max(0.0, Math.min(1.0, preDiabetesProbability / total));
        normalProbability = Math.max(0.0, Math.min(1.0, normalProbability / total));

        analysis.put("diabetes_probability", diabetesProbability);
        analysis.put("pre_diabetes_probability", preDiabetesProbability);
        analysis.put("normal_probability", normalProbability);
        return analysis;
    }

    private int extractIntField(String json, String fieldName) {
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(
                "\"" + java.util.regex.Pattern.quote(fieldName) + "\"\\s*:\\s*(\\d+)");
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return Integer.parseInt(matcher.group(1));
        }
        return 0;
    }

    private int extractRecommendedDoctorId(String json, List<Map<String, Object>> doctors) {
        List<Integer> validDoctorIds = getValidDoctorIds(doctors);

        String normalizedText = normalizePlainDoctorIdText(json);
        if (!normalizedText.isBlank()) {
            for (Integer validDoctorId : validDoctorIds) {
                if (normalizedText.equals(String.valueOf(validDoctorId))) {
                    return validDoctorId;
                }
            }
        }

        int doctorId = extractIntField(json, "recommended_doctor_id");
        if (doctorId > 0 && validDoctorIds.contains(doctorId)) {
            return doctorId;
        }

        doctorId = extractQuotedIntField(json, "recommended_doctor_id");
        if (doctorId > 0 && validDoctorIds.contains(doctorId)) {
            return doctorId;
        }

        doctorId = extractIntField(json, "doctor_id");
        if (doctorId > 0 && validDoctorIds.contains(doctorId)) {
            return doctorId;
        }

        doctorId = extractQuotedIntField(json, "doctor_id");
        if (doctorId > 0 && validDoctorIds.contains(doctorId)) {
            return doctorId;
        }

        doctorId = extractIntField(json, "recommendedDoctorId");
        if (doctorId > 0 && validDoctorIds.contains(doctorId)) {
            return doctorId;
        }

        doctorId = extractQuotedIntField(json, "recommendedDoctorId");
        if (doctorId > 0 && validDoctorIds.contains(doctorId)) {
            return doctorId;
        }

        String doctorName = extractStringField(json, "doctor_name");
        if (doctorName.isBlank()) {
            doctorName = extractStringField(json, "recommended_doctor_name");
        }
        if (doctorName.isBlank()) {
            doctorName = extractStringField(json, "doctorName");
        }
        if (!doctorName.isBlank()) {
            Map<String, Object> matchedDoctor = findDoctorByName(doctorName, doctors);
            if (matchedDoctor != null) {
                Object doctorIdValue = matchedDoctor.get("doctor_id");
                if (doctorIdValue instanceof Number) {
                    return ((Number) doctorIdValue).intValue();
                }
            }
        }

        return 0;
    }

    private List<Integer> getValidDoctorIds(List<Map<String, Object>> doctors) {
        List<Integer> ids = new ArrayList<>();
        if (doctors == null) {
            return ids;
        }
        for (Map<String, Object> doctor : doctors) {
            Object value = doctor.get("doctor_id");
            if (value instanceof Number) {
                ids.add(((Number) value).intValue());
            }
        }
        return ids;
    }

    private String normalizePlainDoctorIdText(String input) {
        if (input == null) {
            return "";
        }
        String normalized = input
                .replace("```", "")
                .replace("`", "")
                .replace("\"", "")
                .trim();
        if (normalized.matches("^\\d+$")) {
            return normalized;
        }

        String[] lines = normalized.split("\\R+");
        for (String line : lines) {
            String trimmed = line == null ? "" : line.trim();
            if (trimmed.matches("^\\d+$")) {
                return trimmed;
            }
        }
        return "";
    }

    private Map<String, Object> findDoctorByDepartmentHint(String json,
                                                           String reason,
                                                           List<Map<String, Object>> doctors) {
        if (doctors == null || doctors.isEmpty()) {
            return null;
        }

        String departmentHint = extractStringField(json, "department");
        if (departmentHint.isBlank()) {
            departmentHint = extractStringField(json, "recommended_department");
        }
        if (departmentHint.isBlank()) {
            departmentHint = extractStringField(json, "specialty");
        }
        if (departmentHint.isBlank()) {
            departmentHint = reason == null ? "" : reason;
        }

        String normalizedHint = normalizeDoctorToken(departmentHint);
        if (normalizedHint.isBlank()) {
            return null;
        }

        Map<String, Object> bestDoctor = null;
        int minWorkload = Integer.MAX_VALUE;
        for (Map<String, Object> doctor : doctors) {
            String department = String.valueOf(doctor.getOrDefault("department", ""));
            String normalizedDepartment = normalizeDoctorToken(department);
            if (normalizedDepartment.isBlank()) {
                continue;
            }

            if (normalizedHint.contains(normalizedDepartment)
                    || normalizedDepartment.contains(normalizedHint)
                    || matchesDepartmentKeyword(normalizedHint, normalizedDepartment)) {
                int workload = ((Number) doctor.getOrDefault("assigned_count", 0)).intValue();
                if (workload < minWorkload) {
                    bestDoctor = doctor;
                    minWorkload = workload;
                }
            }
        }
        return bestDoctor;
    }

    private boolean matchesDepartmentKeyword(String hint, String department) {
        return (hint.contains("noitiet") && department.contains("noitiet"))
                || (hint.contains("tieuduong") && department.contains("tieuduong"))
                || (hint.contains("thankin") && department.contains("thankin"))
                || (hint.contains("tietnieu") && department.contains("tietnieu"))
                || (hint.contains("timmach") && department.contains("timmach"))
                || (hint.contains("tongquat") && department.contains("tongquat"))
                || (hint.contains("tiuhoa") && department.contains("tiuhoa"))
                || (hint.contains("tihoa") && department.contains("tihoa"));
    }

    private int extractQuotedIntField(String json, String fieldName) {
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(
                "\"" + java.util.regex.Pattern.quote(fieldName) + "\"\\s*:\\s*\"(\\d+)\"");
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return Integer.parseInt(matcher.group(1));
        }
        return 0;
    }

    private String extractStringField(String json, String fieldName) {
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(
                "\"" + java.util.regex.Pattern.quote(fieldName) + "\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"");
        java.util.regex.Matcher matcher = pattern.matcher(json);
        if (matcher.find()) {
            return decodeJsonString(matcher.group(1));
        }
        return "";
    }

    private Map<String, Object> findDoctorByName(String doctorName, List<Map<String, Object>> doctors) {
        if (doctorName == null || doctors == null) {
            return null;
        }
        String normalizedTarget = normalizeDoctorToken(doctorName);
        for (Map<String, Object> doctor : doctors) {
            String fullName = String.valueOf(doctor.getOrDefault("full_name", ""));
            if (normalizeDoctorToken(fullName).equals(normalizedTarget)) {
                return doctor;
            }
        }
        return null;
    }

    private String normalizeDoctorToken(String input) {
        if (input == null) {
            return "";
        }
        return input.toLowerCase()
                .replaceAll("[^a-z0-9_]+", "")
                .trim();
    }

    private String decodeJsonString(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\\n", "\n")
                .replace("\\r", "\r")
                .replace("\\t", "\t")
                .replace("\\\"", "\"")
                .replace("\\\\", "\\");
    }

    private String extractFirstJsonObject(String text) {
        if (text == null || text.isBlank()) {
            return null;
        }
        String cleaned = text.replace("```json", "")
                .replace("```", "")
                .trim();
        int start = cleaned.indexOf('{');
        if (start < 0) {
            return null;
        }

        int depth = 0;
        boolean inString = false;
        for (int i = start; i < cleaned.length(); i++) {
            char current = cleaned.charAt(i);
            char previous = i > 0 ? cleaned.charAt(i - 1) : '\0';
            if (current == '"' && previous != '\\') {
                inString = !inString;
            }
            if (inString) {
                continue;
            }
            if (current == '{') {
                depth++;
            } else if (current == '}') {
                depth--;
                if (depth == 0) {
                    return cleaned.substring(start, i + 1);
                }
            }
        }
        return null;
    }

    private String extractFinishReason(String geminiResponse) {
        if (geminiResponse == null || geminiResponse.isBlank()) {
            return "unknown";
        }
        java.util.regex.Pattern pattern = java.util.regex.Pattern.compile(
                "\"finishReason\"\\s*:\\s*\"([^\"]+)\"");
        java.util.regex.Matcher matcher = pattern.matcher(geminiResponse);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return "unknown";
    }

    private String compact(String input) {
        String normalized = sanitizeReason(input);
        if (normalized.length() > 220) {
            return normalized.substring(0, 217) + "...";
        }
        return normalized;
    }

    private String buildDiagnosticMessage(String geminiError) {
        String friendly = normalizeFallbackTrigger(geminiError, false);
        String compactError = compact(geminiError);
        if (compactError.isBlank()) {
            return friendly;
        }
        return friendly + " | Chi tiết: " + compactError;
    }

    private String buildGeminiAcceptedReason(Map<String, Object> healthRecord,
                                             Map<String, Object> aiAnalysis,
                                             Map<String, Object> doctor) {
        if (doctor == null) {
            return "Gemini đã chọn bác sĩ phù hợp từ danh sách active.";
        }

        double hba1c = getDouble(healthRecord, "hba1c");
        double bmi = getDouble(healthRecord, "bmi");
        double urea = getDouble(healthRecord, "urea");
        double cr = getDouble(healthRecord, "cr");
        double diabetesProbability = getDouble(aiAnalysis, "diabetes_probability");
        int workload = ((Number) doctor.getOrDefault("assigned_count", 0)).intValue();
        String department = String.valueOf(doctor.getOrDefault("department", ""));

        String summary;
        if (cr >= 120 || urea >= 7.0) {
            summary = "Gemini ưu tiên chuyên khoa " + department + " do chỉ số thận cần theo dõi";
        } else if (hba1c >= 6.5 || diabetesProbability >= 0.6) {
            summary = "Gemini ưu tiên chuyên khoa " + department + " do nguy cơ đái tháo đường cao";
        } else if (bmi >= 30) {
            summary = "Gemini ưu tiên bác sĩ đúng chuyên môn cho tình trạng BMI cao";
        } else {
            summary = "Gemini cân nhắc chuyên khoa và tải hiện tại để chọn bác sĩ phù hợp";
        }

        String evidence = String.format(
                "Số liệu: HbA1c %.1f%%, BMI %.1f, Urea %.1f, Cr %.1f, nguy cơ tiểu đường %.0f%%, tải bác sĩ %d hồ sơ.",
                hba1c, bmi, urea, cr, diabetesProbability * 100, workload);
        return summary + ". " + evidence;
    }
    
    private void sendJsonError(HttpServletResponse response, String message) throws IOException {
        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        String jsonError = "{\"error\":\"" + escapeJson(message) + "\"}";
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
    
    // Inner class cho kết quả
    public static class RecommendationResult {
        public int recommendedDoctorId;
        public String doctorName;
        public String department;
        public String reason;
        public String source;
        public String diagnostic;
        
        public RecommendationResult(int recommendedDoctorId, String doctorName, 
                                   String department, String reason, String source, String diagnostic) {
            this.recommendedDoctorId = recommendedDoctorId;
            this.doctorName = doctorName;
            this.department = department;
            this.reason = reason;
            this.source = source;
            this.diagnostic = diagnostic;
        }
    }

    private static class GeminiInvocationResult {
        private final String jsonResponse;
        private final String modelUsed;
        private final int keyIndex;

        private GeminiInvocationResult(String jsonResponse, String modelUsed, int keyIndex) {
            this.jsonResponse = jsonResponse;
            this.modelUsed = modelUsed;
            this.keyIndex = keyIndex;
        }
    }
}
