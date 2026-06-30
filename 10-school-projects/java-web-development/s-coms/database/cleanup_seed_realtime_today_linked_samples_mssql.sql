USE [Project_SWP];
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    CREATE TABLE #SeedPatients (
        patient_id INT NOT NULL PRIMARY KEY,
        account_id INT NULL,
        email NVARCHAR(255) NOT NULL
    );

    INSERT INTO #SeedPatients (patient_id, account_id, email)
    SELECT p.patient_id, p.account_id, p.email
    FROM dbo.Patient p
    WHERE p.email LIKE 'seed.today.%';

    IF NOT EXISTS (SELECT 1 FROM #SeedPatients)
    BEGIN
        PRINT N'[SKIP] No synthetic seed patients found.';
        COMMIT TRAN;
        SELECT 'seed_patients' AS metric, 0 AS val;
        RETURN;
    END;

    CREATE TABLE #SeedPatientIds (
        patient_id INT NOT NULL PRIMARY KEY
    );

    INSERT INTO #SeedPatientIds (patient_id)
    SELECT patient_id FROM #SeedPatients;

    CREATE TABLE #SeedInvoices (
        invoice_id INT NOT NULL PRIMARY KEY
    );

    INSERT INTO #SeedInvoices (invoice_id)
    SELECT i.invoice_id
    FROM dbo.Invoice i
    WHERE i.patient_id IN (SELECT patient_id FROM #SeedPatientIds);

    CREATE TABLE #SeedAppointments (
        appointment_id INT NOT NULL PRIMARY KEY
    );

    INSERT INTO #SeedAppointments (appointment_id)
    SELECT a.appointment_id
    FROM dbo.Appointment a
    WHERE a.patient_id IN (SELECT patient_id FROM #SeedPatientIds);

    CREATE TABLE #SeedHealthRecords (
        health_record_id INT NOT NULL PRIMARY KEY
    );

    INSERT INTO #SeedHealthRecords (health_record_id)
    SELECT hr.health_record_id
    FROM dbo.Healthy_Record hr
    WHERE hr.patient_id IN (SELECT patient_id FROM #SeedPatientIds);

    IF EXISTS (SELECT 1 FROM #SeedHealthRecords)
    BEGIN
        DELETE rth
        FROM dbo.Record_Transfer_History rth
        JOIN #SeedHealthRecords shr ON shr.health_record_id = rth.health_record_id;
    END;

    IF EXISTS (SELECT 1 FROM #SeedInvoices)
    BEGIN
        DELETE id
        FROM dbo.Invoice_Detail id
        JOIN #SeedInvoices si ON si.invoice_id = id.invoice_id;

        DELETE i
        FROM dbo.Invoice i
        JOIN #SeedInvoices si ON si.invoice_id = i.invoice_id;
    END;

    IF EXISTS (SELECT 1 FROM #SeedHealthRecords)
    BEGIN
        DELETE hr
        FROM dbo.Healthy_Record hr
        JOIN #SeedHealthRecords shr ON shr.health_record_id = hr.health_record_id;
    END;

    IF EXISTS (SELECT 1 FROM #SeedAppointments)
    BEGIN
        DELETE mr
        FROM dbo.Medical_record mr
        JOIN #SeedAppointments sa ON sa.appointment_id = mr.appointment_id;

        DELETE a
        FROM dbo.Appointment a
        JOIN #SeedAppointments sa ON sa.appointment_id = a.appointment_id;
    END;

    DELETE p
    FROM dbo.Patient p
    JOIN #SeedPatientIds sp ON sp.patient_id = p.patient_id;

    DELETE a
    FROM dbo.Account a
    JOIN #SeedPatients sp ON sp.account_id = a.account_id
    WHERE sp.account_id IS NOT NULL;

    COMMIT TRAN;

    SELECT 'seed_patients_deleted' AS metric, COUNT(*) AS val FROM #SeedPatients
    UNION ALL SELECT 'seed_appointments_deleted', COUNT(*) FROM #SeedAppointments
    UNION ALL SELECT 'seed_invoices_deleted', COUNT(*) FROM #SeedInvoices
    UNION ALL SELECT 'seed_health_records_deleted', COUNT(*) FROM #SeedHealthRecords;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRAN;

    THROW;
END CATCH;
