<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:setLocale value="vi_VN" />
<c:set var="currentAction" value="${empty param.action ? 'dashboard' : param.action}" />
<%
    if (request.getAttribute("totalAccounts") == null) {
        response.sendRedirect(request.getContextPath() + "/admin");
        return;
    }
%>

<%--
    Trang Dashboard Admin:
    - Hiển thị KPI vận hành trong ngày
    - Theo dõi hàng đợi bác sĩ, ca trực hôm nay, biểu đồ tổng quan
    - Cung cấp quick modal để thao tác nhanh bằng AJAX
--%>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Bảng điều hành quản trị - S-COMS</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

        <link href="${pageContext.request.contextPath}/css/admin-ui.css" rel="stylesheet">
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
                0% {
                    box-shadow: 0 0 0 0 rgba(220, 53, 69, 0.45);
                }
                70% {
                    box-shadow: 0 0 0 10px rgba(220, 53, 69, 0);
                }
                100% {
                    box-shadow: 0 0 0 0 rgba(220, 53, 69, 0);
                }
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
                opacity: 1;
                transform: none;
                transition: box-shadow 0.25s ease;
            }

            .kpi-card.is-visible {
                opacity: 1;
                transform: none;
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


            .admin-dashboard-header {
                display: flex;
                align-items: center;
                justify-content: space-between;
                gap: 1rem;
            }

            .admin-dashboard-header .btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                min-height: 40px;
                white-space: nowrap;
                align-self: center;
            }

            .kpi-card .card-body,
            .daily-widget-card .card-body {
                position: relative;
                min-height: 118px;
                padding-right: 4.55rem;
            }

            .kpi-card h6,
            .daily-widget-title {
                padding-right: 0.25rem;
            }

            .kpi-value {
                white-space: nowrap;
            }

            .kpi-money {
                display: flex;
                align-items: baseline;
                gap: 0.35rem;
                white-space: nowrap;
                line-height: 1.12;
                font-size: clamp(1.08rem, 1.45vw, 1.45rem);
            }

            .kpi-money .currency {
                flex: 0 0 auto;
                font-size: 0.72rem;
                font-weight: 800;
                letter-spacing: 0.04em;
                color: #6c757d;
            }

            .kpi-icon-box {
                position: absolute;
                top: 1rem;
                right: 1rem;
                width: 46px;
                height: 46px;
                border-radius: 999px;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                font-size: 1.15rem;
                box-shadow: inset 0 0 0 1px rgba(255, 255, 255, 0.62);
            }

            .kpi-icon-users {
                color: #0f766e;
                background: rgba(15, 118, 110, 0.12);
            }
            .kpi-icon-active {
                color: #15803d;
                background: rgba(21, 128, 61, 0.12);
            }
            .kpi-icon-locked {
                color: #b45309;
                background: rgba(245, 158, 11, 0.16);
            }
            .kpi-icon-revenue {
                color: #7c3aed;
                background: rgba(124, 58, 237, 0.12);
            }
            .kpi-icon-service {
                color: #0369a1;
                background: rgba(3, 105, 161, 0.12);
            }
            .kpi-icon-visit {
                color: #be123c;
                background: rgba(225, 29, 72, 0.12);
            }
            .kpi-icon-waiting {
                color: #ea580c;
                background: rgba(234, 88, 12, 0.13);
            }
            .kpi-icon-bed {
                color: #2563eb;
                background: rgba(37, 99, 235, 0.12);
            }

            .chart-panel .card-body {
                padding-bottom: 1.35rem;
            }

            .chart-canvas-wrap {
                position: relative;
                height: 260px;
                min-height: 260px;
                width: 100%;
            }

            .chart-canvas-wrap canvas {
                display: block;
                width: 100% !important;
                height: 100% !important;
            }

            @media (max-width: 991.98px) {
                .admin-dashboard-header {
                    align-items: flex-start;
                    flex-direction: column;
                }

                .admin-dashboard-header .btn {
                    align-self: flex-start;
                }
            }

            @media (max-width: 575.98px) {
                .kpi-money {
                    font-size: 1.18rem;
                }
            }
            .status-badge-soft {
                border-radius: 12px;
                padding: 6px 12px;
                font-weight: 600;
                display: inline-block;
            }
            .chart-empty-state {
                position: absolute;
                inset: 0;
                display: flex;
                align-items: center;
                justify-content: center;
                text-align: center;
                color: #6c757d;
                font-weight: 600;
                font-size: 0.95rem;
            }

            .chart-empty-state i {
                font-size: 1.8rem;
                display: block;
                margin-bottom: 0.5rem;
                color: #adb5bd;
            }
            .queue-table-scroll {
                max-height: 350px;
                overflow-y: auto;
                overflow-x: auto;
                border-radius: 12px;
            }

            .queue-table-scroll table {
                margin-bottom: 0;
            }

            .queue-table-scroll thead th {
                position: sticky;
                top: 0;
                z-index: 5;
                background: #f8f9fa;
            }

            .queue-table-scroll tbody tr {
                height: 52px;
            }

        </style>
    </head>
    <body class="bg-light">
        <div class="container py-4">
            <div class="admin-dashboard-header mb-3">
                <div>
                    <h3 class="mb-1">Hệ thống Điều hành & Quản trị Danh mục S-COMS</h3>
                    <p class="text-secondary mb-0">Bảng điều hành quản trị theo chuẩn FR-ADM và BR-08</p>
                </div>
            </div>

            <div class="admin-layout row g-3">
                <div class="col-lg-3 admin-sidebar-col">
                    <%@ include file="/admin/fragments/sidebar.jspf" %>
                </div>

                <div class="col-lg-9 admin-content-col">
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="alert alert-success">${sessionScope.successMessage}</div>
                <% session.removeAttribute("successMessage"); %>
            </c:if>
            <c:if test="${not empty sessionScope.errorMessage}">
                <div class="alert alert-danger">${sessionScope.errorMessage}</div>
                <% session.removeAttribute("errorMessage"); %>
            </c:if>

            <div class="row g-3 mb-4">
                <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openAccountQuickModal('all')"><div class="card-body"><span class="kpi-icon-box kpi-icon-users"><i class="fa-solid fa-users"></i></span><h6>Tổng tài khoản</h6><h4 id="kpiTotalAccounts" class="kpi-value">${totalAccounts}</h4></div></div></div>
                <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openAccountQuickModal('active')"><div class="card-body"><span class="kpi-icon-box kpi-icon-active"><i class="fa-solid fa-user-check"></i></span><h6>Tài khoản hoạt động</h6><h4 id="kpiActiveAccounts" class="kpi-value">${activeAccounts}</h4></div></div></div>
                <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openLockedAccountsModal()"><div class="card-body"><span class="kpi-icon-box kpi-icon-locked"><i class="fa-solid fa-lock"></i></span><h6>Tài khoản đã khóa</h6><h4 id="kpiLockedAccounts" class="kpi-value">${lockedAccounts}</h4></div></div></div>
                <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openRevenueQuickModal()"><div class="card-body"><span class="kpi-icon-box kpi-icon-revenue"><i class="fa-solid fa-wallet"></i></span><h6>Doanh thu đã thanh toán</h6><h4 id="kpiRevenuePaid" class="kpi-value kpi-money"><span><fmt:formatNumber value="${sumPaidRevenue}" type="number" maxFractionDigits="0" groupingUsed="true" /></span><span class="currency">VNĐ</span></h4></div></div></div>
                <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openServiceQuickModal()"><div class="card-body"><span class="kpi-icon-box kpi-icon-service"><i class="fa-solid fa-stethoscope"></i></span><h6>Tổng dịch vụ y tế</h6><h4 id="kpiTotalServices" class="kpi-value">${totalServices}</h4></div></div></div>
                <div class="col-md-2"><div class="card h-100 kpi-card dashboard-clickable-card" onclick="openCompletedAppointmentsModal()"><div class="card-body"><span class="kpi-icon-box kpi-icon-visit"><i class="fa-solid fa-clipboard-check"></i></span><h6>Lượt khám hoàn tất</h6><h4 id="kpiCompletedAppointments" class="kpi-value">${completedAppointments}</h4></div></div></div>
            </div>

            <div class="row g-3 mb-3">
                <div class="col-md-4">
                    <div class="card daily-widget-card daily-widget-clickable h-100" onclick="openTodayAppointmentsModal()">
                        <div class="card-body">
                            <span class="kpi-icon-box kpi-icon-visit"><i class="fa-solid fa-calendar-check"></i></span>
                            <div class="daily-widget-title">Tổng số lượt khám trong ngày</div>
                            <div class="daily-widget-value" id="dailyTotalVisits"><c:out value="${todayAppointments}" default="0" /></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card daily-widget-card daily-widget-clickable h-100" onclick="openTodayWaitingModal()">
                        <div class="card-body">
                            <span class="kpi-icon-box kpi-icon-waiting"><i class="fa-solid fa-user-clock"></i></span>
                            <div class="daily-widget-title">Số bệnh nhân đang chờ</div>
                            <div class="daily-widget-value" id="dailyWaitingPatients"><c:out value="${waitingPatients}" default="0" /></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card daily-widget-card daily-widget-clickable h-100" onclick="openDoctorShiftModal()">
                        <div class="card-body">
                            <span class="kpi-icon-box kpi-icon-bed"><i class="fa-solid fa-bed-pulse"></i></span>
                            <div class="daily-widget-title">Danh sách ca trực hôm nay của Bác sĩ</div>
                            <div class="daily-widget-value" id="dailyAvailableBeds"><c:out value="${todayShiftsCount}" default="0" /></div>
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
                    <div class="table-responsive queue-table-scroll">
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
                                                data-department="${row.department == 'Endocrinology' ? 'Nội tiết - Tiểu đường' : (row.department == 'Cardiology' ? 'Tim mạch' : (row.department == 'Nephrology' ? 'Thận học' : (row.department == 'General' ? 'Tổng quát' : row.department)))}"
                                                data-waiting-count="${row.waitingCount}"
                                                onclick="openDoctorQueueModal('${row.doctorId}', this.dataset.doctorName, this.dataset.department)">
                                                <td>${row.doctorName}</td>
                                                <td>${row.department == 'Endocrinology' ? 'Nội tiết - Tiểu đường' : (row.department == 'Cardiology' ? 'Tim mạch' : (row.department == 'Nephrology' ? 'Thận học' : (row.department == 'General' ? 'Tổng quát' : row.department)))}</td>
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

                </div>
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
                                        <th>Ngày Khám</th>
                                        <th>Giờ hẹn</th>
                                        <th>Trạng thái</th>
                                    </tr>
                                </thead>
                                <tbody id="todayAppointmentsTableBody">
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
                        <h5 class="modal-title" id="bedAvailabilityModalLabel">Danh sách ca trực hôm nay của Bác sĩ</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="table-responsive">
                            <table class="table table-sm align-middle mb-0">
                                <thead class="table-light">
                                    <tr>
                                        <th>Mã ca</th>
                                        <th>Bác sĩ trực</th>
                                        <th>Chuyên khoa</th>
                                        <th>Khung giờ</th>
                                        <th class="text-end">Đã đặt / tối đa</th>
                                        <th>Trạng thái ca</th>
                                    </tr>
                                </thead>
                                <tbody id="bedAvailabilityTableBody">
                                    <c:choose>
                                        <c:when test="${empty todayShiftsList}">
                                            <tr>
                                                <td colspan="6" class="text-center text-muted py-4">Không có ca trực hôm nay.</td>
                                            </tr>
                                        </c:when>
                                        <c:otherwise>
                                            <c:forEach var="shift" items="${todayShiftsList}">
                                                <tr>
                                                    <td>${shift.scheduleId}</td>
                                                    <td>${shift.fullName}</td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${shift.department eq 'Endocrinology'}">Nội tiết - Tiểu đường</c:when>
                                                            <c:when test="${shift.department eq 'Cardiology'}">Tim mạch</c:when>
                                                            <c:when test="${shift.department eq 'Nephrology'}">Thận học</c:when>
                                                            <c:when test="${shift.department eq 'General'}">Tổng quát</c:when>
                                                            <c:otherwise>${shift.department}</c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>${shift.timeSlot}</td>
                                                    <td class="text-end">
                                                        <c:set var="currentLoad" value="${empty shift.currentLoad ? 0 : shift.currentLoad}" />
                                                        <c:set var="activeLoad" value="${empty shift.activeCount ? 0 : shift.activeCount}" />
                                                        <c:set var="maxPatients" value="${empty shift.maxPatients ? 0 : shift.maxPatients}" />
                                                        <c:choose>
                                                            <c:when test="${maxPatients le 0}">
                                                                <span class="badge bg-secondary">${currentLoad} / ${maxPatients}</span>
                                                            </c:when>
                                                            <c:when test="${currentLoad * 100 ge maxPatients * 100}">
                                                                <span class="badge bg-danger">${currentLoad} / ${maxPatients}</span>
                                                            </c:when>
                                                            <c:when test="${currentLoad * 100 ge maxPatients * 80}">
                                                                <span class="badge bg-warning text-dark">${currentLoad} / ${maxPatients}</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-success">${currentLoad} / ${maxPatients}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <small class="d-block text-muted mt-1">Đang chờ/khám: ${activeLoad}</small>
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${shift.status eq 'available' or shift.status eq 'Available'}">
                                                                <span class="badge bg-success">Khả dụng</span>
                                                            </c:when>
                                                            <c:when test="${shift.status eq 'Full'}">
                                                                <span class="badge bg-danger">Đã đầy</span>
                                                            </c:when>
                                                            <c:when test="${shift.status eq 'Cancelled'}">
                                                                <span class="badge bg-dark">Đã hủy</span>
                                                            </c:when>
                                                            <c:when test="${shift.status eq 'Expired'}">
                                                                <span class="badge bg-secondary">Đã qua</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="badge bg-secondary">${shift.status}</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </c:otherwise>
                                    </c:choose>
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

                                                    // Call revealKpiCards immediately if DOM is ready, or on DOMContentLoaded
                                                    if (document.readyState === 'loading') {
                                                        document.addEventListener('DOMContentLoaded', revealKpiCards);
                                                    } else {
                                                        // DOM is already ready, call immediately with a small delay to ensure rendering
                                                        window.setTimeout(revealKpiCards, 100);
                                                    }

                                                    function formatCurrency(value) {
                                                        return Number(value || 0).toLocaleString('vi-VN', {
                                                            minimumFractionDigits: 0,
                                                            maximumFractionDigits: 2
                                                        }) + ' VNĐ';
                                                    }

                                                    function escapeHtml(text) {
                                                        const div = document.createElement('div');
                                                        div.textContent = text == null ? '' : String(text);
                                                        return div.innerHTML;
                                                    }

                                                    function translateRole(role) {
                                                        const roleMap = {
                                                            'Patient': 'Bệnh nhân',
                                                            'Doctor': 'Bác sĩ',
                                                            'Receptionist': 'Lễ tân',
                                                            'Admin': 'Quản trị viên'
                                                        };
                                                        return roleMap[role] || role;
                                                    }

                                                    function translateAccountStatus(status) {
                                                        const statusMap = {
                                                            'Active': 'Hoạt động',
                                                            'Locked': 'Đã khóa'
                                                        };
                                                        return statusMap[status] || status;
                                                    }

                                                    function translateServiceStatus(status) {
                                                        const statusMap = {
                                                            'Active': 'Hoạt động',
                                                            'Inactive': 'Ngừng hoạt động'
                                                        };
                                                        return statusMap[status] || status;
                                                    }

                                                    async function fetchQuickData(action, params) {
                                                        const query = new URLSearchParams(params || {});
                                                        query.set('action', action);
                                                        const response = await fetch(dashboardBasePath + '/admin?' + query.toString(), {
                                                            headers: {'Accept': 'application/json'}
                                                        });
                                                        if (!response.ok) {
                                                            throw new Error('HTTP ' + response.status);
                                                        }
                                                        return response.json();
                                                    }

                                                    async function fetchServletJson(servletPath, params) {
                                                        const query = new URLSearchParams(params || {});
                                                        const response = await fetch(dashboardBasePath + servletPath + '?' + query.toString(), {
                                                            headers: {'Accept': 'application/json'}
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
                                                                    label: 'Chờ đợi',
                                                                    className: 'badge bg-warning text-dark status-badge-soft'
                                                                };
                                                            case 'In_Progress':
                                                                return {
                                                                    label: 'Đang khám',
                                                                    className: 'badge bg-info text-white status-badge-soft'
                                                                };
                                                            case 'Completed':
                                                                return {
                                                                    label: 'Hoàn tất',
                                                                    className: 'badge bg-success text-white status-badge-soft'
                                                                };
                                                            case 'No_Show':
                                                                return {
                                                                    label: 'Không đến',
                                                                    className: 'badge bg-secondary text-white status-badge-soft'
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
                                                            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Không có lịch hẹn hôm nay.</td></tr>';
                                                            return;
                                                        }

                                                        let html = '';
                                                        items.forEach((item, index) => {
                                                            const statusMeta = getStatusMeta(item.status);
                                                            html += '<tr>'
                                                                    + '<td>' + (index + 1) + '</td>'
                                                                    + '<td>' + escapeHtml(item.patientName || 'N/A') + '</td>'
                                                                    + '<td>' + escapeHtml(item.doctorName || 'Chưa phân công') + '</td>'
                                                                    + '<td>' + escapeHtml(item.appointmentDate || '') + '</td>'
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

                                                    async function openTodayAppointmentsModal() {
                                                        ensureQuickModals();
                                                        const tbody = document.getElementById('todayAppointmentsTableBody');
                                                        if (tbody) {
                                                            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-4">Đang tải dữ liệu...</td></tr>';
                                                        }
                                                        todayAppointmentsModalInstance.show();
                                                        try {
                                                            const data = await fetchQuickData('getTodayAppointments');
                                                            renderTodayAppointmentsRows(data.items || []);
                                                        } catch (error) {
                                                            if (tbody) {
                                                                tbody.innerHTML = '<tr><td colspan="6" class="text-center text-danger py-4">Không thể tải danh sách ca khám hôm nay.</td></tr>';
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

                                                    function openDoctorShiftModal() {
                                                        ensureQuickModals();
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
                                                                headers: {'Accept': 'application/json'}
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
                                                                rows += '<td>' + escapeHtml(translateRole(item.role)) + '</td>';
                                                                rows += '<td><span class="badge ' + (isLocked ? 'bg-danger' : 'bg-success') + '">' + escapeHtml(translateAccountStatus(item.status)) + '</span></td>';
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

                                                    function renderLockedAccountModalRows(items) {
                                                        let rows = '';
                                                        if (!Array.isArray(items) || items.length === 0) {
                                                            rows = '<tr><td colspan="4" class="text-center text-muted py-4">Không có tài khoản phù hợp</td></tr>';
                                                        } else {
                                                            items.forEach(item => {
                                                                const status = String(item.status || 'locked');
                                                                const isLocked = status.toLowerCase() === 'locked';
                                                                rows += '<tr>';
                                                                rows += '<td>' + escapeHtml(item.fullName || item.full_name || 'N/A') + '</td>';
                                                                rows += '<td>' + escapeHtml(item.email || 'N/A') + '</td>';
                                                                rows += '<td>' + escapeHtml(translateRole(item.role || 'N/A')) + '</td>';
                                                                rows += '<td><span class="badge ' + (isLocked ? 'bg-danger' : 'bg-success') + '">' + escapeHtml(translateAccountStatus(status)) + '</span></td>';
                                                                rows += '</tr>';
                                                            });
                                                        }

                                                        setQuickModalContent(
                                                                'Danh sách tài khoản đã khóa',
                                                                '<div class="table-responsive"><table class="table table-sm table-hover quick-modal-table"><thead class="table-light"><tr><th>Họ tên</th><th>Email</th><th>Vai trò</th><th>Trạng thái</th></tr></thead><tbody>' + rows + '</tbody></table></div>',
                                                                '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button><a class="btn btn-primary" href="' + dashboardBasePath + '/admin?action=listUsers">Mở quản lý tài khoản</a>'
                                                                );
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
                                                                rows += '<td><span class="badge ' + (isActive ? 'bg-success' : 'bg-secondary') + '">' + escapeHtml(translateServiceStatus(item.status)) + '</span></td>';
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
                                                            rows = '<tr><td colspan="6" class="text-center text-muted py-4">Chưa có lượt khám hoàn tất</td></tr>';
                                                        } else {
                                                            items.forEach((item, index) => {
                                                                rows += '<tr>';
                                                                rows += '<td>' + (index + 1) + '</td>';
                                                                rows += '<td>' + escapeHtml(item.patientName || '') + '</td>';
                                                                rows += '<td>' + escapeHtml(item.doctorName || 'Chưa phân công') + '</td>';
                                                                rows += '<td>' + escapeHtml(item.appointmentDate || '') + '</td>';
                                                                rows += '<td>' + escapeHtml(item.appointmentTime || '') + '</td>';
                                                                rows += '<td><span class="badge bg-success">Đã hoàn tất</span></td>';
                                                                rows += '</tr>';
                                                            });
                                                        }

                                                        setQuickModalContent(
                                                                'Danh sách lượt khám hoàn tất',
                                                                '<div class="table-responsive">'
                                                                + '<table class="table table-sm table-hover quick-modal-table align-middle">'
                                                                + '<thead class="table-light">'
                                                                + '<tr>'
                                                                + '<th>STT</th>'
                                                                + '<th>BỆNH NHÂN</th>'
                                                                + '<th>BÁC SĨ</th>'
                                                                + '<th>NGÀY KHÁM</th>'
                                                                + '<th>GIỜ HẸN</th>'
                                                                + '<th>TRẠNG THÁI</th>'
                                                                + '</tr>'
                                                                + '</thead>'
                                                                + '<tbody>' + rows + '</tbody>'
                                                                + '</table>'
                                                                + '</div>',
                                                                '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>'
                                                                + '<a class="btn btn-primary" href="' + dashboardBasePath + '/admin?action=reports">Mở Báo cáo chuyên sâu</a>'
                                                                );
                                                    }

                                                    function renderCompletedAppointmentsModalRows(items) {
                                                        let rows = '';
                                                        if (!Array.isArray(items) || items.length === 0) {
                                                            rows = '<tr><td colspan="6" class="text-center text-muted py-4">Không có lượt khám hoàn tất</td></tr>';
                                                        } else {
                                                            items.forEach((item, index) => {
                                                                const statusMeta = getStatusMeta(item.status || 'Completed');
                                                                rows += '<tr>';
                                                                rows += '<td>' + (index + 1) + '</td>';
                                                                rows += '<td>' + escapeHtml(item.patientName || item.patient_name || 'N/A') + '</td>';
                                                                rows += '<td>' + escapeHtml(item.doctorName || item.doctor_name || 'Chưa phân công') + '</td>';
                                                                rows += '<td>' + escapeHtml(item.appointmentDate || item.appointment_date || '') + '</td>';
                                                                rows += '<td>' + escapeHtml(item.appointmentTime || item.appointment_time || '--:--') + '</td>';
                                                                rows += '<td><span class="' + statusMeta.className + '">' + escapeHtml(statusMeta.label) + '</span></td>';
                                                                rows += '</tr>';
                                                            });
                                                        }

                                                        setQuickModalContent(
                                                                'Danh sách lượt khám hoàn tất',
                                                                '<div class="table-responsive">'
                                                                + '<table class="table table-sm table-hover quick-modal-table">'
                                                                + '<thead class="table-light">'
                                                                + '<tr>'
                                                                + '<th>STT</th>'
                                                                + '<th>Bệnh nhân</th>'
                                                                + '<th>Bác sĩ</th>'
                                                                + '<th>Ngày khám</th>'
                                                                + '<th>Giờ hẹn</th>'
                                                                + '<th>Trạng thái</th>'
                                                                + '</tr>'
                                                                + '</thead>'
                                                                + '<tbody>' + rows + '</tbody>'
                                                                + '</table>'
                                                                + '</div>',
                                                                '<button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>'
                                                                + '<a class="btn btn-primary" href="' + dashboardBasePath + '/admin?action=reports">Mở Báo cáo chuyên sâu</a>'
                                                                );
                                                    }

                                                    async function openAccountQuickModal(filter) {
                                                        ensureQuickModals();
                                                        currentAccountFilter = filter || 'all';
                                                        setQuickModalContent('Quản lý nhanh tài khoản nhân sự', '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>');
                                                        dashboardQuickModalInstance.show();
                                                        try {
                                                            const data = await fetchQuickData('quickAccountsData', {filter: currentAccountFilter});
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

                                                    async function openLockedAccountsModal() {
                                                        ensureQuickModals();
                                                        setQuickModalContent('Danh sách tài khoản đã khóa', '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>');
                                                        dashboardQuickModalInstance.show();
                                                        try {
                                                            const data = await fetchQuickData('quickAccountsData', {
                                                                filter: 'locked'
                                                            });
                                                            const items = Array.isArray(data) ? data : (Array.isArray(data.items) ? data.items : []);
                                                            renderLockedAccountModalRows(items);
                                                        } catch (error) {
                                                            setQuickModalContent('Danh sách tài khoản đã khóa', '<div class="alert alert-danger mb-0">Không thể tải dữ liệu tài khoản đã khóa.</div>');
                                                        }
                                                    }

                                                    async function openCompletedAppointmentsModal() {
                                                        ensureQuickModals();
                                                        setQuickModalContent('Danh sách lượt khám hoàn tất', '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>');
                                                        dashboardQuickModalInstance.show();
                                                        try {
                                                            const data = await fetchQuickData('quickAppointmentsData');
                                                            const items = Array.isArray(data) ? data : (Array.isArray(data.items) ? data.items : []);
                                                            renderCompletedAppointmentsModalRows(items);
                                                        } catch (error) {
                                                            setQuickModalContent('Danh sách lượt khám hoàn tất', '<div class="alert alert-danger mb-0">Không thể tải danh sách ca khám Completed.</div>');
                                                        }
                                                    }

                                                    async function openInvoiceQuickDetail(invoiceId) {
                                                        ensureQuickModals();
                                                        document.getElementById('dashboardInvoiceDetailModalLabel').textContent = 'Chi tiết hóa đơn #' + invoiceId;
                                                        document.getElementById('dashboardInvoiceDetailModalBody').innerHTML = '<div class="text-muted py-4 text-center">Đang tải dữ liệu...</div>';
                                                        dashboardInvoiceDetailModalInstance.show();
                                                        try {
                                                            const data = await fetchQuickData('getInvoiceItems', {invoiceId: invoiceId});
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
                                                    function showChartEmptyState(canvasId, message) {
                                                        const canvas = document.getElementById(canvasId);
                                                        if (!canvas) {
                                                            return;
                                                        }

                                                        const wrapper = canvas.parentElement;
                                                        if (!wrapper) {
                                                            return;
                                                        }

                                                        canvas.style.display = 'none';
                                                        const oldEmptyState = wrapper.querySelector('.chart-empty-state');
                                                        if (oldEmptyState) {
                                                            oldEmptyState.remove();
                                                        }

                                                        const emptyDiv = document.createElement('div');
                                                        emptyDiv.className = 'chart-empty-state';
                                                        emptyDiv.innerHTML = '<div><i class="fa-regular fa-folder-open"></i>' + escapeHtml(message) + '</div>';
                                                        wrapper.appendChild(emptyDiv);
                                                    }

                                                    function hideChartEmptyState(canvasId) {
                                                        const canvas = document.getElementById(canvasId);
                                                        if (!canvas) {
                                                            return;
                                                        }

                                                        const wrapper = canvas.parentElement;
                                                        if (!wrapper) {
                                                            return;
                                                        }

                                                        const oldEmptyState = wrapper.querySelector('.chart-empty-state');
                                                        if (oldEmptyState) {
                                                            oldEmptyState.remove();
                                                        }

                                                        canvas.style.display = 'block';
                                                    }
                                                    function renderTodayCharts() {
                                                        const flowRows = Array.isArray(todayPatientFlowData)
                                                                ? todayPatientFlowData.filter(item => String(item.timeSlot || '').trim() !== '')
                                                                : [];

                                                        const flowLabels = flowRows.map(item => String(item.timeSlot || '').trim());
                                                        const flowValues = flowRows.map(item => Number(item.visitCount || 0));

                                                        const revenueMap = {
                                                            Examination: 0,
                                                            Lab_Test: 0
                                                        };

                                                        if (Array.isArray(todayRevenueByServiceData)) {
                                                            todayRevenueByServiceData.forEach(item => {
                                                                const type = String(item.serviceType || '');
                                                                revenueMap[type] = Number(item.totalRevenue || 0);
                                                            });
                                                        }

                                                        const revenueValues = [
                                                            revenueMap.Examination,
                                                            revenueMap.Lab_Test
                                                        ];

                                                        const statusMap = {
                                                            Waiting: 0,
                                                            In_Progress: 0,
                                                            Completed: 0,
                                                            No_Show: 0
                                                        };

                                                        if (Array.isArray(todayStatusDistributionData)) {
                                                            todayStatusDistributionData.forEach(item => {
                                                                const status = String(item.status || '');

                                                                if (Object.prototype.hasOwnProperty.call(statusMap, status)) {
                                                                    statusMap[status] = Number(item.totalCount || 0);
                                                                }
                                                            });
                                                        }

                                                        const statusValues = [
                                                            statusMap.Waiting,
                                                            statusMap.In_Progress,
                                                            statusMap.Completed,
                                                            statusMap.No_Show
                                                        ];

                                                        const flowCanvas = document.getElementById('todayHourlyFlowChart');
                                                        const hasFlowData = flowValues.some(value => Number(value || 0) > 0);

                                                        if (!hasFlowData) {
                                                            showChartEmptyState('todayHourlyFlowChart', 'Không có lượt khám hôm nay');
                                                        } else if (flowCanvas) {
                                                            hideChartEmptyState('todayHourlyFlowChart');

                                                            new Chart(flowCanvas, {
                                                                type: 'bar',
                                                                data: {
                                                                    labels: flowLabels,
                                                                    datasets: [{
                                                                            label: 'Số lượt khám',
                                                                            data: flowValues,
                                                                            borderWidth: 1,
                                                                            borderRadius: 8,
                                                                            maxBarThickness: 28,
                                                                            backgroundColor: 'rgba(31, 119, 180, 0.35)',
                                                                            borderColor: '#1f77b4'
                                                                        }]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    plugins: {
                                                                        legend: {
                                                                            display: true
                                                                        }
                                                                    },
                                                                    scales: {
                                                                        x: {
                                                                            ticks: {
                                                                                autoSkip: false,
                                                                                maxRotation: 45,
                                                                                minRotation: 45
                                                                            }
                                                                        },
                                                                        y: {
                                                                            beginAtZero: true,
                                                                            ticks: {
                                                                                precision: 0,
                                                                                stepSize: 1
                                                                            }
                                                                        }
                                                                    }
                                                                }
                                                            });
                                                        }

                                                        const revenueCanvas = document.getElementById('todayRevenueServiceChart');
                                                        const hasRevenueData = revenueValues.some(value => Number(value || 0) > 0);

                                                        if (!hasRevenueData) {
                                                            showChartEmptyState('todayRevenueServiceChart', 'Hôm nay chưa có doanh thu');
                                                        } else if (revenueCanvas) {
                                                            hideChartEmptyState('todayRevenueServiceChart');

                                                            new Chart(revenueCanvas, {
                                                                type: 'bar',
                                                                data: {
                                                                    labels: ['Khám bệnh', 'Xét nghiệm'],
                                                                    datasets: [{
                                                                            label: 'Doanh thu',
                                                                            data: revenueValues,
                                                                            borderRadius: 12,
                                                                            maxBarThickness: 56,
                                                                            backgroundColor: ['rgba(20, 184, 166, 0.78)', 'rgba(124, 58, 237, 0.72)'],
                                                                            borderColor: ['#0f766e', '#6d28d9'],
                                                                            borderWidth: 1
                                                                        }]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    plugins: {
                                                                        legend: {
                                                                            display: true,
                                                                            labels: {
                                                                                boxWidth: 24
                                                                            }
                                                                        },
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
                                                        const hasStatusData = statusValues.some(value => Number(value || 0) > 0);

                                                        if (!hasStatusData) {
                                                            showChartEmptyState('todayStatusPieChart', 'Hôm nay chưa có ca khám');
                                                        } else if (statusCanvas) {
                                                            hideChartEmptyState('todayStatusPieChart');

                                                            new Chart(statusCanvas, {
                                                                type: 'doughnut',
                                                                data: {
                                                                    labels: ['Đang chờ', 'Đang khám', 'Đã hoàn tất', 'Không đến'],
                                                                    datasets: [{
                                                                            data: statusValues,
                                                                            backgroundColor: ['#f4a261', '#4cc9f0', '#2a9d8f', '#6c757d']
                                                                        }]
                                                                },
                                                                options: {
                                                                    responsive: true,
                                                                    maintainAspectRatio: false,
                                                                    cutout: '68%'
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
                                                    }
                                                    );
                                                    window.openAccountQuickModal = openAccountQuickModal;
                                                    window.openRevenueQuickModal = openRevenueQuickModal;
                                                    window.openServiceQuickModal = openServiceQuickModal;
                                                    window.openAppointmentQuickModal = openAppointmentQuickModal;
                                                    window.openLockedAccountsModal = openLockedAccountsModal;
                                                    window.openCompletedAppointmentsModal = openCompletedAppointmentsModal;
                                                    window.openDoctorQueueModal = openDoctorQueueModal;
                                                    window.openTodayAppointmentsModal = openTodayAppointmentsModal;
                                                    window.openTodayWaitingModal = openTodayWaitingModal;
                                                    window.openDoctorShiftModal = openDoctorShiftModal;
        </script>

        <%--
        ==================== Servlet + DAO mẫu để cấp dữ liệu động cho Dashboard ====================

// AdminDashboardServlet.java (mẫu)
@WebServlet("/admin")
public class AdminDashboardServlet extends HttpServlet {
    private final DashboardDAO dashboardDAO = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int todayAppointments = dashboardDAO.countTodayAppointments();
        int waitingPatients = dashboardDAO.countWaitingPatientsToday();
        int availableBeds = dashboardDAO.countAvailableBeds();

        request.setAttribute("todayAppointments", todayAppointments);
        request.setAttribute("waitingPatients", waitingPatients);
        request.setAttribute("availableBeds", availableBeds);

        request.getRequestDispatcher("/admin/dashboard.jsp").forward(request, response);
    }
}

// DashboardDAO.java (mẫu JDBC SQL Server)
public class DashboardDAO {
    public int countTodayAppointments() {
        String sql = "SELECT COUNT(*) FROM Appointment WHERE CAST(appointment_date AS date) = CAST(GETDATE() AS date)";
        return queryForCount(sql);
    }

    public int countWaitingPatientsToday() {
        String sql = "SELECT COUNT(*) FROM Appointment WHERE status = 'Waiting' AND CAST(appointment_date AS date) = CAST(GETDATE() AS date)";
        return queryForCount(sql);
    }

    public int countAvailableBeds() {
        String sql = "SELECT COUNT(*) FROM Bed WHERE status = 'Available'";
        return queryForCount(sql);
    }

    private int queryForCount(String sql) {
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}

// AdminAccountServlet.java JSON mẫu: /AdminAccountServlet?action=getAccounts&status=locked
// AdminAppointmentServlet.java JSON mẫu: /AdminAppointmentServlet?action=getAppointments&status=Completed
==============================================================================================
        --%>
    </body>
</html>





