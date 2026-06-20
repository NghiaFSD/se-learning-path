<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Điều phối khẩn cấp và xử lý sự cố - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container py-5">
    <div class="alert alert-danger">
        Màn hình này chỉ dùng cho ngoại lệ vận hành: bác sĩ nghỉ đột xuất, xung đột lịch trực hoặc lỗi dữ liệu xét nghiệm.
        Luồng khám thông thường vẫn tuân thủ BR-08 và được điều khiển tự động bởi trạng thái Appointment cùng vai trò vận hành.
    </div>

    <div class="card mb-3">
        <div class="card-header fw-semibold">Hướng dẫn xử lý ngoại lệ</div>
        <div class="card-body">
            <ol class="mb-0">
                <li>Xác nhận nguyên nhân sự cố và phạm vi ảnh hưởng.</li>
                <li>Điều chỉnh lịch trực hoặc trạng thái khám tại các phân hệ quản trị tương ứng.</li>
                <li>Ghi nhận biên bản xử lý và thông báo lại cho Lễ tân/Bác sĩ liên quan.</li>
            </ol>
        </div>
    </div>

    <div class="d-flex gap-2">
        <a class="btn btn-outline-primary" href="${pageContext.request.contextPath}/admin?action=manageSchedules">Mở quản lý lịch trực</a>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin?action=reports">Mở báo cáo tổng hợp</a>
        <a class="btn btn-primary" href="${pageContext.request.contextPath}/admin">Quay lại Dashboard Admin</a>
    </div>
</div>
</body>
</html>
