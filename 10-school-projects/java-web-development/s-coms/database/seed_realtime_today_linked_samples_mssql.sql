USE [Project];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @today DATE = CAST(GETDATE() AS DATE);
    DECLARE @now DATETIME = GETDATE();

    DECLARE @examServiceId INT = NULL;
    DECLARE @examPrice DECIMAL(18, 2) = NULL;
    DECLARE @labServiceId INT = NULL;
    DECLARE @labPrice DECIMAL(18, 2) = NULL;
    DECLARE @fallbackServiceId INT = NULL;
    DECLARE @fallbackPrice DECIMAL(18, 2) = NULL;
    DECLARE @receptionistId INT = NULL;

    SELECT TOP 1
        @examServiceId = service_id,
        @examPrice = CAST(price AS DECIMAL(18, 2))
    FROM dbo.Medical_Service
    WHERE LOWER(ISNULL(status, '')) = 'active'
      AND LOWER(ISNULL(service_type, '')) LIKE '%exam%'
    ORDER BY service_id;

    SELECT TOP 1
        @labServiceId = service_id,
        @labPrice = CAST(price AS DECIMAL(18, 2))
    FROM dbo.Medical_Service
    WHERE LOWER(ISNULL(status, '')) = 'active'
      AND LOWER(ISNULL(service_type, '')) LIKE '%lab%'
    ORDER BY service_id;

    SELECT TOP 1
        @fallbackServiceId = service_id,
        @fallbackPrice = CAST(price AS DECIMAL(18, 2))
    FROM dbo.Medical_Service
    ORDER BY service_id;

    SET @examServiceId = COALESCE(@examServiceId, @fallbackServiceId);
    SET @examPrice = COALESCE(@examPrice, @fallbackPrice, 0);
    SET @labServiceId = COALESCE(@labServiceId, @examServiceId);
    SET @labPrice = COALESCE(@labPrice, @examPrice, 0);

    SELECT TOP 1 @receptionistId = a.account_id
    FROM dbo.Account a
    WHERE LOWER(a.role) = 'receptionist'
      AND LOWER(ISNULL(a.status, 'active')) = 'active'
    ORDER BY a.account_id;

    IF @receptionistId IS NULL
    BEGIN
        SELECT TOP 1 @receptionistId = a.account_id
        FROM dbo.Account a
        WHERE LOWER(ISNULL(a.status, 'active')) = 'active'
        ORDER BY a.account_id;
    END;

    DECLARE @TodaySchedules TABLE (
        schedule_id INT PRIMARY KEY,
        doctor_id INT NOT NULL,
        time_slot VARCHAR(30) NOT NULL,
        slot_start DATETIME NOT NULL,
        schedule_rank INT NOT NULL
    );

    INSERT INTO @TodaySchedules (schedule_id, doctor_id, time_slot, slot_start, schedule_rank)
    SELECT TOP (6)
        ds.schedule_id,
        ds.doctor_id,
        ds.time_slot,
        CAST(CONVERT(VARCHAR(10), @today, 120) + ' ' + LEFT(ds.time_slot, 5) + ':00' AS DATETIME),
        ROW_NUMBER() OVER (
            ORDER BY TRY_CONVERT(TIME, LEFT(ds.time_slot, 5) + ':00'), ds.schedule_id
        )
    FROM dbo.Doctor_Schedule ds
    WHERE ds.work_date = @today
      AND LOWER(ISNULL(ds.status, 'available')) <> 'cancelled'
    ORDER BY TRY_CONVERT(TIME, LEFT(ds.time_slot, 5) + ':00'), ds.schedule_id;

    IF NOT EXISTS (SELECT 1 FROM @TodaySchedules)
    BEGIN
        PRINT N'[SKIP] No usable schedules found for today. Nothing to seed.';
        COMMIT TRAN;
        SELECT 'no_schedules_today' AS metric, 0 AS val;
        RETURN;
    END;

    DECLARE @serviceMap TABLE (
        service_kind VARCHAR(20) NOT NULL PRIMARY KEY,
        service_id INT NOT NULL,
        price DECIMAL(18, 2) NOT NULL
    );

    INSERT INTO @serviceMap (service_kind, service_id, price)
    VALUES
        ('exam', @examServiceId, @examPrice),
        ('lab', @labServiceId, @labPrice);

    DECLARE @Seed TABLE (
        seed_id INT IDENTITY(1,1) PRIMARY KEY,
        schedule_id INT NOT NULL,
        doctor_id INT NOT NULL,
        schedule_rank INT NOT NULL,
        queue_number INT NOT NULL,
        patient_email NVARCHAR(128) NOT NULL,
        patient_name NVARCHAR(120) NOT NULL,
        patient_gender NVARCHAR(20) NOT NULL,
        patient_dob DATE NOT NULL,
        patient_phone NVARCHAR(30) NOT NULL,
        patient_address NVARCHAR(200) NOT NULL,
        booking_type VARCHAR(20) NOT NULL,
        appointment_time DATETIME NOT NULL,
        appointment_status VARCHAR(20) NOT NULL,
        service_kind VARCHAR(20) NOT NULL,
        payment_method VARCHAR(20) NOT NULL,
        service_id INT NULL,
        service_price DECIMAL(18, 2) NULL,
        invoice_created_at DATETIME NULL,
        should_invoice BIT NOT NULL DEFAULT (0)
    );

    INSERT INTO @Seed (
        schedule_id,
        doctor_id,
        schedule_rank,
        queue_number,
        patient_email,
        patient_name,
        patient_gender,
        patient_dob,
        patient_phone,
        patient_address,
        booking_type,
        appointment_time,
        appointment_status,
        service_kind,
        payment_method,
        should_invoice
    )
    SELECT
        s.schedule_id,
        s.doctor_id,
        s.schedule_rank,
        q.queue_number,
        CONCAT('seed.today.', CONVERT(VARCHAR(8), @today, 112), '.', s.schedule_id, '.', q.queue_number, '@example.com'),
        CONCAT(N'Seed Patient ', RIGHT('00' + CAST(s.schedule_rank AS VARCHAR(2)), 2), '-', q.queue_number),
        CASE WHEN (s.schedule_rank + q.queue_number) % 2 = 0 THEN N'Male' ELSE N'Female' END,
        DATEFROMPARTS(
            YEAR(@today) - (25 + s.schedule_rank),
            ((s.schedule_rank + q.queue_number) % 12) + 1,
            ((s.schedule_rank * 3 + q.queue_number) % 27) + 1
        ),
        CONCAT('09', RIGHT('00000000' + CAST(7000000 + (s.schedule_rank * 100) + q.queue_number AS VARCHAR(8)), 8)),
        CONCAT(N'Sample ward ', s.schedule_rank),
        q.booking_type,
        DATEADD(MINUTE, q.minute_offset, s.slot_start),
        CASE
            WHEN s.slot_start <= DATEADD(MINUTE, -90, @now) THEN
                CASE q.queue_number
                    WHEN 1 THEN 'Completed'
                    WHEN 2 THEN 'Completed'
                    ELSE 'No_Show'
                END
            WHEN s.slot_start <= DATEADD(MINUTE, -30, @now) THEN
                CASE q.queue_number
                    WHEN 1 THEN 'Completed'
                    WHEN 2 THEN 'In_Progress'
                    ELSE 'Waiting'
                END
            WHEN s.slot_start <= DATEADD(MINUTE, 30, @now) THEN
                CASE q.queue_number
                    WHEN 1 THEN 'Waiting'
                    WHEN 2 THEN 'In_Progress'
                    ELSE 'Waiting'
                END
            ELSE 'Waiting'
        END,
        q.service_kind,
        q.payment_method,
        CASE
            WHEN s.slot_start <= DATEADD(MINUTE, -30, @now)
                 AND q.queue_number IN (1, 2) THEN 1
            ELSE 0
        END
    FROM @TodaySchedules s
    CROSS APPLY (
        VALUES
            (1, 5,  'Online',     'exam', 'Cash'),
            (2, 20, 'At_Counter', 'lab',  'VNPay'),
            (3, 35, 'Online',     'exam', 'Momo')
    ) q(queue_number, minute_offset, booking_type, service_kind, payment_method);

    UPDATE s
    SET
        s.service_id = sm.service_id,
        s.service_price = sm.price,
        s.invoice_created_at = CASE WHEN s.should_invoice = 1 THEN DATEADD(MINUTE, 45, s.appointment_time) END
    FROM @Seed s
    JOIN @serviceMap sm ON sm.service_kind = s.service_kind;

    INSERT INTO dbo.Account (full_name, password_hash, email, role, created_at, status)
    SELECT DISTINCT
        s.patient_name,
        'seed_hash',
        s.patient_email,
        'Patient',
        GETDATE(),
        'Active'
    FROM @Seed s
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Account a WHERE a.email = s.patient_email
    );

    INSERT INTO dbo.Patient (full_name, date_of_birth, gender, phone, email, address, account_id)
    SELECT DISTINCT
        s.patient_name,
        s.patient_dob,
        s.patient_gender,
        s.patient_phone,
        s.patient_email,
        s.patient_address,
        a.account_id
    FROM @Seed s
    JOIN dbo.Account a ON a.email = s.patient_email
    WHERE NOT EXISTS (
        SELECT 1 FROM dbo.Patient p WHERE p.account_id = a.account_id
    );

    CREATE TABLE #PatientMap (
        patient_email NVARCHAR(128) NOT NULL PRIMARY KEY,
        account_id INT NOT NULL,
        patient_id INT NOT NULL
    );

    INSERT INTO #PatientMap (patient_email, account_id, patient_id)
    SELECT a.email, a.account_id, p.patient_id
    FROM dbo.Account a
    JOIN dbo.Patient p ON p.account_id = a.account_id
    WHERE a.email IN (SELECT DISTINCT patient_email FROM @Seed);

    UPDATE ap
    SET
        ap.doctor_id = s.doctor_id,
        ap.appointment_time = s.appointment_time,
        ap.status = s.appointment_status,
        ap.booking_type = s.booking_type,
        ap.created_at = ISNULL(ap.created_at, GETDATE())
    FROM dbo.Appointment ap
    JOIN @Seed s ON s.schedule_id = ap.schedule_id AND s.queue_number = ap.queue_number
    JOIN #PatientMap pm ON pm.patient_id = ap.patient_id AND pm.patient_email = s.patient_email
    WHERE CAST(ap.appointment_time AS DATE) = @today;

    INSERT INTO dbo.Appointment (
        patient_id,
        doctor_id,
        schedule_id,
        appointment_time,
        created_at,
        status,
        booking_type,
        queue_number
    )
    SELECT
        pm.patient_id,
        s.doctor_id,
        s.schedule_id,
        s.appointment_time,
        GETDATE(),
        s.appointment_status,
        s.booking_type,
        s.queue_number
    FROM @Seed s
    JOIN #PatientMap pm ON pm.patient_email = s.patient_email
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Appointment ap
        WHERE ap.schedule_id = s.schedule_id
          AND ap.queue_number = s.queue_number
          AND ap.patient_id = pm.patient_id
          AND CAST(ap.appointment_time AS DATE) = @today
    );

    CREATE TABLE #AppointmentMap (
        patient_email NVARCHAR(128) NOT NULL PRIMARY KEY,
        appointment_id INT NOT NULL,
        patient_id INT NOT NULL,
        doctor_id INT NOT NULL,
        schedule_id INT NOT NULL,
        queue_number INT NOT NULL,
        appointment_time DATETIME NOT NULL,
        appointment_status VARCHAR(20) NOT NULL,
        booking_type VARCHAR(20) NOT NULL,
        service_id INT NOT NULL,
        service_price DECIMAL(18, 2) NOT NULL,
        invoice_created_at DATETIME NULL,
        payment_method VARCHAR(20) NOT NULL,
        should_invoice BIT NOT NULL
    );

    INSERT INTO #AppointmentMap (
        patient_email,
        appointment_id,
        patient_id,
        doctor_id,
        schedule_id,
        queue_number,
        appointment_time,
        appointment_status,
        booking_type,
        service_id,
        service_price,
        invoice_created_at,
        payment_method,
        should_invoice
    )
    SELECT
        s.patient_email,
        ap.appointment_id,
        pm.patient_id,
        s.doctor_id,
        s.schedule_id,
        s.queue_number,
        s.appointment_time,
        s.appointment_status,
        s.booking_type,
        s.service_id,
        ISNULL(s.service_price, 0),
        s.invoice_created_at,
        s.payment_method,
        s.should_invoice
    FROM @Seed s
    JOIN #PatientMap pm ON pm.patient_email = s.patient_email
    JOIN dbo.Appointment ap
      ON ap.schedule_id = s.schedule_id
     AND ap.queue_number = s.queue_number
     AND ap.patient_id = pm.patient_id
     AND CAST(ap.appointment_time AS DATE) = @today;

    INSERT INTO dbo.Invoice (
        patient_id,
        receptionist_id,
        total_amount,
        insurance_deduction,
        final_amount,
        payment_method,
        status,
        created_at,
        exported_at
    )
    SELECT
        am.patient_id,
        @receptionistId,
        am.service_price,
        0,
        am.service_price,
        am.payment_method,
        'Paid',
        am.invoice_created_at,
        DATEADD(MINUTE, 5, am.invoice_created_at)
    FROM #AppointmentMap am
    WHERE am.should_invoice = 1
      AND am.invoice_created_at IS NOT NULL
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.Invoice i
          WHERE i.patient_id = am.patient_id
            AND i.created_at = am.invoice_created_at
            AND i.final_amount = am.service_price
            AND LOWER(ISNULL(i.status, '')) = 'paid'
      );

    CREATE TABLE #InvoiceMap (
        invoice_id INT NOT NULL PRIMARY KEY,
        patient_id INT NOT NULL,
        appointment_id INT NOT NULL,
        service_id INT NOT NULL,
        service_price DECIMAL(18, 2) NOT NULL
    );

    INSERT INTO #InvoiceMap (invoice_id, patient_id, appointment_id, service_id, service_price)
    SELECT
        i.invoice_id,
        am.patient_id,
        am.appointment_id,
        am.service_id,
        am.service_price
    FROM #AppointmentMap am
    JOIN dbo.Invoice i
      ON i.patient_id = am.patient_id
     AND i.created_at = am.invoice_created_at
     AND i.final_amount = am.service_price
    WHERE am.should_invoice = 1
      AND am.invoice_created_at IS NOT NULL;

    INSERT INTO dbo.Invoice_Detail (
        invoice_id,
        service_id,
        quantity,
        unit_price,
        line_total,
        appointment_id,
        price
    )
    SELECT
        im.invoice_id,
        im.service_id,
        1,
        im.service_price,
        im.service_price,
        im.appointment_id,
        im.service_price
    FROM #InvoiceMap im
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Invoice_Detail id
        WHERE id.invoice_id = im.invoice_id
          AND id.appointment_id = im.appointment_id
    );

    INSERT INTO dbo.Medical_record (
        patient_id,
        doctor_id,
        final_diagnosis,
        doctor_note,
        health_record_id,
        result_visibility,
        processed_at,
        appointment_id
    )
    SELECT
        am.patient_id,
        am.doctor_id,
        CONCAT(N'Seed completed visit - schedule ', am.schedule_id, N' / queue ', am.queue_number),
        N'Auto-generated sample medical record for dashboard synchronization.',
        NULL,
        1,
        GETDATE(),
        am.appointment_id
    FROM #AppointmentMap am
    WHERE am.appointment_status = 'Completed'
      AND NOT EXISTS (
          SELECT 1
          FROM dbo.Medical_record mr
          WHERE mr.appointment_id = am.appointment_id
      );

    UPDATE ds
    SET ds.status = CASE
        WHEN x.total_assigned >= ds.max_patients THEN 'Full'
        ELSE 'Available'
    END
    FROM dbo.Doctor_Schedule ds
    JOIN @TodaySchedules ts ON ts.schedule_id = ds.schedule_id
    CROSS APPLY (
        SELECT COUNT(*) AS total_assigned
        FROM dbo.Appointment ap
        WHERE ap.schedule_id = ds.schedule_id
          AND CAST(ap.appointment_time AS DATE) = @today
          AND LOWER(ISNULL(ap.status, '')) <> 'cancelled'
    ) x
    WHERE LOWER(ISNULL(ds.status, 'available')) <> 'cancelled';

    COMMIT TRAN;

    SELECT 'schedules_today' AS metric, COUNT(*) AS val FROM @TodaySchedules
    UNION ALL SELECT 'appointments_today', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) = @today
    UNION ALL SELECT 'waiting_today', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) = @today AND LOWER(ISNULL(status, '')) = 'waiting'
    UNION ALL SELECT 'in_progress_today', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) = @today AND LOWER(ISNULL(status, '')) = 'in_progress'
    UNION ALL SELECT 'completed_today', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) = @today AND LOWER(ISNULL(status, '')) = 'completed'
    UNION ALL SELECT 'no_show_today', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) = @today AND LOWER(ISNULL(status, '')) = 'no_show'
    UNION ALL SELECT 'paid_invoices_today', COUNT(*) FROM dbo.Invoice WHERE CAST(created_at AS DATE) = @today AND LOWER(ISNULL(status, '')) = 'paid'
    UNION ALL SELECT 'medical_records_today', COUNT(*) FROM dbo.Medical_record WHERE CAST(processed_at AS DATE) = @today;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    THROW;
END CATCH;