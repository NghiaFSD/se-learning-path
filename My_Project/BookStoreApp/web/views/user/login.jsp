<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Form dang nhap vao he thong. --%>
<!DOCTYPE html>
<html>
<head>
    <title>Đăng nhập</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-4 card p-4 shadow-sm">
                <h3 class="text-center">ĐĂNG NHẬP</h3>
                <c:if test="${not empty message}">
                    <div class="alert alert-success">${message}</div>
                </c:if>
                <p class="text-danger">${error}</p>
                <form action="${pageContext.request.contextPath}/login" method="post">
                    <div class="mb-3">
                        <label>Tài khoản:</label>
                        <input type="text" name="user" class="form-control" required>
                    </div>
                    <div class="mb-3">
                        <label>Mật khẩu:</label>
                        <input type="password" name="pass" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Đăng nhập</button>
                </form>
                <div class="mt-2 text-center">
                    <a href="${pageContext.request.contextPath}/register">
Chưa có tài khoản? Đăng ký</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>