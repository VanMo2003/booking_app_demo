/// Chuỗi cho các tính năng AI: tìm phòng bằng câu nói và trợ lý lễ tân trong chat.
abstract final class AiStrings {
  static const assistantName = 'Trợ lý AI';

  // Tìm phòng bằng AI
  static const searchEntry = 'Hỏi AI tìm phòng';
  static const searchEntryHint = '"Phòng 2 người ở Hà Đông cuối tuần, dưới 1 triệu"';
  static const searchTitle = 'Tìm phòng bằng AI';
  static const searchIntro =
      'Mô tả nơi bạn muốn ở. AI hiểu ngày, số người, mức giá, khu vực và tiện ích; phòng trống và giá lấy trực tiếp từ hệ thống.';
  static const searchHint = 'Ví dụ: phòng cho 4 người gần Hồ Gươm cuối tuần này, dưới 1,5 triệu';
  static const searchAction = 'Tìm';
  static const examplesTitle = 'Thử hỏi';
  static const examples = [
    'Phòng cho 2 người ở Hà Đông cuối tuần này dưới 2 triệu',
    'Khách sạn có hồ bơi gần Hồ Gươm',
    'Phòng gia đình 4 người, có bãi đỗ ô tô',
  ];
  static const understood = 'AI hiểu yêu cầu là';
  static String resultsCount(int n) => '$n cơ sở phù hợp';
  static const noResults = 'Chưa có cơ sở nào khớp';
  static const noResultsHint = 'Thử bớt điều kiện: mức giá, tiện ích hoặc khu vực.';
  static String roomsMatching(int n) => '$n phòng phù hợp';
  static String fromPrice(String price) => 'từ $price/đêm';
  static String guests(int n) => '$n khách';
  static String priceUnder(String price) => 'Dưới $price';
  static String priceOver(String price) => 'Trên $price';
  static String priceBetween(String min, String max) => '$min – $max';

  // Tìm tour bằng AI
  static const tourEntry = 'Hỏi AI tìm tour';
  static const tourEntryHint = '"Tour biển Hạ Long 2 ngày cho gia đình, dưới 2 triệu"';
  static const tourTitle = 'Tìm tour bằng AI';
  static const tourIntro =
      'Kể về chuyến đi bạn muốn. AI hiểu điểm đến, chủ đề, ngày đi, số người và mức giá; tour, giá và chỗ còn lại lấy trực tiếp từ hệ thống.';
  static const tourHint = 'Ví dụ: tour biển Hạ Long 2 ngày 1 đêm cho 2 người lớn 1 trẻ em, dưới 3 triệu';
  static const tourExamples = [
    'Tour biển Hạ Long 2 ngày 1 đêm cho 2 người lớn 1 trẻ em',
    'Tour ẩm thực phố cổ Hà Nội đi về trong ngày dưới 500k',
    'Tour núi Sa Pa kèm khách sạn, thích thiên nhiên',
  ];
  static String tourResultsCount(int n) => '$n tour phù hợp';
  static const tourNoResults = 'Chưa có tour nào khớp';
  static const tourNoResultsHint = 'Thử bớt điều kiện: mức giá, ngày đi hoặc chủ đề.';
  static String tourGuests(int adults, int children) =>
      children == 0 ? '$adults người lớn' : '$adults người lớn · $children trẻ em';
  static String tourNights(int n) => n == 0 ? 'Đi về trong ngày' : '$n đêm';
  static const tourWithRooms = 'Có kèm khách sạn';
  static const tourWithoutRooms = 'Không kèm khách sạn';

