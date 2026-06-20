//Hàm con, closure

var getMessage = function (msg) {
  var msgValue = "Tôi là: " + msg;
  //Biến cục bộ của hàm cha
  var display = function () {
    var a = 10; //Biến cục bộ của hàm con
    console.log("Hoàng An " + msg);
    console.log(msgValue);
  };

  display();
};

getMessage("F8");

/*
Thứ tự ưu tiên

Biến cục bộ của hàm con => Biến cục bộ của hàm cha => Biến toàn cục

Hàm con có thể sử dụng: 
- Tham số của hàm cha
- Biến cục bộ của hàm cha
- Biến toàn cục
- Biến cục bộ của chính nó
- Tham số của chính nó
*/

//Closure
var sum = function (a) {
  //Trả về 1 hàm
  return function (b) {
    return a + b;
  };
};

var add = sum(10); //Trả về function

//Qua 1 quá trình xử lý => Có giá trị biến b
// console.log(add(20));
// console.log(add(30));
// console.log(add(40));
// console.log(sum(10)(20));

/*
var sum = function(a, b) {
    return a + b;
}
*/

//Giải thuật đệ quy
// function showNumber(n) {
//   console.log(n);

//   //Điều kiện dừng
//   if (n > 1) {
//     showNumber(n - 1);
//   }
// }

// showNumber(10);

//Tính tổng S = 1 + 2 + 3 + ... + N
//Không dùng vòng lặp
function total(n) {
  //   if (n === 1) {
  //     return 1;
  //   } else if (n > 1) {
  //     return n + total(n - 1);
  //   }

  if (n === 1) {
    return 1;
  }

  return n + total(n - 1);
}
console.log(total(10));

//Hiển thị số fibinaci tại vị trí n

var fibonaci = function (n) {
  if (n === 1 || n === 2) {
    return 1;
  }

  return fibonaci(n - 1) + fibonaci(n - 2);
};

console.log(fibonaci(5));

/*
fibonaci(5) = 
fibonaci(4) + fibonaci(3)

fibonaci(3) + fibonaci(2) + fibonaci(2) + fibonaci(1)  

fibonaci(2) + fibonaci(1) + 1 + 1 + 1
1 + 1 + 1 + 1 + 1 = 5
*/
