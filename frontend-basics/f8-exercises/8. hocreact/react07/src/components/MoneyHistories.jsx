/* eslint-disable react-refresh/only-export-components */
/* eslint-disable react/prop-types */
import React from "react";
const MoneyHistories = ({ histories, total, onResetHistories }) => {
  console.log("MoneyHistories Re-render");
  return (
    <div>
      <h2>Lịch sử chuyển tiền</h2>
      {histories.map((item, index) => (
        <h3 key={index}>{item.toLocaleString()}đ</h3>
      ))}
      <h2>Tổng tiền: {total.toLocaleString()}</h2>
      <button onClick={onResetHistories}>Xóa lịch sử</button>
    </div>
  );
};

export default React.memo(MoneyHistories);
