package model;

/**
 * Dai dien cho mot tai khoan nguoi dung trong he thong.
 *
 * username: ten dang nhap (trong du an dang dung email)
 * password: mat khau dang nhap
 * displayName: ten hien thi tren giao dien
 * role: 0 = user, 1 = admin
 */
public class Account {

    private String username;
    // private String password; // Not used - hashed passwords should not be stored
    // in this object
    private String displayName;
    private int role;

    /**
     * Tao doi tuong tai khoan voi day du thong tin.
     */
    public Account(String username, String password, String displayName, int role) {
        this.username = username;
        // Password không lưu trong object này
        this.displayName = displayName;
        this.role = role;
    }

    /**
     * Lay username dung de dang nhap.
     */
    public String getUsername() {
        return username;
    }

    /**
     * Lay ten hien thi cho giao dien.
     */
    public String getDisplayName() {
        return displayName;
    }

    /**
     * Lay role de phan quyen (0 user / 1 admin).
     */
    public int getRole() {
        return role;
    }
}