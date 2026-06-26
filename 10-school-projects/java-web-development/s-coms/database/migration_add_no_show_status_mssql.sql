SET NOCOUNT ON;

-- Migration: add No_Show into Appointment status CHECK constraint (SQL Server)
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
    CHECK ([status] IN ('Waiting', 'In_Progress', 'Completed', 'No_Show', 'Cancelled'));

    PRINT N'[OK] Added CK_Appointment_Status with No_Show support.';
END
ELSE
BEGIN
    PRINT N'[OK] CK_Appointment_Status already exists.';
END;
