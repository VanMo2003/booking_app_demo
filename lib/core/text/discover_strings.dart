/// Chữ của phần khám phá tour phía khách: chọn sở thích, trang chủ, tìm tour, chi tiết, chia sẻ, voucher.
abstract final class DiscoverStrings {
  // Tab
  static const tabHome = 'Trang chủ';
  static const tabHotels = 'Khách sạn';

  // Chọn sở thích
  static const interestsTitle = 'Bạn thích kiểu du lịch nào?';
  static const interestsSubtitle =
      'Chọn một vài sở thích để chúng tôi gợi ý tour hợp với bạn. Bạn có thể đổi lại bất cứ lúc nào.';
  static const interestsContinue = 'Bắt đầu khám phá';
  static String interestsContinueCount(int n) => 'Bắt đầu khám phá ($n)';
  static const interestsSkip = 'Bỏ qua';
  static const interestsEdit = 'Sở thích du lịch';
  static const interestsSaved = 'Đã lưu sở thích';
  static const interestsSave = 'Lưu sở thích';

  // Trang chủ
  static const homeHeadline = 'Hôm nay bạn muốn đi đâu?';
  static const searchHint = 'Tìm tour, địa điểm: Hạ Long, Sa Pa…';
  static const destinations = 'Điểm đến';
  static const featured = 'Tour nổi bật';
  static const deals = 'Đang khuyến mãi';
  static const forYou = 'Gợi ý cho bạn';
  static String forYouNote(String themes) => 'Theo sở thích: $themes';
  static const pickInterests = 'Chọn sở thích để nhận gợi ý tour hợp với bạn';
  static const pickInterestsAction = 'Chọn sở thích';
  static const vouchers = 'Mã giảm giá';
  static const seeAll = 'Xem tất cả';
  static String destinationTours(int n) => '$n tour';
  static String fromPrice(String price) => 'từ $price';
  static const homeEmpty = 'Chưa có tour nào đang nhận khách';
  static const findHotels = 'Tìm khách sạn';

  // Tìm tour
  static const searchTitle = 'Tìm tour';
  static const anyTheme = 'Tất cả';
  static const anyPrice = 'Mọi mức giá';
  static String underPrice(String price) => 'Dưới $price';
  static String resultCount(int n) => '$n tour';
  static const noResults = 'Không tìm thấy tour phù hợp';
  static const noResultsHint = 'Thử từ khoá khác, bỏ bớt bộ lọc hoặc chọn một điểm đến gợi ý.';

  // Chi tiết tour
  static String salePercent(int percent) => '-$percent%';
  static String saleUntil(String date) => 'Khuyến mãi đến hết $date';
  static const saleOpen = 'Đang khuyến mãi';
  static const pricesTitle = 'Giá tour';
  static const adultPrice = 'Người lớn';
  static const childPrice = 'Trẻ em <12 tuổi';
  static const childSameAsAdult = 'Trẻ em trả như người lớn';
  static const itinerary = 'Lịch trình';
  static const includes = 'Bao gồm';
  static const cancellation = 'Điều khoản huỷ';
  static const cancellationDefault =
      'Liên hệ khách sạn để biết điều kiện huỷ và đổi ngày của tour này.';
  static const organizedBy = 'Tổ chức bởi';
  static const viewHotel = 'Xem khách sạn';
  static const share = 'Chia sẻ';
  static String shareText(String name, String destination, String price, String link) =>
      '$name${destination.isEmpty ? '' : ' · $destination'}\nGiá từ $price/khách\n$link';
  static const copyLink = 'Sao chép liên kết';
  static const linkCopied = 'Đã sao chép liên kết tour';
  static const shareVia = 'Chia sẻ tour';
  static const shareFacebook = 'Facebook';
  static const shareMessenger = 'Messenger';
  static const shareZalo = 'Zalo';
  static const shareMore = 'Ứng dụng khác';

  // Đặt tour
  static const adults = 'Người lớn';
  static const children = 'Trẻ em';
  static const childrenHint = 'Dưới 12 tuổi';
  static String adultPart(int n) => 'Người lớn × $n';
  static String childPart(int n) => 'Trẻ em × $n';
  static const voucher = 'Mã giảm giá';
  static const voucherHint = 'Nhập mã, ví dụ CHAOMUNG';
  static const voucherApply = 'Áp dụng';
  static const voucherRemove = 'Bỏ mã';
  static const voucherPick = 'Chọn mã có sẵn';
  static const voucherNoneHere = 'Cơ sở này chưa có mã giảm giá nào';
  static String voucherLine(String code) => 'Mã $code';
  static String voucherApplied(String code, String amount) => 'Đã áp mã $code: giảm $amount';
}

