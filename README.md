# Booking App — ứng dụng Flutter

Ứng dụng đặt phòng khách sạn của đồ án tốt nghiệp, dùng chung BE Spring Boot
`booking_app` (`/booking-app/api/v1`). Một app phục vụ mọi vai trò: sau khi đăng
nhập, app tự đưa người dùng tới khung làm việc của vai trò đó.

| Vai trò | Thanh điều hướng | Việc chính |
|---|---|---|
| Khách chưa đăng nhập | Khám phá | Xem cơ sở, thực đơn, tìm phòng trống theo ngày, chi tiết phòng, đăng ký làm chủ khách sạn |
| Khách hàng | Khám phá · Đơn của tôi · Yêu thích · Tin nhắn · Tài khoản | Đặt phòng, thanh toán VNPay, huỷ đơn, đánh giá, nhắn tin với cơ sở, gắn hồ sơ từng đặt tại quầy |
| Nhân viên | Quầy · Phòng · Khách · Thêm | Quầy lễ tân, đặt tại quầy, xác nhận/thu tiền/hoàn tất đơn, trả lời tin nhắn khách, phòng, tiện ích, dịch vụ, xem thực đơn |
| Quản lý cơ sở | Tổng quan · Quầy · Phòng · Báo cáo · Thêm | Như nhân viên, thêm nhân viên, bảng lương, soạn thực đơn món ăn, thông tin cơ sở, báo cáo và xuất Excel |
| Chủ khách sạn (chờ duyệt) | Màn trạng thái hồ sơ | Theo dõi xét duyệt, sửa hồ sơ, gửi lại khi bị từ chối |
| Chủ khách sạn (đã duyệt) | Tổng quan · Cơ sở · Báo cáo · Tin nhắn · Thêm | Tạo quản lý, mở/đóng cơ sở, báo cáo toàn chuỗi, vào quản lý từng cơ sở để thêm phòng, tiện ích, dịch vụ, thực đơn |
| Quản trị | Tổng quan · Xét duyệt · Tài khoản · Danh mục · Hệ thống | Duyệt/từ chối chủ khách sạn, khoá/mở tài khoản, loại phòng và chức vụ, xem toàn bộ dữ liệu (không tạo tài khoản, phòng, tiện ích, dịch vụ) |

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
build_runner (hoặc để `dart run build_runner watch` chạy nền). Thêm plugin có mã
native (Firebase, app_links, connectivity_plus…) thì phải dừng hẳn app rồi
`flutter run` lại — hot restart không nạp plugin mới.

**Bản web:** BE chưa bật CORS trong Spring Security nên trình duyệt bị chặn ở
preflight `OPTIONS` (401). Muốn chạy web, BE cần `http.cors(...)` và cho phép
`OPTIONS`, hoặc đặt bản build web sau một proxy cùng origin. Android/iOS không bị
ảnh hưởng.

## Cấu trúc

```
lib/
├── main.dart, app.dart   # DI, Firebase, locale tiếng Việt, router, phiên hết hạn, thông báo
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
`dish` (thực đơn món ăn), `chat` (nhắn tin khách ↔ cơ sở), `employee`, `payroll`, `report`, `hotel_chain`, `partner` (đăng ký và xét duyệt chủ
khách sạn), `notification` (hộp thông báo, push, deep link), `account`, `catalog`, `admin`.

Quy ước giao diện: màn hình không tự đặt mã màu, cỡ chữ hay câu chữ — lấy từ
`core/color`, `core/style`, `core/text` và ghép từ `core/component`, để mọi màn
đồng nhất và đổi thiết kế chỉ cần sửa một chỗ.

## Đăng ký chủ khách sạn và xét duyệt

1. Khách vãng lai vào tab **Tài khoản → Đăng ký chủ khách sạn** (`OwnerRegisterScreen`):
   bước 1 tạo tài khoản, bước 2 nhập thông tin khách sạn → **Gửi đăng ký**.
2. App đăng nhập luôn bằng tài khoản vừa tạo và mở **màn chờ duyệt**
   (`OwnerStatusScreen`). Màn này tự hỏi lại máy chủ mỗi 30 giây, khi quay lại app và
   khi có thông báo mới.
3. Quản trị viên mở tab **Xét duyệt** (`OwnerApprovalsScreen`) → chi tiết hồ sơ →
   **Duyệt** hoặc **Từ chối** kèm lý do.
4. Chủ khách sạn nhận thông báo (trong app, push và email). Bị từ chối thì màn chờ
   duyệt hiện lý do và nút **Cập nhật & gửi lại**; được duyệt thì app tự chuyển vào
   khung chủ khách sạn.
5. Mở app lại hoặc chạm nút trong email: phiên đăng nhập vẫn còn, `SessionNavigator`
   hỏi lại trạng thái và đưa thẳng tới đúng màn.

`SessionNavigator.goHome` chọn màn cho chủ khách sạn: chưa có chuỗi → gửi hồ sơ
(`CreateChainScreen`), chưa duyệt → màn chờ duyệt, đã duyệt → `OwnerShellScreen`.

Quản trị viên chỉ xem dữ liệu của cơ sở: màn Phòng, Tiện ích, Dịch vụ, Nhân viên ẩn
nút thêm/sửa/xoá và hiện dải "Chế độ xem" (`Role.canEditBranchContent`).

## Nhắn tin khách hàng ↔ khách sạn

- **Khách hàng** bấm **Nhắn tin** ở trang chi tiết cơ sở (hoặc biểu tượng tin nhắn ở chi tiết đơn)
  → `ChatScreen`. Tab **Tin nhắn** liệt kê các cuộc trò chuyện, có số tin chưa đọc trên tab.
  Cần đăng nhập và có hồ sơ khách hàng.
- **Phía cơ sở dùng chung hộp thư**: nhân viên và quản lý mở **Thêm → Tin nhắn khách hàng** hoặc
  biểu tượng tin nhắn ở màn **Quầy** (`BranchChatInboxScreen`); chủ khách sạn có tab **Tin nhắn**
  gộp mọi cơ sở. Quản trị viên không có tin nhắn.
- **Realtime:** `ChatSocket` giữ một kết nối WebSocket `…/ws/chat?token=…` (gói `web_socket_channel`,
  URL suy ra từ `API_BASE_URL`), tự nối lại khi mất mạng và tải lại phần tin có thể đã lỡ. Gửi tin
  vẫn qua REST. `ChatHub` mở/đóng kết nối theo phiên đăng nhập và khi app chạy nền — lúc đó máy chủ
  gửi thông báo đẩy, chạm vào mở đúng cuộc trò chuyện (`bookingapp://chat/{id}`).
