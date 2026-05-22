import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/cart_controller.dart';

/// Loads and persists the cart when the authenticated user changes.
class CartSync extends StatefulWidget {
  final Widget child;

  const CartSync({super.key, required this.child});

  @override
  State<CartSync> createState() => _CartSyncState();
}

class _CartSyncState extends State<CartSync> {
  String? _boundUserId;

  @override
  Widget build(BuildContext context) {
    final userId = context.watch<AuthController>().currentUser?.id;
    if (userId != _boundUserId) {
      _boundUserId = userId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<CartController>().bindUser(userId);
      });
    }
    return widget.child;
  }
}
