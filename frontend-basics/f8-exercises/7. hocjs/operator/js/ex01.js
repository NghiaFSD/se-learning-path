/*
Toán tử và biểu thức

1. Toán tử số học
+, -, *, /, % (Chia lấy dư), ** (Lũy thừa)
++, --

2. Toán tử logic
>, <, >=, <=, ==, ===, !=, !==

3. Toán tử gán
=, +=, -=, *=, /=

4. Toán tử lý luận
&&, ||, !

5. Toán tử 3 ngôi

6. Toán tử nullish (??)
*/

// var a = 10;
// var b = 20;
// var c = a + b; //Ép kiểu
// console.log(c);

// var c = a ** 2; //Lũy thừa
// console.log(c);

//Phép tăng
// var count = 0;
// count++; //count = count+1;
// ++count; //count = count+1;
// console.log(`Count = ${count}`);

// //Phép giảm
// var count = 10;
// count--;
// --count;
// console.log(`Count = ${count}`);

// var total,
//   count = 0;

// // total = count++;
// total = ++count;
// console.log(`Total = ${total}`);
// console.log(`Count = ${count}`);

// var count = 1;
// // var total = 10 + 20 + 5 + count++;
// var total = count++;

// console.log(`Total = ${total}`);
// console.log(`count = ${count}`);

// total = total += ++count;
// console.log(`Total = ${total}`);
// console.log(`count = ${count}`);

// var a = 10;
// var b = "10";
// var c = a !== b;
// console.log(c);

// var a = 11;
// var check = !!(a >= 5 || a <= 10);
// console.log(check);

// var a = 10;
// a = a + 10;
// a += 10;
// a -= 10;
// a *= 10;
// a /= 10;
// console.log(a);

// var fullname = "Hoàng An";
// fullname += " F8";
// console.log(fullname);

/*
Cú pháp toán tử 3 ngôi

dieukien ? giatridung : giatrisai
*/

// var a = 10;
// var result = a >= 10 ? "F8" : "Sai";

// console.log(result);

// console.log(`${a >= 10 ? "F8" : "Sai"}`);

// var a = 10;

// var total = 10 + 20 + (a >= 10 ? 20 : 15) + 30;

// console.log(total);

//Toán tử nullish (Check null, undefined)

// var a;
// var b = a ?? "F8";

// console.log(b);

//Yêu cầu: Viết lại toán nullish bằng toán tử 3 ngồi
// var result = a === null || a === undefined ? "F8" : a;

// var result = a !== null && a !== undefined ? a : "F8";

// console.log(result);

// var b = 0;

// if (1 === b) {
//   console.log(`Đúng`);
// }

//Truthy, Falsy

//1. Truthy
//Ép các kiểu dữ liệu về true

//2. Falsy
//Ép các kiểu dữ liệu khác về false
/*
0, false, null, "", undefined, NaN (Not A Number)

=> Khi không viết biểu thức logic
*/

// var a = NaN;

// var b = a ? "Đúng" : "Sai";
// console.log(b);

//Toán tử &&
//Nếu giá trị trước && (Sau khi ép kiểu) là true => Lấy giá trị sau &&
//Ngược lại: Lấy giá trị trước && (Không lấy giá trị sau ép  kiểu)

var a = 0;
var b = a && "F8";
console.log(b);
