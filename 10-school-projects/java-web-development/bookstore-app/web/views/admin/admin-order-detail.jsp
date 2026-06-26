<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang admin xem chi tiet 1 don hang va thong tin nguoi dat. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn hàng #ORD-${order.id} - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body { background: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
        .info-card { background: white; border-radius: 14px; padding: 24px; box-shadow: 0 4px 15px rgba(0,0,0,.06); margin-bottom: 20px; }
        .label-col { color: #6c757d; font-size: 13px; font-weight: 600; text-transform: uppercase; letter-spacing: .5px; }
        .value-col { font-weight: 500; }
        .badge-oid { background: #333; color: white; border-radius: 20px; padding: 4px 14px; font-size: 14px; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/admin/dashboard">FPT BOOK — Admin</a>
        <ul class="navbar-nav ms-auto align-items-center">
            <li class="nav-item">
                <span class="nav-link text-warning">Chào, <strong>${sessionScope.user.displayName}</strong></span>
            </li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/orders">Quản lý đơn hàng</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/products">Quản lý sản phẩm</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/revenue">Doanh thu đơn hàng</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
        </ul>
    </div>
</nav>

<div class="container mt-4" style="max-width: 900px;">

    <%-- Header --%>
    <div class="d-flex align-items-center gap-3 mb-4">
        <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary btn-sm rounded-pill">← Quay lại</a>
        <div>
            <h4 class="fw-bold mb-0">Chi tiết đơn hàng <span class="badge-oid ms-1">#ORD-${order.id}</span></h4>
            <p class="text-muted small mb-0">
                Đặt lúc: <fmt:formatDate value="${order.orderDate}" pattern="HH:mm - dd/MM/yyyy"/>
            </p>
        </div>
    </div>

    <%-- Customer info --%>
    <div class="info-card">
        <h6 class="fw-bold mb-3 pb-2 border-bottom">Thông tin khách hàng</h6>
        <div class="row g-3">
            <div class="col-md-6">
                <div class="label-col mb-1">Tên khách hàng</div>
                <div class="value-col">${order.displayName}</div>
            </div>
            <div class="col-md-6">
                <div class="label-col mb-1">Tài khoản</div>
                <div class="value-col text-muted">${order.username}</div>
            </div>
            <div class="col-md-6">
                <div class="label-col mb-1">Số điện thoại</div>
                <div class="value-col">${order.phone != null ? order.phone : 'Chưa có'}</div>
            </div>
            <div class="col-md-6">
                <div class="label-col mb-1">Địa chỉ giao hàng</div>
                <div class="value-col">${order.address != null ? order.address : 'Chưa có'}</div>
            </div>
        </div>
    </div>

    <%-- Order items --%>
    <div class="info-card">
        <h6 class="fw-bold mb-3 pb-2 border-bottom">Sản phẩm trong đơn</h6>
        <div class="table-responsive">
            <table class="table align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>Sản phẩm</th>
                        <th style="width:80px">Ảnh</th>
                        <th class="text-center">Số lượng</th>
                        <th class="text-end">Đơn giá</th>
                        <th class="text-end">Thành tiền</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${details}" var="d">
                        <tr>
                            <td class="fw-semibold">${d.book.title}</td>
                            <td><img src="${d.book.image}" width="60" class="rounded border" style="object-fit:contain; height:60px;"></td>
                            <td class="text-center">${d.quantity}</td>
                            <td class="text-end"><fmt:formatNumber value="${d.price}" type="number" groupingUsed="true"/> VND</td>
                            <td class="text-end text-danger fw-bold"><fmt:formatNumber value="${d.subTotal}" type="number" groupingUsed="true"/> VND</td>
                        </tr>
                    </c:forEach>
                </tbody>
                <tfoot class="table-light">
                    <tr>
                        <td colspan="4" class="text-end fw-bold">TỔNG ĐƠN HÀNG:</td>
                        <td class="text-end fw-bold text-danger fs-5">
                            <fmt:formatNumber value="${order.totalPrice}" type="number" groupingUsed="true"/> VND
                        </td>
                    </tr>
                </tfoot>
            </table>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>