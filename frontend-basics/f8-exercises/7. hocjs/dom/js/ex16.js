//Scroll Event

// window.addEventListener("scroll", function () {
//   console.log("Scrolling...", window.scrollY);
// });

//Dừng scroll => window lắng nghe được sự kiện scrollend
// window.addEventListener("scrollend", function () {
//   console.log("Hết rồi");
// });

// var btn = document.querySelector(".btn");
// btn.addEventListener("click", function () {
//   window.scroll(0, 500);
// });

/*
window.scrollY => Lấy tọa độ của vị trí scroll so với top
window.scrollX => Lấy tọa độ của vị trí scroll so với left
window.scroll(x, y) => Thiết lập vị trí scroll theo trục x, y
*/

//Bài tập: Xây dựng chức năng back to top

var backBtn = document.querySelector(".back");
window.addEventListener("scroll", function () {
  var position = window.scrollY;
  if (position >= 60) {
    backBtn.classList.add("show");
  } else {
    backBtn.classList.remove("show");
  }
});

backBtn.addEventListener("click", function (e) {
  e.preventDefault();
  e.stopPropagation();
  //   window.scroll(0, 0);
  scrollTo(0);
});

var scrollTo = function (position) {
  var currentScrollY = window.scrollY;
  var id = setInterval(function () {
    currentScrollY -= 100;
    window.scroll(0, currentScrollY);
    if (currentScrollY < position) {
      clearInterval(id);
    }
  }, 20);
};
