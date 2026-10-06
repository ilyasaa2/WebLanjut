/// Konfigurasi URL Backend API sesuai Panduan Tahap 10 Tugas Kuliah
class ApiConfig {
  /// Sebelumnya (Environment Lokal):
  /// static const String baseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  /// static const String baseUrl = 'http://localhost:8000/api'; // Chrome / Web / iOS

  /// URL Backend Production (Hasil Deployment Online):
  static const String baseUrl = 'https://web-lanjut-gold.vercel.app/api';

  /// Endpoint paths
  static const String productsEndpoint = '$baseUrl/products';

  /// Header default untuk request JSON
  static Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
