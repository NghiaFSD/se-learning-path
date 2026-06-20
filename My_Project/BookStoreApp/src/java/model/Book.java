package model;

/**
 * Entity chua thong tin mot cuon sach trong kho.
 */
public class Book {
    private int id;
    private String title;
    private double price;
    private String image;
    private int cid;
    private String description;
    private int stock;
    private String author;
    private String edition;

    /**
     * Constructor rong, thuong dung khi map du lieu tung buoc.
     */
    public Book() {
    }

    /**
     * Constructor day du thong tin sach.
     */
    public Book(int id, String title, double price, String image, int cid, String description, int stock) {
        this.id = id;
        this.title = title;
        this.price = price;
        this.image = image;
        this.cid = cid;
        this.description = description;
        this.stock = stock;
        this.author = "";
        this.edition = "";
    }

    /**
     * Constructor day du thong tin sach (bao gom author va edition).
     */
    public Book(int id, String title, double price, String image, int cid, String description, int stock, String author,
            String edition) {
        this.id = id;
        this.title = title;
        this.price = price;
        this.image = image;
        this.cid = cid;
        this.description = description;
        this.stock = stock;
        this.author = author;
        this.edition = edition;
    }

    /**
     * Lay id sach.
     */
    public int getId() {
        return id;
    }

    /**
     * Lay tieu de sach.
     */
    public String getTitle() {
        return title;
    }

    /**
     * Lay gia hien tai.
     */
    public double getPrice() {
        return price;
    }

    /**
     * Lay URL anh bia.
     */
    public String getImage() {
        return image;
    }

    /**
     * Lay id danh muc cua sach.
     */
    public int getCid() {
        return cid;
    }

    /**
     * Lay mo ta noi dung sach.
     */
    public String getDescription() {
        return description;
    }

    /**
     * Lay ton kho con lai.
     */
    public int getStock() {
        return stock;
    }

    /**
     * Gan id cho sach.
     */
    public void setId(int id) {
        this.id = id;
    }

    /**
     * Cap nhat so luong ton kho.
     */
    public void setStock(int stock) {
        this.stock = stock;
    }

    /**
     * Cap nhat tieu de sach.
     */
    public void setTitle(String title) {
        this.title = title;
    }

    /**
     * Cap nhat gia sach.
     */
    public void setPrice(double price) {
        this.price = price;
    }

    /**
     * Cap nhat URL anh.
     */
    public void setImage(String image) {
        this.image = image;
    }

    /**
     * Cap nhat danh muc.
     */
    public void setCid(int cid) {
        this.cid = cid;
    }

    /**
     * Cap nhat mo ta sach.
     */
    public void setDescription(String description) {
        this.description = description;
    }

    /**
     * Lay ten tac gia.
     */
    public String getAuthor() {
        return author;
    }

    /**
     * Cap nhat ten tac gia.
     */
    public void setAuthor(String author) {
        this.author = author;
    }

    /**
     * Lay thong tin tai ban (edition).
     */
    public String getEdition() {
        return edition;
    }

    /**
     * Cap nhat tai ban (edition).
     */
    public void setEdition(String edition) {
        this.edition = edition;
    }
}