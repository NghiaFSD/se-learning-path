<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang hoa don xac nhan dat hang thanh cong. --%>
<!DOCTYPE html>
<html>
<head>
    <title>Hóa đơn thanh toán</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="card shadow p-5 text-center">
            <div class="text-success mb-4">
                <svg xmlns="http://www.w3.org/2000/svg" width="64" height="64" fill="currentColor" class="bi bi-check-circle-fill" viewBox="0 0 16 16">
                    <path d="M16 8A8 8 0 1 1 0 8a8 8 0 0 1 16 0zm-3.97-3.03a.75.75 0 0 0-1.08.022L7.477 9.417 5.384 7.323a.75.75 0 0 0-1.06 1.06L6.97 11.03a.75.75 0 0 0 1.079-.02l3.992-4.99a.75.75 0 0 0-.01-1.05z"/>
                </svg>
            </div>
            <h2>ĐẶT HÀNG THÀNH CÔNG!</h2>
            <p class="lead mt-3">Chào <strong>${sessionScope.user.displayName}</strong>, cảm ơn bạn đã mua hàng.</p>
            <hr>
            <div class="row text-start">
                <div class="col-md-6 mb-3">
                    <h6>Số điện thoại nhận hàng</h6>
                    <p>${phone}</p>
                </div>
                <div class="col-md-6 mb-3">
                    <h6>Địa chỉ giao hàng</h6>
                    <p>${address}</p>
                </div>
            </div>
            <div class="my-4">
                <h5>Tổng số tiền đơn hàng:</h5>
                <h1 class="text-danger fw-bold">${total} VND</h1>
            </div>
            <a href="${pageContext.request.contextPath}/home" class="btn btn-dark px-5 py-2 rounded-pill">Tiếp tục mua sắm</a>
        </div>
    </div>
</body>
</html>