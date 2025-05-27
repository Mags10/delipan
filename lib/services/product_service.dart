import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:delipan/models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Colección de productos en Firestore
  CollectionReference get _productsCollection => _firestore.collection('products');  // Obtener todos los productos
  Stream<List<Product>> getProducts() {
    return _productsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          var products = snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList();
          // Ordenar en el cliente por fecha de creación (manejo seguro de nulos)
          products.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.now();
            final bDate = b.createdAt ?? DateTime.now();
            return bDate.compareTo(aDate);
          });
          return products;
        });
  }

  // Stream para productos destacados
  // ...existing code...
  Stream<List<Product>> getFeaturedProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .where('isFeatured', isEqualTo: true) // Cambiar a true para productos destacados
        // Quitar el .orderBy('name') para evitar el índice compuesto
        .snapshots()        .map((snapshot) {
          var products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
          // Ordenar en el cliente
          products.sort((a, b) => a.name.compareTo(b.name));
          return products;
        });
  }

  // Obtener productos no destacados
  // ...existing code...
  Stream<List<Product>> getMoreProducts({DocumentSnapshot? lastDocument, int limit = 10}) {
    Query query = _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) {      List<Product> products = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .where((product) => product.isFeatured == false)
          .toList();
      
      products.sort((a, b) => a.name.compareTo(b.name));
      return products;
    });
  }

  // Función para buscar productos
  Stream<List<Product>> searchProducts(String query) {
    if (query.isEmpty) {
      return Stream.value([]);
    }
    
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          String searchTerm = query.toLowerCase();          List<Product> products = snapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .where((product) {
                return product.name.toLowerCase().contains(searchTerm) ||
                      product.description.toLowerCase().contains(searchTerm) ||
                      product.category.toLowerCase().contains(searchTerm);
              })
              .toList();
          
          products.sort((a, b) => a.name.compareTo(b.name));
          return products;
        });
  }

  // Método para obtener un solo producto por su ID
  Future<Product?> getProductById(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists && doc.data() != null) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error al obtener producto por ID: $e');
      return null;
    }
  }

  // Agregar un producto (para administradores)
  Future<bool> addProduct(Product product) async {
    try {
      await _productsCollection.add(product.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error agregando producto: $e');
      return false;
    }
  }

  // Actualizar un producto (para administradores)
  Future<bool> updateProduct(String id, Product product) async {
    try {
      await _productsCollection.doc(id).update(product.toFirestore());
      return true;
    } catch (e) {
      debugPrint('Error actualizando producto: $e');
      return false;
    }
  }

  // Eliminar un producto (marcar como inactivo)
  Future<bool> deleteProduct(String id) async {
    try {
      await _productsCollection.doc(id).update({'isActive': false});
      return true;
    } catch (e) {
      debugPrint('Error eliminando producto: $e');
      return false;
    }
  }

  // Actualizar stock de un producto
  Future<bool> updateStock(String productId, int newStock) async {
    try {
      await _productsCollection.doc(productId).update({'stock': newStock});
      return true;
    } catch (e) {
      debugPrint('Error actualizando stock: $e');
      return false;
    }
  }

  // Reducir stock (cuando se compra un producto)
  Future<bool> reduceStock(String productId, int quantity) async {
    try {
      return await _firestore.runTransaction((transaction) async {
        DocumentReference productRef = _productsCollection.doc(productId);
        DocumentSnapshot snapshot = await transaction.get(productRef);
        
        if (!snapshot.exists) {
          throw Exception('Producto no encontrado');
        }
        
        int currentStock = snapshot['stock'] ?? 0;
        if (currentStock < quantity) {
          throw Exception('Stock insuficiente');
        }
        
        transaction.update(productRef, {'stock': currentStock - quantity});
        return true;
      });
    } catch (e) {
      debugPrint('Error reduciendo stock: $e');
      return false;
    }
  }
}
