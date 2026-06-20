//ES6 Object, Array
/*
1. Destructuring

2. Spread

3. Enhance Object
*/

//Destructuring -> Phá vỡ cấu trúc của array, object để có thể truy cập vào các phần tử và lưu thành các biến riêng biệt

// const user = {
//     name: 'Hoàng An',
//     email: 'hoangan.web@gmail.com',
//     age: 31,
//     address: 'Hồ Chí Minh'
// }

// const name = user.name;
// const email = user.email;
// console.log(name, email);

// const {name: _name, email, age, address = 'Hà Nội'} = user;
// console.log(_name, email, age, address);

// const {name: _name, email, ...rest} = user;
// console.log(_name, email);
// console.log(rest);

// const user = [
//     'Hoàng An',
//     'hoangan.web@gmail.com',
//     31,
//     'Hồ Chí Minh',
//     10000000
// ];

// const [username, email,, address, salary = 5000000] = user;
// console.log(username, email, address, salary);

// const [username, email, ...rest] = user;
// console.log(username, email);
// console.log(rest);

var customers = [
    {
        id: 1,
        name: 'Nguyễn Văn A'
    },

    {
        id: 2,
        name: 'Nguyễn Văn B'
    },

    {
        id: 3,
        name: 'Nguyễn Văn C'
    },
]

var html = customers.map(({id, name}, index) => `
<h3>${index} - ${id} - ${name}</h3>
`).join('');
console.log(html);

let a = 10;
let b = 20;

[a, b] = [b, a];

console.log(`a = ${a}`);
console.log(`b = ${b}`);

//Spread

const oldObj = {
    name: 'Hoàng An F8',
    email: 'hoangan.web@gmail.com'
}

const newObj = {
    course: 'Fullstack',
    teacher: 'Hoàng An',
    ...oldObj
}

// console.log(newObj);

const oldArr = [
    'Hoàng An F8',
    'hoangan.web@gmail.com'
];

const newArr = [
    'Fullstack',
    ...oldArr
]

// console.log(newArr);

const getTotal = (a, b) => {
    console.log(a, b);
}

var values = [5, 10];
// var values = {a: 5, b: 10}

getTotal(...values)