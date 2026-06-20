/*
Nguyên tắc chung: 
- Muốn import từ file khác vào -> File được import phải được export
- Có 2 loại import, export
+ default
+ named
*/

const user = {
  name: "Hoàng An",
  email: "hoangan.web@gmail.com",
};

const course = {
  name: "Fullstack",
  price: 5000,
};

export const getCourses = () => {
  return ["A", "B", "C"];
};

export default function getUser() {
  return user;
}

//Export Default -> Trong 1 file chỉ có 1 export default
//Với function và class -> Sử dụng export trực tiếp trước từ khóa function, class
// export default user;
// export default getUser;

//Export named
export { user, course };
