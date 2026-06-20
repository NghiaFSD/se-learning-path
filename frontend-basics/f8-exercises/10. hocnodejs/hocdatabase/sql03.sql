-- SELECT users.*, groups.name AS group_name 
-- FROM users
-- INNER JOIN groups
-- ON users.group_id = groups.id;

-- Câu 1: Viết câu lệnh truy vấn lấy ra danh sách users và tên group theo điều kiện sau:
-- Tên group có chứa từ khóa "admin"

SELECT users.*, groups.name AS group_name 
FROM users
INNER JOIN groups
ON users.group_id = groups.id
WHERE LOWER(groups.name) LIKE '%admin%';

