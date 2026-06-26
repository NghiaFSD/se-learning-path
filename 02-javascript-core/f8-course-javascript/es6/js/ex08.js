//Xử lý bất đồng bộ

// const step1 = () => {
//   console.log("Step 1");
// };

// const step2 = () => {
//   setTimeout(() => {
//     console.log("Step 2");
//   }, 1000);
// };

// const step3 = () => {
//   console.log("Step 3");
// };

// step1();
// step2();
// step3();

/*
3 cách xử lý bất đồng bộ

1. Callback

2. Promise

3. Async Await Function
*/

// const getUsers = (callback) => {
//   setTimeout(() => {
//     console.log("Danh sách users");
//     if (typeof callback === "function") {
//       callback();
//     }
//   }, 1000);
// };

// const showMessage = () => {
//   console.log("Lấy dữ liệu  thành công");
// };

// getUsers(showMessage);

//Promise

/*
Các trạng thái của Promise
- pending
- fulfilled
- reject
*/

const getUsers = () => {
  const promise = new Promise((resolve, reject) => {
    setTimeout(() => {
      const data = [
        {
          name: "Hoàng An",
          email: "hoangan.web@gmail.com",
        },
      ];

      resolve(data);
      reject("Lỗi kết nối");
    }, 1000);
  });

  return promise;
};

const showMessage = () => {
  console.log("Lấy dữ liệu thành công");
};

// getUsers()
//   .then((users) => {
//     console.log(users);
//     showMessage();
//   })
//   .catch((error) => {
//     console.log(error);
//   });
// console.log(getUsers());

//Promise Chaining

const getA = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("GetA");
    }, 1000);
  });
};

const getB = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("GetB");
    }, 2000);
  });
};

const getC = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("GetC");
    }, 1500);
  });
};

// getA().then((data) => {
//   console.log(data);
//   getB().then((data) => {
//     console.log(data);
//     getC().then((data) => {
//       console.log(data);
//     });
//   });
// });

getA()
  .then((data) => {
    console.log(data);
    return getB();
  })
  .then((data) => {
    console.log(data);
    return getC();
  })
  .then((data) => {
    console.log(data);
  })
  .finally(() => {
    console.log("Đã xong");
  });
