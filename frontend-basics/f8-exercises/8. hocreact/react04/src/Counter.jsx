import React, { useReducer } from "react";

const Counter = () => {
  /*
  action: object
  - type: Tên hành động: add, update, increment,...
  - payload: Dữ liệu của hành động
  */
  const reducer = (state, action = {}) => {
    //prev, current

    switch (action.type) {
      //type: feature/action
      case "counter/increment": {
        return { ...state, count: state.count + action.payload };
      }
      case "counter/decrement": {
        return { ...state, count: state.count - action.payload };
      }
      default: {
        return state;
      }
    }
  };
  const [state, dispatch] = useReducer(reducer, {
    count: 0,
  });
  //   console.log(state);
  const handleIncrement = () => {
    //useState -> Logic update ở đây
    dispatch({
      type: "counter/increment",
      payload: 2,
    });
  };
  const handleDecrement = () => {
    dispatch({
      type: "counter/decrement",
      payload: 3,
    });
  };
  return (
    <div>
      <h1>Count: {state.count}</h1>
      <button onClick={handleDecrement}>-</button>
      <button onClick={handleIncrement}>+</button>
    </div>
  );
};

export default Counter;

/*
Ôn tập: Vòng lặp reduce, useState, context, closure

Buổi sau: Build Store State sử dụng useReducer + React Context

- action
- actionCreator
- selector
- dispatch
- callApi -> setState bằng useReducer -> Thông qua Middleware

*/
