abstract final class ReportStrings {
  static const branchReportsTitle = 'Báo cáo cơ sở';
  static const chainReportsTitle = 'Báo cáo chuỗi';

  // Tab
  static const tabRevenue = 'Doanh thu';
  static const tabOccupancy = 'Lấp đầy';
  static const tabBreakdown = 'Cơ cấu';
  static const tabPeople = 'Khách & NV';

  // Khoảng thời gian
  static const last7Days = '7 ngày qua';
  static const thisMonth = 'Tháng này';
  static const lastMonth = 'Tháng trước';
  static const thisYear = 'Năm nay';
  static const custom = 'Tuỳ chọn';

  // Độ chi tiết
  static const byDay = 'Ngày';
  static const byWeek = 'Tuần';
  static const byMonth = 'Tháng';
  static const byYear = 'Năm';

  // Doanh thu
  static const totalRevenue = 'Tổng doanh thu';
  static const completedBookings = 'Đơn hoàn tất';
  static const averagePerBooking = 'Trung bình mỗi đơn';
  static const revenueNote =
      'Chỉ tính đơn đã hoàn tất, theo ngày trả phòng.';
  static String weekLabel(int week) => 'Tuần $week';
  static const branchComparison = 'So sánh cơ sở';
  static String branchComparisonNote(int year) =>
      'Doanh thu năm $year của từng cơ sở trong chuỗi';

  // Lấp đầy
  static const occupancyRate = 'Tỷ lệ lấp đầy';
  static const totalRooms = 'Số phòng';
  static const roomNights = 'Đêm phòng';
  static const occupiedNights = 'Đêm có khách';
  static const occupancyNote =
      'Tính mọi đơn chưa huỷ, số đêm giao với khoảng đã chọn.';
  static const dailyOccupancy = 'Lấp đầy theo ngày';
  static const dailyOccupancyTooLong =
      'Chọn khoảng tối đa 92 ngày để xem lấp đầy theo ngày.';
  static const dailyOccupancyChainOnly =
      'Lấp đầy theo ngày chỉ có ở báo cáo từng cơ sở.';

  // Cơ cấu
  static const byRoomType = 'Doanh thu theo loại phòng';
  static const byService = 'Doanh thu theo dịch vụ';
  static String bookedRooms(int n) => '$n lượt phòng';
  static String nights(int n) => '$n đêm';
  static String quantity(int n) => '$n lượt';
  static const roomTypeNote =
      'Doanh thu phòng tính bằng giá phòng hiện tại × số đêm.';

  // Khách & nhân viên
  static const topCustomers = 'Khách chi tiêu nhiều nhất';
  static const staffPerformance = 'Hiệu suất nhân viên';
  static const staffPerformanceNote = 'Chỉ tính đơn được tạo tại quầy.';
  static const cancellation = 'Tỷ lệ huỷ đơn';
  static const totalBookings = 'Tổng đơn';
  static const canceledBookings = 'Đã huỷ';
  static const completedCount = 'Hoàn tất';

  // Xuất file
  static const exporting = 'Đang tạo file Excel…';
  static String exported(String fileName) => 'Đã lưu $fileName';
  static const exportCanceled = 'Đã huỷ lưu file';

  static const noData = 'Không có số liệu trong khoảng này';
  static const detailTitle = 'Chi tiết theo mốc';
  static String rangeLabel(String from, String to, int days) =>
      '$from – $to · $days ngày';
  static String roomsOccupied(int occupied, int total) =>
      '$occupied/$total phòng có khách';
}
