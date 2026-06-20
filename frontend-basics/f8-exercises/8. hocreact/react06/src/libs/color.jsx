export const color = (Component) => {
  const color = "#" + Math.random().toString(16).slice(-6);
  //Kế thừa logic
  return function MyComponent(props) {
    return (
      <div className="color" style={{ color }}>
        <Component {...props} color={color} />
      </div>
    );
  };
};

/*
Tạo ra 1 component mới bên trong 1 hàm khác

- Hàm color -> Hàm bọc (Cấp cao hơn)
*/
