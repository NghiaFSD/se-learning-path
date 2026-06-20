//Kích hoạt strict mode cho file Javascript
// "use strict";
// a = 10;
// console.log(a);

// var getMessage = function () {
//   "use strict";
//   var a = 10;
//   console.log(a);
// };

// getMessage();

// b = 20;

//Hoisting
"use strict";
/*
- Hoisting là 1 cơ chế mặc định của javascript
- Hoisting tự động đẩy phần khai báo lên trước
- Hoisting không đẩy giá trị của biến mà chỉ đẩy phần khai báo

*/

// a = 10;
// console.log(a);

// var a;

// b = 5;
// console.log(b);
// var b = 10;

getMsg();

function getMsg() {
  console.log("Hello F8");
}

getTotal();
var getTotal = function () {
  console.log("Total");
};
