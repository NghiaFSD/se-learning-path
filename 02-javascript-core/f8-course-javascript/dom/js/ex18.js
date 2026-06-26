var btn = document.querySelector(".btn");
var countEl = document.querySelector(".count");
var message = document.querySelector(".message");

// var countEvent = new Event("count");

// btn.addEventListener("click", function () {
//   countEl.innerText++;

//   //Nếu count = 10 -> Hiển thị nội dung: "Hello F8" vào thẻ div message
//   if (+countEl.innerText === 10) {
//     // message.innerText = `Hello F8`;
//     countEl.dispatchEvent(countEvent);
//   }
// });

// countEl.addEventListener("count", function () {
//   console.log("Success");
// });

var increEvent = new Event("increment");

btn.addEventListener("mousedown", function () {
  //   countEl.dispatchEvent(increEvent);
  isMouseDown = true;
  handleIncrement(countEl);
});

btn.addEventListener("mouseup", function () {
  isMouseDown = false;
});

var isMouseDown = false;
var handleIncrement = function (current) {
  current.innerText++;
  var id = setTimeout(function () {
    handleIncrement(current);
  }, 100);
  if (!isMouseDown) {
    clearTimeout(id);
  }
};
// countEl.addEventListener("increment", function () {

// });

var quantity = document.querySelector(".quantity");
var quantityInput = quantity.querySelector("input");
var minusBtn = quantityInput.previousElementSibling;
var plusBtn = quantityInput.nextElementSibling;
var changeEvent = new Event("change");

plusBtn.addEventListener("click", function () {
  quantityInput.value++;
  quantityInput.dispatchEvent(changeEvent);
});

minusBtn.addEventListener("click", function () {
  quantityInput.value--;
  if (quantityInput.value < 1) {
    quantityInput.value = 1;
  }
  quantityInput.dispatchEvent(changeEvent);
});

quantityInput.addEventListener("change", function () {
  console.log(this.value);
});

//Trigger Event

var timer = document.querySelector(".timer");
// timer.addEventListener("change", function () {
//   console.log(this.value);
// });

var initialValue = null;
var dragEvent;

document.addEventListener("mouseup", function () {
  initialValue = null;
});

timer.addEventListener("input", function () {
  if (!initialValue) {
    initialValue = this.value;
    dragEvent = new CustomEvent("drag", {
      detail: {
        initialValue: initialValue,
      },
    });
  }

  if (this.value !== initialValue) {
    timer.dispatchEvent(dragEvent);
  }
});

timer.addEventListener("drag", function (e) {
  //   console.log(this.value);
  //   console.log(e);
  console.log(this.value, e.detail.initialValue);
});
