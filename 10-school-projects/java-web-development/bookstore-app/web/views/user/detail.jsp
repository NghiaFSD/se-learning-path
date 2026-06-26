<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang chi tiet mot san pham sach theo id. --%>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết: ${book.title}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row bg-white p-4 shadow-sm rounded">
            <div class="col-md-4 text-center">
                <img src="${book.image}" class="img-fluid border" style="max-height: 400px;">
            </div>
            <div class="col-md-8">
                <h1 class="fw-bold">${book.title}</h1>
                <div class="mt-2 mb-3">
                    <p class="text-muted mb-1">
                        <strong>Tác giả:</strong> ${book.author != null && !book.author.isEmpty() ? book.author : 'Chưa cập nhật'}
                    </p>
                    <p class="text-muted">
                        <strong>Tái bản:</strong> ${book.edition != null && !book.edition.isEmpty() ? book.edition : 'Chưa cập nhật'}
                    </p>
                </div>
                <h3 class="text-danger my-3"><fmt:formatNumber value="${book.price}" pattern="#,##0" /> ₫</h3>
                
                <div class="mt-4">
                    <h5 class="fw-bold">Mô tả sản phẩm:</h5>
                    <p class="text-muted" style="line-height: 1.8;">
                        ${book.description != null ? book.description : "Chưa có mô tả cho sách này."}
                    </p>
                </div>

                <div class="mt-4 mb-2">
                    <span class="text-muted">Tồn kho: <strong>${book.stock}</strong></span>
                </div>
                <div class="mt-4">
                    <c:choose>
                        <c:when test="${book.stock > 0}">
                            <a href="${pageContext.request.contextPath}/add-to-cart?id=${book.id}" class="btn btn-primary btn-lg px-4">THÊM VÀO GIỎ HÀNG</a>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button class="btn btn-danger btn-lg px-4" disabled>HẾT HÀNG</button>
                        </c:otherwise>
                    </c:choose>
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-outline-secondary btn-lg ms-2">Quay lại</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>