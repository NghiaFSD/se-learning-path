/*
Controller: 
- Tên Controler (Hay gọi tắt là controller)
- Action --> Hành động

Ví dụ: Controller Users sẽ có các action: 
- Thêm
- Sửa
- Xóa
- Hiển thị
*/

const homeController = {
  index: (req, res) => {
    //Tiếp nhận request
    //Xử lý dữ liệu của request: Validate
    //Truy vấn với Database --> Thông qua Model
    //Trả về response
    const title = "<i>Học Back-End dễ hơn Front-End</i>";
    const check = false;
    const users = ["User 1", "User 2", "User 3"];
    //set session
    req.session.message = "Hello F8";
    req.session.user = {
      name: "Hoàng An",
      email: "hoangan.web@gmail.com",
    };
    delete req.session.message;
    res.render("home/index", { title, check, users });
  },

  showProducts: (req, res) => {
    console.log(req.session.message);
    console.log(req.session.user);
    res.render("home/products", { layout: false });
  },
};

export default homeController;
