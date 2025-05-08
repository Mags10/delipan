import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:delipan/models/cart_item.dart';
import 'package:delipan/models/product.dart';

class Cart extends ChangeNotifier {
  // Mapa privado para almacenar los items del carrito
  final Map<String, CartItem> _items = {};

  // Getter para acceder a los items como una lista inmutable
  UnmodifiableListView<CartItem> get items => 
      UnmodifiableListView(_items.values.toList());

  // Cantidad total de items en el carrito
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  // Precio total del carrito
  double get totalPrice => _items.values.fold(
      0, (sum, cartItem) => sum + cartItem.totalPrice);

  // Verificar si el carrito está vacío
  bool get isEmpty => _items.isEmpty;

  // Verificar si un producto está en el carrito
  bool isInCart(String productId) => _items.containsKey(productId);

  // Obtener la cantidad de un producto específico
  int getQuantity(String productId) {
    if (_items.containsKey(productId)) {
      return _items[productId]!.quantity;
    }
    return 0;
  }

  // Añadir un producto al carrito
  void addItem(Product product) {
    if (_items.containsKey(product.id)) {
      _items.update(
        product.id,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product),
      );
    }
    notifyListeners();
  }

  // Eliminar un producto del carrito
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Reducir la cantidad de un producto, eliminarlo si llega a cero
  void decrementItem(String productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingItem) => CartItem(
          product: existingItem.product,
          quantity: existingItem.quantity - 1,
        ),
      );
    } else {
      _items.remove(productId);
    }
    
    notifyListeners();
  }

  // Vaciar el carrito
  void clear() {
    _items.clear();
    notifyListeners();
  }
}