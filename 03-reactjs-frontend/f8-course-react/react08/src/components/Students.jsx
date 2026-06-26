//Data
import { useState, useTransition } from "react";
import students from "./students.json";
const Students = () => {
  const [isPending, startTransition] = useTransition();
  const [keyword, setKeyword] = useState("");
  const handleSearch = (e) => {
    startTransition(() => {
      setKeyword(e.target.value);
    });
  };
  console.log(keyword);

  return (
    <div>
      <input type="search" placeholder="Search..." onChange={handleSearch} />
      <h3>Danh sách sinh viên</h3>
      {students.map(({ id, fullName }) => {
        // console.log("Loop");
        if (
          keyword.length &&
          fullName.toLowerCase().includes(keyword.toLowerCase())
        ) {
          return (
            <h4 key={id} style={{ background: "yellow" }}>
              {fullName}
            </h4>
          );
        }
        return <h4 key={id}>{fullName}</h4>;
      })}
    </div>
  );
};

export default Students;
