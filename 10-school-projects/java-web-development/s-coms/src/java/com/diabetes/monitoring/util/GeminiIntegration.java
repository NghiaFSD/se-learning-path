package com.diabetes.monitoring.util;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.logging.Level;
import java.util.logging.Logger;

public class GeminiIntegration {
    private static final Logger LOGGER = Logger.getLogger(GeminiIntegration.class.getName());
    private static final String API_KEY = System.getenv("GEMINI_API_KEY");
    private static final String API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=" + API_KEY;

    private static final String SYSTEM_PROMPT = 
        "Bạn là một bác sĩ AI chuyên theo dõi và hỗ trợ bệnh nhân tiểu đường. "
  + "Bạn luôn nói chuyện nhẹ nhàng, quan tâm và giống như bác sĩ thật đang chăm sóc bệnh nhân hằng ngày.\n\n"

  + "MỤC TIÊU:\n"
  + "- Tập trung hoàn toàn vào bệnh tiểu đường.\n"
  + "- Hỗ trợ bệnh nhân theo dõi sức khỏe.\n"
  + "- Phát hiện dấu hiệu nguy hiểm liên quan đến tiểu đường.\n"
  + "- Đưa ra lời khuyên ăn uống, vận động và kiểm soát đường huyết.\n"
  + "- Làm cho bệnh nhân cảm thấy được quan tâm.\n\n"

  + "PHONG CÁCH TRÒ CHUYỆN:\n"
  + "- Trò chuyện tự nhiên như bác sĩ thật.\n"
  + "- Luôn thể hiện sự quan tâm và động viên.\n"
  + "- Không trả lời quá ngắn.\n"
  + "- Luôn kết thúc bằng một câu hỏi quan tâm bệnh nhân.\n\n"

  + "CÁC TRIỆU CHỨNG TIỂU ĐƯỜNG CẦN QUAN TÂM:\n"
  + "- Khát nước nhiều\n"
  + "- Đi tiểu nhiều\n"
  + "- Mệt mỏi\n"
  + "- Sụt cân bất thường\n"
  + "- Chóng mặt\n"
  + "- Tê tay chân\n"
  + "- Vết thương lâu lành\n"
  + "- Mờ mắt\n\n"

  + "NHIỆM VỤ DỮ LIỆU:\n"
  + "1. Thu thập:\n"
  + "   - hba1c\n"
  + "   - bmi\n"
  + "   - tg (triglyceride)\n"
  + "   - hdl\n"
  + "   - symptoms (triệu chứng hiện tại)\n\n"

  + "2. Nếu có chiều cao và cân nặng thì tự tính BMI.\n\n"

  + "3. CHỈ điền dữ liệu khi bệnh nhân thực sự cung cấp.\n"
  + "Nếu chưa có dữ liệu thì để 0 hoặc '0'.\n\n"

  + "4. Nếu bệnh nhân chưa có chỉ số xét nghiệm hoặc không nhớ chỉ số, hãy hỏi kỹ triệu chứng hiện tại.\n\n"

  + "5. Nếu đường huyết quá cao hoặc có dấu hiệu nguy hiểm:\n"
  + "- khó thở\n"
  + "- đau ngực\n"
  + "- ngất\n"
  + "- lơ mơ\n"
  + "thì khuyên bệnh nhân đến bệnh viện ngay.\n\n"

  + "6. Luôn ưu tiên tư vấn:\n"
  + "- kiểm soát đường huyết\n"
  + "- chế độ ăn cho người tiểu đường\n"
  + "- vận động nhẹ\n"
  + "- ngủ nghỉ hợp lý\n"
  + "- uống thuốc đúng giờ\n\n"

  + "ĐỊNH DẠNG PHẢN HỒI:\n"
  + "CHỈ trả về JSON.\n\n"

