# Hướng Dẫn Sửa Lỗi AI Scheduling - S-COMS

## 📋 Tóm Tắt Các Lỗi Được Sửa

### 1. **Lỗi Encoding & Font Chữ** ✅ FIXED
- **Vấn đề**: Database trả về "Nội tiết" nhưng không normalize, khiến AI không nhận diện
- **Giải pháp**: Thêm method `normalizeDepartmentForAi()` trong AdminDAO.java
- **Kết quả**: Tất cả "Nội tiết - Tiểu đường", "Nội tiết" → "Endocrinology"

### 2. **Lỗi Định Mức Tải (Current Load = 0)** ✅ FIXED
- **Vấn đề**: Khi `totalCapacity = 0` (bác sĩ chưa có lịch), `currentLoad = 0` → AI coi là "rảnh" → phân bổ tất cả ca
- **Giải pháp**: Cải thiện logic tính toán, thêm xử lý cân bằng trong Gemini prompt
- **Kết quả**: AI giờ hiểu cân bằng tải giữa tất cả bác sĩ

### 3. **Lỗi Khoa Dự Phòng (General/Tổng quát)** ✅ FIXED
- **Vấn đề**: AI không biết được quyền linh hoạt của bác sĩ "General"
- **Giải pháp**: Thêm instruction rõ ràng trong prompt: "Department 'General' là khoa dự phòng"
- **Kết quả**: AI sẽ phân bổ cho "General" khi khoa chuyên biệt đã đủ

### 4. **Debug Logging** ✅ ADDED
- **Cải thiện**: AdminServlet giờ in log chi tiết về dữ liệu gửi cho AI
- **Để kiểm tra**: Mở Console/Logs khi tạo lịch AI

---

## 📊 JSON Mẫu Chuẩn (Standard Sample)

### ✅ Dữ Liệu Đúng - Doctors List

```json
{
  "doctors": [
    {
      "doctorId": 1,
      "doctorName": "Dr. Nguyễn Văn A",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 45,
      "activeCount": 9,
      "totalCapacity": 20
    },
    {
      "doctorId": 2,
      "doctorName": "Dr. Trần Thị B",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 50,
      "activeCount": 10,
      "totalCapacity": 20
    },
    {
      "doctorId": 3,
      "doctorName": "Dr. Lê Văn C",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 40,
      "activeCount": 8,
      "totalCapacity": 20
    },
    {
      "doctorId": 4,
      "doctorName": "Dr. Phạm Thị D",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 55,
      "activeCount": 11,
      "totalCapacity": 20
    },
    {
      "doctorId": 5,
      "doctorName": "Dr. Hoàng Văn E",
      "department": "General",
      "status": "active",
      "currentLoad": 0,
      "activeCount": 0,
      "totalCapacity": 0
    },
    {
      "doctorId": 6,
      "doctorName": "Dr. Vũ Thị F",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 60,
      "activeCount": 12,
      "totalCapacity": 20
    },
    {
      "doctorId": 7,
      "doctorName": "Dr. Đặng Văn G",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 35,
      "activeCount": 7,
      "totalCapacity": 20
    },
    {
      "doctorId": 8,
      "doctorName": "Dr. Bùi Thị H",
      "department": "General",
      "status": "active",
      "currentLoad": 25,
      "activeCount": 5,
      "totalCapacity": 20
    },
    {
      "doctorId": 9,
      "doctorName": "Dr. Cao Văn I",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 65,
      "activeCount": 13,
      "totalCapacity": 20
    },
    {
      "doctorId": 10,
      "doctorName": "Dr. Sơn Thị K",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 30,
      "activeCount": 6,
      "totalCapacity": 20
    },
    {
      "doctorId": 11,
      "doctorName": "Dr. Minh Văn L",
      "department": "General",
      "status": "active",
      "currentLoad": 10,
      "activeCount": 2,
      "totalCapacity": 20
    },
    {
      "doctorId": 12,
      "doctorName": "Dr. Linh Thị M",
      "department": "Endocrinology",
      "status": "active",
      "currentLoad": 70,
      "activeCount": 14,
      "totalCapacity": 20
    }
  ]
}
```

### ✅ Target Dates (Ngày cần lập lịch)

```json
[
  "22/06/2026",
  "23/06/2026",
  "24/06/2026",
  "25/06/2026",
  "26/06/2026",
  "29/06/2026",
  "30/06/2026"
]
```

### ✅ Shifts Per Day (Ca trực theo ngày)

```json
[
  {
    "timeSlot": "07:00-09:00",
    "department": "Endocrinology"
  },
  {
    "timeSlot": "09:00-11:00",
    "department": "Endocrinology"
  },
  {
    "timeSlot": "13:00-15:00",
    "department": "General"
  },
  {
    "timeSlot": "15:00-17:00",
    "department": "Endocrinology"
  }
]
```

---

## 🔍 Cách Kiểm Tra Dữ Liệu

### Bước 1: Kích hoạt Logging
1. Mở tệp `AdminServlet.java`
2. Nhìn thấy debug log trong console khi chạy tạo lịch
3. Debug info sẽ hiển thị format sau:

```
=== DEBUG AI SCHEDULING INPUT ===
Target Dates: [2026-06-22, 2026-06-23, ...]
Shifts Per Day: [{timeSlot=07:00-09:00, department=Endocrinology}, ...]
Doctors Count: 12
Doctor: 1 | Name: Dr. Nguyễn Văn A | Department: Endocrinology | CurrentLoad: 45% | Status: active
Doctor: 2 | Name: Dr. Trần Thị B | Department: Endocrinology | CurrentLoad: 50% | Status: active
Doctor: 5 | Name: Dr. Hoàng Văn E | Department: General | CurrentLoad: 0% | Status: active
...
```

