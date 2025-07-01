import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:umkm_connect/services/api_static.dart';

class CreateShopPage extends StatefulWidget {
  const CreateShopPage({super.key});

  @override
  State<CreateShopPage> createState() => _CreateShopPageState();
}

class _CreateShopPageState extends State<CreateShopPage> {
  final TextEditingController _nameController = TextEditingController();
  File? _ktpFile;
  final ImagePicker _picker = ImagePicker();
  final _api = APIStatic();
  bool _isLoading = false;

  Future<void> _pickKtpImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _ktpFile = File(picked.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_nameController.text.trim().isEmpty || _ktpFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap isi nama toko dan upload foto KTP'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _api.createShop(
        name: _nameController.text.trim(),
        ktpFile: _ktpFile!,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengajuan toko berhasil dikirim, harap tunggu untuk divalidasi',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal membuat toko: $e')));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Toko Baru'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFFDF6FA),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Formulir Pengajuan Toko',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nama Toko',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          ListTile(
            leading:
                _ktpFile != null
                    ? CircleAvatar(
                      backgroundImage: FileImage(_ktpFile!),
                      radius: 20,
                    )
                    : const Icon(Icons.badge),
            title: Text(
              _ktpFile != null ? 'KTP terpilih' : 'Upload Foto KTP Pemilik',
            ),
            trailing: const Icon(Icons.upload),
            onTap: _pickKtpImage,
          ),

          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _submit,
            icon:
                _isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.send),
            label: Text(_isLoading ? 'Mengirim...' : 'Kirim Pengajuan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
