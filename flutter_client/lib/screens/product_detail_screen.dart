import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_form_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _productFuture;

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  void _loadDetail() {
    setState(() {
      _productFuture = ApiService.getProductDetail(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Produk'),
        centerTitle: true,
      ),
      body: FutureBuilder<Product>(
        future: _productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadDetail,
                      child: const Text('Muat Ulang'),
                    ),
                  ],
                ),
              ),
            );
          }

          final product = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'ID: #${product.id}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade900,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Stok: ${product.stock} unit',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          product.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Rp ${product.price.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Divider(height: 32),
                        const Text(
                          'Deskripsi:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          (product.description != null && product.description!.isNotEmpty)
                              ? product.description!
                              : 'Tidak ada deskripsi tambahan.',
                          style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                        ),
                        const Divider(height: 32),
                        if (product.createdAt != null) ...[
                          Text(
                            'Waktu Dibuat: ${product.createdAt}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                        ],
                        if (product.updatedAt != null)
                          Text(
                            'Terakhir Diperbarui: ${product.updatedAt}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
                    );
                    if (result == true) {
                      _loadDetail();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Ubah Data Produk'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
