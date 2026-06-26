-- Thêm chức năng phân bổ hồ sơ cho Bác sĩ
-- Chạy script này trong SQL Server Management Studio

USE project_SWP;
GO

-- 1. Thêm cột doctor_id vào bảng Healthy_Record
ALTER TABLE Healthy_Record
ADD doctor_id INT NULL;
GO

-- 2. Thêm foreign key constraint
ALTER TABLE Healthy_Record
ADD CONSTRAINT FK_Healthy_Record_Doctor 
FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id);
GO

-- 3. Cập nhật status mặc định cho các record chưa có status
UPDATE Healthy_Record 
SET status = 'pending' 
WHERE status IS NULL;
GO

-- 4. Tạo index để truy vấn nhanh hơn
CREATE INDEX IX_Healthy_Record_Status ON Healthy_Record(status);
CREATE INDEX IX_Healthy_Record_DoctorId ON Healthy_Record(doctor_id);
GO

-- 5. Kiểm tra kết quả
SELECT 
    hr.health_record_id,
    hr.patient_id,
    p.full_name as patient_name,
    hr.doctor_id,
    d.full_name as doctor_name,
    hr.status,
    hr.created_at
FROM Healthy_Record hr
LEFT JOIN Patient p ON hr.patient_id = p.patient_id
LEFT JOIN Doctor d ON hr.doctor_id = d.doctor_id;
