import 'package:facebook_app_events/facebook_app_events.dart';

class AnalyticsService {
  static final FacebookAppEvents _fb = FacebookAppEvents();

  // 1) app_open (Meta only)
  static Future<void> logAppOpen() async {
    try {
      await _fb.logEvent(name: 'app_open', parameters: {});
      print('[Meta] app_open logged');
    } catch (e, s) {
      print('logAppOpen error: $e\n$s');
    }
  }

  // 2) sign_up(method) (Meta only)
  static Future<void> logSignUp({required String method}) async {
    try {
      await _fb.logEvent(
        name: 'sign_up',
        parameters: {
          'method': method,
        },
      );
      print('[Meta] sign_up logged, method=$method');
    } catch (e, s) {
      print('logSignUp error: $e\n$s');
    }
  }

  // 3) add_to_cart(item_id, vendor_name, price, quantity) (Meta only)
  static Future<void> logAddToCart({
    required String itemId,
    required String vendorName,
    required double price,
    required int quantity,
  }) async {
    try {
      await _fb.logEvent(
        name: 'add_to_cart',
        parameters: {
          'item_id': itemId,
          'vendor_name': vendorName,
          'price': price,
          'quantity': quantity,
        },
      );
      print('[Meta] add_to_cart logged item_id=$itemId vendor_name=$vendorName price=$price qty=$quantity');
    } catch (e, s) {
      print('logAddToCart error: $e\n$s');
    }
  }

  // 4) begin_checkout(cart_value, item_ids, payment_method) (Meta only)
  static Future<void> logBeginCheckout({
    required double cartValue,
    required List<String> itemIds,
    required String paymentMethod,
  }) async {
    try {
      await _fb.logEvent(
        name: 'begin_checkout',
        parameters: {
          'cart_value': cartValue,
          'item_ids': itemIds,
          'payment_method': paymentMethod,
        },
      );
      print('[Meta] begin_checkout logged cart_value=$cartValue item_ids=$itemIds payment_method=$paymentMethod');
    } catch (e, s) {
      print('logBeginCheckout error: $e\n$s');
    }
  }

  // 5) purchase(transaction_id, value, currency='INR', items) (Meta only)
  static Future<void> logPurchase({
    required String transactionId,
    required double value,
    String currency = 'INR',
    required List<Map<String, dynamic>> items,
  }) async {
    try {
      await _fb.logEvent(
        name: 'purchase',
        parameters: {
          'transaction_id': transactionId,
          'value': value,
          'currency': currency,
          'items': items,
        },
      );
      print('[Meta] purchase logged txn=$transactionId value=$value $currency items_count=${items.length}');
    } catch (e, s) {
      print('logPurchase error: $e\n$s');
    }
  }
}