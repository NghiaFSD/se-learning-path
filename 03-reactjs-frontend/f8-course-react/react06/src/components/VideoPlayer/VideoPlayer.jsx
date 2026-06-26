import React, { useEffect, useRef } from "react";
import Video from "./Video";

const VideoPlayer = () => {
  const videoRef = useRef();
  useEffect(() => {
    // videoRef.current.remove();
    console.log(videoRef.current);
  }, []);
  return (
    <div>
      <Video ref={videoRef} />
      <hr />
      <button
        onClick={() => {
          videoRef.current.chay();
        }}
      >
        Play
      </button>
      <button
        onClick={() => {
          videoRef.current.dung();
        }}
      >
        Pause
      </button>
    </div>
  );
};

export default VideoPlayer;
