import { useEffect } from "react";
import { useDispatch } from "react-redux";
import { fetchTodo } from "../redux/middlewares/fetchTodo";

const Todo = () => {
  const dispatch = useDispatch();
  useEffect(() => {
    //1. dispatch tới action --> Reducer của Store
    //2. dispatch tới middleware --> Middleware call api --> dispatch tới action --> Reducer của Store
    dispatch(fetchTodo());
  }, []);
  return (
    <div>
      <h1>Todo App</h1>
    </div>
  );
};

export default Todo;
