USE project_SWP;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    PRINT '=== Seed dashboard TODAY demo: START ===';

    IF OBJECT_ID(N'dbo.Account', N'U') IS NULL
        THROW 54001, 'Missing table dbo.Account', 1;

    IF OBJECT_ID(N'dbo.Doctor', N'U') IS NULL
        THROW 54002, 'Missing table dbo.Doctor', 1;

    IF OBJECT_ID(N'dbo.Doctor_Schedule', N'U') IS NULL
        THROW 54003, 'Missing table dbo.Doctor_Schedule', 1;

    IF OBJECT_ID(N'dbo.Appointment', N'U') IS NULL
        THROW 54004, 'Missing table dbo.Appointment', 1;

    IF OBJECT_ID(N'dbo.Invoice', N'U') IS NULL
        THROW 54005, 'Missing table dbo.Invoice', 1;

    IF OBJECT_ID(N'dbo.Invoice_Detail', N'U') IS NULL
        THROW 54006, 'Missing table dbo.Invoice_Detail', 1;

    IF OBJECT_ID(N'dbo.Medical_Service', N'U') IS NULL
        THROW 54007, 'Missing table dbo.Medical_Service', 1;

    DECLARE @today DATE = CAST(GETDATE() AS DATE);

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Medical_Service
        WHERE service_type = 'Examination' AND status = 'Active'
    )
    BEGIN
        INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
        VALUES ('SCOMS Demo Examination Service', 180000, 'Examination', 'Active');
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Medical_Service
        WHERE service_type = 'Lab_Test' AND status = 'Active'
    )
    BEGIN
        INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
        VALUES ('SCOMS Demo Lab Test Service', 320000, 'Lab_Test', 'Active');
    END;

    DECLARE @serviceExamId INT = (
        SELECT TOP 1 service_id
        FROM dbo.Medical_Service
        WHERE service_type = 'Examination' AND status = 'Active'
        ORDER BY service_id
    );

    DECLARE @serviceLabId INT = (
        SELECT TOP 1 service_id
        FROM dbo.Medical_Service
        WHERE service_type = 'Lab_Test' AND status = 'Active'
        ORDER BY service_id
    );

    DECLARE @examPrice DECIMAL(18,2) = (
        SELECT TOP 1 price
        FROM dbo.Medical_Service
        WHERE service_id = @serviceExamId
    );

    DECLARE @labPrice DECIMAL(18,2) = (
        SELECT TOP 1 price
        FROM dbo.Medical_Service
        WHERE service_id = @serviceLabId
    );

    IF @serviceExamId IS NULL OR @serviceLabId IS NULL
        THROW 54008, 'Cannot resolve Examination/Lab_Test service ids', 1;

    IF OBJECT_ID('tempdb..#DoctorPool') IS NOT NULL DROP TABLE #DoctorPool;
    IF OBJECT_ID('tempdb..#PatientPool') IS NOT NULL DROP TABLE #PatientPool;
    IF OBJECT_ID('tempdb..#SchedulePool') IS NOT NULL DROP TABLE #SchedulePool;

    SELECT TOP 6
        ROW_NUMBER() OVER (ORDER BY d.doctor_id) AS rn,
        d.doctor_id,
        d.full_name,
        d.department
    INTO #DoctorPool
    FROM dbo.Doctor d
    LEFT JOIN dbo.Account a ON a.account_id = d.account_id
    WHERE a.account_id IS NULL OR LOWER(a.status) = 'active'
    ORDER BY d.doctor_id;

    IF NOT EXISTS (SELECT 1 FROM #DoctorPool)
        THROW 54009, 'No doctor found for demo seed', 1;

    SELECT TOP 80
        ROW_NUMBER() OVER (ORDER BY a.account_id) AS rn,
        a.account_id AS patient_id
    INTO #PatientPool
    FROM dbo.Account a
    WHERE LOWER(a.role) = 'patient'
      AND LOWER(a.status) IN ('active', 'locked')
    ORDER BY a.account_id;

    IF NOT EXISTS (SELECT 1 FROM #PatientPool)
        THROW 54010, 'No patient account found for demo seed', 1;

    DECLARE @slotMap TABLE (slot_order INT PRIMARY KEY, time_slot VARCHAR(50));
    INSERT INTO @slotMap(slot_order, time_slot)
    VALUES (1, '07:00-09:00'), (2, '09:00-11:00'), (3, '13:00-15:00'), (4, '15:00-17:00');

    DECLARE @doctorCount INT = (SELECT COUNT(*) FROM #DoctorPool);
    DECLARE @d INT = 1;

    WHILE @d <= @doctorCount
    BEGIN
        DECLARE @doctorId INT;
        DECLARE @timeSlot VARCHAR(50);

        SELECT @doctorId = doctor_id FROM #DoctorPool WHERE rn = @d;
        SELECT @timeSlot = time_slot FROM @slotMap WHERE slot_order = ((@d - 1) % 4) + 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Doctor_Schedule ds
            WHERE ds.doctor_id = @doctorId
              AND ds.work_date = @today
              AND ds.time_slot = @timeSlot
        )
        BEGIN
            INSERT INTO dbo.Doctor_Schedule(doctor_id, work_date, time_slot, max_patients, status)
            VALUES (@doctorId, @today, @timeSlot, 12, 'Available');
        END;

        SET @d = @d + 1;
    END;

    SELECT
        ROW_NUMBER() OVER (ORDER BY ds.time_slot, ds.doctor_id, ds.schedule_id) AS rn,
        ds.schedule_id,
        ds.doctor_id,
        ds.time_slot,
        CASE ds.time_slot
            WHEN '07:00-09:00' THEN 1
            WHEN '09:00-11:00' THEN 2
            WHEN '13:00-15:00' THEN 3
            WHEN '15:00-17:00' THEN 4
            ELSE 5
        END AS slot_order
    INTO #SchedulePool
    FROM dbo.Doctor_Schedule ds
    WHERE ds.work_date = @today
      AND LOWER(ds.status) <> 'cancelled';

    IF NOT EXISTS (SELECT 1 FROM #SchedulePool)
        THROW 54011, 'No schedule found for today', 1;

    IF OBJECT_ID('tempdb..#SeedPlan') IS NOT NULL DROP TABLE #SeedPlan;
    CREATE TABLE #SeedPlan (
        rn INT PRIMARY KEY,
        status_value VARCHAR(20) NOT NULL,
        slot_order INT NOT NULL,
        minute_offset INT NOT NULL,
        add_lab BIT NOT NULL
    );

    INSERT INTO #SeedPlan(rn, status_value, slot_order, minute_offset, add_lab)
    VALUES
        (1,  'Waiting',     1,  10, 0),
        (2,  'Waiting',     1,  28, 0),
        (3,  'Waiting',     2,  40, 0),
        (4,  'Waiting',     3,  55, 0),
        (5,  'In_Progress', 2,  70, 0),
        (6,  'In_Progress', 3,  90, 0),
        (7,  'Completed',   1, 110, 1),
        (8,  'Completed',   2, 130, 0),
        (9,  'Completed',   3, 150, 1),
        (10, 'Completed',   4, 170, 0),
        (11, 'Waiting',     4, 190, 0),
        (12, 'Completed',   1, 210, 1),
        (13, 'Completed',   2, 230, 0),
        (14, 'Completed',   3, 250, 1),
        (15, 'Completed',   4, 270, 0);

    IF OBJECT_ID('tempdb..#CompletedAppointments') IS NOT NULL DROP TABLE #CompletedAppointments;
    CREATE TABLE #CompletedAppointments (
        appointment_id INT NOT NULL,
        patient_id INT NOT NULL,
        appointment_time DATETIME NOT NULL,
        add_lab BIT NOT NULL
    );

    DECLARE @planCount INT = (SELECT COUNT(*) FROM #SeedPlan);
    DECLARE @i INT = 1;
    DECLARE @patientIdx INT = 1;
    DECLARE @patientPoolCount INT = (SELECT COUNT(*) FROM #PatientPool);

    WHILE @i <= @planCount
    BEGIN
        DECLARE @status VARCHAR(20);
        DECLARE @targetSlotOrder INT;
        DECLARE @offset INT;
        DECLARE @addLab BIT;
        DECLARE @scheduleId INT;
        DECLARE @scheduleDoctorId INT;
        DECLARE @patientId INT;
        DECLARE @apptTime DATETIME;
        DECLARE @insertSql NVARCHAR(MAX);
        DECLARE @insertedAppointmentId INT;

        SELECT
            @status = status_value,
            @targetSlotOrder = slot_order,
            @offset = minute_offset,
            @addLab = add_lab
        FROM #SeedPlan
        WHERE rn = @i;

        SELECT TOP 1
            @scheduleId = sp.schedule_id,
            @scheduleDoctorId = sp.doctor_id
        FROM #SchedulePool sp
        WHERE sp.slot_order = @targetSlotOrder
        ORDER BY sp.rn;

        IF @scheduleId IS NULL
        BEGIN
            SELECT TOP 1
                @scheduleId = sp.schedule_id,
                @scheduleDoctorId = sp.doctor_id
            FROM #SchedulePool sp
            ORDER BY sp.rn;
        END;

        SELECT @patientId = patient_id FROM #PatientPool WHERE rn = @patientIdx;
        SET @apptTime = DATEADD(MINUTE, @offset, CAST(@today AS DATETIME));

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Appointment ap
            WHERE ap.schedule_id = @scheduleId
              AND ap.patient_id = @patientId
              AND ap.status = @status
              AND CAST(ap.appointment_time AS DATE) = @today
              AND DATEDIFF(MINUTE, ap.appointment_time, @apptTime) = 0
        )
        BEGIN
            SET @insertSql = N'INSERT INTO dbo.Appointment ('
                + N'patient_id, schedule_id'
                + CASE WHEN COL_LENGTH('dbo.Appointment', 'doctor_id') IS NOT NULL THEN N', doctor_id' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Appointment', 'appointment_time') IS NOT NULL THEN N', appointment_time' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Appointment', 'created_at') IS NOT NULL THEN N', created_at' ELSE N'' END
                + N', status) VALUES ('
                + N'@p_patient_id, @p_schedule_id'
                + CASE WHEN COL_LENGTH('dbo.Appointment', 'doctor_id') IS NOT NULL THEN N', @p_doctor_id' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Appointment', 'appointment_time') IS NOT NULL THEN N', @p_appt_time' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Appointment', 'created_at') IS NOT NULL THEN N', DATEADD(MINUTE, -25, @p_appt_time)' ELSE N'' END
                + N', @p_status);';

            EXEC sp_executesql
                @insertSql,
                N'@p_patient_id INT, @p_schedule_id INT, @p_doctor_id INT, @p_appt_time DATETIME, @p_status VARCHAR(20)',
                @p_patient_id = @patientId,
                @p_schedule_id = @scheduleId,
                @p_doctor_id = @scheduleDoctorId,
                @p_appt_time = @apptTime,
                @p_status = @status;
        END;

        SELECT TOP 1 @insertedAppointmentId = ap.appointment_id
        FROM dbo.Appointment ap
        WHERE ap.schedule_id = @scheduleId
          AND ap.patient_id = @patientId
          AND ap.status = @status
          AND CAST(ap.appointment_time AS DATE) = @today
        ORDER BY ap.appointment_id DESC;

        IF @status = 'Completed' AND @insertedAppointmentId IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT 1
                FROM #CompletedAppointments ca
                WHERE ca.appointment_id = @insertedAppointmentId
            )
            BEGIN
                INSERT INTO #CompletedAppointments(appointment_id, patient_id, appointment_time, add_lab)
                VALUES (@insertedAppointmentId, @patientId, @apptTime, @addLab);
            END;
        END;

        SET @patientIdx = @patientIdx + 1;
        IF @patientIdx > @patientPoolCount SET @patientIdx = 1;

        SET @i = @i + 1;
    END;

    DECLARE @apptId INT;
    DECLARE @ptId INT;
    DECLARE @apptDT DATETIME;
    DECLARE @needLab BIT;
    DECLARE @invoiceInsertSql NVARCHAR(MAX);
    DECLARE @invoiceId INT;
    DECLARE @lineExam DECIMAL(18,2);
    DECLARE @lineLab DECIMAL(18,2);
    DECLARE @invoiceTotal DECIMAL(18,2);

    DECLARE c_completed CURSOR LOCAL FAST_FORWARD FOR
        SELECT appointment_id, patient_id, appointment_time, add_lab
        FROM #CompletedAppointments
        ORDER BY appointment_id;

    OPEN c_completed;
    FETCH NEXT FROM c_completed INTO @apptId, @ptId, @apptDT, @needLab;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Invoice i
            WHERE i.appointment_id = @apptId
              AND LOWER(i.status) = 'paid'
              AND CAST(i.created_at AS DATE) = @today
        )
        BEGIN
            SET @lineExam = ISNULL(@examPrice, 180000);
            SET @lineLab = CASE WHEN @needLab = 1 THEN ISNULL(@labPrice, 320000) ELSE 0 END;
            SET @invoiceTotal = @lineExam + @lineLab;

            SET @invoiceInsertSql = N'INSERT INTO dbo.Invoice ('
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'appointment_id') IS NOT NULL THEN N'appointment_id, ' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'patient_id') IS NOT NULL THEN N'patient_id, ' ELSE N'' END
                + N'total_amount, final_amount, status'
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'created_at') IS NOT NULL THEN N', created_at' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'exported_at') IS NOT NULL THEN N', exported_at' ELSE N'' END
                + N') VALUES ('
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'appointment_id') IS NOT NULL THEN N'@p_appt_id, ' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'patient_id') IS NOT NULL THEN N'@p_patient_id, ' ELSE N'' END
                + N'@p_total, @p_total, ''Paid'''
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'created_at') IS NOT NULL THEN N', DATEADD(MINUTE, 18, @p_appt_dt)' ELSE N'' END
                + CASE WHEN COL_LENGTH('dbo.Invoice', 'exported_at') IS NOT NULL THEN N', DATEADD(MINUTE, 22, @p_appt_dt)' ELSE N'' END
                + N');';

            EXEC sp_executesql
                @invoiceInsertSql,
                N'@p_appt_id INT, @p_patient_id INT, @p_appt_dt DATETIME, @p_total DECIMAL(18,2)',
                @p_appt_id = @apptId,
                @p_patient_id = @ptId,
                @p_appt_dt = @apptDT,
                @p_total = @invoiceTotal;

            SELECT TOP 1 @invoiceId = i.invoice_id
            FROM dbo.Invoice i
            WHERE i.appointment_id = @apptId
              AND LOWER(i.status) = 'paid'
            ORDER BY i.invoice_id DESC;

            IF @invoiceId IS NOT NULL
            BEGIN
                IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail id WHERE id.invoice_id = @invoiceId)
                BEGIN
                    INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, quantity, unit_price, line_total)
                    VALUES (@invoiceId, @serviceExamId, 1, @lineExam, @lineExam);

                    IF @needLab = 1
                    BEGIN
                        INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, quantity, unit_price, line_total)
                        VALUES (@invoiceId, @serviceLabId, 1, @lineLab, @lineLab);
                    END;
                END;
            END;
        END;

        FETCH NEXT FROM c_completed INTO @apptId, @ptId, @apptDT, @needLab;
    END;

    CLOSE c_completed;
    DEALLOCATE c_completed;

    PRINT '--- Verify widget data (today) ---';
    SELECT
        COUNT(*) AS total_visits_today,
        SUM(CASE WHEN LOWER(status) = 'waiting' THEN 1 ELSE 0 END) AS waiting_patients_today
    FROM dbo.Appointment
    WHERE CAST(appointment_time AS DATE) = @today;

    PRINT '--- Verify chart #1 (patient flow by time slot) ---';
    SELECT ds.time_slot, COUNT(ap.appointment_id) AS visit_count
    FROM dbo.Appointment ap
    JOIN dbo.Doctor_Schedule ds ON ds.schedule_id = ap.schedule_id
    WHERE CAST(ap.appointment_time AS DATE) = @today
    GROUP BY ds.time_slot
    ORDER BY ds.time_slot;

    PRINT '--- Verify chart #2 (revenue by service type today) ---';
    SELECT ms.service_type, SUM(id.line_total) AS total_revenue
    FROM dbo.Invoice i
    JOIN dbo.Invoice_Detail id ON id.invoice_id = i.invoice_id
    JOIN dbo.Medical_Service ms ON ms.service_id = id.service_id
    WHERE LOWER(i.status) = 'paid'
      AND CAST(i.created_at AS DATE) = @today
    GROUP BY ms.service_type
    ORDER BY ms.service_type;

    PRINT '--- Verify chart #3 (status distribution today) ---';
    SELECT ap.status, COUNT(ap.appointment_id) AS total_count
    FROM dbo.Appointment ap
    WHERE CAST(ap.appointment_time AS DATE) = @today
      AND LOWER(ap.status) IN ('waiting', 'in_progress', 'completed')
    GROUP BY ap.status
    ORDER BY ap.status;

    COMMIT TRAN;
    PRINT '=== Seed dashboard TODAY demo: DONE ===';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @errNo INT = ERROR_NUMBER();
    DECLARE @errLine INT = ERROR_LINE();
    RAISERROR('Seed dashboard TODAY demo failed [%d] at line %d: %s', 16, 1, @errNo, @errLine, @errMsg);
END CATCH;
GO
