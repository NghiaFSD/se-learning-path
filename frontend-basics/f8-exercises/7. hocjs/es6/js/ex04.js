//Enhance Object

const name = "Hoàng An";
const email = "hoangan.web@gmail.com";
let age; //undefined
const address = "Hà Nội";

// const user = {
//   name: name,
//   email: email,
// };

const user = {
  name,
  email,
  age,
  location: address,
};

console.log(user);

// const getInfo = ({ name, email, age }) => {
//   console.log(name, email, age);
// };

// getInfo({ name, email, age });
