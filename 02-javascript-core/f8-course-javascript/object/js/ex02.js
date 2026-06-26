var user = {
  name: "Hoàng An",
  email: "hoangan.web@gmail.com",
  getName: function () {
    return this.name;
  },

  getEmail: function () {
    return this.email;
  },

  getInfo: function () {
    return `
    Tên: ${this.getName()}
    Email: ${this.getEmail()}
    `;
  },
  jobs: {
    name: "Giảng viên - Hoàng An",
    salary: 5000000,
    currency: "VNĐ",
    per: "Tháng",
    histories: [
      {
        year: 2020,
        name: "Công việc 1",
      },
      {
        year: 2021,
        name: "Công việc 2",
      },
    ],
  },
};

// console.log(user.getName());
// console.log(user.getEmail());
// console.log(user.getInfo());

console.log(user.jobs.name);
console.log(user.jobs.salary);
console.log(user.jobs.histories[0].name);
