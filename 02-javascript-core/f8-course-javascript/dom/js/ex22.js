//Tạo component tên là: image để hiển thị 1 hình ảnh
/*
Các thuộc tính:
- link -> Đường dẫn ảnh
- width -> Chiều rộng
- height -> Chiều cao
- style -> CSS Inlines
*/

Component.create("image-component", function () {
  var shadow = this.attachShadow({ mode: "open" });
  var link = this.getAttribute("link");
  var width = this.getAttribute("width");
  var height = this.getAttribute("height");
  var style = this.getAttribute("style");
  shadow.innerHTML = `<img src="${link}" width="${width}" height="${height}" style="${style}" />`;
  var styleEl = document.createElement("style");
  styleEl.textContent = `
  img {
    box-shadow: 5px 5px 5px #ccc;
  }
  `;
  shadow.appendChild(styleEl);
});

Component.create("box-image", function () {
  var style = document.createElement("style");
  style.textContent = `
    .box-image {
        border: 3px solid red;
        padding: 10px;
        display: inline-block;
    }
  `;
  this.appendChild(style);
  this.innerHTML = `<div class="box-image">${this.innerHTML}</div>`;
});
