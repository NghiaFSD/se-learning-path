import { useState } from "react";
import Content from "./Content";
import { color } from "../libs/color";

const Counter = ({ title, color }) => {
  const [count, setCount] = useState(0);
  let a;
  if (count < 10) {
    a = count;
  }
  console.log(title);
  console.log(color);
  return (
    <div>
      <h1>Count: {count}</h1>

      <button
        onClick={() => {
          setCount(count + 1);
        }}
      >
        +
      </button>
      <Content count={a} />
    </div>
  );
};

export default color(Counter);
