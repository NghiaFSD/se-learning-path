const userController = {
  index: (req, res) => {
    const { status, keyword } = req.query;
    // console.log(status, keyword);
    /*
    Request: 
    - Nhận thông tin
    - Validate

    Model: Xử lý dữ liệu

    Xử lý logic nghiệp vụ (Nếu có)

    View: Trả dữ liệu cho client
    */
    res.render("users/index", { status, keyword });
  },

  add: (req, res) => {
    res.send("<h1>Thêm người dùng</h1>");
  },

  edit: (req, res) => {
    const id = req.params.id;
    res.send("<h1>Sửa người dùng: " + id + "</h1>");
  },

  orderList: (req, res) => {
    res.send("<h1>Danh sách đơn hàng</h1>");
  },

  orderCompleted: (req, res) => {
    res.send("<h1>Đơn hàng đã hoàn thành</h1>");
  },

  orderCancel: (req, res) => {
    res.send("<h1>Đơn hàng đã hủy</h1>");
  },
};

export default userController;
