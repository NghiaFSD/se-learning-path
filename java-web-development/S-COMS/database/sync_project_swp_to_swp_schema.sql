USE [project_SWP];
GO

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_PADDING ON;
SET ANSI_WARNINGS ON;
SET CONCAT_NULL_YIELDS_NULL ON;
SET ARITHABORT ON;
SET NUMERIC_ROUNDABORT OFF;
GO

/* ============================================================================
   Data-safe schema sync from database/SWP .sql to current project_SWP database.
   This script is intentionally additive/idempotent:
   - Adds missing tables/columns/defaults/indexes/foreign keys where possible.
   - Preserves existing data and legacy compatibility columns.
   - Uses WITH NOCHECK for foreign keys that can be affected by old seed data.
   ============================================================================ */

/* ---------------------------------------------------------------------------
   Appointment
--------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.Appointment', 'conversation_id') IS NULL
    ALTER TABLE dbo.Appointment ADD conversation_id INT NULL;
GO

IF COL_LENGTH('dbo.Appointment', 'booking_type') IS NULL
BEGIN
    EXEC('ALTER TABLE dbo.Appointment ADD booking_type VARCHAR(20) NULL');
    EXEC('UPDATE dbo.Appointment SET booking_type = ''Online'' WHERE booking_type IS NULL');
    EXEC('ALTER TABLE dbo.Appointment ALTER COLUMN booking_type VARCHAR(20) NOT NULL');
END
GO

IF COL_LENGTH('dbo.Appointment', 'queue_number') IS NULL
BEGIN
    EXEC('ALTER TABLE dbo.Appointment ADD queue_number INT NULL');

    EXEC('
    ;WITH q AS (
        SELECT appointment_id,
               ROW_NUMBER() OVER (
                   PARTITION BY ISNULL(schedule_id, -1)
                   ORDER BY appointment_time ASC, appointment_id ASC
               ) AS rn
        FROM dbo.Appointment
    )
    UPDATE ap
       SET queue_number = q.rn
    FROM dbo.Appointment ap
    JOIN q ON q.appointment_id = ap.appointment_id
    WHERE ap.queue_number IS NULL;
    ');

    EXEC('ALTER TABLE dbo.Appointment ALTER COLUMN queue_number INT NOT NULL');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_Appointment_BookingType')
    ALTER TABLE dbo.Appointment ADD CONSTRAINT DF_Appointment_BookingType DEFAULT ('Online') FOR booking_type;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Appointment_BookingType')
    ALTER TABLE dbo.Appointment WITH NOCHECK ADD CONSTRAINT CK_Appointment_BookingType CHECK (booking_type IN ('At_Counter', 'Online'));
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Appointment_QueueNumber')
    ALTER TABLE dbo.Appointment WITH NOCHECK ADD CONSTRAINT CK_Appointment_QueueNumber CHECK (queue_number > 0);
GO

/* ---------------------------------------------------------------------------
   Healthy_Record
--------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.Healthy_Record', 'idl') IS NULL
    ALTER TABLE dbo.Healthy_Record ADD idl DECIMAL(5,2) NULL;
GO

IF COL_LENGTH('dbo.Healthy_Record', 'record_id') IS NULL
    ALTER TABLE dbo.Healthy_Record ADD record_id INT NULL;
GO

IF COL_LENGTH('dbo.Healthy_Record', 'invoice_detail_id') IS NULL
    ALTER TABLE dbo.Healthy_Record ADD invoice_detail_id INT NULL;
GO

IF COL_LENGTH('dbo.Healthy_Record', 'is_synced_automatically') IS NULL
BEGIN
    EXEC('ALTER TABLE dbo.Healthy_Record ADD is_synced_automatically BIT NULL');
    EXEC('UPDATE dbo.Healthy_Record SET is_synced_automatically = 1 WHERE is_synced_automatically IS NULL');
    EXEC('ALTER TABLE dbo.Healthy_Record ALTER COLUMN is_synced_automatically BIT NOT NULL');
END
GO

IF COL_LENGTH('dbo.Healthy_Record', 'synced_at') IS NULL
    ALTER TABLE dbo.Healthy_Record ADD synced_at DATETIME NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_HealthyRecord_AutoSync')
    ALTER TABLE dbo.Healthy_Record ADD CONSTRAINT DF_HealthyRecord_AutoSync DEFAULT ((1)) FOR is_synced_automatically;
GO

/* ---------------------------------------------------------------------------
   Invoice
--------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.Invoice', 'receptionist_id') IS NULL
    ALTER TABLE dbo.Invoice ADD receptionist_id INT NULL;
GO

IF COL_LENGTH('dbo.Invoice', 'insurance_deduction') IS NULL
BEGIN
    EXEC('ALTER TABLE dbo.Invoice ADD insurance_deduction DECIMAL(18,2) NULL');
    EXEC('UPDATE dbo.Invoice SET insurance_deduction = 0 WHERE insurance_deduction IS NULL');
    EXEC('ALTER TABLE dbo.Invoice ALTER COLUMN insurance_deduction DECIMAL(18,2) NOT NULL');
END
GO

IF COL_LENGTH('dbo.Invoice', 'payment_method') IS NULL
    ALTER TABLE dbo.Invoice ADD payment_method VARCHAR(20) NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.default_constraints WHERE name = 'DF_Invoice_Insurance')
    ALTER TABLE dbo.Invoice ADD CONSTRAINT DF_Invoice_Insurance DEFAULT ((0)) FOR insurance_deduction;
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Invoice_PaymentMethod')
    ALTER TABLE dbo.Invoice WITH NOCHECK ADD CONSTRAINT CK_Invoice_PaymentMethod CHECK (
        payment_method IS NULL OR payment_method IN ('Bank_Transfer', 'VNPay', 'Momo', 'Cash')
    );
GO

/* ---------------------------------------------------------------------------
   Invoice_Detail
--------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.Invoice_Detail', 'appointment_id') IS NULL
BEGIN
    EXEC('ALTER TABLE dbo.Invoice_Detail ADD appointment_id INT NULL');

    IF COL_LENGTH('dbo.Invoice', 'appointment_id') IS NOT NULL
    BEGIN
        EXEC('
        UPDATE idt
           SET appointment_id = i.appointment_id
        FROM dbo.Invoice_Detail idt
        JOIN dbo.Invoice i ON i.invoice_id = idt.invoice_id
        WHERE idt.appointment_id IS NULL
          AND i.appointment_id IS NOT NULL;
        ');
    END

    EXEC('
    UPDATE idt
       SET appointment_id = (
           SELECT TOP 1 ap.appointment_id
           FROM dbo.Invoice i
           JOIN dbo.Appointment ap ON ap.patient_id = i.patient_id
           WHERE i.invoice_id = idt.invoice_id
           ORDER BY ABS(DATEDIFF(MINUTE, ap.appointment_time, i.created_at)), ap.appointment_id
    )
    FROM dbo.Invoice_Detail idt
    WHERE idt.appointment_id IS NULL;
    ');

    EXEC('
    UPDATE dbo.Invoice_Detail
       SET appointment_id = (SELECT TOP 1 appointment_id FROM dbo.Appointment ORDER BY appointment_id)
    WHERE appointment_id IS NULL
      AND EXISTS (SELECT 1 FROM dbo.Appointment);
    ');

    IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('dbo.Invoice_Detail') AND name = 'appointment_id')
    BEGIN
        DECLARE @missingAppointmentIdCount INT = 0;
        EXEC sp_executesql
            N'SELECT @countOut = COUNT(*) FROM dbo.Invoice_Detail WHERE appointment_id IS NULL',
            N'@countOut INT OUTPUT',
            @countOut = @missingAppointmentIdCount OUTPUT;

        IF @missingAppointmentIdCount = 0
            EXEC('ALTER TABLE dbo.Invoice_Detail ALTER COLUMN appointment_id INT NOT NULL');
    END
END
GO

IF COL_LENGTH('dbo.Invoice_Detail', 'price') IS NULL
BEGIN
    EXEC('ALTER TABLE dbo.Invoice_Detail ADD price DECIMAL(18,2) NULL');

    IF COL_LENGTH('dbo.Invoice_Detail', 'unit_price') IS NOT NULL
        EXEC('UPDATE dbo.Invoice_Detail SET price = unit_price WHERE price IS NULL');

    IF COL_LENGTH('dbo.Invoice_Detail', 'line_total') IS NOT NULL
        EXEC('
        UPDATE dbo.Invoice_Detail
           SET price = CASE WHEN quantity > 0 THEN line_total / quantity ELSE line_total END
         WHERE price IS NULL;
        ');

    EXEC('UPDATE dbo.Invoice_Detail SET price = 0 WHERE price IS NULL');
    EXEC('ALTER TABLE dbo.Invoice_Detail ALTER COLUMN price DECIMAL(18,2) NOT NULL');
END
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_InvoiceDetail_Price')
    EXEC('ALTER TABLE dbo.Invoice_Detail WITH NOCHECK ADD CONSTRAINT CK_InvoiceDetail_Price CHECK (price >= 0)');
GO

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_InvoiceDetail_Quantity')
    EXEC('ALTER TABLE dbo.Invoice_Detail WITH NOCHECK ADD CONSTRAINT CK_InvoiceDetail_Quantity CHECK (quantity > 0)');
GO

/* ---------------------------------------------------------------------------
   Medical_record
--------------------------------------------------------------------------- */
IF COL_LENGTH('dbo.Medical_record', 'appointment_id') IS NULL
    ALTER TABLE dbo.Medical_record ADD appointment_id INT NULL;
