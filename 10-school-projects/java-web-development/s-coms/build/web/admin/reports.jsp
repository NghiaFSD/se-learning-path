<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="currentAction" value="reports" />

<%--
    Trang Báo cáo Admin:
    - Tổng hợp doanh thu và lượt khám theo ngày/tháng/năm
    - Cho phép drill-down chi tiết hóa đơn và lịch hẹn theo kỳ
--%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo Doanh thu và Lượt khám - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/css/admin-ui.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
    <style>
        .report-chart-panel {
            position: relative;
            height: 320px;
            min-height: 320px;
        }

        .report-table-scroll {
            max-height: 470px;
            overflow-y: auto;
            overflow-x: auto;
            border: 1px solid #e9ecef;
            border-radius: 12px;
        }

        .report-table-scroll table {
            margin-bottom: 0;
            table-layout: fixed;
            width: 100%;
        }

        .report-table-scroll thead th {
            position: sticky;
            top: 0;
            z-index: 2;
            background: #f8f9fa;
            word-wrap: break-word;
            white-space: normal;
        }

        .report-chart-panel canvas {
            width: 100% !important;
            height: 100% !important;
        }

        /* Table cell styling */
        .report-table-scroll table tbody td {
            vertical-align: middle;
            word-wrap: break-word;
            overflow-wrap: break-word;
        }

        .report-table-scroll table tbody td button {
            white-space: nowrap;
        }

        /* Column sizing for invoice table */
        .report-table-scroll table thead th:nth-child(1),
        .report-table-scroll table tbody td:nth-child(1) {
            width: 10%;
        }

        .report-table-scroll table thead th:nth-child(2),
        .report-table-scroll table tbody td:nth-child(2) {
            width: 18%;
        }

        .report-table-scroll table thead th:nth-child(3),
        .report-table-scroll table tbody td:nth-child(3) {
            width: 15%;
        }

        .report-table-scroll table thead th:nth-child(4),
        .report-table-scroll table tbody td:nth-child(4) {
            width: 15%;
        }

        .report-table-scroll table thead th:nth-child(5),
        .report-table-scroll table tbody td:nth-child(5) {
            width: 15%;
        }

        .report-table-scroll table thead th:nth-child(6),
        .report-table-scroll table tbody td:nth-child(6) {
            width: 15%;
        }

        .report-table-scroll table thead th:nth-child(7),
        .report-table-scroll table tbody td:nth-child(7) {
            width: 12%;
        }

        @media (max-width: 992px) {
            .report-chart-panel {
                height: 280px;
                min-height: 280px;
            }
        }
    </style>
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="admin-layout row g-3">
        <div class="col-lg-3 admin-sidebar-col">
            <%@ include file="/admin/fragments/sidebar.jspf" %>
        </div>
        <div class="col-lg-9 admin-content-col">
            <div class="admin-page-header mb-3">
                <h2 class="mb-1">Phân hệ Báo cáo Doanh thu &amp; Hiệu suất Phòng khám S-COMS</h2>
                <p class="text-secondary mb-0">FR-ADM-06 và FR-ADM-07</p>
            </div>

    <c:if test="${not empty errorMessage}">
        <div class="alert alert-danger" role="alert">${errorMessage}</div>
    </c:if>

    <div class="card mb-4">
        <div class="card-body">
            <form method="get" action="${pageContext.request.contextPath}/admin" class="row g-3 align-items-end">
                <input type="hidden" name="action" value="reports">
                <div class="col-md-4">
                    <label class="form-label">Chế độ xem</label>
                    <div class="d-flex gap-3">
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="granularity" id="gDay" value="day" ${granularity == 'day' ? 'checked' : ''}>
                            <label class="form-check-label" for="gDay">Theo Ngày</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="granularity" id="gMonth" value="month" ${granularity == 'month' ? 'checked' : ''}>
                            <label class="form-check-label" for="gMonth">Theo Tháng</label>
                        </div>
                        <div class="form-check">
                            <input class="form-check-input" type="radio" name="granularity" id="gYear" value="year" ${granularity == 'year' ? 'checked' : ''}>
                            <label class="form-check-label" for="gYear">Theo Năm</label>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <label class="form-label">Năm</label>
                    <input class="form-control" type="number" name="year" value="${year}" placeholder="2026">
                </div>
                <div class="col-md-2">
                    <label class="form-label">Tháng</label>
                    <input class="form-control" type="number" min="1" max="12" name="month" value="${month}" placeholder="6">
                </div>
                <div class="col-md-3 d-none" id="reportRangeFilterWrap">
                    <label class="form-label">Từ ngày</label>
                    <input class="form-control" type="date" name="reportStartDate" id="reportStartDate" value="${reportStartDate}">
                    <label class="form-label mt-2">Đến ngày</label>
                    <input class="form-control" type="date" name="reportEndDate" id="reportEndDate" value="${reportEndDate}">
                    <div class="form-text">Dùng khi chọn chế độ xem theo ngày. Mặc định là cả tháng hiện tại.</div>
                </div>
                <div class="col-md-2" id="reportSubmitWrap">
                    <button type="submit" class="btn btn-primary w-100">Lọc dữ liệu</button>
                </div>
            </form>
        </div>
    </div>

    <div class="row g-4">
        <div class="col-lg-6">
            <div class="card h-100">
                <div class="card-header fw-semibold">Doanh thu (SUM(final_amount), Invoice.status = 'Paid')</div>
                <div class="card-body">
                    <div class="report-chart-panel">
                        <canvas id="revenueChart"></canvas>
                    </div>
                    <div class="table-responsive report-table-scroll mt-3">
                        <table class="table table-sm align-middle">
                            <thead><tr><th>Kỳ</th><th>Doanh thu</th></tr></thead>
                            <tbody>
                            <c:forEach var="r" items="${revenueSeries}">
                                <tr>
                                    <td>${r.period}</td>
                                    <td>
                                        <fmt:formatNumber value="${r.value}" type="number" maxFractionDigits="0" groupingUsed="true" /> VNĐ
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-6">
            <div class="card h-100">
                <div class="card-header fw-semibold">Lượt khám (COUNT(appointment_id), Appointment.status = 'Completed')</div>
                <div class="card-body">
                    <div class="report-chart-panel">
                        <canvas id="visitChart"></canvas>
                    </div>
                    <div class="table-responsive report-table-scroll mt-3">
                        <table class="table table-sm align-middle">
                            <thead><tr><th>Kỳ</th><th>Lượt khám</th></tr></thead>
                            <tbody>
                            <c:forEach var="v" items="${visitSeries}">
                                <tr><td>${v.period}</td><td>${v.value}</td></tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="card mt-4">
        <div class="card-header fw-semibold d-flex justify-content-between align-items-center">
            <span>Danh sách chi tiết hóa đơn &amp; lượt khám trong kỳ</span>
            <span id="selectedPeriodBadge" class="badge bg-secondary">Chưa chọn kỳ</span>
        </div>
        <div class="card-body">
            <ul class="nav nav-tabs" role="tablist">
                <li class="nav-item" role="presentation">
                    <button class="nav-link active" id="invoiceTab" data-bs-toggle="tab" data-bs-target="#invoicePane" type="button" role="tab" aria-controls="invoicePane" aria-selected="true">Hóa đơn</button>
                </li>
                <li class="nav-item" role="presentation">
                    <button class="nav-link" id="appointmentTab" data-bs-toggle="tab" data-bs-target="#appointmentPane" type="button" role="tab" aria-controls="appointmentPane" aria-selected="false">Lượt khám</button>
                </li>
            </ul>
            <div class="tab-content mt-3">
                <div class="tab-pane fade show active" id="invoicePane" role="tabpanel" aria-labelledby="invoiceTab">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm">
                            <thead class="table-light">
                            <tr>
                                <th>ID Hóa đơn</th>
                                <th>Bệnh nhân</th>
                                <th class="text-end">Tổng tiền</th>
                                <th class="text-end">Khấu trừ BHYT</th>
                                <th class="text-end">Tiền thanh toán</th>
                                <th>Ngày thanh toán</th>
                                <th>Hành động</th>
                            </tr>
                            </thead>
                            <tbody id="invoiceTableBody">
                            <tr><td colspan="7" class="text-center text-muted py-3">Đang tải dữ liệu kỳ gần nhất...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
                <div class="tab-pane fade" id="appointmentPane" role="tabpanel" aria-labelledby="appointmentTab">
                    <div class="table-responsive">
                        <table class="table table-hover table-sm">
                            <thead class="table-light">
                            <tr>
                                <th>Mã lượt khám</th>
                                <th>Tên bệnh nhân</th>
                                <th>Bác sĩ điều trị</th>
                                <th>Khung giờ</th>
                                <th>Trạng thái</th>
                                <th>Ngày khám</th>
                            </tr>
                            </thead>
                            <tbody id="appointmentTableBody">
                            <tr><td colspan="6" class="text-center text-muted py-3">Đang tải dữ liệu kỳ gần nhất...</td></tr>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>
        </div>
    </div>
