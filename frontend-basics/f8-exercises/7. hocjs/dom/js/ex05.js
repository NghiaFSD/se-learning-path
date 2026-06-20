//ClassList => Thao tác với class
var btn = document.querySelector(".btn");
var content = document.querySelector(".content");
console.log(content.classList);
btn.addEventListener("click", function () {
  //   console.log(content.className);
  //   var currentClass = content.className;
  //   content.className = `${currentClass} content-1`;
  //Thêm class mới
  //   content.classList.add("content-1", "content-2");
  //Xóa class
  //   content.classList.remove("large");
  //Kiểm tra class tồn tại
  //   if (content.classList.contains("abc")) {
  //     console.log("Đã tồn tại");
  //   } else {
  //     content.classList.add("abc");
  //   }
  //Toggle class
  //   content.classList.toggle("abc");

  content.remove();
});

//Xóa element html
//element.remove()
