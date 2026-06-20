/*
Object - Đối tượng

1. Object Literal: Đối tượng nguyên bản
- Khởi tạo từ 1 hàm tạo có tên là Object

2. Function Constructor: Hàm tạo

Cấu tạo của 1 object
- Thuộc tính: Biến
- Phương thức: Hàm
*/

//Khai báo
// var users = new Object();
var users = {
  name: "Hoàng An",
  email: "hoangan.web@gmail.com",
  address: "Hà Nội",
  job: "Giảng viên",
  getName: function () {
    return "Hoàng An";
  },
};

//Thêm key mới
users.location = "Hà Nội";
//users["location"] = "Hà Nội";

//Sửa key
users.email = "hoangan@fullstack.edu.vn";

//Xóa key
delete users.job;

console.log(users);

// var key = "job";
// //Truy cập vào key của object
// console.log(users.name);
// console.log(users.email);
// console.log(users.getName());

// console.log(users["address"]);
// console.log(users[key]);

// for (var key in users) {
//   var value = users[key];
//   if (typeof value === "function") {
//     console.log(value());
//   } else {
//     console.log(value);
//   }
// }

// Object.keys(users).forEach(function (key) {
//   var value = users[key];
//   if (typeof value === "function") {
//     console.log(value());
//   } else {
//     console.log(value);
//   }
// });

//Kiểm tra 1 biến là 1 object

var a = {};

/*
array
object
null
*/

Object.isObject = function (variable) {
  return (
    typeof variable === "object" &&
    !Array.isArray(variable) &&
    variable !== null
  );
};

if (Object.isObject(a)) {
  console.log("Là object");
} else {
  console.log("Không phải Object");
}

// var b = undefined;
// if (b && b.constructor.name === "Object") {
//   console.log("Object");
// }
