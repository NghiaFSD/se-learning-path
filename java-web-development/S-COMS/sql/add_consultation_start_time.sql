-- Migration: add consultation_start_time to Appointment for minimum consultation time rule
-- SQL Server

IF COL_LENGTH('dbo.Appointment', 'consultation_start_time') IS NULL
BEGIN
    ALTER TABLE dbo.Appointment
    ADD consultation_start_time DATETIME2 NULL;
END
GO

-- Optional index for frequent filtering/reporting by start time
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'IX_Appointment_ConsultationStartTime'
      AND object_id = OBJECT_ID('dbo.Appointment')
)
BEGIN
    CREATE INDEX IX_Appointment_ConsultationStartTime
    ON dbo.Appointment (consultation_start_time);
END
GO

-- Suggested trigger points for app integration:
-- 1) Set consultation_start_time = GETDATE() when appointment status changes to In_Progress.
-- 2) Before allowing Completed, enforce DATEDIFF(MINUTE, consultation_start_time, GETDATE()) >= 5.
