-- Script: Điền giá trị mặc định cho trường edition nếu đang rỗng hoặc NULL
-- Chạy script này trên SQL Server (SSMS) để cập nhật các sách chưa có thông tin tái bản.

-- Gán "Lan 1" cho mọi sách chưa có giá trị edition
UPDATE Book
SET edition = 'Lan 1'
WHERE edition IS NULL OR LTRIM(RTRIM(edition)) = '';

-- Kiểm tra kết quả
SELECT id, title, author, edition
FROM Book
ORDER BY id;