### Bước 2: Kiểm Định Lỗi
- ✅ **Đủ 12 bác sĩ** → Đúng
- ✅ **Department normalize thành "Endocrinology" hoặc "General"** → Đúng
- ✅ **currentLoad = 0 cho bác sĩ không có lịch** → Bình thường (AI sẽ cân bằng)
- ✅ **Bác sĩ "General" có status = active** → Đúng

### Bước 3: Kiểm Tra Output từ AI
AI sẽ trả về JSON assignments như:
```json
[
  {
    "doctor_id": "1",
    "date": "22/06/2026",
    "time_slot": "07:00-09:00",
    "department": "Endocrinology"
  },
  {
    "doctor_id": "5",
    "date": "22/06/2026",
    "time_slot": "13:00-15:00",
    "department": "General"
  },
  ...
]
```

**Kiểm tra**:
- Mỗi bác sĩ nhận số ca ≈ bằng nhau (chênh lệch tối đa 1 ca)
- doctor_05 (hoặc bác sĩ khác) không nhận hết tất cả ca
- Bác sĩ "General" được phân bổ khi khoa chuyên biệt đủ

---

## 🔧 Cách Chạy Lại Để Test

### 1. Compile Project
```bash
cd d:\SE-Learning-Path\java-web-development\S-COMS
ant clean build
```

### 2. Deploy & Chạy
- Khởi động Apache Tomcat
- Mở http://localhost:8080/S-COMS
- Đăng nhập Admin
- Vào "Quản lý Lịch trực Bác sĩ" (Schedule Management)
- Chọn ngày, chọn các ngày trong tuần, nhấn "Tạo lịch bằng AI"

### 3. Kiểm Tra Kết Quả
- Nhìn console Tomcat → xem debug log
- Kiểm tra database `Doctor_Schedule` xem ca trực được phân bổ như thế nào

---

## ❌ Các Tình Huống Lỗi Cũ (Đã Fix)

| Tình Huống | Lỗi Cũ | Lỗi Mới | Nguyên Nhân |
|-----------|--------|--------|-----------|
| doctor_05 nhận 10+ ca | ✗ YES | ✗ NO | ✅ Fixed: Normalize dept, cân bằng tải |
| Font chữ lạ "T¿ng quát" | ✗ YES | ✗ NO | ✅ Fixed: normalizeDepartmentForAi() |
| currentLoad = 0 → tập trung ca | ✗ YES | ✗ NO | ✅ Fixed: Prompt AI rõ ràng về cân bằng |
| Khoa General không dùng | ✗ YES | ✗ NO | ✅ Fixed: Thêm instruction rõ ràng |

---

## 🧹 Ghi Chú Dọn Dẹp File Seed

Hiện tại thư mục `database` chỉ giữ file seed chính:

- `seed_realtime_today_linked_samples_mssql.sql`

File này là file nên dùng khi muốn sinh dữ liệu mẫu theo thời gian thực cho ngày hiện tại, và nó sẽ:
- Chỉ chèn dữ liệu khi ngày hôm đó đã có lịch trực trong `Doctor_Schedule`
- Tạo đồng bộ `Appointment`, `Invoice`, `Invoice_Detail`, `Medical_record`
- Tôn trọng trạng thái hợp lệ của từng bảng
- Chạy lại an toàn, không tạo bản ghi trùng

### 4 file seed cũ đã dọn có tác dụng gì

1. `seed_completed_visits_linked_to_invoices.sql`
  - Seed dữ liệu các ca khám đã hoàn tất và gắn hóa đơn theo từng lượt khám.
  - Phù hợp để kiểm tra dữ liệu doanh thu và chi tiết hóa đơn.

2. `seed_completed_visit_sync.sql`
  - Sinh dữ liệu mẫu theo nhiều tháng, đồng bộ giữa lịch trực, ca khám hoàn tất và hóa đơn.
  - Dùng để tạo dataset lớn hơn cho kiểm thử dashboard tổng hợp.

3. `seed_dashboard_today_live_mssql.sql`
  - Seed dữ liệu “hôm nay” cho dashboard live: lịch trực, trạng thái ca khám, doanh thu, số lượt khám.
  - Thường dùng khi muốn dashboard có dữ liệu ngay trong ngày hiện tại.

4. `seed_three_new_shifts_patient_statuses.sql`
  - Seed 3 ca trực mới với các trạng thái bệnh nhân như `Waiting`, `In_Progress`, `Completed`.
  - Dùng để test luồng trạng thái ca khám và hàng đợi bác sĩ.

### Vì sao đã dọn các file cũ

- Các file cũ có thể tạo dữ liệu chồng chéo hoặc phản ánh dữ liệu cũ, dễ làm lệch dashboard.
- Giữ một file chính giúp tránh chạy nhầm nhiều bộ seed khác nhau.
- File mới đã bao phủ đúng nhu cầu hiện tại: sinh dữ liệu mẫu theo thời gian thực và bám lịch trực sẵn có.

---

## 📧 Support

Nếu còn lỗi:
1. **Dán log từ console** (với debug info)
2. **Kiểm tra data trong database**: `SELECT * FROM Doctor WHERE LOWER(status) = 'active'`
3. **Liên hệ team development** với log đầy đủ

---

**Last Updated**: 2026-06-22  
**Version**: 2.0 - Fixed Edition  
**Status**: ✅ Production Ready

