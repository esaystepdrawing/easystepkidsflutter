import 'dart:async';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Wraps in_app_purchase 3.x.
///
/// Note: `queryPastPurchases()` no longer exists in in_app_purchase 3.x.
/// Ownership is discovered by calling [restorePurchases] and listening to
/// [InAppPurchase.purchaseStream]; the result is cached in SharedPreferences.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;

  /// Must match the product ID created in Google Play Console.
  static const String unlockProductId = 'com.easystepkids.app';

  static const String _prefsKey = 'unlocked_all_languages';

  void Function(bool isUnlocked)? _onPurchaseUpdated;

  factory PurchaseService() => _instance;

  PurchaseService._internal();

  Future<void> initialize() async {
    if (_isInitialized) return;

    final available = await _iap.isAvailable();
    if (!available) {
      // ignore: avoid_print
      print('In-app purchases unavailable on this device.');
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      _handlePurchaseUpdate,
      onError: (Object error) {
        // ignore: avoid_print
        print('Purchase stream error: $error');
      },
    );

    _isInitialized = true;
  }

  void setPurchaseCallback(void Function(bool isUnlocked) callback) {
    _onPurchaseUpdated = callback;
  }

  Future<ProductDetails?> fetchProduct() async {
    await initialize();

    try {
      final ProductDetailsResponse response =
      await _iap.queryProductDetails(<String>{unlockProductId});

      if (response.error != null) {
        // ignore: avoid_print
        print('queryProductDetails error: ${response.error}');
      }
      if (response.notFoundIDs.isNotEmpty) {
        // ignore: avoid_print
        print('Product IDs not found: ${response.notFoundIDs}');
      }
      if (response.productDetails.isNotEmpty) {
        return response.productDetails.first;
      }
    } catch (e) {
      // ignore: avoid_print
      print('fetchProduct failed: $e');
    }
    return null;
  }

  Future<void> purchaseProduct() async {
    await initialize();

    final product = await fetchProduct();
    if (product == null) {
      throw Exception('Product $unlockProductId not found in the store.');
    }

    // in_app_purchase 3.x takes a PurchaseParam, not productDetails directly.
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  /// Reads the cached entitlement written by [_handlePurchaseUpdate].
  Future<bool> isUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// Asks the store to re-deliver owned purchases. Results arrive
  /// asynchronously on [InAppPurchase.purchaseStream].
  Future<void> restorePurchases() async {
    await initialize();
    await _iap.restorePurchases();
  }

  Future<void> _setUnlocked(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, value);
    _onPurchaseUpdated?.call(value);
  }

  Future<void> _handlePurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      switch (purchase.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (purchase.productID == unlockProductId) {
            await _setUnlocked(true);
          }
          break;
        case PurchaseStatus.error:
        // ignore: avoid_print
          print('Purchase error: ${purchase.error}');
          break;
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }

      // Required: acknowledge the purchase or Google will refund it.
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }
}