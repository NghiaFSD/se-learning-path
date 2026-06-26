var carousel = document.querySelector(".carousel");

var carouselInner = carousel.querySelector(".carousel-inner");

var carouselNav = carousel.querySelector(".carousel-nav");

var navNext = carouselNav.querySelector(".next");
var navPrev = carouselNav.querySelector(".prev");

//Tính toán số lượng ảnh

var carouselItems = carouselInner.querySelectorAll(".item");

if (carouselItems.length) {
  //Xử lý
  //Lấy chiều rộng của 1 item
  var itemWidth = carouselInner.clientWidth; //Trả về chiều cộng của element

  //Tính tổng chiều rộng các item
  var totalWidth = itemWidth * carouselItems.length;

  //Cập nhật CSS cho carousel-inner
  carouselInner.style.width = `${totalWidth}px`;

  //Xử lý chuyển slide khi click vào nút next
  var position = 0;
  navNext.addEventListener("click", function () {
    if (Math.abs(position) < totalWidth - itemWidth) {
      position -= itemWidth;
      carouselInner.style.translate = `${position}px`;
    }
  });

  navPrev.addEventListener("click", function () {
    if (position < 0) {
      position += itemWidth;
      carouselInner.style.translate = `${position}px`;
    }
  });
}

//Vuốt chuyển slider

var isDrag = false;
var initialOffsetX;
var rate = (10 * itemWidth) / 100;
var check = false;

carouselInner.addEventListener("mousedown", function (e) {
  isDrag = true;
  initialOffsetX = e.offsetX;
});

carouselInner.addEventListener("mousemove", function (e) {
  e.preventDefault();
  if (isDrag) {
    var currentOffsetX = e.offsetX;
    var moveWidth = currentOffsetX - initialOffsetX;

    if (moveWidth < 0) {
      //Next slide
      if (Math.abs(moveWidth) > rate) {
        if (!check && Math.abs(position) < totalWidth - itemWidth) {
          carouselInner.style.transition = null; //Khôi phục lại hiệu ứng
          position -= itemWidth;
          // console.log(position);
          carouselInner.style.translate = `${position}px`;
          check = true;
        }
      } else {
        carouselInner.style.transition = "none"; //Loại bỏ hiệu ứng khi kéo
        carouselInner.style.translate = `${position + moveWidth}px`;
      }
    } else {
      //Prev Slide
      if (Math.abs(moveWidth) > rate) {
        if (!check && position < 0) {
          carouselInner.style.transition = null; //Khôi phục lại hiệu ứng
          position += itemWidth;
          // console.log(position);
          carouselInner.style.translate = `${position}px`;
          check = true;
        }
      } else {
        carouselInner.style.transition = "none"; //Loại bỏ hiệu ứng khi kéo
        carouselInner.style.translate = `${position + moveWidth}px`;
      }
    }
  }
});

carouselInner.addEventListener("mouseup", function () {
  isDrag = false;
  if (check) {
    check = false;
  } else {
    carouselInner.style.transition = null; //Khôi phục lại hiệu ứng
    carouselInner.style.translate = `${position}px`;
  }
});
