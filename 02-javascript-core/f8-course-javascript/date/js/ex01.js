//Xử lý thời gian

// const targetDate = new Date("2023/10/16 09:00:00");
// console.log(targetDate);

const days = [
  "Chủ nhật",
  "Thứ hai",
  "Thứ ba",
  "Thứ tư",
  "Thứ năm",
  "Thứ sáu",
  "Thứ bảy",
];

setInterval(() => {
  const today = new Date();
  today.setDate(today.getDate() + 1);
  const output = `${days[today.getDay()]}, ngày ${today.getDate()} tháng ${
    today.getMonth() + 1
  } năm ${today.getFullYear()}, ${today.getHours()}:${today.getMinutes()}:${today.getSeconds()}`;
  document.body.innerHTML = output;
}, 1000);
