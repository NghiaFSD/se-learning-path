import Image from "next/image";
import { svnFont } from "./layout";
const Page = () => {
  const jsonLd = {
    "@context": "https://schema.org",
    "@type": "Product",
    name: "abc",
  };
  console.log(process.env.SERVER_API);
  return (
    <div>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />
      <h1>HomePage</h1>
      {/* <Image
        src="/assets/images/image01.png"
        width="200"
        height="100"
        alt="Image"
      /> */}
      {/* <img
        src="/assets/images/image01.png"
        alt=""
        style={{
          maxWidth: "300px",
        }}
      /> */}
      <Image
        src="https://picsum.photos/200"
        width={200}
        height={200}
        alt="Image"
      />
      <h1 className={svnFont.className}>F8 - Học lập trình để đi làm</h1>
    </div>
  );
};

export default Page;
