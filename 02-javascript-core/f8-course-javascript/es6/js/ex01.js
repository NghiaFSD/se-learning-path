/*
Scope: Phạm vi

1. Global Scope: Phạm vi toàn cục

2. Local Scope: Phạm vi cục bộ

- Function Scope: Phạm vi trong hàm

- Block Scope: Phạm vi trong 1 khối: if, for, while,... (Cặp ngoặc {})
*/

//Global Scope

function handle() {
  //Function Scope
  var a = 10;
  if (a >= 10) {
    //Block Scope
    for (var i = 1; i <= 5; i++) {
      //Block Scope
    }
  }
}

//Từ khóa let, const
/*
let, const chỉ được sử dụng trong phạm vi đã khai báo (scope) và các phạm vi con
let được phép thay đổi
let không được khai báo nhiều lần trong cùng 1 scope
const không được phép thay đổi
Khi khai báo const bắt buộc phải gán giá trị
*/
// for (let i = 1; i <= 5; i++) {
//   let a = 10;
//   if (i === 3) {
//     let a = 20;
//     console.log(a);
//   }
//   console.log(a);
// }

// console.log(i);
// console.log(a);

// let a = 10;
// if (a >= 5) {
//   let b = 20;
//   let c = 10;

//   if (b === 20) {
//     let c = 30;
//     // console.log(c);
//   }

//   console.log(c);
// }

// const user = {
//   name: "Hoàng An",
// };

// user.name = "Hoàng An F8";

// user = {};

// a = 10;
// console.log(a);
// const a = 10;
