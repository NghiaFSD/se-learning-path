/* eslint-disable react-refresh/only-export-components */
import { memo } from "react";
const Content = () => {
  console.log("Content Render");
  return (
    <div>
      <h2>Học React không khó</h2>
    </div>
  );
};

export default memo(Content);

//Higher Order Component (HOC)
//memo -> Chỉ render khi props thay đổi
