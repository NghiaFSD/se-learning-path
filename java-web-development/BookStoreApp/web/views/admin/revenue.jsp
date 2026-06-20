<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang admin thong ke doanh thu va loc don hang theo ngay/thang/nam. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Doanh thu đơn hàng - Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        :root { --primary: #ff6b6b; --dark: #333; }
        body { background: #f8f9fa; font-family: 'Segoe UI', sans-serif; }
        .stat-card { border: none; border-radius: 14px; padding: 22px 28px; color: white; }
        .stat-card.actual { background: linear-gradient(135deg, #2f9e44, #1c7c36); }
        .stat-card.projected { background: linear-gradient(135deg, #f08c00, #d9480f); }
        .stat-card.orders  { background: linear-gradient(135deg, #4dabf7, #228be6); }
        .filter-card { background: white; border-radius: 14px; padding: 24px; box-shadow: 0 4px 15px rgba(0,0,0,.06); margin-bottom: 24px; }
        .table-card  { background: white; border-radius: 14px; padding: 24px; box-shadow: 0 4px 15px rgba(0,0,0,.06); }
        .badge-status { font-size: 12px; padding: 5px 12px; border-radius: 20px; }
        .btn-detail { background: var(--dark); color: white; border-radius: 20px; font-size: 13px; padding: 5px 16px; border: none; }
        .btn-detail:hover { background: var(--primary); color: white; }
        select.form-select { border-radius: 8px; }
    </style>
</head>
<body>

<nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/admin/dashboard">FPT BOOK</a>
        <ul class="navbar-nav ms-auto align-items-center">
            <li class="nav-item">
                <span class="nav-link text-warning">Chào, <strong>${sessionScope.user.displayName}</strong></span>
            </li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Dashboard</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/products">Quản lý sản phẩm</a></li>
            <li class="nav-item"><a class="nav-link active fw-bold text-warning" href="${pageContext.request.contextPath}/admin/revenue">Doanh thu đơn hàng</a></li>
            <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
        </ul>
    </div>
</nav>

<div class="container mt-4">

    <%-- Tiêu đề --%>
    <div class="d-flex align-items-center mb-4">
        <div>
            <h3 class="fw-bold mb-0">Doanh thu đơn hàng</h3>
            <p class="text-muted mb-0">Quản lý và thống kê doanh thu theo thời gian</p>
        </div>
    </div>

    <%-- Stat cards --%>
    <div class="row g-3 mb-4">
        <div class="col-md-4">
            <div class="stat-card actual">
                <div class="fs-6 opacity-75">Doanh thu thực tế</div>
                <div class="fs-3 fw-bold mt-1">
                    <fmt:formatNumber value="${actualRevenue}" type="number" groupingUsed="true"/> VND
                </div>
                <div class="fs-6 opacity-75 mt-1">
                    Chỉ tính đơn <strong>Hoàn thành</strong>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card projected">
                <div class="fs-6 opacity-75">Doanh thu dự kiến</div>
                <div class="fs-3 fw-bold mt-1">
                    <fmt:formatNumber value="${projectedRevenue}" type="number" groupingUsed="true"/> VND
                </div>
                <div class="fs-6 opacity-75 mt-1">
                    Đơn <strong>Chờ xác nhận</strong> và <strong>Đang giao</strong>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="stat-card orders">
                <div class="fs-6 opacity-75">Số đơn hàng</div>
                <div class="fs-3 fw-bold mt-1">${orders.size()}</div>
                <div class="fs-6 opacity-75 mt-1">
                    <c:choose>
                        <c:when test="${selectedYear != null}">
                            Năm ${selectedYear}
                            <c:if test="${selectedMonth != null}"> / Tháng ${selectedMonth}</c:if>
                            <c:if test="${selectedDay   != null}"> / Ngày ${selectedDay}</c:if>
                        </c:when>
                        <c:otherwise>Toàn bộ thời gian</c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>

    <div class="alert alert-info border-0 shadow-sm" role="alert">
        Quy ước tính doanh thu: <strong>Hoàn thành</strong> = doanh thu thực tế, <strong>Chờ xác nhận</strong> và <strong>Đang giao</strong> = doanh thu dự kiến, <strong>Đã hủy</strong> = không tính.
    </div>

    <%-- Filter form --%>
    <div class="filter-card">
        <h6 class="fw-bold mb-3">Lọc theo thời gian</h6>
        <form method="get" action="${pageContext.request.contextPath}/admin/revenue" class="row g-3 align-items-end">
            <div class="col-auto">
                <label class="form-label text-muted small mb-1">Năm</label>
                <select name="year" class="form-select form-select-sm" style="width:120px">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="y" begin="2023" end="2030">
                        <option value="${y}" <c:if test="${selectedYear == y}">selected</c:if>>${y}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-auto">
                <label class="form-label text-muted small mb-1">Tháng</label>
                <select name="month" class="form-select form-select-sm" style="width:120px">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="m" begin="1" end="12">
                        <option value="${m}" <c:if test="${selectedMonth == m}">selected</c:if>>Tháng ${m}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-auto">
                <label class="form-label text-muted small mb-1">Ngày</label>
                <select name="day" class="form-select form-select-sm" style="width:120px">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="d" begin="1" end="31">
                        <option value="${d}" <c:if test="${selectedDay == d}">selected</c:if>>${d}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-dark btn-sm px-4 rounded-pill">Xem</button>
                <a href="${pageContext.request.contextPath}/admin/revenue" class="btn btn-outline-secondary btn-sm px-4 rounded-pill ms-1">Đặt lại</a>
            </div>
        </form>
    </div>

    <%-- Orders table --%>
    <div class="table-card">
        <h6 class="fw-bold mb-3">Danh sách đơn hàng</h6>
        <c:choose>
            <c:when test="${empty orders}">
                <div class="text-center py-5 text-muted">
                    <div style="font-size:48px">📦</div>
                    <p class="mt-2">Không có đơn hàng nào trong khoảng thời gian này.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-dark">
                            <tr>
                                <th>#Đơn</th>
                                <th>Ngày đặt</th>
                                <th>Khách hàng</th>
                                <th>SĐT</th>
                                <th>Địa chỉ</th>
                                <th class="text-center">Trạng thái</th>
                                <th class="text-end">Tổng tiền</th>
                                <th class="text-center">Chi tiết</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${orders}" var="o">
                                <tr>
                                    <td class="fw-bold text-muted">#ORD-${o.id}</td>
                                    <td>
                                        <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                    </td>
                                    <td>
                                        <div class="fw-semibold">${o.displayName}</div>
                                        <div class="text-muted small">${o.username}</div>
                                    </td>
                                    <td>${o.phone != null ? o.phone : '-'}</td>
                                    <td style="max-width:200px; white-space:nowrap; overflow:hidden; text-overflow:ellipsis" title="${o.address}">
                                        ${o.address != null ? o.address : '-'}
                                    </td>
                                    <td class="text-center">
                                        <c:choose>
                                            <c:when test="${o.status == 'Hoàn thành'}">
                                                <span class="badge bg-success badge-status">${o.status}</span>
                                            </c:when>
                                            <c:when test="${o.status == 'Chờ xác nhận'}">
                                                <span class="badge bg-warning text-dark badge-status">${o.status}</span>
                                            </c:when>
                                            <c:when test="${o.status == 'Đang giao'}">
                                                <span class="badge bg-primary badge-status">${o.status}</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge bg-danger badge-status">${o.status}</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-end text-danger fw-bold">
                                        <fmt:formatNumber value="${o.totalPrice}" type="number" groupingUsed="true"/> VND
                                    </td>
                                    <td class="text-center">
                                        <a href="${pageContext.request.contextPath}/admin/order-detail?oid=${o.id}" class="btn-detail btn">Xem</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                        <tfoot class="table-light">
                            <tr>
                                <td colspan="6" class="fw-bold text-end">DOANH THU THỰC TẾ:</td>
                                <td class="text-end fw-bold text-success fs-5">
                                    <fmt:formatNumber value="${actualRevenue}" type="number" groupingUsed="true"/> VND
                                </td>
                                <td></td>
                            </tr>
                            <tr>
                                <td colspan="6" class="fw-bold text-end">DOANH THU DỰ KIẾN:</td>
                                <td class="text-end fw-bold" style="color:#d9480f; font-size:1.25rem;">
                                    <fmt:formatNumber value="${projectedRevenue}" type="number" groupingUsed="true"/> VND
                                </td>
                                <td></td>
                            </tr>
                        </tfoot>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>