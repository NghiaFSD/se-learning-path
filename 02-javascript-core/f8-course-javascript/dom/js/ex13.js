var progressBar = document.querySelector(".progress-bar");

var progress = progressBar.querySelector(".progress");

var progressDot = progress.querySelector("span");

var progressBarWidth = progressBar.clientWidth;

var isDrag = false;
var initialClientX = 0;
var initalRate = 0;
var rate = 0;

progressBar.addEventListener("mousedown", function (e) {
  //   console.log(e.offsetX, progressBarWidth);
  //Tính tỷ lệ phần trăm giữa vị trí click với chiều rộng
  rate = (e.offsetX * 100) / progressBarWidth;

  //Update CSS vào progress
  progress.style.width = `${rate}%`;

  initalRate = rate;

  isDrag = true;

  initialClientX = e.clientX;

  //   console.log("progress bar");

  handleChange(rate);
});

progressDot.addEventListener("mousedown", function (e) {
  e.stopPropagation();
  isDrag = true;
  initialClientX = e.clientX;
  //   console.log(initalRate);
  //   console.log("progress dot");
});

document.addEventListener("mousemove", function (e) {
  if (isDrag) {
    var space = e.clientX - initialClientX;
    // console.log(space);
    rate = (space * 100) / progressBarWidth + initalRate;
    if (rate < 0) {
      rate = 0;
    }

    if (rate > 100) {
      rate = 100;
    }

    progress.style.width = `${rate}%`;
    handleChange(rate);
  }
});

document.addEventListener("mouseup", function () {
  isDrag = false;
  initalRate = rate;

  audio.currentTime = currentTime;
});

/*
Khi bấm chuột xuống vào chấm màu tím
- Lấy được clientX tại ví trí bấm chuột

Khi kéo chuột
- Lấy được clientX ở vị trí gần nhất (kéo đến đâu lấy vị trí ở đó)
- Tính khoảng cách kéo: clientX mới nhất - clientX ban đầu khi click
*/

var audio = document.querySelector(".audio");
var currentTimeEl = progressBar.previousElementSibling;
var durationTimeEl = progressBar.nextElementSibling;
var playBtn = document.querySelector(".play-btn");

var playIcon = `<i class="fa-solid fa-play"></i>`;
var pauseIcon = `<i class="fa-solid fa-pause"></i>`;

var getTime = function (seconds) {
  var mins = Math.floor(seconds / 60);
  seconds = Math.floor(seconds - mins * 60);
  return `${mins < 10 ? "0" + mins : mins}:${
    seconds < 10 ? "0" + seconds : seconds
  }`;
};

audio.addEventListener("loadeddata", function () {
  //   console.log(audio.duration);
  durationTimeEl.innerText = getTime(audio.duration);
});

playBtn.addEventListener("click", function () {
  if (audio.paused) {
    audio.play();
    this.innerHTML = pauseIcon;
  } else {
    audio.pause();
    this.innerHTML = playIcon;
  }
});

audio.addEventListener("timeupdate", function () {
  //   console.log("đang chạy: ", this.currentTime);
  if (!isDrag) {
    currentTimeEl.innerText = getTime(this.currentTime);

    //Tính tỷ lệ phần trăm
    rate = (this.currentTime / this.duration) * 100;

    //Update vào timer
    progress.style.width = `${rate}%`;

    currentTime = this.currentTime;

    handleKaraoke(currentTime);
  }
});

audio.addEventListener("ended", function () {
  rate = 0;
  currentTime = 0;
  audio.currentTime = 0;
  progress.style.width = 0;
  playBtn.innerHTML = playIcon;
});

var currentTime = 0;
var handleChange = function (value) {
  currentTime = (value / 100) * audio.duration;

  currentTimeEl.innerText = getTime(currentTime);

  if (!isDrag) {
    audio.currentTime = currentTime;
  }
};

