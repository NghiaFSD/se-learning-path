<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />

<%--
    Trang Quản lý lịch trực bác sĩ:
    - Lọc, xem tải ca trực theo bác sĩ/khoa/ngày
    - Tạo ca thủ công và hủy ca
    - Tích hợp modal AI lập lịch (Gemini + fallback)
--%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Quản lý Lịch trực Bác sĩ - S-COMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

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


            .text-purple {
                color: #6f42c1 !important;
            }

            .bg-purple-subtle {
                background: linear-gradient(135deg, rgba(111, 66, 193, 0.12), rgba(139, 92, 246, 0.18)) !important;
            }

            .ai-schedule-toolbar-btn {
                border: 1px solid rgba(111, 66, 193, 0.24);
                box-shadow: 0 8px 18px rgba(111, 66, 193, 0.10);
                transition: transform 0.18s ease, box-shadow 0.18s ease, border-color 0.18s ease;
            }

            .ai-schedule-toolbar-btn:hover,
            .ai-schedule-toolbar-btn:focus {
                color: #5b2fb0 !important;
                border-color: rgba(111, 66, 193, 0.42);
                transform: translateY(-1px);
                box-shadow: 0 12px 24px rgba(111, 66, 193, 0.16);
            }

            .ai-schedule-toolbar-btn:disabled {
                opacity: 0.78;
                transform: none;
                box-shadow: none;
            }

            .ai-schedule-loading {
                border: 1px solid rgba(111, 66, 193, 0.18);
                background: linear-gradient(135deg, rgba(111, 66, 193, 0.10), rgba(13, 202, 240, 0.10));
                color: #4b327f;
                border-radius: 16px;
                animation: ai-schedule-glow 1.25s ease-in-out infinite alternate;
            }

            @keyframes ai-schedule-glow {
                from {
                    box-shadow: 0 0 0 rgba(111, 66, 193, 0);
                }
                to {
                    box-shadow: 0 12px 28px rgba(111, 66, 193, 0.14);
                }
            }

            .ai-generated-row {
                background: linear-gradient(90deg, rgba(111, 66, 193, 0.08), rgba(13, 202, 240, 0.05));
                animation: ai-row-arrive 0.42s ease-out;
            }

            @keyframes ai-row-arrive {
                from {
                    opacity: 0;
                    transform: translateY(-8px);
                }
                to {
                    opacity: 1;
                    transform: translateY(0);
                }
            }

            .ai-schedule-badge {
                background: rgba(111, 66, 193, 0.12);
                color: #5b2fb0;
                border: 1px solid rgba(111, 66, 193, 0.22);
            }
            .schedule-load-state {
                min-width: 96px;
                line-height: 1;
                margin: 0;
                text-align: left;
                white-space: nowrap;
            }

            .ai-step-banner,
            .ai-task-summary {
                border: 1px solid rgba(111, 66, 193, 0.16);
                background: #f8f7fc;
                border-radius: 14px;
            }

            .ai-section-number {
                display: inline-flex;
                width: 28px;
                height: 28px;
                align-items: center;
                justify-content: center;
                border-radius: 50%;
                background: #6f42c1;
                color: #fff;
                font-size: 0.8rem;
                margin-right: 0.55rem;
            }

            .weekday-options {
                display: grid;
                grid-template-columns: repeat(7, minmax(82px, 1fr));
                gap: 0.6rem;
            }

            #aiScheduleModal .modal-dialog {
                max-width: 760px;
            }

            #aiScheduleModal .modal-header,
            #aiScheduleModal .modal-body,
            #aiScheduleModal .modal-footer {
                padding: 0.9rem 1rem;
            }

            #aiScheduleModal .modal-title {
                font-size: 1.35rem;
            }

            #aiScheduleModal .form-label {
                margin-bottom: 0.35rem;
            }

            #aiScheduleModal .ai-section-number {
                width: 24px;
                height: 24px;
                font-size: 0.72rem;
                margin-right: 0.45rem;
            }

            #aiScheduleModal .weekday-option label {
                padding: 0.5rem 0.4rem;
                border-radius: 9px;
            }

            #aiScheduleModal .template-preview {
                max-height: 150px;
            }

            #aiScheduleModal .ai-step-banner,
            #aiScheduleModal .ai-task-summary {
                border-radius: 12px;
            }

            #aiScheduleModal .btn {
                padding-top: 0.45rem;
                padding-bottom: 0.45rem;
            }

            .weekday-option {
                position: relative;
            }

            .weekday-option input {
                position: absolute;
                opacity: 0;
                pointer-events: none;
            }

            .weekday-option label {
                display: block;
                padding: 0.65rem 0.45rem;
                border: 1px solid #dee2e6;
                border-radius: 10px;
                background: #fff;
                text-align: center;
                cursor: pointer;
                transition: 0.18s ease;
            }

            .weekday-option input:checked + label {
                border-color: #6f42c1;
                background: rgba(111, 66, 193, 0.10);
                color: #5b2fb0;
                font-weight: 700;
            }

            .template-preview {
                max-height: 172px;
                resize: none;
                background: #fbfbfd;
            }

            @media (max-width: 767.98px) {
                .weekday-options {
                    grid-template-columns: repeat(4, 1fr);
                }

                #aiScheduleModal .modal-dialog {
                    max-width: calc(100% - 1rem);
                    margin: 0.5rem auto;
                }

                #aiScheduleModal .modal-title {
                    font-size: 1.1rem;
                }

                #aiScheduleModal .modal-body {
                    padding: 0.8rem;
                }
            }
        </style>
    </head>
    <body class="bg-light">
        <div class="container py-4">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div>
                    <h3 class="mb-1">Quản lý Lịch trực Bác sĩ</h3>
                </div>
                <div class="d-flex gap-2">
                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin">Dashboard</a>
                    <button type="button" id="aiScheduleGeminiBtn" class="btn bg-purple-subtle text-purple fw-bold ai-schedule-toolbar-btn" data-bs-toggle="modal" data-bs-target="#aiScheduleModal">
                        <i class="fa-solid fa-brain me-2"></i>AI Lập Lịch (Gemini)
                    </button>
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

            <div id="aiScheduleLoading" class="alert ai-schedule-loading d-none align-items-center gap-2 mb-3">
                <span class="spinner-grow spinner-grow-sm text-purple" aria-hidden="true"></span>
                <span class="fw-semibold">Gemini AI đang phân tích dữ liệu hiệu suất và tự động phân bổ ca trực...</span><span id="aiScheduleLoadingDetail" class="small text-muted ms-2"></span>
            </div>

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
                        <tbody id="scheduleTableBody">
                            <c:if test="${empty schedules}">
                                <tr>
                                    <td colspan="8" class="text-center text-muted py-4">
                                        <i class="bi bi-inbox"></i> Không có ca trực nào. Hãy tạo lịch trực mới hoặc thay đổi bộ lọc.
                                    </td>
                                </tr>
                            </c:if>
                            <c:forEach var="s" items="${schedules}">
                                <c:set var="loadPct" value="${s.maxPatients > 0 ? (s.activeAppointments * 100.0 / s.maxPatients) : 0}" />
                                <tr data-schedule-id="${s.scheduleId}" data-doctor-name="${s.doctorName}" data-department="${s.department}" data-load-pct="${loadPct}" data-active-appointments="${s.activeAppointments}" data-max-patients="${s.maxPatients}">
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
                                        <c:choose>
                                            <c:when test="${s.effectiveStatus == 'Expired'}">
                                                <span class="badge text-bg-secondary">
                                                    <i class="bi bi-clock"></i> Đã qua
                                                </span>
                                            </c:when>

                                            <c:when test="${s.effectiveStatus == 'Cancelled'}">
                                                <span class="badge text-bg-dark">
                                                    <i class="bi bi-x-circle"></i> Đã hủy
                                                </span>
                                            </c:when>

                                            <c:when test="${s.effectiveStatus == 'Full'}">
                                                <span class="badge text-bg-danger">
                                                    <i class="bi bi-exclamation-circle"></i> Đã đầy
                                                </span>
                                            </c:when>

                                            <c:when test="${s.effectiveStatus == 'Available'}">
                                                <span class="badge text-bg-success">
                                                    <i class="bi bi-check-circle"></i> Khả dụng
                                                </span>
                                            </c:when>

                                            <c:otherwise>
                                                <span class="badge text-bg-secondary">
                                                    ${s.effectiveStatus}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${s.effectiveStatus == 'Expired'}">
                                                <button type="button" class="btn btn-sm btn-outline-secondary" disabled>
                                                    <i class="bi bi-clock"></i> Đã qua
                                                </button>
                                            </c:when>

                                            <c:when test="${s.effectiveStatus == 'Cancelled'}">
                                                <button type="button" class="btn btn-sm btn-outline-dark" disabled>
                                                    <i class="bi bi-x-circle"></i> Đã hủy
                                                </button>
                                            </c:when>

                                            <c:otherwise>
                                                <form method="post" action="${pageContext.request.contextPath}/admin" class="d-inline"
                                                      onsubmit="return confirm('Bạn chắc chắn muốn hủy ca trực này?');">
                                                    <input type="hidden" name="action" value="cancelSchedule">
                                                    <input type="hidden" name="scheduleId" value="${s.scheduleId}">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <button type="submit" class="btn btn-sm btn-outline-danger">
                                                        <i class="bi bi-trash"></i> Hủy lịch
                                                    </button>
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


        <div class="modal fade" id="aiScheduleModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content border-0 shadow-lg">
                    <form id="aiScheduleForm">
                        <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                        <div class="modal-header bg-purple-subtle">
                            <div>
                                <h5 class="modal-title text-purple fw-bold mb-1"><i class="fa-solid fa-wand-magic-sparkles me-2"></i>AI LẬP LỊCH THÔNG MINH S-COMS</h5>
                                <div class="small text-secondary">Nhân bản khung lịch rỗng và để Gemini điền bác sĩ phù hợp.</div>
                            </div>
                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <div class="modal-body">
                            <div id="aiScheduleModalAlert" class="ai-step-banner p-3 mb-4 text-purple fw-semibold">
                                <i class="fa-solid fa-circle-info me-2"></i>
                                Bước 1: Nhân bản khung lịch rỗng
                                <i class="fa-solid fa-arrow-right mx-2"></i>
                                Bước 2: Gemini tự động điền bác sĩ
                            </div>
                            <div class="row g-3">
                                <div class="col-12">
                                    <label class="form-label fw-bold">
                                        <span class="ai-section-number">1</span>CHỌN KHUNG MẪU CA TRỰC CÓ SẴN
                                    </label>
                                    <select class="form-select" id="aiScheduleTemplate">
                                        <option value="weekday" selected>Khung ngày thường (6 ca/ngày)</option>
                                        <option value="compact">Khung rút gọn (3 ca/ngày)</option>
                                        <option value="extended">Khung tăng cường (6 ca/ngày)</option>
                                    </select>
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-bold">
                                        <span class="ai-section-number">2</span>CHỌN CÁC NGÀY ÁP DỤNG KHUNG NÀY TRONG TUẦN
                                    </label>
                                    <div class="weekday-options">
                                        <div class="weekday-option"><input type="checkbox" id="weekday1" name="selectedWeekdays" value="1" checked><label for="weekday1">Thứ 2</label></div>
                                        <div class="weekday-option"><input type="checkbox" id="weekday2" name="selectedWeekdays" value="2" checked><label for="weekday2">Thứ 3</label></div>
                                        <div class="weekday-option"><input type="checkbox" id="weekday3" name="selectedWeekdays" value="3" checked><label for="weekday3">Thứ 4</label></div>
                                        <div class="weekday-option"><input type="checkbox" id="weekday4" name="selectedWeekdays" value="4" checked><label for="weekday4">Thứ 5</label></div>
                                        <div class="weekday-option"><input type="checkbox" id="weekday5" name="selectedWeekdays" value="5" checked><label for="weekday5">Thứ 6</label></div>
                                        <div class="weekday-option"><input type="checkbox" id="weekday6" name="selectedWeekdays" value="6"><label for="weekday6">Thứ 7</label></div>
                                        <div class="weekday-option"><input type="checkbox" id="weekday7" name="selectedWeekdays" value="7"><label for="weekday7">Chủ Nhật</label></div>
                                    </div>
                                </div>

                                <div class="col-12">
                                    <label class="form-label fw-bold">
                                        <span class="ai-section-number">3</span>THÔNG TIN PHẠM VI LỊCH TRỰC
                                    </label>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Từ ngày</label>
                                    <input type="date" class="form-control" name="startDate" id="aiStartDate" required>
                                </div>
                                <div class="col-md-6">
                                    <label class="form-label fw-semibold">Đến ngày</label>
                                    <input type="date" class="form-control" name="endDate" id="aiEndDate" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Số bệnh nhân tối đa/ca</label>
                                    <input type="number" class="form-control" name="maxPatients" min="1" max="100" value="20" required>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Số bác sĩ trực mỗi ca</label>
                                    <select class="form-select" name="doctorsPerShift" id="aiDoctorsPerShift" required>
                                        <option value="1" selected>1 bác sĩ/ca</option>
                                        <option value="2">2 bác sĩ/ca</option>
                                        <option value="3">3 bác sĩ/ca</option>
                                        <option value="4">4 bác sĩ/ca</option>
                                    </select>
                                    <div class="form-text">Ví dụ: 6 khung giờ x 2 bác sĩ = 12 slot/ngày.</div>
                                </div>
                                <div class="col-md-4">
                                    <label class="form-label fw-semibold">Tổng số slot bác sĩ phải tạo</label>
                                    <input type="number" class="form-control" name="maxSchedules" id="aiMaxSchedules" value="12" readonly>
                                </div>
                                <div class="col-12">
                                    <label class="form-label fw-semibold">Xem trước khung mẫu ca trực</label>
                                    <textarea class="form-control font-monospace template-preview" name="shiftTemplates" rows="6" required readonly>07:00-09:00|Mắt
