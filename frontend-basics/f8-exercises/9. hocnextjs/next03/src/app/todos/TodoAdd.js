"use client";
import { useRouter } from "next/navigation";
import { useState } from "react";
import { todoApi } from "./TodoList";

const TodoAdd = () => {
  const [name, setName] = useState("");
  const router = useRouter();
  const handleSubmit = (e) => {
    e.preventDefault();
    postTodo({ name });
  };
  const postTodo = async (data) => {
    const response = await fetch(todoApi, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    });
    if (response.ok) {
      router.refresh();
      setName("");
    }
  };
  return (
    <div>
      <form action="" onSubmit={handleSubmit}>
        <input
          type="text"
          name="name"
          placeholder="Tên công việc..."
          value={name}
          onChange={(e) => setName(e.target.value)}
        />
        <button>Thêm</button>
      </form>
    </div>
  );
};

export default TodoAdd;