  // Lên kế hoạch chuyến đi bằng AI
  static const tripEntry = 'Lên kế hoạch chuyến đi';
  static const tripEntryHint = '"Hạ Long 3 ngày 2 đêm, 2 người lớn 1 trẻ, 6 triệu"';
  static const tripTitle = 'Kế hoạch chuyến đi';
  static const tripIntro =
      'Kể về chuyến đi: điểm đến, mấy ngày, mấy người và khoảng tiền. AI xếp lịch trình từng ngày từ khách sạn còn phòng và tour đang chạy; mọi khoản tiền do hệ thống tính.';
  static const tripHint = 'Ví dụ: Hạ Long 3 ngày 2 đêm cho 2 người lớn 1 trẻ em, khoảng 6 triệu, thích biển';
  static const tripAction = 'Lên kế hoạch';
  static const tripExamples = [
    'Hạ Long 3 ngày 2 đêm cho 2 người lớn 1 trẻ em, khoảng 6 triệu, thích biển',
    'Cuối tuần này ở Ninh Bình cho 2 người, thích thiên nhiên và văn hoá',
    'Sa Pa 2 ngày 1 đêm cho 4 người, dưới 8 triệu',
  ];
  static const tripNothing = 'Chưa lên được kế hoạch';
  static const tripNothingHint = 'Thử nói rõ điểm đến và số ngày, hoặc chọn ngày khác.';
  static const tripStay = 'Nơi ở';
  static const tripSchedule = 'Lịch trình';
  static const tripToursTitle = 'Tour trong kế hoạch';
  static const tripCostTitle = 'Chi phí dự kiến';
  static const tripCostRooms = 'Tiền phòng';
  static const tripCostTours = 'Tiền tour';
  static const tripCostVoucher = 'Mã giảm giá';
  static const tripCostTotal = 'Tổng cộng';
  static const tripCostPerPerson = 'Mỗi người';
  static const tripCostLeft = 'Còn lại so với ngân sách';
  static const tripCostOver = 'Vượt ngân sách';
  static const tripCostNote = 'Tiền phòng và tiền tour theo giá hiện tại, chưa gồm ăn uống ngoài tour.';
  static const tripBookStay = 'Đặt phòng';
  static const tripDay = 'Ngày';
  static String tripNights(int nights) => '${nights + 1} ngày $nights đêm';
  static String tripRoom(String number, String type) => 'Phòng $number · $type';
  static String tripPerNight(String price) => '$price/đêm';
  static String tripBudget(String price) => 'Ngân sách $price';

  // Tóm tắt đánh giá
  static const digestTitle = 'Khách nói gì về cơ sở này';
  static const digestPros = 'Thường được khen';
  static const digestCons = 'Thường bị phàn nàn';
  static String digestFrom(int n) => 'Tóm tắt từ $n đánh giá của khách';
  static const digestNote = 'AI tóm tắt từ đánh giá thật của khách, không phải lời của khách sạn.';
  static String digestStars(int stars) => '$stars★';

  // AI soạn nội dung tour
  static const draftTour = 'AI soạn nội dung';
  static const draftTourHint = 'Nhập tên tour và điểm đến, AI viết mô tả, lịch trình và điều khoản huỷ để bạn sửa lại.';
  static const draftTourNeedsName = 'Nhập tên tour trước đã';
  static const draftTourDone = 'Đã điền nội dung nháp — đọc lại và sửa trước khi lưu';
  static const draftTourEmpty = 'AI chưa soạn được nội dung, thử lại sau';
  static const draftOverwriteTitle = 'Thay nội dung đang có?';
  static const draftOverwriteMessage =
      'Mô tả, phần bao gồm, lịch trình và điều khoản huỷ sẽ bị thay bằng bản AI soạn. Giá và ảnh giữ nguyên.';
  static const draftOverwriteConfirm = 'Thay';

  // Hỏi AI về số liệu
  static const askTitle = 'Hỏi AI về số liệu';
  static const askTooltip = 'Hỏi AI về số liệu';
  static const askIntro =
      'Hỏi bằng câu bình thường. AI chỉ đọc đúng số liệu báo cáo của bạn trong kỳ được hỏi, không tự tính thêm.';
  static const askHint = 'Ví dụ: doanh thu tháng này so với tháng trước thế nào?';
  static const askAction = 'Hỏi';
  static const askExamples = [
    'Doanh thu tháng này so với tháng trước thế nào?',
    'Tour nào bán tốt nhất trong 30 ngày qua?',
    'Tỉ lệ huỷ đơn có cao không, nên làm gì?',
  ];
  static const askHighlights = 'Số đáng chú ý';
  static const askSuggestions = 'Nên làm gì';
  static const askPeriod = 'Kỳ số liệu';
  static const copyAnswer = 'Sao chép câu trả lời';
  static const answerCopied = 'Đã sao chép';
  static const askNote = 'Câu trả lời dựa trên số liệu báo cáo của chính bạn — mở tab báo cáo để xem chi tiết.';

