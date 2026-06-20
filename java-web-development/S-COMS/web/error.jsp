<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Lỗi Hệ Thống</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-8">
                <div class="card border-danger">
                    <div class="card-header bg-danger text-white">
                        <h4 class="mb-0"><i class="bi bi-exclamation-triangle"></i> Đã xảy ra lỗi</h4>
                    </div>
                    <div class="card-body">
                        <h5>Chi tiết lỗi:</h5>
                        <div class="alert alert-danger">
                            <strong>Exception:</strong> <%= exception %><br>
                            <strong>Message:</strong> <%= exception != null ? exception.getMessage() : "Không có thông tin" %>
                        </div>
                        
                        <h6>Stack Trace:</h6>
                        <pre class="bg-dark text-light p-3" style="font-size: 12px; max-height: 400px; overflow: auto;">
<%
if (exception != null) {
    java.io.StringWriter sw = new java.io.StringWriter();
    java.io.PrintWriter pw = new java.io.PrintWriter(sw);
    exception.printStackTrace(pw);
    out.print(sw.toString());
}
%>
                        </pre>
                        
                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="btn btn-primary">
                                <i class="bi bi-house"></i> Về Dashboard
                            </a>
                            <a href="javascript:history.back()" class="btn btn-secondary">
                                <i class="bi bi-arrow-left"></i> Quay lại
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
