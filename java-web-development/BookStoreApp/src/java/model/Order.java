package model;

import java.sql.Timestamp;

/**
 * Entity tong quan cua don hang.
 * Chua thong tin header: nguoi dat, tong tien, thoi gian, lien he giao hang.
 */
public class Order {
    private int id;
    private String username;
    private double totalPrice;
    private Timestamp orderDate;
    private String phone;
    private String address;
    private String displayName; // populated via JOIN with Account, not stored in Order table
    private String status;

    public Order() {}

    public Order(int id, String username, double totalPrice, Timestamp orderDate) {
        this.id = id;
        this.username = username;
        this.totalPrice = totalPrice;
        this.orderDate = orderDate;
    }

    public Order(int id, String username, double totalPrice, Timestamp orderDate,
                 String phone, String address) {
        this(id, username, totalPrice, orderDate);
        this.phone = phone;
        this.address = address;
    }

    public Order(int id, String username, double totalPrice, Timestamp orderDate,
                 String phone, String address, String displayName) {
        this(id, username, totalPrice, orderDate, phone, address);
        this.displayName = displayName;
    }

    /** Lay ma don hang. */
    public int getId() { return id; }
    /** Lay username tai khoan dat hang. */
    public String getUsername() { return username; }
    /** Lay tong tien cua don. */
    public double getTotalPrice() { return totalPrice; }
    /** Lay thoi diem dat don. */
    public Timestamp getOrderDate() { return orderDate; }
    /** Lay so dien thoai giao hang. */
    public String getPhone() { return phone; }
    /** Lay dia chi giao hang. */
    public String getAddress() { return address; }
    /** Lay ten hien thi khach hang (JOIN tu Account). */
    public String getDisplayName() { return displayName; }
    /** Lay trang thai don hang (VD: Cho xac nhan, Dang giao, Hoan thanh, Da huy). */
    public String getStatus() { return status; }
    /** Cap nhat trang thai don hang. */
    public void setStatus(String status) { this.status = status; }
}