import 'package:flutter/material.dart';
import '../models/cart_model.dart';
import '../services/firebase_service.dart';

class CartController extends ChangeNotifier {
  final FirebaseService _firebase = FirebaseService();

  Map<String, CartItemModel> _items = {};
  String? _userId;
  bool _isLoading = false;

  Map<String, CartItemModel> get items => _items;
  bool get isLoading => _isLoading;

  int get itemCount {
    int total = 0;
    for (final cartItem in _items.values) {
      total += cartItem.quantity;
    }
    return total;
  }

  /// Bind cart to a user (loads from Firestore) or clear on logout.
  Future<void> bindUser(String? userId) async {
    if (_userId == userId) return;
    _userId = userId;
    if (userId == null) {
      _items = {};
      notifyListeners();
      return;
    }
    await _loadFromFirestore(userId);
  }

  Future<void> _loadFromFirestore(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final loaded = await _firebase.loadCart(userId);
      _items = {for (final item in loaded) item.productId: item};
    } catch (_) {
      // Keep local cart if load fails
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final userId = _userId;
    if (userId == null) return;
    try {
      await _firebase.saveCart(userId, _items.values.toList());
    } catch (_) {
      // UI stays responsive; cart remains in memory
    }
  }

  void addItem(String productId) {
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItemModel(
          productId: existingCartItem.productId,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items[productId] = CartItemModel(
        productId: productId,
        quantity: 1,
      );
    }
    notifyListeners();
    _persist();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
    _persist();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItemModel(
          productId: existingCartItem.productId,
          quantity: quantity,
        ),
      );
      notifyListeners();
      _persist();
    }
  }

  void clearCart() {
    _items = {};
    notifyListeners();
    _persist();
  }
}
