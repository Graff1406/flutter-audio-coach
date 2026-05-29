import 'package:flutter/foundation.dart';

class RevenueCatConfig {
  const RevenueCatConfig._();

  static const entitlementId = 'premium';
  static const androidApiKey = 'test_MdFkWWfdWTTqrOyehmJJsMBfFVi';
  static const iosApiKey = 'test_MdFkWWfdWTTqrOyehmJJsMBfFVi';

  static String? get currentApiKey {
    if (kIsWeb) {
      return null;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidApiKey;
      case TargetPlatform.iOS:
        return iosApiKey;
      default:
        return null;
    }
  }
}
