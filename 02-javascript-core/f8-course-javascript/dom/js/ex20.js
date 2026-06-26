//Custom Element
/*
- Kỹ thuật tạo ra 1 thẻ html riêng
- Thẻ html này phải có 2 từ trở lên và có gạch ngang
- Kỹ thuật để phân chia các thành phần trong trang web -> Hay còn gọi là Component

Sử dụng: 
- customElements
- Kế thừa từ HTMLElement
- lifecycle callbacks -> Vòng đời từ lúc 1 component được tạo ra cho đến lúc xóa nó
*/

//Tạo Component: 1 hàm hoặc 1 class
var HelloWorld = function () {
  return Reflect.construct(HTMLElement, [], this.constructor);
};

HelloWorld.prototype = Object.create(HTMLElement.prototype);

//Vòng đời component

//1. constructor
HelloWorld.prototype.constructor = HelloWorld;

//2. connectedCallback -> Component được hình thành (Chạy sau constructor)
// -> Chỉ chạy 1 lần
HelloWorld.prototype.connectedCallback = function () {
  console.log("Connected");
  //   this.innerText = "Hello World";
  //   this.dataset.index = "1";
  //   var name = this.getAttribute("name");
  //   console.log(name);

  var defaultValue = this.getAttribute("defaultValue");

  var h1 = document.createElement("h1");
  h1.innerText = "Count: ";
  var text = document.createTextNode(defaultValue);
  h1.append(text);
  this.append(h1);

  var button = document.createElement("button");
  button.innerText = "+";
  button.addEventListener("click", function () {
    text.data++;
  });
  this.append(button);
};

//3. disconnectedCallback -> Component được loại bỏ
HelloWorld.prototype.disconnectedCallback = function () {
  console.log("Disconnected");
};

//Đăng ký component
customElements.define("hello-world", HelloWorld);

//shadow DOM
