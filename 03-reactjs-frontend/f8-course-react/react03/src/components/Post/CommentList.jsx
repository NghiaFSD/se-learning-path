import React from "react";

const CommentList = ({ comments }) => {
  return (
    <div className="py-3">
      <h3>Bình luận</h3>
      {comments.length ? (
        comments.map(({ name, message }, index) => (
          <div className="mb-3" key={index}>
            <h5>{name}</h5>
            <p>{message}</p>
          </div>
        ))
      ) : (
        <p>Hãy là người bình luận đầu tiên</p>
      )}
    </div>
  );
};

export default CommentList;
