// Unit tests for CartProvider's pure logic: getCartTotal, areAllSelected,
// selectedCount, and selectedItems. These operate only on in-memory state
// (via setCartForTesting) and never touch Firebase, so they run fast and
// don't need any emulator or mocking setup.
import 'package:flutter_test/flutter_test.dart';
import 'package:morden_ecommerce_app/models/cart_item.dart';
import 'package:morden_ecommerce_app/models/product.dart';
import 'package:morden_ecommerce_app/providers/cart_provider.dart';

CartItem _item({
  required String id,
  required String productId,
  int quantity = 1,
  bool isSelected = true,
}) {
  return CartItem(
    cartItemId: id,
    productId: productId,
    quantity: quantity,
    isSelected: isSelected,
  );
}

ProductModel _product({required String id, double price = 0, int stock = 10}) {
  return ProductModel(
    productId: id,
    name: 'Product $id',
    description: '',
    price: price,
    stock: stock,
    imagePath: '',
  );
}

void main() {
  group('CartProvider.areAllSelected', () {
    test('returns false for an empty cart', () {
      final provider = CartProvider();
      provider.setCartForTesting([]);

      expect(provider.areAllSelected(), isFalse);
    });

    test('returns true when every item is selected', () {
      final provider = CartProvider();
      provider.setCartForTesting([
        _item(id: 'c1', productId: 'p1', isSelected: true),
        _item(id: 'c2', productId: 'p2', isSelected: true),
      ]);

      expect(provider.areAllSelected(), isTrue);
    });

    test('returns false when only some items are selected', () {
      final provider = CartProvider();
      provider.setCartForTesting([
        _item(id: 'c1', productId: 'p1', isSelected: true),
        _item(id: 'c2', productId: 'p2', isSelected: false),
      ]);

      expect(provider.areAllSelected(), isFalse);
    });
  });

  group('CartProvider.selectedCount', () {
    test('returns 0 for an empty cart', () {
      final provider = CartProvider();
      provider.setCartForTesting([]);

      expect(provider.selectedCount(), 0);
    });

    test('counts only selected items', () {
      final provider = CartProvider();
      provider.setCartForTesting([
        _item(id: 'c1', productId: 'p1', isSelected: true),
        _item(id: 'c2', productId: 'p2', isSelected: false),
        _item(id: 'c3', productId: 'p3', isSelected: true),
      ]);

      expect(provider.selectedCount(), 2);
    });
  });

  group('CartProvider.selectedItems', () {
    test('returns only the items marked as selected', () {
      final provider = CartProvider();
      final selected = _item(id: 'c1', productId: 'p1', isSelected: true);
      final unselected = _item(id: 'c2', productId: 'p2', isSelected: false);
      provider.setCartForTesting([selected, unselected]);

      expect(provider.selectedItems, [selected]);
    });

    test('returns an empty list when nothing is selected', () {
      final provider = CartProvider();
      provider.setCartForTesting([
        _item(id: 'c1', productId: 'p1', isSelected: false),
      ]);

      expect(provider.selectedItems, isEmpty);
    });
  });

  group('CartProvider.getCartTotal', () {
    test('returns 0 for an empty cart', () {
      final provider = CartProvider();
      provider.setCartForTesting([]);

      expect(provider.getCartTotal([]), 0);
    });

    test('sums price * quantity for selected items only', () {
      final provider = CartProvider();
      provider.setCartForTesting([
        _item(id: 'c1', productId: 'p1', quantity: 2, isSelected: true),
        _item(id: 'c2', productId: 'p2', quantity: 1, isSelected: false),
      ]);
      final products = [
        _product(id: 'p1', price: 1000),
        _product(id: 'p2', price: 500),
      ];

      // Only p1 is selected: 2 * 1000 = 2000. p2 is ignored despite
      // being in the cart, because isSelected is false.
      expect(provider.getCartTotal(products), 2000);
    });

    test('sums multiple selected items correctly', () {
      final provider = CartProvider();
      provider.setCartForTesting([
        _item(id: 'c1', productId: 'p1', quantity: 2, isSelected: true),
        _item(id: 'c2', productId: 'p2', quantity: 3, isSelected: true),
      ]);
      final products = [
        _product(id: 'p1', price: 1000),
        _product(id: 'p2', price: 500),
      ];

      // 2*1000 + 3*500 = 3500
      expect(provider.getCartTotal(products), 3500);
    });

    test('treats a cart item with no matching product as price 0', () {
      final provider = CartProvider();
      provider.setCartForTesting([
        _item(
          id: 'c1',
          productId: 'missing-product',
          quantity: 5,
          isSelected: true,
        ),
      ]);

      // firstWhere's orElse falls back to a zero-price placeholder
      // product, so the total contribution from this item is 0 rather
      // than throwing.
      expect(provider.getCartTotal([]), 0);
    });
  });
}
