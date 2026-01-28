import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entity/amenity.dart';
import '../cubit/amenity_bloc.dart';
import '../cubit/amenity_event.dart';
import '../cubit/amenity_state.dart';
import 'amenity_form_page.dart';

class AmenityListPage extends StatefulWidget {
  final int hotelId;
  final int? roomId;

  const AmenityListPage({super.key, required this.hotelId, this.roomId});

  @override
  State<AmenityListPage> createState() => _AmenityListPageState();
}

class _AmenityListPageState extends State<AmenityListPage> {
  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    final bloc = context.read<AmenityBloc>();
    if (widget.roomId != null) {
      bloc.add(AmenitiesByRoomFetched(
          hotelId: widget.hotelId, roomId: widget.roomId!));
    } else {
      bloc.add(AmenitiesByHotelFetched(widget.hotelId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AmenityBloc, AmenityState>(
      listenWhen: (p, c) =>
          p.status != c.status || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.status == AmenityStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.roomId != null
                ? 'Tiện ích phòng'
                : 'Tiện ích khách sạn'),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _fetch),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AmenityFormPage(
                      hotelId: widget.hotelId, roomId: widget.roomId),
                ),
              );
              _fetch();
            },
            child: const Icon(Icons.add),
          ),
          body: RefreshIndicator(
            onRefresh: () async => _fetch(),
            child: state.status == AmenityStatus.loading && state.items.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: state.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final a = state.items[index];
                      return _AmenityTile(amenity: a);
                    },
                  ),
          ),
        );
      },
    );
  }
}

class _AmenityTile extends StatelessWidget {
  final Amenity amenity;
  const _AmenityTile({required this.amenity});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(amenity.name),
      subtitle: Text(amenity.description),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'edit') {
            await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      AmenityFormPage(hotelId: 0, amenity: amenity)),
            );
          } else if (value == 'delete') {
            final ok = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Xoá tiện ích'),
                content: Text('Bạn chắc chắn muốn xoá "${amenity.name}"?'),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Huỷ')),
                  FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Xoá')),
                ],
              ),
            );
            if (ok == true && context.mounted) {
              context.read<AmenityBloc>().add(AmenityDeleted(amenity.id));
              // refresh by refetch current list
              // simplest: pop and re-enter, or listen lastDeletedId and refetch outside
              // keep minimal here.
            }
          }
        },
        itemBuilder: (_) => const [
          PopupMenuItem(value: 'edit', child: Text('Chỉnh sửa')),
          PopupMenuItem(value: 'delete', child: Text('Xoá')),
        ],
      ),
    );
  }
}