  + "{\n"
  + "  \"reply\": \"Lời tư vấn bằng tiếng Việt\",\n"
  + "  \"healthData\": {\n"
  + "    \"hba1c\": 0,\n"
  + "    \"bmi\": 0,\n"
  + "    \"tg\": 0,\n"
  + "    \"hdl\": 0,\n"
  + "    \"symptoms\": \"\"\n"
  + "  }\n"
  + "}";
    public String getChatResponse(String userPrompt) {
        if (API_KEY == null || API_KEY.isBlank()) {
            return "{\"reply\": \"AI service is not configured.\", \"healthData\": {\"hba1c\":0, \"bmi\":0, \"tg\":0, \"hdl\":0, \"symptoms\":\"\"}}";
        }

        int maxRetries = 3;
        int retryDelayMs = 4000; // Tăng thời gian chờ lên 4 giây

        for (int i = 0; i < maxRetries; i++) {
            try {
                HttpClient client = HttpClient.newBuilder().connectTimeout(Duration.ofSeconds(10)).build();
                
                String jsonRequest = "{"
                    + "\"contents\": [{\"parts\": [{\"text\": \"" + escapeJson(SYSTEM_PROMPT + "\nUser: " + userPrompt) + "\"}]}], "
                    + "\"generationConfig\": {"
                    + "  \"temperature\": 0.7, "
                    + "  \"topP\": 0.95, "
                    + "  \"maxOutputTokens\": 1024, "
                    + "  \"responseMimeType\": \"application/json\""
                    + "}"
                    + "}";

                HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonRequest, StandardCharsets.UTF_8))
                    .timeout(Duration.ofSeconds(30))
                    .build();

                HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

                if (response.statusCode() == 200) {
                    String responseBody = response.body();

                    String rawResult = parseGeminiResponse(responseBody);
                    String extracted = extractJson(rawResult);
                    
                    if (extracted.startsWith("{") && extracted.endsWith("}")) {
                        return extracted;
                    }
                    return "{\"reply\": \"" + escapeJson(rawResult) + "\", \"healthData\": {\"hba1c\":0, \"bmi\":0, \"tg\":0, \"hdl\":0, \"symptoms\":\"\"}}";
                } else if (response.statusCode() == 429) {
                    // Chờ lâu hơn ở mỗi lần thử lại
                    Thread.sleep(retryDelayMs * (i + 1));
                    continue; // Thêm continue để thử lại
                } else {
                    String errorBody = response.body();
                    LOGGER.severe("Gemini Error (" + response.statusCode() + "): " + errorBody);
                    return "{\"reply\": \"Lỗi dịch vụ AI (Status " + response.statusCode() + "). Vui lòng thử lại.\", \"healthData\": {\"hba1c\":0, \"bmi\":0, \"tg\":0, \"hdl\":0, \"symptoms\":\"\"}}";
                }
            } catch (Exception e) {
                if (i == maxRetries - 1) {
                    return "{\"reply\": \"Lỗi kết nối: " + e.getMessage() + "\", \"healthData\": {\"hba1c\":0, \"bmi\":0, \"tg\":0, \"hdl\":0, \"symptoms\":\"\"}}";
                }
            }
        }
        return "{\"reply\": \"Hạn mức miễn phí đã hết. Vui lòng đợi 30 giây để Google cấp lại quyền truy cập cho Key này.\", \"healthData\": {\"hba1c\":0, \"bmi\":0, \"tg\":0, \"hdl\":0, \"symptoms\":\"\"}}";
    }

    private String extractJson(String text) {
        try {
            int start = text.indexOf("{");
            int end = text.lastIndexOf("}");
            if (start != -1 && end != -1 && end > start) {
                return text.substring(start, end + 1);
            }
        } catch (Exception e) {}
        return text;
    }

    private String extractErrorMessage(String responseBody) {
        try {
            // Cố gắng tìm message trong lỗi JSON của Google
            String searchStr = "\"message\": \"";
            int start = responseBody.indexOf(searchStr);
            if (start != -1) {
                start += searchStr.length();
                int end = responseBody.indexOf("\"", start);
                if (end != -1) {
                    return responseBody.substring(start, end);
                }
            }
        } catch (Exception e) {}
        return "Unknown error";
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

    private String parseGeminiResponse(String responseBody) {
        try {
            // Cấu trúc phản hồi Gemini: candidates[0].content.parts[0].text
            String searchStr = "\"text\": \"";
            int start = responseBody.indexOf(searchStr);
            if (start != -1) {
                start += searchStr.length();
                
                // Tìm vị trí kết thúc của chuỗi text (dấu ngoặc kép không bị escape)
                int end = -1;
                for (int i = start; i < responseBody.length(); i++) {
                    if (responseBody.charAt(i) == '\"') {
                        // Kiểm tra xem dấu ngoặc kép này có bị escape bởi số lẻ dấu backslash không
                        int backslashCount = 0;
                        for (int j = i - 1; j >= start && responseBody.charAt(j) == '\\'; j--) {
                            backslashCount++;
                        }
                        if (backslashCount % 2 == 0) {
                            end = i;
                            break;
                        }
                    }
                }
                
                if (end != -1) {
                    String result = responseBody.substring(start, end);
                    
                    // Unescape các ký tự JSON cơ bản
                    result = result.replace("\\n", "\n")
                                   .replace("\\\"", "\"")
                                   .replace("\\\\", "\\")
                                   .replace("\\t", "\t");
                    
                    // Loại bỏ markdown tags
                    result = result.trim();
                    if (result.startsWith("```json")) {
                        result = result.substring(7);
                    } else if (result.startsWith("```")) {
                        result = result.substring(3);
                    }
                    if (result.endsWith("```")) {
                        result = result.substring(0, result.length() - 3);
                    }
                    return result.trim();
                }
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return "Lỗi khi đọc phản hồi từ AI. Vui lòng thử lại.";
    }
}

