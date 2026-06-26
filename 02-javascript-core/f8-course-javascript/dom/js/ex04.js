/*
DOM HTML

Thay đổi thuộc tính

- Thuộc tính có sẵn: Bản thân thẻ html có sẵn thuộc tính đó

- Thuộc tính tự tạo: data attribute
*/

var link = document.querySelector(".link");
console.log(link);

//1. Lấy giá trị thuộc tính
//Cú pháp: element.tenthuoctinh
// console.log(link.href);
// console.log(link.title);
// console.log(link.target);
// console.log(link.rel);
// console.log(link.className);
// console.log(link.id);
// console.log(link.width);
// console.log(link.getAttribute("width"));

//2. Thay đổi giá trị thuộc tính
link.href = "https://google.com";
link.rel = "follow";
link.id = "link-02";
// link.setAttribute("width", "200");

//3. Xóa thuộc tính
link.removeAttribute("title");

var link02 = document.querySelector(".link-02");
console.log(link02.href);
console.log(link02.getAttribute("href"));

//Data Attribute

var content = document.querySelector(".content");

//Truy cập vào data attribute

//Cách 1: Dùng getAttribute
console.log(content.getAttribute("data-count"));

//Cách 2: Truy cập thông qua dataset
console.log(content.dataset);
console.log(content.dataset.count); //data-count
console.log(content.dataset.indexNumber);
//data-index-number

//Gán giá trị cho data attribute
content.setAttribute("data-count", 10);
content.dataset.indexNumber = "f8";
