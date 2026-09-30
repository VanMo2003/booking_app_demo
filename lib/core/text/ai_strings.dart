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
