//DOM Navigation

//1. parentElement => Chọn cấp cha từ element hiện tại

//Ngoài ra: parentNode => Học kỹ ở DOM Node
// var btn = document.querySelector(".btn");
// btn.addEventListener("click", function () {
//   console.log(this);
//   console.log(this.parentElement);
//   console.log(this.parentElement.parentElement);
// });

// var removeBtnList = document.querySelectorAll(".products .remove");

// if (removeBtnList.length) {
//   removeBtnList.forEach(function (removeBtn) {
//     removeBtn.addEventListener("click", function () {
//       this.parentElement.remove();
//     });
//   });
// }

//2. children => Lấy danh sách các phần tử con cấp gần nhất

// var menu = document.querySelector(".menu");
// var items = menu.querySelectorAll("li");
// var items = menu.children[1].children[1].children; //Array-like object
// console.log(items);

/*
Bài tập: Click vào các item ở menu trên. Nếu item có menu con => Đổi màu nền của cả menu con
Ngược lại, đổi màu chữ của item vừa click vào
*/

var linkList = document.querySelectorAll(".menu a");
if (linkList.length) {
  linkList.forEach(function (link) {
    link.addEventListener("click", function (e) {
      e.preventDefault();

      var children = this.parentElement.children;
      if (children.length === 2) {
        children[1].style.background = "pink";
      } else {
        this.style.color = "red";
      }
    });
  });
}
