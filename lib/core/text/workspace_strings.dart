/// Chuỗi cho không gian làm việc tại cơ sở: nhân viên và quản lý.
abstract final class WorkspaceStrings {
  // Thanh điều hướng
  static const tabDashboard = 'Tổng quan';
  static const tabDesk = 'Quầy';
  static const tabRooms = 'Phòng';
  static const tabCustomers = 'Khách';
  static const tabReports = 'Báo cáo';
  static const tabMore = 'Thêm';

  // Menu "Thêm"
  static const groupOperations = 'Vận hành';
  static const groupPeople = 'Nhân sự';
  static const groupBranch = 'Cơ sở';
  static const groupAccount = 'Tài khoản';
  static const menuWalkIn = 'Đặt phòng tại quầy';
  static const menuAmenities = 'Tiện ích';
  static const menuServices = 'Dịch vụ thêm';
  static const menuCustomers = 'Khách hàng';
  static const menuEmployees = 'Nhân viên';
  static const menuPayroll = 'Bảng lương';
  static const menuBranchInfo = 'Thông tin cơ sở';
  static const menuSwitchBranch = 'Đổi cơ sở';
  static const menuBackToChain = 'Về tổng quan chuỗi';
  static const menuBackToAdmin = 'Về trang quản trị';

  // Chọn cơ sở
  static const pickerTitle = 'Chọn cơ sở';
  static const pickerSubtitle = 'Các cơ sở bạn đang được giao quản lý.';
  static const noBranchTitle = 'Bạn chưa được giao cơ sở nào';
  static const noBranchMessage =
      'Nhờ chủ khách sạn giao cơ sở cho tài khoản này rồi làm mới danh sách.';
  static const branchActive = 'Đang nhận khách';
  static const branchInactive = 'Tạm đóng';

  // Tổng quan
  static const kpiRevenue = 'Doanh thu tháng này';
  static const kpiCompleted = 'Đơn hoàn tất';
  static const kpiOccupancy = 'Lấp đầy tháng này';
  static const kpiCancellation = 'Tỷ lệ huỷ';
  static const revenue5Months = 'Doanh thu 5 tháng gần nhất';
  static const today = 'Hôm nay';
  static const arrivals = 'Khách đến';
  static const departures = 'Trả phòng';
  static const pending = 'Chờ xác nhận';
  static const upcomingArrivals = 'Khách sắp đến';
  static const noArrivals = 'Không có khách đến hôm nay';
  static const quickActions = 'Thao tác nhanh';

  // Phòng
  static const roomsTitle = 'Phòng';
  static const addRoom = 'Thêm phòng';
  static const editRoom = 'Sửa phòng';
  static const roomNumber = 'Số phòng';
  static const roomType = 'Loại phòng';
  static const pricePerNight = 'Giá mỗi đêm (₫)';
  static const capacity = 'Sức chứa (khách)';
  static const description = 'Mô tả';
  static const status = 'Trạng thái';
  static const roomsEmpty = 'Cơ sở chưa có phòng';
  static const roomsEmptyHint = 'Thêm phòng để khách bắt đầu đặt được.';
  static const roomSaved = 'Đã lưu phòng';
  static const roomDeleted = 'Đã xoá phòng';
  static const roomImages = 'Ảnh phòng';
  static const uploadImages = 'Tải ảnh lên';
  static const imagesUploaded = 'Đã tải ảnh lên';
  static const setMaintenance = 'Chuyển sang bảo trì';
  static const setAvailable = 'Mở lại phòng';
  static const noRoomTypes =
      'Chưa có loại phòng. Quản trị viên cần thêm trong Danh mục.';

  // Tiện ích
  static const amenitiesTitle = 'Tiện ích';
  static const commonAmenities = 'Tiện ích chung';
  static const roomAmenities = 'Theo phòng';
  static const addAmenity = 'Thêm tiện ích';
  static const editAmenity = 'Sửa tiện ích';
  static const amenityName = 'Tên tiện ích';
  static const amenityCommon = 'Tiện ích chung của cơ sở';
  static const amenityCommonHint = 'Tắt để gắn tiện ích cho một phòng';
  static const amenityRoom = 'Gắn cho phòng';
  static const linkToRoom = 'Gắn thêm vào phòng khác';
  static const linkedToRoom = 'Đã gắn tiện ích vào phòng';
  static const amenitiesEmpty = 'Chưa có tiện ích';
  static const amenitySaved = 'Đã lưu tiện ích';

  // Dịch vụ
  static const servicesTitle = 'Dịch vụ thêm';
  static const addService = 'Thêm dịch vụ';
  static const editService = 'Sửa dịch vụ';
  static const serviceName = 'Tên dịch vụ';
  static const unitPrice = 'Đơn giá (₫)';
  static const servicesEmpty = 'Chưa có dịch vụ';
  static const servicePriceNote = 'Đổi giá không ảnh hưởng các đơn đã tạo.';
  static const serviceSaved = 'Đã lưu dịch vụ';

