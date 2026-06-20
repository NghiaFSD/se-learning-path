//Async Await

/*
Async là 1 function -> Luôn trả về 1 promise
*/

const getData = () => {
  return new Promise((resolve, reject) => {
    setTimeout(() => {
      //   resolve("Hoàng An");
      reject("Lỗi mạng");
    }, 1000);
  });
};

//IIFE = Immediately Invoked Function Expression
// (async () => {
//   try {
//     const data = await getData();
//     console.log(data);
//   } catch (e) {
//     console.log(e);
//   } finally {
//     console.log("Hoàn thành");
//   }
// })();

// const getName = async () => {
//   //   getData().then((data) => {
//   //     console.log(data);
//   //   });
//   const data = await getData();
//   console.log(data);
// };

// getName();

// getName().then((data) => {
//   console.log(data);
// });

const getA = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("Get A");
    }, 1000);
  });
};
const getB = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("Get B");
    }, 2000);
  });
};
const getC = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      resolve("Get C");
    }, 500);
  });
};

//Hiển thị thứ tự Get A => Get B => Get C (Dùng async await)
// (async () => {
//   const a = await getA();
//   console.log(a);
//   const b = await getB();
//   console.log(b);
//   const c = await getC();
//   console.log(c);
// })();

const getRequest = () => {
  return new Promise((resolve) => {
    setTimeout(() => {
      const response = {
        text: () => {
          return new Promise((resolve) => {
            resolve(JSON.stringify(data));
          });
        },

        json: () => {
          return new Promise((resolve) => {
            resolve(data);
          });
        },
      };
      const data = {
        name: "Hoàng An",
        email: "hoangan.web@gmail.com",
      };

      resolve(response);
    }, 1000);
  });
};

// getRequest()
//   .then((response) => {
//     // console.log(response);
//     return response.text(); //=> data sẽ trả về object
//     //Nếu return response.text() => Trả về json
//   })
//   .then((data) => {
//     console.log(data);
//   });

(async () => {
  const response = await getRequest();
  const data = await response.json();
  console.log(data);
})();
