USE [project_SWP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO

BEGIN TRANSACTION;

DECLARE @today DATE = CAST(GETDATE() AS DATE);
DECLARE @base DATETIME = DATEADD(HOUR, 8, CAST(@today AS DATETIME));
DECLARE @password VARCHAR(255) = 'demo-password-hash';

/* ---------------------------------------------------------------------------
   S-COMS admin/dashboard demo data. Idempotent by DEMO_SCOMS_20260621 markers.
--------------------------------------------------------------------------- */

/* Services */
IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'DEMO_SCOMS_20260621 - Khám nội tiết')
    INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
    VALUES (N'DEMO_SCOMS_20260621 - Khám nội tiết', 180000, 'Examination', 'Active');

IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'DEMO_SCOMS_20260621 - Xét nghiệm HbA1c')
    INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
    VALUES (N'DEMO_SCOMS_20260621 - Xét nghiệm HbA1c', 120000, 'Lab_Test', 'Active');

IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'DEMO_SCOMS_20260621 - Xét nghiệm chức năng thận')
    INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
    VALUES (N'DEMO_SCOMS_20260621 - Xét nghiệm chức năng thận', 150000, 'Lab_Test', 'Active');

DECLARE @serviceExam INT = (SELECT TOP 1 service_id FROM dbo.Medical_Service WHERE service_name = N'DEMO_SCOMS_20260621 - Khám nội tiết');
DECLARE @serviceHbA1c INT = (SELECT TOP 1 service_id FROM dbo.Medical_Service WHERE service_name = N'DEMO_SCOMS_20260621 - Xét nghiệm HbA1c');
DECLARE @serviceKidney INT = (SELECT TOP 1 service_id FROM dbo.Medical_Service WHERE service_name = N'DEMO_SCOMS_20260621 - Xét nghiệm chức năng thận');

/* Doctors */
DECLARE @doctorSeed TABLE (rn INT IDENTITY(1,1), full_name NVARCHAR(100), email VARCHAR(100), phone VARCHAR(15), department NVARCHAR(100));
INSERT INTO @doctorSeed(full_name, email, phone, department)
VALUES
(N'DEMO SCOMS - BS Nội tiết', 'demo.scoms.doctor.endocrine@example.com', '0901000001', N'Nội tiết'),
(N'DEMO SCOMS - BS Tim mạch', 'demo.scoms.doctor.cardio@example.com', '0901000002', N'Tim mạch'),
(N'DEMO SCOMS - BS Thận tiết niệu', 'demo.scoms.doctor.kidney@example.com', '0901000003', N'Thận - Tiết niệu');

INSERT INTO dbo.Account(full_name, password_hash, email, role, status, created_at)
SELECT ds.full_name, @password, ds.email, 'Doctor', 'Active', DATEADD(DAY, -7, GETDATE())
FROM @doctorSeed ds
WHERE NOT EXISTS (SELECT 1 FROM dbo.Account a WHERE a.email = ds.email);

INSERT INTO dbo.Doctor(full_name, phone, email, department, account_id)
SELECT ds.full_name, ds.phone, ds.email, ds.department, a.account_id
FROM @doctorSeed ds
JOIN dbo.Account a ON a.email = ds.email
WHERE NOT EXISTS (SELECT 1 FROM dbo.Doctor d WHERE d.email = ds.email);

DECLARE @doctorEndo INT = (SELECT TOP 1 doctor_id FROM dbo.Doctor WHERE email = 'demo.scoms.doctor.endocrine@example.com');
DECLARE @doctorCardio INT = (SELECT TOP 1 doctor_id FROM dbo.Doctor WHERE email = 'demo.scoms.doctor.cardio@example.com');
DECLARE @doctorKidney INT = (SELECT TOP 1 doctor_id FROM dbo.Doctor WHERE email = 'demo.scoms.doctor.kidney@example.com');

/* Schedules today */
IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorEndo AND work_date = @today AND time_slot = '08:00-11:30')
    INSERT INTO dbo.Doctor_Schedule(doctor_id, work_date, time_slot, max_patients, status)
    VALUES (@doctorEndo, @today, '08:00-11:30', 12, 'Available');
IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorCardio AND work_date = @today AND time_slot = '13:00-16:30')
    INSERT INTO dbo.Doctor_Schedule(doctor_id, work_date, time_slot, max_patients, status)
    VALUES (@doctorCardio, @today, '13:00-16:30', 10, 'Available');
IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorKidney AND work_date = @today AND time_slot = '08:00-11:30')
    INSERT INTO dbo.Doctor_Schedule(doctor_id, work_date, time_slot, max_patients, status)
    VALUES (@doctorKidney, @today, '08:00-11:30', 8, 'Available');

DECLARE @scheduleEndo INT = (SELECT TOP 1 schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorEndo AND work_date = @today AND time_slot = '08:00-11:30');
DECLARE @scheduleCardio INT = (SELECT TOP 1 schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorCardio AND work_date = @today AND time_slot = '13:00-16:30');
DECLARE @scheduleKidney INT = (SELECT TOP 1 schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorKidney AND work_date = @today AND time_slot = '08:00-11:30');

