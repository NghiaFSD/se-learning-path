<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Form dang ky tai khoan moi. --%>
<!DOCTYPE html>
<html>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<head>
    <meta charset="UTF-8">
    <title>Đăng ký</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-5 card p-4 shadow-sm">
                <h3 class="text-center">ĐĂNG KÝ</h3>
                <c:if test="${not empty error}">
                    <div class="alert alert-danger">${error}</div>
                </c:if>
                <c:if test="${not empty message}">
                    <div class="alert alert-success">${message}</div>
                </c:if>
                <form action="${pageContext.request.contextPath}/register" method="post">
                    <div class="mb-3">
                        <label>Email (username):</label>
                        <input type="email" name="email" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>Tên hiển thị:</label>
                        <input type="text" name="displayName" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>Mật khẩu:</label>
                        <input type="password" name="pass" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>Nhập lại mật khẩu:</label>
                        <input type="password" name="confirmPass" class="form-control" required>
                    </div>
                    <input type="hidden" name="role" value="user" />
                    <button type="submit" class="btn btn-success w-100">Đăng ký</button>
                </form>
                <div class="mt-3 text-center">
                    <a href="${pageContext.request.contextPath}/login">Đã có tài khoản? Đăng nhập</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>