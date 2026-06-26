<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:if test="${empty users and empty errorMessage}">
    <c:redirect url="/admin?action=listUsers"/>
</c:if>

<c:set var="currentAction" value="listUsers" />

<%--
    Trang Quản lý tài khoản:
    - Lọc danh sách account theo role/status
    - Tạo user mới, khóa/mở tài khoản, cập nhật thông tin chi tiết
--%>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Quản lý tài khoản và phân quyền - S-COMS</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css" rel="stylesheet">

    <link href="${pageContext.request.contextPath}/css/admin-ui.css" rel="stylesheet">
    <style>
        tr.account-row { cursor: pointer; }
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
                <h3 class="mb-1">Hệ thống Điều hành & Quản trị Danh mục S-COMS</h3>
                <p class="text-secondary mb-0">FR-ADM-01: Quản lý tài khoản</p>
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
        <div class="card-body border-bottom">
            <form class="row g-2 align-items-end" method="get" action="${pageContext.request.contextPath}/admin">
                <input type="hidden" name="action" value="listUsers">
                <div class="col-md-4">
                    <label class="form-label mb-1">Lọc theo vai trò</label>
                    <select class="form-select" name="role">
                        <option value="" ${empty selectedRole ? 'selected' : ''}>Tất cả vai trò</option>
                        <option value="Patient" ${selectedRole == 'Patient' ? 'selected' : ''}>Bệnh nhân</option>
                        <option value="Doctor" ${selectedRole == 'Doctor' ? 'selected' : ''}>Bác sĩ</option>
                        <option value="Receptionist" ${selectedRole == 'Receptionist' ? 'selected' : ''}>Lễ tân</option>
                        <option value="Admin" ${selectedRole == 'Admin' ? 'selected' : ''}>Quản trị viên</option>
                    </select>
                </div>
                <div class="col-md-3 d-flex gap-2">
                    <button class="btn btn-primary" type="submit">Lọc</button>
                    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/admin?action=listUsers">Xóa lọc</a>
                </div>
            </form>
        </div>
        <div class="table-responsive">
            <table class="table table-hover align-middle mb-0">
                <thead class="table-light">
                <tr>
                    <th>ID</th><th>Họ tên</th><th>Email</th><th>Vai trò</th><th>Trạng thái</th><th>Ngày tạo</th><th>Thao tác</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach var="u" items="${users}">
                    <tr class="account-row" data-account-id="${u.id}">
                        <td>${u.id}</td>
                        <td>${u.fullName}</td>
                        <td>${u.email}</td>
                        <td>
                            <c:choose>
                                <c:when test="${u.role == 'Patient'}"><span class="badge text-bg-info">Bệnh nhân</span></c:when>
                                <c:when test="${u.role == 'Doctor'}"><span class="badge text-bg-primary">Bác sĩ</span></c:when>
                                <c:when test="${u.role == 'Receptionist'}"><span class="badge text-bg-secondary">Lễ tân</span></c:when>
                                <c:when test="${u.role == 'Admin'}"><span class="badge text-bg-dark">Quản trị viên</span></c:when>
                                <c:otherwise><span class="badge text-bg-light">${u.role}</span></c:otherwise>
                            </c:choose>
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
                            <div class="d-flex flex-wrap gap-2">
                                <button type="button" class="btn btn-sm btn-outline-info edit-account-btn" data-account-id="${u.id}">
                                    Sửa
                                </button>
                                <c:choose>
                                    <c:when test="${u.status == 'Locked'}">
                                        <form method="post" action="${pageContext.request.contextPath}/admin">
                                            <input type="hidden" name="action" value="reactivateAccount">
                                            <input type="hidden" name="accountId" value="${u.id}">
                                            <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                            <button class="btn btn-sm btn-outline-success" type="submit">Kích hoạt lại</button>
                                        </form>
                                        <c:if test="${u.role != 'Doctor'}">
                                            <form class="confirm-action-form" data-confirm-message="Bạn có chắc muốn xóa tài khoản này? Hành động không thể hoàn tác." method="post" action="${pageContext.request.contextPath}/admin">
                                                <input type="hidden" name="action" value="deleteAccount">
                                                <input type="hidden" name="accountId" value="${u.id}">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <button class="btn btn-sm btn-outline-danger" type="submit">Xóa</button>
                                            </form>
                                        </c:if>
                                    </c:when>
                                    <c:otherwise>
                                        <c:choose>
                                            <c:when test="${u.role == 'Doctor'}">
                                                <form class="confirm-action-form" data-confirm-message="Bạn có chắc muốn vô hiệu hóa tài khoản bác sĩ này?" method="post" action="${pageContext.request.contextPath}/admin">
                                                    <input type="hidden" name="action" value="lockAccount">
                                                    <input type="hidden" name="accountId" value="${u.id}">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <button class="btn btn-sm btn-outline-warning" type="submit">Vô hiệu hóa</button>
                                                </form>
                                            </c:when>
                                            <c:otherwise>
                                                <form class="confirm-action-form" data-confirm-message="Bạn có chắc muốn khóa tài khoản này?" method="post" action="${pageContext.request.contextPath}/admin">
                                                    <input type="hidden" name="action" value="lockAccount">
                                                    <input type="hidden" name="accountId" value="${u.id}">
                                                    <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                    <button class="btn btn-sm btn-outline-warning" type="submit">Khóa</button>
                                                </form>
                                            </c:otherwise>
                                        </c:choose>
                                        <c:if test="${u.role != 'Doctor'}">
                                            <form class="confirm-action-form" data-confirm-message="Bạn có chắc muốn xóa tài khoản này? Hành động không thể hoàn tác." method="post" action="${pageContext.request.contextPath}/admin">
                                                <input type="hidden" name="action" value="deleteAccount">
                                                <input type="hidden" name="accountId" value="${u.id}">
                                                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                                                <button class="btn btn-sm btn-outline-danger" type="submit">Xóa</button>
                                            </form>
                                        </c:if>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </td>
                    </tr>
                </c:forEach>
                </tbody>
            </table>
        </div>
    </div>
        </div>
    </div>
