import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product_model.dart';

class ApiService {
  /// 1. Mengambil seluruh data produk (GET /api/products)
  static Future<List<Product>> getProducts() async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.productsEndpoint),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Product.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat produk. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi ke server: $e');
    }
  }

  /// 2. Mengambil detail data produk (GET /api/products/{id})
  static Future<Product> getProductDetail(int id) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.productsEndpoint}/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        throw Exception('Produk tidak ditemukan di database.');
      } else {
        throw Exception('Gagal memuat detail produk. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan koneksi: $e');
    }
  }

  /// 3. Menambahkan data produk baru (POST /api/products)
  static Future<Product> createProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.productsEndpoint),
        headers: ApiConfig.headers,
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 201) {
        return Product.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errors = errorBody['errors'] != null ? errorBody['errors'].toString() : 'Data tidak valid';
        throw Exception('Validasi Gagal (422): $errors');
      } else {
        throw Exception('Gagal menambahkan produk. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan submit data: $e');
    }
  }

  /// 4. Mengubah data produk (PUT /api/products/{id})
  static Future<Product> updateProduct(int id, Product product) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.productsEndpoint}/$id'),
        headers: ApiConfig.headers,
        body: jsonEncode(product.toJson()),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 422) {
        final errorBody = jsonDecode(response.body);
        final errors = errorBody['errors'] != null ? errorBody['errors'].toString() : 'Data tidak valid';
        throw Exception('Validasi Gagal (422): $errors');
      } else {
        throw Exception('Gagal memperbarui produk. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan update data: $e');
    }
  }

  /// 5. Menghapus data produk (DELETE /api/products/{id})
  static Future<bool> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.productsEndpoint}/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        throw Exception('Gagal menghapus produk. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kesalahan hapus data: $e');
    }
  }
}
