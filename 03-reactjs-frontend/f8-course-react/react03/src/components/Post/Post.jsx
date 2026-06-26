import React, { useEffect, useState } from "react";
import CommentList from "./CommentList";
import CommentForm from "./CommentForm";

const Post = ({ onSetCount }) => {
  //setState -> Comment Post bị re-render
  // -> CommentList và CommentFrom bị re-render
  // -> Truyền dữ liệu xuống CommentList thông qua props
  const [comments, setComments] = useState([]);
  const handleAddComment = (comment) => {
    setComments([...comments, comment]);
  };

  useEffect(() => {
    onSetCount(comments.length);
  }, [comments]);
  return (
    <div className="container py-3">
      <h2>Thông tin bài viết</h2>
      <p>
        Lorem ipsum dolor sit, amet consectetur adipisicing elit. Provident
        adipisci accusantium nisi sit optio sint dignissimos distinctio expedita
        aperiam eum? Obcaecati sint reprehenderit accusamus magni harum
        aspernatur pariatur officiis. Aliquam.
      </p>
      <CommentList comments={comments} />
      <CommentForm onComment={handleAddComment} />
    </div>
  );
};

export default Post;
