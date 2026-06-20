package controller;

import dal.BookDAO;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.text.Normalizer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Book;
import model.Category;
import config.ApiConfig;

@WebServlet(name = "BookChatbotServlet", urlPatterns = { "/chatbot" })
/**
 * Chatbot tu van sach bang Gemini API.
 * Luong chinh:
 * 1) Nhan query tu nguoi dung
 * 2) Lay danh sach sach tu DB
 * 3) Tao prompt co rang buoc chi duoc dung du lieu trong kho
 * 4) Goi AI va hien thi ket qua tra ve
 */
public class BookChatbotServlet extends HttpServlet {

    private static final int MAX_RECOMMENDED_BOOKS = 200;
    private static final Pattern BOOK_IDS_PATTERN = Pattern.compile("(?i)book_ids\\s*[:=]\\s*\\[?([0-9,\\s]*)\\]?");

    // Thu tu thu model: uu tien Gemini chat luong cao, fallback sang Gemma neu
    // quota/qua tai.
    private static final String[] MODEL_CANDIDATES = {
            "gemini-2.5-flash",
            "gemini-2.5-flash-lite",
            "gemma-3n-e4b-it",
            "gemma-3-4b-it",
            "gemma-3n-e2b-it"
    };

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Hien thi giao dien chatbot.
        request.getRequestDispatcher("/views/user/chatbot.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // 1) Lay query tu form.
        String query = request.getParameter("query");
        request.setAttribute("query", query);

        if (query == null || query.trim().isEmpty()) {
            request.setAttribute("error", "Vui long nhap mo ta nhu cau doc sach.");
            request.getRequestDispatcher("/views/user/chatbot.jsp").forward(request, response);
            return;
        }

        String userQuery = query.trim();

        // 2) Lay API key tu ApiConfig (load from environment variables).
        String apiKey = ApiConfig.getGeminiApiKey();

        if (isBlank(apiKey)) {
            request.setAttribute("error", "Chưa cấu hình API key. Vui lòng set biến môi trường GEMINI_API_KEY.");
            request.getRequestDispatcher("/views/user/chatbot.jsp").forward(request, response);
            return;
        }

        // 3) Lay toan bo sach lam du lieu context cho AI.
        BookDAO dao = new BookDAO();
        List<Book> books = dao.getAllBooks("0", "");

        if (books == null || books.isEmpty()) {
            request.setAttribute("answer", "Hien kho chua co du lieu sach de tu van.");
            request.getRequestDispatcher("/views/user/chatbot.jsp").forward(request, response);
            return;
        }

        Map<Integer, String> categoryNames = buildCategoryMap(dao.getAllCategories());
        List<Book> promptBooks = books;

        // 4) Tao prompt va goi AI.
        String prompt = buildPrompt(userQuery, promptBooks, categoryNames, books.size());

        try {
            String aiText = callGemini(apiKey.trim(), prompt);
            ChatbotRecommendation recommendation = parseRecommendation(aiText, books, userQuery, categoryNames);

            request.setAttribute("answer", recommendation.message);
            request.setAttribute("recommendedBooks", recommendation.books);
        } catch (Exception e) {
            String msg = e.getMessage() == null ? "" : e.getMessage();
            // Tach thong bao loi quota de nguoi dung de hieu hon.
            if (msg.contains("HTTP 429")) {
                request.setAttribute("error",
                        "API AI da het luot mien phi trong ngay. Vui long thu lai sau it phut hoac lien he admin de nang cap API key.");
            } else {
                request.setAttribute("error",
                        "Khong the ket noi AI luc nay: " + shorten(msg, 150));
            }
        }

        request.getRequestDispatcher("/views/user/chatbot.jsp").forward(request, response);
    }

