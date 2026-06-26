//Mảng có 1 hàm tạo tên là Array

console.log(Array.prototype);
// console.log([Array]);

// var users = []; //Khai báo mảng
// console.log(users, typeof users);

// var users = new Array(); //Tạo đối tượng từ hàm tạo Array

var users = ["An", "Dương", "Đức"];

//Kiểm tra biến có thuộc kiểu mảng hay không?
if (Array.isArray(users)) {
  console.log("Là mảng");
}

//Lấy số lượng phần tử
//tenbien.length
console.log(users.length);

//Truy cập vào 1 phần tử của mảng
// console.log(users[1]);
// console.log(users[2]);

//Thêm phần tử vào mảng
//tenmang[index] = giatri;
users[users.length] = "Quân";
users[users.length] = "Chi";

//Sửa phần tử
//tenmang[index] = giatrimoi

// users[1] = "Dương 2";

//Duyệt mảng

//1. Duyệt bằng for
// for (var i = 0; i < users.length; i++) {
//   console.log(users[i]);
// }

//2. Duyệt bằng for in => Trả về index
// for (var index in users) {
//   console.log(users[index]);
// }

//3. Duyệt bằng for of => Trả về element
// for (var user of users) {
//   console.log(user);
// }

//Xóa phần tử trong mảng theo index
var results = [];
var indexDelete = 0;
for (var index in users) {
  if (+index === +indexDelete) {
    continue;
  }

  results[results.length] = users[index];
}

console.log(results);
