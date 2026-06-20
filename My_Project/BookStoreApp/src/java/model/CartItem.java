package model;

/**
 * Dai dien mot dong du lieu trong gio hang:
 * 1 cuon sach + so luong da chon.
 */
public class CartItem {
    private Book book;
    private int quantity;

    /**
     * Tao cart item tu sach va so luong ban dau.
     */
    public CartItem(Book book, int quantity) {
        this.book = book;
        this.quantity = quantity;
    }

    /**
     * Lay thong tin sach.
     */
    public Book getBook() { return book; }

    /**
     * Lay so luong cua sach trong gio.
     */
    public int getQuantity() { return quantity; }

    /**
     * Cap nhat so luong trong gio.
     */
    public void setQuantity(int quantity) { this.quantity = quantity; }
}