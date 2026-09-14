# Booking App — ứng dụng Flutter

Ứng dụng đặt phòng khách sạn của đồ án tốt nghiệp, dùng chung BE Spring Boot
`booking_app` (`/booking-app/api/v1`). Một app phục vụ mọi vai trò: sau khi đăng
nhập, app tự đưa người dùng tới khung làm việc của vai trò đó.

| Vai trò | Thanh điều hướng | Việc chính |
|---|---|---|
| Khách chưa đăng nhập | Khám phá | Xem cơ sở, tìm phòng trống theo ngày, chi tiết phòng |
| Khách hàng | Khám phá · Đơn của tôi · Yêu thích · Tài khoản | Đặt phòng, thanh toán VNPay, huỷ đơn, đánh giá, gắn hồ sơ từng đặt tại quầy |
| Nhân viên | Quầy · Phòng · Khách · Thêm | Quầy lễ tân, đặt tại quầy, xác nhận/thu tiền/hoàn tất đơn, phòng, tiện ích, dịch vụ |
| Quản lý cơ sở | Tổng quan · Quầy · Phòng · Báo cáo · Thêm | Như nhân viên, thêm nhân viên, bảng lương, thông tin cơ sở, báo cáo và xuất Excel |
| Chủ khách sạn | Tổng quan · Cơ sở · Báo cáo · Thêm | Tạo chuỗi, mở/đóng cơ sở, giao quản lý, báo cáo toàn chuỗi, vào quản lý từng cơ sở |
| Quản trị | Tổng quan · Tài khoản · Danh mục · Hệ thống | Tài khoản, loại phòng và chức vụ, tra cứu dữ liệu toàn hệ thống |

## Chạy app

Cần Flutter 3.38 (Dart 3.10) và BE đang chạy. Tài khoản quản trị mặc định của BE:
`admin123` / `admin123`.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

Địa chỉ BE mặc định: Android emulator dùng `http://10.0.2.2:8080/booking-app/api/v1`,
nền tảng khác dùng `http://localhost:8080/booking-app/api/v1`. Chạy trên điện thoại
thật hoặc trỏ tới máy chủ khác:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8080/booking-app/api/v1
```

Mỗi khi sửa lớp có `@RoutePage`, `@injectable` hoặc `@RestApi`, chạy lại
build_runner (hoặc để `dart run build_runner watch` chạy nền).

**Bản web:** BE chưa bật CORS trong Spring Security nên trình duyệt bị chặn ở
preflight `OPTIONS` (401). Muốn chạy web, BE cần `http.cors(...)` và cho phép
`OPTIONS`, hoặc đặt bản build web sau một proxy cùng origin. Android/iOS không bị
ảnh hưởng.

## Cấu trúc

```
lib/
├── main.dart, app.dart   # DI, locale tiếng Việt, router, xử lý phiên hết hạn
├── core/
│   ├── bloc/        # LoadState, LoadCubit, PagedCubit, ActionResult
│   ├── color/       # AppColors — bảng màu duy nhất; StatusTone cho trạng thái
│   ├── component/   # widget dùng chung: nút, ô nhập, thẻ, badge, biểu đồ,
│   │                #   trạng thái tải/lỗi/rỗng, danh sách phân trang…
│   ├── config/      # AppConfig: địa chỉ BE, timeout, đường dẫn ảnh
│   ├── constants/   # kích thước trang, loại hình cơ sở, tỉnh thành, khoá lưu trữ
│   ├── di/          # get_it + injectable
│   ├── enums/       # enum khớp 1-1 với BE
│   ├── navigation/  # AppRouter (auto_route), rootRouter
│   ├── network/     # Dio + làm mới token, ApiResponse, AppException, Paged
│   ├── storage/     # token (secure storage), SharedPreferences
│   ├── style/       # AppTextStyles (Be Vietnam Pro), khoảng cách, bo góc, đổ bóng
│   ├── text/        # toàn bộ câu chữ tiếng Việt, chia theo nhóm màn
│   ├── theme/       # AppTheme Material 3 dựng từ color + style
│   └── utils/       # định dạng tiền/ngày, validator, lưu file, tìm kiếm không dấu
└── features/<tính năng>/
    ├── data/          # API Retrofit, model JSON ↔ entity, repository
    ├── domain/        # entity, interface repository, use case
    └── presentation/  # cubit, màn hình @RoutePage, widget riêng
```

Tính năng: `auth`, `splash`, `shell` (khung tab từng vai trò), `hotel`, `room`,
`booking`, `payment`, `feedback`, `favorite`, `customer`, `amenity`, `service`,
`employee`, `payroll`, `report`, `hotel_chain`, `account`, `catalog`, `admin`.

Quy ước giao diện: màn hình không tự đặt mã màu, cỡ chữ hay câu chữ — lấy từ
`core/color`, `core/style`, `core/text` và ghép từ `core/component`, để mọi màn
đồng nhất và đổi thiết kế chỉ cần sửa một chỗ.

## Màn lỗi hệ thống, mất mạng, dữ liệu trống

Lỗi được phân nhóm trong `core/network/app_exception.dart` (`AppErrorKind`).
Khi request không tới được máy chủ, `ConnectivityInterceptor` kiểm tra thiết bị
còn mạng không — nhờ vậy "mất mạng" và "BE không phản hồi" hiện hai màn khác nhau.

| Component | Khi nào | Nút |
|---|---|---|
| `AppErrorView` | BE không chạy, máy chủ lỗi 5xx, lỗi không xác định | Tải lại |
| `AppOfflineView` | Thiết bị mất mạng; có mạng lại thì tự tải lại | Tải lại |
| `AppEmptyView` | Danh sách trống | Thêm mới (khi truyền `onAdd`) |
| `AppFailureView` | Tự chọn một trong các màn trên theo nhóm lỗi | — |

Mọi component đều có `showImage`, `showTitle`, `showDescription`, `showButton`,
và nhận ảnh riêng qua `image` (widget) hoặc `imageAsset` (ảnh trong assets).
Cubit báo lỗi bằng `state.toError(error)`; `LoadStateView` tự hiện đúng component.

```dart
AppEmptyView(
  title: 'Chưa có phòng',
  onAdd: openRoomForm,       // hiện nút "Thêm mới"
  showDescription: false,
)
```

## Xem log request

Bản debug có trình xem request (`requests_inspector`, gắn vào Dio trong
`core/di/app_module.dart`). Điện thoại: lắc máy hoặc nhấn giữ màn hình;
web/desktop: nhấn giữ màn hình.

## FE bù cho các chỗ BE còn thiếu

- Nhân viên: hồ sơ chưa có `hotelId` → FE dò cơ sở qua `/employees/by-hotel`.
- Chưa có API đọc lại: danh sách quản lý của chuỗi, phiếu lương đã tạo, cơ sở yêu
  thích, đơn đã đánh giá → FE lưu cục bộ.
- `PUT /bookings/{id}/payment-status` trả thẳng object đơn, không bọc `ApiResponse`.
- Báo cáo: BE bắt buộc `from < to` và tính lấp đầy theo `[from, to)` → FE chuẩn
  hoá khoảng ngày trước khi gọi.
- File Excel được đặt tên phía FE vì header `Content-Disposition` không đọc được.

Chi tiết từng màn gọi API nào, request/response ra sao: xem tài liệu
"Sổ tay FE Booking App".
