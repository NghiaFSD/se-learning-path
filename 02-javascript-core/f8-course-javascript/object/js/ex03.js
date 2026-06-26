var posts = [
  {
    title: "Bài viết 1",
    thumbnail:
      "https://fastly.picsum.photos/id/787/500/300.jpg?hmac=_n0X4bzKsegouwOqIbajrf01jYobChiQBxc6yxhFaac",
    excerpt: `Lorem, ipsum dolor sit amet consectetur adipisicing elit. Unde, est
        nobis veritatis iste inventore commodi, earum laudantium provident
        repellat ipsa enim voluptatem quam, consequuntur sit? Saepe ipsa
        deserunt neque expedita?`,
  },

  {
    title: "Bài viết 2",
    thumbnail:
      "https://fastly.picsum.photos/id/787/500/300.jpg?hmac=_n0X4bzKsegouwOqIbajrf01jYobChiQBxc6yxhFaac",
    excerpt: `Lorem, ipsum dolor sit amet consectetur adipisicing elit. Unde, est
        nobis veritatis iste inventore commodi, earum laudantium provident
        repellat ipsa enim voluptatem quam, consequuntur sit? Saepe ipsa
        deserunt neque expedita?`,
  },

  {
    title: "Bài viết 3",
    thumbnail:
      "https://fastly.picsum.photos/id/787/500/300.jpg?hmac=_n0X4bzKsegouwOqIbajrf01jYobChiQBxc6yxhFaac",
    excerpt: `Lorem, ipsum dolor sit amet consectetur adipisicing elit. Unde, est
        nobis veritatis iste inventore commodi, earum laudantium provident
        repellat ipsa enim voluptatem quam, consequuntur sit? Saepe ipsa
        deserunt neque expedita?`,
  },
];
var html = `<div class="posts">
${posts
  .map(function (post, index) {
    return `<div class="post-item">
        <img
          src="${post.thumbnail}"
          alt="${post.title}"
          class="${index % 2 !== 0 ? "right" : ""}"
        />
        <h3>${post.title}</h3>
        <p>
          ${post.excerpt}
        </p>
      </div>`;
  })
  .join("")}
</div>`;

document.write(html);
