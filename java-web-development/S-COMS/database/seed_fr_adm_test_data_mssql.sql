USE project_SWP;
GO

SET NOCOUNT ON;

PRINT '=== S-COMS FR-ADM test data seed start ===';

/*
  Coverage mapping:
  - TC-ADM-02/03/04: Account create/role update/lock-reactivate
  - TC-ADM-05/06/07: Medical service create/toggle/delete
  - TC-ADM-08/09/10: Doctor schedule create/delete/full-capacity behavior
  - TC-ADM-11/12: Revenue + visit reports day/month/year
*/

/* -----------------------------
   A) Seed Account + Doctor data
   ----------------------------- */
DECLARE @adminAccountId INT;
DECLARE @doctorAccountId INT;
DECLARE @receptionAccountId INT;
DECLARE @patientAccountId INT;
DECLARE @doctorId INT;

IF OBJECT_ID(N'dbo.Account', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'adm.seed@scoms.local')
    BEGIN
        INSERT INTO dbo.Account (full_name, email, password_hash, role, status)
        VALUES ('Seed Admin SCOMS', 'adm.seed@scoms.local', REPLICATE('a', 64), 'admin', 'active');
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'doctor.seed@scoms.local')
    BEGIN
        INSERT INTO dbo.Account (full_name, email, password_hash, role, status)
        VALUES ('Seed Doctor SCOMS', 'doctor.seed@scoms.local', REPLICATE('b', 64), 'doctor', 'active');
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'reception.seed@scoms.local')
    BEGIN
        INSERT INTO dbo.Account (full_name, email, password_hash, role, status)
        VALUES ('Seed Reception SCOMS', 'reception.seed@scoms.local', REPLICATE('c', 64), 'receptionist', 'active');
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'patient.locked.seed@scoms.local')
    BEGIN
        INSERT INTO dbo.Account (full_name, email, password_hash, role, status)
        VALUES ('Seed Patient Locked', 'patient.locked.seed@scoms.local', REPLICATE('d', 64), 'patient', 'locked');
    END;
END;

SELECT @adminAccountId = account_id FROM dbo.Account WHERE email = 'adm.seed@scoms.local';
SELECT @doctorAccountId = account_id FROM dbo.Account WHERE email = 'doctor.seed@scoms.local';
SELECT @receptionAccountId = account_id FROM dbo.Account WHERE email = 'reception.seed@scoms.local';
SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'patient.locked.seed@scoms.local';

IF OBJECT_ID(N'dbo.Doctor', N'U') IS NOT NULL AND @doctorAccountId IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Doctor WHERE account_id = @doctorAccountId)
    BEGIN
        INSERT INTO dbo.Doctor (full_name, phone, email, department, account_id)
        VALUES ('Seed Doctor SCOMS', '0900000001', 'doctor.seed@scoms.local', 'Endocrinology', @doctorAccountId);
    END;
END;

SELECT @doctorId = doctor_id FROM dbo.Doctor WHERE account_id = @doctorAccountId;

/* -----------------------------------------
   B) Seed Medical_Service for TC-ADM-05/06/07
   ----------------------------------------- */
IF OBJECT_ID(N'dbo.Medical_Service', N'U') IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = 'SCOMS Kham Tong Quat Seed')
        INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
        VALUES ('SCOMS Kham Tong Quat Seed', 250000, 'Examination', 'Active');

    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = 'SCOMS HbA1c Seed')
        INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
        VALUES ('SCOMS HbA1c Seed', 180000, 'Lab_Test', 'Inactive');

    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = 'SCOMS Temporary Delete Seed')
        INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
        VALUES ('SCOMS Temporary Delete Seed', 99000, 'Examination', 'Active');
END;

/* --------------------------------------
   C) Seed Doctor_Schedule for TC-ADM-08/09
   -------------------------------------- */
