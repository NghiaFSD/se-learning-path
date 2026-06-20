var header = document.querySelector(".header");
var body = document.body;

var headerHeight = header.clientHeight;
var currentY = 0;
var scrollType;
window.addEventListener("scroll", function () {
  var y = this.window.scrollY;
  if (y > currentY) {
    scrollType = "down";
  } else {
    scrollType = "up";
  }

  currentY = y;

  if (y >= headerHeight) {
    header.classList.add("fixed");
    body.style.paddingTop = `${headerHeight + 15}px`;
  }

  if (scrollType === "up") {
    header.classList.remove("fixed");
    body.style.paddingTop = 0;
  }
});

//Xác định hành động kéo thanh cuộn lên

//Scroll to section
var navItems = header.querySelectorAll(".menu li a");
navItems.forEach(function (navItem) {
  navItem.addEventListener("click", function (e) {
    e.preventDefault();
    var hash = this.getAttribute("href");
    var section = document.querySelector(hash);
    var sectionOffsetTop = section.offsetTop;
    window.scroll(0, sectionOffsetTop - headerHeight - 15);
  });
});
