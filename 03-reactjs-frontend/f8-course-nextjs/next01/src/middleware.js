import { NextResponse } from "next/server";

const isLogin = true;
// This function can be marked `async` if using `await` inside
export function middleware(request) {
  //Check trạng thái đăng nhập
  const response = NextResponse.next();
  response.cookies.set("email", "hoangan.web@gmail.com");
  response.headers.set("x-api-key", "1234");
  return response;
  //   const pathname = request.nextUrl.pathname;
  //   if (pathname === "/don-hang") {
  //     return NextResponse.rewrite(new URL("/orders", request.url));
  //   }
  //   if (!isLogin) {
  //     return NextResponse.redirect(new URL("/", request.url));
  //   }
}

// See "Matching Paths" below to learn more
export const config = {
  matcher: ["/admin/:path*", "/don-hang/:path*"],
};

/*
- NextRequest --> Lấy được các thông tin từ http request (method, headers, body, url,...)
- NextResponse --> Trả về các thông tin (redirect, headers, response message body: text, html, json,...) 
*/
