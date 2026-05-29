import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_config.dart';

class SubscriptionService extends ChangeNotifier {
  bool _configured = false;
  bool _premium = false;
  String? _lastError;
  String? _currentUserId;

  bool get configured => _configured;
  bool get premium => _premium;
  String? get lastError => _lastError;

  Future<void> configure() async {
    final apiKey = RevenueCatConfig.currentApiKey;
    if (apiKey == null || _configured) {
      return;
    }

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.warn);
      await Purchases.configure(PurchasesConfiguration(apiKey));
      Purchases.addCustomerInfoUpdateListener(_syncCustomerInfo);
      _configured = true;
      await refresh();
    } on PlatformException catch (error) {
      _lastError = error.message ?? error.code;
      notifyListeners();
    } catch (error) {
      _lastError = error.toString();
      notifyListeners();
    }
  }

  Future<void> identify(String userId) async {
    if (!_configured || _currentUserId == userId) {
      return;
    }

    try {
      final result = await Purchases.logIn(userId);
      _currentUserId = userId;
      _syncCustomerInfo(result.customerInfo);
    } on PlatformException catch (error) {
      _lastError = error.message ?? error.code;
      notifyListeners();
    }
  }

  Future<void> reset() async {
    if (!_configured) {
      return;
    }

    try {
      await Purchases.logOut();
      _currentUserId = null;
      _premium = false;
      notifyListeners();
    } on PlatformException catch (error) {
      _lastError = error.message ?? error.code;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (!_configured) {
      return;
    }

    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _syncCustomerInfo(customerInfo);
    } on PlatformException catch (error) {
      _lastError = error.message ?? error.code;
      notifyListeners();
    }
  }

  Future<void> restorePurchases() async {
    if (!_configured) {
      return;
    }

    try {
      final customerInfo = await Purchases.restorePurchases();
      _syncCustomerInfo(customerInfo);
    } on PlatformException catch (error) {
      _lastError = error.message ?? error.code;
      notifyListeners();
    }
  }

  void _syncCustomerInfo(CustomerInfo customerInfo) {
    final entitlement =
        customerInfo.entitlements.all[RevenueCatConfig.entitlementId];
    _premium = entitlement?.isActive ?? false;
    _lastError = null;
    notifyListeners();
  }
}
