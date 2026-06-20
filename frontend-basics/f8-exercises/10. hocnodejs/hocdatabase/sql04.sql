-- Câu 1: Lấy danh sách khóa học mà user có id = 1 đã mua
-- Yêu cầu: Trả về thông tin khóa học, tên và email của user
-- Câu 2: Sắp xếp kết quả theo giá giảm dần và id tăng dần
-- Câu 3: Thêm 1 cột 'discount' ở câu lệnh truy vấn, theo điều kiện sau: 
-- Giá >= 200.000 -> 10%, ngược lại 0
-- Câu 4: Thêm 1 cột 'sale_price': Tính giá phải thanh toán sau khi đã trừ discount
-- Câu 5: Trả về khóa học có giá lớn nhất
-- Câu 6: Trả về khóa học có giá lớn thứ hai
SELECT courses.*, users.name as username, users.email,
CASE
	WHEN courses.price >= 200000 THEN '10%'
	ELSE '0'
END AS discount,
(courses.price - courses.price * (CASE
	WHEN courses.price >= 200000 THEN 10
	ELSE 0
END)/100) AS sale_price
FROM users
INNER JOIN users_courses
ON users.id = users_courses.user_id
INNER JOIN courses
ON courses.id = users_courses.course_id
INNER JOIN phones
ON phones.user_id = users.id
WHERE users.id = 2
ORDER BY courses.price DESC, courses.id ASC
LIMIT 1 
OFFSET 1;

-- Chuyển số trang -> offset = (page - 1) * limit