GO

/* ---------------------------------------------------------------------------
   Record_Transfer_History
--------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.Record_Transfer_History', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.Record_Transfer_History (
        transfer_id INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
        health_record_id INT NOT NULL,
        from_doctor_id INT NOT NULL,
        to_doctor_id INT NOT NULL,
        reason NVARCHAR(500) NULL,
        created_at DATETIME NOT NULL CONSTRAINT DF_RecordTransferHistory_CreatedAt DEFAULT (GETDATE())
    );
END
GO

/* ---------------------------------------------------------------------------
   Indexes from SWP.sql
--------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Account_Email' AND object_id = OBJECT_ID('dbo.Account'))
AND NOT EXISTS (
    SELECT email FROM dbo.Account WHERE email IS NOT NULL GROUP BY email HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_Account_Email ON dbo.Account(email);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Appointment_DoctorTime' AND object_id = OBJECT_ID('dbo.Appointment'))
    CREATE NONCLUSTERED INDEX IX_Appointment_DoctorTime ON dbo.Appointment(doctor_id, appointment_time);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Appointment_Patient' AND object_id = OBJECT_ID('dbo.Appointment'))
    CREATE NONCLUSTERED INDEX IX_Appointment_Patient ON dbo.Appointment(patient_id, created_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Appointment_Queue' AND object_id = OBJECT_ID('dbo.Appointment'))
AND NOT EXISTS (
    SELECT schedule_id, queue_number
    FROM dbo.Appointment
    WHERE schedule_id IS NOT NULL AND queue_number IS NOT NULL
    GROUP BY schedule_id, queue_number
    HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_Appointment_Queue ON dbo.Appointment(schedule_id, queue_number);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Doctor_Account' AND object_id = OBJECT_ID('dbo.Doctor'))
AND NOT EXISTS (
    SELECT account_id FROM dbo.Doctor WHERE account_id IS NOT NULL GROUP BY account_id HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_Doctor_Account ON dbo.Doctor(account_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorAI_HealthRecord' AND object_id = OBJECT_ID('dbo.Doctor_AI'))
AND NOT EXISTS (
    SELECT health_record_id FROM dbo.Doctor_AI WHERE health_record_id IS NOT NULL GROUP BY health_record_id HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_DoctorAI_HealthRecord ON dbo.Doctor_AI(health_record_id) WHERE health_record_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_DoctorSchedule_Slot' AND object_id = OBJECT_ID('dbo.Doctor_Schedule'))
AND NOT EXISTS (
    SELECT doctor_id, work_date, time_slot
    FROM dbo.Doctor_Schedule
    GROUP BY doctor_id, work_date, time_slot
    HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_DoctorSchedule_Slot ON dbo.Doctor_Schedule(doctor_id, work_date, time_slot);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_HealthyRecord_InvoiceDetail' AND object_id = OBJECT_ID('dbo.Healthy_Record'))
AND NOT EXISTS (
    SELECT invoice_detail_id FROM dbo.Healthy_Record WHERE invoice_detail_id IS NOT NULL GROUP BY invoice_detail_id HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_HealthyRecord_InvoiceDetail ON dbo.Healthy_Record(invoice_detail_id) WHERE invoice_detail_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Invoice_PatientStatus' AND object_id = OBJECT_ID('dbo.Invoice'))
    CREATE NONCLUSTERED INDEX IX_Invoice_PatientStatus ON dbo.Invoice(patient_id, status, created_at DESC);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_InvoiceDetail_Appointment' AND object_id = OBJECT_ID('dbo.Invoice_Detail'))
    CREATE NONCLUSTERED INDEX IX_InvoiceDetail_Appointment ON dbo.Invoice_Detail(appointment_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_InvoiceDetail_Invoice' AND object_id = OBJECT_ID('dbo.Invoice_Detail'))
    CREATE NONCLUSTERED INDEX IX_InvoiceDetail_Invoice ON dbo.Invoice_Detail(invoice_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_MedicalRecord_Appointment' AND object_id = OBJECT_ID('dbo.Medical_record'))
AND NOT EXISTS (
    SELECT appointment_id FROM dbo.Medical_record WHERE appointment_id IS NOT NULL GROUP BY appointment_id HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_MedicalRecord_Appointment ON dbo.Medical_record(appointment_id) WHERE appointment_id IS NOT NULL;
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Patient_Phone' AND object_id = OBJECT_ID('dbo.Patient'))
    CREATE NONCLUSTERED INDEX IX_Patient_Phone ON dbo.Patient(phone);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Patient_Account' AND object_id = OBJECT_ID('dbo.Patient'))
AND NOT EXISTS (
    SELECT account_id FROM dbo.Patient WHERE account_id IS NOT NULL GROUP BY account_id HAVING COUNT(*) > 1
)
    CREATE UNIQUE NONCLUSTERED INDEX UX_Patient_Account ON dbo.Patient(account_id) WHERE account_id IS NOT NULL;
GO

/* ---------------------------------------------------------------------------
   Foreign keys from SWP.sql. WITH NOCHECK protects legacy rows during sync.
--------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Appointment_Conversation')
    ALTER TABLE dbo.Appointment WITH NOCHECK ADD CONSTRAINT FK_Appointment_Conversation FOREIGN KEY(conversation_id) REFERENCES dbo.AI_Conversation(conversation_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Appointment_Doctor')
    ALTER TABLE dbo.Appointment WITH NOCHECK ADD CONSTRAINT FK_Appointment_Doctor FOREIGN KEY(doctor_id) REFERENCES dbo.Doctor(doctor_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Appointment_Patient')
    ALTER TABLE dbo.Appointment WITH NOCHECK ADD CONSTRAINT FK_Appointment_Patient FOREIGN KEY(patient_id) REFERENCES dbo.Patient(patient_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Appointment_Schedule')
    ALTER TABLE dbo.Appointment WITH NOCHECK ADD CONSTRAINT FK_Appointment_Schedule FOREIGN KEY(schedule_id) REFERENCES dbo.Doctor_Schedule(schedule_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_DoctorSchedule_Doctor')
    ALTER TABLE dbo.Doctor_Schedule WITH NOCHECK ADD CONSTRAINT FK_DoctorSchedule_Doctor FOREIGN KEY(doctor_id) REFERENCES dbo.Doctor(doctor_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HealthyRecord_InvoiceDetail')
    ALTER TABLE dbo.Healthy_Record WITH NOCHECK ADD CONSTRAINT FK_HealthyRecord_InvoiceDetail FOREIGN KEY(invoice_detail_id) REFERENCES dbo.Invoice_Detail(invoice_detail_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_HealthyRecord_MedicalRecord')
    ALTER TABLE dbo.Healthy_Record WITH NOCHECK ADD CONSTRAINT FK_HealthyRecord_MedicalRecord FOREIGN KEY(record_id) REFERENCES dbo.Medical_record(record_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Invoice_Patient')
    ALTER TABLE dbo.Invoice WITH NOCHECK ADD CONSTRAINT FK_Invoice_Patient FOREIGN KEY(patient_id) REFERENCES dbo.Patient(patient_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Invoice_Receptionist')
    ALTER TABLE dbo.Invoice WITH NOCHECK ADD CONSTRAINT FK_Invoice_Receptionist FOREIGN KEY(receptionist_id) REFERENCES dbo.Account(account_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_InvoiceDetail_Appointment')
    ALTER TABLE dbo.Invoice_Detail WITH NOCHECK ADD CONSTRAINT FK_InvoiceDetail_Appointment FOREIGN KEY(appointment_id) REFERENCES dbo.Appointment(appointment_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_InvoiceDetail_Invoice')
    ALTER TABLE dbo.Invoice_Detail WITH NOCHECK ADD CONSTRAINT FK_InvoiceDetail_Invoice FOREIGN KEY(invoice_id) REFERENCES dbo.Invoice(invoice_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_InvoiceDetail_Service')
    ALTER TABLE dbo.Invoice_Detail WITH NOCHECK ADD CONSTRAINT FK_InvoiceDetail_Service FOREIGN KEY(service_id) REFERENCES dbo.Medical_Service(service_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_MedicalRecord_Appointment')
    ALTER TABLE dbo.Medical_record WITH NOCHECK ADD CONSTRAINT FK_MedicalRecord_Appointment FOREIGN KEY(appointment_id) REFERENCES dbo.Appointment(appointment_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_RTH_FromDoctor')
    ALTER TABLE dbo.Record_Transfer_History WITH NOCHECK ADD CONSTRAINT FK_RTH_FromDoctor FOREIGN KEY(from_doctor_id) REFERENCES dbo.Doctor(doctor_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_RTH_HealthyRecord')
    ALTER TABLE dbo.Record_Transfer_History WITH NOCHECK ADD CONSTRAINT FK_RTH_HealthyRecord FOREIGN KEY(health_record_id) REFERENCES dbo.Healthy_Record(health_record_id);
GO

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_RTH_ToDoctor')
    ALTER TABLE dbo.Record_Transfer_History WITH NOCHECK ADD CONSTRAINT FK_RTH_ToDoctor FOREIGN KEY(to_doctor_id) REFERENCES dbo.Doctor(doctor_id);
GO

PRINT 'Schema sync to SWP.sql completed safely.';
GO
