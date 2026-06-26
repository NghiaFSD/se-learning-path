export const fetcher = ({ url, token }) => {
  console.log(token);
  return fetch(url, {
    headers: {
      "x-token": token,
    },
  }).then((response) => response.json());
};
