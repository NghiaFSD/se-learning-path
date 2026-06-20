//DOM Node
/*
Sự kiện onload => Trang web được tải xong (Tải xong tất cả các tài nguyên: audio, img, video,...)

Sự kiện DOMContentLoaded => Cây DOM được hình thành
*/

// window.addEventListener("load", function () {
//   var title = document.querySelector(".title");
//   console.log(title);
// });

// document.addEventListener("DOMContentLoaded", function () {
//   var title = document.querySelector(".title");
//   console.log(title);
// });

var root = document.querySelector("#root");
//Tạo Element Node
//Dùng phương thức: document.createElement('tag')
var h1 = document.createElement("h1");
h1.innerText = "Hello F8";
h1.classList.add("title");

//Render Element Node lên UI (User Interface)
//Điều kiện: Phải có 1 element thật
root.appendChild(h1);

var ul = document.createElement("ul");
var li = document.createElement("li");
li.innerText = "Item 1";
ul.appendChild(li);

var li = document.createElement("li");
li.innerText = "Item 2";
ul.appendChild(li);

var li = document.createElement("li");
li.innerText = "Item 3";
ul.appendChild(li);

root.append(ul);

var h2 = document.createElement("h2");
h2.innerText = "Fullstack";
root.prepend(h2);

//Thay đổi nội dung, thuộc tính 1 Node
h1.innerText = "Hello F88";

h2.remove();

//Ví dụ: Xây dựng ứng dụng Counter dùng DOM NODE

var handleIncrement = function () {
  countNumber.data++;

  //   if (+countNumber.data === 10) {
  //     countNumber.remove();
  //   }
};

var h2Counter = document.createElement("h2");
h2Counter.innerText = "Count: ";
var countNumber = document.createTextNode(0);
h2Counter.append(countNumber);
root.append(h2Counter);

var btnIncre = document.createElement("button");
btnIncre.innerText = "+";
btnIncre.addEventListener("click", handleIncrement);
root.append(btnIncre);

var counterComment = document.createComment("Counter App");
root.append(counterComment);

//Thêm 1 node mới vào trước 1 node khác
//insertBefore
var h2Title = document.createElement("h2");
h2Title.innerText = "Counter App";
root.insertBefore(h2Title, h2Counter);

//Thay thế node cũ bằng node mới
//replaceChild
var h2TitleNew = document.createElement("h2");
h2TitleNew.innerText = "Ứng dụng đếm";
root.replaceChild(h2TitleNew, h2Title);

//Xóa Node
// h1.remove();
root.removeChild(h1);
console.log(h1);
root.append(h1);
