//DOM CSS
// var content = document.querySelector(".content");
// content.style = `color: red; font-weight: bold`;

// console.log(content.style);

// var css = {
//   color: "white",
//   fontStyle: "italic",
//   fontWeight: "bold",
//   backgroundColor: "black",
//   lineHeight: 1.5,
// };

// Object.assign(content.style, css);
// console.log(content.style.lineHeight);

// content.style.color = "white";
// content.style.fontStyle = "italic";
// content.style.fontWeight = "bold";
// content.style.backgroundColor = "black";
// content.style.lineHeight = "1.5";

//Sử dụng DOM CSS để xây dựng chức năng ẩn/hiện

var content = document.querySelector(".content");

var btn = document.querySelector(".btn");
var count = 0;
btn.addEventListener("click", function () {
  if (content.style.display === "") {
    content.style.display = "none";
    this.innerText = "Hiện";
  } else {
    content.style.display = "";
    this.innerText = "Ẩn";
  }

  count++;
  if (count >= 5) {
    this.disabled = true;
  }
});

//Yêu cầu: Chỉ cho phép click 5 lần. Quá 5 lần => Vô hiệu hóa button
