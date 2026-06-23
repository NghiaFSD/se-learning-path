USE [Project];
SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @doctorAccountId INT;
    DECLARE @doctorId INT;
    DECLARE @examServiceId INT;
    DECLARE @labServiceId INT;

    SELECT @doctorAccountId = account_id
    FROM dbo.Account
    WHERE email = 'doctor.endo.seed@example.com';

    IF @doctorAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Doctor Endo Seed', 'seed_hash', 'doctor.endo.seed@example.com', 'Doctor', '2026-01-10T08:00:00', 'Active');
        SET @doctorAccountId = SCOPE_IDENTITY();
    END

    SELECT @doctorId = doctor_id
    FROM dbo.Doctor
    WHERE account_id = @doctorAccountId;

    IF @doctorId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor (full_name, phone, email, department, account_id)
        VALUES ('Doctor Endo Seed', '0900000000', 'doctor.endo.seed@example.com', N'Endocrinology', @doctorAccountId);
        SET @doctorId = SCOPE_IDENTITY();
    END

    SELECT @examServiceId = service_id
    FROM dbo.Medical_Service
    WHERE service_name = 'General Examination';

    IF @examServiceId IS NULL
    BEGIN
        INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
        VALUES ('General Examination', 650000, 'Examination', 'Active');
        SET @examServiceId = SCOPE_IDENTITY();
    END

    SELECT @labServiceId = service_id
    FROM dbo.Medical_Service
    WHERE service_name = 'HbA1c Test';

    IF @labServiceId IS NULL
    BEGIN
        INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
        VALUES ('HbA1c Test', 450000, 'Lab_Test', 'Active');
        SET @labServiceId = SCOPE_IDENTITY();
    END

    DECLARE @patientAccountId INT;
    DECLARE @patientId INT;
    DECLARE @scheduleId INT;
    DECLARE @appointmentId INT;
    DECLARE @invoiceId INT;

    -- February 2026
    SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'visit.patient1@example.com';
    IF @patientAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Visit Patient 1', 'seed_hash', 'visit.patient1@example.com', 'Patient', '2026-02-01T08:00:00', 'Active');
        SET @patientAccountId = SCOPE_IDENTITY();
    END
    SELECT @patientId = patient_id FROM dbo.Patient WHERE account_id = @patientAccountId;
    IF @patientId IS NULL
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES ('Visit Patient 1', '1990-01-11', N'Male', '0910000001', 'visit.patient1@example.com', N'Ho Chi Minh City', @patientAccountId);
        SET @patientId = SCOPE_IDENTITY();
    END
    SELECT @scheduleId = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-02-19' AND time_slot = '08:00-08:30';
    IF @scheduleId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-02-19', '08:00-08:30', 1, 'Full');
        SET @scheduleId = SCOPE_IDENTITY();
    END
    SELECT @appointmentId = appointment_id FROM dbo.Appointment WHERE patient_id = @patientId AND schedule_id = @scheduleId;
    IF @appointmentId IS NULL
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId, NULL, '2026-02-19T08:15:00', 'Online', 1, 'Completed', '2026-02-19T08:15:00');
        SET @appointmentId = SCOPE_IDENTITY();
    END
    SELECT @invoiceId = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-02-19T09:00:00' AND status = 'Paid';
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, NULL, 650000, 0, 650000, 'Cash', 'Paid', '2026-02-19T09:00:00', NULL);
        SET @invoiceId = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND appointment_id = @appointmentId AND service_id = @examServiceId)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId, @examServiceId, @appointmentId, 1, 650000);
    END

    -- March 2026
    SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'visit.patient2@example.com';
    IF @patientAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Visit Patient 2', 'seed_hash', 'visit.patient2@example.com', 'Patient', '2026-03-01T08:00:00', 'Active');
        SET @patientAccountId = SCOPE_IDENTITY();
    END
    SELECT @patientId = patient_id FROM dbo.Patient WHERE account_id = @patientAccountId;
    IF @patientId IS NULL
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES ('Visit Patient 2', '1988-02-12', N'Female', '0910000002', 'visit.patient2@example.com', N'Ho Chi Minh City', @patientAccountId);
        SET @patientId = SCOPE_IDENTITY();
    END
    SELECT @scheduleId = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-03-19' AND time_slot = '08:30-09:00';
    IF @scheduleId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-03-19', '08:30-09:00', 1, 'Full');
        SET @scheduleId = SCOPE_IDENTITY();
    END
    SELECT @appointmentId = appointment_id FROM dbo.Appointment WHERE patient_id = @patientId AND schedule_id = @scheduleId;
    IF @appointmentId IS NULL
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId, NULL, '2026-03-19T08:45:00', 'Online', 1, 'Completed', '2026-03-19T08:45:00');
        SET @appointmentId = SCOPE_IDENTITY();
    END
    SELECT @invoiceId = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-03-19T09:30:00' AND status = 'Paid';
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, NULL, 450000, 0, 450000, 'Cash', 'Paid', '2026-03-19T09:30:00', NULL);
        SET @invoiceId = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND appointment_id = @appointmentId AND service_id = @labServiceId)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId, @labServiceId, @appointmentId, 1, 450000);
    END

    -- April 2026
    SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'visit.patient3@example.com';
    IF @patientAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Visit Patient 3', 'seed_hash', 'visit.patient3@example.com', 'Patient', '2026-04-01T08:00:00', 'Active');
        SET @patientAccountId = SCOPE_IDENTITY();
    END
    SELECT @patientId = patient_id FROM dbo.Patient WHERE account_id = @patientAccountId;
    IF @patientId IS NULL
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES ('Visit Patient 3', '1992-03-13', N'Male', '0910000003', 'visit.patient3@example.com', N'Ho Chi Minh City', @patientAccountId);
        SET @patientId = SCOPE_IDENTITY();
    END
    SELECT @scheduleId = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-04-19' AND time_slot = '09:00-09:30';
    IF @scheduleId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-04-19', '09:00-09:30', 1, 'Full');
        SET @scheduleId = SCOPE_IDENTITY();
    END
    SELECT @appointmentId = appointment_id FROM dbo.Appointment WHERE patient_id = @patientId AND schedule_id = @scheduleId;
    IF @appointmentId IS NULL
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId, NULL, '2026-04-19T09:15:00', 'Online', 1, 'Completed', '2026-04-19T09:15:00');
        SET @appointmentId = SCOPE_IDENTITY();
    END
    SELECT @invoiceId = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-04-19T10:00:00' AND status = 'Paid';
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, NULL, 650000, 0, 650000, 'Cash', 'Paid', '2026-04-19T10:00:00', NULL);
        SET @invoiceId = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND appointment_id = @appointmentId AND service_id = @examServiceId)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId, @examServiceId, @appointmentId, 1, 650000);
    END

    -- May 2026
    SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'visit.patient4@example.com';
    IF @patientAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Visit Patient 4', 'seed_hash', 'visit.patient4@example.com', 'Patient', '2026-05-01T08:00:00', 'Active');
        SET @patientAccountId = SCOPE_IDENTITY();
    END
    SELECT @patientId = patient_id FROM dbo.Patient WHERE account_id = @patientAccountId;
    IF @patientId IS NULL
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES ('Visit Patient 4', '1991-04-14', N'Female', '0910000004', 'visit.patient4@example.com', N'Ho Chi Minh City', @patientAccountId);
        SET @patientId = SCOPE_IDENTITY();
    END
    SELECT @scheduleId = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-05-19' AND time_slot = '09:30-10:00';
    IF @scheduleId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-05-19', '09:30-10:00', 1, 'Full');
        SET @scheduleId = SCOPE_IDENTITY();
    END
    SELECT @appointmentId = appointment_id FROM dbo.Appointment WHERE patient_id = @patientId AND schedule_id = @scheduleId;
    IF @appointmentId IS NULL
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId, NULL, '2026-05-19T09:45:00', 'Online', 1, 'Completed', '2026-05-19T09:45:00');
        SET @appointmentId = SCOPE_IDENTITY();
    END
    SELECT @invoiceId = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-05-19T10:30:00' AND status = 'Paid';
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, NULL, 450000, 0, 450000, 'Cash', 'Paid', '2026-05-19T10:30:00', NULL);
        SET @invoiceId = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND appointment_id = @appointmentId AND service_id = @labServiceId)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId, @labServiceId, @appointmentId, 1, 450000);
    END

    -- June 2026
    SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'visit.patient5@example.com';
    IF @patientAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Visit Patient 5', 'seed_hash', 'visit.patient5@example.com', 'Patient', '2026-06-01T08:00:00', 'Active');
        SET @patientAccountId = SCOPE_IDENTITY();
    END
    SELECT @patientId = patient_id FROM dbo.Patient WHERE account_id = @patientAccountId;
    IF @patientId IS NULL
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES ('Visit Patient 5', '1989-05-15', N'Male', '0910000005', 'visit.patient5@example.com', N'Ho Chi Minh City', @patientAccountId);
        SET @patientId = SCOPE_IDENTITY();
    END
    SELECT @scheduleId = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-06-19' AND time_slot = '10:00-10:30';
    IF @scheduleId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-06-19', '10:00-10:30', 1, 'Full');
        SET @scheduleId = SCOPE_IDENTITY();
    END
    SELECT @appointmentId = appointment_id FROM dbo.Appointment WHERE patient_id = @patientId AND schedule_id = @scheduleId;
    IF @appointmentId IS NULL
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId, NULL, '2026-06-19T10:15:00', 'Online', 1, 'Completed', '2026-06-19T10:15:00');
        SET @appointmentId = SCOPE_IDENTITY();
    END
    SELECT @invoiceId = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-06-19T11:00:00' AND status = 'Paid';
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, NULL, 650000, 0, 650000, 'Cash', 'Paid', '2026-06-19T11:00:00', NULL);
        SET @invoiceId = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND appointment_id = @appointmentId AND service_id = @examServiceId)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId, @examServiceId, @appointmentId, 1, 650000);
    END

    -- July 2026
    SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'visit.patient6@example.com';
    IF @patientAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Visit Patient 6', 'seed_hash', 'visit.patient6@example.com', 'Patient', '2026-07-01T08:00:00', 'Active');
        SET @patientAccountId = SCOPE_IDENTITY();
    END
    SELECT @patientId = patient_id FROM dbo.Patient WHERE account_id = @patientAccountId;
    IF @patientId IS NULL
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES ('Visit Patient 6', '1993-06-16', N'Female', '0910000006', 'visit.patient6@example.com', N'Ho Chi Minh City', @patientAccountId);
        SET @patientId = SCOPE_IDENTITY();
    END
    SELECT @scheduleId = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-07-19' AND time_slot = '10:30-11:00';
    IF @scheduleId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-07-19', '10:30-11:00', 1, 'Full');
        SET @scheduleId = SCOPE_IDENTITY();
    END
    SELECT @appointmentId = appointment_id FROM dbo.Appointment WHERE patient_id = @patientId AND schedule_id = @scheduleId;
    IF @appointmentId IS NULL
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId, NULL, '2026-07-19T10:45:00', 'Online', 1, 'Completed', '2026-07-19T10:45:00');
        SET @appointmentId = SCOPE_IDENTITY();
    END
    SELECT @invoiceId = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-07-19T11:30:00' AND status = 'Paid';
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, NULL, 450000, 0, 450000, 'Cash', 'Paid', '2026-07-19T11:30:00', NULL);
        SET @invoiceId = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND appointment_id = @appointmentId AND service_id = @labServiceId)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId, @labServiceId, @appointmentId, 1, 450000);
    END

    -- August 2026
    SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'visit.patient7@example.com';
    IF @patientAccountId IS NULL
    BEGIN
        INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
        VALUES ('Visit Patient 7', 'seed_hash', 'visit.patient7@example.com', 'Patient', '2026-08-01T08:00:00', 'Active');
        SET @patientAccountId = SCOPE_IDENTITY();
    END
    SELECT @patientId = patient_id FROM dbo.Patient WHERE account_id = @patientAccountId;
    IF @patientId IS NULL
    BEGIN
        INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES ('Visit Patient 7', '1994-07-17', N'Male', '0910000007', 'visit.patient7@example.com', N'Ho Chi Minh City', @patientAccountId);
        SET @patientId = SCOPE_IDENTITY();
    END
    SELECT @scheduleId = schedule_id FROM dbo.Doctor_Schedule WHERE doctor_id = @doctorId AND work_date = '2026-08-19' AND time_slot = '11:00-11:30';
    IF @scheduleId IS NULL
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, '2026-08-19', '11:00-11:30', 1, 'Full');
        SET @scheduleId = SCOPE_IDENTITY();
    END
    SELECT @appointmentId = appointment_id FROM dbo.Appointment WHERE patient_id = @patientId AND schedule_id = @scheduleId;
    IF @appointmentId IS NULL
    BEGIN
        INSERT INTO dbo.Appointment (patient_id, doctor_id, schedule_id, conversation_id, appointment_time, booking_type, queue_number, status, created_at)
        VALUES (@patientId, @doctorId, @scheduleId, NULL, '2026-08-19T11:15:00', 'Online', 1, 'Completed', '2026-08-19T11:15:00');
        SET @appointmentId = SCOPE_IDENTITY();
    END
    SELECT @invoiceId = invoice_id FROM dbo.Invoice WHERE patient_id = @patientId AND created_at = '2026-08-19T12:00:00' AND status = 'Paid';
    IF @invoiceId IS NULL
    BEGIN
        INSERT INTO dbo.Invoice (patient_id, receptionist_id, total_amount, insurance_deduction, final_amount, payment_method, status, created_at, exported_at)
        VALUES (@patientId, NULL, 650000, 0, 650000, 'Cash', 'Paid', '2026-08-19T12:00:00', NULL);
        SET @invoiceId = SCOPE_IDENTITY();
    END
    IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND appointment_id = @appointmentId AND service_id = @examServiceId)
    BEGIN
        INSERT INTO dbo.Invoice_Detail (invoice_id, service_id, appointment_id, quantity, price)
        VALUES (@invoiceId, @examServiceId, @appointmentId, 1, 650000);
    END

    COMMIT TRAN;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;
    THROW;
END CATCH;
