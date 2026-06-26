// var a = 10,
//   b = 20;
// var total = a + b + 10;
// console.log(total);

// var a = 20,
//   b = 30;
// var total = a + b + 10;
// console.log(total);

// var a = 40,
//   b = 50;
// var total = a + b + 10;
// console.log(total);

/*
1. Định nghĩa hàm

function tenHam() {
    Nội dung hàm
}
 
function tenHam(thamso1, thamso2,...) {
    Nội dung hàm
}

2. Gọi hàm

Thuật ngữ: 
- Tham số: Định nghĩa hàm
- Đối số: Khi gọi hàm
- Hàm return, hàm void 
- Biến toàn cục, biến cục bộ
*/

// function getMsg() {
//   console.log("Xin chào F8");
// }

// function getMessage(msg, type = "success") {
//   console.log(`Xin chào ${msg}`);
//   console.log(`Type ${type}`);
// }

// getMsg();
// getMessage("Hoàng An", "error");

//Hàm void => Không có giá trị
function getTotal(a, b) {
  var s = a + b;
  console.log(s);
}

//Hàm return
//Khi từ khóa return được gọi => Thoát hàm
function getTotal2(a, b = 0) {
  var s = a + b;

  if (b !== 0) {
    return s;
  }

  return "Không tính được";
}

// console.log(getTotal(10, 20));

// var result = getTotal2(10, 20) + 50;
var result = getTotal2(10, 20);
// console.log(`Result ${result}`);

/*
Kiểm tra các số chẵn trong khoảng từ 1 đến n
Yêu cầu: Viết hàm kiểm tra số chẵn
*/

function isEven(number) {
  //   if (number % 2 === 0) {
  //     return true;
  //   }

  //   return false;
  return number % 2 === 0;
}

// var n = 10;
// for (var i = 1; i <= n; i++) {
//   if (isEven(i)) {
//     console.log(`${i} là số chẵn`);
//   }
// }

// function getMessage(msg) {
//   var msgValue = `Xin chào: ${msg}`;
//   //msgValue => Biến cục bộ
//   return msgValue;
// }

// console.log(getMessage("F8"));
// // console.log(msgValue);

// var msg = "Hello F8"; //Biến toàn cục

// function getMessage() {
//   return msg;
// }

// function setMessage(value) {
//   msg = value;
// }

// setMessage("Hoàng An");

// console.log(getMessage());

//Expression Function (anonymous function)

// var getMessage = function (msg) {
//   return msg;
// };

// console.log(getMessage("Xin chào F8"));

// if (typeof getMessage === "function") {
//   console.log(`Đây là function`);
// }

// var getA = function (a) {
//   //   console.log(a);
//   a();
// };

// var getB = function () {
//   console.log(`getB`);
// };

// getA(getB);

//Callback Function
/*
getA()
getB()
getC()
*/

var getA = function (fn) {
  setTimeout(function () {
    console.log(`getA`);
    fn("F8");
  }, 1000);
};

var getB = function (text) {
  console.log(`getB: ${text}`);
};

var getC = function () {
  console.log(`getC`);
};

// getA(getC);

// var handleGetB = function () {
//   getB("F8");
// };

getA(getB); //Callback Function
