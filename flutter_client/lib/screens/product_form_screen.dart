import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _stockController;
  late TextEditingController _descriptionController;

  bool _isLoading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _priceController = TextEditingController(
      text: widget.product != null ? widget.product!.price.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(
      text: widget.product != null ? widget.product!.stock.toString() : '0',
    );
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final newProduct = Product(
      id: widget.product?.id,
      name: _nameController.text.trim(),
      price: double.tryParse(_priceController.text.trim()) ?? 0.0,
      stock: int.tryParse(_stockController.text.trim()) ?? 0,
      description: _descriptionController.text.trim(),
    );

    try {
      if (isEditing) {
        await ApiService.updateProduct(widget.product!.id!, newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil diperbarui!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      } else {
        await ApiService.createProduct(newProduct);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk baru berhasil ditambahkan!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Ubah Data Produk' : 'Tambah Produk Baru'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 0,
                color: Colors.blue.shade50.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.blue),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing
                              ? 'Mengirim request HTTP PUT ke backend server'
                              : 'Mengirim request HTTP POST ke backend server',
                          style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk *',
                  hintText: 'Contoh: Laptop Gaming, Mouse, dll',
                  prefixIcon: Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nama produk wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga (Rp) *',
                  hintText: 'Contoh: 30000',
                  prefixIcon: Icon(Icons.attach_money_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Harga produk wajib diisi';
                  }
                  if (double.tryParse(val.trim()) == null) {
                    return 'Harga harus berupa angka';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok Barang',
                  hintText: 'Contoh: 10',
                  prefixIcon: Icon(Icons.inventory_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi Produk',
                  hintText: 'Keterangan tambahan...',
                  prefixIcon: Icon(Icons.description_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: _isLoading ? null : _submitForm,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(
                  _isLoading ? 'Menyimpan...' : (isEditing ? 'Perbarui Produk' : 'Simpan Produk'),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
