package com.diabetes.monitoring.model;

import java.sql.Timestamp;

/**
 * Model for Health Record - Patient health submission
 */
public class HealthRecord {
    private int healthRecordId;
    private double urea;
    private double cr;
    private double hba1c;
    private double chol;
    private double tg;
    private double hdl;
    private double ldl;
    private double vldl;
    private double bmi;
    private int patientId;
    private String patientName;
    private double weight;
    private double height;
    private String otherInformation;
    private String status; // pending, processing, completed
    private Integer doctorId;
    private String doctorName;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public HealthRecord() {
    }

    // Getters and Setters
    public int getHealthRecordId() {
        return healthRecordId;
    }

    public void setHealthRecordId(int healthRecordId) {
        this.healthRecordId = healthRecordId;
    }

    public double getUrea() {
        return urea;
    }

    public void setUrea(double urea) {
        this.urea = urea;
    }

    public double getCr() {
        return cr;
    }

    public void setCr(double cr) {
        this.cr = cr;
    }

    public double getHba1c() {
        return hba1c;
    }

    public void setHba1c(double hba1c) {
        this.hba1c = hba1c;
    }

    public double getChol() {
        return chol;
    }

    public void setChol(double chol) {
        this.chol = chol;
    }

    public double getTg() {
        return tg;
    }

    public void setTg(double tg) {
        this.tg = tg;
    }

    public double getHdl() {
        return hdl;
    }

    public void setHdl(double hdl) {
        this.hdl = hdl;
    }

    public double getLdl() {
        return ldl;
    }

    public void setLdl(double ldl) {
        this.ldl = ldl;
    }

    public double getVldl() {
        return vldl;
    }

    public void setVldl(double vldl) {
        this.vldl = vldl;
    }

    public double getBmi() {
        return bmi;
    }

    public void setBmi(double bmi) {
        this.bmi = bmi;
    }

    public int getPatientId() {
        return patientId;
    }

    public void setPatientId(int patientId) {
        this.patientId = patientId;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public double getWeight() {
        return weight;
    }
    
    public void setWeight(double weight) {
        this.weight = weight;
    }

    public double getHeight() {
        return height;
    }

    public void setHeight(double height) {
        this.height = height;
    }

    public String getOtherInformation() {
        return otherInformation;
    }

    public void setOtherInformation(String otherInformation) {
        this.otherInformation = otherInformation;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getDoctorId() {
        return doctorId;
    }

    public void setDoctorId(Integer doctorId) {
        this.doctorId = doctorId;
    }

    public String getDoctorName() {
        return doctorName;
    }

    public void setDoctorName(String doctorName) {
        this.doctorName = doctorName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    /**
     * Get status display text
     */
    public String getStatusDisplayText() {
        if (status == null || status.isEmpty()) {
            return "Chờ xử lý"; // Default for NULL status
        }
        switch (status) {
            case "pending": return "Chờ xử lý";
            case "processing": return "Đang xử lý";
            case "completed": return "Hoàn thành";
            default: return status;
        }
    }

    /**
     * Get status badge class
     */
    public String getStatusBadgeClass() {
        if (status == null || status.isEmpty()) {
            return "bg-warning text-dark"; // Default for NULL status
        }
        switch (status) {
            case "pending": return "bg-warning text-dark";
            case "processing": return "bg-primary";
            case "completed": return "bg-success";
            default: return "bg-secondary";
        }
    }

    /**
     * Check if record is assigned to a doctor
     */
    public boolean isAssigned() {
        return doctorId != null;
    }
}