var lyric = `{
  "err": 0,
  "msg": "Success",
  "data": {
      "sentences": [
          {
              "words": [
                  {
                      "startTime": 28920,
                      "endTime": 29450,
                      "data": "Chính"
                  },
                  {
                      "startTime": 29450,
                      "endTime": 29710,
                      "data": "em"
                  },
                  {
                      "startTime": 29710,
                      "endTime": 30250,
                      "data": "vì"
                  },
                  {
                      "startTime": 30250,
                      "endTime": 31580,
                      "data": "em"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 31580,
                      "endTime": 31840,
                      "data": "Đã"
                  },
                  {
                      "startTime": 31840,
                      "endTime": 32100,
                      "data": "cho"
                  },
                  {
                      "startTime": 32100,
                      "endTime": 32380,
                      "data": "anh"
                  },
                  {
                      "startTime": 32380,
                      "endTime": 32640,
                      "data": "biết"
                  },
                  {
                      "startTime": 32640,
                      "endTime": 32900,
                      "data": "yêu"
                  },
                  {
                      "startTime": 32900,
                      "endTime": 33430,
                      "data": "và"
                  },
                  {
                      "startTime": 33430,
                      "endTime": 35560,
                      "data": "thương"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 35560,
                      "endTime": 35820,
                      "data": "Mà"
                  },
                  {
                      "startTime": 35820,
                      "endTime": 36090,
                      "data": "tại"
                  },
                  {
                      "startTime": 36090,
                      "endTime": 36360,
                      "data": "sao"
                  },
                  {
                      "startTime": 36360,
                      "endTime": 36620,
                      "data": "trớ"
                  },
                  {
                      "startTime": 36620,
                      "endTime": 37910,
                      "data": "trêu"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 37910,
                      "endTime": 38170,
                      "data": "Em"
                  },
                  {
                      "startTime": 38170,
                      "endTime": 38430,
                      "data": "là"
                  },
                  {
                      "startTime": 38430,
                      "endTime": 39760,
                      "data": "gió"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 39760,
                      "endTime": 39760,
                      "data": "Lướt"
                  },
                  {
                      "startTime": 39760,
                      "endTime": 40020,
                      "data": "qua"
                  },
                  {
                      "startTime": 40020,
                      "endTime": 40300,
                      "data": "nhanh"
                  },
                  {
                      "startTime": 40300,
                      "endTime": 40560,
                      "data": "để"
                  },
                  {
                      "startTime": 40560,
                      "endTime": 41350,
                      "data": "anh"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 41350,
                      "endTime": 41620,
                      "data": "Đọng"
                  },
                  {
                      "startTime": 41620,
                      "endTime": 42150,
                      "data": "lại"
                  },
                  {
                      "startTime": 42150,
                      "endTime": 42410,
                      "data": "hơi"
                  },
                  {
                      "startTime": 42410,
                      "endTime": 43690,
                      "data": "sương"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 43690,
                      "endTime": 43950,
                      "data": "Hoa"
                  },
                  {
                      "startTime": 43950,
                      "endTime": 43950,
                      "data": "mỹ"
                  },
                  {
                      "startTime": 43950,
                      "endTime": 44210,
                      "data": "trong"
                  },
                  {
                      "startTime": 44210,
                      "endTime": 44480,
                      "data": "câu"
                  },
                  {
                      "startTime": 44480,
                      "endTime": 45010,
                      "data": "ca"
                  },
                  {
                      "startTime": 45010,
                      "endTime": 47410,
                      "data": "này"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 47410,
                      "endTime": 47670,
                      "data": "Để"
                  },
                  {
                      "startTime": 47670,
                      "endTime": 47930,
                      "data": "một"
                  },
                  {
                      "startTime": 47930,
                      "endTime": 48200,
                      "data": "ngày"
                  },
                  {
                      "startTime": 48200,
                      "endTime": 48470,
                      "data": "nào"
                  },
                  {
                      "startTime": 48470,
                      "endTime": 49000,
                      "data": "kia"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 49000,
                      "endTime": 49260,
                      "data": "Con"
                  },
                  {
                      "startTime": 49260,
                      "endTime": 49530,
                      "data": "tim"
                  },
                  {
                      "startTime": 49530,
                      "endTime": 49800,
                      "data": "em"
                  },
                  {
                      "startTime": 49800,
                      "endTime": 50320,
                      "data": "lắng"
                  },
                  {
                      "startTime": 50320,
                      "endTime": 52190,
                      "data": "nghe"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 52190,
                      "endTime": 52450,
                      "data": "Nhìn"
                  },
                  {
                      "startTime": 52450,
                      "endTime": 52450,
                      "data": "thấy"
                  },
                  {
                      "startTime": 52450,
                      "endTime": 52710,
                      "data": "em"
                  },
                  {
                      "startTime": 52710,
                      "endTime": 53250,
                      "data": "lao"
                  },
                  {
                      "startTime": 53250,
                      "endTime": 54580,
                      "data": "đao"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 54580,
                      "endTime": 54840,
                      "data": "Dũng"
                  },
                  {
                      "startTime": 54840,
                      "endTime": 55380,
                      "data": "khí"
                  },
                  {
                      "startTime": 55380,
                      "endTime": 56430,
                      "data": "nào"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 56430,
                      "endTime": 56710,
                      "data": "Để"
                  },
                  {
                      "startTime": 56710,
                      "endTime": 56970,
                      "data": "anh"
                  },
                  {
                      "startTime": 56970,
                      "endTime": 57230,
                      "data": "dang"
                  },
                  {
                      "startTime": 57230,
                      "endTime": 57490,
                      "data": "cánh"
                  },
                  {
                      "startTime": 57490,
                      "endTime": 57760,
                      "data": "tay"
                  },
                  {
                      "startTime": 57760,
                      "endTime": 58290,
                      "data": "ôm"
                  },
                  {
                      "startTime": 58290,
                      "endTime": 58560,
                      "data": "lấy"
                  },
                  {
                      "startTime": 58560,
                      "endTime": 60690,
                      "data": "vào"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 60690,
                      "endTime": 60950,
                      "data": "Quá"
                  },
                  {
                      "startTime": 60950,
                      "endTime": 61210,
                      "data": "khó"
                  },
                  {
                      "startTime": 61210,
                      "endTime": 61210,
                      "data": "để"
                  },
                  {
                      "startTime": 61210,
                      "endTime": 61490,
                      "data": "chăm"
                  },
                  {
                      "startTime": 61490,
                      "endTime": 61750,
                      "data": "lo"
                  },
                  {
                      "startTime": 61750,
                      "endTime": 62010,
                      "data": "một"
                  },
                  {
                      "startTime": 62010,
                      "endTime": 62280,
                      "data": "người"
                  },
                  {
                      "startTime": 62280,
                      "endTime": 62540,
                      "data": "con"
                  },
                  {
                      "startTime": 62540,
                      "endTime": 62810,
                      "data": "gái"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 62810,
                      "endTime": 63080,
                      "data": "Ấm"
                  },
                  {
                      "startTime": 63080,
                      "endTime": 63340,
                      "data": "no"
                  },
                  {
                      "startTime": 63340,
                      "endTime": 63610,
                      "data": "hạnh"
                  },
                  {
                      "startTime": 63610,
                      "endTime": 63880,
                      "data": "phúc"
                  },
                  {
                      "startTime": 63880,
                      "endTime": 64140,
                      "data": "đến"
                  },
                  {
                      "startTime": 64140,
                      "endTime": 64400,
                      "data": "khi"
                  },
                  {
                      "startTime": 64400,
                      "endTime": 64670,
                      "data": "cuối"
                  },
                  {
                      "startTime": 64670,
                      "endTime": 65990,
                      "data": "đời"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 65990,
                      "endTime": 66530,
                      "data": "Bởi"
                  },
                  {
                      "startTime": 66530,
                      "endTime": 67860,
                      "data": "nghèo"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 67860,
                      "endTime": 68120,
                      "data": "Quả"
                  },
                  {
                      "startTime": 68120,
                      "endTime": 68380,
                      "data": "nhiên"
                  },
                  {
                      "startTime": 68380,
                      "endTime": 68660,
                      "data": "là"
                  },
                  {
                      "startTime": 68660,
                      "endTime": 68660,
                      "data": "ai"
                  },
                  {
                      "startTime": 68660,
                      "endTime": 68920,
                      "data": "cũng"
                  },
                  {
                      "startTime": 68920,
                      "endTime": 69180,
                      "data": "thế"
                  },
                  {
                      "startTime": 69180,
                      "endTime": 69710,
                      "data": "thôi"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 69710,
                      "endTime": 69980,
                      "data": "Chẳng"
                  },
                  {
                      "startTime": 69980,
                      "endTime": 70250,
                      "data": "ai"
                  },
                  {
                      "startTime": 70250,
                      "endTime": 70510,
                      "data": "chọn"
                  },
                  {
                      "startTime": 70510,
                      "endTime": 70770,
                      "data": "cách"
                  },
                  {
                      "startTime": 70770,
                      "endTime": 71050,
                      "data": "nắm"
                  },
                  {
                      "startTime": 71050,
                      "endTime": 71310,
                      "data": "tay"
                  },
                  {
                      "startTime": 71310,
                      "endTime": 71570,
                      "data": "một"
                  },
                  {
                      "startTime": 71570,
                      "endTime": 71840,
                      "data": "người"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 71840,
                      "endTime": 72100,
                      "data": "Mà"
                  },
                  {
                      "startTime": 72100,
                      "endTime": 72640,
                      "data": "quên"
                  },
                  {
                      "startTime": 72640,
                      "endTime": 73160,
                      "data": "đi"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 73160,
                      "endTime": 73440,
                      "data": "Hoàn"
                  },
                  {
                      "startTime": 73440,
                      "endTime": 73700,
                      "data": "cảnh"
                  },
                  {
                      "startTime": 73700,
                      "endTime": 73970,
                      "data": "trước"
                  },
                  {
                      "startTime": 73970,
                      "endTime": 74230,
                      "data": "mắt"
                  },
                  {
                      "startTime": 74230,
                      "endTime": 74490,
                      "data": "lầm"
                  },
                  {
                      "startTime": 74490,
                      "endTime": 75830,
                      "data": "than"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 75830,
                      "endTime": 76090,
                      "data": "Vì"
                  },
                  {
                      "startTime": 76090,
                      "endTime": 76360,
                      "data": "quá"
                  },
                  {
                      "startTime": 76360,
                      "endTime": 76620,
                      "data": "ngu"
                  },
                  {
                      "startTime": 76620,
                      "endTime": 76880,
                      "data": "si"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 76880,
                      "endTime": 77160,
                      "data": "Hay"
                  },
                  {
                      "startTime": 77160,
                      "endTime": 77420,
                      "data": "vì"
                  },
                  {
                      "startTime": 77420,
                      "endTime": 77950,
                      "data": "em"
                  },
                  {
                      "startTime": 77950,
                      "endTime": 77950,
                      "data": "đã"
                  },
                  {
                      "startTime": 77950,
                      "endTime": 78220,
                      "data": "yêu"
                  },
                  {
                      "startTime": 78220,
                      "endTime": 78750,
                      "data": "vội"
                  },
                  {
                      "startTime": 78750,
                      "endTime": 79810,
                      "data": "vàng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 79810,
                      "endTime": 80070,
                      "data": "Vì"
                  },
                  {
                      "startTime": 80070,
                      "endTime": 80340,
                      "data": "cả"
                  },
                  {
                      "startTime": 80340,
                      "endTime": 80610,
                      "data": "tương"
                  },
                  {
                      "startTime": 80610,
                      "endTime": 80870,
                      "data": "lai"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 80870,
                      "endTime": 81140,
                      "data": "Nên"
                  },
                  {
                      "startTime": 81140,
                      "endTime": 81400,
                      "data": "là"
                  },
                  {
                      "startTime": 81400,
                      "endTime": 81670,
                      "data": "em"
                  },
                  {
                      "startTime": 81670,
                      "endTime": 81940,
                      "data": "trả"
                  },
                  {
                      "startTime": 81940,
                      "endTime": 82200,
                      "data": "nợ"
                  },
                  {
                      "startTime": 82200,
                      "endTime": 82460,
                      "data": "cưu"
                  },
                  {
                      "startTime": 82460,
                      "endTime": 83790,
                      "data": "mang"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 83790,
                      "endTime": 84050,
                      "data": "Một"
                  },
                  {
                      "startTime": 84050,
                      "endTime": 84330,
                      "data": "nụ"
                  },
                  {
                      "startTime": 84330,
                      "endTime": 84850,
                      "data": "hồng"
                  },
                  {
                      "startTime": 84850,
                      "endTime": 85120,
                      "data": "thơ"
                  },
                  {
                      "startTime": 85120,
                      "endTime": 85650,
                      "data": "ngây"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 85650,
                      "endTime": 85920,
                      "data": "Đôi"
                  },
                  {
                      "startTime": 85920,
                      "endTime": 86190,
                      "data": "vai"
                  },
                  {
                      "startTime": 86190,
                      "endTime": 86450,
                      "data": "phải"
                  },
                  {
                      "startTime": 86450,
                      "endTime": 86720,
                      "data": "chịu"
                  },
                  {
                      "startTime": 86720,
                      "endTime": 86980,
                      "data": "nhiều"
                  },
                  {
                      "startTime": 86980,
                      "endTime": 87250,
                      "data": "gánh"
                  },
                  {
                      "startTime": 87250,
                      "endTime": 87780,
                      "data": "vác"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 87780,
                      "endTime": 88050,
                      "data": "Giờ"
                  },
                  {
                      "startTime": 88050,
                      "endTime": 88310,
                      "data": "mang"
                  },
                  {
                      "startTime": 88310,
                      "endTime": 88850,
                      "data": "thêm"
                  },
                  {
                      "startTime": 88850,
                      "endTime": 88850,
                      "data": "đau"
                  },
                  {
                      "startTime": 88850,
                      "endTime": 89110,
                      "data": "thương"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 89110,
                      "endTime": 89370,
                      "data": "Vì"
                  },
                  {
                      "startTime": 89370,
                      "endTime": 89640,
                      "data": "bởi"
                  },
                  {
                      "startTime": 89640,
                      "endTime": 89900,
                      "data": "kẻ"
                  },
                  {
                      "startTime": 89900,
                      "endTime": 90170,
                      "data": "phũ"
                  },
                  {
                      "startTime": 90170,
                      "endTime": 91760,
                      "data": "phàng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 91760,
                      "endTime": 92030,
                      "data": "Người"
                  },
                  {
                      "startTime": 92030,
                      "endTime": 92290,
                      "data": "muốn"
                  },
                  {
                      "startTime": 92290,
                      "endTime": 92560,
                      "data": "kêu"
                  },
                  {
                      "startTime": 92560,
                      "endTime": 92830,
                      "data": "ai"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 92830,
                      "endTime": 93090,
                      "data": "Trong"
                  },
                  {
                      "startTime": 93090,
                      "endTime": 93630,
                      "data": "màn"
                  },
                  {
                      "startTime": 93630,
                      "endTime": 93890,
                      "data": "đêm"
                  },
                  {
                      "startTime": 93890,
                      "endTime": 94150,
                      "data": "tối"
                  },
                  {
                      "startTime": 94150,
                      "endTime": 94150,
                      "data": "tăm"
                  },
                  {
                      "startTime": 94150,
                      "endTime": 94680,
                      "data": "đọa"
                  },
                  {
                      "startTime": 94680,
                      "endTime": 95740,
                      "data": "đày"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 95740,
                      "endTime": 96020,
                      "data": "Người"
                  },
                  {
                      "startTime": 96020,
                      "endTime": 96280,
                      "data": "muốn"
                  },
                  {
                      "startTime": 96280,
                      "endTime": 96540,
                      "data": "tìm"
                  },
                  {
                      "startTime": 96540,
                      "endTime": 97070,
                      "data": "gì"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 97070,
                      "endTime": 97340,
                      "data": "Ở"
                  },
                  {
                      "startTime": 97340,
                      "endTime": 97610,
                      "data": "dưới"
                  },
                  {
                      "startTime": 97610,
                      "endTime": 97870,
                      "data": "đáy"
                  },
                  {
                      "startTime": 97870,
                      "endTime": 98130,
                      "data": "ly"
                  },
                  {
                      "startTime": 98130,
                      "endTime": 98400,
                      "data": "rượu"
                  },
                  {
                      "startTime": 98400,
                      "endTime": 99730,
                      "data": "cay"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 99730,
                      "endTime": 100000,
                      "data": "Đêm"
                  },
                  {
                      "startTime": 100000,
                      "endTime": 100260,
                      "data": "đêm"
                  },
                  {
                      "startTime": 100260,
                      "endTime": 100520,
                      "data": "khóc"
                  },
                  {
                      "startTime": 100520,
                      "endTime": 101060,
                      "data": "than"
                  },
                  {
                      "startTime": 101060,
                      "endTime": 101330,
                      "data": "mình"
                  },
                  {
                      "startTime": 101330,
                      "endTime": 101850,
                      "data": "em"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 101850,
                      "endTime": 102130,
                      "data": "Cơm"
                  },
                  {
                      "startTime": 102130,
                      "endTime": 102130,
                      "data": "bưng"
                  },
                  {
                      "startTime": 102130,
                      "endTime": 102390,
                      "data": "nước"
                  },
                  {
                      "startTime": 102390,
                      "endTime": 102920,
                      "data": "rót"
                  },
                  {
                      "startTime": 102920,
                      "endTime": 103190,
                      "data": "cho"
                  },
                  {
                      "startTime": 103190,
                      "endTime": 103720,
                      "data": "chồng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 103720,
                      "endTime": 103980,
                      "data": "Làm"
                  },
                  {
                      "startTime": 103980,
                      "endTime": 104520,
                      "data": "sao"
                  },
                  {
                      "startTime": 104520,
                      "endTime": 104780,
                      "data": "anh"
                  },
                  {
                      "startTime": 104780,
                      "endTime": 105040,
                      "data": "quên"
                  },
                  {
                      "startTime": 105040,
                      "endTime": 105310,
                      "data": "đi"
                  },
                  {
                      "startTime": 105310,
                      "endTime": 105580,
                      "data": "và"
                  },
                  {
                      "startTime": 105580,
                      "endTime": 105840,
                      "data": "thôi"
                  },
                  {
                      "startTime": 105840,
                      "endTime": 106370,
                      "data": "ngóng"
                  },
                  {
                      "startTime": 106370,
                      "endTime": 106850,
                      "data": "trông"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 106850,
                      "endTime": 107120,
                      "data": "Em"
                  },
                  {
                      "startTime": 107120,
                      "endTime": 107380,
                      "data": "buông"
                  },
                  {
                      "startTime": 107380,
                      "endTime": 107650,
                      "data": "đi"
                  },
                  {
                      "startTime": 107650,
                      "endTime": 107910,
                      "data": "hết"
                  },
                  {
                      "startTime": 107910,
                      "endTime": 108440,
                      "data": "trong"
                  },
                  {
                      "startTime": 108440,
                      "endTime": 111440,
                      "data": "lòng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 149010,
                      "endTime": 149540,
                      "data": "Chính"
                  },
                  {
                      "startTime": 149540,
                      "endTime": 149800,
                      "data": "em"
                  },
                  {
                      "startTime": 149800,
                      "endTime": 150340,
                      "data": "vì"
                  },
                  {
                      "startTime": 150340,
                      "endTime": 151670,
                      "data": "em"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 151670,
                      "endTime": 151670,
                      "data": "Đã"
                  },
                  {
                      "startTime": 151670,
                      "endTime": 151930,
                      "data": "cho"
                  },
                  {
                      "startTime": 151930,
                      "endTime": 152200,
                      "data": "anh"
                  },
                  {
                      "startTime": 152200,
                      "endTime": 152460,
                      "data": "biết"
                  },
                  {
                      "startTime": 152460,
                      "endTime": 153000,
                      "data": "yêu"
                  },
                  {
                      "startTime": 153000,
                      "endTime": 153260,
                      "data": "và"
                  },
                  {
                      "startTime": 153260,
                      "endTime": 155650,
                      "data": "thương"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 155650,
                      "endTime": 155650,
                      "data": "Mà"
                  },
                  {
                      "startTime": 155650,
                      "endTime": 155920,
                      "data": "tại"
                  },
                  {
                      "startTime": 155920,
                      "endTime": 156190,
                      "data": "sao"
                  },
                  {
                      "startTime": 156190,
                      "endTime": 156450,
                      "data": "trớ"
                  },
                  {
                      "startTime": 156450,
                      "endTime": 157980,
                      "data": "trêu"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 157980,
                      "endTime": 158240,
                      "data": "Em"
                  },
                  {
                      "startTime": 158240,
                      "endTime": 158500,
                      "data": "là"
                  },
                  {
                      "startTime": 158500,
                      "endTime": 159570,
                      "data": "gió"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 159570,
                      "endTime": 159830,
                      "data": "Lướt"
                  },
                  {
                      "startTime": 159830,
                      "endTime": 160110,
                      "data": "qua"
                  },
                  {
                      "startTime": 160110,
                      "endTime": 160370,
                      "data": "nhanh"
                  },
                  {
                      "startTime": 160370,
                      "endTime": 160630,
                      "data": "để"
                  },
                  {
                      "startTime": 160630,
                      "endTime": 161160,
                      "data": "anh"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 161160,
                      "endTime": 161430,
                      "data": "Đọng"
                  },
                  {
                      "startTime": 161430,
                      "endTime": 161960,
                      "data": "lại"
                  },
                  {
                      "startTime": 161960,
                      "endTime": 162500,
                      "data": "hơi"
                  },
                  {
                      "startTime": 162500,
                      "endTime": 163550,
                      "data": "sương"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 163550,
                      "endTime": 163820,
                      "data": "Hoa"
                  },
                  {
                      "startTime": 163820,
                      "endTime": 164090,
                      "data": "mỹ"
                  },
                  {
                      "startTime": 164090,
                      "endTime": 164350,
                      "data": "trong"
                  },
                  {
                      "startTime": 164350,
                      "endTime": 164610,
                      "data": "câu"
                  },
                  {
                      "startTime": 164610,
                      "endTime": 164880,
                      "data": "ca"
                  },
                  {
                      "startTime": 164880,
                      "endTime": 167540,
                      "data": "này"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 167540,
                      "endTime": 167800,
                      "data": "Để"
                  },
                  {
                      "startTime": 167800,
                      "endTime": 168070,
                      "data": "một"
                  },
                  {
                      "startTime": 168070,
                      "endTime": 168330,
                      "data": "ngày"
                  },
                  {
                      "startTime": 168330,
                      "endTime": 168600,
                      "data": "nào"
                  },
                  {
                      "startTime": 168600,
                      "endTime": 169130,
                      "data": "kia"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 169130,
                      "endTime": 169390,
                      "data": "Con"
                  },
                  {
                      "startTime": 169390,
                      "endTime": 169660,
                      "data": "tim"
                  },
                  {
                      "startTime": 169660,
                      "endTime": 169930,
                      "data": "em"
                  },
                  {
                      "startTime": 169930,
                      "endTime": 170460,
                      "data": "lắng"
                  },
                  {
                      "startTime": 170460,
                      "endTime": 172060,
                      "data": "nghe"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 172060,
                      "endTime": 172320,
                      "data": "Nhìn"
                  },
                  {
                      "startTime": 172320,
                      "endTime": 172590,
                      "data": "thấy"
                  },
                  {
                      "startTime": 172590,
                      "endTime": 172850,
                      "data": "em"
                  },
                  {
                      "startTime": 172850,
                      "endTime": 173390,
                      "data": "lao"
                  },
                  {
                      "startTime": 173390,
                      "endTime": 174710,
                      "data": "đao"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 174710,
                      "endTime": 174980,
                      "data": "Dũng"
                  },
                  {
                      "startTime": 174980,
                      "endTime": 175240,
                      "data": "khí"
                  },
                  {
                      "startTime": 175240,
                      "endTime": 176570,
                      "data": "nào"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 176570,
                      "endTime": 176840,
                      "data": "Để"
                  },
                  {
                      "startTime": 176840,
                      "endTime": 177100,
                      "data": "anh"
                  },
                  {
                      "startTime": 177100,
                      "endTime": 177100,
                      "data": "dang"
                  },
                  {
                      "startTime": 177100,
                      "endTime": 177630,
                      "data": "cánh"
                  },
                  {
                      "startTime": 177630,
                      "endTime": 177900,
                      "data": "tay"
                  },
                  {
                      "startTime": 177900,
                      "endTime": 178170,
                      "data": "ôm"
                  },
                  {
                      "startTime": 178170,
                      "endTime": 178690,
                      "data": "lấy"
                  },
                  {
                      "startTime": 178690,
                      "endTime": 180490,
                      "data": "vào"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 180490,
                      "endTime": 180750,
                      "data": "Quá"
                  },
                  {
                      "startTime": 180750,
                      "endTime": 181030,
                      "data": "khó"
                  },
                  {
                      "startTime": 181030,
                      "endTime": 181290,
                      "data": "để"
                  },
                  {
                      "startTime": 181290,
                      "endTime": 181550,
                      "data": "chăm"
                  },
                  {
                      "startTime": 181550,
                      "endTime": 181820,
                      "data": "lo"
                  },
                  {
                      "startTime": 181820,
                      "endTime": 182090,
                      "data": "một"
                  },
                  {
                      "startTime": 182090,
                      "endTime": 182350,
                      "data": "người"
                  },
                  {
                      "startTime": 182350,
                      "endTime": 182620,
                      "data": "con"
                  },
                  {
                      "startTime": 182620,
                      "endTime": 182880,
                      "data": "gái"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 182880,
                      "endTime": 183150,
                      "data": "Ấm"
                  },
                  {
                      "startTime": 183150,
                      "endTime": 183150,
                      "data": "no"
                  },
                  {
                      "startTime": 183150,
                      "endTime": 183680,
                      "data": "hạnh"
                  },
                  {
                      "startTime": 183680,
                      "endTime": 183940,
                      "data": "phúc"
                  },
                  {
                      "startTime": 183940,
                      "endTime": 184220,
                      "data": "đến"
                  },
                  {
                      "startTime": 184220,
                      "endTime": 184220,
                      "data": "khi"
                  },
                  {
                      "startTime": 184220,
                      "endTime": 184740,
                      "data": "cuối"
                  },
                  {
                      "startTime": 184740,
                      "endTime": 186070,
                      "data": "đời"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 186070,
                      "endTime": 186600,
                      "data": "Bởi"
                  },
                  {
                      "startTime": 186600,
                      "endTime": 187870,
                      "data": "nghèo"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 187870,
                      "endTime": 188130,
                      "data": "Quả"
                  },
                  {
                      "startTime": 188130,
                      "endTime": 188400,
                      "data": "nhiên"
                  },
                  {
                      "startTime": 188400,
                      "endTime": 188670,
                      "data": "là"
                  },
                  {
                      "startTime": 188670,
                      "endTime": 188930,
                      "data": "ai"
                  },
                  {
                      "startTime": 188930,
                      "endTime": 188930,
                      "data": "cũng"
                  },
                  {
                      "startTime": 188930,
                      "endTime": 189200,
                      "data": "thế"
                  },
                  {
                      "startTime": 189200,
                      "endTime": 189730,
                      "data": "thôi"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 189730,
                      "endTime": 190000,
                      "data": "Chẳng"
                  },
                  {
                      "startTime": 190000,
                      "endTime": 190260,
                      "data": "ai"
                  },
                  {
                      "startTime": 190260,
                      "endTime": 190520,
                      "data": "chọn"
                  },
                  {
                      "startTime": 190520,
                      "endTime": 190800,
                      "data": "cách"
                  },
                  {
                      "startTime": 190800,
                      "endTime": 191060,
                      "data": "nắm"
                  },
                  {
                      "startTime": 191060,
                      "endTime": 191320,
                      "data": "tay"
                  },
                  {
                      "startTime": 191320,
                      "endTime": 191590,
                      "data": "một"
                  },
                  {
                      "startTime": 191590,
                      "endTime": 192130,
                      "data": "người"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 192130,
                      "endTime": 192390,
                      "data": "Mà"
                  },
                  {
                      "startTime": 192390,
                      "endTime": 192650,
                      "data": "quên"
                  },
                  {
                      "startTime": 192650,
                      "endTime": 193190,
                      "data": "đi"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 193190,
                      "endTime": 193720,
                      "data": "Hoàn"
                  },
                  {
                      "startTime": 193720,
                      "endTime": 193980,
                      "data": "cảnh"
                  },
                  {
                      "startTime": 193980,
                      "endTime": 193980,
                      "data": "trước"
                  },
                  {
                      "startTime": 193980,
                      "endTime": 194240,
                      "data": "mắt"
                  },
                  {
                      "startTime": 194240,
                      "endTime": 194520,
                      "data": "lầm"
                  },
                  {
                      "startTime": 194520,
                      "endTime": 195840,
                      "data": "than"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 195840,
                      "endTime": 196110,
                      "data": "Vì"
                  },
                  {
                      "startTime": 196110,
                      "endTime": 196370,
                      "data": "quá"
                  },
                  {
                      "startTime": 196370,
                      "endTime": 196640,
                      "data": "ngu"
                  },
                  {
                      "startTime": 196640,
                      "endTime": 196910,
                      "data": "si"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 196910,
                      "endTime": 197170,
                      "data": "Hay"
                  },
                  {
                      "startTime": 197170,
                      "endTime": 197430,
                      "data": "vì"
                  },
                  {
                      "startTime": 197430,
                      "endTime": 197970,
                      "data": "em"
                  },
                  {
                      "startTime": 197970,
                      "endTime": 198230,
                      "data": "đã"
                  },
                  {
                      "startTime": 198230,
                      "endTime": 198230,
                      "data": "yêu"
                  },
                  {
                      "startTime": 198230,
                      "endTime": 198760,
                      "data": "vội"
                  },
                  {
                      "startTime": 198760,
                      "endTime": 199820,
                      "data": "vàng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 199820,
                      "endTime": 200090,
                      "data": "Vì"
                  },
                  {
                      "startTime": 200090,
                      "endTime": 200360,
                      "data": "cả"
                  },
                  {
                      "startTime": 200360,
                      "endTime": 200620,
                      "data": "tương"
                  },
                  {
                      "startTime": 200620,
                      "endTime": 200890,
                      "data": "lai"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 200890,
                      "endTime": 201150,
                      "data": "Nên"
                  },
                  {
                      "startTime": 201150,
                      "endTime": 201410,
                      "data": "là"
                  },
                  {
                      "startTime": 201410,
                      "endTime": 201690,
                      "data": "em"
                  },
                  {
                      "startTime": 201690,
                      "endTime": 201950,
                      "data": "trả"
                  },
                  {
                      "startTime": 201950,
                      "endTime": 202210,
                      "data": "nợ"
                  },
                  {
                      "startTime": 202210,
                      "endTime": 202480,
                      "data": "cưu"
                  },
                  {
                      "startTime": 202480,
                      "endTime": 203800,
                      "data": "mang"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 203800,
                      "endTime": 204080,
                      "data": "Một"
                  },
                  {
                      "startTime": 204080,
                      "endTime": 204600,
                      "data": "nụ"
                  },
                  {
                      "startTime": 204600,
                      "endTime": 204870,
                      "data": "hồng"
                  },
                  {
                      "startTime": 204870,
                      "endTime": 205410,
                      "data": "thơ"
                  },
                  {
                      "startTime": 205410,
                      "endTime": 205670,
                      "data": "ngây"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 205670,
                      "endTime": 205930,
                      "data": "Đôi"
                  },
                  {
                      "startTime": 205930,
                      "endTime": 206200,
                      "data": "vai"
                  },
                  {
                      "startTime": 206200,
                      "endTime": 206470,
                      "data": "phải"
                  },
                  {
                      "startTime": 206470,
                      "endTime": 206730,
                      "data": "chịu"
                  },
                  {
                      "startTime": 206730,
                      "endTime": 207000,
                      "data": "nhiều"
                  },
                  {
                      "startTime": 207000,
                      "endTime": 207260,
                      "data": "gánh"
                  },
                  {
                      "startTime": 207260,
                      "endTime": 207800,
                      "data": "vác"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 207800,
                      "endTime": 208060,
                      "data": "Giờ"
                  },
                  {
                      "startTime": 208060,
                      "endTime": 208320,
                      "data": "mang"
                  },
                  {
                      "startTime": 208320,
                      "endTime": 208600,
                      "data": "thêm"
                  },
                  {
                      "startTime": 208600,
                      "endTime": 208860,
                      "data": "đau"
                  },
                  {
                      "startTime": 208860,
                      "endTime": 209120,
                      "data": "thương"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 209120,
                      "endTime": 209390,
                      "data": "Vì"
                  },
                  {
                      "startTime": 209390,
                      "endTime": 209650,
                      "data": "bởi"
                  },
                  {
                      "startTime": 209650,
                      "endTime": 209920,
                      "data": "kẻ"
                  },
                  {
                      "startTime": 209920,
                      "endTime": 210450,
                      "data": "phũ"
                  },
                  {
                      "startTime": 210450,
                      "endTime": 211780,
                      "data": "phàng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 211780,
                      "endTime": 212050,
                      "data": "Người"
                  },
                  {
                      "startTime": 212050,
                      "endTime": 212310,
                      "data": "muốn"
                  },
                  {
                      "startTime": 212310,
                      "endTime": 212580,
                      "data": "kêu"
                  },
                  {
                      "startTime": 212580,
                      "endTime": 212840,
                      "data": "ai"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 212840,
                      "endTime": 213110,
                      "data": "Trong"
                  },
                  {
                      "startTime": 213110,
                      "endTime": 213380,
                      "data": "màn"
                  },
                  {
                      "startTime": 213380,
                      "endTime": 213640,
                      "data": "đêm"
                  },
                  {
                      "startTime": 213640,
                      "endTime": 213900,
                      "data": "tối"
                  },
                  {
                      "startTime": 213900,
                      "endTime": 214170,
                      "data": "tăm"
                  },
                  {
                      "startTime": 214170,
                      "endTime": 214700,
                      "data": "đọa"
                  },
                  {
                      "startTime": 214700,
                      "endTime": 215770,
                      "data": "đày"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 215770,
                      "endTime": 216030,
                      "data": "Người"
                  },
                  {
                      "startTime": 216030,
                      "endTime": 216290,
                      "data": "muốn"
                  },
                  {
                      "startTime": 216290,
                      "endTime": 216560,
                      "data": "tìm"
                  },
                  {
                      "startTime": 216560,
                      "endTime": 217090,
                      "data": "gì"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 217090,
                      "endTime": 217360,
                      "data": "Ở"
                  },
                  {
                      "startTime": 217360,
                      "endTime": 217620,
                      "data": "dưới"
                  },
                  {
                      "startTime": 217620,
                      "endTime": 217880,
                      "data": "đáy"
                  },
                  {
                      "startTime": 217880,
                      "endTime": 218160,
                      "data": "ly"
                  },
                  {
                      "startTime": 218160,
                      "endTime": 218420,
                      "data": "rượu"
                  },
                  {
                      "startTime": 218420,
                      "endTime": 219750,
                      "data": "cay"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 219750,
                      "endTime": 220010,
                      "data": "Đêm"
                  },
                  {
                      "startTime": 220010,
                      "endTime": 220280,
                      "data": "đêm"
                  },
                  {
                      "startTime": 220280,
                      "endTime": 220540,
                      "data": "khóc"
                  },
                  {
                      "startTime": 220540,
                      "endTime": 220810,
                      "data": "than"
                  },
                  {
                      "startTime": 220810,
                      "endTime": 221340,
                      "data": "mình"
                  },
                  {
                      "startTime": 221340,
                      "endTime": 221880,
                      "data": "em"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 221880,
                      "endTime": 222140,
                      "data": "Cơm"
                  },
                  {
                      "startTime": 222140,
                      "endTime": 222140,
                      "data": "bưng"
                  },
                  {
                      "startTime": 222140,
                      "endTime": 222670,
                      "data": "nước"
                  },
                  {
                      "startTime": 222670,
                      "endTime": 222940,
                      "data": "rót"
                  },
                  {
                      "startTime": 222940,
                      "endTime": 223200,
                      "data": "cho"
                  },
                  {
                      "startTime": 223200,
                      "endTime": 223730,
                      "data": "chồng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 223730,
                      "endTime": 223990,
                      "data": "Làm"
                  },
                  {
                      "startTime": 223990,
                      "endTime": 224530,
                      "data": "sao"
                  },
                  {
                      "startTime": 224530,
                      "endTime": 224790,
                      "data": "anh"
                  },
                  {
                      "startTime": 224790,
                      "endTime": 224790,
                      "data": "quên"
                  },
                  {
                      "startTime": 224790,
                      "endTime": 225070,
                      "data": "đi"
                  },
                  {
                      "startTime": 225070,
                      "endTime": 225330,
                      "data": "và"
                  },
                  {
                      "startTime": 225330,
                      "endTime": 225590,
                      "data": "thôi"
                  },
                  {
                      "startTime": 225590,
                      "endTime": 225860,
                      "data": "ngóng"
                  },
                  {
                      "startTime": 225860,
                      "endTime": 226860,
                      "data": "trông"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 226860,
                      "endTime": 227120,
                      "data": "Em"
                  },
                  {
                      "startTime": 227120,
                      "endTime": 227380,
                      "data": "buông"
                  },
                  {
                      "startTime": 227380,
                      "endTime": 227660,
                      "data": "đi"
                  },
                  {
                      "startTime": 227660,
                      "endTime": 227920,
                      "data": "hết"
                  },
                  {
                      "startTime": 227920,
                      "endTime": 228450,
                      "data": "trong"
                  },
                  {
                      "startTime": 228450,
                      "endTime": 231450,
                      "data": "lòng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 232110,
                      "endTime": 232380,
                      "data": "Vì"
                  },
                  {
                      "startTime": 232380,
                      "endTime": 232380,
                      "data": "quá"
                  },
                  {
                      "startTime": 232380,
                      "endTime": 232640,
                      "data": "ngu"
                  },
                  {
                      "startTime": 232640,
                      "endTime": 232910,
                      "data": "si"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 232910,
                      "endTime": 233170,
                      "data": "Hay"
                  },
                  {
                      "startTime": 233170,
                      "endTime": 233430,
                      "data": "vì"
                  },
                  {
                      "startTime": 233430,
                      "endTime": 233970,
                      "data": "em"
                  },
                  {
                      "startTime": 233970,
                      "endTime": 234230,
                      "data": "đã"
                  },
                  {
                      "startTime": 234230,
                      "endTime": 234500,
                      "data": "yêu"
                  },
                  {
                      "startTime": 234500,
                      "endTime": 234500,
                      "data": "vội"
                  },
                  {
                      "startTime": 234500,
                      "endTime": 235820,
                      "data": "vàng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 235820,
                      "endTime": 236100,
                      "data": "Vì"
                  },
                  {
                      "startTime": 236100,
                      "endTime": 236360,
                      "data": "cả"
                  },
                  {
                      "startTime": 236360,
                      "endTime": 236620,
                      "data": "tương"
                  },
                  {
                      "startTime": 236620,
                      "endTime": 236890,
                      "data": "lai"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 236890,
                      "endTime": 237160,
                      "data": "Nên"
                  },
                  {
                      "startTime": 237160,
                      "endTime": 237420,
                      "data": "là"
                  },
                  {
                      "startTime": 237420,
                      "endTime": 237690,
                      "data": "em"
                  },
                  {
                      "startTime": 237690,
                      "endTime": 237950,
                      "data": "trả"
                  },
                  {
                      "startTime": 237950,
                      "endTime": 238210,
                      "data": "nợ"
                  },
                  {
                      "startTime": 238210,
                      "endTime": 238490,
                      "data": "cưu"
                  },
                  {
                      "startTime": 238490,
                      "endTime": 239810,
                      "data": "mang"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 239810,
                      "endTime": 240340,
                      "data": "Một"
                  },
                  {
                      "startTime": 240340,
                      "endTime": 240600,
                      "data": "nụ"
                  },
                  {
                      "startTime": 240600,
                      "endTime": 240880,
                      "data": "hồng"
                  },
                  {
                      "startTime": 240880,
                      "endTime": 241400,
                      "data": "thơ"
                  },
                  {
                      "startTime": 241400,
                      "endTime": 241940,
                      "data": "ngây"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 241940,
                      "endTime": 242200,
                      "data": "Đôi"
                  },
                  {
                      "startTime": 242200,
                      "endTime": 242200,
                      "data": "vai"
                  },
                  {
                      "startTime": 242200,
                      "endTime": 242470,
                      "data": "phải"
                  },
                  {
                      "startTime": 242470,
                      "endTime": 242730,
                      "data": "chịu"
                  },
                  {
                      "startTime": 242730,
                      "endTime": 242990,
                      "data": "nhiều"
                  },
                  {
                      "startTime": 242990,
                      "endTime": 243270,
                      "data": "gánh"
                  },
                  {
                      "startTime": 243270,
                      "endTime": 243790,
                      "data": "vác"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 243790,
                      "endTime": 244330,
                      "data": "Giờ"
                  },
                  {
                      "startTime": 244330,
                      "endTime": 244600,
                      "data": "mang"
                  },
                  {
                      "startTime": 244600,
                      "endTime": 244860,
                      "data": "thêm"
                  },
                  {
                      "startTime": 244860,
                      "endTime": 245120,
                      "data": "đau"
                  },
                  {
                      "startTime": 245120,
                      "endTime": 245330,
                      "data": "thương"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 245330,
                      "endTime": 245600,
                      "data": "Vì"
                  },
                  {
                      "startTime": 245600,
                      "endTime": 245860,
                      "data": "bởi"
                  },
                  {
                      "startTime": 245860,
                      "endTime": 246130,
                      "data": "kẻ"
                  },
                  {
                      "startTime": 246130,
                      "endTime": 246650,
                      "data": "dối"
                  },
                  {
                      "startTime": 246650,
                      "endTime": 247920,
                      "data": "gian"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 247920,
                      "endTime": 247920,
                      "data": "Người"
                  },
                  {
                      "startTime": 247920,
                      "endTime": 248190,
                      "data": "muốn"
                  },
                  {
                      "startTime": 248190,
                      "endTime": 248710,
                      "data": "kêu"
                  },
                  {
                      "startTime": 248710,
                      "endTime": 248990,
                      "data": "ai"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 248990,
                      "endTime": 249250,
                      "data": "Trong"
                  },
                  {
                      "startTime": 249250,
                      "endTime": 249510,
                      "data": "màn"
                  },
                  {
                      "startTime": 249510,
                      "endTime": 249780,
                      "data": "đêm"
                  },
                  {
                      "startTime": 249780,
                      "endTime": 250040,
                      "data": "tối"
                  },
                  {
                      "startTime": 250040,
                      "endTime": 250310,
                      "data": "tăm"
                  },
                  {
                      "startTime": 250310,
                      "endTime": 250840,
                      "data": "đọa"
                  },
                  {
                      "startTime": 250840,
                      "endTime": 251900,
                      "data": "đày"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 251900,
                      "endTime": 252170,
                      "data": "Người"
                  },
                  {
                      "startTime": 252170,
                      "endTime": 252430,
                      "data": "muốn"
                  },
                  {
                      "startTime": 252430,
                      "endTime": 252700,
                      "data": "tìm"
                  },
                  {
                      "startTime": 252700,
                      "endTime": 252970,
                      "data": "gì"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 252970,
                      "endTime": 253230,
                      "data": "Ở"
                  },
                  {
                      "startTime": 253230,
                      "endTime": 253490,
                      "data": "dưới"
                  },
                  {
                      "startTime": 253490,
                      "endTime": 253770,
                      "data": "đáy"
                  },
                  {
                      "startTime": 253770,
                      "endTime": 254030,
                      "data": "ly"
                  },
                  {
                      "startTime": 254030,
                      "endTime": 254560,
                      "data": "rượu"
                  },
                  {
                      "startTime": 254560,
                      "endTime": 255880,
                      "data": "cay"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 255880,
                      "endTime": 255880,
                      "data": "Đêm"
                  },
                  {
                      "startTime": 255880,
                      "endTime": 256170,
                      "data": "đêm"
                  },
                  {
                      "startTime": 256170,
                      "endTime": 256420,
                      "data": "khóc"
                  },
                  {
                      "startTime": 256420,
                      "endTime": 256950,
                      "data": "than"
                  },
                  {
                      "startTime": 256950,
                      "endTime": 257210,
                      "data": "mình"
                  },
                  {
                      "startTime": 257210,
                      "endTime": 257750,
                      "data": "em"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 257750,
                      "endTime": 258010,
                      "data": "Cơm"
                  },
                  {
                      "startTime": 258010,
                      "endTime": 258270,
                      "data": "bưng"
                  },
                  {
                      "startTime": 258270,
                      "endTime": 258540,
                      "data": "nước"
                  },
                  {
                      "startTime": 258540,
                      "endTime": 258810,
                      "data": "rót"
                  },
                  {
                      "startTime": 258810,
                      "endTime": 259070,
                      "data": "cho"
                  },
                  {
                      "startTime": 259070,
                      "endTime": 259870,
                      "data": "chồng"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 259870,
                      "endTime": 260140,
                      "data": "Làm"
                  },
                  {
                      "startTime": 260140,
                      "endTime": 260400,
                      "data": "sao"
                  },
                  {
                      "startTime": 260400,
                      "endTime": 260660,
                      "data": "anh"
                  },
                  {
                      "startTime": 260660,
                      "endTime": 260940,
                      "data": "quên"
                  },
                  {
                      "startTime": 260940,
                      "endTime": 261200,
                      "data": "đi"
                  },
                  {
                      "startTime": 261200,
                      "endTime": 261470,
                      "data": "và"
                  },
                  {
                      "startTime": 261470,
                      "endTime": 261730,
                      "data": "thôi"
                  },
                  {
                      "startTime": 261730,
                      "endTime": 262270,
                      "data": "ngóng"
                  },
                  {
                      "startTime": 262270,
                      "endTime": 263060,
                      "data": "trông"
                  }
              ]
          },
          {
              "words": [
                  {
                      "startTime": 263060,
                      "endTime": 263330,
                      "data": "Em"
                  },
                  {
                      "startTime": 263330,
                      "endTime": 263590,
                      "data": "buông"
                  },
                  {
                      "startTime": 263590,
                      "endTime": 263590,
                      "data": "đi"
                  },
                  {
                      "startTime": 263590,
                      "endTime": 264120,
                      "data": "hết"
                  },
                  {
                      "startTime": 264120,
                      "endTime": 264390,
                      "data": "trong"
                  },
                  {
                      "startTime": 264390,
                      "endTime": 265390,
                      "data": "lòng"
                  }
              ]
          }
      ],
      "file": "https://static-zmp3.zmdcdn.me/lyrics/f/8/3/6/f836ebba8baf8efb0e42033e1d982d2a.lrc",
      "enabledVideoBG": true,
      "defaultIBGUrls": [
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/3/c/0/5/3c05c10ae36f6361f9af0874bb7c4851.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/b/b/e/0/bbe01e4bf6d8e23101fcb6db44df311d.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/a/1/f/3/a1f34293d1dc92735be8c3f9082c4acf.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/6/e/9/5/6e95b598e1e14a187ee779bcd888e75c.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/1/c/8/1/1c81e957a6270eba91571d822a47e7c5.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/0/0/0/d/000d9d0679bbbb564a191a6801d7f19d.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/e/6/4/f/e64f4fd6f53caebabc1c26d592093cfa.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/d/e/3/1/de315c40b537d40b7409a6702f446631.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/1/4/6/2/1462efc7378bed3f98ace411e11eab45.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/5/b/f/a/5bfa05533ed7975035e69a4508c82fd6.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/f/2/b/1/f2b1b91fa64e0c354150c86fd96c249c.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/5/1/f/b/51fbcd4ae32096ffe2dd89cd36bb6ed9.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/6/2/3/9/62392463eab1eb1aaa2d1f3bd0f758bb.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/1/2/f/0/12f01e12d6e13e263ef76f3fdb65d66e.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/8/8/2/4/8824ef8e3e3aa3e302f03879a1f9d7d3.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/4/3/4/9/43491e9d95a9942015548bd2a061250d.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/9/8/7/5/987517940ce71a96bab9c0c88d5b6b95.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/8/e/2/4/8e24305fde744814083af980a593e8c2.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/f/1/2/7/f1270dd1bed79b527228e3351d2b67ae.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/0/a/3/0/0a301934881ee4e2de30dc8f41bc55f9.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/c/c/9/f/cc9fce8719364ba9d8a846984c590a0e.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/e/5/d/e/e5de86acd7567465f54a6b9307076947.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/6/4/b/b/64bb19c5f971b4e4f16f3bfdff64a396.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/0/3/2/0/03206606d461843e22451747a9b60769.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/b/d/4/4/bd4485d6dfef80764869a4d88d9b0475.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/e/8/6/8/e86817d147315d9d644835f60d17ae41.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/b/b/4/7/bb477f2f56f162b13426f70c9858c732.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/c/5/3/6/c536ff6ab992e36be24ca0adf8e86ae0.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/6/c/f/c/6cfc1e6e3b94c62cded257659602f00b.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/2/5/d/6/25d6adaa11b4e932d61309ed635d57fa.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/d/2/a/e/d2ae42243ccd4fec321fc60692a5a2dc.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/b/8/0/e/b80e5777c7eec332c882bf79bd692056.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/e/7/b/a/e7ba1207018f1d2fa7048598c7d627df.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/3/f/4/0/3f40bd0d6d8cbcf833c72ab050f19e6a.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/a/d/a/d/adad060e15f8409ec2e7670cf943c202.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/e/d/1/7/ed17742d63b635725e6071a9bee362c5.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/3/a/e/8/3ae816de233a9eae0116b4b5a21af43e.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/d/7/f/1/d7f15e3996e7923ffc2a64d1f8e43448.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/0/0/7/e/007e6b48696aab4a61ca46a10d980f63.jpg",
          "https://photo-resize-zmp3.zmdcdn.me/w1920_r3x2_jpeg/cover/d/9/f/5/d9f592437d80e358a76e32798ce2d294.jpg"
      ],
      "BGMode": 0
  },
  "timestamp": 1695111422005
}`;

