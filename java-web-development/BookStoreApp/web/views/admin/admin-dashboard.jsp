<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang dashboard tong quan danh cho admin. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard — FPT Book</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        body { background-color: #f0f2f5; }
        .stat-link { text-decoration: none; color: inherit; display: block; }
        .stat-card {
            border: none;
            border-radius: 14px;
            padding: 20px 22px;
            color: white;
            min-height: 188px;
            position: relative;
            overflow: hidden;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .stat-link:hover .stat-card {
            transform: translateY(-4px);
            box-shadow: 0 12px 28px rgba(0, 0, 0, 0.18);
        }
        .stat-card .stat-icon {
            position: absolute;
            right: 20px;
            top: 20px;
            font-size: 2.3rem;
            opacity: 0.68;
        }
        .stat-card .stat-title { font-size: 1rem; font-weight: 600; opacity: 0.95; margin-top: 6px; }
        .stat-card .stat-value { font-size: 2.1rem; font-weight: 700; line-height: 1.08; margin-top: 20px; }
        .stat-card .stat-note { font-size: 0.95rem; font-weight: 500; opacity: 0.88; margin-top: 8px; }
        .quick-link-card { border: none; border-radius: 14px; background: white; padding: 20px; text-decoration: none; color: #333; transition: box-shadow 0.2s, transform 0.2s; display: block; }
        .quick-link-card:hover { box-shadow: 0 8px 24px rgba(0,0,0,0.1); transform: translateY(-3px); color: #333; }
        .quick-link-card .ql-icon { font-size: 2rem; margin-bottom: 10px; }
    </style>
</head>
<body>

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid px-4">
        <span class="navbar-brand fw-bold"><i class="bi bi-speedometer2 me-2"></i>FPT BOOK — Admin</span>
        <div class="d-flex align-items-center gap-3">
            <span class="text-white-50 small">Xin chào, <strong class="text-white">${sessionScope.user.displayName}</strong></span>
            <a class="btn btn-outline-danger btn-sm" href="${pageContext.request.contextPath}/logout">
                <i class="bi bi-box-arrow-right"></i> Đăng xuất
            </a>
        </div>
    </div>
</nav>

<div class="container py-5">

    <h3 class="fw-bold mb-1">Tổng quan hệ thống</h3>
    <p class="text-muted mb-4">Cập nhật theo ngày hôm nay</p>

    <%-- Stat cards --%>
    <div class="row g-4 mb-5">
        <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/admin/orders?status=Ch%E1%BB%9D+x%C3%A1c+nh%E1%BA%ADn" class="stat-link">
                <div class="stat-card bg-warning text-dark shadow">
                    <i class="bi bi-hourglass-split stat-icon"></i>
                    <div class="stat-title">Đơn chờ xác nhận</div>
                    <div class="stat-value">${pendingOrders}</div>
                    <div class="stat-note">Cần xử lý sớm</div>
                </div>
            </a>
        </div>
        <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/admin/revenue?year=${todayYear}&month=${todayMonth}&day=${todayDay}" class="stat-link">
                <div class="stat-card bg-primary shadow">
                    <i class="bi bi-graph-up-arrow stat-icon"></i>
                    <div class="stat-title">Hiệu suất hôm nay</div>
                    <div class="stat-value">
                        <fmt:formatNumber value="${todayRevenue}" type="number" maxFractionDigits="0"/> VND
                    </div>
                    <div class="stat-note">${todayOrders} đơn mới trong ngày</div>
                </div>
            </a>
        </div>
        <div class="col-md-4">
            <a href="${pageContext.request.contextPath}/admin/products" class="stat-link">
                <div class="stat-card shadow ${lowStockCount > 0 ? 'bg-danger' : 'bg-secondary'}">
                    <i class="bi bi-exclamation-triangle stat-icon"></i>
                    <div class="stat-title">Sản phẩm tồn kho thấp</div>
                    <div class="stat-value">${lowStockCount}</div>
                    <div class="stat-note">Theo ngưỡng cảnh báo tồn kho</div>
                </div>
            </a>
        </div>
    </div>

    <%-- Quick navigation --%>
    <h5 class="fw-semibold mb-3">Quản lý nhanh</h5>
    <div class="row g-3">
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/admin/orders" class="quick-link-card shadow-sm">
                <div class="ql-icon text-primary"><i class="bi bi-bag-check-fill"></i></div>
                <div class="fw-semibold">Quản lý đơn hàng</div>
                <div class="text-muted small mt-1">Xem, lọc và cập nhật trạng thái đơn</div>
            </a>
        </div>
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/admin/products" class="quick-link-card shadow-sm">
                <div class="ql-icon text-success"><i class="bi bi-book-fill"></i></div>
                <div class="fw-semibold">Quản lý sản phẩm</div>
                <div class="text-muted small mt-1">Thêm, sửa, xóa sách trong kho</div>
            </a>
        </div>
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/admin/revenue" class="quick-link-card shadow-sm">
                <div class="ql-icon text-warning"><i class="bi bi-bar-chart-fill"></i></div>
                <div class="fw-semibold">Báo cáo doanh thu</div>
                <div class="text-muted small mt-1">Thống kê theo ngày / tháng / năm</div>
            </a>
        </div>
        <div class="col-md-3">
            <a href="${pageContext.request.contextPath}/home" class="quick-link-card shadow-sm">
                <div class="ql-icon text-secondary"><i class="bi bi-shop"></i></div>
                <div class="fw-semibold">Xem cửa hàng</div>
                <div class="text-muted small mt-1">Mở trang mua sắm của khách hàng</div>
            </a>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>