  // Khách hàng
  static const customersTitle = 'Khách hàng';
  static const customersSearchHint = 'Tìm theo tên hoặc số điện thoại';
  static const customersEmpty = 'Chưa có khách nào đặt tại cơ sở';
  static const walkInBadge = 'Vãng lai';
  static const accountBadge = 'Có tài khoản';
  static const bookingHistory = 'Lịch sử đơn tại cơ sở';
  static const editCustomer = 'Sửa thông tin khách';
  static const customerSaved = 'Đã lưu thông tin khách';

  // Nhân viên
  static const employeesTitle = 'Nhân viên';
  static const addEmployee = 'Thêm nhân viên';
  static const editEmployee = 'Sửa nhân viên';
  static const loginAccount = 'Tài khoản đăng nhập';
  static const personalInfo = 'Thông tin cá nhân';
  static const workInfo = 'Công việc';
  static const position = 'Chức vụ';
  static const salary = 'Lương cơ bản (₫)';
  static const dateOfBirth = 'Ngày sinh';
  static const employeesEmpty = 'Cơ sở chưa có nhân viên';
  static const employeeSaved = 'Đã lưu nhân viên';
  static const noPositions =
      'Chưa có chức vụ. Quản trị viên cần thêm trong Danh mục.';

  // Bảng lương
  static const payrollTitle = 'Bảng lương';
  static const payrollIntro = 'Ghi nhận lương tháng cho nhân viên cơ sở.';
  static const payrollGap =
      'Máy chủ chưa có API xem lại bảng lương. Phiếu tạo trong phiên này hiện bên dưới để cập nhật trạng thái.';
  static const employee = 'Nhân viên';
  static const month = 'Tháng';
  static const totalSalary = 'Tổng lương (₫)';
  static const payrollStatus = 'Trạng thái';
  static const createPayroll = 'Tạo phiếu lương';
  static const payrollCreated = 'Đã tạo phiếu lương';
  static const sessionPayrolls = 'Phiếu đã tạo';
  static const updatePayroll = 'Cập nhật phiếu';

  // Thông tin cơ sở
  static const branchInfoTitle = 'Thông tin cơ sở';
  static const branchName = 'Tên cơ sở';
  static const address = 'Địa chỉ';
  static const phone = 'Số điện thoại';
  static const category = 'Loại hình';
  static const acceptingGuests = 'Đang nhận khách';
  static const acceptingGuestsHint =
      'Tắt khi tạm đóng — khách sẽ thấy cơ sở ở trạng thái Tạm đóng.';
  static const gallery = 'Thư viện ảnh';
  static const cover = 'Ảnh bìa';
  static const setCover = 'Đặt làm ảnh bìa';
  static const branchSaved = 'Đã lưu thông tin cơ sở';
  static const imagesHint = 'Chạm vào một ảnh để đặt làm ảnh bìa.';
  static const coverUpdated = 'Đã đổi ảnh bìa';
  static const setCoverMessage = 'Dùng ảnh này làm ảnh bìa của cơ sở?';

  // Phòng (bổ sung)
  static const roomsSearchHint = 'Tìm số phòng hoặc loại phòng';
  static const roomInfo = 'Thông tin phòng';
  static const priceLabel = 'Giá mỗi đêm';
  static const capacityLabel = 'Sức chứa';
  static const roomImagesHint = 'Ảnh được tải lên sau khi lưu phòng.';
  static const roomStatusUpdated = 'Đã cập nhật trạng thái phòng';
  static const roomNoAmenities = 'Phòng chưa có tiện ích riêng';
  static const manageAmenities = 'Quản lý tiện ích';

  // Tiện ích (bổ sung)
  static const amenityDescription = 'Mô tả ngắn';
  static const amenityRoomRequired = 'Chọn phòng để gắn tiện ích';
  static const amenitiesRoomEmpty = 'Chưa có tiện ích gắn theo phòng';
  static const amenityDeleted = 'Đã xoá tiện ích';
  static String amenityInRoom(String room) => 'Phòng $room';

  // Dịch vụ (bổ sung)
  static const serviceDeleted = 'Đã xoá dịch vụ';

  // Khách hàng (bổ sung)
  static const customerDetailTitle = 'Hồ sơ khách';
  static const customerBookingsEmpty = 'Khách chưa có đơn tại cơ sở';

  // Nhân viên (bổ sung)
  static const employeeDeleted = 'Đã xoá nhân viên';
  static const accountNote = 'Nhân viên đăng nhập bằng tài khoản này để vào quầy.';

  // Bảng lương (bổ sung)
  static const payrollEmpty = 'Chưa có phiếu nào được tạo trong phiên này';
  static const payrollUpdated = 'Đã cập nhật phiếu lương';
  static const noEmployees = 'Cơ sở chưa có nhân viên để tạo phiếu lương';

  // Tổng quan (bổ sung)
  static String previousMonth(String amount) => 'Tháng trước: $amount';
  static String occupiedOf(int occupied, int total) => '$occupied/$total đêm phòng';
  static String canceledOf(int canceled, int total) => '$canceled/$total đơn';
  static const noReportData = 'Chưa có số liệu';
  static const openDesk = 'Mở quầy lễ tân';
  static const customerSpend = 'Đã chi tiêu';
  static const salaryLabel = 'Lương cơ bản';
  static const noUpcoming = 'Chưa có khách sắp đến';
  static String employeesCount(int n) => '$n nhân viên';
}
