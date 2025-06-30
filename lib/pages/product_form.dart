import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:umkm_connect/services/api_static.dart';
import 'package:umkm_connect/models/product_model.dart';

class ProductFormPage extends StatefulWidget {
  const ProductFormPage({super.key});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  String? _selectedCategory;
  String? _selectedLocation;
  File? _imageFile;
  bool _loading = false;

  final _picker = ImagePicker();
  final _api = APIStatic();

  final List<String> _categories = ['Makanan', 'Minuman', 'Fashion', 'Kerajinan', 'Jasa'];
  final List<String> _locations = ['Denpasar', 'Singaraja', 'Tabanan', 'Badung'];

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon lengkapi semua data dan upload gambar')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await _api.createProduct(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        price: int.parse(_priceController.text.trim()),
        stock: int.parse(_stockController.text.trim()),
        category: _selectedCategory!,
        location: _selectedLocation!,
        imageFile: _imageFile!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan produk: $e')),
      );
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Produk'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
      ),
      backgroundColor: const Color(0xFFFDF6FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nama Produk'),
                validator: (v) => v!.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
                validator: (v) => v!.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok'),
                validator: (v) => v!.isEmpty ? 'Stok wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text('Pilih Kategori'),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val),
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                hint: const Text('Pilih Lokasi'),
                items: _locations.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) => setState(() => _selectedLocation = val),
                validator: (v) => v == null ? 'Lokasi wajib dipilih' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: _imageFile != null
                    ? CircleAvatar(backgroundImage: FileImage(_imageFile!))
                    : const Icon(Icons.image),
                title: Text(_imageFile != null ? 'Gambar dipilih' : 'Pilih Gambar Produk'),
                trailing: const Icon(Icons.upload),
                onTap: _pickImage,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loading ? null : _submitForm,
                icon: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Icon(Icons.save),
                label: Text(_loading ? 'Menyimpan...' : 'Simpan Produk'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
