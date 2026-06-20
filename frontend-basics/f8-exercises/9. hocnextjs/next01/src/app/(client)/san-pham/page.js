import { Suspense } from "react";
import ProductLists from "@/components/ProductLists";

export const metadata = {
  title: "Danh sách sản phẩm",
};

// http://localhost:3000/san-pham?keywords=abc&status=active
const Products = () => {
  return (
    <Suspense fallback={<p>Loading...</p>}>
      <ProductLists />
    </Suspense>
  );
};

export default Products;
