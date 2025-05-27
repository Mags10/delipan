import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delipan/models/firebase_cart_item.dart';
import 'package:delipan/models/product.dart';
import 'package:flutter/foundation.dart';

class FirebaseCartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  static final FirebaseCartService _instance = FirebaseCartService._internal();
  factory FirebaseCartService() => _instance;
  FirebaseCartService._internal();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // Colección del carrito del usuario actual
  CollectionReference? get _userCartCollection {
    final user = currentUser;
    if (user == null) return null;
    return _firestore.collection('users').doc(user.uid).collection('cart');
  }

  // Obtener todos los items del carrito
  Stream<List<FirebaseCartItem>> getCartItems() {
    final cartCollection = _userCartCollection;
    if (cartCollection == null) {
      return Stream.value([]);
    }

    return cartCollection
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FirebaseCartItem.fromFirestore(doc))
            .toList());
  }

  // Agregar producto al carrito
  Future<bool> addProduct(Product product, {int quantity = 1}) async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) {
        throw Exception('Usuario no autenticado');
      }

      // Verificar si el producto ya está en el carrito
      final existingItem = await cartCollection
          .where('productId', isEqualTo: product.id)
          .limit(1)
          .get();

      if (existingItem.docs.isNotEmpty) {
        // Si ya existe, actualizar la cantidad
        final doc = existingItem.docs.first;
        final currentQuantity = doc['quantity'] as int;
        await doc.reference.update({
          'quantity': currentQuantity + quantity,
        });
      } else {
        // Si no existe, crear nuevo item
        final cartItem = FirebaseCartItem.fromProduct(product, quantity: quantity);
        await cartCollection.add(cartItem.toFirestore());
      }

      return true;
    } catch (e) {
      debugPrint('Error agregando producto al carrito: $e');
      return false;
    }
  }

  // Verificar si un producto está en el carrito
  Future<bool> isInCart(String productId) async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return false;

      final result = await cartCollection
          .where('productId', isEqualTo: productId)
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando producto en carrito: $e');
      return false;
    }
  }

  // Actualizar cantidad de un producto
  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return false;

      if (quantity <= 0) {
        // Si la cantidad es 0 o menos, eliminar el item
        await cartCollection.doc(cartItemId).delete();
      } else {
        // Actualizar la cantidad
        await cartCollection.doc(cartItemId).update({'quantity': quantity});
      }

      return true;
    } catch (e) {
      debugPrint('Error actualizando cantidad: $e');
      return false;
    }
  }

  // Eliminar producto del carrito
  Future<bool> removeProduct(String cartItemId) async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return false;

      await cartCollection.doc(cartItemId).delete();
      return true;
    } catch (e) {
      debugPrint('Error eliminando producto del carrito: $e');
      return false;
    }
  }

  // Eliminar producto por ID de producto
  Future<bool> removeProductById(String productId) async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return false;

      final items = await cartCollection
          .where('productId', isEqualTo: productId)
          .get();

      for (var doc in items.docs) {
        await doc.reference.delete();
      }

      return true;
    } catch (e) {
      debugPrint('Error eliminando producto por ID: $e');
      return false;
    }
  }

  // Limpiar todo el carrito
  Future<bool> clearCart() async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return false;

      final items = await cartCollection.get();
      for (var doc in items.docs) {
        await doc.reference.delete();
      }

      return true;
    } catch (e) {
      debugPrint('Error limpiando carrito: $e');
      return false;
    }
  }

  // Obtener cantidad total de items en el carrito
  Future<int> getCartItemCount() async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return 0;

      final snapshot = await cartCollection.get();
      int total = 0;
      
      for (var doc in snapshot.docs) {
        total += (doc['quantity'] as int? ?? 0);
      }

      return total;
    } catch (e) {
      debugPrint('Error obteniendo cantidad de items: $e');
      return 0;
    }
  }

  // Obtener total del carrito
  Future<double> getCartTotal() async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return 0.0;

      final snapshot = await cartCollection.get();
      double total = 0.0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final price = (data['productPrice'] as num? ?? 0).toDouble();
        final quantity = data['quantity'] as int? ?? 0;
        total += price * quantity;
      }

      return total;
    } catch (e) {
      debugPrint('Error obteniendo total del carrito: $e');
      return 0.0;
    }
  }

  // Sincronizar carrito local con Firebase (útil para migración)
  Future<bool> syncLocalCart(List<dynamic> localCartItems) async {
    try {
      final cartCollection = _userCartCollection;
      if (cartCollection == null) return false;

      // Limpiar carrito actual
      await clearCart();

      // Agregar items del carrito local
      for (var item in localCartItems) {
        if (item is Map<String, dynamic>) {
          await cartCollection.add(item);
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error sincronizando carrito local: $e');
      return false;
    }
  }
}