IF OBJECT_ID(N'dbo.Doctor_Schedule', N'U') IS NOT NULL AND @doctorId IS NOT NULL
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM dbo.Doctor_Schedule
        WHERE doctor_id = @doctorId AND work_date = CAST(DATEADD(DAY, 1, GETDATE()) AS DATE) AND time_slot = '07:00-09:00'
    )
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, CAST(DATEADD(DAY, 1, GETDATE()) AS DATE), '07:00-09:00', 2, 'Available');
    END;

    IF NOT EXISTS (
        SELECT 1 FROM dbo.Doctor_Schedule
        WHERE doctor_id = @doctorId AND work_date = CAST(DATEADD(DAY, 2, GETDATE()) AS DATE) AND time_slot = '09:00-11:00'
    )
    BEGIN
        INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
        VALUES (@doctorId, CAST(DATEADD(DAY, 2, GETDATE()) AS DATE), '09:00-11:00', 1, 'Available');
    END;
END;

/* ---------------------------------------------------------
   D) Report + capacity shaping using existing rows (safe mode)
   TC-ADM-10/11/12
   --------------------------------------------------------- */
IF OBJECT_ID(N'dbo.Appointment', N'U') IS NOT NULL
BEGIN
    /* Promote a few existing appointments into Waiting/In_Progress/Completed across dates */
    IF COL_LENGTH('dbo.Appointment', 'appointment_time') IS NOT NULL
    BEGIN
        UPDATE TOP (2) dbo.Appointment
        SET status = 'Waiting', appointment_time = DATEADD(DAY, -1, GETDATE())
        WHERE status IS NULL OR status NOT IN ('Waiting', 'In_Progress', 'Completed', 'Cancelled');

        UPDATE TOP (2) dbo.Appointment
        SET status = 'In_Progress', appointment_time = GETDATE()
        WHERE status = 'Waiting';

        UPDATE TOP (5) dbo.Appointment
        SET status = 'Completed', appointment_time = DATEADD(MONTH, -1, GETDATE())
        WHERE status <> 'Completed';
    END;
END;

IF OBJECT_ID(N'dbo.Invoice', N'U') IS NOT NULL
BEGIN
    /* Shape existing invoices for day/month/year chart aggregation */
    IF COL_LENGTH('dbo.Invoice', 'created_at') IS NOT NULL
    BEGIN
        UPDATE TOP (3) dbo.Invoice
        SET status = 'Paid', final_amount = 300000, created_at = DATEADD(DAY, -2, GETDATE())
        WHERE status <> 'Paid' OR final_amount IS NULL;

        UPDATE TOP (3) dbo.Invoice
        SET status = 'Paid', final_amount = 450000, created_at = DATEADD(MONTH, -1, GETDATE())
        WHERE status = 'Paid';

        UPDATE TOP (3) dbo.Invoice
        SET status = 'Paid', final_amount = 520000, created_at = DATEADD(YEAR, -1, GETDATE())
        WHERE status = 'Paid';
    END;
END;

/* ----------------------------------------
   E) Quick verification snapshot for tester
   ---------------------------------------- */
PRINT '--- Account summary snapshot ---';
IF OBJECT_ID(N'dbo.Account', N'U') IS NOT NULL
BEGIN
    SELECT role, status, COUNT(*) AS cnt
    FROM dbo.Account
    GROUP BY role, status
    ORDER BY role, status;
END;

PRINT '--- Service summary snapshot ---';
IF OBJECT_ID(N'dbo.Medical_Service', N'U') IS NOT NULL
BEGIN
    SELECT service_name, service_type, status, price
    FROM dbo.Medical_Service
    WHERE service_name LIKE 'SCOMS % Seed' OR service_name LIKE 'SCOMS Temporary %'
    ORDER BY service_name;
END;

PRINT '--- Schedule summary snapshot ---';
IF OBJECT_ID(N'dbo.Doctor_Schedule', N'U') IS NOT NULL
BEGIN
    SELECT TOP 10 schedule_id, doctor_id, work_date, time_slot, max_patients, status
    FROM dbo.Doctor_Schedule
    ORDER BY work_date DESC, time_slot ASC;
END;

PRINT '--- Report summary snapshot (Paid invoice) ---';
IF OBJECT_ID(N'dbo.Invoice', N'U') IS NOT NULL
BEGIN
    SELECT FORMAT(created_at, 'yyyy-MM') AS period, SUM(final_amount) AS total_revenue
    FROM dbo.Invoice
    WHERE status = 'Paid'
    GROUP BY FORMAT(created_at, 'yyyy-MM')
    ORDER BY period;
END;

PRINT '=== S-COMS FR-ADM test data seed done ===';
GO
