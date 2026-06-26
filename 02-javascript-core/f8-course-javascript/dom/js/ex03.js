/*
DOM HTML: 
- Thay đổi text html
- Thay đổi thuộc tính
- Xóa thẻ html
*/

//1. Lấy nội dung bên trong thẻ html

//Trước khi lấy nội dung => Cần phải lấy được Element

var content = document.querySelector(".content");

//1.1. innerHTML => Trả về nội dung bên trong thẻ html (Bao gồm các các thẻ html khác nếu có)
// console.log(content.innerHTML);

//1.2 innerText => Trả về nội dung bên trong thẻ html (Dạng text)
// console.log(content.innerText);

//1.3 textContent => Trả về text ở bên trong thẻ HTML (Giữ nguyên khoảng cách)
// console.log(content.textContent);

//1.4. outerHTML
// console.log(content.outerHTML);

//2. Thay đổi content thẻ html
// content.innerHTML = `<h1>Hoàng An F8</h1>
// <h2>Hello</h2>`

// content.innerText = `<h1>Hoàng An F8</h1>
// <h2>Hello</h2>`

// content.outerHTML = `<h1>Hoàng An F8</h1>
// <h2>Hello</h2>`;

//Bài tập:
/*
Khi click vào nút "Click me" => Lấy toàn bộ content của div class content và chèn vào div class result
Đồng thời xóa nội dung của div class content

Gợi ý từng bước

1. Tạo element cần thiết: button, result, content

2. Gán sự kiện cho button

3. Lấy content từ div content và gán vào div result thông qua innerHTML
*/

var btn = document.querySelector(".btn");
var result = document.querySelector(".result");
// console.log(btn, result, content);
if (btn && content && result) {
  var count = 0;
  btn.addEventListener("click", function () {
    // console.log(this);
    if (result.innerHTML === "") {
      result.innerHTML = content.innerHTML;
      content.innerHTML = "";
      this.querySelector(".text").innerText = "Lên";
    } else {
      content.innerHTML = result.innerHTML;
      result.innerHTML = "";
      this.querySelector(".text").innerText = "Xuống";
    }

    count++;
    this.querySelector(".count").innerText = count;
  });
}
