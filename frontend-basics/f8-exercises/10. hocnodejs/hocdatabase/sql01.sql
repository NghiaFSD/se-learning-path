-- Đây là comment trong SQL

--1. Thêm dữ liệu
-- INSERT INTO users(id, name, email, password, status, created_at, updated_at)
-- VALUES(1, 'User 1', 'user1@gmail.com', '123456', true, NOW(), NOW());

-- INSERT INTO users(id, name, email, password, status, created_at, updated_at)
-- VALUES(2, 'User 2', 'user2@gmail.com', '123456', false, NOW(), NOW());

-- INSERT INTO users(id, name, email, password, status, created_at, updated_at)
-- VALUES(3, 'User 3', 'user3@gmail.com', '123456', false, NOW(), NOW());

-- INSERT INTO users(id, name, email, password, status, created_at, updated_at)
-- VALUES(4, 'User 4', 'user4@gmail.com', '123456', true, NOW(), NOW());

--2. Cập nhật dữ liệu
-- UPDATE users SET name='User11', email='user11@gmail.com', status=false, updated_at=NOW()
-- WHERE id=1;

--3. Xóa dữ liệu
-- DELETE FROM users WHERE id=1;

-- 4. Hiển thị dữ liệu
-- UPDATE users SET updated_at=NULL WHERE id=1;
-- UPDATE users SET updated_at=NULL WHERE id=3;
SELECT * FROM users WHERE updated_at IS NOT NULL;






