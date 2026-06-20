"use server";
import { revalidatePath } from "next/cache";
import { todoApi } from "./TodoList";
import { redirect } from "next/navigation";
import { headers } from "next/headers";
const postTodo = async (data) => {
  const response = await fetch(todoApi, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(data),
  });
  if (response.ok) {
    console.log(response);
  }
};
export const addTodo = async (formData) => {
  const name = formData.get("name");
  await postTodo({ name });
  const headerList = headers();
  const pathname = headerList.get("next-url"); //Lấy pathname
  revalidatePath(pathname);

  //Chuyển hướng về trang chủ
  //   redirect("/");
};
