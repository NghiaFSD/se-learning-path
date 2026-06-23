SET NOCOUNT ON;
GO

USE [Project];
GO

BEGIN TRY
    BEGIN TRAN;

    DECLARE @doctorAccountId INT;
    DECLARE @patientAccountId INT;
    DECLARE @doctorId INT;
    DECLARE @patientId INT;
    DECLARE @receptionistAccountId INT;
    DECLARE @receptionistId INT;
    DECLARE @examServiceId INT;
    DECLARE @labServiceId INT;

    IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'seed.doctor.scoms@example.com')
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES (N'Seed Doctor S-COMS', 'seed-hash', 'seed.doctor.scoms@example.com', 'Doctor', GETDATE(), 'Active');
    END;
    SELECT @doctorAccountId = account_id
    FROM dbo.Account
    WHERE email = 'seed.doctor.scoms@example.com';

    IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'seed.patient.scoms@example.com')
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES (N'Seed Patient S-COMS', 'seed-hash', 'seed.patient.scoms@example.com', 'Patient', GETDATE(), 'Active');
    END;
    SELECT @patientAccountId = account_id
    FROM dbo.Account
    WHERE email = 'seed.patient.scoms@example.com';

    IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'seed.receptionist.scoms@example.com')
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES (N'Seed Receptionist S-COMS', 'seed-hash', 'seed.receptionist.scoms@example.com', 'Receptionist', GETDATE(), 'Active');
    END;
    SELECT @receptionistAccountId = account_id
    FROM dbo.Account
    WHERE email = 'seed.receptionist.scoms@example.com';

    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor WHERE account_id = @doctorAccountId)
    BEGIN
        INSERT INTO dbo.Doctor (full_name, phone, email, department, account_id)
        VALUES (N'BS. Nguyễn Minh Khoa', '0909000001', 'seed.doctor.scoms@example.com', N'Nội tiết - Tiểu đường', @doctorAccountId);
    END;
    SELECT @doctorId = doctor_id
    FROM dbo.Doctor
    WHERE account_id = @doctorAccountId;

    IF NOT EXISTS (SELECT 1 FROM dbo.Patient WHERE account_id = @patientAccountId)
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES (N'Nguyen Van A', '1990-05-12', N'Nam', '0909000002', 'seed.patient.scoms@example.com', N'Ho Chi Minh City', @patientAccountId);
    END;
    SELECT @patientId = patient_id
    FROM dbo.Patient
    WHERE account_id = @patientAccountId;

    SELECT TOP 1 @receptionistId = a.account_id
    FROM dbo.Account a
    WHERE a.role = 'Receptionist'
    ORDER BY a.account_id;

    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'Khám nội tiết')
    BEGIN
        INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
        VALUES (N'Khám nội tiết', 650000, 'Examination', 'Active');
    END;
    SELECT @examServiceId = service_id
    FROM dbo.Medical_Service
    WHERE service_name = N'Khám nội tiết';

    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'Xét nghiệm HbA1c')
    BEGIN
        INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
        VALUES (N'Xét nghiệm HbA1c', 1150000, 'Lab_Test', 'Active');
    END;
    SELECT @labServiceId = service_id
    FROM dbo.Medical_Service
    WHERE service_name = N'Xét nghiệm HbA1c';

    DECLARE @scheduleId1 INT;
    DECLARE @scheduleId2 INT;
    DECLARE @scheduleId3 INT;
    DECLARE @scheduleId4 INT;
    DECLARE @scheduleId5 INT;
    DECLARE @scheduleId6 INT;

    DECLARE @appointmentId1 INT;
    DECLARE @appointmentId2 INT;
    DECLARE @appointmentId3 INT;
    DECLARE @appointmentId4 INT;
    DECLARE @appointmentId5 INT;
    DECLARE @appointmentId6 INT;

    DECLARE @invoiceId1 INT;
    DECLARE @invoiceId2 INT;
    DECLARE @invoiceId3 INT;
    DECLARE @invoiceId4 INT;
    DECLARE @invoiceId5 INT;
    DECLARE @invoiceId6 INT;

    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-02-10' AND time_slot = '08:00-08:30')
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-02-10', '08:00-08:30', 6, 'Available');
    END;
    SELECT @scheduleId1 = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-02-10' AND time_slot = '08:00-08:30';

    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-03-12' AND time_slot = '09:00-09:30')
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-03-12', '09:00-09:30', 6, 'Available');
    END;
    SELECT @scheduleId2 = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-03-12' AND time_slot = '09:00-09:30';

    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-04-14' AND time_slot = '10:00-10:30')
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-04-14', '10:00-10:30', 6, 'Available');
    END;
    SELECT @scheduleId3 = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-04-14' AND time_slot = '10:00-10:30';

    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-05-16' AND time_slot = '11:00-11:30')
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-05-16', '11:00-11:30', 6, 'Available');
    END;
    SELECT @scheduleId4 = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-05-16' AND time_slot = '11:00-11:30';

    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-06-18' AND time_slot = '08:30-09:00')
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-06-18', '08:30-09:00', 6, 'Available');
    END;
    SELECT @scheduleId5 = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-06-18' AND time_slot = '08:30-09:00';

    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-07-20' AND time_slot = '13:00-13:30')
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-07-20', '13:00-13:30', 6, 'Available');
    END;
    SELECT @scheduleId6 = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-07-20' AND time_slot = '13:00-13:30';

    IF NOT EXISTS (SELECT 1 FROM dbo.Appointment WHERE schedule_id = @scheduleId1 AND queue_number = 1 AND patient_id = @patientId)
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId1, NULL, '2026-02-10T08:05:00', 'Online', 1, 'Completed', '2026-02-10T08:05:00');
    END;
    SELECT TOP 1 @appointmentId1 = appointment_id FROM dbo.Appointment WHERE schedule_id = @scheduleId1 AND queue_number = 1 AND patient_id = @patientId ORDER BY appointment_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Appointment WHERE schedule_id = @scheduleId2 AND queue_number = 1 AND patient_id = @patientId)
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId2, NULL, '2026-03-12T09:10:00', 'Online', 1, 'Completed', '2026-03-12T09:10:00');
    END;
    SELECT TOP 1 @appointmentId2 = appointment_id FROM dbo.Appointment WHERE schedule_id = @scheduleId2 AND queue_number = 1 AND patient_id = @patientId ORDER BY appointment_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Appointment WHERE schedule_id = @scheduleId3 AND queue_number = 1 AND patient_id = @patientId)
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId3, NULL, '2026-04-14T10:15:00', 'Online', 1, 'Completed', '2026-04-14T10:15:00');
    END;
    SELECT TOP 1 @appointmentId3 = appointment_id FROM dbo.Appointment WHERE schedule_id = @scheduleId3 AND queue_number = 1 AND patient_id = @patientId ORDER BY appointment_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Appointment WHERE schedule_id = @scheduleId4 AND queue_number = 1 AND patient_id = @patientId)
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId4, NULL, '2026-05-16T11:20:00', 'Online', 1, 'Completed', '2026-05-16T11:20:00');
    END;
    SELECT TOP 1 @appointmentId4 = appointment_id FROM dbo.Appointment WHERE schedule_id = @scheduleId4 AND queue_number = 1 AND patient_id = @patientId ORDER BY appointment_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Appointment WHERE schedule_id = @scheduleId5 AND queue_number = 1 AND patient_id = @patientId)
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId5, NULL, '2026-06-18T08:35:00', 'Online', 1, 'Completed', '2026-06-18T08:35:00');
    END;
    SELECT TOP 1 @appointmentId5 = appointment_id FROM dbo.Appointment WHERE schedule_id = @scheduleId5 AND queue_number = 1 AND patient_id = @patientId ORDER BY appointment_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Appointment WHERE schedule_id = @scheduleId6 AND queue_number = 1 AND patient_id = @patientId)
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId6, NULL, '2026-07-20T13:05:00', 'Online', 1, 'Completed', '2026-07-20T13:05:00');
    END;
    SELECT TOP 1 @appointmentId6 = appointment_id FROM dbo.Appointment WHERE schedule_id = @scheduleId6 AND queue_number = 1 AND patient_id = @patientId ORDER BY appointment_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-02-10T09:00:00' AND final_amount = 650000)
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, @receptionistId, 650000, 0, 650000, 'Cash', 'Paid', '2026-02-10T09:00:00', '2026-02-10T09:05:00');
    END;
    SELECT TOP 1 @invoiceId1 = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-02-10T09:00:00' AND final_amount = 650000 ORDER BY invoice_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-03-12T09:40:00' AND final_amount = 1150000)
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, @receptionistId, 1150000, 0, 1150000, 'VNPay', 'Paid', '2026-03-12T09:40:00', '2026-03-12T09:45:00');
    END;
    SELECT TOP 1 @invoiceId2 = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-03-12T09:40:00' AND final_amount = 1150000 ORDER BY invoice_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-04-14T10:40:00' AND final_amount = 1300000)
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, @receptionistId, 1300000, 0, 1300000, 'Momo', 'Paid', '2026-04-14T10:40:00', '2026-04-14T10:45:00');
    END;
    SELECT TOP 1 @invoiceId3 = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-04-14T10:40:00' AND final_amount = 1300000 ORDER BY invoice_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-05-16T11:45:00' AND final_amount = 1800000)
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, @receptionistId, 1800000, 0, 1800000, 'Cash', 'Paid', '2026-05-16T11:45:00', '2026-05-16T11:50:00');
    END;
    SELECT TOP 1 @invoiceId4 = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-05-16T11:45:00' AND final_amount = 1800000 ORDER BY invoice_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-06-18T09:00:00' AND final_amount = 9660000)
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, @receptionistId, 9660000, 0, 9660000, 'Bank_Transfer', 'Paid', '2026-06-18T09:00:00', '2026-06-18T09:05:00');
    END;
    SELECT TOP 1 @invoiceId5 = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-06-18T09:00:00' AND final_amount = 9660000 ORDER BY invoice_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-07-20T13:30:00' AND final_amount = 1300000)
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, @receptionistId, 1300000, 0, 1300000, 'Cash', 'Paid', '2026-07-20T13:30:00', '2026-07-20T13:35:00');
    END;
    SELECT TOP 1 @invoiceId6 = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-07-20T13:30:00' AND final_amount = 1300000 ORDER BY invoice_id DESC;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId1 AND appointment_id = @appointmentId1)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId1, @examServiceId, @appointmentId1, 1, 650000);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId2 AND appointment_id = @appointmentId2)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId2, @labServiceId, @appointmentId2, 1, 1150000);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId3 AND appointment_id = @appointmentId3)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId3, @examServiceId, @appointmentId3, 1, 1300000);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId4 AND appointment_id = @appointmentId4)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId4, @labServiceId, @appointmentId4, 1, 1800000);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId5 AND appointment_id = @appointmentId5)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId5, @examServiceId, @appointmentId5, 1, 9660000);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId6 AND appointment_id = @appointmentId6)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId6, @labServiceId, @appointmentId6, 1, 1300000);
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_record WHERE appointment_id = @appointmentId1)
    BEGIN
        INSERT INTO dbo.Medical_record (patient_id, doctor_id, final_diagnosis, doctor_note, health_record_id, result_visibility, processed_at, appointment_id)
        VALUES (@patientId, @doctorId, N'Khám nội tiết ổn định', N'Ghi chú mẫu cho lượt khám hoàn thành', NULL, 1, GETDATE(), @appointmentId1);
    END;

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;
END CATCH;
GO
