import { Roboto, Open_Sans } from "next/font/google";
import localFont from "next/font/local";

const roboto = Roboto({
  weight: ["300", "400", "700", "900"],
  subsets: ["latin"],
  display: "swap",
});

const openSans = Open_Sans({
  weight: ["300", "400", "700", "800"],
  subsets: ["latin"],
  display: "swap",
});

export const svnFont = localFont({
  src: "../assets/fonts/SVN-Fontbox-Boathouse-Filled.otf",
  display: "swap",
});

// export const metadata = {
//   title: "F8 - Học lập trình để đi làm",
//   description: "Học lập trình không khó",
//   openGraph: {
//     title: "F8 - Học lập trình để đi làm",
//     description: "Tôi muốn học lập trình",
//     images: [
//       "https://fullstack.edu.vn/images/image01.jpg",
//       "https://fullstack.edu.vn/images/image02.jpg",
//     ],
//   },
// };
export const generateMetadata = async ({ params, searchParams }) => {
  //Call API
  return {
    title: "F8 - Học lập trình để đi làm",
    description: "Học lập trình không khó",
    openGraph: {
      title: "F8 - Học lập trình để đi làm",
      description: "Tôi muốn học lập trình",
      images: [
        "https://fullstack.edu.vn/images/image01.jpg",
        "https://fullstack.edu.vn/images/image02.jpg",
      ],
    },
  };
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={roboto.className}>
      <body>{children}</body>
    </html>
  );
}

/*
SEO Onpage
- Semantic
- Meta: 
+ title
+ meta description
+ Open Graph (Các mạng xã hội phổ biến)

- File robots.txt: Cho phép, ngăn chặn bot của các bộ máy tìm kiếm truy cập vào các đường dẫn trên website để thu nhập dữ liệu (index)
- File sitemap.xml --> Khai báo file sitemap.xml cho công cụ: Google Search Console
- File favicon.ico
- json-ld
*/
