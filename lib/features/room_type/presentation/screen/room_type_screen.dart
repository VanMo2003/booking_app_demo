import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/features/room_type/domain/entity/room_type.dart';
import 'package:booking_app_mobile/features/room_type/presentation/cubit/room_type_cubit.dart';
import 'package:booking_app_mobile/features/room_type/presentation/cubit/room_type_state.dart';
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
        title: Text(item == null ? 'Add Room type' : 'Edit Room type'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              TextFormField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                minLines: 1,
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel')),
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
                      const SnackBar(content: Text('Room type added')));
                } else {
                  await cubit.edit(rt);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room type updated')));
                }
                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room type')),
      body: BlocProvider(
        create: (context) => RoomTypeCubit(
          getRoomTypes: getIt<GetRoomTypes>(),
          createRoomType: getIt<CreateRoomType>(),
          updateRoomType: getIt<UpdateRoomType>(),
          deleteRoomType: getIt<DeleteRoomType>(),
        )..fetch(),
        child: BlocConsumer<RoomTypeCubit, RoomTypeState>(
          listener: (context, state) {
            if (state is RoomTypeError) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
          builder: (context, state) {
            if (state is RoomTypeLoading || state is RoomTypeInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RoomTypeError) {
              return Center(child: Text('Error: ${state.message}'));
            }

            if (state is RoomTypeLoaded) {
              final items = state.items;
              if (items.isEmpty) {
                return const Center(child: Text('No room types found'));
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
                                      title: const Text('Confirm delete'),
                                      content: const Text(
                                          'Are you sure you want to delete this room type?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () =>
                                                Navigator.of(context)
                                                    .pop(false),
                                            child: const Text('Cancel')),
                                        ElevatedButton(
                                            onPressed: () =>
                                                Navigator.of(context).pop(true),
                                            child: const Text('Delete')),
                                      ],
                                    ),
                                  );
                                  if (confirm == true && r.id != null) {
                                    await context
                                        .read<RoomTypeCubit>()
                                        .remove(r.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Room type deleted')));
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
