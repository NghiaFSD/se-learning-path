USE project_SWP;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    PRINT '=== Seed multi-month dashboard data 2026: START ===';

    IF OBJECT_ID(N'dbo.Appointment', N'U') IS NULL
        THROW 52001, 'Missing table dbo.Appointment. Run base seed first.', 1;

    IF OBJECT_ID(N'dbo.Invoice', N'U') IS NULL
        THROW 52002, 'Missing table dbo.Invoice. Run base seed first.', 1;

    IF OBJECT_ID(N'dbo.Invoice_Detail', N'U') IS NULL
        THROW 52003, 'Missing table dbo.Invoice_Detail. Run base seed first.', 1;

    IF OBJECT_ID(N'dbo.Medical_record', N'U') IS NULL OR OBJECT_ID(N'dbo.Healthy_Record', N'U') IS NULL
        THROW 52004, 'Missing Medical_record/Healthy_Record.', 1;

    IF OBJECT_ID(N'dbo.Doctor', N'U') IS NULL OR OBJECT_ID(N'dbo.Patient', N'U') IS NULL
        THROW 52005, 'Missing Doctor/Patient.', 1;

    IF OBJECT_ID(N'dbo.Medical_Service', N'U') IS NULL
        THROW 52006, 'Missing Medical_Service.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'Khám nội tiết tổng quát' AND status = 'Active')
        INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
        VALUES (N'Khám nội tiết tổng quát', 150000, 'Examination', 'Active');

    IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'Xét nghiệm HbA1c' AND status = 'Active')
        INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
        VALUES (N'Xét nghiệm HbA1c', 350000, 'Lab_Test', 'Active');

    DECLARE @serviceExamId INT = (
        SELECT TOP 1 service_id FROM dbo.Medical_Service
        WHERE service_type = 'Examination' AND status = 'Active'
        ORDER BY service_id
    );

    DECLARE @serviceLabId INT = (
        SELECT TOP 1 service_id FROM dbo.Medical_Service
        WHERE service_type = 'Lab_Test' AND status = 'Active'
        ORDER BY service_id
    );

    IF @serviceExamId IS NULL OR @serviceLabId IS NULL
        THROW 52007, 'Need active Examination and Lab_Test services.', 1;

    IF OBJECT_ID('tempdb..#Doctors') IS NOT NULL DROP TABLE #Doctors;
    IF OBJECT_ID('tempdb..#Patients') IS NOT NULL DROP TABLE #Patients;
    IF OBJECT_ID('tempdb..#SeedPlan') IS NOT NULL DROP TABLE #SeedPlan;

    SELECT ROW_NUMBER() OVER (ORDER BY doctor_id) AS rn, doctor_id
    INTO #Doctors
    FROM dbo.Doctor;

    SELECT ROW_NUMBER() OVER (ORDER BY patient_id) AS rn, patient_id
    INTO #Patients
    FROM dbo.Patient;

    DECLARE @doctorPool INT = (SELECT COUNT(*) FROM #Doctors);
    DECLARE @patientPool INT = (SELECT COUNT(*) FROM #Patients);

    IF @doctorPool = 0 OR @patientPool = 0
        THROW 52008, 'Doctor/Patient pool empty.', 1;

    CREATE TABLE #SeedPlan (
        rn INT IDENTITY(1,1) PRIMARY KEY,
        appt_dt DATETIME NOT NULL,
        use_lab BIT NOT NULL
    );

    INSERT INTO #SeedPlan(appt_dt, use_lab)
    VALUES
    ('2026-02-10T08:15:00', 0),
    ('2026-02-18T14:20:00', 1),
    ('2026-03-05T09:10:00', 1),
    ('2026-03-12T10:45:00', 0),
    ('2026-03-27T15:30:00', 1),
    ('2026-04-03T08:40:00', 0),
    ('2026-04-11T11:00:00', 1),
    ('2026-04-19T14:35:00', 0),
    ('2026-04-26T16:10:00', 1),
    ('2026-05-04T08:30:00', 1),
    ('2026-05-10T09:50:00', 0),
    ('2026-05-16T13:20:00', 1),
    ('2026-05-22T15:05:00', 0),
    ('2026-05-29T10:15:00', 1),
    ('2026-07-03T08:20:00', 0),
    ('2026-07-09T09:40:00', 1),
    ('2026-07-17T14:10:00', 0),
    ('2026-07-24T16:25:00', 1),
    ('2026-08-06T09:05:00', 1),
    ('2026-08-15T10:55:00', 0);

    DECLARE @i INT = 1;
    DECLARE @maxI INT = (SELECT COUNT(*) FROM #SeedPlan);
    DECLARE @apptDT DATETIME;
    DECLARE @useLab BIT;
    DECLARE @doctorId INT;
    DECLARE @patientId INT;
    DECLARE @appointmentId INT;
    DECLARE @invoiceId INT;
    DECLARE @total DECIMAL(18,2);
    DECLARE @final DECIMAL(18,2);
    DECLARE @healthRecordId INT;

    WHILE @i <= @maxI
    BEGIN
        SELECT @apptDT = appt_dt, @useLab = use_lab FROM #SeedPlan WHERE rn = @i;
        SELECT @doctorId = doctor_id FROM #Doctors WHERE rn = ((@i - 1) % @doctorPool) + 1;
        SELECT @patientId = patient_id FROM #Patients WHERE rn = ((@i - 1) % @patientPool) + 1;

        SELECT TOP 1 @appointmentId = appointment_id
        FROM dbo.Appointment
        WHERE patient_id = @patientId
          AND doctor_id = @doctorId
          AND appointment_time = @apptDT
          AND status = 'Completed'
        ORDER BY appointment_id DESC;

        IF @appointmentId IS NULL
        BEGIN
            INSERT INTO dbo.Appointment(patient_id, doctor_id, appointment_time, created_at, status)
            VALUES (@patientId, @doctorId, @apptDT, DATEADD(MINUTE, -30, @apptDT), 'Completed');
            SET @appointmentId = CAST(SCOPE_IDENTITY() AS INT);
        END;

        SET @total = CASE WHEN @useLab = 1 THEN 500000 ELSE 150000 END;
        SET @final = @total;

        SELECT TOP 1 @invoiceId = invoice_id
        FROM dbo.Invoice
        WHERE appointment_id = @appointmentId AND status = 'Paid'
        ORDER BY invoice_id DESC;

        IF @invoiceId IS NULL
        BEGIN
            INSERT INTO dbo.Invoice(appointment_id, patient_id, total_amount, final_amount, status, created_at, exported_at)
            VALUES (@appointmentId, @patientId, @total, @final, 'Paid', DATEADD(MINUTE, 20, @apptDT), DATEADD(MINUTE, 25, @apptDT));
            SET @invoiceId = CAST(SCOPE_IDENTITY() AS INT);
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND service_id = @serviceExamId)
        BEGIN
            INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, quantity, unit_price, line_total)
            VALUES (@invoiceId, @serviceExamId, 1, 150000, 150000);
        END;

        IF @useLab = 1
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.Invoice_Detail WHERE invoice_id = @invoiceId AND service_id = @serviceLabId)
            BEGIN
                INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, quantity, unit_price, line_total)
                VALUES (@invoiceId, @serviceLabId, 1, 350000, 350000);
            END;
        END;

        SELECT TOP 1 @healthRecordId = health_record_id
        FROM dbo.Healthy_Record
        WHERE patient_id = @patientId
          AND doctor_id = @doctorId
          AND created_at = DATEADD(MINUTE, 22, @apptDT)
        ORDER BY health_record_id DESC;

        IF @healthRecordId IS NULL
        BEGIN
            INSERT INTO dbo.Healthy_Record(
                urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
                patient_id, weight, height, other_information, status, created_at, doctor_id
            )
            VALUES (
                6.8, 95.5, 7.2, 5.4, 1.8, 1.2, 3.0, 0.8, 24.1,
                @patientId, 68.5, 168.0,
                N'Seed multi-month 2026 for dashboard trend',
                N'Completed', DATEADD(MINUTE, 22, @apptDT), @doctorId
            );
            SET @healthRecordId = CAST(SCOPE_IDENTITY() AS INT);
        END;

        IF NOT EXISTS (SELECT 1 FROM dbo.Medical_record WHERE health_record_id = @healthRecordId)
        BEGIN
            INSERT INTO dbo.Medical_record(
                patient_id, doctor_id, final_diagnosis, doctor_note,
                health_record_id, result_visibility, processed_at
            )
            VALUES (
                @patientId, @doctorId,
                N'ĐTĐ type 2 theo dõi định kỳ',
                N'Dữ liệu mẫu đa tháng để kiểm thử biểu đồ xu hướng',
                @healthRecordId, 1, DATEADD(MINUTE, 25, @apptDT)
            );
        END;

        SET @appointmentId = NULL;
        SET @invoiceId = NULL;
        SET @healthRecordId = NULL;
        SET @i += 1;
    END;

    PRINT '--- Verify monthly trend in 2026 (Paid Revenue) ---';
    SELECT FORMAT(created_at, 'yyyy-MM') AS period, SUM(final_amount) AS paid_revenue
    FROM dbo.Invoice
    WHERE status = 'Paid'
      AND YEAR(created_at) = 2026
    GROUP BY FORMAT(created_at, 'yyyy-MM')
    ORDER BY period;

    PRINT '--- Verify monthly trend in 2026 (Completed Visits) ---';
    SELECT FORMAT(appointment_time, 'yyyy-MM') AS period, COUNT(*) AS completed_visits
    FROM dbo.Appointment
    WHERE status = 'Completed'
      AND YEAR(appointment_time) = 2026
    GROUP BY FORMAT(appointment_time, 'yyyy-MM')
    ORDER BY period;

    COMMIT TRAN;
    PRINT '=== Seed multi-month dashboard data 2026: DONE ===';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrLine INT = ERROR_LINE();
    DECLARE @ErrNo INT = ERROR_NUMBER();
    RAISERROR('Multi-month seed failed at line %d (error %d): %s', 16, 1, @ErrLine, @ErrNo, @ErrMsg);
END CATCH;
GO
