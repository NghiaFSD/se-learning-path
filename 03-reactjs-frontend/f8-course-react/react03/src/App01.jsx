import "bootstrap/dist/css/bootstrap.min.css";

import React, { useState } from "react";
import Post from "./components/Post/Post";
import Notifications from "./components/Notifications";

const App = () => {
  const [commentCount, setCommentCount] = useState(0);
  const handleSetCount = (number) => {
    setCommentCount(number);
  };

  return (
    <>
      <div className="container">
        <Notifications commentCount={commentCount} />
      </div>
      <Post onSetCount={handleSetCount} />
    </>
  );
};

export default App;
