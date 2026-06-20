<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Giao dien chatbot AI tu van sach tu du lieu kho. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AI Tư vấn sách</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .book-card {
            border: none;
            border-radius: 16px;
            background: #fff;
            padding: 18px;
            box-shadow: 0 10px 24px rgba(0, 0, 0, 0.08);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            height: 100%;
        }

        .book-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 14px 30px rgba(0, 0, 0, 0.12);
        }

        .book-img {
            width: 100%;
            height: 220px;
            object-fit: contain;
            margin-bottom: 16px;
        }

        .book-title {
            font-size: 1.05rem;
            font-weight: 700;
            min-height: 52px;
            color: #1f2937;
        }

        .book-price {
            color: #dc3545;
            font-size: 1.2rem;
            font-weight: 700;
        }

        .book-stock {
            color: #6c757d;
            font-size: 0.95rem;
        }
    </style>
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-dark">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/home">FPT BOOK</a>
        <a class="btn btn-outline-light" href="${pageContext.request.contextPath}/home">Về trang chủ</a>
    </div>
</nav>

<div class="container mt-5">
    <div class="card shadow-sm p-4">
        <h3 class="mb-3">Chatbot tư vấn sách (AI)</h3>
        <p class="text-muted mb-4">Nhập mô tả nhu cầu đọc, AI sẽ chọn sách phù hợp và hiển thị ngay để bạn xem chi tiết hoặc mua luôn.</p>

        <form method="post" action="${pageContext.request.contextPath}/chatbot">
            <div class="mb-3">
                <label for="query" class="form-label">Bạn đang muốn tìm sách như thế nào?</label>
                <textarea class="form-control" id="query" name="query" rows="4" placeholder="Ví dụ: Tôi cần sách Java cho người mới bắt đầu, có bài tập thực hành.">${query}</textarea>
            </div>
            <button class="btn btn-primary" type="submit">Nhờ AI gợi ý</button>
        </form>

        <c:if test="${not empty error}">
            <div class="alert alert-danger mt-4">${error}</div>
        </c:if>

        <c:if test="${not empty answer}">
            <div class="card mt-4 border-success">
                <div class="card-header bg-success text-white">Kết quả tư vấn</div>
                <div class="card-body">
                    <div class="mb-0"><c:out value="${answer}" /></div>
                </div>
            </div>
        </c:if>

        <c:if test="${not empty recommendedBooks}">
            <div class="d-flex justify-content-between align-items-center mt-4 mb-3">
                <h5 class="mb-0">Sách AI đề xuất</h5>
                <span class="text-muted small">Bạn có thể xem chi tiết hoặc thêm vào giỏ hàng</span>
            </div>

            <div class="row">
                <c:forEach items="${recommendedBooks}" var="b">
                    <div class="col-md-4 mb-4">
                        <div class="book-card text-center">
                            <a href="${pageContext.request.contextPath}/detail?id=${b.id}">
                                <img src="${b.image}" class="book-img" alt="${b.title}">
                            </a>

                            <div class="book-title mb-2">${b.title}</div>
                            <div class="book-price mb-2">
                                <fmt:formatNumber value="${b.price}" pattern="#,##0" /> VND
                            </div>
                            <div class="book-stock mb-3">Trên kệ: <strong>${b.stock}</strong></div>

                            <div class="d-flex justify-content-center gap-2">
                                <a href="${pageContext.request.contextPath}/detail?id=${b.id}" class="btn btn-outline-secondary btn-sm">Xem chi tiết</a>
                                <c:choose>
                                    <c:when test="${b.stock gt 0}">
                                        <a href="${pageContext.request.contextPath}/add-to-cart?id=${b.id}" class="btn btn-primary btn-sm">Thêm vào giỏ hàng</a>
                                    </c:when>
                                    <c:otherwise>
                                        <button class="btn btn-danger btn-sm" disabled>Hết hàng</button>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </c:forEach>
            </div>
        </c:if>
    </div>
</div>
</body>
</html>