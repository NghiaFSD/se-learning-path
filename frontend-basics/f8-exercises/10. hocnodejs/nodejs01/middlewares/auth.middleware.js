//Middleware là 1 function có 3 tham số
/*
- req --> Object
- res --> Object
- next --> Hàm
*/
const authMiddleware = (req, res, next) => {
  const isLogin = true;
  if (!isLogin) {
    res.redirect("/dang-nhap");
  }
  next(); //Cho phép request đi tiếp
};

export default authMiddleware;