- Tin mới ở màn khác hiện toast; đang mở đúng cuộc trò chuyện thì tự đánh dấu đã đọc. Tin gửi lỗi
  hiện đỏ, chạm để gửi lại hoặc xoá.
- Chạy bản web sau proxy: proxy phải chuyển tiếp cả WebSocket (header `Upgrade`), không thì màn chat
  hiện dải "Đang kết nối lại" (gửi tin vẫn được).

## Thực đơn món ăn

- **Quản lý:** không gian làm việc → **Thêm → Thực đơn** (`DishesScreen`). Lọc theo nhóm
  món (Khai vị → Món chính → Món phụ → Tráng miệng → Đồ uống → Khác), menu ⋮ của từng món để
  sửa, **Đánh dấu tạm hết / Phục vụ trở lại**, xoá. Chỉ chủ khách sạn và quản lý cơ sở được
  sửa (`Role.canManageMenu`); nhân viên và quản trị viên thấy dải "Chế độ xem".
- **Thêm/sửa món** (`DishFormScreen`): chọn ảnh từ máy (tải lên sau khi lưu món) hoặc dán
  link ảnh `http(s)://`, tên, nhóm, giá, mô tả, công tắc còn phục vụ.
- **Phía khách:** trang chi tiết cơ sở có mục **Thực đơn** với vài món đầu (`HotelMenuPreview`,
  tự ẩn khi cơ sở chưa có món hoặc tải lỗi) và nút **Xem thực đơn** mở `HotelMenuScreen`. Món
  tạm hết vẫn hiện nhưng mờ kèm nhãn "Tạm hết". Không cần đăng nhập.

## Thông báo, push và deep link

- **Trong app:** chuông ở đầu các màn quản trị/chờ duyệt (`NotificationBell`), hộp
  thông báo `NotificationsScreen`. `AppEventsListener` (bọc `MaterialApp` trong
  `app.dart`) đếm thông báo chưa đọc mỗi 45 giây và khi quay lại app, có thông báo
  mới thì hiện toast — hoạt động cả khi chưa cấu hình Firebase và trên web.
- **Push (Firebase Cloud Messaging):** `PushService` tự tắt nếu thiếu cấu hình. Để bật
  trên Android:
  1. Tạo project Firebase, thêm app Android package `com.example.booking_app_demo`.
  2. Tải `google-services.json` đặt vào `android/app/` (plugin Google Services chỉ được
     áp dụng khi file này tồn tại). Hoặc truyền `--dart-define=FIREBASE_API_KEY=… 
     FIREBASE_APP_ID=… FIREBASE_MESSAGING_SENDER_ID=… FIREBASE_PROJECT_ID=…`.
  3. Cấu hình `FIREBASE_CREDENTIALS` cho BE (xem README BE) rồi `flutter run` lại.
  Sau khi đăng nhập, app xin quyền thông báo và gửi token lên `POST /notifications/devices`;
  đăng xuất thì gỡ token. Web không nhận push, chỉ có thông báo trong app.
- **Deep link `bookingapp://`:** khai báo trong `AndroidManifest.xml` và `Info.plist`,
  nhận bằng `app_links` (`DeepLinkService`) và mở màn bằng `AppLinkNavigator`
  (`owner-status`, `notifications`, `owner-registrations/{id}`). Email chứa link
  `http(s)` tới trang `/app-links/...` của BE, trang đó chuyển sang `bookingapp://`.
  Thử trên emulator:

  ```bash
  adb shell am start -W -a android.intent.action.VIEW -d "bookingapp://owner-status" com.example.booking_app_demo
  ```

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
