import 'package:flutter/material.dart';
import '../../features/products/domain/entities/product.dart';

/// Cart Item Model
/// موديل عنصر السلة
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get totalPrice => product.price * quantity;
}

/// Cart Service - Singleton
/// خدمة السلة - نمط Singleton
class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItem> _items = [];

  /// Get all cart items
  List<CartItem> get items => List.unmodifiable(_items);

  /// Get total items count
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  /// Get total price
  double get totalPrice => _items.fold(0, (sum, item) => sum + item.totalPrice);

  /// Check if cart is empty
  bool get isEmpty => _items.isEmpty;

  /// Add product to cart
  void addToCart(Product product, {int quantity = 1}) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  /// Remove product from cart
  void removeFromCart(Product product) {
    _items.removeWhere((item) => item.product.id == product.id);
    notifyListeners();
  }

  /// Update quantity
  void updateQuantity(Product product, int quantity) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      if (quantity <= 0) {
        _items.removeAt(existingIndex);
      } else {
        _items[existingIndex].quantity = quantity;
      }
      notifyListeners();
    }
  }

  /// Increment quantity
  void incrementQuantity(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      _items[existingIndex].quantity++;
      notifyListeners();
    }
  }

  /// Decrement quantity
  void decrementQuantity(Product product) {
    final existingIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingIndex >= 0) {
      if (_items[existingIndex].quantity > 1) {
        _items[existingIndex].quantity--;
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  /// Clear cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  /// Get quantity for a product
  int getQuantity(Product product) {
    final item = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );
    return item.quantity;
  }

  /// Check if product is in cart
  bool isInCart(Product product) {
    return _items.any((item) => item.product.id == product.id);
  }
}
