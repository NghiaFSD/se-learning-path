<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang dat hang, nhap thong tin giao nhan truoc khi thanh toan. --%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thanh toán</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card shadow-sm p-4">
        <h3 class="fw-bold mb-4">ĐẶT HÀNG</h3>
        <form method="post" action="${pageContext.request.contextPath}/checkout">
            <div class="mb-3">
                <label for="phone" class="form-label">Số điện thoại</label>
                <input type="text" class="form-control" id="phone" name="phone" placeholder="VD: 0912345678"
                       value="${not empty phone ? phone : (not empty param.phone ? param.phone : '')}">
                <c:if test="${not empty phoneError}">
                    <div class="text-danger mt-1">${phoneError}</div>
                </c:if>
            </div>
            <div class="mb-3">
                <label for="address" class="form-label">Địa chỉ giao hàng</label>
                <textarea class="form-control" id="address" name="address" rows="3"
                          placeholder="Số nhà, đường, quận, thành phố">${not empty address ? address : (not empty param.address ? param.address : '')}</textarea>
                <c:if test="${not empty addressError}">
                    <div class="text-danger mt-1">${addressError}</div>
                </c:if>
            </div>
            <div class="mb-3">
                <h5>Tổng thanh toán: <span class="text-danger">${requestScope.total} VND</span></h5>
            </div>
            <div class="d-flex justify-content-between">
                <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">Quay lại giỏ hàng</a>
                <button type="submit" class="btn btn-success">Xác nhận và Đặt hàng</button>
            </div>
        </form>
    </div>
</div>
</body>
</html>