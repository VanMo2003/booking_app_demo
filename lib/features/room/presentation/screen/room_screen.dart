import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/room/domain/entity/room.dart';
import 'package:booking_app_mobile/features/room/presentation/cubit/room_cubit.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/get_rooms.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/create_room.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/update_room.dart';
import 'package:booking_app_mobile/features/room/domain/usecases/delete_room.dart';
import 'package:booking_app_mobile/features/room_type/domain/entity/room_type.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/get_room_types.dart';

@RoutePage()
class RoomScreen extends StatelessWidget {
  const RoomScreen({Key? key}) : super(key: key);

  Future<void> _showEditDialog(BuildContext context, Room? item,
      {required int hotelId}) async {
    final roomNumberCtrl = TextEditingController(text: item?.roomNumber);
    final priceCtrl = TextEditingController(text: item?.price?.toString());
    final descCtrl = TextEditingController(text: item?.description);
    final capacityCtrl =
        TextEditingController(text: item?.capacity?.toString());
    String status = item?.status ?? 'AVAILABLE';

    // fetch room types
    List<RoomType> roomTypes = [];
    int? selectedRoomTypeId = item?.roomTypeId;
    try {
      roomTypes = await getIt<GetRoomTypes>().call();
      if (roomTypes.isNotEmpty && selectedRoomTypeId == null)
        selectedRoomTypeId = roomTypes.first.id;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tải được danh sách loại phòng')));
      return;
    }

    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Thêm phòng' : 'Chỉnh sửa phòng'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                    controller: roomNumberCtrl,
                    decoration: const InputDecoration(labelText: 'Số phòng'),
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                SizedBox(
                  height: 12,
                ),
                TextFormField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Giá'),
                    keyboardType: TextInputType.number,
                    validator: (v) => v?.isEmpty ?? true ? 'Required' : null),
                SizedBox(
                  height: 12,
                ),
                TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Mô tả')),
                SizedBox(
                  height: 12,
                ),
                TextFormField(
                    controller: capacityCtrl,
                    decoration: const InputDecoration(labelText: 'Sức chứa'),
                    keyboardType: TextInputType.number),
                SizedBox(
                  height: 12,
                ),
                DropdownButtonFormField<int>(
                  value: selectedRoomTypeId,
                  decoration: const InputDecoration(labelText: 'Loại phòng'),
                  items: roomTypes
                      .map((rt) => DropdownMenuItem<int>(
                          value: rt.id, child: Text(rt.name ?? '')))
                      .toList(),
                  onChanged: (v) => selectedRoomTypeId = v,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                // DropdownButtonFormField<String>(
                //     value: status,
                //     items: const [
                //       DropdownMenuItem(
                //           value: 'AVAILABLE', child: Text('AVAILABLE')),
                //       DropdownMenuItem(
                //           value: 'OCCUPIED', child: Text('OCCUPIED')),
                //       DropdownMenuItem(
                //           value: 'MAINTENANCE', child: Text('MAINTENANCE'))
                //     ],
                //     onChanged: (v) => status = v ?? status),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final cubit = context.read<RoomCubit>();
              final r = Room(
                id: item?.id,
                roomNumber: roomNumberCtrl.text,
                price: int.tryParse(priceCtrl.text) ?? 0,
                description: descCtrl.text,
                capacity: int.tryParse(capacityCtrl.text) ?? 0,
                hotelId: item?.hotelId ?? hotelId,
                roomTypeId: selectedRoomTypeId ?? item?.roomTypeId,
                status: status,
              );

              try {
                if (item == null) {
                  await cubit.add(r);
                } else {
                  await cubit.edit(r);
                }
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(item == null
                        ? 'Thêm phòng thành công'
                        : 'Cập nhật phòng')));
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RoomCubit(
        getRooms: getIt<GetRooms>(),
        createRoom: getIt<CreateRoom>(),
        updateRoom: getIt<UpdateRoom>(),
        deleteRoom: getIt<DeleteRoom>(),
      )..fetch(hotelId: 1, page: 0, size: 10),
      child: Scaffold(
        appBar: AppBar(title: const Text('Room')),
        body: BlocConsumer<RoomCubit, RoomState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage ?? 'Có lỗi xảy ra')));
            }
            if (state.status.isSuccess) {
              // optional success handling
            }
          },
          builder: (context, state) {
            if (state.status.isLoading || state.status.isInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.status.isFailure)
              return Center(child: Text(state.errorMessage ?? 'Error'));
            if (state.status.isSuccess) {
              final items = state.data?.content ?? [];
              if (items.isEmpty)
                return const Center(child: Text('Không có phòng nào'));
              return Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _showEditDialog(context, null, hotelId: 1),
                    child: const Icon(Icons.add),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (ctx, i) {
                        final it = items[i];
                        return ListTile(
                          title: Text(it.roomNumber ?? '-'),
                          subtitle: Text(
                              '${it.hotelName ?? ''} • ${it.roomTypeName ?? ''} • ${it.price ?? 0}'),
                          trailing:
                              Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, it,
                                    hotelId: it.hotelId ?? 1)),
                            IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  final cubit = context.read<RoomCubit>();
                                  try {
                                    await cubit.remove(it.id!);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Xóa thành công')));
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')));
                                  }
                                }),
                          ]),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
