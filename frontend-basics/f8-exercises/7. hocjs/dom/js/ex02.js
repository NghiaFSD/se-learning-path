/*
DOM Event
1. Tác động trực tiếp vào thẻ html thông qua thuộc tính

2. Tác động thông qua DOM
*/

// var handleClick = function () {
//   console.log("Đăng ký khóa học thành công");
// };

// var handleChange = function () {
//   console.log("Đã nhập xong");
// };

//Tạo Element
// var btn = document.querySelector(".btn");
// // console.log([btn]);
// //Gắn nội dung hàm
// btn.onclick = function () {
//   console.log("Đăng ký khóa học thành công");
// };

// btn.onclick = function () {
//   console.log("Đăng ký khóa học thất bại");
// };

// var province = document.querySelector(".province");
// var handleChangeSelect = function () {
//   console.log("Đã chọn");
// };
// province.onchange = handleChangeSelect;

//=> Event Handler

//Event Listener
/*
Hàm addEventListener()
Hàm removeEventListener()
*/
var btn = document.querySelector(".btn");
var select = document.querySelector(".province");

//listener
var handleClick = function (e) {
  //   console.log("Đăng ký khóa học thành công");
  //e = event object
  console.log(this);
  console.log(e);
};

btn.addEventListener("click", handleClick);

// select.addEventListener("change", function () {
//   console.log("Đã chọn");
//   btn.removeEventListener("click", handleClick);
// });

// btn.addEventListener("click", function () {
//   console.log("Đăng ký khóa học thất bại");
// });

var items = document.querySelectorAll(".menu li");
for (var index = 0; index < items.length; index++) {
  items[index].addEventListener("click", function () {
    // console.log(index);
    console.log(this);
  });
}

// console.log(items[index]);
