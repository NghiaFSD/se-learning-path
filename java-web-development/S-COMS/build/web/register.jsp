<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Register - Diabetes Monitoring</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css" />
</head>
<body class="bg-light d-flex align-items-center justify-content-center" style="min-height: 100vh; background: linear-gradient(135deg, #f4fbf9 0%, #e8f7f4 100%);">

    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-xl-9 col-lg-10">
                
                <div class="card border-0 shadow-lg overflow-hidden" style="border-radius: 20px;">
                    <div class="row g-0">
                        
                        <div class="col-md-4 p-4 text-white d-flex flex-column justify-content-center text-center text-md-start" style="background-color: #2dbbbc;">
                            <div class="mb-3">
                                <i class="bi bi-heart-pulse-fill" style="font-size: 3rem;"></i>
                            </div>
                            <h3 class="fw-bold mb-3">Create account</h3>
                            <p class="small opacity-90 mb-0">Join the diabetes monitoring system with secure patient records and AI-assisted health support.</p>
                        </div>
                        
                        <div class="col-md-8 p-4 p-md-5 bg-white">
                            <c:if test="${not empty registerError}">
                                <div class="alert alert-danger" role="alert">
                                    ${registerError}
                                </div>
                            </c:if>
                            <form action="register" method="post" class="needs-validation" novalidate>
                                <div class="row g-3">
                                    
                                    <div class="col-md-6">
                                        <label class="form-label text-secondary fw-semibold small" for="fullName">Full name</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-person-fill"></i></span>
                                            <input type="text" class="form-control border-start-0 ps-0 shadow-none" id="fullName" name="fullName" placeholder="Nguyen Van A" required>
                                            <div class="invalid-feedback ms-3">Enter your full name.</div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label class="form-label text-secondary fw-semibold small" for="email">Email</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-envelope-fill"></i></span>
                                            <input type="email" class="form-control border-start-0 ps-0 shadow-none" id="email" name="email" placeholder="example@gmail.com" required>
                                            <div class="invalid-feedback ms-3">Enter a valid email.</div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label class="form-label text-secondary fw-semibold small" for="password">Password</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-key-fill"></i></span>
                                            <input type="password" class="form-control border-start-0 ps-0 shadow-none" id="password" name="password" placeholder="Min 8 characters" required minlength="8">
                                            <div class="invalid-feedback ms-3">Password must be at least 8 characters.</div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label class="form-label text-secondary fw-semibold small" for="confirmPassword">Confirm password</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-shield-lock-fill"></i></span>
                                            <input type="password" class="form-control border-start-0 ps-0 shadow-none" id="confirmPassword" name="confirmPassword" placeholder="Repeat password" required>
                                            <div class="invalid-feedback ms-3" id="confirmFeedback">Confirm your password.</div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label class="form-label text-secondary fw-semibold small" for="gender">Gender</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-gender-ambiguous"></i></span>
                                            <select class="form-select border-start-0 ps-0 shadow-none text-secondary" id="gender" name="gender" required>
                                                <option selected disabled value="">Choose...</option>
                                                <option value="male">Male</option>
                                                <option value="female">Female</option>
                                                <option value="other">Other</option>
                                            </select>
                                            <div class="invalid-feedback ms-3">Select a gender.</div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <label class="form-label text-secondary fw-semibold small" for="dob">Date of birth</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-calendar-event-fill"></i></span>
                                            <input type="date" class="form-control border-start-0 ps-0 shadow-none text-secondary" id="dob" name="dob" required>
                                            <div class="invalid-feedback ms-3">Enter your date of birth.</div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-12">
                                        <label class="form-label text-secondary fw-semibold small" for="phone">Phone number</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-telephone-fill"></i></span>
                                            <input type="tel" class="form-control border-start-0 ps-0 shadow-none" id="phone" name="phone" placeholder="0912345678" required>
                                            <div class="invalid-feedback ms-3">Enter a phone number.</div>
                                        </div>
                                    </div>
                                    
                                    <div class="col-md-12">
                                        <label class="form-label text-secondary fw-semibold small" for="address">Address</label>
                                        <div class="input-group custom-input-group">
                                            <span class="input-group-text bg-white border-end-0 text-secondary"><i class="bi bi-house-fill"></i></span>
                                            <input type="text" class="form-control border-start-0 ps-0 shadow-none" id="address" name="address" placeholder="123 Street, District, City">
                                        </div>
                                    </div>
                                </div>
                                
                                <div class="mt-4 d-flex flex-column flex-sm-row justify-content-between align-items-center gap-3">
                                    <button type="submit" class="btn btn-vinmec text-white fw-bold px-4 py-2-5 shadow-sm order-sm-2 w-100 w-sm-auto">Create account</button>
                                    <a href="login.jsp" class="text-decoration-none text-secondary small fw-medium order-sm-1 link-hover-vinmec">Already have an account?</a>
                                </div>
                            </form>
                        </div>
                        
                    </div>
                </div>
                
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        (() => {
            'use strict'
            const form = document.querySelector('.needs-validation')
            
            form.addEventListener('submit', event => {
                const password = document.getElementById('password');
                const confirmPassword = document.getElementById('confirmPassword');
                const feedback = document.getElementById('confirmFeedback');

                // Kiểm tra mật khẩu khớp nhau trước khi submit
                if (password.value !== confirmPassword.value) {
                    confirmPassword.setCustomValidity('Passwords do not match');
                    feedback.textContent = 'Passwords do not match.';
                } else {
                    confirmPassword.setCustomValidity('');
                    feedback.textContent = 'Confirm your password.';
                }

                if (!form.checkValidity()) {
                    event.preventDefault()
                    event.stopPropagation()
                }
                form.classList.add('was-validated')
            }, false)
        })()
    </script>
</body>
</html>

