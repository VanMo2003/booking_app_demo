import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/features/position/domain/entity/position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/get_positions.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/create_position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/update_position.dart';
import 'package:booking_app_mobile/features/position/domain/usecases/delete_position.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/position_cubit.dart';
import '../cubit/position_state.dart';
import 'package:booking_app_mobile/core/di/injector.dart';

@RoutePage()
class PositionScreen extends StatelessWidget {
  const PositionScreen({super.key});

  Future<void> _showEditDialog(BuildContext context, Position? position) async {
    final nameController = TextEditingController(text: position?.name ?? '');
    final descController =
        TextEditingController(text: position?.description ?? '');
    final formKey = GlobalKey<FormState>();
    final cubit = context.read<PositionCubit>();

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title:
            Text(position == null ? 'Thêm chức vụ mới' : 'Chỉnh sửa chức vụ'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên chức vụ'),
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
              final pos = Position(
                id: position?.id,
                name: nameController.text.trim(),
                description: descController.text.trim(),
              );

              try {
                if (position == null) {
                  await cubit.addPosition(pos);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm chức vụ mới')));
                } else {
                  await cubit.editPosition(pos);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Cập nhật chức vụ')));
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
      appBar: AppBar(
        title: const Text('Chức vu'),
      ),
      body: BlocProvider(
        create: (context) => PositionCubit(
          getPositions: getIt<GetPositions>(),
          createPosition: getIt<CreatePosition>(),
          updatePosition: getIt<UpdatePosition>(),
          deletePosition: getIt<DeletePosition>(),
        )..fetchPositions(),
        child: BlocConsumer<PositionCubit, PositionState>(
          listener: (context, state) {
            if (state is PositionError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is PositionLoading || state is PositionInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is PositionError) {
              return Center(child: Text('Có lỗi xảy ra: ${state.message}'));
            }

            if (state is PositionLoaded) {
              final items = state.positions;
              if (items.isEmpty) {
                return const Center(child: Text('Không có chức vụ nào'));
              }

              return Column(
                children: [
                  FloatingActionButton(
                    child: const Icon(Icons.add),
                    onPressed: () => _showEditDialog(context, null),
                  ),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final p = items[index];
                        return ListTile(
                          title: Text(p.name ?? '-'),
                          subtitle: Text(p.description ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _showEditDialog(context, p),
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
                                          'Bạn có chắc chắn muốn xóa chức vụ này không?'),
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
                                  if (confirm == true && p.id != null) {
                                    await context
                                        .read<PositionCubit>()
                                        .removePosition(p.id!);
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
