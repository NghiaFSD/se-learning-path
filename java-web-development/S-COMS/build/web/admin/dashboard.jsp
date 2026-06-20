<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<%
    if (request.getAttribute("totalAccounts") == null) {
        response.sendRedirect(request.getContextPath() + "/admin");
        return;
    }
%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Bảng điều hành quản trị - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        .queue-monitor-card {
            border: 0;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }

        .queue-row {
            transition: background-color 0.2s ease, transform 0.2s ease;
        }

        .queue-row:hover {
            background-color: #f1f3f5;
            cursor: pointer;
        }

        .queue-load-badge,
        .queue-summary-badge {
            border-radius: 20px;
            font-weight: 600;
            padding: 0.45rem 0.8rem;
            letter-spacing: 0.01em;
        }

        .animate-pulse {
            animation: pulse-alert 1.4s ease-in-out infinite;
        }

        @keyframes pulse-alert {
            0% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.45); }
            70% { box-shadow: 0 0 0 10px rgba(220, 53, 69, 0); }
            100% { box-shadow: 0 0 0 0 rgba(220, 53, 69, 0); }
        }

        .reserve-doctor-item {
            border: 1px solid #e9ecef;
            border-radius: 10px;
            padding: 0.85rem 1rem;
            margin-bottom: 0.75rem;
            transition: border-color 0.2s ease, background-color 0.2s ease;
        }

        .reserve-doctor-item:hover {
            border-color: #86b7fe;
            background-color: #f8fbff;
        }

        .kpi-card {
            border: 0;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.04);
            opacity: 0;
            transform: translateY(18px);
            transition: opacity 0.55s ease, transform 0.55s ease, box-shadow 0.25s ease;
        }

        .kpi-card.is-visible {
            opacity: 1;
            transform: translateY(0);
        }

        .kpi-card:hover {
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.08);
        }

        .dashboard-clickable-card {
            cursor: pointer;
        }

        .kpi-value {
            font-variant-numeric: tabular-nums;
            letter-spacing: 0.01em;
        }

        .quick-modal-table td,
        .quick-modal-table th {
            vertical-align: middle;
        }

        .quick-action-btn {
            min-width: 92px;
        }

        .daily-widget-card {
            border: 0;
            border-radius: 14px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            background: #ffffff;
        }

        .daily-widget-clickable {
            cursor: pointer;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .daily-widget-clickable:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 18px rgba(0, 0, 0, 0.09);
        }

        .daily-widget-title {
            font-size: 0.92rem;
            color: #5f6b7a;
            margin-bottom: 0.35rem;
        }

        .daily-widget-value {
            font-size: 1.6rem;
            line-height: 1.2;
            font-weight: 700;
            color: #1f2d3d;
            font-variant-numeric: tabular-nums;
        }

        .chart-panel {
            border: 0;
            border-radius: 14px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.06);
            background: #ffffff;
        }

        .chart-panel .card-title {
            font-size: 0.98rem;
            font-weight: 600;
            margin-bottom: 0.75rem;
            color: #27384d;
        }

        .chart-canvas-wrap {
            position: relative;
            height: 260px;
        }

        .status-badge-soft {
            border-radius: 12px;
            padding: 6px 12px;
            font-weight: 600;
            display: inline-block;
        }
    </style>
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h3 class="mb-1">Hệ thống Điều hành & Quản trị Danh mục S-COMS</h3>
            <p class="text-secondary mb-0">Bảng điều hành quản trị theo chuẩn FR-ADM và BR-08</p>
        </div>
        <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-danger">Đăng xuất</a>
    </div>

    <c:if test="${not empty sessionScope.successMessage}">
        <div class="alert alert-success">${sessionScope.successMessage}</div>
        <% session.removeAttribute("successMessage"); %>
    </c:if>
    <c:if test="${not empty sessionScope.errorMessage}">
        <div class="alert alert-danger">${sessionScope.errorMessage}</div>
        <% session.removeAttribute("errorMessage"); %>
    </c:if>

    <div class="alert alert-warning">
        BR-08: Admin không phân luồng khám thường hàng loạt; luồng xếp hàng khám do Appointment và vai trò vận hành xử lý.
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openAccountQuickModal('all')"><div class="card-body"><h6>Tổng tài khoản</h6><h4 id="kpiTotalAccounts" class="kpi-value">${totalAccounts}</h4></div></div></div>
        <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openAccountQuickModal('active')"><div class="card-body"><h6>Tài khoản hoạt động</h6><h4 id="kpiActiveAccounts" class="kpi-value">${activeAccounts}</h4></div></div></div>
        <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openAccountQuickModal('locked')"><div class="card-body"><h6>Tài khoản đã khóa</h6><h4 id="kpiLockedAccounts" class="kpi-value">${lockedAccounts}</h4></div></div></div>
        <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openRevenueQuickModal()"><div class="card-body"><h6>Doanh thu đã thanh toán</h6><h4 id="kpiRevenuePaid" class="kpi-value"><fmt:formatNumber value="${sumPaidRevenue}" type="number" maxFractionDigits="0" groupingUsed="true" /> VND</h4></div></div></div>
        <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openServiceQuickModal()"><div class="card-body"><h6>Tổng dịch vụ y tế</h6><h4 id="kpiTotalServices" class="kpi-value">${totalServices}</h4></div></div></div>
        <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openAppointmentQuickModal()"><div class="card-body"><h6>Lượt khám hoàn tất</h6><h4 id="kpiCompletedAppointments" class="kpi-value">${completedAppointments}</h4></div></div></div>
    </div>

    <div class="row g-3 mb-3">
        <div class="col-md-4">
            <div class="card daily-widget-card daily-widget-clickable h-100" onclick="openTodayAppointmentsModal()">
                <div class="card-body">
                    <div class="daily-widget-title">Tổng số lượt khám trong ngày</div>
                    <div class="daily-widget-value" id="dailyTotalVisits">${totalVisitsToday}</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card daily-widget-card daily-widget-clickable h-100" onclick="openTodayWaitingModal()">
                <div class="card-body">
                    <div class="daily-widget-title">Số bệnh nhân đang chờ</div>
                    <div class="daily-widget-value" id="dailyWaitingPatients">${waitingPatientsToday}</div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card daily-widget-card daily-widget-clickable h-100" onclick="openBedAvailabilityModal()">
                <div class="card-body">
                    <div class="daily-widget-title">Số giường bệnh còn trống</div>
                    <div class="daily-widget-value" id="dailyAvailableBeds">${availableBedsToday}</div>
                </div>
            </div>
        </div>
    </div>

    <div class="card mt-3 queue-monitor-card">
        <div class="card-header fw-semibold d-flex justify-content-between align-items-center">
            <span>Tình trạng hàng đợi phòng khám hôm nay</span>
            <span class="badge bg-warning text-dark queue-summary-badge">Tổng ca chờ: ${totalWaitingToday}</span>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-hover align-middle mb-0">
                    <thead class="table-light">
                    <tr>
                        <th>Bác sĩ trực</th>
                        <th>Chuyên khoa</th>
                        <th class="text-end">Số ca đang đợi</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:choose>
                        <c:when test="${empty todayQueueStatus}">
                            <tr>
                                <td colspan="3" class="text-center text-muted py-4">Không có lịch trực hôm nay.</td>
                            </tr>
                        </c:when>
                        <c:otherwise>
                            <c:forEach var="row" items="${todayQueueStatus}">
                                <tr class="queue-row"
                                    data-doctor-name="${row.doctorName}"
                                    data-department="${row.department == 'Endocrinology' ? 'Nội tiết - Tiểu đường' : row.department}"
                                    data-waiting-count="${row.waitingCount}"
                                    onclick="openDoctorQueueModal('${row.doctorId}', this.dataset.doctorName, this.dataset.department)">
                                    <td>${row.doctorName}</td>
                                    <td>${row.department == 'Endocrinology' ? 'Nội tiết - Tiểu đường' : row.department}</td>
                                    <td class="text-end">
                                        <span class="badge queue-load-badge" data-waiting-count="${row.waitingCount}">${row.waitingCount}</span>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:otherwise>
                    </c:choose>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="row g-3 mt-2">
        <div class="col-md-4">
            <div class="card chart-panel h-100">
                <div class="card-body">
                    <h6 class="card-title">Lưu lượng bệnh nhân theo giờ</h6>
                    <div class="chart-canvas-wrap">
                        <canvas id="todayHourlyFlowChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card chart-panel h-100">
                <div class="card-body">
                    <h6 class="card-title">Doanh thu theo loại dịch vụ hôm nay</h6>
                    <div class="chart-canvas-wrap">
                        <canvas id="todayRevenueServiceChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-4">
            <div class="card chart-panel h-100">
                <div class="card-body">
                    <h6 class="card-title">Tỷ lệ trạng thái ca khám hôm nay</h6>
                    <div class="chart-canvas-wrap">
                        <canvas id="todayStatusPieChart"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="d-flex flex-wrap gap-2 mt-4">
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin?action=listUsers">Quản lý Tài khoản & Phân quyền</a>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin?action=manageServices">Quản lý Danh mục Y tế</a>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin?action=schedule">Quản lý Lịch trực Bác sĩ</a>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin?action=reports">Báo cáo Doanh thu/Lượt khám</a>
        <a class="btn btn-warning" href="${pageContext.request.contextPath}/admin?action=exception">Điều phối khẩn cấp & Xử lý sự cố</a>
    </div>
