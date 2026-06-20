// import getUser, {
//   course,
//   user,
//   getCourses as getCourseList,
// } from "./modules/home.js";

// console.log(getUser());
// console.log(course);
// console.log(user);
// console.log(getCourseList());

//Import tất cả 1 file
import * as home from "./modules/home.js";

const { course, default: getUser, getCourses, user } = home;

console.log(course);
console.log(getUser());
console.log(getCourses());
console.log(user);
