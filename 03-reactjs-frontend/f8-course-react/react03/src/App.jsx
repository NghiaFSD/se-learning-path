import React, { useState } from "react";
import ComponentA from "./components/ComponentA";
import ComponentB from "./components/ComponentB";
//Khởi tạo Context
export const AppContext = React.createContext();
const App = () => {
  const [title, setTitle] = useState("");
  const data = {
    name: "Hoàng An",
    email: "hoangan.web@gmail.com",
    title,
  };
  const handleUpdateTitle = (value) => {
    setTitle(value);
  };
  return (
    <AppContext.Provider
      value={{
        data,
        handleUpdateTitle,
      }}
    >
      <ComponentA />
      <ComponentB />
    </AppContext.Provider>
  );
};

export default App;
