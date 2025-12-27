import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/features/room_type/domain/entity/room_type.dart';
import 'package:booking_app_mobile/features/room_type/presentation/cubit/room_type_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/get_room_types.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/create_room_type.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/update_room_type.dart';
import 'package:booking_app_mobile/features/room_type/domain/usecases/delete_room_type.dart';

@RoutePage()
class RoomTypeScreen extends StatelessWidget {
  const RoomTypeScreen({Key? key}) : super(key: key);

  Future<void> _showEditDialog(BuildContext context, RoomType? item) async {
    final nameController = TextEditingController(text: item?.name ?? '');
    final descController = TextEditingController(text: item?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<RoomTypeCubit>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(item == null ? 'Thêm loại phòng mới' : 'Chỉnh sửa loại phòng'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên loại phòng'),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Vui lòng nhập thông tin' : null,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Chi tiết'),
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final rt = RoomType(
                id: item?.id,
                name: nameController.text.trim(),
                description: descController.text.trim(),
              );

              try {
                if (item == null) {
                  await cubit.add(rt);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm loại phòng mới')));
                } else {
                  await cubit.edit(rt);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật loại phòng')));
                }
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loại phòng')),
      body: BlocProvider(
        create: (context) => RoomTypeCubit(
          getRoomTypes: getIt<GetRoomTypes>(),
          createRoomType: getIt<CreateRoomType>(),
          updateRoomType: getIt<UpdateRoomType>(),
          deleteRoomType: getIt<DeleteRoomType>(),
        )..fetch(),
        child: BlocConsumer<RoomTypeCubit, RoomTypeState>(
          listener: (context, state) {
            if (state.status.isFailure) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(state.errorMessage ?? 'Có lỗi xảy ra')));
            }
          },
          builder: (context, state) {
            if (state.status.isLoading || state.status.isInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.status.isFailure) {
              return Center(
                  child: Text('Error: ${state.errorMessage ?? 'Unknown'}'));
            }

            if (state.status.isSuccess) {
              final items = state.items ?? [];
              if (items.isEmpty) {
                return const Center(child: Text('Không có loại phòng nào'));
              }

              return Column(
                children: [
                  FloatingActionButton(
                    onPressed: () => _showEditDialog(context, null),
                    child: const Icon(Icons.add),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final r = items[index];
                        return ListTile(
                          title: Text(r.name ?? '-'),
                          subtitle: Text(r.description ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, r),
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Xác nhận xóa'),
                                      content: const Text(
                                          'Bạn có chắc chắn muốn xóa loại phòng này không?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Hủy')),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Xác nhận')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && r.id != null) {
                                    await context
                                        .read<RoomTypeCubit>()
                                        .remove(r.id!);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Xóa thành công')));
                                  }
                                },
                              ),
                            ],
                          ),
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
