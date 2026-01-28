import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app_mobile/core/api/app_config.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/core/navigation/app_routes.dart';
import 'package:booking_app_mobile/core/widgets/app_scaffold.dart';
import 'package:booking_app_mobile/features/room/domain/entity/room.dart';
import 'package:booking_app_mobile/features/room/presentation/cubit/room_cubit.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/get_rooms.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/create_room.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/update_room.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/delete_room.dart';
import 'package:booking_app_mobile/features/room_type/domain/entity/room_type.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/get_room_types.dart';
import 'package:intl/intl.dart';

@RoutePage()
class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.hotelId});

  final int hotelId;

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final DateFormat _displayDateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');
  DateTime? _checkinDate;
  DateTime? _checkoutDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _checkinDate = DateTime(now.year, now.month, now.day);
    _checkoutDate = _checkinDate!.add(const Duration(days: 1));
  }

  String _formatCurrency(num? amount) {
    if (amount == null) return '0 đ';
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(amount);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    return _displayDateFormat.format(date);
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

  String _resolveRoomImageUrl(Room room) {
    const fallbackUrl =
        'https://images.unsplash.com/photo-1505691938895-1758d7feb511?q=80&w=1000&auto=format&fit=crop';
    final path = (room.pathImage?.isNotEmpty == true)
        ? room.pathImage!
        : (room.images?.isNotEmpty == true ? room.images!.first : "");
    if (path.isEmpty) return fallbackUrl;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    return "${AppConfig().baseURL}$path";
  }

  Future<void> _showEditDialog(
    BuildContext context,
    Room? item, {
    required int hotelId,
  }) async {
    final roomNumberCtrl = TextEditingController(text: item?.roomNumber);
    final priceCtrl = TextEditingController(text: item?.price?.toString());
    final descCtrl = TextEditingController(text: item?.description);
    final capacityCtrl =
        TextEditingController(text: item?.capacity?.toString());
    String status = item?.status ?? 'AVAILABLE';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    List<RoomType> roomTypes = [];
    try {
      roomTypes = await getIt<GetRoomTypes>().call();
      if (context.mounted) Navigator.pop(context); // Hide loading
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tải được danh sách loại phòng')),
        );
      }
      return;
    }

    int? selectedRoomTypeId = item?.roomTypeId;
    if (roomTypes.isNotEmpty && selectedRoomTypeId == null) {
      selectedRoomTypeId = roomTypes.first.id;
    }

    final cubit = context.read<RoomCubit>();

    if (!context.mounted) return;

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          top: 20,
          left: 20,
          right: 20,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item == null ? 'Thêm phòng mới' : 'Cập nhật phòng',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: roomNumberCtrl,
                  decoration: InputDecoration(
                    labelText: 'Số phòng (VD: 101)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    prefixIcon: const Icon(Icons.meeting_room),
                  ),
                  validator: (v) =>
                      v?.isEmpty ?? true ? 'Vui lòng nhập số phòng' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: priceCtrl,
                        decoration: InputDecoration(
                          labelText: 'Giá theo đêm',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixText: 'VNĐ',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            v?.isEmpty ?? true ? 'Nhập giá' : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: capacityCtrl,
                        decoration: InputDecoration(
                          labelText: 'Sức chứa',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: selectedRoomTypeId,
                  decoration: InputDecoration(
                    labelText: 'Loại phòng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: roomTypes
                      .map(
                        (rt) => DropdownMenuItem<int>(
                          value: rt.id,
                          child: Text(rt.name ?? 'Unknown'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => selectedRoomTypeId = v,
                  validator: (v) => v == null ? 'Chọn loại phòng' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: status,
                  decoration: InputDecoration(
                    labelText: 'Trạng thái',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'AVAILABLE', child: Text('Trống')),
                    DropdownMenuItem(value: 'OCCUPIED', child: Text('Đã thuê')),
                    DropdownMenuItem(
                      value: 'MAINTENANCE',
                      child: Text('Bảo trì'),
                    ),
                  ],
                  onChanged: (v) => status = v!,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Mô tả thêm',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;

                      final r = Room(
                        id: item?.id,
                        roomNumber: roomNumberCtrl.text,
                        price: int.tryParse(priceCtrl.text) ?? 0,
                        description: descCtrl.text,
                        capacity: int.tryParse(capacityCtrl.text) ?? 1,
                        hotelId: widget.hotelId,
                        roomTypeId: selectedRoomTypeId,
                        status: status,
                      );

                      try {
                        if (item == null) {
                          await cubit.add(r);
                        } else {
                          await cubit.edit(r);
                        }

                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                item == null
                                    ? 'Thêm phòng thành công'
                                    : 'Cập nhật thành công',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Đã có lỗi xảy ra')),
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Lưu thông tin',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate({
    required bool isCheckin,
  }) async {
    final initialDate = isCheckin
        ? (_checkinDate ?? DateTime.now())
        : (_checkoutDate ??
            _checkinDate?.add(const Duration(days: 1)) ??
            DateTime.now().add(const Duration(days: 1)));
    final firstDate =
        isCheckin ? DateTime.now() : (_checkinDate ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
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
  }

  void _fetchRooms(BuildContext context) {
    final checkin = _apiDateFormat.format(_checkinDate!);
    final checkout = _apiDateFormat.format(_checkoutDate!);
    context.read<RoomCubit>().fetch(
          hotelId: widget.hotelId,
          checkinDate: checkin,
          checkoutDate: checkout,
        );
  }

  void _applyFilter(BuildContext context) {
    if (_checkoutDate!.isBefore(_checkinDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ngày đi phải sau ngày đến'),
        ),
      );
      return;
    }
    _fetchRooms(context);
  }

  void _clearFilter(BuildContext context) {
    final now = DateTime.now();
    setState(() {
      _checkinDate = DateTime(now.year, now.month, now.day);
      _checkoutDate = _checkinDate!.add(const Duration(days: 1));
    });
    _fetchRooms(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomCubit(
        getRooms: getIt<GetAvailableRooms>(),
        createRoom: getIt<CreateRoom>(),
        updateRoom: getIt<UpdateRoom>(),
        deleteRoom: getIt<DeleteRoom>(),
      )..fetch(
          hotelId: widget.hotelId,
          checkinDate: _apiDateFormat.format(_checkinDate!),
          checkoutDate: _apiDateFormat.format(_checkoutDate!),
        ),
      child: BlocConsumer<RoomCubit, RoomState>(
        listener: (context, state) {
          if (state.status.isFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Có lỗi xảy ra'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return AppScaffold(
            title: 'Quản lý phòng',
            body: _buildContent(context, state: state),
            floatingActionButton: FloatingActionButton(
              onPressed: () =>
                  _showEditDialog(context, null, hotelId: widget.hotelId),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, {required RoomState state}) {
    if (state.status.isLoading || state.status.isInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = state.data?.content ?? [];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isCheckin: true),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày đến',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                        ),
                        child: Text(_formatDate(_checkinDate)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(isCheckin: false),
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Ngày đi',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.event_outlined),
                        ),
                        child: Text(_formatDate(_checkoutDate)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => _applyFilter(context),
                      child: const Text('Lọc'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: (_checkinDate != null || _checkoutDate != null)
                          ? () => _clearFilter(context)
                          : null,
                      child: const Text('Xóa lọc'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async => _fetchRooms(context),
            child: items.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      const SizedBox(height: 40),
                      Icon(Icons.meeting_room_outlined,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text(
                          'Chưa có phòng nào',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final it = items[i];
                      final imageUrl = _resolveRoomImageUrl(it);

                      return Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            if (it.id != null) {
                              context.router.push(RoomDetailRoute(
                                  roomId: it.id!, isHotelManager: true));
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: 72,
                                    height: 72,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              'Phòng ${it.roomNumber}',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          _buildStatusChip(
                                              it.status ?? 'AVAILABLE'),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        it.roomTypeName ?? 'Loại phòng',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatCurrency(it.price),
                                        style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit_outlined,
                                          color: Colors.blue),
                                      onPressed: () => _showEditDialog(
                                          context, it,
                                          hotelId: widget.hotelId),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.red),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('X?c nh?n x?a'),
                                            content: Text(
                                                'Xóa phòng ${it.roomNumber}?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('H?y'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('X?a'),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true && it.id != null) {
                                          if (context.mounted) {
                                            context
                                                .read<RoomCubit>()
                                                .remove(it.id!);
                                          }
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
