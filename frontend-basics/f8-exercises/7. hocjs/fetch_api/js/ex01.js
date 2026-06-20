/*
API = application programming interface
-> Giao diện lập trình ứng dụng

+ Front-end với Back-End
+ Back-end với Back-end
+ Sử dụng các hàm trong 1 thư viện
+ ... 

Khi làm việc với Web API => Thường sử dụng chuẩn RESTFul

- URL: Server API + resource
- Http Method: Phương thức giao tiếp
+ GET => Lấy dữ liệu
+ POST => Thêm mới dữ liệu
+ PUT => Cập nhật dữ liệu
+ PATCH => Cập nhật dữ liệu
+ DELETE => Xóa dữ liệu

=> Back-End sẽ xây dựng

Ví dụ: 
- Url: https://api.fullstack.edu.vn/users

- Tổng hợp Http Method + Resource => Endpoint

Ví dụ: 
- POST /users
- GET /users

Làm sao để có API

- Sử dụng các dịch vụ có sẵn
- Fake bằng thư viện: JSON SERVER
*/

//Sử dụng hàm fetch() để gọi API
//fetch() -> Trả về promise
const apiUrl = `http://localhost:3000/users`;

const getUsers = async () => {
  const response = await fetch(apiUrl);
  //response => Trả về thông tin của response sau khi gọi API

  const users = await response.json();
  //Response Message Body

  document.body.innerHTML = users
    .map(({ name, email }) => `<h2>${name}</h2><h3>${email}</h3><hr/>`)
    .join("");
};

getUsers();

const getUser = async (id) => {
  const response = await fetch(apiUrl + "/" + id);
  const user = await response.json();
  console.log(user);
};

getUser(2);

const postUser = async (data) => {
  const response = await fetch(apiUrl, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });
  if (response.ok) {
    console.log("Thêm thành công");
  }
};

// postUser({
//   name: "User 4",
//   email: "user4@gmail.com",
// });
