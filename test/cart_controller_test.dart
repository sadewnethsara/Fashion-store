import 'package:flutter_test/flutter_test.dart';
import 'package:fashion_store/controllers/cart_controller.dart';
import 'helpers/mock_firebase.dart';

void main() {
  setUpAll(() async {
    await setupFirebaseForTests();
  });

  group('CartController', () {
    late CartController cart;

    setUp(() {
      cart = CartController();
    });

    test('starts empty', () {
      expect(cart.itemCount, 0);
      expect(cart.items, isEmpty);
    });

    test('addItem increases count', () {
      cart.addItem('p1');
      expect(cart.itemCount, 1);
      cart.addItem('p1');
      expect(cart.itemCount, 2);
    });

    test('removeItem clears product', () {
      cart.addItem('p1');
      cart.removeItem('p1');
      expect(cart.items, isEmpty);
    });

    test('updateQuantity changes amount', () {
      cart.addItem('p1');
      cart.updateQuantity('p1', 5);
      expect(cart.items['p1']!.quantity, 5);
    });

    test('updateQuantity to zero removes item', () {
      cart.addItem('p1');
      cart.updateQuantity('p1', 0);
      expect(cart.items, isEmpty);
    });

    test('clearCart removes all items', () {
      cart.addItem('p1');
      cart.addItem('p2');
      cart.clearCart();
      expect(cart.items, isEmpty);
    });
  });
}
