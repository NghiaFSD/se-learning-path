import React, { useState, useEffect } from "react";
let a = 10;
let b = 20;
const App = () => {
  const [count, setCount] = useState(0);
  const [todoList, setTodoList] = useState([]);

  const handleClick = () => {
    setCount((count) => count + 1);
    a++;
  };

  //   useEffect(() => {
  //     console.log("Hello F8");
  //     return () => {
  //       console.log("Unmount 1");
  //     };
  //   }, []);

  //   useEffect(() => {
  //     console.log("Update...");
  //   });
  //   useEffect(() => {
  //     console.log("Update...");
  //   }, [b]);

  const getTodo = async () => {
    const response = await fetch(`https://jsonplaceholder.typicode.com/todos`);
    const data = await response.json();
    setTodoList(data);
  };

  useEffect(() => {
    getTodo();
  }, []);
  console.log("re-render");
  return (
    <div>
      <h1>Count: {count}</h1>
      <button onClick={handleClick}>Click me</button>
      <hr />
      {todoList.map(({ id, title }) => (
        <h3 key={id}>{title}</h3>
      ))}
    </div>
  );
};

export default App;
