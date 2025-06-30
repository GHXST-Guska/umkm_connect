import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:umkm_connect/models/product_model.dart';
import 'package:umkm_connect/services/api_static.dart';

class ProductFormPage extends StatefulWidget {
  final ProductModel? existingProduct;

  const ProductFormPage({super.key, this.existingProduct});

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

  @override
  void initState() {
    super.initState();
    if (widget.existingProduct != null) {
      final p = widget.existingProduct!;
      _titleController.text = p.title;
      _descController.text = p.description;
      _priceController.text = p.price.toString();
      _stockController.text = p.stock.toString();
      _selectedCategory = p.category;
      _selectedLocation = p.location;
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_imageFile == null && widget.existingProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Upload gambar produk terlebih dahulu')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      if (widget.existingProduct == null) {
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
        }
      } else {
        await _api.updateProduct(
          id: widget.existingProduct!.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          price: int.parse(_priceController.text.trim()),
          stock: int.parse(_stockController.text.trim()),
          category: _selectedCategory!,
          location: _selectedLocation!,
          imageFile: _imageFile,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Produk berhasil diperbarui')),
          );
        }
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan produk: $e')),
        );
      }
    }

    setState(() => _loading = false);
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    bool obscure = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.pinkAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.pink, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      hint: Text(hint),
      items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text(e.toString()))).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.pinkAccent),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.pink, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (v) => v == null ? 'Wajib dipilih' : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProduct != null;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF6FA),
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Produk' : 'Tambah Produk'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.pink,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildInputField(
                controller: _titleController,
                label: 'Nama Produk',
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _descController,
                label: 'Deskripsi Produk',
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _priceController,
                label: 'Harga',
                type: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildInputField(
                controller: _stockController,
                label: 'Stok',
                type: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 14),
              _buildDropdown(
                hint: 'Pilih Kategori',
                value: _selectedCategory,
                items: _categories,
                onChanged: (val) => setState(() => _selectedCategory = val),
              ),
              const SizedBox(height: 14),
              _buildDropdown(
                hint: 'Pilih Lokasi',
                value: _selectedLocation,
                items: _locations,
                onChanged: (val) => setState(() => _selectedLocation = val),
              ),
              const SizedBox(height: 16),
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                tileColor: Colors.white,
                leading: _imageFile != null
                    ? CircleAvatar(backgroundImage: FileImage(_imageFile!))
                    : (isEdit && widget.existingProduct?.imageUrl != null)
                        ? CircleAvatar(backgroundImage: NetworkImage(widget.existingProduct!.imageUrl!))
                        : const Icon(Icons.image),
                title: Text(_imageFile != null
                    ? 'Gambar dipilih'
                    : isEdit
                        ? 'Gambar sebelumnya'
                        : 'Pilih gambar produk'),
                trailing: const Icon(Icons.upload),
                onTap: _pickImage,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submitForm,
                  icon: _loading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Icon(isEdit ? Icons.save_as : Icons.save),
                  label: Text(_loading ? 'Menyimpan...' : isEdit ? 'Simpan Perubahan' : 'Tambah Produk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
