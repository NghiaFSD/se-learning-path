"use client";
import useSWR from "swr";

export const fetcher = (...args) => fetch(...args).then((res) => res.json());
export const postApi = `${process.env.NEXT_PUBLIC_SERVER_API}/posts`;
// export const postApi = `https://jsonplaceholder.typicode.com/posts`;

const PostList = () => {
  //   setInterval(() => {
  //     console.log(navigator.onLine);
  //   }, 1000);
  const {
    data: posts,
    isLoading,
    error,
    mutate,
  } = useSWR(postApi, fetcher, {
    // revalidateOnFocus: false,
    // refreshInterval: 2000,
    revalidateOnReconnect: true,
    // refreshWhenOffline: true,
  });
  if (isLoading) {
    return <h3>Loading...</h3>;
  }
  if (error) {
    return <h3>Đã có lỗi xảy ra</h3>;
  }
  return (
    <div>
      <h1>Posts</h1>
      {posts?.map(({ id, title }) => (
        <h3 key={id}>{title}</h3>
      ))}
    </div>
  );
};

export default PostList;
