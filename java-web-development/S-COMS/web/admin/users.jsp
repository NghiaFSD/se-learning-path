<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${empty users and empty errorMessage}">
    <c:redirect url="/admin?action=listUsers"/>
</c:if>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tài khoản và phân quyền - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-1">Hệ thống Điều hành & Quản trị Danh mục S-COMS</h3>
            <p class="text-secondary mb-0">FR-ADM-01, FR-ADM-02: Quản lý tài khoản và phân quyền</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin">Tổng quan</a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin?action=manageServices">Danh mục</a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin?action=manageSchedules">Lịch trực</a>
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin?action=reports">Báo cáo</a>
        </div>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <% session.removeAttribute("successMessage"); %>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger">${sessionScope.errorMessage}</div>
        <% session.removeAttribute("errorMessage"); %>
    </c:if>

    <div class="card mb-4">
        <div class="card-header fw-semibold">Tạo tài khoản nhân sự</div>
        <div class="card-body">
            <form class="row g-3" method="post" action="${pageContext.request.contextPath}/admin">
                <input type="hidden" name="action" value="createAccount">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <div class="col-md-3"><label class="form-label">Họ và tên</label><input class="form-control" name="fullName" required></div>
                <div class="col-md-3"><label class="form-label">Email</label><input type="email" class="form-control" name="email" required></div>
                <div class="col-md-2"><label class="form-label">Mật khẩu</label><input type="password" class="form-control" name="password" required></div>
                <div class="col-md-2">
                    <label class="form-label">Vai trò hệ thống</label>
                    <select class="form-select" name="role" required>
                        <option value="Patient">Bệnh nhân</option>
                        <option value="Doctor">Bác sĩ</option>
                        <option value="Receptionist">Lễ tân</option>
                        <option value="Admin">Quản trị viên</option>
                    </select>
                </div>
                <div class="col-md-2 d-flex align-items-end"><button class="btn btn-primary w-100" type="submit">Tạo</button></div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header fw-semibold">Danh sách tài khoản</div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>ID</th><th>Họ tên</th><th>Email</th><th>Vai trò</th><th>Trạng thái</th><th>Ngày tạo</th><th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="u" items="${users}">
                    <tr>
                        <td>${u.id}</td>
                        <td>${u.fullName}</td>
                        <td>${u.email}</td>
                        <td>
                            <form class="d-flex gap-2" method="post" action="${pageContext.request.contextPath}/admin">
                                <input type="hidden" name="action" value="updateAccountRole">
                                <input type="hidden" name="accountId" value="${u.id}">
                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                <select class="form-select form-select-sm" name="role">
                                    <option value="Patient" ${u.role == 'Patient' ? 'selected' : ''}>Bệnh nhân</option>
                                    <option value="Doctor" ${u.role == 'Doctor' ? 'selected' : ''}>Bác sĩ</option>
                                    <option value="Receptionist" ${u.role == 'Receptionist' ? 'selected' : ''}>Lễ tân</option>
                                    <option value="Admin" ${u.role == 'Admin' ? 'selected' : ''}>Quản trị viên</option>
                                </select>
                                <button class="btn btn-sm btn-outline-primary" type="submit">Lưu</button>
                            </form>
                        </td>
                        <td>
                            <c:choose>
                                <c:when test="${u.status == 'Active'}"><span class="badge text-bg-success">Hoạt động</span></c:when>
                                <c:when test="${u.status == 'Locked'}"><span class="badge text-bg-warning">Đã khóa</span></c:when>
                                <c:otherwise><span class="badge text-bg-secondary">${u.status}</span></c:otherwise>
                            </c:choose>
                        </td>
                        <td>${u.createdAt}</td>
                        <td>
                            <c:choose>
                                <c:when test="${u.status == 'Locked'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin">
                                        <input type="hidden" name="action" value="reactivateAccount">
                                        <input type="hidden" name="accountId" value="${u.id}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button class="btn btn-sm btn-outline-success" type="submit">Kích hoạt lại</button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <form method="post" action="${pageContext.request.contextPath}/admin">
                                        <input type="hidden" name="action" value="lockAccount">
                                        <input type="hidden" name="accountId" value="${u.id}">
                                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                        <button class="btn btn-sm btn-outline-warning" type="submit">Khóa</button>
                                    </form>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>
</body>
</html>
