import { v4 as uuid } from "uuid";
import React, { useEffect, useState } from "react";
import "bootstrap/dist/css/bootstrap.min.css";
import { useSelector } from "../core/useSelector";
import { setLocalStorage, getLocalStorage } from "../utils/localStorage";
const Chat = () => {
  const { state, dispatch } = useSelector();
  const [messageValue, setMessageValue] = useState("");
  const handleChangeInput = (e) => {
    setMessageValue(e.target.value);
  };
  const handleSumbit = (e) => {
    e.preventDefault();
    if (!messageValue.trim().length) {
      alert("Vui lòng nhập tin nhắn");
      return;
    }
    const message = {
      id: uuid(),
      message: messageValue,
    };
    dispatch({
      type: "message/add",
      payload: message,
    });
    setMessageValue(""); //Reset Input
  };

  useEffect(() => {
    console.log("Hello");
    console.log(state.messages);
    //Đọc message
    const timeout = setTimeout(() => {
      dispatch({
        type: "message/fetch",
        payload: getLocalStorage("messages"),
      });
    }, 100);

    //Lưu vào localStorage -> Khi thêm
    if (state.messages.length) {
      setLocalStorage("messages", state.messages);
    }
    return () => {
      clearTimeout(timeout);
    };
  }, [state.messages]);

  //   useEffect(() => {
  //     var array = JSON.parse(localStorage.getItem("messages"));
  //     dispatch({ type: "message/add", payload: array });
  //   }, [state]);
  return (
    <div className="container">
      <div className="chat my-3 p-3" style={{ border: "1px solid red" }}>
        {state.messages.map(({ id, message }) => (
          <div key={id} className="message">
            <div className="mb-2">{message}</div>
          </div>
        ))}
        <form action="" onSubmit={handleSumbit}>
          <div className="input-group">
            <input
              type="text"
              className="form-control"
              placeholder="Tin nhắn..."
              onChange={handleChangeInput}
              value={messageValue}
            />
            <button className="btn btn-primary">Gửi</button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default Chat;
