import { config } from "./config.js";
import { client } from "./client.js";

const { PAGE_LIMIT } = config;

const render = (posts) => {
  const postsEl = document.querySelector(".posts");
  postsEl.innerText = ``;
  if (posts.length) {
    posts.forEach(({ id, title, excerpt }) => {
      const postItem = document.createElement("div");
      postItem.classList.add("post-item");
      const h2 = document.createElement("h2");
      const a = document.createElement("a");
      a.innerText = title;
      a.href = "#";
      h2.append(a);
      postItem.append(h2);

      const p = document.createElement("p");
      p.innerText = excerpt;
      postItem.append(p);

      const removeBtn = document.createElement("span");

      removeBtn.innerText = "Xóa";
      removeBtn.classList.add("remove");
      removeBtn.addEventListener("click", function () {
        if (confirm("Bạn có chắc chắn?")) {
          removePost(id);
        }
      });
      postItem.append(removeBtn);

      postsEl.append(postItem);
    });
  }
};

const renderPaginate = (totalPage) => {
  const paginateEl = document.querySelector(".paginate");
  paginateEl.innerText = "";
  if (totalPage > 1) {
    //Prev Button
    if (currentPage > 1) {
      const spanPrev = document.createElement("span");
      const aPrev = document.createElement("a");
      aPrev.href = "#";
      aPrev.addEventListener("click", (e) => {
        e.preventDefault();
        goPage(--currentPage);
      });
      aPrev.innerText = "Prev";
      spanPrev.append(aPrev);
      paginateEl.append(spanPrev);
    }

    //Page Number
    for (let page = 1; page <= totalPage; page++) {
      const span = document.createElement("span");
      if (+page === +currentPage) {
        span.classList.add("active");
      }
      const a = document.createElement("a");
      a.href = "#";
      a.innerText = page;
      a.addEventListener("click", (e) => {
        e.preventDefault();
        goPage(page);
      });

      span.append(a);
      paginateEl.append(span);
    }

    //Next Button
    if (currentPage < totalPage) {
      const spanNext = document.createElement("span");
      const aNext = document.createElement("a");
      aNext.href = "#";
      aNext.addEventListener("click", (e) => {
        e.preventDefault();
        goPage(++currentPage);
      });
      aNext.innerText = "Next";
      spanNext.append(aNext);
      paginateEl.append(spanNext);
    }
  }
};

const goPage = (page) => {
  window.scroll({
    top: 0,
    behavior: "smooth",
  });

  currentPage = page;

  getPosts({
    _sort: sort,
    _order: order,
    _limit: limit,
    _page: currentPage,
    q: keyword,
  });
};

const getPosts = async (query = {}) => {
  const queryString = new URLSearchParams(query).toString();
  const { response, data } = await client.get(`/posts?${queryString}`);
  const total = response.headers.get("x-total-count");

  const totalPage = Math.ceil(total / PAGE_LIMIT);

  renderPaginate(totalPage);

  render(data);
};

const addPost = async (data) => {
  const { response } = await client.post("/posts", data);
  if (response.ok) {
    //Render
    currentPage = 1;
    getPosts({
      _sort: "id",
      _order: "desc",
      _limit: limit,
      _page: currentPage,
    });

    //Đóng form
    postForm.innerText = "";

    //Reset Select Sort
    sortByEl.value = "latest";
  }
};

const removePost = async (id) => {
  const { response } = await client.delete(`/posts/${id}`);
  if (response.ok) {
    currentPage = 1;
    getPosts({
      _sort: "id",
      _order: "desc",
      _limit: limit,
      _page: currentPage,
    });
    //Reset Select Sort
    sortByEl.value = "latest";
  }
};

//Khởi tạo các giá trị mặc định
let sort = "id";
let order = "desc";
let keyword = "";
let limit = PAGE_LIMIT;
let currentPage = 1;

getPosts({
  _sort: sort,
  _order: order,
  _limit: limit,
  _page: currentPage,
});

const searchForm = document.querySelector(".search");
searchForm.addEventListener("submit", (e) => {
  e.preventDefault();
  keyword = e.target.children[0].value;
  getPosts({
    q: keyword,
    _sort: sort,
    _order: order,
    _limit: limit,
    _page: currentPage,
  });
  e.target.children[0].value = "";
});

const sortByEl = document.querySelector(".sort-by");
sortByEl.addEventListener("change", (e) => {
  order = e.target.value === "latest" ? "desc" : "asc";
  getPosts({
    q: keyword,
    _sort: sort,
    _order: order,
    _limit: limit,
    _page: currentPage,
  });
});

const postNewBtn = document.querySelector(".post-new");
const postForm = document.querySelector(".post-form");
postNewBtn.addEventListener("click", function () {
  postForm.innerText = "";
  const form = document.createElement("form");
  form.addEventListener("submit", handleSubmitForm);
  const titleEl = document.createElement("input");
  titleEl.placeholder = `Tiêu đề bài viết`;
  titleEl.required = true;
  form.append(titleEl);

  const excerptEl = document.createElement("textarea");
  excerptEl.placeholder = "Mô tả ngắn";
  excerptEl.required = true;
  form.append(excerptEl);

  const contentEl = document.createElement("textarea");
  contentEl.placeholder = "Nội dung";
  contentEl.required = true;
  form.append(contentEl);

  const submitBtn = document.createElement("button");
  submitBtn.innerText = "Lưu";
  form.append(submitBtn);

  postForm.append(form);
});

const handleSubmitForm = (e) => {
  e.preventDefault();
  const fieldList = e.target.children;
  const [titleEl, excerptEl, contentEl] = Array.from(fieldList);
  const title = titleEl.value;
  const excerpt = excerptEl.value;
  const content = contentEl.value;
  addPost({ title, excerpt, content });
};
