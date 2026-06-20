USE project_SWP;
GO

/*
    Run with UTF-8 input to preserve Vietnamese literals:
    sqlcmd -S localhost -d project_SWP -f 65001 -i "...\\seed_medical_service_utf8_mssql.sql" -b
*/

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    BEGIN TRAN;

    PRINT '=== Reset Medical_Service UTF-8 seed: START ===';

    IF OBJECT_ID(N'dbo.Medical_Service', N'U') IS NULL
        THROW 53001, 'Missing table dbo.Medical_Service.', 1;

    /*
      Dung DELETE de an toan voi FK (thay vi TRUNCATE).
      Neu bang khong co lien ket FK, co the doi sang TRUNCATE TABLE dbo.Medical_Service.
    */
    DELETE FROM dbo.Medical_Service;

    DBCC CHECKIDENT ('dbo.Medical_Service', RESEED, 0);

    INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
    VALUES (N'Khám nội tiết tổng quát', 150000.00, 'Examination', 'Active');

    INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
    VALUES (N'Xét nghiệm HbA1c', 180000.00, 'Lab_Test', 'Active');

    INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
    VALUES (N'Khám chuyên khoa đái tháo đường', 220000.00, 'Examination', 'Active');

    INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
    VALUES (N'Xét nghiệm đường huyết lúc đói', 120000.00, 'Lab_Test', 'Active');

    INSERT INTO dbo.Medical_Service (service_name, price, service_type, status)
    VALUES (N'Xét nghiệm mỡ máu toàn phần', 250000.00, 'Lab_Test', 'Inactive');

    PRINT '--- Verify Medical_Service ---';
    SELECT service_id, service_name, price, service_type, status
    FROM dbo.Medical_Service
    ORDER BY service_id;

    COMMIT TRAN;
    PRINT '=== Reset Medical_Service UTF-8 seed: DONE ===';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRAN;
    DECLARE @ErrMsg NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrLine INT = ERROR_LINE();
    DECLARE @ErrNo INT = ERROR_NUMBER();
    RAISERROR('Medical_Service UTF-8 seed failed at line %d (error %d): %s', 16, 1, @ErrLine, @ErrNo, @ErrMsg);
END CATCH;
GO
