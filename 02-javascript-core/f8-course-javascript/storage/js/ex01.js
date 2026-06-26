// => Storage chỉ lưu trữ Text

//1. localStorage -> Lưu trữ vô thời hạn
//1.1. set localStorage: localStorage.setItem('key', 'value')
//1.2. get localStorage: localStorage.getItem('key')
//1.3. remove localStoraage: localStorage.removeItem('key')
//1.4. Xóa tất cả localStorage: localStorage.clear()

//2. sessionStorage -> Lưu trữ theo phiên (Tắt trình duyệt tự xóa)
//-> Tương tự localStorage

//3. Cookie -> Lưu trữ theo phiên, lưu trữ theo thời gian xác định

// localStorage.setItem("username", "hoangan.web");
// if (typeof Storage !== "undefined") {
//   console.log(localStorage.getItem("username"));

//   sessionStorage.setItem("username", "hoangan.web@gmail.com");
// }

//Cookie => Tự động đính kèm vào Http Request (Dùng trình duyệt)
//Chuỗi cookie: key1=value1; key2=value2;...

//1. set cookie
//Expire sẽ chấp nhận định dạng thời gian UTC
const expire = new Date("2023-10-16 09:00:00").toUTCString();

// document.cookie = `username=hoangan.web;expires=${expire}`;
// document.cookie = `email=hoangan.web@gmail.com`;
document.cookie = "username=hoangan.web;path=/";
document.cookie = "username=hoanganit19";

//2. Đọc cookie
// console.log(document.cookie);

//3. Cập nhật cookie
// document.cookie = "username=hoanganit19";

//4. Xóa cookie
// document.cookie = `username=;expires=${new Date().toUTCString()}`;

/*
HttpOnly -> Chỉ phép back-end lấy cookie (Lấy thông qua HTTP)
secure -> Chỉ thao tác với cookie nếu sử dụng https
*/
