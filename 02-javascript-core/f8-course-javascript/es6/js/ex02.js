//Function
/*
1. Arrow Function -> Hàm mũi tên

2. rest parameter

3. parameter default
*/

//- Arrow Function không có tham số

// var getMessage = () => {
//   return "Hello F8";
// };

// console.log(getMessage());

//- Arrow Function có 1 tham số

// var getMessage = msg => {
//     return msg;
// }

// console.log(getMessage('Hello F8'));

//- Arrow Function có nhiều tham số
// var getMessage = (msg, type = 'success') => {
//     console.log(`msg: ${msg}`);
//     console.log(`type: ${type}`);
// }

// getMessage('Hello F8', 'error')

//- Arrow Function có return
var getTotal = (a, b) => a + b;
console.log(getTotal(10, 20));

//Lưu ý: Nếu return về 1 object -> Bọc cặp ngoặc () -> Ngoặc tròn

var getCustomer = () => ({name: 'Hoàng An', email: 'hoangan.web@gmail.com'});
console.log(getCustomer());

// var users = [
//     {
//         name: 'Nguyễn Văn A',
//         email: 'nguyenvana@gmail.com'
//     },

//     {
//         name: 'Nguyễn Văn B',
//         email: 'nguyenvanb@gmail.com'
//     },

//     {
//         name: 'Nguyễn Văn C',
//         email: 'nguyenvanc@gmail.com'
//     }
// ]

// var html = users.map((user) => `
// <h3>${user.name}</h3>
// <h3>${user.email}</h3>
// `).join('');

// document.body.innerHTML = html;

/*
Lưu ý khi sử dụng Arrow Function

- Không bind this, arguments
*/

// var btn = document.querySelector('.btn');
// var content = document.querySelector('.content');
// btn.addEventListener('click', (() => {
//     console.log(this);
// }).bind(btn));

// content.addEventListener('click', function() {
//     btn.addEventListener('click', () => {
//         console.log(this);
//     });
// })

// var products = document.querySelectorAll('.products h2');
// products.forEach((item) => {
//     item.addEventListener('click', () => {
//         console.log(this);
//     });
// })
// for (var i = 0; i < products.length; i++) {
//     products[i].addEventListener('click', () => {
//         console.log(this);
//     });
// }

// var getMax = () => {
//     console.log(arguments);
// }
// var getMax = function() {
//     console.log(arguments); //Array-like Object
// }

// getMax(5, 10, 15, 20)

var user = {
    name: 'Hoàng An',
    email: 'hoangan.web@gmail.com',
    getName: () => {
        console.log(this);
        return this.email;
    }
}

console.log(user.getName());

// var Customer = () => {
//     this.name = 'Hoàng An';
//     this.getName = function() {
//         return 'Hoàng An'
//     }
//  }

//  var customer = new Customer;

var getMin = (msg, ...args) => {
    console.log(msg);
    console.log(args);
}

getMin('Min là: ', 5, 10, 15, 20);