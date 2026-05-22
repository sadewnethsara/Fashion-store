import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'controllers/auth_controller.dart';
import 'controllers/cart_controller.dart';
import 'controllers/order_controller.dart';
import 'controllers/product_controller.dart';
import 'controllers/user_controller.dart';
import 'controllers/wishlist_controller.dart';
import 'core/theme_controller.dart';

/// Shared Provider list for [main.dart] and widget tests.
List<SingleChildWidget> createAppProviders() {
  return [
    ChangeNotifierProvider<AuthController>(
      create: (_) => AuthController(),
    ),
    ChangeNotifierProvider<ProductController>(
      create: (_) => ProductController(),
    ),
    ChangeNotifierProvider<CartController>(
      create: (_) => CartController(),
    ),
    ChangeNotifierProvider<OrderController>(
      create: (_) => OrderController(),
    ),
    ChangeNotifierProvider<UserController>(
      create: (_) => UserController(),
    ),
    ChangeNotifierProvider<ThemeController>(
      create: (_) => ThemeController(),
    ),
    ChangeNotifierProvider<WishlistController>(
      create: (_) => WishlistController(),
    ),
  ];
}
