<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang hien thi cac dong chi tiet cua mot don hang. --%>
<!DOCTYPE html>
<html>
<head>
    <title>Chi tiết đơn hàng #${orderID}</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card shadow-sm p-4">
        <h3 class="fw-bold mb-4">CHI TIẾT ĐƠN HÀNG #ORD-${orderID}</h3>

        <%-- Thong tin giao hang cua don --%>
        <div class="row g-3 mb-4">
            <div class="col-md-6">
                <div class="border rounded p-3 h-100">
                    <h6 class="fw-bold text-secondary mb-2">THÔNG TIN GIAO HÀNG</h6>
                    <p class="mb-1"><strong>Số điện thoại:</strong> ${order.phone}</p>
                    <p class="mb-0"><strong>Địa chỉ:</strong> ${order.address}</p>
                </div>
            </div>
            <div class="col-md-6">
                <div class="border rounded p-3 h-100">
                    <h6 class="fw-bold text-secondary mb-2">THÔNG TIN ĐƠN HÀNG</h6>
                    <p class="mb-1"><strong>Ngày đặt:</strong> ${order.orderDate}</p>
                    <p class="mb-1"><strong>Tổng tiền:</strong>
                        <span class="text-danger fw-bold"><fmt:formatNumber value="${order.totalPrice}" pattern="#,##0" /> ₫</span>
                    </p>
                    <p class="mb-0"><strong>Trạng thái:</strong>
                        <c:choose>
                            <c:when test="${order.status == 'Chờ xác nhận'}">
                                <span class="badge" style="background:#fff3cd;color:#856404">Chờ xác nhận</span>
                            </c:when>
                            <c:when test="${order.status == 'Đang giao'}">
                                <span class="badge bg-primary">Đang giao</span>
                            </c:when>
                            <c:when test="${order.status == 'Hoàn thành'}">
                                <span class="badge bg-success">Hoàn thành</span>
                            </c:when>
                            <c:when test="${order.status == 'Đã hủy'}">
                                <span class="badge bg-danger">Đã hủy</span>
                            </c:when>
                            <c:otherwise>
                                <span class="badge bg-secondary">${order.status}</span>
                            </c:otherwise>
                        </c:choose>
                    </p>
                </div>
            </div>
        </div>

        <h5 class="fw-bold mb-3">Sản phẩm đã đặt</h5>
        <table class="table align-middle">
            <thead class="table-dark">
                <tr>
                    <th>Sản phẩm</th>
                    <th>Hình ảnh</th>
                    <th>Giá mua</th>
                    <th>Số lượng</th>
                    <th>Thành tiền</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${details}" var="d">
                    <tr>
                        <td class="fw-bold">${d.book.title}</td>
                        <td><img src="${d.book.image}" width="60" class="rounded border"></td>
                        <td><fmt:formatNumber value="${d.price}" pattern="#,##0" /> ₫</td>
                        <td>${d.quantity}</td>
                        <td class="text-danger fw-bold"><fmt:formatNumber value="${d.subTotal}" pattern="#,##0" /> ₫</td>
                    </tr>
                </c:forEach>
            </tbody>
        </table>
        <div class="mt-3">
            <a href="${pageContext.request.contextPath}/history" class="btn btn-secondary">Quay lại lịch sử</a>
        </div>
    </div>
</div>
</body>
</html>