    private String buildPrompt(String userQuery, List<Book> books, Map<Integer, String> categoryNames,
            int totalBooksInStock) {
        // Prompt co rang buoc chat de AI khong bịa sach ngoai kho.
        StringBuilder sb = new StringBuilder();
        sb.append("Ban la tro ly tu van sach cho website ban sach.\n");
        sb.append(
                "MUC TIEU: Chon sach phu hop nhat trong danh sach BOOKS de website co the hien thi nut xem chi tiet va them vao gio hang.\n");
        sb.append("LUU Y: BOOKS ben duoi la TOAN BO kho hien tai, khong phai shortlist.\n");
        sb.append("QUY TAC:\n");
        sb.append("- CHI duoc chon sach co trong BOOKS ben duoi. TUYET DOI KHONG bịa them sach moi.\n");
        sb.append("- Uu tien DO CHINH XAC hon viec rut gon so luong.\n");
        sb.append("- Neu khach hoi ve gia, uu tien loc theo gia.\n");
        sb.append("- Neu khach hoi ve chu de/noi dung/tac gia/ten sach, chon sach lien quan nhat.\n");
        sb.append("- Neu khach nhap ten sach cu the khong dau, uu tien sach trung hoac gan trung title/title_ascii.\n");
        sb.append(
                "- Neu yeu cau co y 'tat ca/toan bo/hien het' theo 1 danh muc, BAT BUOC tra ve DAY DU tat ca id thuoc danh muc do, khong bo sot.\n");
        sb.append("- Uu tien sach con hang de nguoi dung co the them vao gio hang ngay.\n");
        sb.append("- So luong de xuat tuy theo yeu cau. Neu hoi 'tat ca' thi tra ve tat ca id phu hop.\n");
        sb.append("- TRA VE DUNG 1 DONG DUY NHAT theo format: book_ids=[id1,id2,id3].\n");
        sb.append("- KHONG viet markdown, KHONG viet giai thich, KHONG them ky tu khac.\n");
        sb.append("- Neu khong co sach phu hop, tra ve: book_ids=[].\n\n");

        sb.append("Yeu cau khach: ").append(userQuery).append("\n");

        String normalizedQuery = normalizeNoAccent(userQuery);
        if (!normalizedQuery.equals(userQuery.toLowerCase(Locale.ROOT).trim())) {
            sb.append("(Khong dau: ").append(normalizedQuery).append(")\n");
        }

        sb.append("Tong so sach trong kho: ").append(totalBooksInStock).append("\n");
        sb.append("So sach gui len AI: ").append(books.size()).append("\n");

        if (!categoryNames.isEmpty()) {
            sb.append("Danh muc hien co: ");
            List<String> categoryList = new ArrayList<>(categoryNames.values());
            for (int i = 0; i < categoryList.size(); i++) {
                if (i > 0) {
                    sb.append(", ");
                }
                sb.append(categoryList.get(i));
            }
            sb.append("\n");
        }

        sb.append("\nBOOKS:\n");
        for (Book b : books) {
            String title = clean(b.getTitle());
            String titleAscii = normalizeNoAccent(title);
            String category = cleanCategoryName(categoryNames.get(b.getCid()));
            String desc = limitLength(clean(b.getDescription()), 140);
            sb.append("id=").append(b.getId())
                    .append(" | title=").append(title)
                    .append(" | title_ascii=").append(titleAscii)
                    .append(" | category=").append(category)
                    .append(" | gia=").append((long) b.getPrice()).append(" VND")
                    .append(" | stock=").append(b.getStock())
                    .append(" | mo_ta=").append(desc)
                    .append("\n");
        }

        return sb.toString();
    }

    private Map<Integer, String> buildCategoryMap(List<Category> categories) {
        Map<Integer, String> map = new HashMap<>();
        if (categories == null) {
            return map;
        }

        for (Category category : categories) {
            if (category != null) {
                map.put(category.getId(), clean(category.getName()));
            }
        }
        return map;
    }

    private String cleanCategoryName(String value) {
        if (isBlank(value)) {
            return "Khac";
        }
        return value.trim();
    }

    private String callGemini(String apiKey, String prompt) throws IOException {
        // Thu tung model den khi co model tra ve hop le.
        IOException lastError = null;

        for (String model : MODEL_CANDIDATES) {
            try {
                return callGeminiWithModel(apiKey, prompt, model);
            } catch (IOException e) {
                lastError = e;
                String msg = e.getMessage() == null ? "" : e.getMessage();
                // 429 = quota het, 503 = qua tai -> thu model tiep theo
                if (msg.contains("HTTP 429") || msg.contains("HTTP 503") || msg.contains("NO_TEXT")) {
                    continue;
                }
                // Loi khac (500, 404, network) -> cung thu model tiep
                if (msg.contains("HTTP 5") || msg.contains("HTTP 404")) {
                    continue;
                }
                throw e;
            }
        }

        if (lastError != null) {
            throw lastError;
        }
        throw new IOException("Khong co model AI nao kha dung luc nay.");
    }