  // AI tư vấn giá phòng
  static const pricingTitle = 'AI tư vấn giá phòng';
  static const pricingMenu = 'AI tư vấn giá phòng';
  static const pricingRefresh = 'Xem lại';
  static const pricingByType = 'Theo loại phòng';
  static const pricingRisks = 'Cần cân nhắc';
  static const pricingEmpty = 'Chưa có loại phòng nào để tư vấn';
  static const pricingRaise = 'Tăng';
  static const pricingHold = 'Giữ nguyên';
  static const pricingLower = 'Giảm';
  static const pricingNote =
      'Gợi ý dựa trên số liệu của chính cơ sở bạn. AI không đổi giá phòng — bạn tự sửa trong mục Phòng nếu thấy hợp lý.';
  static String pricingPeriod(String from, String to, int days) =>
      'Số liệu $from – $to, kèm lượng đã đặt trước cho $days ngày tới';
  static String pricingRooms(int n) => '$n phòng';
  static String pricingOccupancy(String percent) => 'Lấp phòng $percent%';
  static String pricingList(String price) => 'Niêm yết $price';
  static String pricingAdr(String price) => 'ADR thực $price';

  // Trợ lý riêng của khách
  static const guestTitle = 'Trợ lý của bạn';
  static const guestEntry = 'Trợ lý';
  static const guestIntro =
      'Hỏi về chính các đơn của bạn. Trợ lý chỉ đọc đơn phòng, đơn tour, mã giảm giá và sở thích của bạn; không đặt, không huỷ và không thanh toán hộ.';
  static const guestHint = 'Ví dụ: đơn sắp tới của tôi thế nào?';
  static const guestExamples = [
    'Đơn sắp tới của tôi thế nào?',
    'Tôi còn mã giảm giá nào dùng được không?',
    'Tôi đã đặt tour nào, ngày mấy?',
  ];
  static const guestNext = 'Nên làm gì tiếp';
  static const guestFrom = 'Trả lời từ các đơn của chính bạn';
  static const guestNote =
      'Muốn đặt, huỷ hay thanh toán thì làm trong ứng dụng; cần khách sạn hỗ trợ thì nhắn trong mục Tin nhắn.';

  // Trợ lý lễ tân trong chat
  static const suggest = 'Gợi ý trả lời bằng AI';
  static const suggestionNote = 'Bản nháp AI soạn từ dữ liệu của cơ sở — kiểm tra trước khi gửi.';
  static String suggestionHandoff(String reason) => 'AI đề nghị nhân viên xử lý: $reason';
  static const needsStaff = 'Cần nhân viên';
  static String handedOff(String? reason) =>
      'Trợ lý AI đã chuyển cho nhân viên${reason == null || reason.isEmpty ? '' : ': $reason'}';
  static const autoReplyTitle = 'Trợ lý AI tự trả lời';
  static String autoReplyHint(int seconds) =>
      'Khách nhắn mà sau ${_duration(seconds)} chưa ai trả lời thì trợ lý AI trả lời thay (phòng trống, giá, tiện ích, thực đơn). Việc cần người như huỷ đơn, khiếu nại được chuyển cho nhân viên.';
  static const autoReplyActiveForStaff =
      'Trợ lý AI đang bật: tin khách chưa ai trả lời sẽ được AI trả lời thay.';
  static const autoReplyOn = 'Đã bật trợ lý AI tự trả lời';
  static const autoReplyOff = 'Đã tắt trợ lý AI tự trả lời';

  static String _duration(int seconds) =>
      seconds < 60 ? '$seconds giây' : '${(seconds / 60).round()} phút';
}