/* Patients + appointments */
DECLARE @patientSeed TABLE (
    rn INT IDENTITY(1,1), full_name NVARCHAR(100), email VARCHAR(100), phone VARCHAR(15), gender NVARCHAR(10), dob DATE,
    doctor_id INT, schedule_id INT, status VARCHAR(20), minute_offset INT,
    hba1c DECIMAL(5,2), bmi DECIMAL(5,2), urea DECIMAL(5,2), cr DECIMAL(5,2), note NVARCHAR(500), add_lab BIT
);

INSERT INTO @patientSeed(full_name, email, phone, gender, dob, doctor_id, schedule_id, status, minute_offset, hba1c, bmi, urea, cr, note, add_lab)
VALUES
(N'DEMO SCOMS - Nguyễn Minh An', 'demo.scoms.patient01@example.com', '0912000001', N'Nam', '1985-02-12', @doctorEndo, @scheduleEndo, 'Waiting', 15, 8.20, 29.60, 5.90, 74.00, N'Đường huyết cao, cần ưu tiên khám nội tiết.', 1),
(N'DEMO SCOMS - Trần Thu Hà', 'demo.scoms.patient02@example.com', '0912000002', N'Nữ', '1990-09-20', @doctorEndo, @scheduleEndo, 'In_Progress', 35, 7.40, 26.30, 5.10, 68.00, N'HbA1c cao vừa, đang được bác sĩ theo dõi.', 1),
(N'DEMO SCOMS - Lê Quốc Bảo', 'demo.scoms.patient03@example.com', '0912000003', N'Nam', '1978-04-05', @doctorKidney, @scheduleKidney, 'Waiting', 55, 6.30, 24.10, 9.20, 118.00, N'Chỉ số thận cao, cần kiểm tra chức năng thận.', 1),
(N'DEMO SCOMS - Phạm Ngọc Mai', 'demo.scoms.patient04@example.com', '0912000004', N'Nữ', '1995-12-11', @doctorCardio, @scheduleCardio, 'Completed', 75, 5.60, 22.40, 4.80, 61.00, N'Ca khám hoàn tất, chỉ số ổn định.', 1),
(N'DEMO SCOMS - Hoàng Đức Long', 'demo.scoms.patient05@example.com', '0912000005', N'Nam', '1982-07-18', @doctorCardio, @scheduleCardio, 'Completed', 95, 6.90, 31.50, 6.10, 80.00, N'BMI cao, đã tư vấn điều chỉnh chế độ ăn.', 0),
(N'DEMO SCOMS - Vũ Hải Yến', 'demo.scoms.patient06@example.com', '0912000006', N'Nữ', '1988-03-03', @doctorEndo, @scheduleEndo, 'Waiting', 115, 9.10, 33.20, 7.30, 91.00, N'Nguy cơ tiểu đường cao, cần khám sớm.', 1),
(N'DEMO SCOMS - Đặng Anh Khoa', 'demo.scoms.patient07@example.com', '0912000007', N'Nam', '1975-10-29', @doctorKidney, @scheduleKidney, 'In_Progress', 135, 6.00, 25.80, 8.70, 106.00, N'Theo dõi creatinine tăng.', 1),
(N'DEMO SCOMS - Bùi Thanh Trúc', 'demo.scoms.patient08@example.com', '0912000008', N'Nữ', '2001-05-14', @doctorCardio, @scheduleCardio, 'Waiting', 155, 5.20, 21.70, 4.20, 55.00, N'Khám định kỳ, chưa có dấu hiệu bất thường.', 0);

INSERT INTO dbo.Account(full_name, password_hash, email, role, status, created_at)
SELECT ps.full_name, @password, ps.email, 'Patient', 'Active', DATEADD(DAY, -rn, GETDATE())
FROM @patientSeed ps
WHERE NOT EXISTS (SELECT 1 FROM dbo.Account a WHERE a.email = ps.email);

INSERT INTO dbo.Patient(full_name, date_of_birth, gender, phone, email, address, account_id)
SELECT ps.full_name, ps.dob, ps.gender, ps.phone, ps.email, N'DEMO SCOMS - địa chỉ test', a.account_id
FROM @patientSeed ps
JOIN dbo.Account a ON a.email = ps.email
WHERE NOT EXISTS (SELECT 1 FROM dbo.Patient p WHERE p.email = ps.email);

INSERT INTO dbo.Appointment(patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
SELECT p.patient_id, ps.doctor_id, ps.schedule_id, NULL, DATEADD(MINUTE, ps.minute_offset, @base), 'Online', ps.rn, ps.status, DATEADD(MINUTE, ps.minute_offset - 30, @base)
FROM @patientSeed ps
JOIN dbo.Patient p ON p.email = ps.email
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Appointment ap
    WHERE ap.patient_id = p.patient_id
      AND CAST(ap.appointment_time AS DATE) = @today
);

