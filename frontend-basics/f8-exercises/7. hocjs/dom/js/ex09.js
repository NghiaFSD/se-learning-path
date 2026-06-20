var checkAll = document.querySelector(".check-all");

var checkItems = document.querySelectorAll(".check-item");

var count = 0;
checkAll.addEventListener("change", function () {
  //Đếm và reset check all
  count = checkAll.checked ? checkItems.length : 0;

  checkItems.forEach(function (checkItem) {
    checkItem.checked = checkAll.checked; //true/false
  });
});

checkItems.forEach(function (checkItem) {
  checkItem.addEventListener("change", function () {
    if (checkItem.checked) {
      count++;
    } else {
      count--;
    }

    console.log(count);

    if (count === checkItems.length) {
      checkAll.checked = true;
    } else {
      checkAll.checked = false;
    }
  });
});
