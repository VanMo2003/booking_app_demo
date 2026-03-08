import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/navigation/app_routes.dart';
import '../../domain/entities/hotel.dart';
import '../cubit/hotel_bloc.dart';
import '../cubit/hotel_event.dart';
import '../cubit/hotel_state.dart';

@RoutePage()
class HotelListScreen extends StatefulWidget {
  const HotelListScreen({super.key});

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  void _onScroll() {
    final bloc = context.read<HotelBloc>();
    final st = bloc.state;
    if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 200) {
      if (!st.hasMore || st.status == HotelStatus.loading) return;
      bloc.add(HotelsFetched(page: st.page, size: st.size));
    }
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HotelBloc, HotelState>(
      listenWhen: (p, c) =>
          p.status != c.status || p.errorMessage != c.errorMessage,
      listener: (context, state) {
        if (state.status == HotelStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            title: const Text('Danh sách khách sạn'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  context.read<HotelBloc>().add(
                        HotelsFetched(page: 0, size: state.size, refresh: true),
                      );
                },
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              context
                  .read<HotelBloc>()
                  .add(HotelsFetched(page: 0, size: state.size, refresh: true));
            },
            child: ListView.separated(
              controller: _scroll,
              itemCount: state.items.length + 1,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                if (index == state.items.length) {
                  if (state.status == HotelStatus.loading) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!state.hasMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: Text('Hết dữ liệu')),
                    );
                  }
                  return const SizedBox.shrink();
                }

                final h = state.items[index];
                return _HotelTile(hotel: h);
              },
            ),
          ),
        );
      },
    );
  }
}

class _HotelTile extends StatelessWidget {
  final Hotel hotel;
  const _HotelTile({required this.hotel});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(hotel.name),
      subtitle: Text('${hotel.address}\n${hotel.phone} • ${hotel.category}'),
      isThreeLine: true,
      trailing: Text(hotel.active ? 'Active' : 'Inactive'),
      onTap: () => context.router.push(HotelDetailRoute(hotel: hotel)),
    );
  }
}
