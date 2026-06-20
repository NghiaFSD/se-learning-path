<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Trang gio hang, cap nhat so luong va xoa san pham trong gio. --%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Giỏ hàng của bạn</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <style>
            .table img {
                width: 60px;
                height: 80px;
                object-fit: contain;
            }
            .cart-container {
                background: white;
                padding: 30px;
                border-radius: 10px;
                margin-top: 50px;
            }
        </style>
    </head>
    <body class="bg-light">
        <div class="container cart-container shadow-sm">
            <h2 class="text-center mb-4">GIỎ HÀNG CỦA BẠN</h2>
            <c:if test="${not empty sessionScope.stockMessage}">
                <div class="alert alert-warning" role="alert">${sessionScope.stockMessage}</div>
                <c:set var="stockMessage" value="" scope="session" />
            </c:if>
            <c:set var="cartInvalid" value="false" />
            <table class="table table-hover align-middle">
                <thead class="table-dark">
                    <tr>
                        <th>Sản phẩm</th><th>Hình ảnh</th><th>Giá</th><th>Số lượng</th><th>Tổng</th><th>Hành động</th>
                    </tr>
                </thead>
                <tbody>
                    <c:set var="totalPrice" value="0" />
                    <c:forEach items="${sessionScope.cart}" var="item">
                        <c:set var="book" value="${item.value.book}" />
                        <c:set var="quantity" value="${item.value.quantity}" />
                        <c:if test="${quantity > book.stock}">
                            <c:set var="cartInvalid" value="true" />
                        </c:if>
                        <tr>
                            <td class="fw-bold">${book.title}</td>
                            <td><img src="${book.image}" alt="${book.title}"></td>
                            <td><fmt:formatNumber value="${book.price}" pattern="#,##0" /> ₫</td>
                            <td>
                                <input type="number" value="${quantity}" min="1" max="${book.stock}" 
                                       class="form-control d-inline-block cart-qty" 
                                       style="width: 70px;"
                                       data-price="${book.price}" 
                                       data-stock="${book.stock}" 
                                       onchange="updateTotal(this, ${book.id})">
                                <small class="text-muted">Tồn: ${book.stock}</small>
                            </td>
                            <td class="text-danger fw-bold line-total"><fmt:formatNumber value="${book.price * quantity}" pattern="#,##0" /> ₫</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/remove-item?id=${book.id}" class="btn btn-outline-danger btn-sm" 
                                   onclick="return confirm('Bạn có chắc muốn xóa?')">Xóa</a>
                            </td>
                        </tr>
                        <c:set var="totalPrice" value="${totalPrice + (book.price * quantity)}" />
                    </c:forEach>
                <script>
                    function updateTotal(input, bookId) {
                        const quantity = input.value;
                        const price = input.getAttribute('data-price');

                        // 1. Cập nhật cột "Tổng" của dòng hiện tại
                        const totalCell = input.parentElement.nextElementSibling;
                        const computed = Number(price) * Number(quantity);
                        totalCell.innerHTML = new Intl.NumberFormat('vi-VN').format(computed) + ' ₫';

                        // 2. Tính lại "Tổng thanh toán" toàn bộ giỏ hàng
                        let finalTotal = 0;
                        document.querySelectorAll('.cart-qty').forEach(item => {
                            finalTotal += Number(item.value) * Number(item.getAttribute('data-price'));
                        });
                        document.querySelector('h4 .text-danger').innerHTML = new Intl.NumberFormat('vi-VN').format(finalTotal) + ' ₫';

                        // 3. Gửi cập nhật ngầm về UpdateCartServlet để lưu vào Session
                        fetch('update-cart?id=' + bookId + '&quantity=' + quantity)
                            .then(response => {
                                // Refresh lại để đồng bộ số lượng với server
                                window.location.reload();
                            });
                    }
                </script>
                </tbody>
            </table>

            <div class="row mt-4">
                <div class="col-md-6">
                    <a href="${pageContext.request.contextPath}/home" class="btn btn-secondary">Tiếp tục mua sắm</a>
                </div>
                <div class="col-md-6 text-end">
                    <h4>Tổng đơn hàng: <span class="text-danger"><fmt:formatNumber value="${totalPrice}" pattern="#,##0" /> ₫</span></h4>
                    <c:choose>
                        <c:when test="${cartInvalid}">
                            <button class="btn btn-secondary btn-lg mt-2 px-5" disabled>ĐẶT HÀNG (Kiểm tra tồn kho)</button>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/checkout" class="btn btn-success btn-lg mt-2 px-5">ĐẶT HÀNG</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </body>
</html>