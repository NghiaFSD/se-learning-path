import React, { forwardRef, useImperativeHandle, useRef } from "react";
import video from "./video.mp4";
const Video = (props, ref) => {
  const videoRef = useRef(); //Ref nội bộ trong component video
  useImperativeHandle(ref, () => ({
    chay: () => {
      videoRef.current.play();
    },
    dung: () => {
      videoRef.current.pause();
    },
  }));
  return <video ref={videoRef} src={video} />;
};

export default forwardRef(Video);