09:00-11:00|Nội tiết - Tiểu đường
11:00-13:00|Tim mạch
13:00-15:00|Thần kinh
15:00-17:00|Nội tiết - Tiểu đường
17:00-19:00|Mắt</textarea>
                                </div>
                                <input type="hidden" name="startTime" value="07:00">
                                <input type="hidden" name="endTime" value="19:00">
                                <input type="hidden" name="slotMinutes" value="120">
                                <input type="hidden" name="department" value="">
                                <div class="col-12">
                                    <div class="ai-task-summary p-3">
                                        <div class="fw-bold text-purple mb-1"><i class="fa-solid fa-chart-column me-2"></i>TỔNG QUAN TÁC VỤ</div>
                                        <div id="aiScheduleSummary">Hệ thống sẽ tạo lịch rỗng trước, sau đó Gemini điền bác sĩ đúng chuyên khoa.</div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Hủy bỏ</button>
                            <button type="submit" id="aiScheduleSubmitBtn" class="btn bg-purple-subtle text-purple fw-bold ai-schedule-toolbar-btn">
                                <i class="fa-solid fa-rocket me-2"></i>Tiến hành phân bổ bằng AI
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                                          const adminScheduleEndpoint = '${pageContext.request.contextPath}/admin';

                                                          function escapeHtmlForSchedule(value) {
                                                              const div = document.createElement('div');
                                                              div.textContent = value == null ? '' : String(value);
                                                              return div.innerHTML;
                                                          }

                                                          function getIsoDateOffset(dayOffset) {
                                                              const date = new Date();
                                                              date.setDate(date.getDate() + dayOffset);
                                                              return date.toISOString().slice(0, 10);
                                                          }

                                                          function formatVietnameseDate(isoDate) {
                                                              const parts = String(isoDate || '').split('-');
                                                              if (parts.length !== 3) {
                                                                  return isoDate || '';
                                                              }
                                                              return parts[2] + '/' + parts[1] + '/' + parts[0];
                                                          }


                                                          function countShiftTemplateLines() {
                                                              const textarea = document.querySelector('textarea[name="shiftTemplates"]');
                                                              if (!textarea) {
                                                                  return 0;
                                                              }
                                                              return textarea.value.split(/\r?\n/).filter(line => line.trim().includes('|')).length;
                                                          }

                                                          const scheduleTemplates = {
                                                              weekday: [
                                                                  '07:00-09:00|Mắt',
                                                                  '09:00-11:00|Nội tiết - Tiểu đường',
                                                                  '11:00-13:00|Tim mạch',
                                                                  '13:00-15:00|Thần kinh',
                                                                  '15:00-17:00|Nội tiết - Tiểu đường',
                                                                  '17:00-19:00|Mắt'
                                                              ],
                                                              compact: [
                                                                  '07:00-11:00|Mắt',
                                                                  '11:00-15:00|Nội tiết - Tiểu đường',
                                                                  '15:00-19:00|Tim mạch'
                                                              ],
                                                              extended: [
                                                                  '06:00-09:00|Mắt',
                                                                  '09:00-12:00|Nội tiết - Tiểu đường',
                                                                  '12:00-15:00|Tim mạch',
                                                                  '15:00-18:00|Thần kinh',
                                                                  '18:00-21:00|Nội tiết - Tiểu đường',
                                                                  '21:00-23:00|Mắt'
                                                              ]
                                                          };

                                                          function getSelectedWeekdays() {
                                                              return Array.from(document.querySelectorAll('input[name="selectedWeekdays"]:checked'))
                                                                      .map(input => Number(input.value));
                                                          }

                                                          function countSelectedTargetDates(startValue, endValue) {
                                                              if (!startValue || !endValue) {
                                                                  return 0;
                                                              }
                                                              const selected = new Set(getSelectedWeekdays());
                                                              const cursor = new Date(startValue + 'T00:00:00');
                                                              const end = new Date(endValue + 'T00:00:00');
                                                              let count = 0;
                                                              while (cursor <= end) {
                                                                  const jsDay = cursor.getDay();
                                                                  const isoDay = jsDay === 0 ? 7 : jsDay;
                                                                  if (selected.has(isoDay)) {
                                                                      count++;
                                                                  }
                                                                  cursor.setDate(cursor.getDate() + 1);
                                                              }
                                                              return count;
                                                          }

                                                          function getDoctorsPerShift() {
                                                              const input = document.getElementById('aiDoctorsPerShift');
                                                              const value = input ? Number(input.value) : 1;
                                                              return Number.isFinite(value) && value > 0 ? value : 1;
                                                          }

                                                          function updateAiMaxSchedules() {
                                                              const startDate = document.getElementById('aiStartDate');
                                                              const endDate = document.getElementById('aiEndDate');
                                                              const maxSchedules = document.getElementById('aiMaxSchedules');
                                                              const summary = document.getElementById('aiScheduleSummary');
                                                              if (!startDate || !endDate || !maxSchedules || !startDate.value || !endDate.value) {
                                                                  return;
                                                              }
                                                              const days = countSelectedTargetDates(startDate.value, endDate.value);
                                                              const shifts = countShiftTemplateLines();
                                                              const doctorsPerShift = getDoctorsPerShift();
                                                              const total = days * shifts * doctorsPerShift;
                                                              maxSchedules.value = total;
                                                              if (summary) {
                                                                  summary.textContent = 'Hệ thống sẽ tạo ra: ' + days + ' ngày x ' + shifts
                                                                          + ' ca x ' + doctorsPerShift + ' bác sĩ/ca = ' + total
                                                                          + ' slot lịch trực, sau đó Gemini điền bác sĩ.';
                                                              }
                                                          }
                                                          function setAiScheduleBusy(isBusy) {
                                                              const toolbarButton = document.getElementById('aiScheduleGeminiBtn');
                                                              const submitButton = document.getElementById('aiScheduleSubmitBtn');
                                                              const loadingBox = document.getElementById('aiScheduleLoading');
                                                              const detail = document.getElementById('aiScheduleLoadingDetail');
                                                              if (toolbarButton) {
                                                                  toolbarButton.disabled = isBusy;
                                                              }
                                                              if (submitButton) {
                                                                  submitButton.disabled = isBusy;
                                                                  submitButton.innerHTML = isBusy
                                                                          ? '<span class="spinner-border spinner-border-sm me-2" aria-hidden="true"></span>Gemini đang phân bổ...'
                                                                          : '<i class="fa-solid fa-rocket me-2"></i>Tiến hành phân bổ bằng AI';
                                                              }
                                                              if (loadingBox) {
                                                                  loadingBox.classList.toggle('d-none', !isBusy);
                                                                  loadingBox.classList.toggle('d-flex', isBusy);
                                                              }
                                                              if (detail) {
                                                                  detail.textContent = isBusy ? 'Đang ghi lịch trực thật vào hệ thống...' : '';
                                                              }
                                                          }

                                                          function buildScheduleRow(schedule) {
                                                              const maxPatients = Number(schedule.maxPatients || 20);
                                                              const activeAppointments = Number(schedule.activeAppointments || 0);
                                                              const loadPct = 0;

                                                              const department = schedule.department === 'Endocrinology'
                                                                      ? 'Nội tiết - Tiểu đường'
                                                                      : (schedule.department || 'Chưa xác định');

                                                              const isGemini = schedule.source === 'Gemini AI';
                                                              const sourceLabel = isGemini ? 'Gemini AI tạo lịch' : 'Cân bằng tải dự phòng';
                                                              const sourceIcon = isGemini ? 'fa-brain' : 'fa-scale-balanced';

                                                              const status = schedule.effectiveStatus || schedule.status || 'Available';

                                                              let statusBadge = '<span class="badge text-bg-success"><i class="bi bi-check-circle"></i> Khả dụng</span>';

                                                              if (status === 'Expired') {
                                                                  statusBadge = '<span class="badge text-bg-secondary"><i class="bi bi-clock"></i> Đã qua</span>';
                                                              } else if (status === 'Cancelled') {
                                                                  statusBadge = '<span class="badge text-bg-dark"><i class="bi bi-x-circle"></i> Đã hủy</span>';
                                                              } else if (status === 'Full') {
                                                                  statusBadge = '<span class="badge text-bg-danger"><i class="bi bi-exclamation-circle"></i> Đã đầy</span>';
                                                              }

                                                              let actionColumn = '<span class="badge ai-schedule-badge" title="'
                                                                      + escapeHtmlForSchedule(schedule.reason || '')
                                                                      + '"><i class="fa-solid fa-database me-1"></i>Đã lưu DB</span>';

                                                              if (status === 'Expired') {
                                                                  actionColumn = '<button type="button" class="btn btn-sm btn-outline-secondary" disabled>'
                                                                          + '<i class="bi bi-clock"></i> Đã qua'
                                                                          + '</button>';
                                                              } else if (status === 'Cancelled') {
                                                                  actionColumn = '<button type="button" class="btn btn-sm btn-outline-dark" disabled>'
                                                                          + '<i class="bi bi-x-circle"></i> Đã hủy'
                                                                          + '</button>';
                                                              }

                                                              return '<tr class="ai-generated-row" data-schedule-id="' + (schedule.scheduleId || '') + '" data-doctor-name="' + escapeHtmlForSchedule(schedule.doctorName)
                                                                      + '" data-department="' + escapeHtmlForSchedule(schedule.department || '')
                                                                      + '" data-load-pct="0" data-active-appointments="0" data-max-patients="' + maxPatients + '">'

                                                                      + '<td><span class="fw-semibold">' + escapeHtmlForSchedule(schedule.doctorName)
                                                                      + '</span><div class="small text-purple"><i class="fa-solid ' + sourceIcon + ' me-1"></i>'
                                                                      + sourceLabel + '</div></td>'

                                                                      + '<td>' + escapeHtmlForSchedule(department) + '</td>'

                                                                      + '<td>' + escapeHtmlForSchedule(formatVietnameseDate(schedule.workDate)) + '</td>'

                                                                      + '<td>' + escapeHtmlForSchedule(schedule.timeSlot) + '</td>'

                                                                      + '<td><div style="background-color: #f0f8f4; padding: 6px 10px; border-radius: 4px; font-weight: 500; text-align: center;">'
                                                                      + activeAppointments + ' / ' + maxPatients + '</div></td>'

                                                                      + '<td class="schedule-load-cell">'
                                                                      + '<div class="schedule-load-wrap" title="Bình thường">'
                                                                      + '<div class="progress schedule-load-progress">'
                                                                      + '<div class="progress-bar bg-success" role="progressbar" style="width: ' + loadPct + '%;" aria-valuemin="0" aria-valuemax="100" aria-valuenow="0"></div>'
                                                                      + '</div>'
                                                                      + '<span class="badge schedule-load-percent text-bg-success">0%</span>'
                                                                      + '<small class="text-muted schedule-load-state">Bình thường</small>'
                                                                      + '</div>'
                                                                      + '</td>'

                                                                      + '<td>' + statusBadge + '</td>'

                                                                      + '<td>' + actionColumn + '</td>'

                                                                      + '</tr>';
                                                          }

                                                          function appendCreatedSchedules(schedules) {
                                                              const tbody = document.getElementById('scheduleTableBody');
                                                              if (!tbody || !Array.isArray(schedules) || schedules.length === 0) {
                                                                  return;
                                                              }
                                                              const emptyRow = tbody.querySelector('td[colspan="8"]');
                                                              if (emptyRow) {
                                                                  emptyRow.closest('tr').remove();
                                                              }
                                                              tbody.insertAdjacentHTML('afterbegin', schedules.map(buildScheduleRow).join(''));
                                                          }

                                                          function showAiScheduleMessage(message, isSuccess) {
                                                              const alertBox = document.getElementById('aiScheduleModalAlert');
                                                              if (!alertBox) {
                                                                  return;
                                                              }
                                                              alertBox.className = 'alert border-0 fw-semibold ' + (isSuccess ? 'alert-success' : 'alert-danger');
                                                              alertBox.innerHTML = '<i class="fa-solid ' + (isSuccess ? 'fa-circle-check' : 'fa-triangle-exclamation') + ' me-2"></i>' + escapeHtmlForSchedule(message);
                                                          }

                                                          document.addEventListener('DOMContentLoaded', function () {
                                                              const startDate = document.getElementById('aiStartDate');
                                                              const endDate = document.getElementById('aiEndDate');
                                                              const form = document.getElementById('aiScheduleForm');
                                                              const templateSelect = document.getElementById('aiScheduleTemplate');
                                                              if (startDate && !startDate.value) {
                                                                  startDate.value = getIsoDateOffset(1);
                                                              }
                                                              if (endDate && !endDate.value) {
                                                                  endDate.value = getIsoDateOffset(7);
                                                              }
                                                              const shiftTemplates = document.querySelector('textarea[name="shiftTemplates"]');
                                                              [startDate, endDate, document.getElementById('aiDoctorsPerShift'), ...document.querySelectorAll('input[name="selectedWeekdays"]')].forEach(element => {
                                                                  if (element) {
                                                                      element.addEventListener('input', updateAiMaxSchedules);
                                                                      element.addEventListener('change', updateAiMaxSchedules);
                                                                  }
                                                              });
                                                              if (templateSelect && shiftTemplates) {
                                                                  templateSelect.addEventListener('change', function () {
                                                                      shiftTemplates.value = (scheduleTemplates[this.value] || scheduleTemplates.weekday).join('\n');
                                                                      updateAiMaxSchedules();
                                                                  });
                                                              }
                                                              updateAiMaxSchedules();
                                                              if (!form) {
                                                                  return;
                                                              }

                                                              form.addEventListener('submit', async function (event) {
                                                                  event.preventDefault();
                                                                  const formData = new FormData(form);
                                                                  const params = new URLSearchParams();
                                                                  params.set('action', 'aiCreateSchedules');
                                                                  formData.forEach((value, key) => params.append(key, value));

                                                                  if (getSelectedWeekdays().length === 0) {
                                                                      showAiScheduleMessage('Vui lòng chọn ít nhất một ngày áp dụng trong tuần.', false);
                                                                      return;
                                                                  }
                                                                  if (Number(document.getElementById('aiMaxSchedules').value) <= 0) {
                                                                      showAiScheduleMessage('Khoảng ngày đã chọn không có ngày áp dụng phù hợp.', false);
                                                                      return;
                                                                  }

                                                                  setAiScheduleBusy(true);
                                                                  try {
                                                                      const response = await fetch(adminScheduleEndpoint, {
                                                                          method: 'POST',
                                                                          headers: {
                                                                              'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                                                                              'Accept': 'application/json'
                                                                          },
                                                                          body: params.toString()
                                                                      });
                                                                      if (!response.ok) {
                                                                          throw new Error('HTTP ' + response.status);
                                                                      }
                                                                      const data = await response.json();
                                                                      showAiScheduleMessage(data.message || 'Đã xử lý yêu cầu lập lịch.', data.success);
                                                                      if (data.success) {
                                                                          appendCreatedSchedules(data.items || []);
                                                                          window.setTimeout(() => {
                                                                              const modalEl = document.getElementById('aiScheduleModal');
                                                                              const instance = bootstrap.Modal.getInstance(modalEl);
                                                                              if (instance) {
                                                                                  instance.hide();
                                                                              }
                                                                          }, 900);
                                                                      }
                                                                  } catch (error) {
                                                                      showAiScheduleMessage('Không thể tạo lịch bằng Gemini: ' + error.message, false);
                                                                  } finally {
                                                                      setAiScheduleBusy(false);
                                                                  }
                                                              });
                                                          });
        </script>

        <!-- Modal xem danh sách bệnh nhân của ca trực -->
        <div class="modal fade" id="scheduleAppointmentsModal" tabindex="-1" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title">Danh sách bệnh nhân - Ca trực <span id="appointmentsModalTitle"></span></h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="table-responsive">
                            <table class="table table-hover align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Thời gian</th>
                                        <th>Tên bệnh nhân</th>
                                        <th>Trạng thái khám</th>
                                    </tr>
                                </thead>
                                <tbody id="appointmentsTableBody">
                                    <tr>
                                        <td colspan="3" class="text-center text-muted py-3">
                                            <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                                            Đang tải...
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <script>
            // Event listener bấp vào hàng schedule để xem bệnh nhân
            document.addEventListener('click', function(e) {
                const row = e.target.closest('tbody tr');
                if (!row) return;
                
                // Bỏ qua nếu bấp vào button hoặc form elements
                if (e.target.closest('button') || e.target.closest('form')) return;
                
                // Lấy schedule ID từ data attribute
                const scheduleId = row.dataset.scheduleId;
                const doctorName = row.dataset.doctorName || 'Không xác định';
                const timeSlot = row.querySelector('td:nth-child(4)')?.textContent || '';
                const workDate = row.querySelector('td:nth-child(3)')?.textContent || '';
                
                if (!scheduleId) return;
                
                // Cập nhật tiêu đề modal
                const titleEl = document.getElementById('appointmentsModalTitle');
                if (titleEl) {
                    titleEl.textContent = doctorName + ' (' + workDate + ' ' + timeSlot + ')';
                }
                
                // Mở modal
                const modal = new bootstrap.Modal(document.getElementById('scheduleAppointmentsModal'));
                modal.show();
                
                // Tải danh sách bệnh nhân
                fetch('${pageContext.request.contextPath}/admin?action=scheduleAppointments&scheduleId=' + scheduleId)
                    .then(response => {
                        if (!response.ok) throw new Error('HTTP ' + response.status);
                        return response.json();
                    })
                    .then(data => {
                        const tbody = document.getElementById('appointmentsTableBody');
                        if (!data.items || data.items.length === 0) {
                            tbody.innerHTML = '<tr><td colspan="3" class="text-center text-muted py-3">Chưa có bệnh nhân nào đặt lịch</td></tr>';
                            return;
                        }
                        
                        tbody.innerHTML = data.items.map(item => {
                            const statusBadge = getStatusBadge(item.status);
                            return '<tr>'
                                + '<td><strong>' + escapeHtmlForSchedule(item.appointmentTime || '') + '</strong></td>'
                                + '<td>' + escapeHtmlForSchedule(item.patientName || '') + '</td>'
                                + '<td>' + statusBadge + '</td>'
                                + '</tr>';
                        }).join('');
                    })
                    .catch(error => {
                        const tbody = document.getElementById('appointmentsTableBody');
                        tbody.innerHTML = '<tr><td colspan="3" class="text-center text-danger py-3"><i class="bi bi-exclamation-circle me-2"></i>Lỗi: ' + error.message + '</td></tr>';
                    });
            }, false);
            
            function getStatusBadge(status) {
                const statusMap = {
                    'Waiting': '<span class="badge text-bg-warning"><i class="bi bi-hourglass-split me-1"></i>Chờ đợi</span>',
                    'In_Progress': '<span class="badge text-bg-info"><i class="bi bi-play-circle me-1"></i>Đang khám</span>',
                    'Completed': '<span class="badge text-bg-success"><i class="bi bi-check-circle me-1"></i>Hoàn tất</span>',
                    'No_Show': '<span class="badge text-bg-secondary"><i class="bi bi-x-circle me-1"></i>Không có mặt</span>',
                    'Cancelled': '<span class="badge text-bg-danger"><i class="bi bi-trash me-1"></i>Đã hủy</span>'
                };
                return statusMap[status] || '<span class="badge text-bg-secondary">' + (status || 'Không xác định') + '</span>';
            }
            
            // Hàm escapeHtml để tránh XSS
            function escapeHtmlForSchedule(text) {
                if (!text) return '';
                const div = document.createElement('div');
                div.textContent = text;
                return div.innerHTML;
            }
        </script>
</body>
