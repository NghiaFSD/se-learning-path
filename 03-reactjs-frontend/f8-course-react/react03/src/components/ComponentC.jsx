import React, { useContext } from "react";
import { AppContext } from "../App";
const ComponentC = () => {
  const context = useContext(AppContext);

  return (
    <div>
      <h1>Component C</h1>
      <button
        onClick={() => {
          context.handleUpdateTitle("Hello F8");
        }}
      >
        Click me
      </button>
    </div>
  );
};

export default ComponentC;
