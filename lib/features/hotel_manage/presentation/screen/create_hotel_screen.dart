import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:booking_app_mobile/core/di/injector.dart';
import 'package:booking_app_mobile/features/hotel/domain/repositories/hotel_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

@RoutePage()
class CreateHotelScreen extends StatefulWidget {
  const CreateHotelScreen({super.key});

  @override
  State<CreateHotelScreen> createState() => _CreateHotelScreenState();
}

class _CreateHotelScreenState extends State<CreateHotelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtl = TextEditingController();
  final _addressCtl = TextEditingController();
  final _phoneCtl = TextEditingController();
  final _descriptionCtl = TextEditingController();
  final _categoryCtl = TextEditingController();

  final HotelRepository _hotelRepository = getIt<HotelRepository>();
  final List<String> _imagePaths = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtl.dispose();
    _addressCtl.dispose();
    _phoneCtl.dispose();
    _descriptionCtl.dispose();
    _categoryCtl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) return;

    final path = result.files.first.path;
    if (path == null || path.isEmpty) return;

    setState(() {
      _imagePaths
        ..clear()
        ..add(path);
    });
  }

  void _removeImage() {
    setState(() => _imagePaths.clear());
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    if (_imagePaths.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn 1 ảnh cho cơ sở.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final created = await _hotelRepository.createHotel(
        name: _nameCtl.text.trim(),
        address: _addressCtl.text.trim(),
        phone: _phoneCtl.text.trim(),
        description: _descriptionCtl.text.trim(),
        category: _categoryCtl.text.trim(),
        active: true,
        pathImage: null,
        imagePaths: _imagePaths,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo cơ sở mới thành công: ${created.name}')),
      );
      context.router.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tạo cơ sở mới thất bại: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPath = _imagePaths.isNotEmpty ? _imagePaths.first : null;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text('Tạo cơ sở mới',
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameCtl,
                decoration: _decoration('Tên khách sạn'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nhập tên khách sạn'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressCtl,
                decoration: _decoration('Địa chỉ'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập địa chỉ' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneCtl,
                decoration: _decoration('Số điện thoại'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Nhập số điện thoại'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtl,
                decoration: _decoration('Mô tả'),
                minLines: 2,
                maxLines: 3,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập mô tả' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _categoryCtl,
                decoration: _decoration('Thể loại'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nhập thể loại' : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ảnh cơ sở',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _pickImage,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn ảnh'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (selectedPath == null)
                const Text(
                  'Chưa chọn ảnh. Vui lòng chọn đúng 1 ảnh.',
                  style: TextStyle(color: Colors.redAccent),
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(selectedPath),
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 72,
                              height: 72,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.broken_image_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedPath.split(RegExp(r'[\\/]')).last,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        IconButton(
                          onPressed: _isSubmitting ? null : _removeImage,
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Tạo cơ sở mới'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