</div>

<div class="modal fade" id="viewAccountModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Thông tin tài khoản</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="alert alert-light border" id="viewRoleInfo">Vai trò: -</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label text-secondary">Họ và tên</label>
                        <div class="form-control bg-light" id="viewFullName">-</div>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label text-secondary">Email</label>
                        <div class="form-control bg-light" id="viewEmail">-</div>
                    </div>
                    <div class="col-md-6 d-none" id="viewPhoneWrap">
                        <label class="form-label text-secondary">Số điện thoại</label>
                        <div class="form-control bg-light" id="viewPhone">-</div>
                    </div>
                    <div class="col-md-6 d-none" id="viewDepartmentWrap">
                        <label class="form-label text-secondary">Chuyên khoa</label>
                        <div class="form-control bg-light" id="viewDepartment">-</div>
                    </div>
                    <div class="col-12 d-none" id="viewAddressWrap">
                        <label class="form-label text-secondary">Địa chỉ</label>
                        <div class="form-control bg-light" id="viewAddress">-</div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="actionConfirmModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 shadow-lg">
            <div class="modal-header">
                <h5 class="modal-title" id="actionConfirmTitle">Xác nhận thao tác</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p class="mb-0" id="actionConfirmMessage">Bạn có chắc muốn tiếp tục?</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Hủy</button>
                <button type="button" class="btn btn-warning" id="actionConfirmSubmitBtn">Xác nhận</button>
            </div>
        </div>
    </div>
</div>

