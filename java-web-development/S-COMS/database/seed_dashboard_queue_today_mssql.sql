USE project_SWP;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    PRINT '=== Seed dashboard queue today: START ===';

    IF OBJECT_ID(N'dbo.Doctor_Schedule', N'U') IS NULL
        THROW 53001, 'Missing table dbo.Doctor_Schedule', 1;

    IF OBJECT_ID(N'dbo.Appointment', N'U') IS NULL
        THROW 53002, 'Missing table dbo.Appointment', 1;

    IF OBJECT_ID(N'dbo.Doctor', N'U') IS NULL
        THROW 53003, 'Missing table dbo.Doctor', 1;

    IF OBJECT_ID(N'dbo.Account', N'U') IS NULL
        THROW 53004, 'Missing table dbo.Account', 1;

    IF COL_LENGTH('dbo.Appointment', 'patient_id') IS NULL
       OR COL_LENGTH('dbo.Appointment', 'schedule_id') IS NULL
       OR COL_LENGTH('dbo.Appointment', 'appointment_time') IS NULL
       OR COL_LENGTH('dbo.Appointment', 'status') IS NULL
        THROW 53005, 'Appointment table missing one of required columns: patient_id, schedule_id, appointment_time, status', 1;

    IF COL_LENGTH('dbo.Doctor_Schedule', 'doctor_id') IS NULL
       OR COL_LENGTH('dbo.Doctor_Schedule', 'work_date') IS NULL
       OR COL_LENGTH('dbo.Doctor_Schedule', 'time_slot') IS NULL
       OR COL_LENGTH('dbo.Doctor_Schedule', 'status') IS NULL
        THROW 53006, 'Doctor_Schedule table missing required columns', 1;

    DECLARE @today DATE = CAST(GETDATE() AS DATE);

    IF OBJECT_ID('tempdb..#DoctorPool') IS NOT NULL DROP TABLE #DoctorPool;
    IF OBJECT_ID('tempdb..#PatientPool') IS NOT NULL DROP TABLE #PatientPool;
    IF OBJECT_ID('tempdb..#SchedulePool') IS NOT NULL DROP TABLE #SchedulePool;

    SELECT TOP 5
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
        THROW 53007, 'No doctor found to seed queue', 1;

    SELECT TOP 20
        ROW_NUMBER() OVER (ORDER BY a.account_id) AS rn,
        a.account_id AS patient_id
    INTO #PatientPool
    FROM dbo.Account a
    WHERE LOWER(a.role) = 'patient' AND LOWER(a.status) IN ('active', 'locked')
    ORDER BY a.account_id;

    IF NOT EXISTS (SELECT 1 FROM #PatientPool)
        THROW 53008, 'No patient account found to seed queue', 1;

    DECLARE @timeSlots TABLE (slot_order INT PRIMARY KEY, time_slot VARCHAR(50));
    INSERT INTO @timeSlots(slot_order, time_slot)
    VALUES (1, '07:00-09:00'), (2, '09:00-11:00'), (3, '13:00-15:00');

    DECLARE @doctorCount INT = (SELECT COUNT(*) FROM #DoctorPool);
    DECLARE @i INT = 1;

    WHILE @i <= @doctorCount
    BEGIN
        DECLARE @doctorId INT;
        DECLARE @slot VARCHAR(50);

        SELECT @doctorId = doctor_id FROM #DoctorPool WHERE rn = @i;
        SELECT @slot = time_slot FROM @timeSlots WHERE slot_order = ((@i - 1) % 3) + 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.Doctor_Schedule ds
            WHERE ds.doctor_id = @doctorId
              AND ds.work_date = @today
              AND ds.time_slot = @slot
        )
        BEGIN
            INSERT INTO dbo.Doctor_Schedule (doctor_id, work_date, time_slot, max_patients, status)
            VALUES (@doctorId, @today, @slot, 8, 'Available');
        END;

        SET @i = @i + 1;
    END;

    SELECT
        ROW_NUMBER() OVER (ORDER BY ds.doctor_id, ds.time_slot) AS rn,
        ds.schedule_id,
        ds.doctor_id,
        ds.time_slot
    INTO #SchedulePool
    FROM dbo.Doctor_Schedule ds
    WHERE ds.work_date = @today
      AND LOWER(ds.status) <> 'cancelled';

    IF NOT EXISTS (SELECT 1 FROM #SchedulePool)
        THROW 53009, 'No schedule found for today after seed', 1;

    DECLARE @scheduleCount INT = (SELECT COUNT(*) FROM #SchedulePool);
    DECLARE @s INT = 1;
    DECLARE @patientCursor INT = 1;
    DECLARE @patientPoolCount INT = (SELECT COUNT(*) FROM #PatientPool);

    WHILE @s <= @scheduleCount
    BEGIN
        DECLARE @scheduleId INT;
        DECLARE @scheduleDoctorId INT;
        DECLARE @existingWaiting INT;

        SELECT
            @scheduleId = schedule_id,
            @scheduleDoctorId = doctor_id
        FROM #SchedulePool
        WHERE rn = @s;

        SELECT @existingWaiting = COUNT(*)
        FROM dbo.Appointment ap
        WHERE ap.schedule_id = @scheduleId
          AND LOWER(ap.status) = 'waiting';

        WHILE @existingWaiting < 2
        BEGIN
            DECLARE @patientId INT;
            DECLARE @apptTime DATETIME;

            SELECT @patientId = patient_id FROM #PatientPool WHERE rn = @patientCursor;
            SET @apptTime = DATEADD(MINUTE, (@s * 20) + (@existingWaiting * 7), CAST(@today AS DATETIME));

            IF NOT EXISTS (
                SELECT 1
                FROM dbo.Appointment ap
                WHERE ap.schedule_id = @scheduleId
                  AND ap.patient_id = @patientId
                  AND LOWER(ap.status) IN ('waiting', 'in_progress')
            )
            BEGIN
                IF COL_LENGTH('dbo.Appointment', 'doctor_id') IS NOT NULL AND COL_LENGTH('dbo.Appointment', 'created_at') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.Appointment (patient_id, schedule_id, doctor_id, appointment_time, created_at, status)
                    VALUES (@patientId, @scheduleId, @scheduleDoctorId, @apptTime, GETDATE(), 'Waiting');
                END
                ELSE IF COL_LENGTH('dbo.Appointment', 'doctor_id') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.Appointment (patient_id, schedule_id, doctor_id, appointment_time, status)
                    VALUES (@patientId, @scheduleId, @scheduleDoctorId, @apptTime, 'Waiting');
                END
                ELSE IF COL_LENGTH('dbo.Appointment', 'created_at') IS NOT NULL
                BEGIN
                    INSERT INTO dbo.Appointment (patient_id, schedule_id, appointment_time, created_at, status)
                    VALUES (@patientId, @scheduleId, @apptTime, GETDATE(), 'Waiting');
                END
                ELSE
                BEGIN
                    INSERT INTO dbo.Appointment (patient_id, schedule_id, appointment_time, status)
                    VALUES (@patientId, @scheduleId, @apptTime, 'Waiting');
                END;

                SET @existingWaiting = @existingWaiting + 1;
            END;

            SET @patientCursor = @patientCursor + 1;
            IF @patientCursor > @patientPoolCount SET @patientCursor = 1;
        END;

        SET @s = @s + 1;
    END;

    PRINT '--- Queue snapshot for dashboard ---';
    SELECT
        d.full_name AS doctor_name,
        d.department,
        COUNT(ap.appointment_id) AS waiting_count
    FROM dbo.Doctor_Schedule ds
    JOIN dbo.Doctor d ON d.doctor_id = ds.doctor_id
    LEFT JOIN dbo.Appointment ap
        ON ap.schedule_id = ds.schedule_id
       AND LOWER(ap.status) = 'waiting'
    WHERE ds.work_date = @today
      AND LOWER(ds.status) <> 'cancelled'
    GROUP BY d.full_name, d.department
    ORDER BY waiting_count DESC, d.full_name ASC;

    COMMIT TRAN;
    PRINT '=== Seed dashboard queue today: DONE ===';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    DECLARE @errMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @errNo INT = ERROR_NUMBER();
    DECLARE @errLine INT = ERROR_LINE();
    RAISERROR('Seed failed [%d] at line %d: %s', 16, 1, @errNo, @errLine, @errMsg);
END CATCH;
GO
