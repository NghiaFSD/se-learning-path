//Classes

// function User() {
//   this.name = "Hoàng An";
//   this.email = "hoangan.web@gmail.com";
//   this.getName = function () {
//     return this.name;
//   };
// }

class User {
  //Khai báo constructor()
  //- Dùng để khai báo các thuộc tính, các giá trị khởi tạo
  //- Chạy đầu tiên khi object được khởi tạo

  constructor(name, email) {
    console.log("Constructor User");
    //Định nghĩa thuộc tính
    this.name = name;
    this.email = email;

    //Các giá trị khởi tạo
  }

  //Các phương thức
  getName() {
    return this.name;
  }

  getEmail() {
    return this.email;
  }
}

class Authentication extends User {
  constructor(name, email, age) {
    console.log("Constructor Authentication");
    super(name, email);
    this.age = age;
  }
  getUser() {
    return {
      name: this.getName(),
      email: this.getEmail(),
    };
  }
}

// User.prototype.message = `Hello F8`;

// const user = new User("Hoàng An", "contact@fullstack.edu.vn");
// console.log(user);
// console.log(user.name);
// console.log(user.email);
// console.log(user.getEmail());
// console.log(user.message);

// const auth = new Authentication("Hoàng An", "hoangan.web@gmail.com", 31);
// console.log(auth);
// console.log(auth.getUser());

const root = document.querySelector("#root");

class Counter {
  constructor() {
    this.count = 0;
    this.h1 = null;
  }

  handleIncrement = () => {
    this.count++;
    // console.log(this.count);
    this.h1.innerText = this.count;
  };

  render() {
    this.h1 = document.createElement("h1");
    this.h1.innerText = this.count;
    const button = document.createElement("button");
    button.innerText = "+";
    button.addEventListener("click", this.handleIncrement);

    root.append(this.h1);
    root.append(button);
  }
}

new Counter().render();
