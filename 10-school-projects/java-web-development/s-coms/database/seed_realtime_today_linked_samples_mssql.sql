USE [Project_SWP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;
SET ANSI_NULLS ON;
SET ANSI_WARNINGS ON;
SET ANSI_PADDING ON;
SET QUOTED_IDENTIFIER ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;

BEGIN TRY
    BEGIN TRAN;

    DECLARE @seedStartDate DATE = CAST(GETDATE() AS DATE);
    DECLARE @seedEndDate DATE = DATEADD(DAY, 2, @seedStartDate);
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

    DECLARE @TargetSchedules TABLE (
        seed_date DATE NOT NULL,
        schedule_id INT PRIMARY KEY,
        doctor_id INT NOT NULL,
        time_slot VARCHAR(30) NOT NULL,
        slot_start DATETIME NOT NULL,
        schedule_rank INT NOT NULL
    );

    ;WITH RankedSchedules AS (
        SELECT
            ds.work_date AS seed_date,
            ds.schedule_id,
            ds.doctor_id,
            ds.time_slot,
            CAST(CONVERT(VARCHAR(10), ds.work_date, 120) + ' ' + LEFT(ds.time_slot, 5) + ':00' AS DATETIME) AS slot_start,
            ROW_NUMBER() OVER (
                PARTITION BY ds.work_date
                ORDER BY TRY_CONVERT(TIME, LEFT(ds.time_slot, 5) + ':00'), ds.schedule_id
            ) AS schedule_rank
        FROM dbo.Doctor_Schedule ds
        WHERE ds.work_date BETWEEN @seedStartDate AND @seedEndDate
          AND LOWER(ISNULL(ds.status, 'available')) <> 'cancelled'
    )
    INSERT INTO @TargetSchedules (seed_date, schedule_id, doctor_id, time_slot, slot_start, schedule_rank)
    SELECT seed_date, schedule_id, doctor_id, time_slot, slot_start, schedule_rank
    FROM RankedSchedules
    WHERE schedule_rank <= 6;

    IF NOT EXISTS (SELECT 1 FROM @TargetSchedules)
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
        seed_date DATE NOT NULL,
        schedule_id INT NOT NULL,
        doctor_id INT NOT NULL,
        schedule_rank INT NOT NULL,
        queue_number INT NOT NULL,
        patient_id INT NULL,
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
        seed_date,
        schedule_id,
        doctor_id,
        schedule_rank,
        queue_number,
        booking_type,
        appointment_time,
        appointment_status,
        service_kind,
        payment_method,
        should_invoice
    )
    SELECT
        s.seed_date,
        s.schedule_id,
        s.doctor_id,
        s.schedule_rank,
        q.queue_number,
        q.booking_type,
        DATEADD(MINUTE, q.minute_offset, s.slot_start),
        CASE
            WHEN CAST(s.seed_date AS DATE) = CAST(@now AS DATE) AND s.slot_start <= DATEADD(MINUTE, -90, @now) THEN
                CASE q.queue_number
                    WHEN 1 THEN 'Completed'
                    WHEN 2 THEN 'In_Progress'
                    WHEN 3 THEN 'Checked_In'
                    WHEN 4 THEN 'Waiting'
                    WHEN 5 THEN 'No_Show'
                    ELSE 'Cancelled'
                END
            WHEN CAST(s.seed_date AS DATE) = CAST(@now AS DATE) AND s.slot_start <= DATEADD(MINUTE, -30, @now) THEN
                CASE q.queue_number
                    WHEN 1 THEN 'Completed'
                    WHEN 2 THEN 'Checked_In'
                    WHEN 3 THEN 'In_Progress'
                    WHEN 4 THEN 'Waiting'
                    WHEN 5 THEN 'No_Show'
                    ELSE 'Cancelled'
                END
            WHEN CAST(s.seed_date AS DATE) = CAST(@now AS DATE) AND s.slot_start <= DATEADD(MINUTE, 30, @now) THEN
                CASE q.queue_number
                    WHEN 1 THEN 'Waiting'
                    WHEN 2 THEN 'Checked_In'
                    WHEN 3 THEN 'In_Progress'
                    WHEN 4 THEN 'Completed'
                    WHEN 5 THEN 'No_Show'
                    ELSE 'Cancelled'
                END
            ELSE
                CASE q.queue_number
                    WHEN 1 THEN 'Waiting'
                    WHEN 2 THEN 'Checked_In'
                    WHEN 3 THEN 'In_Progress'
                    WHEN 4 THEN 'Waiting'
                    WHEN 5 THEN 'No_Show'
                    ELSE 'Cancelled'
                END
        END,
        q.service_kind,
        q.payment_method,
        CASE
            WHEN CAST(s.seed_date AS DATE) = CAST(@now AS DATE)
                 AND s.slot_start <= DATEADD(MINUTE, -30, @now)
                 AND q.queue_number IN (1, 2, 3, 4) THEN 1
            ELSE 0
        END
    FROM @TargetSchedules s
    CROSS APPLY (
        VALUES
            (1, 5,  'Online',     'exam', 'Cash'),
            (2, 20, 'At_Counter', 'lab',  'VNPay'),
            (3, 35, 'Online',     'exam', 'Momo'),
            (4, 50, 'At_Counter', 'lab',  'Cash'),
            (5, 65, 'Online',     'exam', 'VNPay'),
            (6, 80, 'At_Counter', 'lab',  'Momo')
    ) q(queue_number, minute_offset, booking_type, service_kind, payment_method);

    UPDATE s
    SET
        s.service_id = sm.service_id,
        s.service_price = sm.price,
        s.invoice_created_at = CASE WHEN s.should_invoice = 1 THEN DATEADD(MINUTE, 45, s.appointment_time) END
    FROM @Seed s
    JOIN @serviceMap sm ON sm.service_kind = s.service_kind;

    CREATE TABLE #PatientPool (
        patient_row INT NOT NULL PRIMARY KEY,
        patient_id INT NOT NULL
    );

    DECLARE @PatientCount INT;

    INSERT INTO #PatientPool (patient_row, patient_id)
    SELECT ROW_NUMBER() OVER (ORDER BY p.patient_id), p.patient_id
    FROM dbo.Patient p
    ORDER BY p.patient_id;

    SELECT @PatientCount = COUNT(*) FROM #PatientPool;

    IF @PatientCount IS NULL OR @PatientCount = 0
    BEGIN
        THROW 50001, 'No existing patients available to seed appointments.', 1;
    END;

    UPDATE s
    SET s.patient_id = pp.patient_id
    FROM @Seed s
    JOIN #PatientPool pp ON pp.patient_row = ((s.seed_id - 1) % @PatientCount) + 1;

    UPDATE ap
    SET
        ap.patient_id = s.patient_id,
        ap.doctor_id = s.doctor_id,
        ap.appointment_time = s.appointment_time,
        ap.status = s.appointment_status,
        ap.booking_type = s.booking_type,
        ap.created_at = ISNULL(ap.created_at, GETDATE())
    FROM dbo.Appointment ap
    JOIN @Seed s ON s.schedule_id = ap.schedule_id AND s.queue_number = ap.queue_number
    WHERE CAST(ap.appointment_time AS DATE) = s.seed_date;

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
        s.patient_id,
        s.doctor_id,
        s.schedule_id,
        s.appointment_time,
        GETDATE(),
        s.appointment_status,
        s.booking_type,
        s.queue_number
    FROM @Seed s
    WHERE NOT EXISTS (
        SELECT 1
        FROM dbo.Appointment ap
        WHERE ap.schedule_id = s.schedule_id
          AND ap.queue_number = s.queue_number
        AND CAST(ap.appointment_time AS DATE) = s.seed_date
    );

    CREATE TABLE #AppointmentMap (
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
        ap.appointment_id,
        s.patient_id,
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
    JOIN dbo.Appointment ap
      ON ap.schedule_id = s.schedule_id
     AND ap.queue_number = s.queue_number
    AND CAST(ap.appointment_time AS DATE) = s.seed_date;

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
    JOIN @TargetSchedules ts ON ts.schedule_id = ds.schedule_id
    CROSS APPLY (
        SELECT COUNT(*) AS total_assigned
        FROM dbo.Appointment ap
        WHERE ap.schedule_id = ds.schedule_id
            AND CAST(ap.appointment_time AS DATE) = ts.seed_date
          AND LOWER(ISNULL(ap.status, '')) <> 'cancelled'
    ) x
        WHERE LOWER(ISNULL(ds.status, 'available')) <> 'cancelled';

    COMMIT TRAN;

    SELECT 'schedules_seeded' AS metric, COUNT(*) AS val FROM @TargetSchedules
    UNION ALL SELECT 'appointments_seeded', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) BETWEEN @seedStartDate AND @seedEndDate
    UNION ALL SELECT 'waiting_seeded', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) BETWEEN @seedStartDate AND @seedEndDate AND LOWER(ISNULL(status, '')) = 'waiting'
    UNION ALL SELECT 'checked_in_seeded', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) BETWEEN @seedStartDate AND @seedEndDate AND LOWER(ISNULL(status, '')) = 'checked_in'
    UNION ALL SELECT 'in_progress_seeded', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) BETWEEN @seedStartDate AND @seedEndDate AND LOWER(ISNULL(status, '')) = 'in_progress'
    UNION ALL SELECT 'completed_seeded', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) BETWEEN @seedStartDate AND @seedEndDate AND LOWER(ISNULL(status, '')) = 'completed'
    UNION ALL SELECT 'no_show_seeded', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) BETWEEN @seedStartDate AND @seedEndDate AND LOWER(ISNULL(status, '')) = 'no_show'
    UNION ALL SELECT 'cancelled_seeded', COUNT(*) FROM dbo.Appointment WHERE CAST(appointment_time AS DATE) BETWEEN @seedStartDate AND @seedEndDate AND LOWER(ISNULL(status, '')) = 'cancelled'
    UNION ALL SELECT 'paid_invoices_seeded', COUNT(*) FROM dbo.Invoice WHERE CAST(created_at AS DATE) BETWEEN @seedStartDate AND @seedEndDate AND LOWER(ISNULL(status, '')) = 'paid'
    UNION ALL SELECT 'medical_records_seeded', COUNT(*) FROM dbo.Medical_record WHERE CAST(processed_at AS DATE) BETWEEN @seedStartDate AND @seedEndDate;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    THROW;
END CATCH;