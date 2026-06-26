//BOM = Browser Object Model

const btn = document.querySelector(".btn");
// const close = document.querySelector(".close");
// let website;
// btn.addEventListener("click", () => {
//   //   window.open(
//   //     "https://vnexpress.net",
//   //     "",
//   //     "width=200px,height=200px,top=100px,left=200px",
//   //   );
//   website = window.open("https://vnexpress.net");
//   console.log(website);
// });

// close.addEventListener("click", () => {
//   website.close();
// });

// console.log(window.location);
// window.location.search = "keyword=abc";
// window.location.reload();
// console.log(window.location.toString());

// const params = new URLSearchParams(window.location.search);
// const keyword = params.get("keyword");
// console.log(keyword);

btn.addEventListener("click", () => {
  window.history.pushState({}, "", "/san-pham?page=1");
});

console.log(navigator);
console.log(navigator.language);
