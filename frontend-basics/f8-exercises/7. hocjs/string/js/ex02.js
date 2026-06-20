var keyword = "a";

var title = `<p>Từ khóa tìm kiếm: <b>${keyword}</b></p>`;

var content = `Lorem Ipsum is hoàng an simply dummy text of HOÀNG AN the printing and typesetting industry. Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived hoàng An not hOàng aN only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.`;

// if (position !== -1) {
//   content =
//     content.slice(0, position) +
//     `<span>${content.slice(position, position + keyword.length)}</span>` +
//     content.slice(position + keyword.length);
//   count++;
// }

//Phần 1: Đầu đến position
//Phần 2: Từ postion đến hết keyword
//Phần 3: Sau keyword đến hết

var count = 0;

var result = "";

var position = content.toLowerCase().indexOf(keyword.toLowerCase());

while (position !== -1) {
  //Lưu lại nội dung từ đầu cho đến hết keyword và bổ sung thẻ span
  result +=
    content.slice(0, position) +
    `<span>${content.slice(position, position + keyword.length)}</span>`;

  //Xóa bỏ nội dung đã được lưu vào biến result
  content = content.slice(position + keyword.length);

  //Thực hiện tìm lại với content mới
  position = content.toLowerCase().indexOf(keyword.toLowerCase());

  count++;
}

console.log(result);
// console.log(content);
result += content;
//Trong trường không tìm thấy => Bị thiếu đoạn content cuối

var countHtml = `<p>Đã tìm thấy <b>${count}</b> lần với từ khóa <b>${keyword}</b></p>`;

document.write(title + result + countHtml);