    private String callGeminiWithModel(String apiKey, String prompt, String model) throws IOException {
        // Endpoint generateContent cua Generative Language API.
        String endpoint = "https://generativelanguage.googleapis.com/v1beta/models/"
                + model + ":generateContent?key=" + apiKey;

        HttpURLConnection conn = (HttpURLConnection) new URL(endpoint).openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
        conn.setDoOutput(true);
        conn.setConnectTimeout(15000);
        conn.setReadTimeout(30000);

        String payload = "{\"contents\":[{\"parts\":[{\"text\":\""
                + escapeJson(prompt)
                + "\"}]}],\"generationConfig\":{\"temperature\":0.1,\"maxOutputTokens\":260}}";

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300)
                ? conn.getInputStream()
                : conn.getErrorStream();
        String body = readAll(is);
        conn.disconnect();

        if (status < 200 || status >= 300) {
            throw new IOException("HTTP " + status + " model=" + model + " " + shorten(body, 200));
        }

        String text = extractText(body);
        if (text == null || text.trim().isEmpty()) {
            throw new IOException("NO_TEXT model=" + model);
        }
        return text.trim();
    }

    /**
     * Parse ket qua AI thanh message hien thi + danh sach sach thuc te trong DB.
     */
    private ChatbotRecommendation parseRecommendation(String aiText, List<Book> books,
            String userQuery, Map<Integer, String> categoryNames) {
        List<Integer> selectedIds = extractBookIds(aiText);
        List<Book> selectedBooks = selectBooksByIds(books, selectedIds);

        if (selectedBooks.isEmpty() && !containsNoMatchMessage(aiText)) {
            selectedBooks = selectBooksByListedTitles(books, aiText);
        }

        if (selectedBooks.isEmpty() && !containsNoMatchMessage(aiText)) {
            selectedBooks = selectBooksByMentionedTitles(books, aiText);
        }

        // Dam bao query "tat ca ... theo danh muc" thi phai hien thi day du, khong bo
        // sot.
        List<Book> categoryAllBooks = selectAllBooksByCategoryIntent(userQuery, books, categoryNames);
        if (!categoryAllBooks.isEmpty()) {
            selectedBooks = categoryAllBooks;
        }

        String message;
        if (selectedBooks.isEmpty()) {
            message = "AI chưa tìm thấy cuốn sách phù hợp trong kho hiện tại.";
        } else if (!categoryAllBooks.isEmpty()) {
            message = "Đã hiển thị toàn bộ sách phù hợp theo yêu cầu của bạn.";
        } else if (selectedBooks.size() == 1) {
            message = "AI đề xuất cuốn sách sau cho nhu cầu của bạn. Bạn có thể xem chi tiết hoặc thêm vào giỏ hàng.";
        } else {
            message = "AI đề xuất các cuốn sách sau cho nhu cầu của bạn. Bạn có thể xem chi tiết hoặc thêm vào giỏ hàng.";
        }

        return new ChatbotRecommendation(message, selectedBooks);
    }

    private List<Integer> extractBookIds(String aiText) {
        List<Integer> ids = new ArrayList<>();
        Matcher matcher = BOOK_IDS_PATTERN.matcher(aiText);
        if (!matcher.find()) {
            return ids;
        }

        String rawIds = matcher.group(1);
        if (isBlank(rawIds)) {
            return ids;
        }

        String[] parts = rawIds.split(",");
        for (String part : parts) {
            String value = part == null ? "" : part.trim();
            if (value.isEmpty()) {
                continue;
            }

            try {
                ids.add(Integer.parseInt(value));
            } catch (NumberFormatException e) {
                // Bo qua id loi dinh dang.
            }
        }
        return ids;
    }

    private List<Book> selectBooksByIds(List<Book> books, List<Integer> ids) {
        List<Book> selectedBooks = new ArrayList<>();
        for (Integer id : ids) {
            if (id == null || containsBookId(selectedBooks, id)) {
                continue;
            }

            Book matchedBook = findBookById(books, id);
            if (matchedBook != null) {
                selectedBooks.add(matchedBook);
            }

            if (selectedBooks.size() >= MAX_RECOMMENDED_BOOKS) {
                break;
            }
        }
        return selectedBooks;
    }

    private List<Book> selectBooksByListedTitles(List<Book> books, String aiText) {
        List<Book> selectedBooks = new ArrayList<>();
        String[] lines = aiText.split("\\r?\\n");

        for (String line : lines) {
            String possibleTitle = extractPossibleTitleFromLine(line);
            if (isBlank(possibleTitle) || containsNoMatchMessage(possibleTitle)) {
                continue;
            }

            Book matchedBook = findBookByTitle(books, possibleTitle);
            if (matchedBook != null && !containsBookId(selectedBooks, matchedBook.getId())) {
                selectedBooks.add(matchedBook);
            }

            if (selectedBooks.size() >= MAX_RECOMMENDED_BOOKS) {
                break;
            }
        }

        return selectedBooks;
    }

    private List<Book> selectBooksByMentionedTitles(List<Book> books, String aiText) {
        List<Book> selectedBooks = new ArrayList<>();
        String normalizedAiText = normalizeNoAccent(aiText);

        while (selectedBooks.size() < MAX_RECOMMENDED_BOOKS) {
            Book bestBook = null;
            int bestPosition = Integer.MAX_VALUE;

            for (Book book : books) {
                if (containsBookId(selectedBooks, book.getId())) {
                    continue;
                }

                String normalizedTitle = normalizeNoAccent(clean(book.getTitle()));
                if (normalizedTitle.length() < 3) {
                    continue;
                }

                int position = normalizedAiText.indexOf(normalizedTitle);
                if (position >= 0 && position < bestPosition) {
                    bestBook = book;
                    bestPosition = position;
                }
            }

            if (bestBook == null) {
                break;
            }

            selectedBooks.add(bestBook);
        }

        return selectedBooks;
    }

    private List<Book> selectAllBooksByCategoryIntent(String userQuery, List<Book> books,
            Map<Integer, String> categoryNames) {
        String normalizedQuery = normalizeNoAccent(userQuery);
        if (!isAllBooksIntent(normalizedQuery) || categoryNames == null || categoryNames.isEmpty()) {
            return new ArrayList<>();
        }

        Set<Integer> matchedCategoryIds = new HashSet<>();
        for (Map.Entry<Integer, String> entry : categoryNames.entrySet()) {
            String categoryName = normalizeNoAccent(entry.getValue());
            if (!isBlank(categoryName) && normalizedQuery.contains(categoryName)) {
                matchedCategoryIds.add(entry.getKey());
            }
        }

        if (matchedCategoryIds.isEmpty()) {
            return new ArrayList<>();
        }

        List<Book> matchedBooks = new ArrayList<>();
        for (Book book : books) {
            if (matchedCategoryIds.contains(book.getCid())) {
                matchedBooks.add(book);
            }
        }
        return matchedBooks;
    }

    private boolean isAllBooksIntent(String normalizedQuery) {
        return containsAnyPhrase(normalizedQuery,
                "tat ca", "toan bo", "hien het", "liet ke het", "list het", "show all", "all");
    }

    private boolean containsAnyPhrase(String text, String... phrases) {
        if (isBlank(text) || phrases == null) {
            return false;
        }

        for (String phrase : phrases) {
            if (!isBlank(phrase) && text.contains(phrase)) {
                return true;
            }
        }
        return false;
    }

    private Book findBookById(List<Book> books, int id) {
        for (Book book : books) {
            if (book.getId() == id) {
                return book;
            }
        }
        return null;
    }

    private Book findBookByTitle(List<Book> books, String possibleTitle) {
        String normalizedCandidate = normalizeNoAccent(possibleTitle);
        if (isBlank(normalizedCandidate)) {
            return null;
        }

        for (Book book : books) {
            String normalizedTitle = normalizeNoAccent(clean(book.getTitle()));
            if (normalizedTitle.equals(normalizedCandidate)) {
                return book;
            }
        }

        for (Book book : books) {
            String normalizedTitle = normalizeNoAccent(clean(book.getTitle()));
            if (normalizedCandidate.contains(normalizedTitle) || normalizedTitle.contains(normalizedCandidate)) {
                return book;
            }
        }

        return null;
    }

    private String extractPossibleTitleFromLine(String line) {
        if (line == null) {
            return "";
        }

        String value = line.trim();
        if (value.startsWith("-")) {
            value = value.substring(1).trim();
        }
        if (value.startsWith("*")) {
            value = value.substring(1).trim();
        }

        int pipeIndex = value.indexOf('|');
        if (pipeIndex >= 0) {
            value = value.substring(0, pipeIndex).trim();
        }

        int colonIndex = value.indexOf(':');
        if (colonIndex >= 0) {
            value = value.substring(0, colonIndex).trim();
        }

        return value;
    }

    private boolean containsBookId(List<Book> books, int id) {
        for (Book book : books) {
            if (book.getId() == id) {
                return true;
            }
        }
        return false;
    }

    private boolean containsNoMatchMessage(String aiText) {
        String compact = aiText == null ? "" : aiText.toLowerCase(Locale.ROOT).replaceAll("\\s+", "");
        if (compact.contains("book_ids=[]") || compact.contains("bookids=[]")) {
            return true;
        }

        String normalized = normalizeNoAccent(aiText);
        return normalized.contains("hien chua co sach phu hop trong kho");
    }

    /**
     * Tach truong text trong JSON response cua Gemini.
     */
    private String extractText(String json) {
        Pattern p = Pattern.compile("\"text\"\\s*:\\s*\"((?:\\\\.|[^\"\\\\])*)\"");
        Matcher m = p.matcher(json);
        StringBuilder result = new StringBuilder();
        while (m.find()) {
            String part = unescapeJson(m.group(1)).trim();
            if (!part.isEmpty()) {
                if (result.length() > 0) {
                    result.append("\n");
                }
                result.append(part);
            }
        }
        return result.length() == 0 ? null : result.toString();
    }

    /**
     * Chuyen chuoi tieng Viet ve dang khong dau de tang kha nang match.
     */
    private String normalizeNoAccent(String text) {
        if (isBlank(text))
            return "";
        return Normalizer.normalize(text, Normalizer.Form.NFD)
                .replaceAll("\\p{M}+", "")
                .replace('\u0111', 'd').replace('\u0110', 'D')
                .toLowerCase(Locale.ROOT)
                .replaceAll("[^a-z0-9 ]", " ")
                .replaceAll("\\s+", " ")
                .trim();
    }

    /**
     * Escape chuoi de an toan khi dua vao JSON payload.
     */
    private String escapeJson(String text) {
        if (text == null)
            return "";
        StringBuilder sb = new StringBuilder(text.length() + 64);
        for (char ch : text.toCharArray()) {
            switch (ch) {
                case '\\':
                    sb.append("\\\\");
                    break;
                case '"':
                    sb.append("\\\"");
                    break;
                case '\n':
                    sb.append("\\n");
                    break;
                case '\r':
                    sb.append("\\r");
                    break;
                case '\t':
                    sb.append("\\t");
                    break;
                default:
                    sb.append(ch);
            }
        }
        return sb.toString();
    }

    /**
     * Unescape chuoi text sau khi doc tu JSON response.
     */
    private String unescapeJson(String text) {
        return text
                .replace("\\n", "\n")
                .replace("\\r", "")
                .replace("\\t", "\t")
                .replace("\\\"", "\"")
                .replace("\\\\", "\\");
    }

    /**
     * Doc toan bo noi dung InputStream thanh String.
     */
    private String readAll(InputStream is) throws IOException {
        if (is == null)
            return "";
        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }
        return sb.toString();
    }

    /**
     * Lam sach chuoi mo ta (xu ly null, xuong dong).
     */
    private String clean(String text) {
        if (text == null || text.trim().isEmpty())
            return "(khong co mo ta)";
        return text.replace("\n", " ").replace("\r", " ").trim();
    }

    /**
     * Cat gon chuoi de tranh prompt qua dai.
     */
    private String limitLength(String text, int max) {
        if (text == null)
            return "";
        String v = text.trim();
        return v.length() <= max ? v : v.substring(0, max) + "...";
    }

    /**
     * Rut gon thong bao loi de hien thi gon tren UI.
     */
    private String shorten(String text, int max) {
        if (text == null)
            return "";
        return text.length() > max ? text.substring(0, max) + "..." : text;
    }

    /**
     * Kiem tra chuoi rong/chi co khoang trang.
     */
    private boolean isBlank(String v) {
        return v == null || v.trim().isEmpty();
    }

    private static class ChatbotRecommendation {
        private final String message;
        private final List<Book> books;

        ChatbotRecommendation(String message, List<Book> books) {
            this.message = message;
            this.books = books;
        }
    }
}