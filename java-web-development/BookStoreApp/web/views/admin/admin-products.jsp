<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang admin quan ly danh sach san pham. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý sản phẩm</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
</head>
<body class="bg-light">
<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/admin/dashboard">FPT BOOK — Admin</a>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2"></i> Dashboard
            </a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/admin/orders">
                <i class="bi bi-bag-check"></i> Quản lý đơn hàng
            </a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/admin/revenue">
                <i class="bi bi-bar-chart"></i> Doanh thu
            </a>
            <a class="btn btn-light btn-sm" href="${pageContext.request.contextPath}/admin/products?action=add">+ Thêm sản phẩm mới</a>
        </div>
    </div>
</nav>

<div class="container mt-4">

    <%-- Canh bao ton kho thap --%>
    <c:if test="${not empty lowStockBooks}">
        <div class="alert alert-warning border-warning shadow-sm" role="alert">
            <h6 class="alert-heading fw-bold">
                <i class="bi bi-exclamation-triangle-fill"></i>
                Cảnh báo tồn kho thấp — ${fn:length(lowStockBooks)} sản phẩm còn ≤ 5 cuốn
            </h6>
            <ul class="mb-0 mt-2">
                <c:forEach items="${lowStockBooks}" var="b">
                    <li>
                        <strong>${b.title}</strong>
                        <small class="text-muted"> - ${b.author} <c:if test="${not empty b.edition}">(${b.edition})</c:if></small>
                        — còn <span class="text-danger fw-bold">${b.stock}</span> cuốn
                        <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${b.id}" class="ms-2 btn btn-sm btn-outline-warning py-0">Cập nhật</a>
                    </li>
                </c:forEach>
            </ul>
        </div>
    </c:if>
    <div class="card p-4 shadow-sm">
        <h3>Danh sách sản phẩm</h3>
        <table class="table table-bordered mt-3">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Title</th>
                    <th>Tác giả</th>
                    <th>Tái bản</th>
                    <th>Giá (VND)</th>
                    <th>Stock</th>
                    <th>Danh mục</th>
                    <th>Hành động</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${books}" var="b">
                    <tr>
                        <td>${b.id}</td>
                        <td>${b.title}</td>
                        <td>${b.author}</td>
                        <td>${b.edition}</td>
                        <td><fmt:formatNumber value="${b.price}" pattern="#,##0" /> ₫</td>
                        <td>${b.stock}</td>
                        <td>
                            <c:forEach items="${categories}" var="cat">
                                <c:if test="${cat.id == b.cid}">${cat.name}</c:if>
                            </c:forEach>
                        </td>
                        <td>
                            <a href="${pageContext.request.contextPath}/admin/products?action=edit&id=${b.id}" class="btn btn-sm btn-primary">Sửa</a>
                            <a href="${pageContext.request.contextPath}/admin/products?action=delete&id=${b.id}" class="btn btn-sm btn-danger"
                               onclick="return confirm('Xóa sản phẩm ?')">Xóa</a>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty books}">
                    <tr>
                        <td colspan="8" class="text-center">Không có sản phẩm</td>
                    </tr>
                </c:if>
            </tbody>
        </table>
        <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">Quay lại cửa hàng</a>
    </div>
</div>

</body>
</html>