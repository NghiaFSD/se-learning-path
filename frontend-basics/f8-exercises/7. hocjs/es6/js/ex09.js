//Try Catch -> Xử lý lỗi ngoại lệ (Exception)

console.log("Chương trình bắt đầu");
var a = 10;
try {
  //Code logic
  //Nếu đoạn chương trình trong block try bị lỗi -> Đẩy lỗi sang block catch và lưu thông tin vào biến exception
  //Nếu trường hợp là lỗi logic nhưng vẫn muốn đẩy vào ngoại lệ

  if (a < 20) {
    throw new Error("Biến a phải từ 20 trở lên");
  }
} catch (exception) {
  //   console.log([exception]);
  console.log(exception.message);
} finally {
  console.log("Hoàn thành");
}

//Thứ tự: Try => Catch => Finally
//-> Try, catch chỉ xảy ra 1 trong 2

console.log("Hello F8");