</div>

<div class="modal fade" id="dashboardQuickModal" tabindex="-1" aria-labelledby="dashboardQuickModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header">
                <h5 class="modal-title" id="dashboardQuickModalLabel">Xem nhanh dữ liệu</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="dashboardQuickModalBody">
                <div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>
            </div>
            <div class="modal-footer" id="dashboardQuickModalFooter">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="dashboardInvoiceDetailModal" tabindex="-1" aria-labelledby="dashboardInvoiceDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header">
                <h5 class="modal-title" id="dashboardInvoiceDetailModalLabel">Chi tiết hóa đơn nhanh</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="dashboardInvoiceDetailModalBody">
                <div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin?action=reports">Mở Báo cáo chuyên sâu</a>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="doctorQueueModal" tabindex="-1" aria-labelledby="doctorQueueModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header">
                <h5 class="modal-title" id="doctorQueueModalLabel">Chi tiết hàng đợi</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="table-responsive">
                    <table class="table table-sm table-hover align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>STT</th>
                            <th>Mã lịch hẹn</th>
                            <th>Tên bệnh nhân</th>
                            <th>Khung giờ hẹn</th>
                            <th>Trạng thái</th>
                            <th class="text-end">Thao tác</th>
                        </tr>
                        </thead>
                        <tbody id="doctorQueueTableBody">
                        <tr>
                            <td colspan="6" class="text-center text-muted py-4">Chọn bác sĩ để xem chi tiết hàng đợi.</td>
                        </tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="todayAppointmentsModal" tabindex="-1" aria-labelledby="todayAppointmentsModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header">
                <h5 class="modal-title" id="todayAppointmentsModalLabel">Danh sách ca khám hôm nay</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="table-responsive">
                    <table class="table table-sm table-hover align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>STT</th>
                            <th>Bệnh nhân</th>
                            <th>Bác sĩ</th>
                            <th>Giờ hẹn</th>
                            <th>Trạng thái</th>
                        </tr>
                        </thead>
                        <tbody id="todayAppointmentsTableBody">
                        <tr><td colspan="5" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="todayWaitingModal" tabindex="-1" aria-labelledby="todayWaitingModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-xl modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header">
                <h5 class="modal-title" id="todayWaitingModalLabel">Danh sách bệnh nhân đang xếp hàng chờ</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="table-responsive">
                    <table class="table table-sm table-hover align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>STT</th>
                            <th>Bệnh nhân</th>
                            <th>Chuyên khoa</th>
                            <th>Giờ hẹn</th>
                            <th>Trạng thái</th>
                            <th>Thời gian chờ</th>
                        </tr>
                        </thead>
                        <tbody id="todayWaitingTableBody">
                        <tr><td colspan="6" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="bedAvailabilityModal" tabindex="-1" aria-labelledby="bedAvailabilityModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg modal-dialog-scrollable">
        <div class="modal-content border-0 shadow">
            <div class="modal-header">
                <h5 class="modal-title" id="bedAvailabilityModalLabel">Sơ đồ quản lý giường bệnh lưu trú</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="table-responsive">
                    <table class="table table-sm align-middle mb-0">
                        <thead class="table-light">
                        <tr>
                            <th>Giường</th>
                            <th>Trạng thái</th>
                        </tr>
                        </thead>
                        <tbody id="bedAvailabilityTableBody">
                        <tr><td colspan="2" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.4/dist/chart.umd.min.js"></script>
