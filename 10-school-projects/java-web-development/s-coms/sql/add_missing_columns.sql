-- Thêm các cột còn thiếu vào bảng Healthy_Record
-- Chạy script này trong SQL Server Management Studio

USE project_SWP;
GO

-- Kiểm tra và thêm cột ldl nếu chưa có
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Healthy_Record' AND COLUMN_NAME = 'ldl')
BEGIN
    ALTER TABLE Healthy_Record
    ADD ldl FLOAT NULL;
    PRINT 'Added column: ldl';
END
ELSE
BEGIN
    PRINT 'Column ldl already exists';
END
GO

-- Kiểm tra và thêm cột vldl nếu chưa có
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Healthy_Record' AND COLUMN_NAME = 'vldl')
BEGIN
    ALTER TABLE Healthy_Record
    ADD vldl FLOAT NULL;
    PRINT 'Added column: vldl';
END
ELSE
BEGIN
    PRINT 'Column vldl already exists';
END
GO

-- Kiểm tra và thêm cột hdl nếu chưa có
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS 
               WHERE TABLE_NAME = 'Healthy_Record' AND COLUMN_NAME = 'hdl')
BEGIN
    ALTER TABLE Healthy_Record
    ADD hdl FLOAT NULL;
    PRINT 'Added column: hdl';
END
ELSE
BEGIN
    PRINT 'Column hdl already exists';
END
GO

-- Kiểm tra cấu trúc bảng sau khi cập nhật
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Healthy_Record'
ORDER BY ORDINAL_POSITION;
GO
