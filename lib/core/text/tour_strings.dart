/// Chuỗi cho tour tham quan của cơ sở: quản lý (chủ khách sạn, quản lý) và phần khách xem.
abstract final class TourStrings {
  static const title = 'Tour tham quan';
  static String toursCount(int n) => '$n tour';
  static const running = 'Đang nhận khách';
  static const paused = 'Tạm ngừng';
  static const perGuest = '/khách';

  // Quản lý
  static const addTour = 'Thêm tour';
  static const editTour = 'Sửa tour';
  static const empty = 'Chưa có tour nào';
  static const emptyHint =
      'Thêm tour để khách tham khảo khi xem cơ sở, và để trợ lý AI gợi ý tour cho khách trong tin nhắn.';
  static const readOnlyNotice =
      'Chế độ xem — chỉ chủ khách sạn và quản lý cơ sở được thêm, sửa, xoá tour.';
  static const saved = 'Đã lưu tour';
  static const deleted = 'Đã xoá tour';
  static const markPaused = 'Tạm ngừng tour';
  static const markRunning = 'Mở lại tour';
  static const markedPaused = 'Đã tạm ngừng tour';
  static const markedRunning = 'Tour đã mở lại';

  // Biểu mẫu
  static const photo = 'Ảnh tour';
  static const photoHint = 'Ảnh phong cảnh hoặc hoạt động nổi bật của tour, khổ ngang.';
  static const tourInfo = 'Thông tin tour';
  static const name = 'Tên tour';
  static const nameHint = 'VD: Food tour phố cổ buổi tối';
  static const price = 'Giá mỗi khách (₫)';
  static const pricePerGuest = 'Giá mỗi khách';
  static const duration = 'Thời lượng';
  static const durationHint = 'VD: 4 giờ, 1 ngày, 2 ngày 1 đêm';
  static const departure = 'Khởi hành';
  static const departureHint = 'VD: 8:00 hằng ngày';
  static const includes = 'Giá đã gồm';
  static const includesHint = 'Xe đưa đón, vé tham quan, hướng dẫn viên…';
  static const maxGuests = 'Số khách tối đa';
  static const maxGuestsHint = 'Để trống nếu không giới hạn';
  static const description = 'Mô tả, lịch trình';
  static const descriptionHint = 'Điểm đến, hoạt động, lưu ý cho khách…';
  static const availableHint =
      'Tắt khi tạm ngừng — tour vẫn hiện nhưng khách thấy "Tạm ngừng" và trợ lý AI không gợi ý.';

  // Phía khách
  static const sectionSubtitle = 'Khách sạn tổ chức, đặt qua lễ tân';
  static String viewAll(int n) => 'Xem cả $n tour';
  static String maxGuestsValue(int n) => 'Tối đa $n khách';
  static const ask = 'Hỏi khách sạn về tour này';
  static String askDraft(String name) => 'Mình muốn hỏi về tour "$name": ';
  static const bookingNote =
      'Tour đặt qua khách sạn: nhắn tin để nhân viên xác nhận ngày khởi hành và số khách.';
  static const guestEmpty = 'Cơ sở chưa có tour';
}
