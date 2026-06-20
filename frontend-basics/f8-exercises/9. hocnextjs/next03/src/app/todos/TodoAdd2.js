"use client";
import { useRef } from "react";
import { addTodo } from "./action";
const TodoAdd2 = () => {
  const inputRef = useRef("");
  return (
    <div>
      <form
        action={async (formData) => {
          await addTodo(formData);
          inputRef.current.value = "";
        }}
      >
        <input
          type="text"
          name="name"
          placeholder="Tên công việc..."
          ref={inputRef}
        />
        <button>Thêm</button>
      </form>
    </div>
  );
};

export default TodoAdd2;
