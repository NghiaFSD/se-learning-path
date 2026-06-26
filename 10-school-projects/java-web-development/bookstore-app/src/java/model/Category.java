package model;

/**
 * Entity danh muc sach (VD: Tieu thuyet, Cong nghe, Ky nang...).
 */
public class Category {
    private int id;
    private String name;

    /**
     * Tao danh muc voi id va ten.
     */
    public Category(int id, String name) {
        this.id = id;
        this.name = name;
    }

    /**
     * Lay id danh muc.
     */
    public int getId() { return id; }

    /**
     * Lay ten danh muc.
     */
    public String getName() { return name; }
}