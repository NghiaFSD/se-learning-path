import Link from "next/link";
import Image from "next/image";
import errorImage from "@/assets/images/not-found.jpg";
const NotFound = () => {
  return (
    <div>
      <h1>Page Not Found</h1>
      <Image
        src={errorImage}
        alt="Page Not Found"
        style={{ maxWidth: "100%", height: "auto" }}
      />
      <p>Lạc đường rồi. Vui lòng quay lại trang chủ</p>
      <Link href={"/"}>Về trang chủ</Link>
    </div>
  );
};

export default NotFound;
