package model;

/**
 * Entity chi tiet don hang (detail line).
 * Moi dong ung voi 1 sach trong don.
 */
public class OrderDetail {
    private int odid;
    private Book book;
    private int quantity;
    private double price;

    /**
     * Constructor rong.
     */
    public OrderDetail() {
    }

    /**
     * Constructor day du thong tin chi tiet.
     */
    public OrderDetail(int odid, Book book, int quantity, double price) {
        this.odid = odid;
        this.book = book;
        this.quantity = quantity;
        this.price = price;
    }

    /**
     * Lay id chi tiet don hang.
     */
    public int getOdid() {
        return odid;
    }

    /**
     * Gan id chi tiet don hang.
     */
    public void setOdid(int odid) {
        this.odid = odid;
    }

    /**
     * Lay thong tin sach cua dong chi tiet.
     */
    public Book getBook() {
        return book;
    }

    /**
     * Gan sach cho dong chi tiet.
     */
    public void setBook(Book book) {
        this.book = book;
    }

    /**
     * Lay so luong mua.
     */
    public int getQuantity() {
        return quantity;
    }

    /**
     * Cap nhat so luong mua.
     */
    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    /**
     * Lay don gia tai thoi diem dat hang.
     */
    public double getPrice() {
        return price;
    }

    /**
     * Cap nhat don gia.
     */
    public void setPrice(double price) {
        this.price = price;
    }

    /**
     * Tinh thanh tien = don gia * so luong.
     */
    public double getSubTotal() {
        return price * quantity;
    }
}
