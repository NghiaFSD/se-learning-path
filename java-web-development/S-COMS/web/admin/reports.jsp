<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo cáo Doanh thu và Lượt khám - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/css/admin-ui.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
</head>
<body class="bg-light">
<div class="container py-4">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <div>
            <h2 class="mb-1">Phân hệ Báo cáo Doanh thu &amp; Hiệu suất Phòng khám S-COMS</h2>
            <p class="text-secondary mb-0">FR-ADM-06 và FR-ADM-07</p>
        </div>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin">Dashboard</a>
    </div>

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
                <div class="col-md-2">
                    <label class="form-label">Ngày</label>
                    <input class="form-control" type="number" min="1" max="31" name="day" value="${day}" placeholder="19">
                </div>
                <div class="col-md-2">
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
                    <canvas id="revenueChart"></canvas>
                    <div class="table-responsive mt-3">
                        <table class="table table-sm align-middle">
                            <thead><tr><th>Kỳ</th><th>Doanh thu</th></tr></thead>
                            <tbody>
                            <c:forEach var="r" items="${revenueSeries}">
                                <tr><td>${r.period}</td><td>${r.value}</td></tr>
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
                    <canvas id="visitChart"></canvas>
                    <div class="table-responsive mt-3">
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
    let currentChartData = { labels: [], revenueValues: [], visitValues: [] };
    let currentSelectedPeriod = null;
    let currentDetailData = { invoices: [], appointments: [] };
    let invoiceDetailModalInstance = null;
    let selectedChartPeriod = '';

    const revenueSeries = ${revenueJson};
    const visitSeries = ${visitJson};

    const revenueLabels = revenueSeries.map(x => x.period);
    const revenueValues = revenueSeries.map(x => Number(x.value || 0));
    const visitLabels = visitSeries.map(x => x.period);
    const visitValues = visitSeries.map(x => Number(x.value || 0));

    currentChartData = {
        labels: revenueLabels,
        revenueValues: revenueValues,
        visitValues: visitValues
    };

    revenueChart = new Chart(document.getElementById('revenueChart'), {
        type: 'bar',
        data: {
            labels: revenueLabels,
            datasets: [{
                label: 'Doanh thu (VNĐ)',
                data: revenueValues,
                borderColor: '#198754',
                backgroundColor: buildChartColors(revenueLabels, '', 'rgba(25,135,84,.95)', 'rgba(25,135,84,.25)')
            }]
        },
        options: {
            onClick: (event, activeElements) => {
                if (activeElements && activeElements.length > 0) {
                    const firstPoint = activeElements[0];
                    const label = currentChartData.labels[firstPoint.index];
                    if (label) {
                        fetchReportDetail(label);
                    }
                }
            }
        }
    });

    visitChart = new Chart(document.getElementById('visitChart'), {
        type: 'bar',
        data: {
            labels: visitLabels,
            datasets: [{
                label: 'Lượt khám đã hoàn tất',
                data: visitValues,
                backgroundColor: buildChartColors(visitLabels, '', 'rgba(13,110,253,.95)', 'rgba(13,110,253,.25)')
            }]
        },
        options: {
            datasets: {
                bar: {
                    categoryPercentage: 0.4,
                    barPercentage: 0.8
                }
            },
            onClick: (event, activeElements) => {
                if (activeElements && activeElements.length > 0) {
                    const firstPoint = activeElements[0];
                    const label = currentChartData.labels[firstPoint.index];
                    if (label) {
                        fetchReportDetail(label);
                    }
                }
            }
        }
    });

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

    function formatNumber(num) {
        if (num === null || num === undefined) return '0';
        const value = typeof num === 'string' ? parseFloat(num) : num;
        if (Number.isNaN(value)) return '0';
        return value.toLocaleString('vi-VN', {
            minimumFractionDigits: 0,
            maximumFractionDigits: 2
        });
    }

    function parseDetailResponse(data) {
        const invoices = Array.isArray(data && data.invoices) ? data.invoices : [];
        const appointments = Array.isArray(data && data.appointments) ? data.appointments : [];
        return { invoices, appointments };
    }

    function buildChartColors(labels, selectedLabel, activeColor, inactiveColor) {
        return labels.map(label => label === selectedLabel ? activeColor : inactiveColor);
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
            html += '<td class="text-end">' + formatNumber(item.totalAmount) + ' VNĐ</td>';
            html += '<td class="text-end">' + formatNumber(item.bhytDeduction) + ' VNĐ</td>';
            html += '<td class="text-end fw-semibold">' + formatNumber(item.finalAmount) + ' VNĐ</td>';
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
            html += '<tr>';
            html += '<td>' + escapeHtml(item.appointmentId) + '</td>';
            html += '<td>' + escapeHtml(item.patientName) + '</td>';
            html += '<td>' + escapeHtml(item.doctorName) + '</td>';
            html += '<td>' + escapeHtml(item.timeSlot) + '</td>';
            html += '<td><span class="badge bg-success">' + escapeHtml(item.status || 'Completed') + '</span></td>';
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
            html += '<td class="text-end">' + formatNumber(item.unitPrice) + ' VNĐ</td>';
            html += '<td class="text-end fw-semibold">' + formatNumber(item.lineTotal) + ' VNĐ</td>';
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
        let latestLabel = null;
        if (currentChartData.labels.length > 0) {
            latestLabel = currentChartData.labels[currentChartData.labels.length - 1];
        }

        if (latestLabel) {
            syncSelectedPeriodUI(latestLabel);
            fetchReportDetail(latestLabel);
        }
    });
</script>
</body>
</html>



