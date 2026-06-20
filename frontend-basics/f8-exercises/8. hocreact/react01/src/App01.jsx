import Header from "./Components/Header";
import React, { Fragment } from "react";
function App() {
  // const h1 = React.createElement(
  //   "h1",
  //   {
  //     id: "title",
  //     className: "title",
  //     style: {
  //       color: "red",
  //       fontStyle: "italic",
  //     },
  //     onClick: (e) => {
  //       console.log("Click me", e);
  //     },
  //   },
  //   "Hello F8",
  // );
  // const h2 = React.createElement("h2", {}, "Học React không khó");

  // const number = 10;
  // const range = [...Array(number).keys()];
  // const li = range.map((index) =>
  //   React.createElement("li", {}, `Item ${index + 1}`),
  // );
  // const ul = React.createElement(
  //   "ul",
  //   {
  //     className: "menu",
  //   },
  //   ...li,
  // );
  // const div = React.createElement(
  //   "div",
  //   {
  //     className: "container",
  //   },
  //   h1,
  //   ul,
  //   h2,
  // );
  const Product = () => {
    return <h2>Danh sách sản phẩm</h2>;
  };

  const handleClick = (text) => {
    console.log("Hello F8", text);
  };

  const title = "Xin chào F8";
  const isPrimary = false;

  // let welcome = <h2>Chào mừng bạn đã quay trở lại</h2>;
  const isLogin = false;
  // if (!isLogin) {
  //   welcome = <h2>Vui lòng đăng nhập để tiếp tục</h2>;
  // }

  //Render 1 danh sách -> Chuyển về array
  const lists = ["Item 1", "Item 2", "Item 3"];
  const content = `
  <h2>Sản phẩm 1</h2>
  <p>Mô tả sản phẩm</p>
  `;

  return (
    <>
      <Product />
      <h1>{title}</h1>

      {lists.map((item, index) => (
        <h3 key={index}>{item}</h3>
      ))}
      {isLogin ? (
        <h2>Chào mừng bạn quay trở lại</h2>
      ) : (
        <h3>Vui lòng đăng nhập để tiếp tục</h3>
      )}
      {isLogin && (
        <ul className="menu">
          <li>Item 1</li>
          <li>Item 2</li>
          <li>Item 3</li>
        </ul>
      )}

      <button
        className={`btn ${isPrimary ? "btn-primary" : ""}`}
        onClick={() => {
          handleClick("Hoàng An");
        }}
      >
        Click me
      </button>
      <div
        dangerouslySetInnerHTML={{
          __html: content,
        }}
      >
        {/* <iframe
          width={560}
          height={315}
          src="https://www.youtube.com/embed/80vgCpHXs98?si=uffRmK9mBm7wFrFe"
          title="YouTube video player"
          border={0}
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
          allowFullScreen=""
        /> */}
      </div>
    </>
  );
}

export default App;
