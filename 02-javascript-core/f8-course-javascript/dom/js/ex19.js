//HTMLElement

// var title = document.querySelector(".title");
// console.log(title);

// var p = document.querySelector("p");

// console.log(p);

// console.log(HTMLElement.prototype);

// var css = {
//   border: "1px solid red",
//   background: "yellow",
// };

// var changeCSS = function (element, style) {
//   Object.assign(element.style, style);
// };

// changeCSS(title, css);

HTMLElement.prototype.changeCSS = function (style) {
  Object.assign(this.style, style);
};

var title = document.querySelector(".title");
title.changeCSS({
  border: "1px solid red",
  background: "yellow",
});

document.querySelector("p").changeCSS({
  color: "red",
  fontWeight: "bold",
  fontSize: "2rem",
});
