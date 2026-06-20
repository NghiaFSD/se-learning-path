import React, { useId } from "react";

const Input = ({ title }) => {
  const id = useId();
  return (
    <div>
      <label htmlFor={id}>{title}</label>
      <input type="text" id={id} placeholder="Vui lòng nhập" />
    </div>
  );
};

export default Input;
