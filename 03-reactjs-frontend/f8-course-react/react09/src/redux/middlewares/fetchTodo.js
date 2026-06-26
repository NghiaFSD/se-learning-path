//Thunk Middleware --> Function trả về 1 function khác
export const fetchTodo = () => {
  return async (dispatch) => {
    const response = await fetch(`https://jsonplaceholder.typicode.com/todos`);
    const data = await response.json();
    dispatch({
      type: "todo/fetch",
      payload: data,
    });
  };
};
