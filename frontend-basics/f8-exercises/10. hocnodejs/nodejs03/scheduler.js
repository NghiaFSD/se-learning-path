const cron = require("node-cron");

cron.schedule("* 0 * * *", () => {
  //Gọi hàm xóa blacklist hết hạn
});

// cron.schedule("*/45 * * * *", () => {
//   console.log("Checking log");
// });

// setInterval(() => {
//   console.log("F8");
// }, 10000);
