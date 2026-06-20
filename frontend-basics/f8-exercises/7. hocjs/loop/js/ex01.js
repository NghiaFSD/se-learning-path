/*
Các vòng lặp trong Javascript

1. Vòng lặp for
=> Lặp với số lần lặp xác định trước
1.1. Vòng lặp for tăng
1.2. Vòng lặp for giảm

Cú pháp: 
for (bienchay, dieukiendung, buocnhay) {

}

2. Vòng lặp while
=> Lặp với số lần lặp không xác định trước

3. Vòng lặp do while
=> Lặp với số lần lặp không xác định trước
*/

// for (var i = 1; i <= 10; i += 2) {
//   console.log("Xin chào F8: " + i);
// }

// for (var i = 10; i >= 1; i--) {
//   console.log("Xin chào F8: " + i);
// }

// for (var i = 1; i <= 5; i++) {
//   for (var j = 1; j <= 5; j++) {
//     console.log(`i = ${i} - j = ${j}`);
//   }
// }

//Bài tập 1: Tính giá trị biểu thức
//S = 1 + 2 + 3 +...+ N

var n = 10;
var s = 0;
for (var i = 1; i <= n; i++) {
  s += i;
}

console.log(`Tổng = ${s}`);

/*
i = 5;
s = 0;

- i = 1 => s = s + i = 0 + 1 = 1
- i = 2 => s = s + i = 1 + 2 = 3
- i = 3 => s = s + i = 3 + 3 = 6
- i = 4 => s = s + i = 6 + 4 = 10
- i = 5 => s = s + i = 10 + 5 = 15
=> Kết thúc vòng lặp => s nhận giá trị cuối cùng = 15
*/

/*
Bài tập 2:
total = 1 + 1*2 + 1*2*3 + ... + 1*2*3*4*...*n
*/

var n = 5;
var total = 0;

for (var i = 1; i <= n; i++) {
  //   subTotal *= i;
  //   total += subTotal;
  //Tính i!
  var subTotal = 1;
  for (var j = 1; j <= i; j++) {
    subTotal *= j;
  }

  total += subTotal;
}

console.log(`Total = ${total}`);

/*
i = 1 => 1 * 1 = 1
i = 2 => 1 * 1 * 2 = 2
i = 3 => 1 * 1 * 2 * 3
i = 4 => 1 * 1 * 2 * 3 * 4
i = 5 => 1 * 1 * 2 * 3 * 4 * 5
*/

/*
Kiểm tra số nguyên tố N

Số nguyên tố là gì?

1. >1
2. Số nguyên tố CHỈ chia hết cho 1 và chính nó

Học được: 
- Phân tích sử dụng phương pháp loại trừ
- Kỹ thuật đặt cờ hiệu (Cắm cờ)
*/

var n = 5;
var check = true; //Giả định n là số nguyên tố
if (n <= 1 || n % 1 !== 0) {
  check = false;
} else {
  for (var i = 2; i < n; i++) {
    if (n % i === 0) {
      check = false;
      //Thoát vòng lặp
      i = n;
    }
  }
}

if (check) {
  console.log(`${n} là số nguyên tố`);
} else {
  console.log(`${n} không phải là số nguyên tố`);
}
