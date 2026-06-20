<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang admin quan ly tat ca don hang, loc theo trang thai va cap nhat trang thai. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Quản lý đơn hàng</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.10.0/font/bootstrap-icons.css">
    <style>
        .status-cho   { background:#fff3cd; color:#856404; border:1px solid #ffc107; }
        .status-giao  { background:#cfe2ff; color:#084298; border:1px solid #0d6efd; }
        .status-xong  { background:#d1e7dd; color:#0a3622; border:1px solid #198754; }
        .status-huy   { background:#f8d7da; color:#842029; border:1px solid #dc3545; }
        .status-badge { padding:4px 10px; border-radius:20px; font-size:12px; font-weight:600; }
    </style>
</head>
<body class="bg-light">

<nav class="navbar navbar-dark bg-dark">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/admin/dashboard">
            <i class="bi bi-book-half"></i> FPT BOOK — Admin
        </a>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/admin/dashboard">
                <i class="bi bi-speedometer2"></i> Dashboard
            </a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/admin/products">
                <i class="bi bi-box-seam"></i> Sản phẩm
            </a>
            <a class="btn btn-outline-light btn-sm" href="${pageContext.request.contextPath}/admin/revenue">
                <i class="bi bi-bar-chart"></i> Doanh thu
            </a>
        </div>
    </div>
</nav>

<div class="container-fluid px-4 mt-4">

    <c:url var="urlAll" value="orders">
        <c:if test="${selectedYear != null}"><c:param name="year" value="${selectedYear}"/></c:if>
        <c:if test="${selectedMonth != null}"><c:param name="month" value="${selectedMonth}"/></c:if>
        <c:if test="${selectedDay != null}"><c:param name="day" value="${selectedDay}"/></c:if>
    </c:url>
    <c:url var="urlPending" value="orders">
        <c:param name="status" value="Chờ xác nhận"/>
        <c:if test="${selectedYear != null}"><c:param name="year" value="${selectedYear}"/></c:if>
        <c:if test="${selectedMonth != null}"><c:param name="month" value="${selectedMonth}"/></c:if>
        <c:if test="${selectedDay != null}"><c:param name="day" value="${selectedDay}"/></c:if>
    </c:url>
    <c:url var="urlShipping" value="orders">
        <c:param name="status" value="Đang giao"/>
        <c:if test="${selectedYear != null}"><c:param name="year" value="${selectedYear}"/></c:if>
        <c:if test="${selectedMonth != null}"><c:param name="month" value="${selectedMonth}"/></c:if>
        <c:if test="${selectedDay != null}"><c:param name="day" value="${selectedDay}"/></c:if>
    </c:url>
    <c:url var="urlDone" value="orders">
        <c:param name="status" value="Hoàn thành"/>
        <c:if test="${selectedYear != null}"><c:param name="year" value="${selectedYear}"/></c:if>
        <c:if test="${selectedMonth != null}"><c:param name="month" value="${selectedMonth}"/></c:if>
        <c:if test="${selectedDay != null}"><c:param name="day" value="${selectedDay}"/></c:if>
    </c:url>
    <c:url var="urlCancelled" value="orders">
        <c:param name="status" value="Đã hủy"/>
        <c:if test="${selectedYear != null}"><c:param name="year" value="${selectedYear}"/></c:if>
        <c:if test="${selectedMonth != null}"><c:param name="month" value="${selectedMonth}"/></c:if>
        <c:if test="${selectedDay != null}"><c:param name="day" value="${selectedDay}"/></c:if>
    </c:url>

    <%-- Bo loc theo trang thai --%>
    <div class="card shadow-sm p-3 mb-4">
        <form method="get" action="${pageContext.request.contextPath}/admin/orders" class="row g-2 align-items-end mb-3">
            <input type="hidden" name="status" value="${selectedStatus}">
            <div class="col-auto">
                <label class="form-label small text-muted mb-1">Năm</label>
                <select name="year" class="form-select form-select-sm" style="width:120px">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="y" begin="2023" end="2030">
                        <option value="${y}" <c:if test="${selectedYear == y}">selected</c:if>>${y}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-auto">
                <label class="form-label small text-muted mb-1">Tháng</label>
                <select name="month" class="form-select form-select-sm" style="width:120px">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="m" begin="1" end="12">
                        <option value="${m}" <c:if test="${selectedMonth == m}">selected</c:if>>Tháng ${m}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-auto">
                <label class="form-label small text-muted mb-1">Ngày</label>
                <select name="day" class="form-select form-select-sm" style="width:120px">
                    <option value="">-- Tất cả --</option>
                    <c:forEach var="d" begin="1" end="31">
                        <option value="${d}" <c:if test="${selectedDay == d}">selected</c:if>>${d}</option>
                    </c:forEach>
                </select>
            </div>
            <div class="col-auto">
                <button type="submit" class="btn btn-dark btn-sm px-4">Lọc thời gian</button>
                <a href="${pageContext.request.contextPath}/admin/orders" class="btn btn-outline-secondary btn-sm px-4 ms-1">ĐẶt lại</a>
            </div>
        </form>
        <div class="d-flex flex-wrap gap-2 align-items-center">
            <span class="fw-bold me-2">Lọc trạng thái:</span>
            <a href="${urlAll}" class="btn btn-sm ${empty selectedStatus ? 'btn-dark' : 'btn-outline-dark'}">
                Tất cả
            </a>
            <a href="${urlPending}"
               class="btn btn-sm ${selectedStatus == 'Chờ xác nhận' ? 'btn-warning' : 'btn-outline-warning'}">
                Chờ xác nhận
            </a>
            <a href="${urlShipping}"
               class="btn btn-sm ${selectedStatus == 'Đang giao' ? 'btn-primary' : 'btn-outline-primary'}">
                Đang giao
            </a>
            <a href="${urlDone}"
               class="btn btn-sm ${selectedStatus == 'Hoàn thành' ? 'btn-success' : 'btn-outline-success'}">
                Hoàn thành
            </a>
            <a href="${urlCancelled}"
               class="btn btn-sm ${selectedStatus == 'Đã hủy' ? 'btn-danger' : 'btn-outline-danger'}">
                Đã hủy
            </a>
        </div>
    </div>

    <%-- Bang don hang --%>
    <div class="card shadow-sm">
        <div class="card-header bg-dark text-white d-flex justify-content-between align-items-center">
            <h5 class="mb-0"><i class="bi bi-list-ul"></i> Danh sách đơn hàng
                <c:if test="${not empty selectedStatus}">
                    — <span class="text-warning">${selectedStatus}</span>
                </c:if>
                <c:if test="${selectedYear != null || selectedMonth != null || selectedDay != null}">
                    <span class="text-info">
                        —
                        <c:if test="${selectedDay != null}">Ngày ${selectedDay} </c:if>
                        <c:if test="${selectedMonth != null}">Tháng ${selectedMonth} </c:if>
                        <c:if test="${selectedYear != null}">Năm ${selectedYear}</c:if>
                    </span>
                </c:if>
            </h5>
            <span class="badge bg-secondary">${fn:length(orders)} đơn</span>
        </div>
        <div class="card-body p-0">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-secondary">
                        <tr>
                            <th class="ps-3">Mã đơn</th>
                            <th>Khách hàng</th>
                            <th>SĐT</th>
                            <th>Ngày đặt</th>
                            <th class="text-end">Tổng tiền</th>
                            <th class="text-center">Trạng thái hiện tại</th>
                            <th class="text-center">Cập nhật trạng thái</th>
                            <th class="text-center">Chi tiết</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach items="${orders}" var="o">
                            <tr>
                                <td class="ps-3 fw-bold">#ORD-${o.id}</td>
                                <td>${empty o.displayName ? o.username : o.displayName}</td>
                                <td>${o.phone}</td>
                                <td>
                                    <fmt:formatDate value="${o.orderDate}" pattern="dd/MM/yyyy HH:mm"/>
                                </td>
                                <td class="text-end fw-bold text-danger">
                                    <fmt:formatNumber value="${o.totalPrice}" type="number"/> VND
                                </td>
                                <%-- Badge trang thai --%>
                                <td class="text-center">
                                    <c:choose>
                                        <c:when test="${o.status == 'Chờ xác nhận'}">
                                            <span class="status-badge status-cho">Chờ xác nhận</span>
                                        </c:when>
                                        <c:when test="${o.status == 'Đang giao'}">
                                            <span class="status-badge status-giao">Đang giao</span>
                                        </c:when>
                                        <c:when test="${o.status == 'Hoàn thành'}">
                                            <span class="status-badge status-xong">Hoàn thành</span>
                                        </c:when>
                                        <c:when test="${o.status == 'Đã hủy'}">
                                            <span class="status-badge status-huy">Đã hủy</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="badge bg-secondary">${o.status}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <%-- Form cap nhat trang thai --%>
                                <td class="text-center">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/orders"
                                          class="d-flex gap-1 justify-content-center">
                                        <input type="hidden" name="oid" value="${o.id}">
                                        <input type="hidden" name="filterStatus" value="${selectedStatus}">
                                                                                <input type="hidden" name="filterYear" value="${selectedYear}">
                                                                                <input type="hidden" name="filterMonth" value="${selectedMonth}">
                                                                                <input type="hidden" name="filterDay" value="${selectedDay}">
                                        <select name="status" class="form-select form-select-sm" style="width:150px">
                                            <option value="Chờ xác nhận" ${o.status == 'Chờ xác nhận' ? 'selected' : ''}>Chờ xác nhận</option>
                                            <option value="Đang giao"    ${o.status == 'Đang giao'    ? 'selected' : ''}>Đang giao</option>
                                            <option value="Hoàn thành"   ${o.status == 'Hoàn thành'   ? 'selected' : ''}>Hoàn thành</option>
                                            <option value="Đã hủy"       ${o.status == 'Đã hủy'       ? 'selected' : ''}>Đã hủy</option>
                                        </select>
                                        <button type="submit" class="btn btn-sm btn-primary">
                                            <i class="bi bi-check-lg"></i>
                                        </button>
                                    </form>
                                </td>
                                <td class="text-center">
                                    <a href="${pageContext.request.contextPath}/admin/order-detail?oid=${o.id}"
                                       class="btn btn-sm btn-outline-secondary">
                                        <i class="bi bi-eye"></i>
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty orders}">
                            <tr>
                                <td colspan="8" class="text-center py-5 text-muted">
                                    <i class="bi bi-inbox fs-3 d-block mb-2"></i>
                                    Không có đơn hàng nào
                                    <c:if test="${not empty selectedStatus}">
                                        với trạng thái "<strong>${selectedStatus}</strong>"
                                    </c:if>
                                </td>
                            </tr>
                        </c:if>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>