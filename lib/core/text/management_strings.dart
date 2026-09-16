/// Chuỗi cho chủ khách sạn (chuỗi, cơ sở, quản lý) và quản trị hệ thống.
abstract final class ManagementStrings {
  // Chủ khách sạn — điều hướng
  static const tabOverview = 'Tổng quan';
  static const tabBranches = 'Cơ sở';
  static const tabReports = 'Báo cáo';
  static const tabMore = 'Thêm';

  // Gửi hồ sơ chuỗi (chủ khách sạn chưa có chuỗi, ví dụ sau khi xoá chuỗi cũ)
  static const createChainTitle = 'Hồ sơ khách sạn';
  static const createChainHeadline = 'Hoàn tất hồ sơ khách sạn';
  static const createChainSubtitle =
      'Tài khoản chưa có khách sạn. Gửi thông tin để quản trị viên xét duyệt trước khi bạn mở cơ sở.';
  static const chainName = 'Tên chuỗi';
  static const chainDescription = 'Giới thiệu';
  static const createChainAction = 'Gửi hồ sơ xét duyệt';
  static const chainCreated = 'Đã gửi hồ sơ, đang chờ xét duyệt';

  // Tổng quan chuỗi
  static String branchesCount(int n) => '$n cơ sở';
  static String activeBranches(int active, int total) =>
      '$active/$total đang nhận khách';
  static const chainRevenue5Months = 'Doanh thu toàn chuỗi 5 tháng';
  static const chainOccupancy = 'Lấp đầy toàn chuỗi tháng này';
  static const branchesSection = 'Các cơ sở';
  static const openWorkspace = 'Vào quản lý';
  static const revenueThisMonth = 'Doanh thu tháng này';

  // Danh sách cơ sở
  static const branchesTitle = 'Cơ sở';
  static const openBranch = 'Mở cơ sở mới';
  static const branchesEmpty = 'Chuỗi chưa có cơ sở';
  static const branchesEmptyHint =
      'Mở cơ sở đầu tiên và giao cho một tài khoản quản lý.';
  static const activate = 'Mở nhận khách';
  static const deactivate = 'Tạm đóng';
  static const activated = 'Cơ sở đã mở nhận khách';
  static const deactivated = 'Cơ sở đã tạm đóng';
  static const deleteBranchMessage =
      'Xoá cơ sở cùng toàn bộ phòng, dịch vụ và đơn liên quan. Không thể hoàn tác.';
  static const manager = 'Quản lý';

  // Mở cơ sở
  static const branchFormTitle = 'Mở cơ sở mới';
  static const branchManager = 'Quản lý cơ sở';
  static const newManager = 'Tạo tài khoản quản lý mới';
  static const existingManager = 'Chọn quản lý có sẵn';
  static const managerUsername = 'Tên đăng nhập quản lý';
  static const managerPassword = 'Mật khẩu quản lý';
  static const branchPhotos = 'Ảnh cơ sở';
  static const pickPhotos = 'Chọn ảnh';
  static const branchCreated = 'Đã mở cơ sở mới';
  static const managerRequired = 'Chọn hoặc tạo tài khoản quản lý';

  // Tài khoản quản lý
  static const managersTitle = 'Tài khoản quản lý';
  static const managersGap =
      'Máy chủ chưa có API liệt kê quản lý — danh sách gom từ các cơ sở trong chuỗi và tài khoản vừa tạo.';
  static const createManager = 'Tạo tài khoản quản lý';
  static const managerCreated = 'Đã tạo tài khoản quản lý';
  static String managedBranches(int n) => 'Phụ trách $n cơ sở';
  static const managersEmpty = 'Chưa có tài khoản quản lý';

  // Thông tin chuỗi
  static const chainInfoTitle = 'Thông tin chuỗi';
  static const chainSaved = 'Đã lưu thông tin chuỗi';
  static const deleteChain = 'Xoá chuỗi khách sạn';
  static const deleteChainMessage =
      'Xoá chuỗi và mọi cơ sở bên trong. Muốn kinh doanh lại, bạn cần gửi hồ sơ mới để được duyệt.';
  static const dangerZone = 'Vùng nguy hiểm';

  // Quản trị — điều hướng
  static const tabAdminOverview = 'Tổng quan';
  static const tabAccounts = 'Tài khoản';
  static const tabCatalog = 'Danh mục';
  static const tabSystem = 'Hệ thống';

  // Quản trị — tổng quan
  static const adminTitle = 'Quản trị hệ thống';
  static const countAccounts = 'Tài khoản';
  static const countChains = 'Chuỗi khách sạn';
  static const countBranches = 'Cơ sở';
  static const countCustomers = 'Khách hàng';
  static const countEmployees = 'Nhân viên';
  static const recentAccounts = 'Tài khoản mới tạo';

  // Quản trị — tài khoản
  static const accountsTitle = 'Tài khoản';
  static const editAccount = 'Khoá / mở tài khoản';
  static const accountActive = 'Đang hoạt động';
  static const accountLocked = 'Đã khoá';
  static const accountStatusNote =
      'Lưu ý: máy chủ chưa chặn đăng nhập với tài khoản bị khoá.';
  static const accountsReviewNote =
      'Quản trị viên chỉ xem và khoá/mở tài khoản. Chủ khách sạn tự đăng ký và chờ duyệt ở tab Xét duyệt; quản lý và nhân viên do chủ khách sạn tạo.';
  static const accountSaved = 'Đã lưu tài khoản';
  static const accountsEmpty = 'Chưa có tài khoản';

  // Quản trị — danh mục
  static const catalogTitle = 'Danh mục';
  static const roomTypes = 'Loại phòng';
  static const positions = 'Chức vụ';
  static const addRoomType = 'Thêm loại phòng';
  static const addPosition = 'Thêm chức vụ';
  static const editRoomType = 'Sửa loại phòng';
  static const editPosition = 'Sửa chức vụ';
  static const name = 'Tên';
  static const description = 'Mô tả';
  static const catalogEmpty = 'Danh mục trống';

  // Quản trị — dữ liệu hệ thống
  static const systemTitle = 'Dữ liệu hệ thống';
  static const chains = 'Chuỗi';
  static const branches = 'Cơ sở';
  static const customers = 'Khách hàng';
  static const employees = 'Nhân viên';

  // Bổ sung
  static const accountMissing =
      'Không xác định được tài khoản chủ khách sạn. Đăng nhập lại rồi thử lại.';
  static const chainGroup = 'Chuỗi khách sạn';
  static const noManagersYet =
      'Chưa có tài khoản quản lý nào — chọn "Tạo tài khoản quản lý mới".';
  static const searchUsername = 'Tìm theo tên đăng nhập';
  static const cannotEditSelf =
      'Đây là tài khoản đang đăng nhập — không khoá được tại đây.';
  static String createdOn(String date) => 'Tạo ngày $date';
}