<script>
    const dashboardBasePath = '${pageContext.request.contextPath}';
    const csrfToken = '${sessionScope.csrfToken}';
    const todayPatientFlowData = ${todayPatientFlowJson};
    const todayRevenueByServiceData = ${todayRevenueByServiceJson};
    const todayStatusDistributionData = ${todayStatusDistributionJson};
    const dailyAvailableBeds = Number(document.getElementById('dailyAvailableBeds') ? document.getElementById('dailyAvailableBeds').textContent : 15) || 15;
    let dashboardQuickModalInstance = null;
    let dashboardInvoiceDetailModalInstance = null;
    let doctorQueueModalInstance = null;
    let todayAppointmentsModalInstance = null;
    let todayWaitingModalInstance = null;
    let bedAvailabilityModalInstance = null;
    let currentAccountFilter = 'all';

    function revealKpiCards() {
        const cards = document.querySelectorAll('.kpi-card');
        cards.forEach((card, index) => {
            window.setTimeout(() => {
                card.classList.add('is-visible');
            }, index * 90);
        });
    }

    function formatCurrency(value) {
        return Number(value || 0).toLocaleString('vi-VN', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 0
        }) + ' VND';
    }

    function escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text == null ? '' : String(text);
        return div.innerHTML;
    }

    async function fetchQuickData(action, params) {
        const query = new URLSearchParams(params || {});
        query.set('action', action);
        const response = await fetch(dashboardBasePath + '/admin?' + query.toString(), {
            headers: { 'Accept': 'application/json' }
        });
        if (!response.ok) {
            throw new Error('HTTP ' + response.status);
        }
        return response.json();
    }

    async function postQuickAction(action, payload) {
        const body = new URLSearchParams(payload || {});
        body.set('action', action);
        body.set('csrfToken', csrfToken);
        const response = await fetch(dashboardBasePath + '/admin', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8',
                'Accept': 'application/json'
            },
            body: body.toString()
        });
        if (!response.ok) {
            throw new Error('HTTP ' + response.status);
        }
        return response.json();
    }

    function ensureQuickModals() {
        if (!dashboardQuickModalInstance) {
            dashboardQuickModalInstance = new bootstrap.Modal(document.getElementById('dashboardQuickModal'));
        }
        if (!dashboardInvoiceDetailModalInstance) {
            dashboardInvoiceDetailModalInstance = new bootstrap.Modal(document.getElementById('dashboardInvoiceDetailModal'));
        }
        if (!doctorQueueModalInstance) {
            doctorQueueModalInstance = new bootstrap.Modal(document.getElementById('doctorQueueModal'));
        }
        if (!todayAppointmentsModalInstance) {
            todayAppointmentsModalInstance = new bootstrap.Modal(document.getElementById('todayAppointmentsModal'));
        }
        if (!todayWaitingModalInstance) {
            todayWaitingModalInstance = new bootstrap.Modal(document.getElementById('todayWaitingModal'));
        }
        if (!bedAvailabilityModalInstance) {
            bedAvailabilityModalInstance = new bootstrap.Modal(document.getElementById('bedAvailabilityModal'));
        }
    }

    function getStatusMeta(status) {
        const rawStatus = String(status || '').trim();
        switch (rawStatus) {
            case 'Waiting':
                return {
                    label: 'Đang chờ',
                    className: 'badge bg-warning text-dark status-badge-soft'
                };
            case 'In_Progress':
                return {
                    label: 'Đang khám',
                    className: 'badge bg-info text-white status-badge-soft'
                };
            case 'Completed':
                return {
                    label: 'Đã hoàn tất',
                    className: 'badge bg-success text-white status-badge-soft'
                };
            default:
                return {
                    label: rawStatus || 'Không xác định',
                    className: 'badge bg-secondary text-white status-badge-soft'
                };
        }
    }

    function renderTodayAppointmentsRows(items) {
        const tbody = document.getElementById('todayAppointmentsTableBody');
        if (!tbody) {
            return;
        }

        if (!Array.isArray(items) || items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">Không có lịch hẹn hôm nay.</td></tr>';
            return;
        }

        let html = '';
        items.forEach((item, index) => {
            const statusMeta = getStatusMeta(item.status);
            html += '<tr>'
                + '<td>' + (index + 1) + '</td>'
                + '<td>' + escapeHtml(item.patientName || 'N/A') + '</td>'
                + '<td>' + escapeHtml(item.doctorName || 'Chưa phân công') + '</td>'
                + '<td>' + escapeHtml(item.appointmentTime || '--:--') + '</td>'
                + '<td><span class="' + statusMeta.className + '">' + escapeHtml(statusMeta.label) + '</span></td>'
                + '</tr>';
        });
        tbody.innerHTML = html;
    }

    function renderTodayWaitingRows(items) {
        const tbody = document.getElementById('todayWaitingTableBody');
        if (!tbody) {
            return;
        }

        if (!Array.isArray(items) || items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Không có bệnh nhân đang chờ trong ngày.</td></tr>';
            return;
        }

        let html = '';
        items.forEach((item, index) => {
            const waitMinutes = Number(item.waitingMinutes || 0);
            const statusMeta = getStatusMeta(item.status || 'Waiting');
            html += '<tr>'
                + '<td>' + (index + 1) + '</td>'
                + '<td>' + escapeHtml(item.patientName || 'N/A') + '</td>'
                + '<td>' + escapeHtml(item.department || 'Chưa xác định') + '</td>'
                + '<td>' + escapeHtml(item.appointmentTime || '--:--') + '</td>'
                + '<td><span class="' + statusMeta.className + '">' + escapeHtml(statusMeta.label) + '</span></td>'
                + '<td>' + waitMinutes + ' phút</td>'
                + '</tr>';
        });
        tbody.innerHTML = html;
    }

    function renderBedAvailabilityRows() {
        const tbody = document.getElementById('bedAvailabilityTableBody');
        if (!tbody) {
            return;
        }

        const totalBeds = 15;
        const availableBeds = Math.max(0, Math.min(totalBeds, dailyAvailableBeds));
        let html = '';
        for (let i = 1; i <= totalBeds; i++) {
            const isAvailable = i <= availableBeds;
            html += '<tr>'
                + '<td>Giường ' + i + '</td>'
                + '<td><span class="badge ' + (isAvailable ? 'bg-success' : 'bg-secondary') + '">' + (isAvailable ? 'Trống' : 'Đang sử dụng') + '</span></td>'
                + '</tr>';
        }
        tbody.innerHTML = html;
    }

    async function openTodayAppointmentsModal() {
        ensureQuickModals();
        const tbody = document.getElementById('todayAppointmentsTableBody');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="5" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>';
        }
        todayAppointmentsModalInstance.show();
        try {
            const data = await fetchQuickData('getTodayAppointments');
            renderTodayAppointmentsRows(data.items || []);
        } catch (error) {
            if (tbody) {
                tbody.innerHTML = '<tr><td colspan="5" class="text-center text-danger py-4">Không thể tải danh sách ca khám hôm nay.</td></tr>';
            }
        }
    }

    async function openTodayWaitingModal() {
        ensureQuickModals();
        const tbody = document.getElementById('todayWaitingTableBody');
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>';
        }
        todayWaitingModalInstance.show();
        try {
            const data = await fetchQuickData('getTodayWaiting');
            renderTodayWaitingRows(data.items || []);
        } catch (error) {
            if (tbody) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-danger py-4">Không thể tải danh sách bệnh nhân đang chờ.</td></tr>';
            }
        }
    }

    function openBedAvailabilityModal() {
        ensureQuickModals();
        renderBedAvailabilityRows();
        bedAvailabilityModalInstance.show();
    }

    function renderDoctorQueueRows(items) {
        const tbody = document.getElementById('doctorQueueTableBody');
        if (!tbody) {
            return;
        }

        if (!Array.isArray(items) || items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Không có bệnh nhân đang chờ cho bác sĩ này hôm nay.</td></tr>';
            return;
        }

        let html = '';
        items.forEach((item, index) => {
            const statusMeta = getStatusMeta(item.status || 'Waiting');
            const appointmentId = escapeHtml(item.appointmentId);
            html += '<tr>';
            html += '<td>' + (index + 1) + '</td>';
            html += '<td>' + appointmentId + '</td>';
            html += '<td>' + escapeHtml(item.patientName || 'N/A') + '</td>';
            html += '<td>' + escapeHtml(item.appointmentTime || '--:--') + '</td>';
            html += '<td><span class="' + statusMeta.className + '">' + escapeHtml(statusMeta.label) + '</span></td>';
            html += '<td class="text-end"><a class="btn btn-sm btn-warning text-dark" href="' + dashboardBasePath + '/admin?action=exception&appointmentId=' + appointmentId + '">Điều phối ca này</a></td>';
            html += '</tr>';
        });
        tbody.innerHTML = html;
    }

    async function openDoctorQueueModal(doctorId, doctorName, department) {
        ensureQuickModals();
        const title = document.getElementById('doctorQueueModalLabel');
        const tbody = document.getElementById('doctorQueueTableBody');

        if (title) {
            title.textContent = 'Chi tiết hàng đợi - Bác sĩ: ' + (doctorName || '') + ' (' + (department || '') + ')';
        }
        if (tbody) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>';
        }

        doctorQueueModalInstance.show();

        try {
            const response = await fetch(dashboardBasePath + '/admin?action=getDoctorQueueDetail&doctorId=' + encodeURIComponent(doctorId), {
                headers: { 'Accept': 'application/json' }
            });
            if (!response.ok) {
                throw new Error('HTTP ' + response.status);
            }
            const data = await response.json();
            renderDoctorQueueRows(data.items || []);
        } catch (error) {
            if (tbody) {
                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-danger py-4">Không thể tải danh sách bệnh nhân đang chờ.</td></tr>';
            }
        }
    }

    function setQuickModalContent(title, bodyHtml, footerHtml) {
        document.getElementById('dashboardQuickModalLabel').textContent = title;
        document.getElementById('dashboardQuickModalBody').innerHTML = bodyHtml;
        document.getElementById('dashboardQuickModalFooter').innerHTML = footerHtml || '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>';
    }

    function renderAccountQuickModal(data) {
        const items = Array.isArray(data.items) ? data.items : [];
        let rows = '';
        if (items.length === 0) {
            rows = '<tr><td colspan="5" class="text-center text-muted py-4">Không có tài khoản phù hợp</td></tr>';
        } else {
            items.forEach(item => {
                const isLocked = String(item.status).toLowerCase() === 'locked';
                rows += '<tr>';
                rows += '<td>' + escapeHtml(item.fullName) + '</td>';
                rows += '<td>' + escapeHtml(item.email) + '</td>';
                rows += '<td>' + escapeHtml(item.role) + '</td>';
                rows += '<td><span class="badge ' + (isLocked ? 'bg-danger' : 'bg-success') + '">' + escapeHtml(item.status) + '</span></td>';
                rows += '<td class="text-end"><button type="button" class="btn btn-sm ' + (isLocked ? 'btn-success' : 'btn-outline-danger') + ' quick-toggle-account quick-action-btn" data-account-id="' + item.accountId + '" data-next-status="' + (isLocked ? 'active' : 'locked') + '">' + (isLocked ? 'Mở khóa' : 'Khóa') + '</button></td>';
                rows += '</tr>';
            });
        }

        setQuickModalContent(
            'Quản lý nhanh tài khoản nhân sự',
            '<div class="table-responsive"><table class="table table-sm table-hover quick-modal-table"><thead class="table-light"><tr><th>Họ tên</th><th>Email</th><th>Vai trò</th><th>Trạng thái</th><th class="text-end">Thao tác</th></tr></thead><tbody>' + rows + '</tbody></table></div>',
            '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button><a class="btn btn-primary" href="' + dashboardBasePath + '/admin?action=listUsers">Mở quản lý tài khoản</a>'
        );

        if (data.summary) {
            document.getElementById('kpiTotalAccounts').textContent = data.summary.totalAccounts;
            document.getElementById('kpiActiveAccounts').textContent = data.summary.activeAccounts;
            document.getElementById('kpiLockedAccounts').textContent = data.summary.lockedAccounts;
        }
    }

    function renderRevenueQuickModal(data) {
        const items = Array.isArray(data.items) ? data.items : [];
        let rows = '';
        if (items.length === 0) {
            rows = '<tr><td colspan="5" class="text-center text-muted py-4">Hôm nay chưa có hóa đơn thu tiền</td></tr>';
        } else {
            items.forEach(item => {
                rows += '<tr>';
                rows += '<td>' + escapeHtml(item.invoiceId) + '</td>';
                rows += '<td>' + escapeHtml(item.patientName) + '</td>';
                rows += '<td>' + escapeHtml(item.payment_time || '--/--/---- --:--') + '</td>';
                rows += '<td class="text-end fw-semibold">' + formatCurrency(item.finalAmount) + '</td>';
                rows += '<td class="text-end"><button type="button" class="btn btn-sm btn-outline-primary quick-view-invoice" data-invoice-id="' + escapeHtml(item.invoiceId) + '">Xem chi tiết</button></td>';
                rows += '</tr>';
            });
        }

        setQuickModalContent(
            'Hóa đơn thu tiền gần nhất trong ngày',
            '<div class="table-responsive"><table class="table table-sm table-hover quick-modal-table"><thead class="table-light"><tr><th>Mã HD</th><th>Tên BN</th><th>Thời gian</th><th class="text-end">Thực thu</th><th class="text-end">Thao tác</th></tr></thead><tbody>' + rows + '</tbody></table></div>',
            '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button><a class="btn btn-primary" href="' + dashboardBasePath + '/admin?action=reports">Mở Báo cáo chuyên sâu</a>'
        );
    }

    function renderServiceQuickModal(data) {
        const items = Array.isArray(data.items) ? data.items : [];
        let rows = '';
        if (items.length === 0) {
            rows = '<tr><td colspan="5" class="text-center text-muted py-4">Không có dịch vụ để hiển thị</td></tr>';
        } else {
            items.forEach(item => {
                const isActive = String(item.status).toLowerCase() === 'active';
                rows += '<tr>';
                rows += '<td>' + escapeHtml(item.serviceName) + '</td>';
                rows += '<td>' + escapeHtml(item.serviceType) + '</td>';
                rows += '<td class="text-end">' + formatCurrency(item.price) + '</td>';
                rows += '<td><span class="badge ' + (isActive ? 'bg-success' : 'bg-secondary') + '">' + escapeHtml(item.status) + '</span></td>';
                rows += '<td class="text-end"><button type="button" class="btn btn-sm ' + (isActive ? 'btn-outline-secondary' : 'btn-success') + ' quick-toggle-service quick-action-btn" data-service-id="' + item.serviceId + '" data-next-status="' + (isActive ? 'Inactive' : 'Active') + '">' + (isActive ? 'Ngưng dùng' : 'Kích hoạt') + '</button></td>';
                rows += '</tr>';
            });
        }

        setQuickModalContent(
            'Danh sách dịch vụ y tế hiện tại',
            '<div class="table-responsive"><table class="table table-sm table-hover quick-modal-table"><thead class="table-light"><tr><th>Dịch vụ</th><th>Loại</th><th class="text-end">Đơn giá</th><th>Trạng thái</th><th class="text-end">Thao tác</th></tr></thead><tbody>' + rows + '</tbody></table></div>',
            '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button><a class="btn btn-primary" href="' + dashboardBasePath + '/admin?action=manageServices">Mở quản lý dịch vụ</a>'
        );

        if (data.summary) {
            document.getElementById('kpiTotalServices').textContent = data.summary.activeServices;
        }
    }

    function renderAppointmentQuickModal(data) {
        const items = Array.isArray(data.items) ? data.items : [];
        let rows = '';
        if (items.length === 0) {
            rows = '<tr><td colspan="4" class="text-center text-muted py-4">Hôm nay chưa có ca khám hoàn tất</td></tr>';
        } else {
            items.forEach(item => {
                rows += '<tr>';
                rows += '<td>' + escapeHtml(item.appointmentId) + '</td>';
                rows += '<td>' + escapeHtml(item.patientName) + '</td>';
                rows += '<td>' + escapeHtml(item.doctorName || 'Chưa phân công') + '</td>';
                rows += '<td>' + escapeHtml(item.appointmentTime) + '</td>';
                rows += '</tr>';
            });
        }

        setQuickModalContent(
            'Ca bệnh vừa hoàn tất trong ngày',
            '<div class="table-responsive"><table class="table table-sm table-hover quick-modal-table"><thead class="table-light"><tr><th>Mã LK</th><th>Bệnh nhân</th><th>Bác sĩ điều trị</th><th>Giờ hoàn tất</th></tr></thead><tbody>' + rows + '</tbody></table></div>',
            '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button><a class="btn btn-primary" href="' + dashboardBasePath + '/admin?action=reports">Mở Báo cáo chuyên sâu</a>'
        );
    }

    async function openAccountQuickModal(filter) {
        ensureQuickModals();
        currentAccountFilter = filter || 'all';
        setQuickModalContent('Quản lý nhanh tài khoản nhân sự', '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>');
        dashboardQuickModalInstance.show();
        try {
            const data = await fetchQuickData('quickAccountsData', { filter: currentAccountFilter });
            renderAccountQuickModal(data);
        } catch (error) {
            setQuickModalContent('Quản lý nhanh tài khoản nhân sự', '<div class="alert alert-danger mb-0">Không thể tải dữ liệu tài khoản.</div>');
        }
    }

    async function openRevenueQuickModal() {
        ensureQuickModals();
        setQuickModalContent('Hóa đơn thu tiền gần nhất trong ngày', '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>');
        dashboardQuickModalInstance.show();
        try {
            const data = await fetchQuickData('quickRevenueData');
            renderRevenueQuickModal(data);
        } catch (error) {
            setQuickModalContent('Hóa đơn thu tiền gần nhất trong ngày', '<div class="alert alert-danger mb-0">Không thể tải dữ liệu hóa đơn.</div>');
        }
    }

    async function openServiceQuickModal() {
        ensureQuickModals();
        setQuickModalContent('Danh sách dịch vụ y tế hiện tại', '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>');
        dashboardQuickModalInstance.show();
        try {
            const data = await fetchQuickData('quickServicesData');
            renderServiceQuickModal(data);
        } catch (error) {
            setQuickModalContent('Danh sách dịch vụ y tế hiện tại', '<div class="alert alert-danger mb-0">Không thể tải dữ liệu dịch vụ.</div>');
        }
    }

    async function openAppointmentQuickModal() {
        ensureQuickModals();
        setQuickModalContent('Ca bệnh vừa hoàn tất trong ngày', '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>');
        dashboardQuickModalInstance.show();
        try {
            const data = await fetchQuickData('quickAppointmentsData');
            renderAppointmentQuickModal(data);
        } catch (error) {
            setQuickModalContent('Ca bệnh vừa hoàn tất trong ngày', '<div class="alert alert-danger mb-0">Không thể tải dữ liệu lượt khám.</div>');
        }
    }

    async function openInvoiceQuickDetail(invoiceId) {
        ensureQuickModals();
        document.getElementById('dashboardInvoiceDetailModalLabel').textContent = 'Chi tiết hóa đơn #' + invoiceId;
        document.getElementById('dashboardInvoiceDetailModalBody').innerHTML = '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>';
        dashboardInvoiceDetailModalInstance.show();
        try {
            const data = await fetchQuickData('getInvoiceItems', { invoiceId: invoiceId });
            const items = Array.isArray(data.items) ? data.items : [];
            let rows = '';
            if (items.length === 0) {
                rows = '<tr><td colspan="4" class="text-center text-muted py-4">Hóa đơn chưa có dòng dịch vụ</td></tr>';
            } else {
                items.forEach(item => {
                    rows += '<tr>';
                    rows += '<td>' + escapeHtml(item.serviceName) + '</td>';
                    rows += '<td class="text-end">' + escapeHtml(item.quantity) + '</td>';
                    rows += '<td class="text-end">' + formatCurrency(item.unitPrice) + '</td>';
                    rows += '<td class="text-end fw-semibold">' + formatCurrency(item.lineTotal) + '</td>';
                    rows += '</tr>';
                });
            }
            document.getElementById('dashboardInvoiceDetailModalBody').innerHTML = '<div class="table-responsive"><table class="table table-sm table-hover quick-modal-table"><thead class="table-light"><tr><th>Dịch vụ</th><th class="text-end">SL</th><th class="text-end">Đơn giá</th><th class="text-end">Thành tiền</th></tr></thead><tbody>' + rows + '</tbody></table></div>';
        } catch (error) {
            document.getElementById('dashboardInvoiceDetailModalBody').innerHTML = '<div class="alert alert-danger mb-0">Không thể tải chi tiết hóa đơn.</div>';
        }
    }

    function applyQueueBadgeStyles() {
        document.querySelectorAll('.queue-load-badge').forEach(badge => {
            const waitingCount = Number(badge.dataset.waitingCount || badge.textContent || 0);
            badge.classList.remove('bg-secondary', 'text-white', 'bg-warning', 'text-dark', 'bg-danger', 'animate-pulse', 'bg-success');

            if (waitingCount === 0) {
                badge.classList.add('bg-secondary', 'text-white');
            } else if (waitingCount >= 1 && waitingCount <= 5) {
                badge.classList.add('bg-warning', 'text-dark');
            } else {
                badge.classList.add('bg-danger', 'text-white', 'animate-pulse');
            }
        });
    }

    function renderTodayCharts() {
        const flowLabels = todayPatientFlowData.map(item => item.timeSlot || 'N/A');
        const flowValues = todayPatientFlowData.map(item => Number(item.visitCount || 0));

        const revenueMap = {
            Examination: 0,
            Lab_Test: 0
        };
        todayRevenueByServiceData.forEach(item => {
            const type = String(item.serviceType || '');
            revenueMap[type] = Number(item.totalRevenue || 0);
        });

        const statusMap = {
            Waiting: 0,
            In_Progress: 0,
            Completed: 0
        };
        todayStatusDistributionData.forEach(item => {
            const status = String(item.status || '');
            if (Object.prototype.hasOwnProperty.call(statusMap, status)) {
                statusMap[status] = Number(item.totalCount || 0);
            }
        });

        const flowCanvas = document.getElementById('todayHourlyFlowChart');
        if (flowCanvas) {
            new Chart(flowCanvas, {
                type: 'line',
                data: {
                    labels: flowLabels,
                    datasets: [{
                        label: 'Số lượt khám',
                        data: flowValues,
                        borderColor: '#1f77b4',
                        backgroundColor: 'rgba(31, 119, 180, 0.2)',
                        borderWidth: 2,
                        tension: 0.35,
                        pointRadius: 3,
                        fill: true
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    scales: {
                        y: { beginAtZero: true, ticks: { precision: 0 } }
                    }
                }
            });
        }

        const revenueCanvas = document.getElementById('todayRevenueServiceChart');
        if (revenueCanvas) {
            new Chart(revenueCanvas, {
                type: 'doughnut',
                data: {
                    labels: ['Khám bệnh', 'Xét nghiệm'],
                    datasets: [{
                        data: [revenueMap.Examination, revenueMap.Lab_Test],
                        backgroundColor: ['#2a9d8f', '#e9c46a']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false,
                    plugins: {
                        tooltip: {
                            callbacks: {
                                label: function (context) {
                                    return context.label + ': ' + formatCurrency(context.raw);
                                }
                            }
                        }
                    }
                }
            });
        }

        const statusCanvas = document.getElementById('todayStatusPieChart');
        if (statusCanvas) {
            new Chart(statusCanvas, {
                type: 'pie',
                data: {
                    labels: ['Waiting', 'In_Progress', 'Completed'],
                    datasets: [{
                        data: [statusMap.Waiting, statusMap.In_Progress, statusMap.Completed],
                        backgroundColor: ['#f4a261', '#4cc9f0', '#2a9d8f']
                    }]
                },
                options: {
                    responsive: true,
                    maintainAspectRatio: false
                }
            });
        }
    }

    document.addEventListener('DOMContentLoaded', function () {
        revealKpiCards();
        applyQueueBadgeStyles();
        renderTodayCharts();

        document.addEventListener('click', async function (event) {
            const accountToggle = event.target.closest('.quick-toggle-account');
            if (accountToggle) {
                accountToggle.disabled = true;
                try {
                    const data = await postQuickAction('ajaxToggleAccountStatus', {
                        accountId: accountToggle.dataset.accountId,
                        status: accountToggle.dataset.nextStatus
                    });
                    if (data.success) {
                        document.getElementById('kpiActiveAccounts').textContent = data.activeAccounts;
                        document.getElementById('kpiLockedAccounts').textContent = data.lockedAccounts;
                        openAccountQuickModal(currentAccountFilter);
                    }
                } catch (error) {
                    accountToggle.disabled = false;
                }
                return;
            }

            const serviceToggle = event.target.closest('.quick-toggle-service');
            if (serviceToggle) {
                serviceToggle.disabled = true;
                try {
                    const data = await postQuickAction('ajaxToggleServiceStatus', {
                        serviceId: serviceToggle.dataset.serviceId,
                        status: serviceToggle.dataset.nextStatus
                    });
                    if (data.success) {
                        document.getElementById('kpiTotalServices').textContent = data.activeServices;
                        openServiceQuickModal();
                    }
                } catch (error) {
                    serviceToggle.disabled = false;
                }
                return;
            }

            const invoiceButton = event.target.closest('.quick-view-invoice');
            if (invoiceButton) {
                openInvoiceQuickDetail(invoiceButton.dataset.invoiceId);
            }
        });
    });

    window.openAccountQuickModal = openAccountQuickModal;
    window.openRevenueQuickModal = openRevenueQuickModal;
    window.openServiceQuickModal = openServiceQuickModal;
    window.openAppointmentQuickModal = openAppointmentQuickModal;
    window.openDoctorQueueModal = openDoctorQueueModal;
    window.openTodayAppointmentsModal = openTodayAppointmentsModal;
    window.openTodayWaitingModal = openTodayWaitingModal;
    window.openBedAvailabilityModal = openBedAvailabilityModal;
</script>
</body>
</html>
