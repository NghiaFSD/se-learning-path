/*
JSON (JavaScript Object Notation) 
- Là chuỗi
- Mô tả dữ liệu 1 cách chính xác
- Được dùng để giao tiếp dữ liệu giữa các nền tảng với nhau

Ví dụ:
Web F8 <-> App F8

Chuyển dữ liệu từ web F8 thành định dạng chung mà App F8 đọc được (Đảm bảo tính toàn vẹn của dữ liệu)

xml, json

-> Hầu như các ngôn ngữ đều đọc được và chuyển thành kiểu dữ liệu của ngôn ngữ đó

Các thao tác với JSON

1. Chuyển từ các kiểu dữ liệu thành JSON
JSON.stringify()

2. Chuyển từ JSON về kiểu dữ liệu tương ứng
JSON.parse()
*/

var users = [
  {
    id: 1,
    name: "Hoàng An",
    email: "hoangan.web@gmail.com",
  },
  {
    id: 2,
    name: "Hoàng An 2",
    email: "hoangan.web@gmail.com",
  },
  {
    id: 3,
    name: "Hoàng An 3",
    email: "hoangan.web@gmail.com",
  },
];
var json = JSON.stringify(users);

var users = JSON.parse(json);
console.log(users);

/*
Nguyên tắc: 
- key phải nằm trong dấu nháy kép
- kết thúc cặp key, value cuối cùng không được có dấu ,
*/
