import React from "react";
import Header from "./Components/Header";
import Footer from "./Components/Footer";

const App = () => {
  const user = {
    name: "Hoàng An",
    email: "hoangan.web@gmail.com",
    age: 31,
  };
  return (
    <div>
      <h1>React không khó</h1>
      <Header title="Học lập trình tại F8" {...user} />
      <Footer>
        <h3>F8 - Hoàng An</h3>
      </Footer>
    </div>
  );
};

export default App;

//Props => Truyền dữ liệu từ component cha sang component con
