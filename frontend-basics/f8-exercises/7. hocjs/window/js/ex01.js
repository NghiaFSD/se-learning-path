// var name = "Hoàng An";
// console.log(name);

var user = "Hoàng An";
var getUser = function () {
  return user;
};

//biến, hàm => Con của đối tượng có tên là window
//Truy cập vào 1 biến, hàm trong 1 đối tượng JS bằng cách sử dụng cú pháp sau
//tendoituong.tenbien, tendoituong.tenHam()

window.console.log(window.user);
window.console.log(window.getUser());

window.setTimeout(function () {
  console.log("F8");
}, 1000);

console.log(window);

var port = window.location.port;
console.log(port);

window.document.write(`<h1>F8</h1>`);

// console.log(window.console);

// console.error("Lỗi rồi");

// console.log(window.String.prototype);

// var fullname = "Hoàng An";
// fullname.charCodeAt();
