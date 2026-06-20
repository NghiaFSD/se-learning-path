import React, { useEffect, useRef, useState } from "react";
import Button from "./Button";

const Search = () => {
  //   const helloRef = useRef(0);
  //   const [number, setNumber] = useState(0);
  //   let a = 0;
  //   const handleClick = () => {
  //     setNumber(number + 1);
  //     helloRef.current++;
  //     a++;
  //     console.log(`number: ${number}`, `Ref: ${helloRef.current}`);
  //   };
  //   console.log(`Ref: ${helloRef.current}`, `a: ${a}`);
  const inputRef = useRef();
  const buttonRef = useRef();
  //   console.log("1");
  //useEffect -> Side Effect
  useEffect(() => {
    // console.log(inputRef);
    inputRef.current.focus();
    //   console.log("3");
    console.log(buttonRef);
  }, []);
  return (
    <div>
      <input
        ref={inputRef}
        type="text"
        placeholder="Nhập từ khóa tìm kiếm..."
      />
      <Button ref={buttonRef} />
    </div>
  );
};

export default Search;
