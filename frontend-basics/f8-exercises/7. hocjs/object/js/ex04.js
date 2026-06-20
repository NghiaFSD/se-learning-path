Object.prototype.combine = function (...args) {
  var result = [];
  var currentObj = this;
  if (args.length) {
    args.forEach(function (arg) {
      //Nếu dùng this ở đây => chính là function hiện tại
      //Do vậy, muốn dùng this là object user => Cần khai báo 1 biến ở phương thức combine
      result.push(currentObj[arg]);
    });
  }

  return result;
};

Object.prototype.getMessage = function () {
  return "F8 - Fullstack";
};

Object.prototype.name = "Fullstack K1";

var user = {
  name: "Hoàng An",
  email: "hoangan.web@gmail.com",
  age: 31,
};

console.log(user.combine("name", "email", "age"));

// var post = {
//   title: "Bài viết 1",
//   content: "Nội dung 1",
//   author: "Hoàng An",
// };

// console.log(post.combine("title", "content", "author"));

// var service = {
//   name: "Đào tạo lập trình",
//   teacher: "Hoàng An",
// };

// console.log(service.combine("name", "teacher"));

// var a = [];
// console.log(a.getMessage());

var a = "Hoàng an"; //String(s)
console.log(a.getMessage());
console.log(String.prototype);
console.log(a.name);

//Chuỗi có 1 hàm tạo là String => String là con Object

/*
Ngoài ra, prototype còn được định nghĩa ở cấp hàm tạo

*/
