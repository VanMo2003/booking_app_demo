/// Chuỗi cho tính năng nhắn tin giữa khách hàng và cơ sở.
abstract final class ChatStrings {
  static const tabChats = 'Tin nhắn';
  static const title = 'Tin nhắn';
  static const branchInbox = 'Tin nhắn khách hàng';
  static const allBranches = 'Tất cả cơ sở';

  // Hộp thư
  static const emptyCustomer = 'Chưa có cuộc trò chuyện nào';
  static const emptyCustomerHint =
      'Mở một cơ sở và chạm "Nhắn tin" để hỏi phòng, giá hay dịch vụ.';
  static const emptyHotel = 'Chưa có khách nào nhắn tin';
  static const emptyHotelHint = 'Tin nhắn khách gửi tới cơ sở sẽ hiện ở đây.';
  static const loginPrompt = 'Đăng nhập để nhắn tin với khách sạn và xem lại các cuộc trò chuyện.';
  static const profileRequired = 'Hoàn tất hồ sơ để nhắn tin';
  static const profileRequiredHint =
      'Khách sạn cần biết tên và số điện thoại của bạn để trả lời.';
  static const completeProfile = 'Hoàn tất hồ sơ';
  static const you = 'Bạn';
  static const guest = 'Khách hàng';
  static String unreadCount(int n) => n > 99 ? '99+' : '$n';

  // Cuộc trò chuyện
  static const messageAction = 'Nhắn tin';
  static const messageHotel = 'Nhắn khách sạn';
  static const inputHint = 'Nhập tin nhắn…';
  static const send = 'Gửi';
  static const sending = 'Đang gửi…';
  static const failed = 'Chưa gửi được · Chạm để gửi lại';
  static const retry = 'Gửi lại';
  static const discard = 'Xoá tin';
  static const reconnecting = 'Đang kết nối lại — tin nhắn vẫn được gửi';
  static const loadOlderFailed = 'Không tải được tin cũ hơn';
  static const today = 'Hôm nay';
  static const yesterday = 'Hôm qua';
  static String greeting(String hotelName) => 'Gửi lời chào tới $hotelName';
  static const greetingHint =
      'Hỏi về phòng trống, giá, giờ nhận phòng… Chủ khách sạn, quản lý và nhân viên của cơ sở đều nhận được tin.';
  static const hotelEmptyHint = 'Khách chưa gửi tin nào.';
  static const quickReplies = [
    'Cơ sở còn phòng trống cuối tuần này không?',
    'Giờ nhận và trả phòng là mấy giờ?',
    'Khách sạn có chỗ đỗ xe không?',
  ];
  static const tooLong = 'Tin nhắn tối đa 2.000 ký tự';
}
