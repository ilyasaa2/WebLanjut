import 'package:flutter/material.dart';
import '../config/api_config.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    setState(() {
      _productsFuture = ApiService.getProducts();
    });
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ApiService.deleteProduct(product.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Produk "${product.name}" berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
        _loadProducts();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Produk REST API'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Segarkan Data',
            onPressed: _loadProducts,
          ),
        ],
      ),
      body: Column(
        children: [
          // Banner Status Koneksi Backend Online (Sangat membantu untuk Screenshot/Video tugas)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                const Icon(Icons.cloud_done, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Backend Endpoint URL:',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                      Text(
                        ApiConfig.productsEndpoint,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Daftar Produk
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadProducts(),
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
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
                            ElevatedButton.icon(
                              onPressed: _loadProducts,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Coba Lagi'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final products = snapshot.data ?? [];

                  if (products.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum ada data produk di server.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => _navigateToAdd(context),
                            icon: const Icon(Icons.add),
                            label: const Text('Tambah Produk Pertama'),
                          )
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Card(
                        elevation: 1.5,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              '#${product.id ?? (index + 1)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${product.price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              if (product.description != null && product.description!.isNotEmpty)
                                Text(
                                  product.description!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                ),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'detail') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(productId: product.id!),
                                  ),
                                );
                              } else if (value == 'edit') {
                                _navigateToEdit(context, product);
                              } else if (value == 'delete') {
                                _deleteProduct(product);
                              }
                            },
                            itemBuilder: (ctx) => [
                              const PopupMenuItem(
                                value: 'detail',
                                child: Row(
                                  children: [
                                    Icon(Icons.visibility, size: 18, color: Colors.blue),
                                    SizedBox(width: 8),
                                    Text('Lihat Detail'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit, size: 18, color: Colors.orange),
                                    SizedBox(width: 8),
                                    Text('Ubah Data'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, size: 18, color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Hapus Data'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(productId: product.id!),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAdd(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Produk'),
      ),
    );
  }

  void _navigateToAdd(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProductFormScreen()),
    );
    if (result == true) {
      _loadProducts();
    }
  }

  void _navigateToEdit(BuildContext context, Product product) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductFormScreen(product: product)),
    );
    if (result == true) {
      _loadProducts();
    }
  }
}
