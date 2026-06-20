<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điều phối khẩn cấp và xử lý sự cố - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-1">Điều phối khẩn cấp và xử lý sự cố</h3>
            <p class="text-secondary mb-0">Quản lý hàng đợi kẹt và tái phân bác sĩ thủ công</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin">Dashboard</a>
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
        <div class="card-header fw-semibold">Danh sách ca bệnh đang kẹt trong hàng đợi</div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>Mã lịch hẹn</th>
                    <th>Bệnh nhân</th>
                    <th>Bác sĩ hiện tại</th>
                    <th>Chuyên khoa</th>
                    <th>Trạng thái</th>
                    <th>Thời gian hẹn</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="q" items="${queueItems}">
                    <tr>
                        <td>${q.appointmentId}</td>
                        <td>${q.patientName}</td>
                        <td>${q.currentDoctorName}</td>
                        <td>${q.department}</td>
                        <td><span class="badge text-bg-warning">${q.appointmentStatus}</span></td>
                        <td>${q.appointmentTime}</td>
                        <td>
                            <a class="btn btn-sm btn-outline-primary"
                               href="${pageContext.request.contextPath}/admin?action=exception&appointmentId=${q.appointmentId}&doctorId=${q.currentDoctorId}">
                                Tái điều phối khẩn cấp
                            </a>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>

    <c:if test="${not empty selectedQueueItem}">
        <div class="card">
            <div class="card-header fw-semibold">Danh sách bác sĩ thay thế khả dụng</div>
            <div class="card-body">
                <p class="mb-3">Đang xử lý lịch hẹn <strong>#${selectedQueueItem.appointmentId}</strong> của bệnh nhân <strong>${selectedQueueItem.patientName}</strong>.</p>
                <form method="post" action="${pageContext.request.contextPath}/admin" class="row g-3">
                    <input type="hidden" name="action" value="emergencyReassign">
                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                    <input type="hidden" name="appointmentId" value="${selectedQueueItem.appointmentId}">
                    <div class="col-md-8">
                        <label class="form-label">Chọn bác sĩ tái điều phối</label>
                        <select class="form-select" name="targetDoctorId" required>
                            <c:forEach var="d" items="${candidateDoctors}">
                                <option value="${d.doctorId}">${d.fullName} - ${d.department}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="col-md-4 d-flex align-items-end">
                        <button type="submit" class="btn btn-danger w-100">Xác nhận tái điều phối</button>
                    </div>
                </form>
            </div>
        </div>
    </c:if>
</div>
</body>
</html>