/* Healthy records */
INSERT INTO dbo.Healthy_Record(urea, cr, hba1c, chol, tg, hdl, ldl, idl, vldl, bmi, patient_id, weight, height, other_information, status, created_at, doctor_id, is_synced_automatically, synced_at)
SELECT ps.urea, ps.cr, ps.hba1c, 5.20, 1.80, 1.10, 2.90, NULL, 0.80, ps.bmi,
       p.patient_id, 70.00, 1.68, ps.note,
       CASE WHEN ps.status = 'Completed' THEN N'completed' ELSE N'processing' END,
       DATEADD(MINUTE, ps.minute_offset - 20, @base), ps.doctor_id, 1, GETDATE()
FROM @patientSeed ps
JOIN dbo.Patient p ON p.email = ps.email
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Healthy_Record hr
    WHERE hr.patient_id = p.patient_id
      AND CAST(hr.created_at AS DATE) = @today
      AND hr.other_information LIKE N'DEMO SCOMS%'
);

/* Invoices and invoice details for completed/paid demo cases */
DECLARE @paidAppointments TABLE(appointment_id INT, patient_id INT, created_at DATETIME, rn INT IDENTITY(1,1));
INSERT INTO @paidAppointments(appointment_id, patient_id, created_at)
SELECT ap.appointment_id, ap.patient_id, ap.appointment_time
FROM dbo.Appointment ap
JOIN dbo.Patient p ON p.patient_id = ap.patient_id
WHERE p.email LIKE 'demo.scoms.patient%'
  AND ap.status = 'Completed'
  AND CAST(ap.appointment_time AS DATE) = @today;

INSERT INTO dbo.Invoice(patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
SELECT pa.patient_id, NULL, 300000, 0, 300000,
       CASE WHEN pa.rn % 2 = 0 THEN 'Cash' ELSE 'VNPay' END,
       'Paid', DATEADD(MINUTE, 20, pa.created_at), DATEADD(MINUTE, 25, pa.created_at)
FROM @paidAppointments pa
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.Invoice i
    WHERE i.patient_id = pa.patient_id
      AND i.status = 'Paid'
      AND CAST(i.created_at AS DATE) = @today
);

INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, appointment_id, quantity, price, unit_price, line_total)
SELECT i.invoice_id, @serviceExam, pa.appointment_id, 1, 180000, 180000, 180000
FROM @paidAppointments pa
JOIN dbo.Invoice i ON i.patient_id = pa.patient_id AND CAST(i.created_at AS DATE) = @today
WHERE NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail id WHERE id.invoice_id = i.invoice_id AND id.service_id = @serviceExam);

INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, appointment_id, quantity, price, unit_price, line_total)
SELECT i.invoice_id, @serviceHbA1c, pa.appointment_id, 1, 120000, 120000, 120000
FROM @paidAppointments pa
JOIN dbo.Invoice i ON i.patient_id = pa.patient_id AND CAST(i.created_at AS DATE) = @today
WHERE NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail id WHERE id.invoice_id = i.invoice_id AND id.service_id = @serviceHbA1c);

/* Some suspicious health records for anti-fraud/dashboard review */
DECLARE @fraudPatient INT = (SELECT TOP 1 patient_id FROM dbo.Patient WHERE email = 'demo.scoms.patient01@example.com');
IF @fraudPatient IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Healthy_Record WHERE other_information LIKE N'DEMO_SCOMS_FRAUD_01%')
        INSERT INTO dbo.Healthy_Record(urea, cr, hba1c, chol, tg, hdl, ldl, idl, vldl, bmi, patient_id, weight, height, other_information, status, created_at, doctor_id, is_synced_automatically)
        VALUES (0, 0, 0, 0, 0, 0, 0, NULL, 0, 0, @fraudPatient, 0, 0, N'DEMO_SCOMS_FRAUD_01 spam hack malicious content test', N'pending', DATEADD(MINUTE, -10, GETDATE()), NULL, 1);

    IF NOT EXISTS (SELECT 1 FROM dbo.Healthy_Record WHERE other_information LIKE N'DEMO_SCOMS_FRAUD_02%')
        INSERT INTO dbo.Healthy_Record(urea, cr, hba1c, chol, tg, hdl, ldl, idl, vldl, bmi, patient_id, weight, height, other_information, status, created_at, doctor_id, is_synced_automatically)
        VALUES (15.5, 180, 12.4, 9.1, 6.5, 0.5, 5.8, NULL, 1.8, 39.5, @fraudPatient, 120, 1.55, N'DEMO_SCOMS_FRAUD_02 chỉ số bất thường cực cao để test cảnh báo', N'pending', DATEADD(MINUTE, -5, GETDATE()), NULL, 1);
END

COMMIT TRANSACTION;

SELECT 'DEMO_SEED_DONE' AS status,
       (SELECT COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) = @today) AS today_appointments,
       (SELECT COUNT(*) FROM dbo.Invoice WHERE CAST(created_at AS DATE) = @today AND status = 'Paid') AS today_paid_invoices,
       (SELECT COUNT(*) FROM dbo.Healthy_Record WHERE CAST(created_at AS DATE) = @today) AS today_health_records;
GO

