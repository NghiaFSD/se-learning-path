//Chọn thành phần kế tiếp

//nextElementSibling => Trả về element
//nextSibling => Trả về Node => Học sau

//Chọn thành phần phía trước
//previousElementSibling => Trả về element
//previousSibling => Trả về Node => Học sau

// var productActive = document.querySelector(".products .active");
// console.log(productActive);
// console.log(productActive.nextElementSibling);

// console.log(productActive.previousElementSibling);

var productActive = document.querySelector(".products .active");
var btnNext = document.querySelector(".next");
var btnPrev = document.querySelector(".prev");

var handleNext = function () {
  var nextElement = productActive.nextElementSibling;
  if (nextElement === null) {
    nextElement = document.querySelector(".products h2");
  }
  nextElement.classList.add("active");
  productActive.classList.remove("active");
  productActive = nextElement;
};

btnNext.addEventListener("click", handleNext);

btnPrev.addEventListener("click", function () {
  var prevElement = productActive.previousElementSibling;

  if (prevElement === null) {
    prevElement = document.querySelector(".products h2:last-child");
  }

  prevElement.classList.add("active");
  productActive.classList.remove("active");
  productActive = prevElement;
});

var isHover = false;

var products = document.querySelector(".products");
products.addEventListener("mouseover", function () {
  isHover = true;
});

products.addEventListener("mouseout", function () {
  isHover = false;
});

setInterval(function () {
  //check hover
  if (!isHover) {
    handleNext();
  }
}, 500);
