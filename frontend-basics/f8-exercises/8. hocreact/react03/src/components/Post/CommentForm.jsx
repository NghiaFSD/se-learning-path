import React, { useState } from "react";

const CommentForm = ({ onComment }) => {
  const [form, setForm] = useState({
    name: "",
    message: "",
  });
  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };
  const handleSubmit = (e) => {
    e.preventDefault();
    onComment(form);
    setForm({
      ...form,
      message: "",
    });
  };
  return (
    <form onSubmit={handleSubmit}>
      <div className="mb-3">
        <input
          type="text"
          name="name"
          className="form-control"
          placeholder="Tên..."
          onChange={handleChange}
          value={form.name}
          required
        />
      </div>
      <div className="mb-3">
        <textarea
          className="form-control"
          name="message"
          placeholder="Nội dung..."
          onChange={handleChange}
          value={form.message}
          required
        ></textarea>
      </div>
      <div className="text-end">
        <button type="submit" className="btn btn-primary">
          Bình luận
        </button>
      </div>
    </form>
  );
};

export default CommentForm;