</div>

<div class="modal fade" id="invoiceDetailModal" tabindex="-1" aria-labelledby="invoiceDetailModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-scrollable">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="invoiceDetailModalLabel">Chi tiết hóa đơn</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="mb-2 text-secondary">Mã hóa đơn: <span id="invoiceDetailModalInvoiceId" class="fw-semibold">-</span></p>
                <div class="table-responsive">
                    <table class="table table-sm table-hover align-middle">
                        <thead class="table-light">
                        <tr>
                            <th>Dịch vụ</th>
                            <th class="text-end">Số lượng</th>
                            <th class="text-end">Đơn giá</th>
                            <th class="text-end">Thành tiền</th>
                        </tr>
                        </thead>
                        <tbody id="invoiceItemTableBody">
                        <tr><td colspan="4" class="text-center text-muted py-3">Chưa có dữ liệu</td></tr>
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
<script>
    let revenueChart = null;
    let visitChart = null;
    let currentChartData = { revenueLabels: [], revenueValues: [], visitLabels: [], visitValues: [] };
    let currentSelectedPeriod = null;
    let currentDetailData = { invoices: [], appointments: [] };
    let invoiceDetailModalInstance = null;
    let selectedChartPeriod = '';

    const revenueSeries = ${empty revenueJson ? '[]' : revenueJson};
    const visitSeries = ${empty visitJson ? '[]' : visitJson};
    const granularityInputName = 'granularity';

    const revenueLabels = revenueSeries.map(x => x.period);
    const revenueValues = revenueSeries.map(x => Number(x.value || 0));
    const visitLabels = visitSeries.map(x => x.period);
    const visitValues = visitSeries.map(x => Number(x.value || 0));

    currentChartData = {
        revenueLabels: revenueLabels,
        revenueValues: revenueValues,
        visitLabels: visitLabels,
        visitValues: visitValues
    };

    const initialPeriod = revenueLabels.length > 0
        ? revenueLabels[revenueLabels.length - 1]
        : (visitLabels.length > 0 ? visitLabels[visitLabels.length - 1] : '');

    function createChartConfig(labels, values, chartLabel, activeColor, inactiveColor, onPick) {
        return {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                    label: chartLabel,
                    data: values,
                    borderColor: activeColor,
                    backgroundColor: buildChartColors(labels, selectedChartPeriod, activeColor, inactiveColor)
                }]
            },
            options: {
                maintainAspectRatio: false,
                onClick: (event, activeElements) => {
                    if (activeElements && activeElements.length > 0) {
                        const firstPoint = activeElements[0];
                        const clickedLabel = labels[firstPoint.index];
                        if (clickedLabel) {
                            onPick(clickedLabel);
                        }
                    }
                }
            }
        };
    }

    if (revenueLabels.length > 0) {
        revenueChart = new Chart(
            document.getElementById('revenueChart'),
            createChartConfig(
                revenueLabels,
                revenueValues,
                'Doanh thu (VNĐ)',
                'rgba(25,135,84,.95)',
                'rgba(25,135,84,.25)',
                fetchReportDetail
            )
        );
    }

    if (visitLabels.length > 0) {
        visitChart = new Chart(
            document.getElementById('visitChart'),
            createChartConfig(
                visitLabels,
                visitValues,
                'Lượt khám đã hoàn tất',
                'rgba(13,110,253,.95)',
                'rgba(13,110,253,.25)',
                fetchReportDetail
            )
        );
        visitChart.options.datasets = {
            bar: {
                categoryPercentage: 0.4,
                barPercentage: 0.8
            }
        };
        visitChart.update();
    }

    function escapeHtml(text) {
        if (text === null || text === undefined) return '';
        const map = {
            '&': '&amp;',
            '<': '&lt;',
            '>': '&gt;',
            '"': '&quot;',
            "'": '&#039;'
        };
        return String(text).replace(/[&<>"']/g, char => map[char]);
    }

    function formatCurrency(num) {
        if (num === null || num === undefined) return '0';
        const value = typeof num === 'string' ? parseFloat(num) : num;
        if (Number.isNaN(value)) return '0';
        return value.toLocaleString('vi-VN', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 2
        }) + ' VNĐ';
    }

    function getAppointmentStatusMeta(status) {
        const normalized = String(status || '').trim();
        switch (normalized) {
            case 'Completed':
                return { label: 'Hoàn tất', className: 'badge bg-success' };
            case 'No_Show':
                return { label: 'Không đến', className: 'badge bg-secondary' };
            case 'In_Progress':
                return { label: 'Đang khám', className: 'badge bg-info text-dark' };
            case 'Waiting':
                return { label: 'Chờ đợi', className: 'badge bg-warning text-dark' };
            default:
                return { label: normalized || 'Không xác định', className: 'badge bg-secondary' };
        }
    }

    function parseDetailResponse(data) {
        const invoices = Array.isArray(data && data.invoices) ? data.invoices : [];
        const appointments = Array.isArray(data && data.appointments) ? data.appointments : [];
        return { invoices, appointments };
    }

    function buildChartColors(labels, selectedLabel, activeColor, inactiveColor) {
        return labels.map(label => label === selectedLabel ? activeColor : inactiveColor);
    }

    function getSelectedGranularity() {
        const checked = document.querySelector('input[name="' + granularityInputName + '"]:checked');
        return checked ? checked.value : 'month';
    }

    function syncReportFilterUI() {
        const dayMode = getSelectedGranularity() === 'day';
        const reportRangeWrap = document.getElementById('reportRangeFilterWrap');
        const reportStartDateInput = document.getElementById('reportStartDate');
        const reportEndDateInput = document.getElementById('reportEndDate');
        const yearInput = document.querySelector('input[name="year"]');
        const monthInput = document.querySelector('input[name="month"]');
        if (reportRangeWrap) {
            reportRangeWrap.classList.toggle('d-none', !dayMode);
        }
        if (yearInput) {
            yearInput.closest('.col-md-2')?.classList.toggle('d-none', dayMode);
        }
        if (monthInput) {
            monthInput.closest('.col-md-2')?.classList.toggle('d-none', dayMode);
        }
        if (dayMode) {
            const today = new Date();
            const firstDay = new Date(today.getFullYear(), today.getMonth(), 1);
            const lastDay = new Date(today.getFullYear(), today.getMonth() + 1, 0);
            const pad = value => String(value).padStart(2, '0');

            if (reportStartDateInput && !reportStartDateInput.value) {
                reportStartDateInput.value = firstDay.getFullYear() + '-' + pad(firstDay.getMonth() + 1) + '-' + pad(firstDay.getDate());
            }
            if (reportEndDateInput && !reportEndDateInput.value) {
                reportEndDateInput.value = lastDay.getFullYear() + '-' + pad(lastDay.getMonth() + 1) + '-' + pad(lastDay.getDate());
            }
        }
        if (reportStartDateInput) {
            reportStartDateInput.required = dayMode;
        }
        if (reportEndDateInput) {
            reportEndDateInput.required = dayMode;
        }
    }

    function syncSelectedPeriodUI(period) {
        selectedChartPeriod = period || '';

        const badge = document.getElementById('selectedPeriodBadge');
        if (badge) {
            badge.textContent = selectedChartPeriod ? ('Đang xem kỳ: ' + selectedChartPeriod) : 'Chưa chọn kỳ';
            badge.className = 'badge ' + (selectedChartPeriod ? 'bg-primary' : 'bg-secondary');
        }

        if (revenueChart) {
            revenueChart.data.datasets[0].backgroundColor = buildChartColors(
                revenueChart.data.labels,
                selectedChartPeriod,
                'rgba(25,135,84,.95)',
                'rgba(25,135,84,.25)'
            );
            revenueChart.update();
        }

        if (visitChart) {
            visitChart.data.datasets[0].backgroundColor = buildChartColors(
                visitChart.data.labels,
                selectedChartPeriod,
                'rgba(13,110,253,.95)',
                'rgba(13,110,253,.25)'
            );
            visitChart.update();
        }
    }

    async function fetchReportDetail(period) {
        if (!period || (period.trim && period.trim() === '')) {
            return;
        }

        const normalizedPeriod = period.trim();
        const basePath = '${pageContext.request.contextPath}';
        const url = basePath + '/admin?action=getReportDetail&period=' + encodeURIComponent(normalizedPeriod);

        try {
            const response = await fetch(url, { headers: { 'Accept': 'application/json' } });
            if (!response.ok) {
                throw new Error('HTTP ' + response.status);
            }

            const data = await response.json();
            const parsed = parseDetailResponse(data);
            currentDetailData.invoices = parsed.invoices;
            currentDetailData.appointments = parsed.appointments;
            currentSelectedPeriod = normalizedPeriod;
            syncSelectedPeriodUI(normalizedPeriod);

            renderInvoiceTable(currentDetailData.invoices);
            renderAppointmentTable(currentDetailData.appointments);
        } catch (err) {
            console.error('[fetchReportDetail] Error:', err);
            alert('Không thể tải dữ liệu chi tiết kỳ ' + normalizedPeriod + '.');
        }
    }

    function renderInvoiceTable(invoices) {
        const tbody = document.getElementById('invoiceTableBody');
        if (!tbody) {
            return;
        }
        tbody.innerHTML = '';

        if (!invoices || invoices.length === 0) {
            tbody.innerHTML = '<tr><td colspan="7" class="text-center text-muted py-3">Không có dữ liệu</td></tr>';
            return;
        }

        let html = '';
        invoices.forEach(item => {
            const safeInvoiceId = String(item.invoiceId || '').replace(/'/g, "\\'");
            html += '<tr>';
            html += '<td>' + escapeHtml(item.invoiceId) + '</td>';
            html += '<td>' + escapeHtml(item.patientName) + '</td>';
            html += '<td class="text-end">' + formatCurrency(item.totalAmount) + '</td>';
            html += '<td class="text-end">' + formatCurrency(item.bhytDeduction) + '</td>';
            html += '<td class="text-end fw-semibold">' + formatCurrency(item.finalAmount) + '</td>';
            html += '<td>' + escapeHtml(item.paymentDate) + '</td>';
            html += '<td><button class="btn btn-sm btn-outline-primary" onclick="viewInvoiceDetail(\'' + safeInvoiceId + '\')">Xem chi tiết</button></td>';
            html += '</tr>';
        });
        tbody.innerHTML = html;
    }

    function renderAppointmentTable(appointments) {
        const tbody = document.getElementById('appointmentTableBody');
        if (!tbody) {
            return;
        }
        tbody.innerHTML = '';

        if (!appointments || appointments.length === 0) {
            tbody.innerHTML = '<tr><td colspan="6" class="text-center text-muted py-3">Không có dữ liệu</td></tr>';
            return;
        }

        let html = '';
        appointments.forEach(item => {
            const statusMeta = getAppointmentStatusMeta(item.status);
            html += '<tr>';
            html += '<td>' + escapeHtml(item.appointmentId) + '</td>';
            html += '<td>' + escapeHtml(item.patientName) + '</td>';
            html += '<td>' + escapeHtml(item.doctorName) + '</td>';
            html += '<td>' + escapeHtml(item.timeSlot) + '</td>';
            html += '<td><span class="' + statusMeta.className + '">' + escapeHtml(statusMeta.label) + '</span></td>';
            html += '<td>' + escapeHtml(item.appointmentDate) + '</td>';
            html += '</tr>';
        });
        tbody.innerHTML = html;
    }

    function renderInvoiceItemTable(items) {
        const tbody = document.getElementById('invoiceItemTableBody');
        if (!tbody) {
            return;
        }
        tbody.innerHTML = '';

        if (!items || items.length === 0) {
            tbody.innerHTML = '<tr><td colspan="4" class="text-center text-muted py-3">Không có chi tiết dịch vụ</td></tr>';
            return;
        }

        let html = '';
        items.forEach(item => {
            html += '<tr>';
            html += '<td>' + escapeHtml(item.serviceName || ('Dịch vụ #' + item.serviceId)) + '</td>';
            html += '<td class="text-end">' + escapeHtml(item.quantity) + '</td>';
            html += '<td class="text-end">' + formatCurrency(item.unitPrice) + '</td>';
            html += '<td class="text-end fw-semibold">' + formatCurrency(item.lineTotal) + '</td>';
            html += '</tr>';
        });
        tbody.innerHTML = html;
    }

    async function viewInvoiceDetail(invoiceId) {
        if (!invoiceId) {
            return;
        }

        const basePath = '${pageContext.request.contextPath}';
        const url = basePath + '/admin?action=getInvoiceItems&invoiceId=' + encodeURIComponent(invoiceId);
        const invoiceIdHolder = document.getElementById('invoiceDetailModalInvoiceId');
        if (invoiceIdHolder) {
            invoiceIdHolder.textContent = invoiceId;
        }

        renderInvoiceItemTable([]);

        try {
            const response = await fetch(url, { headers: { 'Accept': 'application/json' } });
            if (!response.ok) {
                throw new Error('HTTP ' + response.status);
            }
            const data = await response.json();
            renderInvoiceItemTable(Array.isArray(data.items) ? data.items : []);
        } catch (err) {
            console.error('[viewInvoiceDetail] Error:', err);
            renderInvoiceItemTable([]);
        }

        if (!invoiceDetailModalInstance) {
            invoiceDetailModalInstance = new bootstrap.Modal(document.getElementById('invoiceDetailModal'));
        }
        invoiceDetailModalInstance.show();
    }

    document.getElementById('invoiceTab').addEventListener('shown.bs.tab', function () {
        renderInvoiceTable(currentDetailData.invoices);
    });

    document.getElementById('appointmentTab').addEventListener('shown.bs.tab', function () {
        renderAppointmentTable(currentDetailData.appointments);
    });

    window.viewInvoiceDetail = viewInvoiceDetail;

    document.addEventListener('DOMContentLoaded', function () {
        syncReportFilterUI();
        document.querySelectorAll('input[name="granularity"]').forEach(function (radio) {
            radio.addEventListener('change', syncReportFilterUI);
        });

        const reportForm = document.querySelector('form[action="${pageContext.request.contextPath}/admin"]');
        if (reportForm) {
            reportForm.addEventListener('submit', function () {
                if (getSelectedGranularity() !== 'day') {
                    return;
                }
                const reportStartDateInput = document.getElementById('reportStartDate');
                const reportEndDateInput = document.getElementById('reportEndDate');
                if (!reportStartDateInput || !reportEndDateInput) {
                    return;
                }
                const startParts = reportStartDateInput.value ? reportStartDateInput.value.split('-') : [];
                const endParts = reportEndDateInput.value ? reportEndDateInput.value.split('-') : [];
                if (startParts.length === 3 && endParts.length === 3) {
                    const yearInput = document.querySelector('input[name="year"]');
                    const monthInput = document.querySelector('input[name="month"]');
                    if (yearInput) yearInput.value = startParts[0];
                    if (monthInput) monthInput.value = startParts[1];
                }
            });
        }

        if (initialPeriod) {
            syncSelectedPeriodUI(initialPeriod);
            fetchReportDetail(initialPeriod);
        }
    });
</script>
</body>
</html>



