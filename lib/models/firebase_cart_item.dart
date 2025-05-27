import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delipan/models/product.dart';

class FirebaseCartItem {
  final String id;
  final String productId;
  final String productName;
  final double productPrice;
  final String productImageUrl;
  final String category;
  int quantity;
  final DateTime addedAt;

  FirebaseCartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productPrice,
    required this.productImageUrl,
    required this.category,
    required this.quantity,
    required this.addedAt,
  });

  double get totalPrice => productPrice * quantity;

  // Factory constructor para crear desde Firestore
  factory FirebaseCartItem.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return FirebaseCartItem(
      id: doc.id,
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      productPrice: (data['productPrice'] ?? 0).toDouble(),
      productImageUrl: data['productImageUrl'] ?? '',
      category: data['category'] ?? '',
      quantity: data['quantity'] ?? 1,
      addedAt: data['addedAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Método para convertir a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'productName': productName,
      'productPrice': productPrice,
      'productImageUrl': productImageUrl,
      'category': category,
      'quantity': quantity,
      'addedAt': addedAt,
    };
  }

  // Factory constructor para crear desde Product
  factory FirebaseCartItem.fromProduct(Product product, {int quantity = 1}) {
    return FirebaseCartItem(
      id: '', // Se asignará automáticamente por Firestore
      productId: product.id,
      productName: product.name,
      productPrice: product.price,
      productImageUrl: product.imageUrl,
      category: product.category,
      quantity: quantity,
      addedAt: DateTime.now(),
    );
  }

  // Convertir a Product para compatibilidad con el carrito existente
  Product toProduct() {
    return Product(
      id: productId,
      name: productName,
      price: productPrice,
      imageUrl: productImageUrl,
      category: category,
    );
  }
}
