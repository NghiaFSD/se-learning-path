// const html = `
// <h2>Khóa học Fullstack</h2>
// <p>Hello F8</p>
// `;

const html = (strings, personExp, ageExp, addressExp) => {
  console.log(strings);
  console.log(personExp);
  console.log(ageExp);
  console.log(addressExp);
};

const person = "Hoàng An";
const age = 31;
const address = "Phú Thọ";
// const str = `Tôi tên là ${person}, tôi ${age} tuổi. Ở ${address}`;

const output = html`Tôi tên là ${person}, tôi ${age} tuổi. Ở ${address} abc`;
