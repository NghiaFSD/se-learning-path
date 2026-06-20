import React, { useState } from "react";
//Không thể gọi Hook ở đây
const App = () => {
  //Call hook
  // const [count, setCount] = React.useState(0);
  const [count, setCount] = useState(0);
  const [form, setForm] = useState({
    name: "",
    email: "",
    phone: "",
  });

  const handleClick = () => {
    //Không thể gọi Hook ở đây
    setCount(count + 1);
  };
  const handleSubmit = (e) => {
    e.preventDefault();
    const { name, email, phone } = form;
    console.log(name, email, phone);
  };
  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };
  return (
    <div>
      {/* <h1>Count: {count}</h1>
      <button onClick={handleClick}>+</button>
      <hr /> */}
      <form action="" onSubmit={handleSubmit}>
        <div>
          <input
            type="text"
            name="name"
            placeholder="Name..."
            onChange={handleChange}
          />
        </div>
        <div>
          <input
            type="email"
            name="email"
            placeholder="Email..."
            onChange={handleChange}
          />
        </div>
        <div>
          <input
            type="tel"
            name="phone"
            placeholder="Phone..."
            onChange={handleChange}
          />
        </div>
        <button>Submit</button>
      </form>
    </div>
  );
};

export default App;

/*
Class: 
- render() -> Khi bị re-render -> Gọi lại hàm này
- Class React.Component: 
+ Lifecycle
+ State

Function -> Không có state, lifecycle -> Hook

Hook là gì? 
- Function đặc biệt
- Chỉ được gọi ở cấp đầu tiên trong functional component
- Function bắt đầu bằng chữ use
*/
