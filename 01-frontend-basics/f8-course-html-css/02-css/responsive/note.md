# Breakpoint

- Điểm dừng mà tại đó giao diện sẽ thay đổi
- Không có breakpoint cho tất cả các dự án
- Không khai báo tất cả các breakpoint khi làm dự án (Tùy dự án)
- Một số breakpoint phổ biến

* 576px
* 768px
* 992px
* 1200px
* 1400px

# Viewport

- Khung nội dung người dùng trên thấy trên trang web
- Để xây dựng website responsive => Cần có thẻ meta viewport
  => Cross Browser Testing

# Media Query

## Desktop First

CSS Giao diện 1400px trở lên

@media screen and (max-width: 1400px) {
Giao diện màn hình <= 1400px
}

@media screen and (max-width: 1200px) {
Giao diện màn hình <= 1200px
}

@media screen and (max-width: 992px) {
Giao diện màn hình <= 992px
}

@media screen and (max-width: 768px) {
Giao diện màn hình <= 768px
}

@media screen and (max-width: 576px) {
Giao diện màn hình <= 576px
}

## Mobile First

@media screen and (min-width: 576px) {

}

@media screen and (min-width: 768px) {

}

@media screen and (min-width: 992px) {

}

@media screen and (min-width: 1200px) {

}

@media screen and (min-width: 1400px) {

}

- all => Tất cả giao diện web và giao diện trang in
- screen => Chỉ hoạt động ở giao diện web
- print => Chỉ hoạt động ở giao diện trang in

Lưu ý: Chỉ viết media query theo 1 chiều (max-width hoặc min-width)

- max-width => Desktop First
- min-width => Mobile First

## Buổi sau

- Thử làm phần Header
- Thử làm phần chia cột section products
- Tự build Grid System giống bootstrap sử dụng CSS thuần
