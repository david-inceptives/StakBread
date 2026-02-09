import 'package:get/get.dart';
import 'package:stakBread/screen/store_screen/store_screen_controller.dart';

class CartItem {
  final StoreProduct product;
  int quantity;
  final String? variantText; // e.g. "Size: M", "Color: Black"

  CartItem({required this.product, this.quantity = 1, this.variantText});

  double get linePrice {
    final p = _parsePrice(product.price);
    return p * quantity;
  }

  static double _parsePrice(String? priceStr) {
    if (priceStr == null || priceStr.isEmpty) return 0;
    final cleaned = priceStr.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0;
  }
}

class CartController extends GetxController {
  final RxList<CartItem> items = <CartItem>[].obs;

  static const double deliveryFee = 10.0;

  int get totalItemCount => items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotal => items.fold(0.0, (sum, e) => sum + e.linePrice);

  double get total => subtotal + deliveryFee;

  void addItem(StoreProduct product, {int quantity = 1, String? variantText}) {
    final existing = items.indexWhere((e) => e.product.id == product.id);
    if (existing >= 0) {
      items[existing].quantity += quantity;
      items.refresh();
    } else {
      items.add(CartItem(product: product, quantity: quantity, variantText: variantText));
    }
  }

  void removeItem(String productId) {
    items.removeWhere((e) => e.product.id == productId);
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final i = items.indexWhere((e) => e.product.id == productId);
    if (i >= 0) {
      items[i].quantity = quantity;
      items.refresh();
    }
  }

  void incrementQuantity(String productId) {
    final i = items.indexWhere((e) => e.product.id == productId);
    if (i >= 0) {
      items[i].quantity++;
      items.refresh();
    }
  }

  void decrementQuantity(String productId) {
    final i = items.indexWhere((e) => e.product.id == productId);
    if (i >= 0) {
      if (items[i].quantity <= 1) {
        removeItem(productId);
      } else {
        items[i].quantity--;
        items.refresh();
      }
    }
  }
}
