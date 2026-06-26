var users = ["An", "Tuấn", "Dũng", "Yến"];
console.log(users);
//1. fill() => Cập nhật tất cả các phần tử thành 1 giá trị
// users.fill("F8");

//2.forEach(callback)
/*
Duyệt từng phần tử của mảng và trả về element và index (Trong callback)
Hàm này sẽ không có giá trị trả về
Không dừng được
*/
// users.forEach(function (user, index) {
//   console.log(user, index);
// });

//3. map(callback)
/*
- Trả về 1 mảng mới với số lượng phần tử bằng với mảng ban đầu
- Giá trị của từng phần tử phụ thuộc vào giá trị của hàm callback (Có return)
*/

// var newArr = users.map(function (user, index) {
//   console.log(user, index);
//   return `<h3>${index + 1} - ${user}</h3>`;
// });

// var html = newArr.join("");
// document.write(html);

//4. some()
/*
- Trả về true/false 
- Trả về true nếu 1 lần lặp có giá trị callback là true
*/
// var check = users.some(function (user, index) {
//   console.log(user, index);
//   if (user === "An") {
//     return true;
//   }
// });

// console.log(check);

//Kiểm tra xem trong mảng sau có số chẵn hay không?
// var numbers = [1, 3, 5, 2, 9];
// var check = numbers.some(function (number) {
//   return number % 2 === 0;
// });
// console.log(check);

//5. every
/*
- Trả về true/false 
- Chỉ trả về true khi tất cả các phần tử có return true
- Trả về false nếu tất cả các phần tử không return true
*/
// var numbers = [1, 3, 5, 11, 9];
// //Kiểm tra mảng trên xem tất cả có phải là số lẻ hay không?
// var check = numbers.every(function (number) {
//   if (number % 2 !== 0) {
//     return true;
//   }
// });
// console.log(check);

/*
6. filter()
- Trả về 1 mảng mới
- Số lượng phần tử của mảng mới phụ thuộc vào return true của từng phần tử trong mảng ban đầu
*/
// var result = users.filter(function (user) {
//   console.log(user);
//   if (user === "An" || user === "Dũng") {
//     return true;
//   }
// });
// console.log(result);

var customers = [
  "Lưu Anh Quân",
  "Dương Đức Hiệp",
  "Đỗ Hà Chi",
  "Mai Việt Hoàng",
  "Nguyễn Xuân Tuấn Anh",
  "Nguyễn Duy An",
  "Tạ Hoàng An",
];

//Lọc danh sách khách hàng trên theo từ khóa
/*
- Không tìm tên chính xác (Không cần cả họ và tên)
- Không phân biệt chữ hoa chữ thường
*/
// var keyword = "an";

// var results = customers.filter(function (customer) {
//   return customer.toLowerCase().includes(keyword.toLowerCase());
// });

// console.log(results);

/*
7. find()
- Trả về 1 phần của mảng
- Trả về kết quả đầu tiên tìm được

8. findLast()
*/

// var customers = [
//   "Lưu Anh Quân",
//   "Dương Đức Hiệp",
//   "Đỗ Hà Chi",
//   "Mai Việt Hoàng",
//   "Nguyễn Xuân Tuấn Anh",
//   "Nguyễn Duy An",
//   "Tạ Hoàng An",
// ];
// var keyword = "an";
// var result = customers.find(function (customer) {
//   return customer.toLowerCase().includes(keyword.toLowerCase());
// });

// var result = customers.findLast(function (customer) {
//   return customer.toLowerCase().includes(keyword.toLowerCase());
// });

// console.log(result);

/*
9. findIndex()
- Tìm index dựa vào điều kiện trong callback
- Tìm với kết quả đầu

10. findLastIndex()
- Tìm với kết quả cuối
*/

var customers = [
  "Lưu Anh Quân",
  "Dương Đức Hiệp",
  "Đỗ Hà Chi",
  "Mai Việt Hoàng",
  "Nguyễn Xuân Tuấn Anh",
  "Nguyễn Duy An",
  "Tạ Hoàng An",
];
var keyword = "an";

var index = customers.findLastIndex(function (customer) {
  return customer.toLowerCase().includes(keyword.toLowerCase());
});
console.log(index);