<div class="modal fade" id="editAccountModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-lg modal-dialog-centered">
        <div class="modal-content">
            <form method="post" action="${pageContext.request.contextPath}/admin" id="editAccountForm">
                <input type="hidden" name="action" value="updateAccountProfile">
                <input type="hidden" name="csrfToken" value="${sessionScope.csrfToken}">
                <input type="hidden" name="accountId" id="editAccountId">

                <div class="modal-header">
                    <h5 class="modal-title">Chỉnh sửa hồ sơ tài khoản</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="alert alert-light border" id="editRoleInfo">Vai trò: -</div>

                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label">Họ và tên</label>
                            <input class="form-control" name="fullName" id="editFullName" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label">Email</label>
                            <input type="email" class="form-control" name="email" id="editEmail" required>
                        </div>

                        <div class="col-md-6 d-none" id="editPhoneWrap">
                            <label class="form-label">Số điện thoại</label>
                            <input class="form-control" name="phone" id="editPhone">
                        </div>

                        <div class="col-md-6 d-none" id="editDepartmentWrap">
                            <label class="form-label">Chuyên khoa (Bác sĩ)</label>
                            <select class="form-select" name="department" id="editDepartment">
                                <option value="Endocrinology">Nội tiết - Tiểu đường</option>
                                <option value="Cardiology">Tim mạch</option>
                                <option value="Nephrology">Thận học</option>
                                <option value="General">Tổng quát</option>
                            </select>
                        </div>

                        <div class="col-12 d-none" id="editAddressWrap">
                            <label class="form-label">Địa chỉ (Bệnh nhân)</label>
                            <input class="form-control" name="address" id="editAddress">
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Đóng</button>
                    <button type="submit" class="btn btn-primary">Lưu thay đổi</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    (function () {
        const viewModalElement = document.getElementById('viewAccountModal');
        const viewModal = new bootstrap.Modal(viewModalElement);
        const actionConfirmModalElement = document.getElementById('actionConfirmModal');
        const actionConfirmModal = new bootstrap.Modal(actionConfirmModalElement);
        const actionConfirmTitle = document.getElementById('actionConfirmTitle');
        const actionConfirmMessage = document.getElementById('actionConfirmMessage');
        const actionConfirmSubmitBtn = document.getElementById('actionConfirmSubmitBtn');
        const modalElement = document.getElementById('editAccountModal');
        const modal = new bootstrap.Modal(modalElement);
        const basePath = '${pageContext.request.contextPath}';
        let pendingConfirmForm = null;

        const departmentTextMap = {
            Endocrinology: 'Nội tiết - Tiểu đường',
            Cardiology: 'Tim mạch',
            Nephrology: 'Thận học',
            General: 'Tổng quát'
        };

        function roleText(role) {
            const roleTextMap = {
                Patient: 'Bệnh nhân',
                Doctor: 'Bác sĩ',
                Receptionist: 'Lễ tân',
                Admin: 'Quản trị viên'
            };
            return roleTextMap[role] || role || 'Không xác định';
        }

        const viewFields = {
            roleInfo: document.getElementById('viewRoleInfo'),
            fullName: document.getElementById('viewFullName'),
            email: document.getElementById('viewEmail'),
            phone: document.getElementById('viewPhone'),
            address: document.getElementById('viewAddress'),
            department: document.getElementById('viewDepartment'),
            phoneWrap: document.getElementById('viewPhoneWrap'),
            addressWrap: document.getElementById('viewAddressWrap'),
            departmentWrap: document.getElementById('viewDepartmentWrap')
        };

        const fields = {
            accountId: document.getElementById('editAccountId'),
            fullName: document.getElementById('editFullName'),
            email: document.getElementById('editEmail'),
            phone: document.getElementById('editPhone'),
            address: document.getElementById('editAddress'),
            department: document.getElementById('editDepartment'),
            roleInfo: document.getElementById('editRoleInfo'),
            phoneWrap: document.getElementById('editPhoneWrap'),
            addressWrap: document.getElementById('editAddressWrap'),
            departmentWrap: document.getElementById('editDepartmentWrap')
        };

        function setRoleDisplay(role) {
            fields.roleInfo.textContent = 'Vai trò: ' + roleText(role);

            const isPatient = role === 'Patient';
            const isDoctor = role === 'Doctor';

            fields.phoneWrap.classList.toggle('d-none', !(isPatient || isDoctor));
            fields.addressWrap.classList.toggle('d-none', !isPatient);
            fields.departmentWrap.classList.toggle('d-none', !isDoctor);
            fields.department.required = isDoctor;
        }

        function fillViewProfile(item) {
            const role = item.role || '';
            const isPatient = role === 'Patient';
            const isDoctor = role === 'Doctor';

            viewFields.roleInfo.textContent = 'Vai trò: ' + roleText(role);
            viewFields.fullName.textContent = item.fullName || '-';
            viewFields.email.textContent = item.email || '-';
            viewFields.phone.textContent = item.phone || '-';
            viewFields.address.textContent = item.address || '-';
            viewFields.department.textContent = departmentTextMap[item.department] || item.department || '-';

            viewFields.phoneWrap.classList.toggle('d-none', !(isPatient || isDoctor));
            viewFields.addressWrap.classList.toggle('d-none', !isPatient);
            viewFields.departmentWrap.classList.toggle('d-none', !isDoctor);
        }

        async function fetchAccountProfile(accountId) {
            const url = basePath + '/admin?action=getAccountProfile&accountId=' + encodeURIComponent(accountId);
            const response = await fetch(url, {headers: {'Accept': 'application/json'}});
            if (!response.ok) {
                throw new Error('HTTP ' + response.status);
            }
            const payload = await response.json();
            if (!payload.success || !payload.item) {
                throw new Error(payload.message || 'Không tải được hồ sơ');
            }

            return payload.item;
        }

        async function openEditModal(accountId) {
            const item = await fetchAccountProfile(accountId);

            fields.accountId.value = item.accountId || '';
            fields.fullName.value = item.fullName || '';
            fields.email.value = item.email || '';
            fields.phone.value = item.phone || '';
            fields.address.value = item.address || '';
            fields.department.value = item.department || 'General';
            setRoleDisplay(item.role || '');

            modal.show();
        }

        async function openViewModal(accountId) {
            const item = await fetchAccountProfile(accountId);
            fillViewProfile(item);
            viewModal.show();
        }

        document.addEventListener('click', function (event) {
            const button = event.target.closest('.edit-account-btn');
            if (button) {
                const accountId = button.getAttribute('data-account-id');
                if (!accountId) {
                    return;
                }
                openEditModal(accountId).catch(function (err) {
                    alert('Không thể tải hồ sơ tài khoản. ' + err.message);
                });
                return;
            }

            const row = event.target.closest('tr.account-row');
            if (!row) {
                return;
            }
            if (event.target.closest('button, a, input, select, textarea, label, form')) {
                return;
            }

            const accountId = row.getAttribute('data-account-id');
            if (!accountId) {
                return;
            }

            openViewModal(accountId).catch(function (err) {
                alert('Không thể tải thông tin tài khoản. ' + err.message);
            });
        });

        document.addEventListener('submit', function (event) {
            const form = event.target.closest('form');
            if (!form) {
                return;
            }

            if (form.classList.contains('confirm-action-form')) {
                event.preventDefault();

                pendingConfirmForm = form;
                const actionField = form.querySelector('input[name="action"]');
                const actionValue = actionField ? actionField.value : '';
                const submitBtn = form.querySelector('button[type="submit"]');
                const submitLabel = submitBtn ? submitBtn.textContent.trim() : '';
                const row = form.closest('tr.account-row');
                const nameCell = row ? row.querySelector('td:nth-child(2)') : null;
                const accountName = nameCell ? nameCell.textContent.trim() : 'tài khoản này';

                let title = 'Xác nhận thao tác';
                let message = form.getAttribute('data-confirm-message') || 'Bạn có chắc muốn tiếp tục?';

                if (actionValue === 'deleteAccount') {
                    title = 'Xác nhận xóa';
                    message = 'Bạn có chắc muốn xóa tài khoản "' + accountName + '"? Hành động không thể hoàn tác.';
                } else if (actionValue === 'lockAccount' && submitLabel === 'Vô hiệu hóa') {
                    title = 'Xác nhận vô hiệu hóa';
                    message = 'Bạn có chắc muốn vô hiệu hóa tài khoản bác sĩ "' + accountName + '"?';
                } else if (actionValue === 'lockAccount') {
                    title = 'Xác nhận khóa';
                    message = 'Bạn có chắc muốn khóa tài khoản "' + accountName + '"?';
                }

                actionConfirmTitle.textContent = title;
                actionConfirmMessage.textContent = message;
                actionConfirmSubmitBtn.classList.remove('btn-danger', 'btn-warning');
                actionConfirmSubmitBtn.classList.add(actionValue === 'deleteAccount' ? 'btn-danger' : 'btn-warning');
                actionConfirmModal.show();
                return;
            }
        });

        actionConfirmSubmitBtn.addEventListener('click', function () {
            if (!pendingConfirmForm) {
                actionConfirmModal.hide();
                return;
            }

            const submittingForm = pendingConfirmForm;
            pendingConfirmForm = null;
            actionConfirmModal.hide();
            HTMLFormElement.prototype.submit.call(submittingForm);
        });

        actionConfirmModalElement.addEventListener('hidden.bs.modal', function () {
            if (pendingConfirmForm) {
                pendingConfirmForm = null;
            }
        });

        document.addEventListener('keydown', function (event) {
            if (event.key !== 'Enter') {
                return;
            }
            if (!pendingConfirmForm) {
                return;
            }
            if (!actionConfirmModalElement.classList.contains('show')) {
                return;
            }
            event.preventDefault();
            actionConfirmSubmitBtn.click();
        });
    })();
</script>
</body>
</html>



