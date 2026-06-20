<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%-- View: Form admin them moi/cap nhat thong tin san pham. --%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title><c:choose><c:when test="${not empty book}">Sửa sản phẩm</c:when><c:otherwise>Thêm sản phẩm</c:otherwise></c:choose></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
<div class="container mt-5">
    <div class="card p-4 shadow-sm">
        <h3 class="mb-4"><c:choose><c:when test="${not empty book}">Sửa sản phẩm</c:when><c:otherwise>Thêm sản phẩm</c:otherwise></c:choose></h3>
        <c:if test="${not empty formError}">
            <div class="alert alert-danger">${formError}</div>
        </c:if>
        <form method="post" action="${pageContext.request.contextPath}/admin/products">
            <input type="hidden" name="id" value="${book.id}" />
            <div class="mb-3">
                <label class="form-label">Tiêu đề</label>
                <input type="text" name="title" class="form-control" value="${book.title}" />
                <small class="text-danger">${titleError}</small>
            </div>
            <div class="mb-3">
                <label class="form-label">Giá (đồng)</label>
                <div class="input-group">
                    <input type="text" id="priceDisplay" class="form-control" placeholder="Nhập giá..." />
                    <span class="input-group-text">₫</span>
                    <input type="hidden" name="price" id="priceHidden" value="${book.price}" />
                </div>
                <small class="text-danger">${priceError}</small>
            </div>
            <div class="mb-3">
                <label class="form-label">Ảnh (URL)</label>
                <input type="text" name="image" class="form-control" value="${book.image}" />
                <small class="text-danger">${imageError}</small>
            </div>
            <div class="mb-3">
                <label class="form-label">Tác giả</label>
                <input type="text" name="author" class="form-control" maxlength="100" value="${book.author}" />
                <small class="text-danger">${authorError}</small>
            </div>
            <div class="mb-3">
                <label class="form-label">Tái bản (Edition)</label>
                <input type="text" name="edition" class="form-control" maxlength="50" value="${book.edition}" />
                <small class="text-danger">${editionError}</small>
            </div>
            <div class="mb-3">
                <label class="form-label">Danh mục</label>
                <select id="categorySelect" class="form-select" name="cid"
                        onchange="document.getElementById('newCategoryName').value=''">
                    <option value="">-- Chọn danh mục hiện có --</option>
                    <c:forEach items="${categories}" var="c">
                        <option value="${c.id}" ${c.id == book.cid ? 'selected' : ''}>${c.name}</option>
                    </c:forEach>
                </select>
                <div class="text-center text-muted small my-2">— hoặc tạo danh mục mới —</div>
                <input type="text" id="newCategoryName" name="newCategoryName"
                       class="form-control" placeholder="Nhập tên danh mục mới..."
                       value="${newCategoryName}"
                       oninput="if(this.value.trim()) document.getElementById('categorySelect').value=''">
                <small class="text-danger">${cidError}</small>
            </div>
            <div class="mb-3">
                <label class="form-label">Mô tả</label>
                <textarea name="description" class="form-control" rows="3">${book.description}</textarea>
                <small class="text-danger">${descriptionError}</small>
            </div>
            <div class="mb-3">
                <label class="form-label">Tồn kho</label>
                <input type="number" name="stock" class="form-control" value="${book.stock}" />
                <small class="text-danger">${stockError}</small>
            </div>
            <div class="d-flex justify-content-between">
                <a href="${pageContext.request.contextPath}/admin/products" class="btn btn-secondary">Hủy</a>
                <button type="submit" class="btn btn-primary">Lưu</button>
            </div>
        </form>
    </div>
</div>
<script>
    (function(){
        const nf = new Intl.NumberFormat('vi-VN');
        const displayInput = document.getElementById('priceDisplay');
        const hiddenInput = document.getElementById('priceHidden');

        // Helper: keep only digits (and optional decimal point if any)
        function digitsOnly(str) {
            return str ? str.replace(/[^0-9.]/g, '') : '';
        }

        // User typing: update hidden (raw digits) and format display
        displayInput.addEventListener('input', function() {
            const digits = this.value.replace(/[^0-9]/g, '');
            hiddenInput.value = digits;
            this.value = digits ? nf.format(Number(digits)) : '';
        });

        // Ensure hidden contains raw digits on submit
        displayInput.form.addEventListener('submit', function(e) {
            hiddenInput.value = (hiddenInput.value || '').toString().replace(/[^0-9]/g, '');
        });

        // Initialize display from hidden value (server-provided number)
        if (hiddenInput.value) {
            const parsed = hiddenInput.value.toString().replace(/[^0-9.]/g, '');
            const num = parsed ? Number(parsed) : NaN;
            if (!isNaN(num)) {
                displayInput.value = nf.format(num);
            }
        }
    })();
</script>
</body>
</html>