// lib/pages/admin/content_form_page.dart

import 'package:flutter/material.dart';
import 'package:umkm_connect/models/content_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class ContentFormPage extends StatefulWidget {
  final ContentModel? content; // Jika null, berarti mode Tambah. Jika ada, mode Edit.

  const ContentFormPage({super.key, this.content});

  @override
  State<ContentFormPage> createState() => _ContentFormPageState();
}

class _ContentFormPageState extends State<ContentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final APIStatic _api = APIStatic();
  bool get _isEditMode => widget.content != null;
  
  late TextEditingController _titleController;
  late TextEditingController _videoIdController;
  late TextEditingController _descriptionController;
  late TextEditingController _creatorController;
  late TextEditingController _playlistController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.content?.title ?? '');
    _videoIdController = TextEditingController(text: widget.content?.videoId ?? '');
    _descriptionController = TextEditingController(text: widget.content?.description ?? '');
    _creatorController = TextEditingController(text: widget.content?.creator ?? '');
    _playlistController = TextEditingController(text: widget.content?.playlist ?? '');
  }
  
  @override
  void dispose() {
    // Jangan lupa dispose semua controller
    _titleController.dispose();
    _videoIdController.dispose();
    _descriptionController.dispose();
    _creatorController.dispose();
    _playlistController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'title': _titleController.text,
        'video': _videoIdController.text,
        'description': _descriptionController.text,
        'creator': _creatorController.text,
        'playlist': _playlistController.text,
      };

      try {
        if (_isEditMode) {
          await _api.updateContent(widget.content!.id, data);
        } else {
          await _api.createContent(data);
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konten berhasil disimpan!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Konten' : 'Tambah Konten Baru'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildTextFormField(_titleController, 'Judul'),
            _buildTextFormField(_videoIdController, 'ID Video YouTube'),
            _buildTextFormField(_descriptionController, 'Deskripsi', maxLines: 5),
            _buildTextFormField(_creatorController, 'Kreator'),
            _buildTextFormField(_playlistController, 'Playlist'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Simpan'),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (label.contains('Opsional')) return null; // Lewati validasi jika opsional
          if (value == null || value.isEmpty) {
            return '$label tidak boleh kosong';
          }
          return null;
        },
      ),
    );
  }
}