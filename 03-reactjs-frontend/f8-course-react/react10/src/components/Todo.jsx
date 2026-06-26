import { useEffect } from "react";
import { useDispatch, useSelector } from "react-redux";
import { fetchTodos } from "../redux/slice/todoSlice";

const Todo = () => {
  const todoList = useSelector((state) => state.todo.todoList);
  const status = useSelector((state) => state.todo.status);
  const dispatch = useDispatch();
  useEffect(() => {
    dispatch(fetchTodos());
  }, []);

  if (status === "error") {
    return <h1>Đã có lỗi xảy ra</h1>;
  }

  return (
    <div>
      <ul>
        {status !== "idle" &&
          (status === "pending" ? (
            <h4>Loading...</h4>
          ) : (
            todoList.map(({ id, title }) => <li key={id}>{title}</li>)
          ))}
      </ul>
    </div>
  );
};

export default Todo;
