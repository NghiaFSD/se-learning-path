<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang lich su cac don hang da dat cua user dang nhap. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lịch sử mua hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        body { background-color: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
        .card { border: none; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.08); }
        .table thead { background-color: #333; color: white; }
        .status-badge { padding: 5px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; }
    </style>
</head>
<body>

<nav class="navbar navbar-dark bg-dark mb-5 shadow-sm">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/home"><i class="bi bi-arrow-left"></i> QUẰY LẠI Cửa HÀNG</a>
    </div>
</nav>

<div class="container">
    <div class="card p-4 bg-white">
        <h2 class="fw-bold mb-4"><i class="bi bi-clock-history"></i> LỊCH SỬ ĐƠN HÀNG</h2>

        <div class="table-responsive">
            <table class="table table-hover align-middle">
                <thead>
                    <tr>
                        <th class="ps-3">Mã đơn</th>
                        <th>Ngày đặt hàng</th>
                        <th>Tổng thanh toán</th>
                        <th>Trạng thái</th>
                        <th class="text-center">Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${history}" var="o">
                        <tr>
                            <td class="ps-3 fw-bold">#ORD-${o.id}</td>
                            <td>
                                <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                            </td>
                            <td class="text-danger fw-bold">
                                <fmt:formatNumber value="${o.totalPrice}" type="number"/> VND
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${o.status == 'Chờ xác nhận'}">
                                        <span class="status-badge" style="background:#fff3cd;color:#856404;border:1px solid #ffc107">
                                            <i class="bi bi-clock"></i> Chờ xác nhận
                                        </span>
                                    </c:when>
                                    <c:when test="${o.status == 'Đang giao'}">
                                        <span class="status-badge" style="background:#cfe2ff;color:#084298;border:1px solid #0d6efd">
                                            <i class="bi bi-truck"></i> Đang giao
                                        </span>
                                    </c:when>
                                    <c:when test="${o.status == 'Hoàn thành'}">
                                        <span class="status-badge" style="background:#d1e7dd;color:#0a3622;border:1px solid #198754">
                                            <i class="bi bi-check-circle-fill"></i> Hoàn thành
                                        </span>
                                    </c:when>
                                    <c:when test="${o.status == 'Đã hủy'}">
                                        <span class="status-badge" style="background:#f8d7da;color:#842029;border:1px solid #dc3545">
                                            <i class="bi bi-x-circle-fill"></i> Đã hủy
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge bg-secondary text-white">${o.status}</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="text-center">
                                <a href="${pageContext.request.contextPath}/order-detail?oid=${o.id}" 
                                   class="btn btn-primary btn-sm rounded-pill px-3 me-1">
                                    <i class="bi bi-eye"></i> Chi tiết
                                </a>
                                <c:if test="${o.status == 'Chờ xác nhận'}">
                                <a href="${pageContext.request.contextPath}/delete-order?oid=${o.id}" 
                                   class="btn btn-danger btn-sm rounded-pill px-3"
                                   onclick="return confirm('Hủy đơn hàng #ORD-${o.id}?')">
                                    <i class="bi bi-trash"></i> Hủy đơn
                                </a>
                                </c:if>
                            </td>
                        </tr>
                    </c:forEach>

                    <c:if test="${empty history}">
                        <tr>
                            <td colspan="5" class="text-center py-5 text-muted">
                                Bạn chưa có đơn hàng nào. <a href="${pageContext.request.contextPath}/home">
Mua sắm ngay</a>
                            </td>
                        </tr>
                    </c:if>
                </tbody>
            </table>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>