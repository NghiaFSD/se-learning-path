//Chuỗi
/*

*/
//Khai báo chuỗi
// var fullname = "Hoàng An";
// console.log(fullname, typeof fullname);
// console.log(fullname.length);

// var fullname2 = String("Hoàng An");
// console.log(fullname2, typeof fullname2);

// var fullname3 = new String("Hoàng An");
// console.log(fullname3, typeof fullname3);

// console.log(fullname3.length);

//String => Hàm tạo => Dùng để tạo ra các object liên quan đến chuỗi
//Trong hàm tạo String sẽ có các thuộc tính (biến), phương thức (hàm) để xử lý chuỗi
//Việc tạo ra các phương thức, thuộc tính đó => Sử dụng thông qua prototype (kế thừa phương và thuộc tính) => Học kỹ ở phần object
//Khi 1 biến có kiểu dữ liệu là string => Tạo ra 1 object tạm thời để truy cập vào các phương thức, thuộc tính của hàm tạo String

//Để hiển thị danh sách các thuộc tính, phương thức trong hàm tạo String. hiển thị: String.prototype

console.log(String.prototype);

//Kiểm tra 1 chuỗi

// if (typeof fullname === "string") {
//   console.log(`Đây là chuỗi`);
// } else {
//   console.log(`Đây không phải chuỗi`);
// }

//Các phương thức xử lý chuỗi
var str = "Xin chào F8 Hoàng An F8";

//1. Thuộc tính length => Trả về độ dài của chuỗi
// console.log(str.length);

//2. charAt(index) => Lấy 1 ký tự theo index
// console.log(str.charAt(1));
// console.log(str.charAt(str.length - 1));

//3. charCodeAt(index) => Trả về mã ASCII của ký tự index
// console.log(str.charCodeAt(1));

//4. slice(start, end) => Cắt chuỗi từ vị trí index tới end
// console.log(str.slice(5, 10));
// console.log(str.slice(5));
// console.log(str.slice(-2));

//5. indexOf(subStr) => Trả về vị trí đầu tiên tìm được của chuỗi con trong chuỗi cha, nếu không thấy sẽ trả về -1
// console.log(str.indexOf("F8"));

//6. lastIndexOf(subStr) => Trả về vị trí cuối cùng
// console.log(str.lastIndexOf("F8"));

//Bài tập: hoangan.web@gmail.com => Lấy username

// var email = "hoangan.web@gmail.com";
// var position = email.indexOf("@");
// //lấy index của ký tự @
// var username = email.slice(0, position);
// //Cắt chuỗi từ đầu cho đến position
// console.log(username);

//7. includes(subStr) => Tìm chuỗi subStr trong chuỗi cha => Nếu tìm thấy trả về true, ngược lại trả về false
// console.log(str.includes("F8"));

//8. concat(str1, str2,...) => Nối chuỗi

// console.log(str.concat("Item 1", "Item 2", "Item 3"));

//9. replace(tucantim, tuthaythe) => Thay thế từ đầu tiên

// console.log(str.replace("F8", "F88"));

//10. replaceAll(tucantim, tuthaythe) => Thay thế tất cả
// console.log(str.replaceAll("F8", "F88"));

//11. split(char) => Tách chuỗi thành mảng
// console.log(str.split(" "));

//12. trim() => Loại bỏ khoảng trắng đầu và cuối chuỗi
//trimStart() => Loại bỏ khoảng trắng đầu chuỗi
//trimEnd() => Loại bỏ khoảng trắng cuối chuỗi
// str = " Hoàng An  ";
// console.log(str);
// console.log(str.trim());

//13. toLowerCase() => Chuyển thành chữ thường
console.log(str.toLowerCase());

//14. toUpperCase() => Chuyển thành chữ hoa
console.log(str.toUpperCase());

// var content = "ABC vdv bfdfvb 0388875179 vsd h 0123456789";
// var pattern = /0\d{9}/g; //Regular Expression
// var phones = content.match(pattern);
// console.log(phones);

var welcome = "Chào mừng bạn đến với F8";
//Đảo ngược chữ đầu tiên và chữ cuối cùng
//F8 mừng bạn đến với Chào
var firstWord = welcome.slice(0, welcome.indexOf(" "));

var lastWord = welcome.slice(welcome.lastIndexOf(" ") + 1);

var middleWord = welcome.slice(
  welcome.indexOf(" "),
  welcome.lastIndexOf(" ") + 1,
);

welcome = lastWord + middleWord + firstWord;

console.log(welcome);

var fullname = "tạ hoàng an";
//Tạ Hoàng An

//Tạ      Hoàng   An => Tạ Hoàng An
