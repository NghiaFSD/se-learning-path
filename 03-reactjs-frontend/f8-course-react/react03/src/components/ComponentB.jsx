import React, { useContext } from "react";
import { AppContext } from "../App";
import ComponentC from "./ComponentC";
const ComponentB = () => {
  const context = useContext(AppContext);
  // console.log(context);
  return (
    <div>
      <h1>Component B</h1>
      <h2>{context.data.title}</h2>
      <ComponentC />
    </div>
  );
};

export default ComponentB;
