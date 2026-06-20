const getUser = (id) => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const users = [
        {
          id: 1,
          name: "User 1",
          salary: 1000,
        },
        {
          id: 2,
          name: "User 2",
          salary: 2000,
        },
        {
          id: 3,
          name: "User 3",
          salary: 3000,
        },
      ];
      const user = users.find(({ id: _id }) => _id === id);
      resolve(user);
    }, 1000);
  });
};

const lists = [1, 2, 3];

//Tính tổng thu tất cả users có trong mảng lists

// let total = 0;
// lists.forEach(async (id) => {
//   const user = await getUser(id);
//   total += user.salary;
// });

// console.log(total);

// let total = 0;
// const getSalary = async () => {
//   for (let id of lists) {
//     const user = await getUser(id);
//     total += user.salary;
//   }

//   console.log(total);
// };

// getSalary();

//Promise.all()

const requests = lists.map(async (id) => await getUser(id));

Promise.all(requests).then((users) => {
  const total = users.reduce((prev, current) => prev + current.salary, 0);
  console.log(total);
});
