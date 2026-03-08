import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/request/amenity_create_request.dart';
import '../../data/models/request/amenity_update_request.dart';
import '../../domain/entity/amenity.dart';
import '../cubit/amenity_bloc.dart';
import '../cubit/amenity_event.dart';
import '../cubit/amenity_state.dart';

class AmenityFormPage extends StatefulWidget {
  final int hotelId;
  final int? roomId;
  final Amenity? amenity;

  const AmenityFormPage({
    super.key,
    required this.hotelId,
    this.roomId,
    this.amenity,
  });

  @override
  State<AmenityFormPage> createState() => _AmenityFormPageState();
}

class _AmenityFormPageState extends State<AmenityFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  bool _common = false;

  bool get isEdit => widget.amenity != null;

  @override
  void initState() {
    super.initState();
    if (widget.amenity != null) {
      _name.text = widget.amenity!.name;
      _description.text = widget.amenity!.description;
      _common = widget.amenity!.common;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Báº¯t buá»™c' : null;

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (!isEdit) {
      final req = AmenityCreateRequest(
        name: _name.text.trim(),
        description: _description.text.trim(),
        common: _common,
        hotelId: widget.hotelId,
        roomId: widget.roomId,
      );
      context.read<AmenityBloc>().add(AmenityCreated(req));
    } else {
      final req = AmenityUpdateRequest(
        name: _name.text.trim(),
        description: _description.text.trim(),
        common: _common,
      );
      context
          .read<AmenityBloc>()
          .add(AmenityUpdated(id: widget.amenity!.id, request: req));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AmenityBloc, AmenityState>(
      listenWhen: (p, c) =>
          p.status != c.status ||
          p.lastCreatedOrUpdated != c.lastCreatedOrUpdated,
      listener: (context, state) {
        if (state.status == AmenityStatus.success &&
            state.lastCreatedOrUpdated != null) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(isEdit
                    ? 'Cáº­p nháº­t thÃ nh cÃ´ng'
                    : 'ThÃªm tiá»‡n Ã­ch thÃ nh cÃ´ng')),
          );
        }
        if (state.status == AmenityStatus.failure &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          title: Text(isEdit ? 'Chỉnh sửa tiện ích' : 'Thêm tiện ích'),
        ),
        body: BlocBuilder<AmenityBloc, AmenityState>(
          builder: (context, state) {
            final loading = state.status == AmenityStatus.loading;
            return AbsorbPointer(
              absorbing: loading,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    TextFormField(
                      controller: _name,
                      decoration:
                          const InputDecoration(labelText: 'TÃªn tiá»‡n Ã­ch'),
                      validator: _required,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _description,
                      decoration: const InputDecoration(labelText: 'MÃ´ táº£'),
                      validator: _required,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      title: const Text('Tiá»‡n Ã­ch chung (common)'),
                      value: _common,
                      onChanged: (v) => setState(() => _common = v),
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _submit,
                      child: loading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? 'LÆ°u' : 'ThÃªm'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
