import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String description;
  final bool isFeatured;
  final String category;
  final DateTime? createdAt;
  final bool isActive;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.description = '',
    this.isFeatured = false,
    this.category = 'general',
    this.createdAt,
    this.isActive = true,
    this.stock = 0,
  });

  // Factory constructor para crear Product desde Firestore
  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      category: data['category'] ?? 'general',
      createdAt: data['createdAt']?.toDate(),
      isActive: data['isActive'] ?? true,
      stock: data['stock'] ?? 0,
    );
  }

  // Método para convertir Product a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'description': description,
      'isFeatured': isFeatured,
      'category': category,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'isActive': isActive,
      'stock': stock,
    };
  }

  // Factory constructor para crear Product desde Map
  factory Product.fromMap(Map<String, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      description: map['description'] ?? '',
      isFeatured: map['isFeatured'] ?? false,
      category: map['category'] ?? 'general',
      createdAt: map['createdAt']?.toDate(),
      isActive: map['isActive'] ?? true,
      stock: map['stock'] ?? 0,
    );
  }

  // Crear una copia de Product con algunos campos actualizados
  Product copyWith({
    String? name,
    double? price,
    String? imageUrl,
    String? description,
    bool? isFeatured,
    String? category,
    DateTime? createdAt,
    bool? isActive,
    int? stock,
  }) {
    return Product(
      id: this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isFeatured: isFeatured ?? this.isFeatured,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      stock: stock ?? this.stock,
    );
  }
}