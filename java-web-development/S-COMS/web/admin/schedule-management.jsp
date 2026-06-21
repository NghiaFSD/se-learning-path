<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý Lịch trực Bác sĩ - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="${pageContext.request.contextPath}/css/admin-ui.css" rel="stylesheet">
    <style>
        .schedule-load-cell {
            min-width: 280px;
        }

        .schedule-load-wrap {
            display: grid;
            grid-template-columns: minmax(120px, 1fr) 66px 96px;
            align-items: center;
            column-gap: 0.5rem;
        }

        .schedule-load-progress {
            height: 10px;
            margin: 0;
        }

        .schedule-load-percent {
            min-width: 66px;
            text-align: center;
            font-weight: 600;
        }

        .schedule-load-state {
            min-width: 96px;
            line-height: 1;
            margin: 0;
            text-align: left;
            white-space: nowrap;
        }
    </style>
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-1">Quản lý Lịch trực Bác sĩ</h3>
            <p class="text-secondary mb-0">FR-ADM-04 và FR-ADM-05</p>
        </div>
        <div class="d-flex gap-2">
            <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin">Dashboard</a>
            <button class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#createScheduleModal">Tạo lịch trực mới</button>
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

    <div class="card mb-3">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin" class="row g-3 align-items-end">
                <input type="hidden" name="action" value="schedule">
                <div class="col-md-3">
                    <label class="form-label">Chuyên khoa</label>
                    <select class="form-select" name="department">
                        <option value="">Tất cả chuyên khoa</option>
                        <c:forEach var="dep" items="${departments}">
                            <option value="${dep}" ${selectedDepartment == dep ? 'selected' : ''}>
                                <c:choose>
                                    <c:when test="${dep == 'Endocrinology'}">Nội tiết - Tiểu đường</c:when>
                                    <c:otherwise>${dep}</c:otherwise>
                                </c:choose>
                            </option>
                        </c:forEach>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label">Tìm theo tên Bác sĩ</label>
                    <input type="text" class="form-control" name="doctorName" placeholder="Nhập tên bác sĩ" value="${doctorNameFilter}">
                </div>
                <div class="col-md-3">
                    <label class="form-label">Ngày trực</label>
                    <input type="date" class="form-control" name="workDate" value="${selectedWorkDate}">
                </div>
                <div class="col-md-2 d-flex gap-2">
                    <button type="submit" class="btn btn-primary w-100">Lọc</button>
                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin?action=schedule">Reset</a>
                </div>
            </form>
        </div>
    </div>

    <div class="card">
        <div class="card-header fw-semibold">Danh sách lịch trực</div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>Tên bác sĩ</th>
                    <th>Chuyên khoa</th>
                    <th>Ngày trực</th>
                    <th>Khung giờ</th>
                    <th>Tải hiện tại (Đã đặt / Tối đa)</th>
                    <th>Mức tải</th>
                    <th>Trạng thái slot</th>
                    <th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:if test="${empty schedules}">
                    <tr>
                        <td colspan="8" class="text-center text-muted py-4">
                            <i class="bi bi-inbox"></i> Không có ca trực nào. Hãy tạo lịch trực mới hoặc thay đổi bộ lọc.
                        </td>
                    </tr>
                </c:if>
                <c:forEach var="s" items="${schedules}">
                    <c:set var="loadPct" value="${s.maxPatients > 0 ? (s.activeAppointments * 100.0 / s.maxPatients) : 0}" />
                    <tr>
                        <td>${s.doctorName}</td>
                        <td>
                            <c:choose>
                                <c:when test="${s.department == 'Endocrinology'}">Nội tiết - Tiểu đường</c:when>
                                <c:otherwise>${s.department}</c:otherwise>
                            </c:choose>
                        </td>
                        <td><fmt:formatDate value="${s.workDate}" pattern="dd/MM/yyyy" /></td>
                        <td>${s.timeSlot}</td>
                        <td><div style="background-color: #f0f8f4; padding: 6px 10px; border-radius: 4px; font-weight: 500; text-align: center;">${s.activeAppointments} / ${s.maxPatients}</div></td>
                        <td class="schedule-load-cell">
                            <div class="schedule-load-wrap" title="${loadPct >= 100 ? 'Quá tải' : (loadPct >= 80 ? 'Cận full' : 'Bình thường')}">
                                <div class="progress schedule-load-progress">
                                    <div class="progress-bar ${loadPct >= 100 ? 'bg-danger' : (loadPct >= 80 ? 'bg-warning' : 'bg-success')}"
                                         role="progressbar"
                                         style="width: ${loadPct > 100 ? 100 : loadPct}%;"
                                         aria-valuemin="0" aria-valuemax="100" aria-valuenow="${loadPct}"></div>
                                </div>
                                <span class="badge schedule-load-percent ${loadPct >= 100 ? 'text-bg-danger' : (loadPct >= 80 ? 'text-bg-warning' : 'text-bg-success')}">
                                    <fmt:formatNumber value="${loadPct}" maxFractionDigits="0"/>%
                                </span>
                                <small class="text-muted schedule-load-state">${loadPct >= 100 ? 'Quá tải' : (loadPct >= 80 ? 'Cận full' : 'Bình thường')}</small>
                            </div>
                        </td>
                        <td>
                            <span class="badge ${s.effectiveStatus == 'Full' ? 'text-bg-danger' : (s.effectiveStatus == 'Cancelled' ? 'text-bg-secondary' : 'text-bg-success')}">
                                <c:if test="${s.effectiveStatus == 'Cancelled'}">
                                    <i class="bi bi-x-circle"></i>
                                </c:if>
                                <c:if test="${s.effectiveStatus == 'Available'}">
                                    <i class="bi bi-check-circle"></i>
                                </c:if>
                                <c:if test="${s.effectiveStatus == 'Full'}">
                                    <i class="bi bi-exclamation-circle"></i>
                                </c:if>
                                <c:choose>
                                    <c:when test="${s.effectiveStatus == 'Cancelled'}">Đã hủy</c:when>
                                    <c:when test="${s.effectiveStatus == 'Available'}">Khả dụng</c:when>
                                    <c:when test="${s.effectiveStatus == 'Full'}">Đã đầy</c:when>
                                    <c:otherwise>${s.effectiveStatus}</c:otherwise>
                                </c:choose>
                            </span>
                        </td>
                        <td>
                            <c:if test="${s.effectiveStatus != 'Cancelled'}">
                                <form method="post" action="${pageContext.request.contextPath}/admin" class="d-inline" onsubmit="return confirm('Bạn chắc chắn muốn hủy ca trực này?');">
                                    <input type="hidden" name="action" value="cancelSchedule">
                                    <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                    <button type="submit" class="btn btn-sm btn-outline-danger"><i class="bi bi-trash"></i> Hủy lịch</button>
                                </form>
                            </c:if>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="createScheduleModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin">
                <input type="hidden" name="action" value="createSchedule">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <div class="modal-header">
                    <h5 class="modal-title">Tạo lịch trực mới</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div class="mb-3">
                        <label class="form-label">Bác sĩ</label>
                        <select class="form-select" name="doctorId" required>
                            <c:forEach var="d" items="${doctors}">
                                <option value="${d.doctorId}">${d.fullName}</option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Ngày trực</label>
                        <input type="date" class="form-control" name="workDate" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Khung giờ</label>
                        <input class="form-control" name="timeSlot" placeholder="07:00-09:00" required>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Số bệnh nhân tối đa</label>
                        <input type="number" class="form-control" name="maxPatients" min="1" required>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">Lưu lịch trực</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>





