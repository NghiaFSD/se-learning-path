package com.diabetes.monitoring.dao;

import com.diabetes.monitoring.model.PatientRecord;
import com.diabetes.monitoring.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MedicalRecordDAO {
    private static final Logger LOGGER = Logger.getLogger(MedicalRecordDAO.class.getName());

    public boolean saveRecord(PatientRecord record) {
        String sql = "INSERT INTO patient_records (user_id, date, glucose, bmi, blood_pressure, notes) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, record.getUserId());
            statement.setString(2, record.getDate());
            statement.setDouble(3, record.getGlucose());
            statement.setDouble(4, record.getBmi());
            statement.setString(5, record.getBloodPressure());
            statement.setString(6, record.getNotes());
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
            return false;
        }
    }

    public List<PatientRecord> getRecordsByUserId(int userId) {
        List<PatientRecord> records = new ArrayList<>();
        String sql = "SELECT id, date, glucose, bmi, blood_pressure, notes FROM patient_records WHERE user_id = ? ORDER BY date DESC";
        try (Connection connection = DatabaseConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    PatientRecord record = new PatientRecord();
                    record.setId(resultSet.getInt("id"));
                    record.setDate(resultSet.getString("date"));
                    record.setGlucose(resultSet.getDouble("glucose"));
                    record.setBmi(resultSet.getDouble("bmi"));
                    record.setBloodPressure(resultSet.getString("blood_pressure"));
                    record.setNotes(resultSet.getString("notes"));
                    records.add(record);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Operation failed", e);
        }
        return records;
    }
}

