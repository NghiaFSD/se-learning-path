//Tạo các element
var btn = document.querySelector(".btn");
var modalBox = document.querySelector(".modal-box");
var modalClose = modalBox.querySelector(".close");
var modalOverlay = modalBox.querySelector(".overlay");

btn.addEventListener("click", function () {
  modalBox.classList.add("show");
});

modalClose.addEventListener("click", function () {
  modalBox.classList.remove("show");
});

modalOverlay.addEventListener("click", function () {
  modalBox.classList.remove("show");
});

document.addEventListener("keyup", function (e) {
  if (e.key === "Escape") {
    modalBox.classList.remove("show");
  }
});
