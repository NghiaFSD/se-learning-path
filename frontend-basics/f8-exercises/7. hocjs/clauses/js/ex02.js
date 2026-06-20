var action = "update";

switch (action) {
  case "create":
  case "insert":
  case "add":
    console.log("Thêm");
    break;

  case "edit":
  case "update":
    console.log("Sửa");
    break;

  case "delete":
  case "remove":
  case "destroy":
    console.log("Xóa");
    break;

  default:
    console.log("Danh sách");
    break;
}

if (action === "add" || action === "create" || action === "insert") {
  console.log("Thêm");
} else if (action === "edit" || action === "update") {
  console.log("Sửa");
} else if (action === "delete" || action === "remove" || action === "destroy") {
  console.log("Xóa");
} else {
  console.log("Danh sách");
}

/*
Hiển thị số ngày trong 1 tháng

Input: 
var month = 12;

Output: Tháng 12 có 31 ngày

Quy tắc: 
- Tháng 31 ngày: 1, 3, 5, 7, 8, 10, 12
- Tháng 30 ngày: 4, 6, 9, 11
- Tháng 29 ngày: 2

Yêu cầu: 
Tháng phải là số nguyên
Có giá trị từ 1 đến 12
Không được dùng hàm để xử lý
*/

var month = 2;
var year = 2023;
if (month % 1 === 0 && month >= 1 && month <= 12 && year % 1 === 0) {
  var days;
  month = +month;
  switch (month) {
    case 2:
      if (year % 4 === 0) {
        days = 29;
      } else {
        days = 28;
      }

      break;

    case 4:
    case 6:
    case 9:
    case 11:
      days = 30;
      break;
    default:
      days = 31;
      break;
  }

  console.log(`Tháng ${month} có ${days} ngày`);
} else {
  console.log(`Tháng ${month} không hợp lệ`);
}

//dispatch action
