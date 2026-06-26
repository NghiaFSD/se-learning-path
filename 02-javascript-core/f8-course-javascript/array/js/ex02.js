console.log(Array.prototype);

var users = ["An", "Dương", "Đức", "Dương"];

//1. at(index) => Lấy ra phần tử theo index

// console.log(users.at(0));

//2. concat(arr2, arr3,...) => Nối mảng

// console.log(users.concat([1, 2, 3], [4, 5, 6]));

// console.log(users.concat("Quân", "Tuấn Anh"));

//3. indexOf(value) => Tìm vị trí xuất hiện đầu tiên của phần tử trong mảng. Nếu tìm thấy sẽ trả về index, không tìm thấy trả về -1
// console.log(users.indexOf("Dương"));

//4. lastIndexOf(value) => Tìm vị trí cuối cùng
// console.log(users.lastIndexOf("Dương"));

//5. includes(value) => Tìm phần tử trong mảng và trả về true/false
// console.log(users.includes("Dương"));

//6. slice(start, end) => Cắt mảng từ start đến end
// console.log(users.slice(1, 3));
// console.log(users.slice(2));
// console.log(users.slice(-2));

//7. join(char) => Nối các phần tử mảng thành chuỗi
// console.log(users.join(" - "));
//Chuỗi: Dùng hàm split để tách chuỗi thành mảng

//Bài tập: Tách tên từ chuỗi họ và tên
// var fullname = "Tạ Hoàng An";
// var firstName = fullname.split(" ").slice(-1).join();
// console.log(firstName);

//8. push() => Thêm phần tử vào cuối mảng và trả về số lượng phần tử sau khi thêm xong

// var count = users.push("Item 1", "Item 2", "Item 3");

//9. unshift() => Thêm phần tử vào đầu mảng và trả về số lượng phần tử sau khi thêm xong

// var count = users.unshift("Item 1", "Item 2", "Item 3");

//10. pop() => Xóa phần tử cuối mảng và trả về giá trị phần tử vừa xóa
// var value = users.pop();
// console.log(value);

//11. shift() => Xóa phần tử đầu mảng và trả về giá trị phần tử vừa xóa
// var value = users.shift();
// console.log(value);

//12. splice(index, number) => Xóa number phần tử từ vị trí thứ index trong mảng
// users.splice(1, 1, "Quân", "Tuấn Anh");

//13. reverse() => Đảo ngược mảng
// users.reverse();

//14. sort() => Sắp xếp mảng theo thứ tự tăng dần
// users.sort(); //Chỉ áp dụng với chuỗi

// console.log(users);

var numbers = [5, 10, 1, 9, 2];
numbers.sort(function (next, prev) {
  //   if (prev > next) {
  //     return -10;
  //   }
  return next - prev;
  /*
  Tham số thứ 1 là phần tử sau
  Tham số thứ 2 là phần tử trước
  return về số âm => Đổi chỗ
  */
});
// console.log(numbers);

var customers = [
  "Tạ Hoàng An",
  "Nguyễn Thị Yến",
  "Mai Thị Tâm",
  "Nguyễn Văn Dũng",
];

//Sắp xếp danh sách khách hàng tăng dần theo tên

var getFirstName = function (fullname) {
  return fullname.split(" ").slice(-1).join();
};

customers.sort(function (a, b) {
  if (getFirstName(b) > getFirstName(a)) {
    return -1;
  }
});
console.log(customers);
