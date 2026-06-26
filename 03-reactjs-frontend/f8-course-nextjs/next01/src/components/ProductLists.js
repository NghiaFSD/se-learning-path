"use client";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { useState } from "react";
const ProductLists = () => {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [form, setForm] = useState({
    status: "all",
    keywords: "",
  });
  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };
  const handleSubmit = (e) => {
    e.preventDefault();
    const url = pathname + "/?" + new URLSearchParams(form).toString();
    router.push(url);
  };
  return (
    <div>
      <h1>Danh sách sản phẩm</h1>
      <h3>Trạng thái: {searchParams.get("status")}</h3>
      <h3>Từ khóa: {searchParams.get("keywords")}</h3>
      <form action="" onSubmit={handleSubmit}>
        <select name="status" onChange={handleChange}>
          <option value="all">Tất cả</option>
          <option value="active">Kích hoạt</option>
          <option value="inactive">Chưa kích hoạt</option>
        </select>
        <input
          type="search"
          name="keywords"
          placeholder="Từ khóa tìm kiếm..."
          onChange={handleChange}
        />
        <button>Lọc</button>
      </form>
    </div>
  );
};

export default ProductLists;
