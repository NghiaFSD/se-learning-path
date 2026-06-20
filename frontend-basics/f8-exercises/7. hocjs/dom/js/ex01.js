/*
DOM = Document Object Model

1. DOM Element: Truy xuất vào các thẻ html => Tạo đối tượng HTML

2. DOM CSS: Thay đổi CSS Inline của thẻ html

3. DOM HTML: Thay đổi nội dung, thuộc tính thẻ html

4. DOM Event: Gán sự kiện cho các thẻ HTML

5. DOM Event Listener: Lắng nghe các sự kiện

6. DOM Navigation: Thao tác với các element phân cấp

7. DOM Node: Thao tác với các thẻ HTML thông qua Node (Object)
*/

/*
DOM Element: Truy xuất vào các thẻ html có sẵn

- Truy xuất thông qua id:
document.getElementById(id)

- Truy xuất thông qua class
document.getElementsByClassName(class)

- Truy xuất thông qua tag name
document.getElementsByTagName(tag)

- Truy xuất thông qua css selector
document.querySelector(selector)

document.querySelectorAll(selector)
*/
// var title = document.getElementById("title");
// console.log(title);
// var titleList = document.getElementsByClassName("title");
// for (var index = 0; index < titleList.length; index++) {
//   console.log(titleList[index]);
// }

// var titleList = document.getElementsByTagName("h1");
// console.log(titleList);

// var title = document.querySelector("h1.title");
// console.log(title);

var titleList = document.querySelectorAll(".title");
titleList.forEach(function (title) {
  console.log(title.innerText);
  //   title.innerText = "F8";
});
