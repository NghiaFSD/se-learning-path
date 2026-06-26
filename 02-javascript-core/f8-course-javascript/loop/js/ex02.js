// var i = 1;
// while (i <= 10) {
//   console.log(`Xin chào F8: ${i}`);
//   i++;
// }

var s = 0,
  i = 1;
while (i <= 10) {
  s += i;
  i++;
}

console.log(`S = ${s}`);

/*
Tất cả các bài toán sử dụng for đều có thể chuyển thành while nhưng không có trường hợp ngược lại
*/

var i = 10;
do {
  console.log(i);
  i++;
} while (i < 10);

//Chạy trước, kiểm tra sau
//Cho dù điều kiện => Chạy 1 lần
