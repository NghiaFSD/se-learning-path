/*
Cần xây dựng 2 object

1. person => Thông tin của 1 người

2. user => Thông tin của 1 người và có bổ sung 1 vài phương thức

=> Tạo ra 1 bản thiết kế => Khi khởi tạo object lấy bản thiết kế đó và thay dữ liệu

Function Constructor = Hàm tạo
*/

// var person = {
//   name: "Hoàng An",
//   age: 31,
//   email: "hoangan.web@gmail.com",
// };

// var user = {
//   name: "Nguyễn Dương",
//   age: 19,
//   email: "duong@fullstack.edu.vn",
//   getName: function () {
//     this.name;
//   },
// };

//Định nghĩa hàm tạo
var Person = function (name, email, age) {
  var current = this;
  //Định nghĩa các thuộc tính
  current.name = name;
  current.email = email;
  current.age = age;

  //Định nghĩa phương thức
  current.getName = function () {
    return current.name;
  };
};

Person.prototype.getMessage = function () {
  //Từ khóa this trong prototype => Trả về object mà chúng ta khởi tạo hiện tại
  return "Fullstack K1";
};

//Khởi tạo đối tượng
var person = new Person("Hoàng An", "hoangan.web@gmail.com", 31);

// console.log(person);
// console.log(person.getMessage());
// // console.log(person.name);
// // console.log(person.email);
// // console.log(person.getName());

// var user = new Person("Nguyễn Dương", "duong@fullstack.edu.vn", 19);
// console.log(user);
// console.log(user.getMessage());

// Array.prototype.getMsg = function () {
//   console.log(this);
//   console.log("F8");
// };

// var users = ["An", "Dương", "Đức"];
// users.getMsg();

// var numbers = [1, 2, 5, 9];
// numbers.getMsg();

//Kiểm tra 1 object được khởi tạo từ hàm tạo nào
console.log(person.constructor.name);

var user = [];
console.log(user.constructor.name);

var fullname = "";
console.log(fullname.constructor.name);

//Tạo 1 hàm nội bộ từ 1 hàm tạo
Person.isPerson = function () {
  console.log("Hello");
};

Person.isPerson();
