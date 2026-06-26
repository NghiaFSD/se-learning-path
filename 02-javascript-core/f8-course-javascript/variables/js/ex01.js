//Khai báo biến

//Khai báo nhiều dòng
var customerName;
var customerEmail;
var customerShippingAddress;
/*
Đặt tên biến theo cú pháp camelCase
*/

//Khai báo trên 1 dòng
var userName, userEmail, userAddress;

//Khai báo và gán
var serviceName = "Đào tạo lập trình",
  teacher = "Hoàng An";

//Hiển thị nội dung trong tab console
console.log(serviceName);
console.log(customerName);

//Hiển thị nội dung lên trình duyệt
document.write(teacher);

// var company = "F88";
var company = "F8";
// var welcome =
//   "<h2>Chào mừng bạn đến với " + company + ' - Tôi là "Hoàng An"</h2>';
var welcome = `<h2>Chào mừng bạn đến với ${company}</h2>`;
console.log(welcome);
document.write(welcome);

// Ký hiệu escape \
// Dấu backtick (`)
