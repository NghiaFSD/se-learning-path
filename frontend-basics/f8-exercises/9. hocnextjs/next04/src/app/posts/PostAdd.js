"use client";
import { useState } from "react";
import { postApi } from "./PostList";
// import { useSWRConfig } from "swr"
import { mutate } from "swr";
// --> Mutation Global --> Bắt buộc phải thêm key khi gọi hàm mutate
const PostAdd = () => {
  const [name, setName] = useState("");
  // const { mutate } = useSWRConfig();
  const handleSubmit = (e) => {
    e.preventDefault();
    addPost({ title: name });
  };
  const handleChange = (e) => {
    setName(e.target.value);
  };
  const addPost = async (data) => {
    const response = await fetch(postApi, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(data),
    });
    if (response.ok) {
      mutate(postApi);
      setName("");
    }
  };
  return (
    <div>
      <form action="" onSubmit={handleSubmit}>
        <input
          type="text"
          placeholder="Title"
          onChange={handleChange}
          value={name}
        />
        <button>Thêm</button>
      </form>
    </div>
  );
};

export default PostAdd;
