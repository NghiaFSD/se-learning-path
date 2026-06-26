//Classes

class Person {
  constructor(name, email) {
    //Thuộc tính non-static
    this.name = name;
    this.email = email;
  }

  //Phương thức non-static
  getEmail() {
    console.log(this);
    return this.email;
  }

  //Thuộc tính static
  static displayName = "Hoàng An F8";

  //Phương thức static
  static getName() {
    // console.log(this);
    return "F8";
  }
}

const person = new Person("Hoàng An", "hoangan.web@gmail.com");
console.log(person.getEmail());
console.log(Person.getName());
console.log(Person.displayName);

//Array.isArray()

/*
Bài tập: Tạo class User có các thuộc tính sau

- data -> Chứa danh sách users
- name
- email
- password

Viết các phương thức xử lý

- add() -> Thêm user mới
- getInfo() -> Lấy thông tin user theo id

Tạo class Auth kế thừa từ class User và xây dựng các phương thức tĩnh sau

- login -> Đăng nhập -> Trả về id của user nào thành công
- register -> Đăng ký -> Trả về thông tin người dùng đăng ký thành công (Kiểm tra email tồn tại)
- profile -> Lấy thông tin user theo id
*/

class User {
  constructor() {
    this.data = [];
    this.name = null;
    this.email = null;
    this.password = null;
    this.constructor.self = this;
  }

  static self = null;

  isExist(email) {
    return this.data.find(({ email: _email }) => email === _email);
  }

  add(name, email, password) {
    if (!this.isExist(email)) {
      return this.data.push({
        id: this.data.length + 1,
        name,
        email,
        password,
      });
    }
  }

  getInfo(id) {
    const user = this.data.find(({ id: _id }) => id === _id);
    delete user.password;
    return user;
  }
}

class Auth extends User {
  static register(name, email, password) {
    return this.self.add(name, email, password);
  }

  static login(email, password) {
    const user = this.self.data.find((item) => {
      return item.email === email && item.password === password;
    });

    if (user) {
      return user.id;
    }
  }

  static profile(id) {
    return this.self.getInfo(id);
  }
}

new Auth();
Auth.register("Hoàng An", "hoangan.web@gmail.com", "123456");

Auth.register("Lưu Anh Quân", "luuanhquan@gmail.com", "123456");
const id = Auth.login("luuanhquan@gmail.com", "123456");

const user = Auth.profile(id);
console.log(user);
// const user = new User();
// user.add("Hoàng An", "hoangan.web@gmail.com", "123456");
// user.add("Lưu Anh Quân", "quan@gmail.com", "123456");
// console.log(user.getInfo(1));
// console.log(user.getInfo(2));
