import { useCallback, useMemo } from "react";
import { useState } from "react";
import MoneyHistories from "./MoneyHistories";

const MoneyTransfer = () => {
  const [histories, setHistories] = useState([]);
  const [cost, setCost] = useState(0);
  const handleChange = (e) => {
    setCost(e.target.value);
  };
  const handleSubmit = (e) => {
    e.preventDefault();
    setHistories([...histories, +cost]);
    setCost("");
  };
  const handleResetHistories = useCallback(() => {
    setHistories([]);
  }, []);
  const total = useMemo(
    () =>
      histories.reduce((acc, cur) => {
        console.log("Total");
        return acc + cur;
      }, 0),
    [histories],
  );
  //Giải pháp: Cache giá trị của biến total
  //--> ví dụ: Khi nào histories thay đổi --> tính toán lại

  return (
    <div>
      <form action="" onSubmit={handleSubmit}>
        <input
          type="number"
          placeholder="Số tiền..."
          onChange={handleChange}
          value={cost}
        />
        <button>Add</button>
      </form>
      <MoneyHistories
        histories={histories}
        total={total}
        onResetHistories={handleResetHistories}
      />
    </div>
  );
};

export default MoneyTransfer;

/*
useMemo(callback, deps) --> Cache giá trị tính toán qua mỗi lần re-render
- Trả về giá trị
- Callback phải có return
- Áp dụng cho các biểu thức logic

useCallback(callback, deps) --> Cache function qua mỗi lần re-render
- Callback không có return
- Áp dụng cho việc khởi tạo hàm
*/
