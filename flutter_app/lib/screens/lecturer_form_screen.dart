import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../config/api_config.dart';
import '../../models/lecturer.dart';
import '../../services/lecturer_service.dart';

class LecturerFormScreen extends StatefulWidget {
  const LecturerFormScreen({super.key, this.lecturer});

  final Lecturer? lecturer;

  @override
  State<LecturerFormScreen> createState() => _LecturerFormScreenState();
}

class _LecturerFormScreenState extends State<LecturerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _fullnameController = TextEditingController();
  final _sumClassController = TextEditingController();
  final _imagePicker = ImagePicker();

  XFile? _selectedImage;
  bool _isSaving = false;

  bool get _isEditing => widget.lecturer != null;

  @override
  void initState() {
    super.initState();
    final lecturer = widget.lecturer;
    if (lecturer != null) {
      _idController.text = lecturer.idgv;
      _fullnameController.text = lecturer.fullname;
      _sumClassController.text = lecturer.sumClass.toString();
    }
    _restoreLostImage();
  }

  @override
  void dispose() {
    _idController.dispose();
    _fullnameController.dispose();
    _sumClassController.dispose();
    super.dispose();
  }

  Future<void> _restoreLostImage() async {
    try {
      final response = await _imagePicker.retrieveLostData();
      if (!response.isEmpty &&
          response.files != null &&
          response.files!.isNotEmpty &&
          mounted) {
        setState(() => _selectedImage = response.files!.first);
      }
    } catch (_) {
      // No interrupted image-picker operation to restore.
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1400,
      );
      if (image != null && mounted) setState(() => _selectedImage = image);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not select image: $error')));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isEditing && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a lecturer portrait.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final idgv = _idController.text.trim();
      final fullname = _fullnameController.text.trim();
      final sumClass = int.parse(_sumClassController.text.trim());

      if (_isEditing) {
        await LecturerService.update(
          id: widget.lecturer!.id,
          idgv: idgv,
          fullname: fullname,
          sumClass: sumClass,
          imagePath: _selectedImage?.path,
        );
      } else {
        await LecturerService.create(
          idgv: idgv,
          fullname: fullname,
          sumClass: sumClass,
          imagePath: _selectedImage!.path,
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Lecturer updated.' : 'Lecturer added.'),
        ),
      );
      debugPrint('Lecturer saved successfully. Returning true.');

      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePreview() {
    Widget image;
    if (_selectedImage != null) {
      image = Image.file(
        File(_selectedImage!.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 190,
      );
    } else if (_isEditing && widget.lecturer!.image != null) {
      final url = ApiConfig.imageUrl(widget.lecturer!.image);
      image = Image.network(
        url!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 190,
        errorBuilder: (_, _, _) => _imagePlaceholder(),
      );
    } else {
      image = _imagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(height: 190, width: double.infinity, child: image),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: const Color(0xFFEAF3FB),
      width: double.infinity,
      height: 190,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_a_photo_outlined, size: 38, color: Color(0xFF5F91BD)),
          SizedBox(height: 9),
          Text(
            'Choose lecturer portrait',
            style: TextStyle(color: Color(0xFF5F7890)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit lecturer' : 'Add lecturer',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
            children: [
              const Text(
                'Lecturer information',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF18344F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Enter the lecturer details below.',
                style: TextStyle(color: Color(0xFF71869A)),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE5EDF5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Portrait',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF18344F),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildImagePreview(),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : _pickImage,
                        icon: const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _selectedImage == null
                              ? 'Choose from gallery'
                              : 'Change image',
                        ),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(46),
                        ),
                      ),
                      if (_isEditing && _selectedImage == null)
                        const Padding(
                          padding: EdgeInsets.only(top: 7),
                          child: Text(
                            'Leave unchanged to keep the current portrait.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8295A7),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFE5EDF5)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _idController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Lecturer ID (IDGV)',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Lecturer ID is required.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _fullnameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Fullname',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Fullname is required.'
                            : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _sumClassController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Total classes',
                          prefixIcon: Icon(Icons.school_outlined),
                          hintText: 'Enter a positive integer',
                        ),
                        validator: (value) {
                          final number = int.tryParse(value?.trim() ?? '');
                          if (number == null || number <= 0) {
                            return 'Enter a positive whole number.';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 22),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_isSaving ? 'Saving...' : 'Save lecturer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
