console.log(Math);
// console.log(Math.PI);

//1. Lấy trị tuyệt đối
// var a = -10;
// console.log(Math.abs(a));

//2. Lấy ngẫu nhiên
// console.log(Math.random());

//3. Làm tròn xuống
// var a = 10.9;
// console.log(Math.floor(a));

//4. Làm tròn lên
// var a = 10.1;
// console.log(Math.ceil(a));

//5. Làm tròn theo quy tắc

// var a = 10.5;
// console.log(Math.round(a));

//6. Căn bậc hai
// var a = 10;
// console.log(Math.sqrt(a));

//7. Số lớn nhất
// console.log(Math.max(5, 2, 1, 8));

//8. Số nhỏ nhất
// console.log(Math.min(5, 1, 9));

var getRandom = function (min, max) {
  min = Math.ceil(min);
  max = Math.floor(max);
  return Math.floor(Math.random() * (max - min + 1)) + min;
};

console.log(getRandom(1, 100));
