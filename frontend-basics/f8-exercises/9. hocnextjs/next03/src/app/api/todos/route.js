import { NextResponse } from "next/server";
export const todoApi = `http://localhost:3005/todos`;
export async function GET() {
  const response = await fetch(todoApi);
  const data = await response.json();
  return NextResponse.json(
    {
      status: "success",
      data: data,
    },
    {
      status: 404,
    },
  );
}
