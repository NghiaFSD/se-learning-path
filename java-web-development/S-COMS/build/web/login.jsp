<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Login - Diabetes Monitoring</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="min-height: 100vh; background: linear-gradient(135deg, #f4fbf9 0%, #e8f7f4 100%);">

    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 d-flex justify-content-center">
                
                <div class="card login-card border-0 shadow-lg p-3 bg-white">
                    <div class="card-body p-4 p-md-5">
                        <div class="text-center mb-4">
                            <h2 class="fw-bold text-dark mb-2">Welcome Back</h2>
                            <p class="text-secondary small">Login to access your patient dashboard or doctor support tools.</p>
                        </div>
                        <c:if test="${not empty loginError}">
                            <div class="alert alert-danger" role="alert">
                                ${loginError}
                            </div>
                        </c:if>
                        
                        <form action="auth" method="post" class="needs-validation" novalidate id="loginForm">
                            
                            <div class="mb-3">
                                <label for="email" class="form-label text-secondary fw-semibold small">Email address</label>
                                <div class="input-group custom-input-group">
                                    <span class="input-group-text bg-white border-end-0 text-secondary">
                                        <i class="bi bi-envelope-fill"></i>
                                    </span>
                                    <input type="email" class="form-control border-start-0 ps-0 shadow-none" id="email" name="email" placeholder="trunhiu0305@gmail.com" required>
                                    <div class="invalid-feedback ms-3">Please enter your email.</div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="password" class="form-label text-secondary fw-semibold small">Password</label>
                                <div class="input-group custom-input-group">
                                    <span class="input-group-text bg-white border-end-0 text-secondary">
                                        <i class="bi bi-key-fill"></i>
                                    </span>
                                    <input type="password" class="form-control border-start-0 ps-0 shadow-none" id="password" name="password" placeholder="**********" required>
                                    <div class="invalid-feedback ms-3">Please enter your password.</div>
                                </div>
                            </div>
                            
                            <div class="mb-3">
                                <label for="role" class="form-label text-secondary fw-semibold small">Login as</label>
                                <div class="input-group custom-input-group">
                                    <span class="input-group-text bg-white border-end-0 text-secondary">
                                        <i class="bi bi-person-badge-fill"></i>
                                    </span>
                                    <select class="form-select border-start-0 ps-0 shadow-none text-secondary" id="role" name="role" required>
                                        <option value="patient">Patient</option>
                                        <option value="doctor">Doctor</option>
                                        <option value="admin">Admin</option>
                                    </select>
                                </div>
                            </div>
                            
                            <div class="d-flex justify-content-between align-items-center mb-4 pt-1">
                                <div class="form-check">
                                    <input class="form-check-input shadow-none checkbox-vinmec" type="checkbox" value="true" id="rememberMe" name="rememberMe">
                                    <label class="form-check-label text-secondary small" for="rememberMe">Remember me</label>
                                </div>
                                <a href="#" class="text-decoration-none text-secondary small link-hover-vinmec">Quên mật khẩu?</a>
                            </div>
                            
                            <button type="submit" class="btn btn-vinmec w-100 fw-bold py-2-5 text-white shadow-sm">Đăng nhập</button>
                        </form>
                        
                        <p class="text-center text-secondary mt-4 mb-0 small">
                            Chưa có tài khoản? <a href="register.jsp" class="text-decoration-none fw-bold text-dark link-hover-vinmec">Đăng ký</a>
                        </p>
                    </div>
                </div>
                
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        // Auto-select role based on email
        const emailInput = document.getElementById('email');
        const roleSelect = document.getElementById('role');
        const loginForm = document.getElementById('loginForm');

        const autoSelectRole = () => {
            const emailValue = emailInput.value.toLowerCase();
            if (emailValue.includes('admin')) {
                roleSelect.value = 'admin';
            } else if (emailValue.includes('doctor')) {
                roleSelect.value = 'doctor';
            } else if (emailValue.includes('patient')) {
                roleSelect.value = 'patient';
            }
        };

        emailInput.addEventListener('blur', autoSelectRole);
        loginForm.addEventListener('submit', autoSelectRole);
    </script>
    <script>
        (() => {
            'use strict'
            const forms = document.querySelectorAll('.needs-validation')
            Array.from(forms).forEach(form => {
                form.addEventListener('submit', event => {
                    if (!form.checkValidity()) {
                        event.preventDefault()
                        event.stopPropagation()
                    }
                    form.classList.add('was-validated')
                }, false)
            })
        })()
    </script>
</body>
</html>