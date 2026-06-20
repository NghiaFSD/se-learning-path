var getA = function (fn, ...args) {
  setTimeout(function () {
    console.log("getA");
    if (typeof fn === "function") {
      //   console.log(args);
      fn(...args); //Gọi hàm chủ động
      //Spread Operator
      //fn(giatri1, giatri2, giatri3)
      //getC()
    }
  }, 2000);
};
//Mất 2s

var getB = function (name, content, subject) {
  console.log("getB", name, content, subject);
};

// getA(getB, "Hoàng An", "F8", "Fullstack");

getA(
  function (name, email) {
    console.log(name, email);
  },
  "Hoàng An",
  "hoangan.web@gmail.com",
);

// var handleGetB = function () {
//   getB("F8");
// };

//JS => ngôn ngữ lập trình bất đồng bộ

//Callback => Xử lý bất đồng bộ

//getA() => getC()
//getA() => getB()

/*
=> getA => getC => getA => getB
*/

//Rest parameter
var sum = function (...args) {
  console.log(args);
};

sum(5, 10, 15, 20, 25, 30, 35, 40);

// var sum2 = function (title, content, subject) {
//   console.log(title, content, subject);
// };

// var a = ["Hoàng An", "F8", "Fullstack"]; //mảng

// sum2(...a);

/*
Kỹ thuật debounce
*/
