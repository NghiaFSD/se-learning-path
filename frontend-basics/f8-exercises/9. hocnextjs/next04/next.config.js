/** @type {import('next').NextConfig} */
const nextConfig = {
  env: {
    SERVER_API: process.env.SERVER_API,
  },
  images: {
    remotePatterns: [
      {
        hostname: "picsum.photos",
      },
    ],
  },
};

module.exports = nextConfig;