lyric = JSON.parse(lyric).data.sentences;
console.log(lyric);

//Xây dựng tính năng karaoke
var karaoke = document.querySelector(".karaoke");
var karaokePlayBtn = document.querySelector(".play");
var karaokeInner = karaoke.querySelector(".karaoke-inner");
var karaokeClose = karaokeInner.querySelector(".close");
var karaokeContent = karaokeInner.querySelector(".karaoke-content");

var songInfo = `
<p>Ai chung tình được mãi</p>
<p>Ca sỹ: Lưu Anh Quân</p>
`;

karaokePlayBtn.addEventListener("click", function () {
  karaokeInner.classList.add("show");
  // karaokeContent.innerHTML = songInfo;
});

karaokeClose.addEventListener("click", function () {
  karaokeInner.classList.remove("show");
  // karaokeContent.innerHTML = "";
});

var number = 2;
var currentPage;
var handleKaraoke = function (currentTime) {
  //Quy đổi currentTime ra mili giây
  currentTime *= 1000;

  var index = lyric.findIndex(function (wordItem) {
    var wordItemArr = wordItem.words;
    return (
      currentTime >= wordItemArr[0].startTime &&
      currentTime <= wordItemArr[wordItemArr.length - 1].endTime
    );
  });

  if (index !== -1) {
    // var karaokeContent = karaokeInner.querySelector(".karaoke-content");

    /*
    Page = 1 -> index = 0 đến 1
    Page = 2 -> index = 2 đến 3
    Page = 3 -> index = 4 đến 5

    index = (page - 1) * 2
    Công thức: page = index / 2 + 1
    */

    var page = Math.floor(index / number + 1);

    // handleColor(currentTime);

    if (page !== currentPage) {
      var offset = (page - 1) * number;

      // console.log(`Màn hình thứ: ${page}`);
      // console.log(`Index = ${index}`, `Offset = ${offset}`);

      if (index >= offset && index < offset + number) {
        // console.log(index);
        karaokeContent.innerText = "";
        var div = document.createElement("div");

        for (var i = offset; i < offset + number; i++) {
          //Vòng lặp các câu trong 1 màn hình
          var p = document.createElement("p");

          //Vòng lặp các từ trong 1 câu
          lyric[i].words.forEach(function (word) {
            var wordEl = document.createElement("span");
            wordEl.classList.add("word");
            wordEl.innerText = word.data;
            wordEl.dataset.startTime = word.startTime;
            wordEl.dataset.endTime = word.endTime;

            var span = document.createElement("span");
            span.innerText = word.data;
            wordEl.append(span);

            p.append(wordEl);

            // if (currentTime >= word.startTime) {
            //   span.style.width = `100%`;

            //   if (
            //     currentTime >= word.startTime &&
            //     currentTime <= word.endTime
            //   ) {
            //     // console.log(word.data);
            //     var wordTime = word.endTime - word.startTime;

            //     span.style.transition = `width ${wordTime}ms linear`;
            //   }
            // }
          });

          div.append(p);

          // if (p.previousElementSibling !== null) {
          //   p.previousElementSibling.remove();
          // }
        }

        karaokeContent.append(div);
      }

      currentPage = page;
    }
  }
};

var karaokeInterval;
audio.addEventListener("play", function () {
  karaokeInterval = setInterval(handleColor);
  //requestAnimationFrame(handleColor);
});

audio.addEventListener("pause", function () {
  clearInterval(karaokeInterval);
});

var handleColor = function () {
  var currentTime = (audio.currentTime * 1000).toFixed(0);

  var wordItems = karaokeContent.querySelectorAll(".word");
  wordItems.forEach(function (wordItem, i) {
    if (
      currentTime > wordItem.dataset.startTime &&
      currentTime < wordItem.dataset.endTime
    ) {
      var rate =
        ((currentTime - wordItem.dataset.startTime) * 100) /
        (wordItem.dataset.endTime - wordItem.dataset.startTime);
      wordItem.children[0].style.width = rate.toFixed(2) + "%";
      if (i > 0) {
        wordItems[i - 1].children[0].style.width = "100%";
      }

      // var wordTime = wordItem.dataset.endTime - wordItem.dataset.startTime;
      // if (wordTime > 50) {
      //   wordItem.children[0].style.transition = `width ${wordTime}ms linear`;
      // }
    }
  });

  requestAnimationFrame(handleColor);
};
