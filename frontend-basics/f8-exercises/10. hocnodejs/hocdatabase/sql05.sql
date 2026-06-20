-- HÀM TỔNG HỢP: COUNT(), SUM(), AVG(), MAX(), MIN() --> Đi kèm với mệnh đề GROUP BY, HAVING
SELECT status, count(id) 
FROM users
GROUP BY status
HAVING count(id) >= 2;

-- Câu 1: Truy vấn trả về danh sách users và số bài posts của từng users
-- Câu 2: Trả về thông tin users có tổng số bài posts >= 2
-- Câu 3: Trả về thông tin users có số bài posts lớn nhất (Không được dùng LIMIT, OFFSET)
SELECT users.*, count(posts.id)
FROM users
LEFT JOIN posts ON posts.user_id = users.id
GROUP BY users.id
HAVING count(posts.id) = (
	SELECT MAX(post_count)
	FROM (
		--Bảng tạm
		SELECT COUNT(id) as post_count
		FROM posts
		GROUP BY user_id
	)
)
fetch first 1 rows only;
-- ORDER BY count(posts.id) DESC
-- LIMIT 1;
-- SELECT *, (SELECT count(id) FROM posts WHERE users.id = posts.user_id) AS post_count
-- FROM users;