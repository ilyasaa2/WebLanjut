class Product {
  final int? id;
  final String name;
  final double price;
  final String? description;
  final int stock;
  final String? createdAt;
  final String? updatedAt;

  Product({
    this.id,
    required this.name,
    required this.price,
    this.description,
    this.stock = 0,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()),
      name: json['name'] ?? '',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) ?? 0.0 : 0.0,
      description: json['description'],
      stock: json['stock'] is int ? json['stock'] : int.tryParse(json['stock'].toString()) ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'price': price,
      if (description != null) 'description': description,
      'stock': stock,
    };
  }
}
