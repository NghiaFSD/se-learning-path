SET NOCOUNT ON;

-- Migration: add online_quota to Doctor_Schedule and booking_source to Appointment.
-- This script is idempotent and safe to rerun.

IF COL_LENGTH('dbo.Doctor_Schedule', 'online_quota') IS NULL
BEGIN
    ALTER TABLE dbo.Doctor_Schedule ADD online_quota INT NULL;
    PRINT N'[OK] Added Doctor_Schedule.online_quota.';
END
ELSE
BEGIN
    PRINT N'[OK] Doctor_Schedule.online_quota already exists.';
END;

UPDATE dbo.Doctor_Schedule
SET online_quota = CASE
    WHEN max_patients <= 1 THEN max_patients
    WHEN CEILING(max_patients * 0.6) >= max_patients THEN max_patients - 1
    ELSE CAST(CEILING(max_patients * 0.6) AS INT)
END
WHERE online_quota IS NULL;

IF COL_LENGTH('dbo.Appointment', 'booking_source') IS NULL
BEGIN
    ALTER TABLE dbo.Appointment ADD booking_source NVARCHAR(30) NULL;
    PRINT N'[OK] Added Appointment.booking_source.';
END
ELSE
BEGIN
    PRINT N'[OK] Appointment.booking_source already exists.';
END;

UPDATE dbo.Appointment
SET booking_source = 'Online'
WHERE booking_source IS NULL;

-- Migration: add Checked_In and No_Show into Appointment status CHECK constraint (SQL Server)
-- This script is idempotent and safe to rerun.

DECLARE @appointmentTableId INT = OBJECT_ID(N'dbo.Appointment');
IF @appointmentTableId IS NULL
BEGIN
    PRINT N'[SKIP] Table dbo.Appointment does not exist.';
    RETURN;
END;

-- Drop existing status-related check constraints on Appointment when they do not include No_Show.
DECLARE @dropSql NVARCHAR(MAX) = N'';
SELECT @dropSql = @dropSql
    + N'ALTER TABLE dbo.Appointment DROP CONSTRAINT [' + cc.name + N'];' + CHAR(10)
FROM sys.check_constraints cc
WHERE cc.parent_object_id = @appointmentTableId
  AND LOWER(cc.definition) LIKE '%status%'
  AND LOWER(cc.definition) NOT LIKE '%no_show%';

IF @dropSql <> N''
BEGIN
    EXEC sp_executesql @dropSql;
    PRINT N'[INFO] Dropped old Appointment status check constraints that did not include No_Show.';
END;

-- Ensure the canonical status constraint exists.
IF NOT EXISTS (
    SELECT 1
    FROM sys.check_constraints
    WHERE parent_object_id = @appointmentTableId
      AND name = N'CK_Appointment_Status'
)
BEGIN
    ALTER TABLE dbo.Appointment WITH NOCHECK
    ADD CONSTRAINT CK_Appointment_Status
    CHECK ([status] IN ('Waiting', 'Checked_In', 'In_Progress', 'Completed', 'No_Show', 'Cancelled'));

    PRINT N'[OK] Added CK_Appointment_Status with No_Show support.';
END
ELSE
BEGIN
    PRINT N'[OK] CK_Appointment_Status already exists.';
END;
