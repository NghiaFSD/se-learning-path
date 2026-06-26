/*
Hàm reduce(callback, initialValue)
- callback: Hàm có 2 tham số (prevValue, currentValue)
- initialValue: Giá trị khởi tạo

Giá trị của hàm reduce là kết quả lần return cuối cùng
*/

// var numbers = [1, 2, 3, 4, 5];
// // var result = numbers.reduce(function (prev, current) {
// //   //   console.log(`Prev: ${prev}`);
// //   //   console.log(`Current: ` + current);
// //   console.log(`Prev: ${prev}`, `Current: ${current}`);
// //   return current;
// // }, 0);

// // console.log(result);

// var result = numbers.reduce(function (total, current) {
//   return total + current;
// }, 0);

// console.log(result);
// index=0; total = 0; current = 1 => return 1
//index=1; total=1; current=2 => return 3
//index=2; total=3; current=3 => return 6
//index=3 total=6; current=4 => return 10
//index=4 total=10 current=5 => return 15

// var numbers = [5, 9, 10, 2, 8];
// //tìm max sử dụng reduce
// var result = numbers.reduce(function (max, current) {
//   //   if (max < current) {
//   //     return current;
//   //   }

//   //   return max;
//   return max < current ? current : max;
// });

// console.log(result);

var arr1 = [1, 5, 2, 9];

var arr2 = [1, 3, 2];

//Tìm phần tử khác giữa 2 mảng
/*
Phần tử xuất hiện trong mảng thứ nhất, nhưng không xuất hiện trong mảng thứ hai

//=> [5, 9]
*/

var diff = arr1.reduce(function (prev, current) {
  //   if (!arr2.includes(current)) {
  //     prev.push(current);
  //   }

  //   return prev;
  return !arr2.includes(current) && prev.push(current), prev;
  //return a, b, c
}, []);

// console.log(diff);

// var testFunc = function () {
//   console.log(arguments);
//   Array.from(arguments).forEach(function (number) {
//     console.log(number);
//   });
// };

// testFunc(5, 10, 15, 20);

// var pElement = document.getElementsByTagName("p");
// Array.from(pElement).forEach(function (item) {
//   console.log(item);
// });

var a = ["Hoàng An", 31];

// var b = a;
//Sao chép mảng
// b = a.map(function (item) {
//   return item;
// });
b = [...a]; //spread operator

b[0] = "Hoàng An F8";

console.log(a, b);
