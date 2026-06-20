<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang chu hien thi danh sach sach, bo loc danh muc va tim kiem. --%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>FPT - Book Store</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            :root {
                --primary-color: #ff6b6b;
                --dark-color: #333;
            }
            body {
                background-color: #f8f9fa;
                font-family: 'Segoe UI', sans-serif;
            }
            .sidebar {
                background: white;
                padding: 25px;
                border-radius: 12px;
                box-shadow: 0 4px 15px rgba(0,0,0,0.05);
            }
            .sidebar h5 {
                font-size: 14px;
                font-weight: 700;
                color: var(--dark-color);
                border-bottom: 2px solid var(--primary-color);
                display: inline-block;
                margin-bottom: 20px;
            }
            .category-link {
                color: #666;
                text-decoration: none;
                transition: 0.3s;
                display: block;
                padding: 5px 0;
            }
            .category-link:hover {
                color: var(--primary-color);
                padding-left: 5px;
            }
            .book-card {
                border: none;
                border-radius: 15px;
                transition: 0.4s;
                overflow: hidden;
                background: white;
                padding: 15px;
            }
            .book-card:hover {
                transform: translateY(-10px);
                box-shadow: 0 15px 30px rgba(0,0,0,0.1);
            }
            .book-img {
                height: 220px;
                object-fit: contain;
                width: 100%;
                transition: 0.3s;
            }
            .book-title {
                font-weight: 600;
                font-size: 15px;
                color: var(--dark-color);
                height: 45px;
                overflow: hidden;
                margin-top: 15px;
            }
            .book-price {
                color: var(--primary-color);
                font-weight: 700;
                font-size: 18px;
                margin: 10px 0;
            }
            .btn-add {
                background: var(--dark-color);
                color: white;
                border-radius: 25px;
                font-size: 13px;
                font-weight: 600;
                border: none;
                padding: 8px 20px;
                transition: 0.3s;
            }
            .btn-add:hover {
                background: var(--primary-color);
                color: white;
                box-shadow: 0 4px 12px rgba(255, 107, 107, 0.3);
            }
        </style>
    </head>
    <body>

        <nav class="navbar navbar-expand-lg navbar-dark bg-dark sticky-top">
            <div class="container">
                <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/home">FPT BOOK</a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <!-- Desktop search (hidden on sm) -->
                    <form class="d-none d-md-flex ms-lg-4 mt-2 mt-lg-0 align-items-center" action="${pageContext.request.contextPath}/home" method="get">
                        <input class="form-control me-2 rounded-pill px-3" type="search" name="txtSearch" placeholder="Tìm tên sách..." value="${param.txtSearch}">
                        <div class="d-flex align-items-center me-2">
                            <div class="input-group input-group-sm me-1" style="min-width:110px;">
                                <span class="input-group-text">₫</span>
                                <input class="form-control price-input" type="text" id="priceMinDisplay" placeholder="Giá từ" value="${param.priceMin}" aria-label="Giá từ">
                                <input type="hidden" name="priceMin" id="priceMin" value="${param.priceMin}" />
                            </div>
                            <div class="input-group input-group-sm" style="min-width:110px;">
                                <span class="input-group-text">₫</span>
                                <input class="form-control price-input" type="text" id="priceMaxDisplay" placeholder="Giá đến" value="${param.priceMax}" aria-label="Giá đến">
                                <input type="hidden" name="priceMax" id="priceMax" value="${param.priceMax}" />
                            </div>
                        </div>
                        <div class="d-flex align-items-center">
                            <button class="btn btn-outline-light rounded-pill" type="submit">Tìm</button>
                        </div>
                    </form>

                    <!-- Mobile compact search (visible on sm) -->
                    <form class="d-flex d-md-none w-100 align-items-center gap-2" action="${pageContext.request.contextPath}/home" method="get">
                        <button class="btn btn-outline-light btn-sm" type="button" data-bs-toggle="collapse" data-bs-target="#categoryCollapse" aria-expanded="false" aria-controls="categoryCollapse" title="Danh mục">
                            <i class="bi bi-list" style="font-size:1.2rem"></i>
                        </button>
                        <input class="form-control rounded-pill px-3" type="search" name="txtSearch" placeholder="Tìm tên sách..." value="${param.txtSearch}" style="flex:1">

                        <a class="btn btn-outline-light btn-sm position-relative me-1" href="${pageContext.request.contextPath}/cart">
                            <i class="bi bi-cart"></i>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                ${sessionScope.cart != null ? sessionScope.cart.size() : 0}
                            </span>
                        </a>

                        <div class="dropdown">
                            <button class="btn btn-outline-light btn-sm dropdown-toggle" type="button" id="mobileUserMenu" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="bi bi-person"></i>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="mobileUserMenu">
                                <c:choose>
                                    <c:when test="${sessionScope.user == null}">
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/login">Đăng nhập</a></li>
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/register">Đăng ký</a></li>
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/chatbot">AI tư vấn sách</a></li>
                                    </c:when>
                                    <c:otherwise>
                                        <li><h6 class="dropdown-header">Chào, ${sessionScope.user.displayName}</h6></li>
                                        <c:if test="${sessionScope.user.role == 1}">
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard">Trang Admin</a></li>
                                        </c:if>
                                        <c:if test="${sessionScope.user.role != 1}">
                                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/history">Lịch sử mua hàng</a></li>
                                        </c:if>
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/chatbot">AI tư vấn sách</a></li>
                                        <li><hr class="dropdown-divider"></li>
                                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                                    </c:otherwise>
                                </c:choose>
                            </ul>
                        </div>
                    </form>
                    <c:if test="${not empty priceError}">
                        <div class="alert alert-danger mt-2 mb-0 py-2 px-3" role="alert" style="font-size: 0.9rem;">
                            ${priceError}
                        </div>
                    </c:if>

                    <ul class="navbar-nav ms-auto align-items-center">
                        <c:choose>
                            <c:when test="${sessionScope.user == null}">
                                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/login">Đăng nhập</a></li>
                                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/register">Đăng ký</a></li>
                                </c:when>
                                <c:otherwise>
                                <li class="nav-item">
                                    <span class="nav-link text-warning">Chào, <strong>${sessionScope.user.displayName}</strong></span>
                                </li>
                                <c:if test="${sessionScope.user.role == 1}">
                                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard">Trang Admin</a></li>
                                    </c:if>
                                    <c:if test="${sessionScope.user.role != 1}">
                                    <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/history">Lịch sử mua hàng</a></li>
                                    </c:if>
                                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/logout">Đăng xuất</a></li>
                                </c:otherwise>
                            </c:choose>

                        <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/chatbot">AI tư vấn sách</a></li>

                        <li class="nav-item ms-lg-3">
                            <a href="${pageContext.request.contextPath}/cart" class="btn btn-outline-light position-relative btn-sm px-3 rounded-pill">
                                Giỏ hàng
                                <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">
                                    ${sessionScope.cart != null ? sessionScope.cart.size() : 0}
                                </span>
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>

        <div class="container mt-5">
            <c:if test="${not empty sessionScope.stockMessage}">
                <div class="alert alert-warning" role="alert">
                    ${sessionScope.stockMessage}
                </div>
                <c:set var="stockMessage" value="" scope="session" />
            </c:if>
            <div class="row">
                <c:set var="extraParams" value="" />
                <c:if test="${not empty param.txtSearch}">
                    <c:set var="extraParams" value="${extraParams}&amp;txtSearch=${param.txtSearch}" />
                </c:if>
                <c:if test="${not empty param.priceMin}">
                    <c:set var="extraParams" value="${extraParams}&amp;priceMin=${param.priceMin}" />
                </c:if>
                <c:if test="${not empty param.priceMax}">
                    <c:set var="extraParams" value="${extraParams}&amp;priceMax=${param.priceMax}" />
                </c:if>

                <div class="col-md-3 mb-4">
                    <div class="sidebar">
                        <div class="d-flex align-items-center">
                            <button class="btn btn-outline-secondary btn-sm" type="button" data-bs-toggle="collapse" data-bs-target="#categoryCollapse" aria-expanded="false" aria-controls="categoryCollapse" title="Danh mục">
                                &#9776;
                            </button>
                            <h5 class="mb-0 ms-2 d-none d-md-block">SHOPPING OPTIONS</h5>
                        </div>
                        <div class="collapse mt-3" id="categoryCollapse">
                            <p class="small fw-bold text-muted mt-0 mb-2">Sản Phẩm</p>
                            <div class="category-list">
                                <a href="${pageContext.request.contextPath}/home?cid=0${extraParams}" class="category-link ${param.cid == '0' || param.cid == null ? 'text-danger fw-bold' : ''}">Tất cả sản phẩm</a>
                                <c:forEach items="${categories}" var="c">
                                    <a href="${pageContext.request.contextPath}/home?cid=${c.id}${extraParams}" class="category-link ${param.cid == c.id ? 'text-danger fw-bold' : ''}">
                                        ${c.name}
                                    </a>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-md-9">
                    <div class="d-flex justify-content-between align-items-center mb-4 bg-white p-3 rounded shadow-sm">
                        <h5 class="m-0 text-uppercase fw-bold">Danh sách sách</h5>
                        <div class="text-muted small">Hiển thị ${data.size()} kết quả</div>
                    </div>

                    <div class="row">
                        <c:forEach items="${data}" var="b">
                            <div class="col-md-4 mb-4">
                                <div class="book-card shadow-sm text-center">
                                    <a href="${pageContext.request.contextPath}/detail?id=${b.id}">
                                        <img src="${b.image}" class="book-img" alt="${b.title}">
                                    </a>
                                    <div class="book-title">${b.title}</div>
                                    <div class="text-muted small mb-2" style="height: 25px; overflow: hidden;">
                                        ${b.author != null && !b.author.isEmpty() ? 'Tác giả: ' : ''}<strong>${b.author}</strong>
                                    </div>
                                    <div class="book-price"><fmt:formatNumber value="${b.price}" pattern="#,##0" /> ₫</div>
                                    <div class="mb-2">
                                        <small class="text-secondary">Trên kệ: <strong>${b.stock}</strong></small>
                                    </div>
                                    <c:choose>
                                        <c:when test="${b.stock gt 0}">
                                            <a href="${pageContext.request.contextPath}/add-to-cart?id=${b.id}" class="btn btn-add">Add To Cart</a>
                                        </c:when>
                                        <c:otherwise>
                                            <button class="btn btn-danger" disabled>Hết hàng</button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>

                        <c:if test="${data.size() == 0}">
                            <div class="col-12 text-center mt-5">
                                <img src="https://cdn-icons-png.flaticon.com/512/7486/7486744.png" width="100" class="mb-3 opacity-50">
                                <p class="text-muted">Không tìm thấy cuốn sách nào.</p>
                            </div>
                        </c:if>
                    </div>
                </div>
            </div>
        </div>

        <footer class="bg-dark text-white py-4 mt-5">
            <div class="container text-center">
                <small>&copy; 2026 FPT Book Store - PRJ301 FPT University</small>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            (function(){
                const nf = new Intl.NumberFormat('vi-VN');
                function digitsOnly(s){ return s ? s.replace(/[^0-9]/g, '') : '' }
                function formatInput(display, hidden){
                    const raw = digitsOnly(display.value);
                    hidden.value = raw;
                    display.value = raw ? nf.format(raw) : '';
                }
                function attach(displayId, hiddenId){
                    const display = document.getElementById(displayId);
                    const hidden = document.getElementById(hiddenId);
                    if(!display || !hidden) return;
                    // initial format
                    if(hidden.value) display.value = nf.format(hidden.value);
                    display.addEventListener('input', function(e){
                        const cursorPos = this.selectionStart;
                        const raw = digitsOnly(this.value);
                        this.value = raw ? nf.format(raw) : '';
                        hidden.value = raw;
                        // move caret to end for simplicity
                        this.setSelectionRange(this.value.length, this.value.length);
                    });
                    // on form submit ensure hidden is correct
                    const form = display.form;
                    if(form) form.addEventListener('submit', function(){
                        hidden.value = digitsOnly(display.value);
                    });
                }
                attach('priceMinDisplay','priceMin');
                attach('priceMaxDisplay','priceMax');
            })();
        </script>
    </body>
</html>