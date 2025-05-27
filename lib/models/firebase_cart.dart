import 'package:flutter/foundation.dart';
import 'package:delipan/models/product.dart';
import 'package:delipan/models/firebase_cart_item.dart';
import 'package:delipan/services/firebase_cart_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}

class FirebaseCart with ChangeNotifier {
  final FirebaseCartService _cartService = FirebaseCartService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<FirebaseCartItem> _items = [];
  StreamSubscription<List<FirebaseCartItem>>? _cartSubscription;
  StreamSubscription<User?>? _authSubscription;
  bool _isLoading = false;

  List<FirebaseCartItem> get items => List.unmodifiable(_items);
  
  // Getters adicionales para compatibilidad
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _auth.currentUser != null;
  int get totalItems => _items.fold(0, (total, item) => total + item.quantity);
  
  // Compatibilidad con el carrito existente
  List<CartItem> get cartItems => _items.map((item) => CartItem(
    product: item.toProduct(),
    quantity: item.quantity,
  )).toList();

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  double get totalAmount {
    return _items.fold(0.0, (total, item) => total + item.totalPrice);
  }

  FirebaseCart() {
    _initializeCart();
  }

  void _initializeCart() {
    // Escuchar cambios en el estado de autenticación
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _subscribeToCartChanges();
      } else {
        _clearLocalCart();
      }
    });
  }
  void _subscribeToCartChanges() {
    _cartSubscription?.cancel();
    _setLoading(true);
    _cartSubscription = _cartService.getCartItems().listen(
      (items) {
        _items = items;
        _setLoading(false);
        notifyListeners();
      },
      onError: (error) {
        _setLoading(false);
        debugPrint('Error en stream del carrito: $error');
      },
    );
  }
  
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _clearLocalCart() {
    _cartSubscription?.cancel();
    _items.clear();
    notifyListeners();
  }

  // Verificar si un producto está en el carrito
  bool isInCart(String productId) {
    return _items.any((item) => item.productId == productId);
  }

  // Agregar producto al carrito
  Future<bool> addProduct(Product product, {int quantity = 1}) async {
    try {
      final success = await _cartService.addProduct(product, quantity: quantity);
      if (!success) {
        debugPrint('Error al agregar producto al carrito en Firebase');
      }
      return success;
    } catch (e) {
      debugPrint('Error agregando producto: $e');
      return false;
    }
  }

  // Eliminar producto por ID del producto
  Future<bool> removeProduct(String productId) async {
    try {
      return await _cartService.removeProductById(productId);
    } catch (e) {
      debugPrint('Error eliminando producto: $e');
      return false;
    }
  }

  // Eliminar item específico del carrito
  Future<bool> removeCartItem(String cartItemId) async {
    try {
      return await _cartService.removeProduct(cartItemId);
    } catch (e) {
      debugPrint('Error eliminando item del carrito: $e');
      return false;
    }
  }

  // Actualizar cantidad de un producto
  Future<bool> updateQuantity(String cartItemId, int quantity) async {
    try {
      return await _cartService.updateQuantity(cartItemId, quantity);
    } catch (e) {
      debugPrint('Error actualizando cantidad: $e');
      return false;
    }
  }
  // Limpiar carrito
  Future<bool> clear() async {
    try {
      return await _cartService.clearCart();
    } catch (e) {
      debugPrint('Error limpiando carrito: $e');
      return false;
    }
  }

  // Alias para compatibilidad
  Future<bool> clearCart() async {
    return await clear();
  }

  // Obtener item del carrito por ID del producto
  FirebaseCartItem? getCartItemByProductId(String productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Incrementar cantidad de un producto específico
  Future<bool> incrementQuantity(String productId) async {
    final cartItem = getCartItemByProductId(productId);
    if (cartItem != null) {
      return await updateQuantity(cartItem.id, cartItem.quantity + 1);
    }
    return false;
  }

  // Decrementar cantidad de un producto específico
  Future<bool> decrementQuantity(String productId) async {
    final cartItem = getCartItemByProductId(productId);
    if (cartItem != null) {
      if (cartItem.quantity > 1) {
        return await updateQuantity(cartItem.id, cartItem.quantity - 1);
      } else {
        return await removeCartItem(cartItem.id);
      }
    }
    return false;
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
