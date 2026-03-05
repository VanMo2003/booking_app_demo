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

  Future<void> _pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );
    if (result == null || result.files.isEmpty) return;

    final paths = result.files.map((e) => e.path).whereType<String>().toList();
    if (paths.isEmpty) return;
    setState(() {
      for (final path in paths) {
        if (!_imagePaths.contains(path)) {
          _imagePaths.add(path);
        }
      }
    });
  }

  void _removeImageAt(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

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
        SnackBar(content: Text('Tên cơ sở đã tồn tại: ${created.name}')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo cơ sở mới'),
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
                    'Ảnh mặc định',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  OutlinedButton.icon(
                    onPressed: _isSubmitting ? null : _pickImages,
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn ảnh'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_imagePaths.isEmpty)
                const Text(
                  'Chưa chọn ảnh. Bạn vẫn có thể tạo cơ sở mà không cần ảnh.',
                  style: TextStyle(color: Colors.grey),
                )
              else
                Column(
                  children: List.generate(_imagePaths.length, (index) {
                    final path = _imagePaths[index];
                    final fileName = path.split(RegExp(r'[\\\\/]')).last;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.image_outlined),
                        title: Text(
                          fileName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          path,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _removeImageAt(index),
                          icon: const Icon(Icons.close),
                        ),
                      ),
                    );
                  }),
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
