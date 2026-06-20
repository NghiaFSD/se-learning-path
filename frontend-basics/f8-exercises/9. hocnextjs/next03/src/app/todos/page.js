import TodoAdd from "./TodoAdd";
import TodoAdd2 from "./TodoAdd2";
import TodoList from "./TodoList";

const Todos = () => {
  return (
    <div>
      <h1>Todo App</h1>
      <TodoList />
      {/* <TodoAdd /> */}
      <TodoAdd2 />
    </div>
  );
};

export default Todos;
