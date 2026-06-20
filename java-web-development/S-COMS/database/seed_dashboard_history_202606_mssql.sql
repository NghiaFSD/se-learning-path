USE project_SWP;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    PRINT '=== Seed Dashboard History 06/2026: START ===';

    /* --------------------------------------------------
       0) Ensure core tables exist (minimal compatible shape)
       -------------------------------------------------- */
    IF OBJECT_ID(N'dbo.Appointment', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Appointment (
            appointment_id INT IDENTITY(1,1) PRIMARY KEY,
            patient_id INT NOT NULL,
            doctor_id INT NULL,
            schedule_id INT NULL,
            appointment_time DATETIME NOT NULL,
            created_at DATETIME NOT NULL CONSTRAINT DF_Appointment_CreatedAt DEFAULT GETDATE(),
            status VARCHAR(20) NOT NULL CONSTRAINT DF_Appointment_Status DEFAULT 'Waiting'
        );
        PRINT 'Created table dbo.Appointment';
    END;

    IF OBJECT_ID(N'dbo.Invoice', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Invoice (
            invoice_id INT IDENTITY(1,1) PRIMARY KEY,
            appointment_id INT NULL,
            patient_id INT NULL,
            total_amount DECIMAL(18,2) NOT NULL CONSTRAINT DF_Invoice_Total DEFAULT 0,
            final_amount DECIMAL(18,2) NOT NULL CONSTRAINT DF_Invoice_Final DEFAULT 0,
            status VARCHAR(20) NOT NULL CONSTRAINT DF_Invoice_Status DEFAULT 'Pending',
            created_at DATETIME NOT NULL CONSTRAINT DF_Invoice_CreatedAt DEFAULT GETDATE(),
            exported_at DATETIME NULL
        );
        PRINT 'Created table dbo.Invoice';
    END;

    IF OBJECT_ID(N'dbo.Invoice_Detail', N'U') IS NULL
    BEGIN
        CREATE TABLE dbo.Invoice_Detail (
            invoice_detail_id INT IDENTITY(1,1) PRIMARY KEY,
            invoice_id INT NOT NULL,
            service_id INT NOT NULL,
            quantity INT NOT NULL CONSTRAINT DF_Invoice_Detail_Qty DEFAULT 1,
            unit_price DECIMAL(18,2) NOT NULL,
            line_total DECIMAL(18,2) NOT NULL
        );
        PRINT 'Created table dbo.Invoice_Detail';
    END;

    /* --------------------------------------------------
       1) Ensure report-compatible columns exist
       -------------------------------------------------- */
    IF COL_LENGTH('dbo.Appointment', 'created_at') IS NULL
        ALTER TABLE dbo.Appointment ADD created_at DATETIME NOT NULL CONSTRAINT DF_Appointment_CreatedAt_Seed DEFAULT GETDATE();

    IF COL_LENGTH('dbo.Appointment', 'appointment_time') IS NULL
        ALTER TABLE dbo.Appointment ADD appointment_time DATETIME NOT NULL CONSTRAINT DF_Appointment_Time_Seed DEFAULT GETDATE();

    IF COL_LENGTH('dbo.Appointment', 'status') IS NULL
        ALTER TABLE dbo.Appointment ADD status VARCHAR(20) NOT NULL CONSTRAINT DF_Appointment_Status_Seed DEFAULT 'Waiting';

    IF COL_LENGTH('dbo.Appointment', 'patient_id') IS NULL
        ALTER TABLE dbo.Appointment ADD patient_id INT NULL;

    IF COL_LENGTH('dbo.Appointment', 'doctor_id') IS NULL
        ALTER TABLE dbo.Appointment ADD doctor_id INT NULL;

    IF COL_LENGTH('dbo.Invoice', 'final_amount') IS NULL
        ALTER TABLE dbo.Invoice ADD final_amount DECIMAL(18,2) NOT NULL CONSTRAINT DF_Invoice_Final_Seed DEFAULT 0;

    IF COL_LENGTH('dbo.Invoice', 'total_amount') IS NULL
        ALTER TABLE dbo.Invoice ADD total_amount DECIMAL(18,2) NOT NULL CONSTRAINT DF_Invoice_Total_Seed DEFAULT 0;

    IF COL_LENGTH('dbo.Invoice', 'status') IS NULL
        ALTER TABLE dbo.Invoice ADD status VARCHAR(20) NOT NULL CONSTRAINT DF_Invoice_Status_Seed DEFAULT 'Pending';

    IF COL_LENGTH('dbo.Invoice', 'created_at') IS NULL
        ALTER TABLE dbo.Invoice ADD created_at DATETIME NOT NULL CONSTRAINT DF_Invoice_CreatedAt_Seed DEFAULT GETDATE();

    IF COL_LENGTH('dbo.Invoice', 'exported_at') IS NULL
        ALTER TABLE dbo.Invoice ADD exported_at DATETIME NULL;

    IF COL_LENGTH('dbo.Invoice', 'appointment_id') IS NULL
        ALTER TABLE dbo.Invoice ADD appointment_id INT NULL;

    IF COL_LENGTH('dbo.Invoice', 'patient_id') IS NULL
        ALTER TABLE dbo.Invoice ADD patient_id INT NULL;

    IF COL_LENGTH('dbo.Invoice_Detail', 'quantity') IS NULL
        ALTER TABLE dbo.Invoice_Detail ADD quantity INT NOT NULL CONSTRAINT DF_Invoice_Detail_Qty_Seed DEFAULT 1;

    IF COL_LENGTH('dbo.Invoice_Detail', 'unit_price') IS NULL
        ALTER TABLE dbo.Invoice_Detail ADD unit_price DECIMAL(18,2) NOT NULL CONSTRAINT DF_Invoice_Detail_Price_Seed DEFAULT 0;

    IF COL_LENGTH('dbo.Invoice_Detail', 'line_total') IS NULL
        ALTER TABLE dbo.Invoice_Detail ADD line_total DECIMAL(18,2) NOT NULL CONSTRAINT DF_Invoice_Detail_Line_Seed DEFAULT 0;

    /* --------------------------------------------------
       2) Ensure master data: active service + patient + doctor
       -------------------------------------------------- */
    IF OBJECT_ID(N'dbo.Medical_Service', N'U') IS NOT NULL
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'Khám nội tiết tổng quát' AND status = 'Active')
            INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
            VALUES (N'Khám nội tiết tổng quát', 150000, 'Examination', 'Active');

        IF NOT EXISTS (SELECT 1 FROM dbo.Medical_Service WHERE service_name = N'Xét nghiệm HbA1c' AND status = 'Active')
            INSERT INTO dbo.Medical_Service(service_name, price, service_type, status)
            VALUES (N'Xét nghiệm HbA1c', 350000, 'Lab_Test', 'Active');
    END;

    DECLARE @DoctorCount INT = (SELECT COUNT(*) FROM dbo.Doctor);
    DECLARE @PatientCount INT = (SELECT COUNT(*) FROM dbo.Patient);

    IF @DoctorCount = 0
    BEGIN
        DECLARE @doctorAccountId INT;
        IF OBJECT_ID(N'dbo.Account', N'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'seed.doctor.202606@scoms.local')
            BEGIN
                INSERT INTO dbo.Account(full_name, email, password_hash, role, status)
                VALUES (N'Seed Doctor 202606', 'seed.doctor.202606@scoms.local', REPLICATE('d', 64), 'doctor', 'active');
            END;
            SELECT @doctorAccountId = account_id FROM dbo.Account WHERE email = 'seed.doctor.202606@scoms.local';
        END;

        INSERT INTO dbo.Doctor(full_name, phone, email, department, account_id)
        VALUES (N'BS Seed Nội tiết 202606', '0909000001', 'seed.doctor.202606@scoms.local', N'Endocrinology', @doctorAccountId);
    END;

    IF @PatientCount = 0
    BEGIN
        DECLARE @patientAccountId INT;
        IF OBJECT_ID(N'dbo.Account', N'U') IS NOT NULL
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.Account WHERE email = 'seed.patient.202606@scoms.local')
            BEGIN
                INSERT INTO dbo.Account(full_name, email, password_hash, role, status)
                VALUES (N'Seed Patient 202606', 'seed.patient.202606@scoms.local', REPLICATE('p', 64), 'patient', 'active');
            END;
            SELECT @patientAccountId = account_id FROM dbo.Account WHERE email = 'seed.patient.202606@scoms.local';
        END;

        INSERT INTO dbo.Patient(full_name, date_of_birth, gender, phone, email, address, account_id)
        VALUES (N'Bệnh nhân Seed 202606', '1990-06-15', N'Nam', '0911000001', 'seed.patient.202606@scoms.local', N'Hà Nội', @patientAccountId);
    END;

    /* --------------------------------------------------
       3) Build source pools and seed 18 completed appointments
       -------------------------------------------------- */
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
        THROW 51010, 'Missing active Medical_Service records for Examination/Lab_Test.', 1;

    IF OBJECT_ID('tempdb..#Doctors') IS NOT NULL DROP TABLE #Doctors;
    IF OBJECT_ID('tempdb..#Patients') IS NOT NULL DROP TABLE #Patients;

    SELECT ROW_NUMBER() OVER (ORDER BY doctor_id) AS rn, doctor_id
    INTO #Doctors
    FROM dbo.Doctor;

    SELECT ROW_NUMBER() OVER (ORDER BY patient_id) AS rn, patient_id
    INTO #Patients
    FROM dbo.Patient;

    DECLARE @doctorPool INT = (SELECT COUNT(*) FROM #Doctors);
    DECLARE @patientPool INT = (SELECT COUNT(*) FROM #Patients);

    IF @doctorPool = 0 OR @patientPool = 0
        THROW 51011, 'Doctor/Patient pool is empty, cannot seed appointments.', 1;

    IF OBJECT_ID('tempdb..#SeedSlots') IS NOT NULL DROP TABLE #SeedSlots;
    CREATE TABLE #SeedSlots (
        rn INT PRIMARY KEY,
        slot_dt DATETIME NOT NULL
    );

    INSERT INTO #SeedSlots(rn, slot_dt)
    VALUES
    (1 , '2026-06-13T08:00:00'),
    (2 , '2026-06-13T10:30:00'),
    (3 , '2026-06-14T09:15:00'),
    (4 , '2026-06-14T14:10:00'),
    (5 , '2026-06-15T08:40:00'),
    (6 , '2026-06-15T10:50:00'),
    (7 , '2026-06-15T15:20:00'),
    (8 , '2026-06-16T08:25:00'),
    (9 , '2026-06-16T11:05:00'),
    (10, '2026-06-16T16:30:00'),
    (11, '2026-06-17T09:00:00'),
    (12, '2026-06-17T13:40:00'),
    (13, '2026-06-17T17:10:00'),
    (14, '2026-06-18T08:10:00'),
    (15, '2026-06-18T10:45:00'),
    (16, '2026-06-18T15:55:00'),
    (17, '2026-06-19T09:20:00'),
    (18, '2026-06-19T14:35:00');

    IF OBJECT_ID('tempdb..#InsertedAppointments') IS NOT NULL DROP TABLE #InsertedAppointments;
    CREATE TABLE #InsertedAppointments (
        rn INT NOT NULL,
        appointment_id INT NOT NULL,
        patient_id INT NOT NULL,
        doctor_id INT NULL,
        appt_dt DATETIME NOT NULL
    );

    DECLARE @i INT = 1;
    DECLARE @doctorId INT;
    DECLARE @patientId INT;
    DECLARE @apptDT DATETIME;
    DECLARE @sqlApp NVARCHAR(MAX);
    DECLARE @NewAppointment TABLE (appointment_id INT);

    WHILE @i <= 18
    BEGIN
        SELECT @doctorId = doctor_id FROM #Doctors WHERE rn = ((@i - 1) % @doctorPool) + 1;
        SELECT @patientId = patient_id FROM #Patients WHERE rn = ((@i - 1) % @patientPool) + 1;
        SELECT @apptDT = slot_dt FROM #SeedSlots WHERE rn = @i;

        SET @sqlApp = N'INSERT INTO dbo.Appointment ('
            + N'patient_id'
            + CASE WHEN COL_LENGTH('dbo.Appointment', 'doctor_id') IS NOT NULL THEN N', doctor_id' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Appointment', 'appointment_time') IS NOT NULL THEN N', appointment_time' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Appointment', 'created_at') IS NOT NULL THEN N', created_at' ELSE N'' END
            + N', status) VALUES ('
            + N'@p_patient_id'
            + CASE WHEN COL_LENGTH('dbo.Appointment', 'doctor_id') IS NOT NULL THEN N', @p_doctor_id' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Appointment', 'appointment_time') IS NOT NULL THEN N', @p_appt_dt' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Appointment', 'created_at') IS NOT NULL THEN N', DATEADD(MINUTE, -35, @p_appt_dt)' ELSE N'' END
            + N', ''Completed'');';

        EXEC sp_executesql
            @sqlApp,
            N'@p_patient_id INT, @p_doctor_id INT, @p_appt_dt DATETIME',
            @p_patient_id = @patientId,
            @p_doctor_id = @doctorId,
            @p_appt_dt = @apptDT;

                DELETE FROM @NewAppointment;
                INSERT INTO @NewAppointment(appointment_id)
                SELECT TOP 1 appointment_id
                FROM dbo.Appointment
                WHERE patient_id = @patientId
                    AND status = 'Completed'
                    AND appointment_time = @apptDT
                ORDER BY appointment_id DESC;

                IF NOT EXISTS (SELECT 1 FROM @NewAppointment)
                        THROW 51012, 'Could not resolve inserted appointment_id during seed.', 1;

        INSERT INTO #InsertedAppointments(rn, appointment_id, patient_id, doctor_id, appt_dt)
                SELECT @i, appointment_id, @patientId, @doctorId, @apptDT
                FROM @NewAppointment;

        SET @i += 1;
    END;

    /* --------------------------------------------------
       4) Create paid invoices + invoice detail per completed appointment
       -------------------------------------------------- */
    IF OBJECT_ID('tempdb..#InsertedInvoices') IS NOT NULL DROP TABLE #InsertedInvoices;
    CREATE TABLE #InsertedInvoices (
        appointment_id INT NOT NULL,
        invoice_id INT NOT NULL
    );

    DECLARE @apptId INT;
    DECLARE @ptId INT;
    DECLARE @apDT DATETIME;
    DECLARE @total DECIMAL(18,2);
    DECLARE @final DECIMAL(18,2);
    DECLARE @useLab BIT;
    DECLARE @invoiceId INT;
    DECLARE @sqlInv NVARCHAR(MAX);
    DECLARE @NewInvoice TABLE (invoice_id INT);

    DECLARE c_appt CURSOR LOCAL FAST_FORWARD FOR
        SELECT appointment_id, patient_id, appt_dt
        FROM #InsertedAppointments
        ORDER BY rn;

    OPEN c_appt;
    FETCH NEXT FROM c_appt INTO @apptId, @ptId, @apDT;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @useLab = CASE WHEN (@apptId % 3) IN (0,1) THEN 1 ELSE 0 END;
        SET @total = CASE WHEN @useLab = 1 THEN 500000 ELSE 150000 END;
        SET @final = CASE WHEN @useLab = 1 THEN 500000 ELSE 150000 END;

        SET @sqlInv = N'INSERT INTO dbo.Invoice ('
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'appointment_id') IS NOT NULL THEN N'appointment_id, ' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'patient_id') IS NOT NULL THEN N'patient_id, ' ELSE N'' END
            + N'total_amount, final_amount, status'
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'created_at') IS NOT NULL THEN N', created_at' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'exported_at') IS NOT NULL THEN N', exported_at' ELSE N'' END
            + N') VALUES ('
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'appointment_id') IS NOT NULL THEN N'@p_appt_id, ' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'patient_id') IS NOT NULL THEN N'@p_patient_id, ' ELSE N'' END
            + N'@p_total, @p_final, ''Paid'''
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'created_at') IS NOT NULL THEN N', DATEADD(MINUTE, 20, @p_appt_dt)' ELSE N'' END
            + CASE WHEN COL_LENGTH('dbo.Invoice', 'exported_at') IS NOT NULL THEN N', DATEADD(MINUTE, 25, @p_appt_dt)' ELSE N'' END
            + N');';

        EXEC sp_executesql
            @sqlInv,
            N'@p_appt_id INT, @p_patient_id INT, @p_total DECIMAL(18,2), @p_final DECIMAL(18,2), @p_appt_dt DATETIME',
            @p_appt_id = @apptId,
            @p_patient_id = @ptId,
            @p_total = @total,
            @p_final = @final,
            @p_appt_dt = @apDT;

                DELETE FROM @NewInvoice;
                INSERT INTO @NewInvoice(invoice_id)
                SELECT TOP 1 invoice_id
                FROM dbo.Invoice
                WHERE status = 'Paid'
                    AND final_amount = @final
                    AND created_at = DATEADD(MINUTE, 20, @apDT)
                    AND (@apptId IS NULL OR appointment_id = @apptId OR appointment_id IS NULL)
                ORDER BY invoice_id DESC;

                SELECT TOP 1 @invoiceId = invoice_id FROM @NewInvoice;
                IF @invoiceId IS NULL
                    THROW 51013, 'Could not resolve inserted invoice_id during seed.', 1;
        INSERT INTO #InsertedInvoices(appointment_id, invoice_id) VALUES (@apptId, @invoiceId);

        INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, quantity, unit_price, line_total)
        VALUES (@invoiceId, @serviceExamId, 1, 150000, 150000);

        IF @useLab = 1
        BEGIN
            INSERT INTO dbo.Invoice_Detail(invoice_id, service_id, quantity, unit_price, line_total)
            VALUES (@invoiceId, @serviceLabId, 1, 350000, 350000);
        END;

        FETCH NEXT FROM c_appt INTO @apptId, @ptId, @apDT;
    END;
    CLOSE c_appt;
    DEALLOCATE c_appt;

    /* --------------------------------------------------
       5) Create Medical_record + Healthy_Record 1-1 per appointment
       -------------------------------------------------- */
    DECLARE @healthRecordId INT;
    DECLARE @docId INT;

    DECLARE c_mr CURSOR LOCAL FAST_FORWARD FOR
        SELECT ia.appointment_id, ia.patient_id, ia.doctor_id, ia.appt_dt
        FROM #InsertedAppointments ia
        ORDER BY ia.rn;

    OPEN c_mr;
    FETCH NEXT FROM c_mr INTO @apptId, @ptId, @docId, @apDT;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        INSERT INTO dbo.Healthy_Record(
            urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
            patient_id, weight, height, other_information, status, created_at, doctor_id
        )
        VALUES (
            6.8, 95.5, 7.2, 5.4, 1.8, 1.2, 3.0, 0.8, 24.1,
            @ptId, 68.5, 168.0,
            N'Seed 06/2026: completed visit for dashboard + AI flow validation',
            N'Completed', DATEADD(MINUTE, 22, @apDT), @docId
        );

        SET @healthRecordId = CAST(SCOPE_IDENTITY() AS INT);

        INSERT INTO dbo.Medical_record(
            patient_id, doctor_id, final_diagnosis, doctor_note,
            health_record_id, result_visibility, processed_at
        )
        VALUES (
            @ptId, @docId,
            N'ĐTĐ type 2 kiểm soát trung bình',
            N'Khuyến nghị duy trì ăn giảm đường và tái khám sau 4 tuần',
            @healthRecordId, 1, DATEADD(MINUTE, 25, @apDT)
        );

        FETCH NEXT FROM c_mr INTO @apptId, @ptId, @docId, @apDT;
    END;
    CLOSE c_mr;
    DEALLOCATE c_mr;

    /* --------------------------------------------------
       6) Verification output for quick checks
       -------------------------------------------------- */
    PRINT '--- Verification: Completed Appointments by day (13-19/06/2026) ---';
    SELECT CAST(appointment_time AS DATE) AS visit_date, COUNT(*) AS completed_visits
    FROM dbo.Appointment
    WHERE status = 'Completed'
      AND appointment_time >= '2026-06-13' AND appointment_time < '2026-06-20'
    GROUP BY CAST(appointment_time AS DATE)
    ORDER BY visit_date;

    PRINT '--- Verification: Paid Revenue by day (13-19/06/2026) ---';
    SELECT CAST(created_at AS DATE) AS revenue_date, SUM(final_amount) AS total_paid_revenue
    FROM dbo.Invoice
    WHERE status = 'Paid'
      AND created_at >= '2026-06-13' AND created_at < '2026-06-20'
    GROUP BY CAST(created_at AS DATE)
    ORDER BY revenue_date;

    PRINT '--- Verification: Inserted rows snapshot ---';
    SELECT
        (SELECT COUNT(*) FROM #InsertedAppointments) AS inserted_appointments,
        (SELECT COUNT(*) FROM #InsertedInvoices) AS inserted_invoices,
        (SELECT COUNT(*) FROM dbo.Invoice_Detail idt JOIN #InsertedInvoices ii ON ii.invoice_id = idt.invoice_id) AS inserted_invoice_details;

    COMMIT TRAN;
    PRINT '=== Seed Dashboard History 06/2026: DONE ===';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    PRINT '=== Seed Dashboard History 06/2026: FAILED ===';
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrLine INT = ERROR_LINE();
    DECLARE @ErrNo INT = ERROR_NUMBER();
    RAISERROR('Seed failed at line %d (error %d): %s', 16, 1, @ErrLine, @ErrNo, @ErrMsg);
END CATCH;
GO
