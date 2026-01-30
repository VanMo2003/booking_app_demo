import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/booking/data/models/request/booking_create_request.dart';
import 'package:booking_app_mobile/features/booking/presentation/cubit/booking_cubit.dart';
import 'package:booking_app_mobile/features/room/domain/entity/room.dart';
import 'package:booking_app_mobile/features/room/domain/repositories/room_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

import '../cubit/room_detail/room_detail_cubit.dart';
import '../cubit/room_detail/room_detail_state.dart';

@RoutePage()
class RoomDetailScreen extends StatefulWidget {
  final int roomId;
  final bool isHotelManager;
  final String? statusRoom;

  const RoomDetailScreen(
      {super.key,
      required this.roomId,
      this.statusRoom,
      this.isHotelManager = false});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late final RoomDetailCubit _cubit;
  // Đổi locale sang vi_VN và symbol ₫ cho đồng bộ với màn Hotel
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime? _checkinDate;
  DateTime? _checkoutDate;
  String _paymentMethod = 'CASH';
  bool _isSubmittingBooking = false;
  bool _isBookingSheetOpen = false;

  @override
  void initState() {
    super.initState();
    _cubit = RoomDetailCubit(getIt<RoomRepository>());
    _cubit.fetch(widget.roomId);
  }

  @override
  void dispose() {
    _cubit.close();
    _customerIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'AVAILABLE':
        color = Colors.green;
        label = 'Trống';
        break;
      case 'BOOKED':
        color = Colors.red;
        label = 'Đã được đặt';
        break;
      case 'MAINTENANCE':
        color = Colors.orange;
        label = 'Bảo trì';
        break;
      default:
        color = Colors.grey;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBlue = theme.primaryColor;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _cubit),
        BlocProvider(
          create: (_) => BookingCubit(
            getBookings: getIt(),
            createBooking: getIt(),
            confirmBooking: getIt(),
            cancelBooking: getIt(),
            completeBooking: getIt(),
          ),
        ),
      ],
      child: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (!_isSubmittingBooking) return;
          if (state.status.isFailure) {
            setState(() => _isSubmittingBooking = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Dat phong that bai'),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state.status.isSuccess) {
            setState(() => _isSubmittingBooking = false);
            if (_isBookingSheetOpen && Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Dat phong thanh cong'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        child: BlocBuilder<RoomDetailCubit, RoomDetailState>(
          builder: (context, state) {
            final room = state.room;

            // Logic lấy ảnh đại diện
            final mainImagePath = room?.pathImage?.isNotEmpty == true
                ? room?.pathImage
                : (room?.images?.isNotEmpty == true
                    ? room?.images?.first
                    : null);
            final fallbackImageUrl =
                'https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=1000&auto=format&fit=crop';
            final imageUrl = _resolveImageUrl(mainImagePath, fallbackImageUrl);

            return Scaffold(
              backgroundColor: Colors.white,
              // Sử dụng CustomScrollView để có hiệu ứng SliverAppBar giống màn Hotel
              body: state.status == RoomDetailStatus.loading
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      slivers: [
                        SliverAppBar(
                          expandedHeight: 250,
                          pinned: true,
                          leading: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              backgroundColor: Colors.black26,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back,
                                    color: Colors.white),
                                onPressed: () => context.router.back(),
                              ),
                            ),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background:
                                Image.network(imageUrl, fit: BoxFit.cover),
                          ),
                        ),
                        if (state.status == RoomDetailStatus.failure)
                          SliverFillRemaining(
                            child: Center(
                              child: Text(
                                state.errorMessage ??
                                    "Lỗi tải thông tin phòng.",
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        if (room != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // --- TITLE & TRẠNG THÁI ---
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          "Phòng ${room.roomNumber ?? '-'}"
                                          "${room.roomTypeName != null ? " - ${room.roomTypeName}" : ""}",
                                          style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatusChip(
                                        widget.statusRoom ?? "AVAILABLE",
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // --- GIÁ & SỨC CHỨA ---
                                  Row(
                                    children: [
                                      Text(
                                        currencyFormat.format(room.price ?? 0),
                                        style: TextStyle(
                                            color: primaryBlue,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text(" /đêm",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14)),
                                      const Spacer(),
                                      Icon(Icons.people_outline,
                                          size: 20, color: Colors.grey[700]),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Sức chứa: ${room.capacity ?? 0} người",
                                        style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),

                                  const Divider(height: 40),

                                  // --- MÔ TẢ ---
                                  const Text("Mô tả phòng",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(
                                    room.description?.isNotEmpty == true
                                        ? room.description!
                                        : "Chưa có mô tả chi tiết.",
                                    style: const TextStyle(
                                        color: Colors.black87, height: 1.5),
                                  ),

                                  const SizedBox(height: 24),

                                  // --- TIỆN ÍCH RIÊNG CỦA PHÒNG ---
                                  if (room.amenities != null &&
                                      room.amenities!.isNotEmpty) ...[
                                    const Text("Tiện ích phòng",
                                        style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 12),
                                    _buildAmenitiesList(
                                        room.amenities!, primaryBlue),
                                    const SizedBox(height: 24),
                                  ],

                                  if (widget.isHotelManager) ...[
                                    const Text(
                                      "Thêm ảnh phòng",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Bạn có thể chọn nhiều ảnh.",
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        onPressed: (state.isUploadingImages ||
                                                room.id == null)
                                            ? null
                                            : () => _pickAndUploadImages(
                                                context, room.id!),
                                        icon: const Icon(
                                            Icons.photo_library_outlined),
                                        label: Text(state.isUploadingImages
                                            ? "Đang tải..."
                                            : "Chọn ảnh"),
                                      ),
                                    ),
                                  ],

                                  if (state.isUploadingImages)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 12),
                                      child: LinearProgressIndicator(),
                                    ),
                                  if (state.uploadErrorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        state.uploadErrorMessage!,
                                        style:
                                            const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  const SizedBox(height: 24),

                                  // --- HÌNH ẢNH KHÁC ---
                                  if (room.images?.isNotEmpty == true) ...[
                                    const Text(
                                      "Hình ảnh chi tiết",
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      height: 120,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: room.images!.length,
                                        separatorBuilder: (_, __) =>
                                            const SizedBox(width: 12),
                                        itemBuilder: (context, index) {
                                          final path = room.images![index];
                                          final url =
                                              _resolveImageUrl(path, imageUrl);
                                          return ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Image.network(
                                              url,
                                              width: 160,
                                              height: 120,
                                              fit: BoxFit.cover,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],

                                  // --- NÚT ĐẶT PHÒNG ---
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed:
                                          widget.statusRoom == "AVAILABLE"
                                              ? () {
                                                  if (room == null) return;
                                                  _openBookingSheet(
                                                      room, primaryBlue);
                                                }
                                              : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            widget.statusRoom == "AVAILABLE"
                                                ? primaryBlue
                                                : Colors.grey,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        elevation: 0,
                                      ),
                                      child: Text("Đặt phòng ngay",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  String _formatDateDisplay(DateTime? date) {
    if (date == null) return 'Chon ngay';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Future<void> _pickDate(
      {required bool isCheckin, VoidCallback? onChanged}) async {
    final now = DateTime.now();
    final initialDate = isCheckin
        ? (_checkinDate ?? now)
        : (_checkoutDate ?? (_checkinDate ?? now).add(const Duration(days: 1)));
    final firstDate = isCheckin ? now : (_checkinDate ?? now);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: now.add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isCheckin) {
        _checkinDate = picked;
        if (_checkoutDate != null && _checkoutDate!.isBefore(picked)) {
          _checkoutDate = picked.add(const Duration(days: 1));
        }
      } else {
        _checkoutDate = picked;
      }
    });
    if (onChanged != null) onChanged();
  }

  int _calculateNights() {
    if (_checkinDate == null || _checkoutDate == null) return 1;
    final nights = _checkoutDate!.difference(_checkinDate!).inDays;
    return nights <= 0 ? 1 : nights;
  }

  int _calculateTotalAmount(int? price) {
    final nights = _calculateNights();
    final roomPrice = price ?? 0;
    return roomPrice * nights;
  }

  Future<void> _submitBooking(Room room) async {
    if (_isSubmittingBooking) return;
    final customerId = int.tryParse(_customerIdController.text.trim());
    if (customerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap customerId')),
      );
      return;
    }
    if (_checkinDate == null || _checkoutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long chon ngay nhan va tra phong')),
      );
      return;
    }
    if (room.id == null || room.hotelId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Khong xac dinh duoc phong/khach san')),
      );
      return;
    }

    final dto = BookingCreateRequest(
      checkinDate: DateFormat('yyyy-MM-dd').format(_checkinDate!),
      checkoutDate: DateFormat('yyyy-MM-dd').format(_checkoutDate!),
      paymentMethod: _paymentMethod,
      hotelId: room.hotelId,
      customerId: customerId,
      rooms: [room.id!],
      services: <int>[],
      totalAmount: _calculateTotalAmount(room.price),
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    setState(() => _isSubmittingBooking = true);
    context.read<BookingCubit>().add(dto);
  }

  Future<void> _openBookingSheet(Room room, Color primaryBlue) async {
    final now = DateTime.now();
    _checkinDate ??= DateTime(now.year, now.month, now.day);
    _checkoutDate ??= _checkinDate!.add(const Duration(days: 1));

    setState(() => _isBookingSheetOpen = true);
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return BlocBuilder<BookingCubit, BookingState>(
              builder: (context, bookingState) {
                final totalAmount = _calculateTotalAmount(room.price);
                final nights = _calculateNights();
                final isLoading = bookingState.status.isLoading;
                return Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dat phong',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customerIdController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Customer ID',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDate(
                                  isCheckin: true,
                                  onChanged: () => setModalState(() {})),
                              icon: const Icon(Icons.calendar_today, size: 16),
                              label: Text(_formatDateDisplay(_checkinDate)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _pickDate(
                                  isCheckin: false,
                                  onChanged: () => setModalState(() {})),
                              icon: const Icon(Icons.event_outlined, size: 16),
                              label: Text(_formatDateDisplay(_checkoutDate)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('So dem: $nights'),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _paymentMethod,
                        decoration: const InputDecoration(
                          labelText: 'Phuong thuc thanh toan',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'CASH', child: Text('Tien mat')),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            _paymentMethod = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _noteController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Ghi chu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tong tien',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(
                            currencyFormat.format(totalAmount),
                            style: TextStyle(
                              color: primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed:
                              isLoading ? null : () => _submitBooking(room),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Text('Dat phong ngay'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
    setState(() => _isBookingSheetOpen = false);
  }

  // Helper widget để hiển thị amenities giống màn HotelDetail
  String _resolveImageUrl(String? path, String fallback) {
    final value = path?.trim() ?? "";
    if (value.isEmpty) return fallback;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return "${AppConfig().baseURL}$value";
  }

  Future<void> _pickAndUploadImages(BuildContext context, int roomId) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final paths =
        result.files.map((file) => file.path).whereType<String>().toList();
    if (paths.isEmpty) return;

    final cubit = context.read<RoomDetailCubit>();
    final success = await cubit.uploadImages(roomId: roomId, filePaths: paths);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Images uploaded"),
      ));
    }
  }

  Widget _buildAmenitiesList(List<dynamic> amenities, Color color) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: amenities.map((a) {
        // Xử lý an toàn nếu a là String hoặc Object có thuộc tính name
        final name = (a is String) ? a : (a.name ?? "");
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 14, color: color),
              const SizedBox(width: 6),
              Text(name,
                  style: TextStyle(
                      fontSize: 13, color: color, fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