/// Chữ của mã giảm giá: danh sách của khách và quản lý mã của khách sạn.
abstract final class VoucherStrings {
  static const title = 'Mã giảm giá';
  static const manageTitle = 'Mã giảm giá của khách sạn';
  static const empty = 'Chưa có mã giảm giá nào';
  static const emptyHint = 'Tạo mã để khách nhập khi đặt tour, ví dụ giảm 10% cho đơn đầu tiên.';
  static const add = 'Tạo mã';
  static const edit = 'Sửa mã';
  static const code = 'Mã';
  static const codeHint = 'Chữ không dấu và số, ví dụ HE2026';
  static const titleLabel = 'Tiêu đề';
  static const titleHint = 'Giảm 10% cho đơn tour đầu tiên';
  static const description = 'Mô tả';
  static const type = 'Kiểu giảm';
  static const percent = 'Theo %';
  static const amount = 'Số tiền';
  static const valuePercent = 'Giảm (%)';
  static const valueAmount = 'Giảm (₫)';
  static const maxDiscount = 'Giảm tối đa (₫)';
  static const minOrder = 'Đơn tối thiểu (₫)';
  static const optional = 'Để trống = không giới hạn';
  static const startsAt = 'Bắt đầu';
  static const endsAt = 'Kết thúc';
  static const usageLimit = 'Tổng lượt dùng';
  static const perCustomer = 'Mỗi khách dùng tối đa';
  static const active = 'Đang áp dụng';
  static const scope = 'Áp dụng cho';
  static const allBranches = 'Mọi cơ sở của chuỗi';
  static const saved = 'Đã lưu mã giảm giá';
  static const deleted = 'Đã xoá mã giảm giá';
  static const deleteConfirm = 'Xoá mã giảm giá này? Khách sẽ không dùng được nữa.';
  static const delete = 'Xoá mã';
  static String off(String value) => 'Giảm $value';
  static String offPercent(String percent, String? cap) => 'Giảm $percent%${cap == null ? '' : ', tối đa $cap'}';
  static String minOrderLine(String amount) => 'Đơn từ $amount';
  static String validUntil(String date) => 'HSD $date';
  static String used(int used, int? limit) => limit == null ? 'Đã dùng $used' : 'Đã dùng $used/$limit';
  static const inactive = 'Đã tắt';
  static const expired = 'Hết hạn';
  static const copy = 'Sao chép mã';
  static const copied = 'Đã sao chép mã';
  static const needValue = 'Nhập mức giảm';
  static const percentMax = 'Tối đa 90%';
  static const datesOrder = 'Ngày kết thúc phải sau ngày bắt đầu';
}

/// Chữ thêm cho form tour của quản lý.
abstract final class TourFormStrings {
  static const destination = 'Điểm đến';
  static const destinationHint = 'Hạ Long, Quảng Ninh';
  static const adultPrice = 'Giá người lớn';
  static const childPrice = 'Giá trẻ em';
  static const childPriceHint = 'Để trống = như người lớn';
  static const themes = 'Chủ đề';
  static const themesHint = 'Khách tìm và được gợi ý tour theo chủ đề.';
  static const itinerary = 'Lịch trình';
  static const itineraryHint = 'Mỗi chặng một dòng: giờ (hoặc "Ngày 1 · Sáng"), việc làm, mô tả ngắn.';
  static String step(int n) => 'Chặng $n';
  static const stepTime = 'Giờ';
  static const stepTitle = 'Hoạt động';
  static const stepDescription = 'Mô tả';
  static const addStep = 'Thêm chặng';
  static const removeStep = 'Xoá chặng';
  static const cancellation = 'Điều khoản huỷ';
  static const cancellationHint = 'Huỷ miễn phí trước 3 ngày; trong 1–2 ngày phí 30%…';
  static const promotion = 'Khuyến mãi và nổi bật';
  static const discount = 'Giảm giá (%)';
  static const discountHint = 'Để trống = không giảm';
  static const discountMax = 'Tối đa 90%';
  static const promotionEnds = 'Giảm đến hết';
  static const featured = 'Tour nổi bật';
  static const featuredHint = 'Hiện ở mục "Tour nổi bật" trên trang chủ của khách.';
}
