SET NOCOUNT ON;

DECLARE @now DATETIME = GETDATE();

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 1)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 1
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_01]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        4.2, 68.0, 0.0, 3.5, 1.1, 1.2, 1.6, 0.5, 0.0,
        1, 60.0, 165.0,
        N'[AI_FRAUD_SEED_20260615_01] spam spam asdasd bot input 0000',
        N'pending', DATEADD(SECOND, 1, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 2)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 2
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_02]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        5.0, 72.0, 0.0, 4.0, 1.5, 1.1, 1.9, 0.6, 0.0,
        2, 58.0, 162.0,
        N'[AI_FRAUD_SEED_20260615_02] hack hack malicious content injected by bot',
        N'pending', DATEADD(SECOND, 2, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 3)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 3
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_03]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        4.8, 70.0, 0.0, 3.8, 1.2, 1.3, 1.7, 0.5, 0.0,
        3, 62.0, 168.0,
        N'[AI_FRAUD_SEED_20260615_03] asdasd asdasd spam du lieu vo nghia',
        N'pending', DATEADD(SECOND, 3, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 4)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 4
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_04]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        5.4, 74.0, 0.0, 4.2, 1.8, 1.0, 2.1, 0.7, 0.0,
        4, 64.0, 170.0,
        N'[AI_FRAUD_SEED_20260615_04] bot spam malicious input vo nghia hack',
        N'pending', DATEADD(SECOND, 4, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 5)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 5
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_05]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        4.6, 69.0, 0.0, 3.9, 1.4, 1.2, 1.8, 0.6, 0.0,
        5, 57.0, 160.0,
        N'[AI_FRAUD_SEED_20260615_05] spam spam spam fake record test',
        N'pending', DATEADD(SECOND, 5, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 1)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 1
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_06]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        4.1, 67.0, 0.0, 3.6, 1.0, 1.3, 1.5, 0.4, 0.0,
        1, 60.0, 165.0,
        N'[AI_FRAUD_SEED_20260615_06] bot bot auto submit asdasd',
        N'pending', DATEADD(SECOND, 6, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 2)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 2
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_07]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        5.2, 73.0, 0.0, 4.1, 1.6, 1.0, 2.0, 0.6, 0.0,
        2, 59.0, 161.0,
        N'[AI_FRAUD_SEED_20260615_07] malicious payload hack bot spam',
        N'pending', DATEADD(SECOND, 7, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 3)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 3
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_08]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        4.7, 71.0, 0.0, 3.7, 1.3, 1.2, 1.7, 0.5, 0.0,
        3, 62.0, 168.0,
        N'[AI_FRAUD_SEED_20260615_08] asdasd spam random random random',
        N'pending', DATEADD(SECOND, 8, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 4)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 4
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_09]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        5.5, 75.0, 0.0, 4.3, 1.9, 1.0, 2.2, 0.7, 0.0,
        4, 64.0, 170.0,
        N'[AI_FRAUD_SEED_20260615_09] hack input spam script bot',
        N'pending', DATEADD(SECOND, 9, @now), NULL
    );
END;

IF EXISTS (SELECT 1 FROM Patient WHERE patient_id = 5)
AND NOT EXISTS (
    SELECT 1
    FROM Healthy_Record
    WHERE patient_id = 5
      AND other_information LIKE N'%[AI_FRAUD_SEED_20260615_10]%'
)
BEGIN
    INSERT INTO Healthy_Record (
        urea, cr, hba1c, chol, tg, hdl, ldl, vldl, bmi,
        patient_id, weight, height, other_information, status, created_at, doctor_id
    )
    VALUES (
        4.9, 70.0, 0.0, 3.8, 1.4, 1.1, 1.8, 0.6, 0.0,
        5, 57.0, 160.0,
        N'[AI_FRAUD_SEED_20260615_10] bot spam malformed data 123123',
        N'pending', DATEADD(SECOND, 10, @now), NULL
    );
END;

SELECT TOP 10
    health_record_id,
    patient_id,
    hba1c,
    bmi,
    other_information,
    created_at
FROM Healthy_Record
WHERE other_information LIKE N'%AI_FRAUD_SEED_20260615%'
ORDER BY created_at DESC;
