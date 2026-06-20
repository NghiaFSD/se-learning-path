// Array.prototype.map2 = function (callback) {
//   if (typeof callback !== "function") {
//     return;
//   }

//   var array = this;

//   var newArr = [];
//   for (var i = 0; i < array.length; i++) {
//     var element = array[i];

//     var result = callback(element, i);
//     // console.log(result);

//     newArr[newArr.length] = result;
//   }

//   return newArr;
// };
// var users = ["User 1", "User 2", "User 3"];

// var newArr2 = users.map2(function (user, index) {
//   //   console.log(user, index);
//   return `<h2>${index + 1} - ${user}</h2>`;
// });

// console.log(newArr2);

// var obj1 = {
//   name: "Hoàng An",
//   email: "hoangan.web@gmail.com",
// };

// var obj2 = {
//   age: 31,
//   address: "Hà Nội",
// };

// //Nối 2 object trên (Không dùng hàm, es6 trở lên)

// // Object.keys(obj2).forEach(function (key) {
// //   obj1[key] = obj2[key];
// // });

// // console.log(obj1);

// //Object.assign()
// // var obj3 = Object.assign(obj1, obj2);
// // console.log(obj1);
// // console.log(obj3);

// //Object.create(null);
// // var user = {};
// // var user = Object.create(null); //Tạo object không có prototype
// // console.log(user);

// //Tham chiếu
// var a = {
//   name: "Hoàng An",
//   email: "hoangan.web@gmail.com",
// };

// //Sao chép object
// // var b = a;
// var b = Object.assign({}, a);
// b.name = "Hoàng An F8";

// console.log(a);
// console.log(b);

// var a = ["Hoàng An", "hoangan.web@gmail.com"];
// // var b = a;
// // var b = a.map(function (item) {
// //   return item;
// // });
// var b = a.filter(function () {
//   return true;
// });
// b[0] = "Hoàng An F8";
// console.log(a);
// console.log(b);

// //Trong kiểu dữ liệu tham chiếu, không so sánh được
// console.log([] === []);
// console.log({} === {});

// var func1 = function () {};

// var func2 = function () {};
// console.log(func1 === func2);

// var arr1 = ["Hoàng An", "hoangan.web@gmail.com"];

// var arr2 = ["Hoàng An", "hoangan.web@gmail.com"];

// console.log(JSON.stringify(arr1) === JSON.stringify(arr2));

//Optional Chaining (?.)
var a = {
  name: {
    job: "Giảng viên",
  },
  getName1: function () {
    return "Hoàng An";
  },
};
console.log(a?.name?.job);
//Optional Chaining với thuộc tính
console.log(a.getName?.());
//Optional Chaining với phương thức

var users = "F8";
if (users?.length) {
  //Đọc mảng
  users.forEach?.(function (user) {
    console.log(user);
  });
}
