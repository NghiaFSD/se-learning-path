import Counter from "./components/Counter";
import Counter2 from "./components/Counter2";
import Input from "./components/Input";
import Search from "./components/Search";
import VideoPlayer from "./components/VideoPlayer/VideoPlayer";

const App = () => {
  return (
    <div>
      {/* <h1>Ref</h1>
      <VideoPlayer /> */}
      {/* <Search /> */}
      {/* <Counter title="Hello F8" /> */}
      {/* <h1>useLayoutEffect</h1> */}
      {/* <Counter2 /> */}
      <h1>useId</h1>
      <Input title={"Tên"} />
      <Input title={"Email"} />
      <Input title={"Địa chỉ"} />
    </div>
  );
};

export default App;
