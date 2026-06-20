/*
Các ký hiệu viết tắt
- \d -> [0-9]
- \D -> Các ký tự không phải là số
- \s -> Khoảng trắng
- \S -> Không phải khoảng trắng
- \w -> A-Z, a-z, 0-9, _
- \W -> Ngược lại của \w

Phủ định: ^
Hoặc: |

Ký tự đại diện cho tất cả các ký tự: .
*/
// const str = "https://fullstack.edu.vn";
// const pattern = /^(http|https):\/\/[a-z-_0-9\.]+\.[a-z]{2,}$/;
// const check = pattern.test(str);
// console.log(check);

//Khẳng định: a > 0 || b > 0 || c > 0
//Phủ định: a <=0 && b <=0 && c <= 0

// const str = "https://www.youtube.com/watch?v=VJLSaq1Ll0U";
//Yêu cầu: Check chuỗi url xem có phải url của Youtube hay không? (Regex)
//https://www.youtu.be/VJLSaq1Ll0U
// const pattern = /^(http|https):\/\/(www\.)*(youtube\.com\/.+|youtu\.be\/.+)$/;
// const check = pattern.test(str);
// console.log(check);

//Cắt chuỗi

//Capturing Group: Lấy 1 phần của biểu thức chính quy (Không áp dụng với global)

// const content = `Hello 0388875179, abcd 0124567890`;
// const content = `ABC hoangan.web@gmail.com acd hoangan@fullstack.edu.vm xyz hoangan@yahoo.com`;
// // const pattern = /(0|\+84)\d{9}/g;
// const pattern = /[a-z\.0-9-_]{3,}@[a-z-_\.0-9]+\.[a-z]{2,}/g;
// const result = content.match(pattern);
// const domainList = result.map((email) => {
//   const pattern = /[a-z\.0-9-_]{3,}@([a-z-_\.0-9]+\.[a-z]{2,})/;
//   const domain = email.match(pattern);
//   return domain[1];
// });

// console.log(domainList);

//Non-Capturing Group
// const url = "https://fullstack.edu.vn/khoa-hoc/fullstack-offline";
// const pattern = /^(?:http|https):\/\/[a-z-_0-9\.]+\.([a-z]{2,})\/.*$/;
// const result = url.match(pattern);
// console.log(result);

//Greedy

// const str = `<img title="F8" src="https://fullstack.edu.vn" width="200" alt="F8 - Fullstack" />`;
// const pattern = /<img.*src="(.+?)"/;
// const result = str.match(pattern);
// console.log(result);

//Thay thế
// let content = `Số điện thoại của tôi là: 0388875179. Thêm số nữa: 0123456789`;

// const pattern = /(0|\+84)\d{9}/g;

// content = content.replace(pattern, "***");

// console.log(content);

//Đối sánh chuỗi -> Chỉ hoạt động với capturing group

let content = `Số điện thoại của tôi là: 0388875179. Thêm số nữa: +84123456789`;

const pattern = /((0|\+84)\d{9})/g;

content = content.replace(pattern, `<a href="tel:$1" data-start="$2">$1</a>`);

// console.log(content);

document.body.innerHTML = content;

const a = `abc\/\d+`;
//Chuyển đổi thành pattern
const pattern2 = new RegExp(a, "ig");
console.log(pattern2);

//{{count}}, {name}, <%= %>

/*
1. Phủ định
2. Hoặc
3. Cắt chuỗi
- Capturing Group
- Non-Capturing Group
- Greedy
4. Thay thế
- Thay thông thường: Chuyển biểu thức chính quy thành 1 chuỗi cố định
- Đối sánh chuỗi

5. Ký tự đại diện: .

6. Các ký tự viết tắt: \d, \D, \w, \W, \s, \S
*/
