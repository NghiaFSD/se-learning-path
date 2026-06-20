/*
Event Object
*/
var btn = document.querySelector(".btn");
var nameEl = document.querySelector(".name");

// btn.addEventListener("click", function (e) {
//   console.log(this);
//   console.log(e);
//   if (!e.ctrlKey) {
//     this.style.background = "green";
//   } else {
//     this.style.background = "red";
//   }
// });

// btn.addEventListener("mouseup", function (e) {
//   console.log(e);
// });

// nameEl.addEventListener("input", function (e) {
//   console.log(e);
// });

// nameEl.addEventListener("keyup", function (e) {
//   console.log(e);
// });

/*
1. mousedown
2. mouseup
3. mousemove

Các bước triển khai: 
1. Xác định hành động giữ chuột và kéo
- mousedown của button => Gắn cờ
- mousemove của document => Chỉ thực thi khi cờ == true
- mouseup của documnent => Hủy cờ
*/

var isDown = false;
var offsetX = 0;
var offsetY = 0;
btn.addEventListener("mousedown", function (e) {
  if (e.which === 1) {
    isDown = true;
    offsetX = e.offsetX;
    offsetY = e.offsetY;
  }
});

document.addEventListener("mousemove", function (e) {
  if (isDown) {
    // console.log("Đang kéo");
    // console.log(e.clientX, e.clientY);
    var css = {
      top: `${e.clientY - offsetY}px`,
      left: `${e.clientX - offsetX}px`,
    };

    Object.assign(btn.style, css);
  }
});

document.addEventListener("mouseup", function () {
  isDown = false;
});

//Hành động mặc định của html
//Chặn bằng phương thức: preventDefault()

var link = document.querySelector(".link");
link.addEventListener("click", function (e) {
  e.preventDefault();
  console.log(this.href);
});

// document.addEventListener("contextmenu", function (e) {
//   e.preventDefault();
//   alert("Không được click chuột phải");
// });

var content = document.querySelector(".content");
var span = content.querySelector("span");

// content.addEventListener("click", function () {
//   console.log(`Content clicked`);
// });

// span.addEventListener("click", function (e) {
//   e.stopPropagation();
//   console.log(`Span clicked`);
// });

content.addEventListener("click", function (e) {
  console.log(this);
  console.log(e.target);
});
