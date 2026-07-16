# Store URLs & Mandatory Update – Implementation Guide (New Setup)

This document describes how to implement **Play Store / App Store URLs** and **mandatory update** behavior in a new Flutter (GetX) project. Use it as a step-by-step guide.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Dependencies](#2-dependencies)
3. [Store Constants (Single Source of Truth)](#3-store-constants-single-source-of-truth)
4. [Update Checker Service](#4-update-checker-service)
5. [Mandatory Update Dialog Widget](#5-mandatory-update-dialog-widget)
6. [Splash Integration](#6-splash-integration)
7. [Rate Us (Profile / Me Screen)](#7-rate-us-profile--me-screen)
8. [Firebase Dynamic Links (Share)](#8-firebase-dynamic-links-share)
9. [Lottie Assets for Dialog](#9-lottie-assets-for-dialog)
10. [Implementation Checklist](#10-implementation-checklist)

---

## 1. Overview

| Feature | Where used | Purpose |
|--------|------------|---------|
| **Mandatory update** | Splash → Update checker → Dialog | If store version > app version, show non-dismissible dialog and open store on "Update Now". |
| **Rate us** | Profile / Me screen | "Rate us" opens Play Store or App Store listing. |
| **Dynamic Links (share)** | Home details / share flow | `packageName` (Android) and `appStoreId` (iOS) for Firebase Dynamic Links. |
| **Dialog assets** | Mandatory update dialog | Lottie JSON paths for App Store / Play Store icons (UI only). |

**Replace in new setup:**

- `com.good.grab` → your Android **package name**
- `6451374378` → your iOS **App Store ID** (from App Store Connect)
- `good-to-grab` → your **App Store slug** (from the App Store URL)
- App name, theme colors, and route names as per your app

---

## 2. Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  # Existing
  get: ^4.6.5
  url_launcher: ^6.3.0
  package_info_plus: ^4.0.2
  lottie: ^2.4.0
  http: ^1.2.0

  # For mandatory update (version check + store link on Android)
  new_version_plus: ^0.0.10
```

- **package_info_plus**: Read current app version.
- **new_version_plus**: On Android, fetch Play Store version and get Play Store URL (`appStoreLink`).
- **http**: For iOS iTunes lookup API.
- **url_launcher**: Open store URLs in browser/app store.
- **lottie**: Optional Lottie animation in the update dialog.

Run:

```bash
flutter pub get
```

---

## 3. Store Constants (Single Source of Truth)

Create a single place for store IDs and URLs so **update checker**, **rate us**, and **Dynamic Links** all use the same values.

**File:** `lib/infrastructure/constants/store_constants.dart` (create if missing)

```dart
/// Single source of truth for Play Store / App Store identifiers and URLs.
/// Use these in: update checker, rate-us, Firebase Dynamic Links.
class StoreConstants {
  StoreConstants._();

  // --- Android ---
  /// Android application ID (package name), e.g. com.example.app
  static const String androidPackageName = 'com.good.grab';

  /// Full Play Store URL for your app (used for rate-us and fallback).
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.good.grab';

  // --- iOS ---
  /// iOS App Store numeric ID (from App Store Connect / URL).
  static const String iosAppId = '6451374378';

  /// App Store slug (from URL: apps.apple.com/.../app/<slug>/id...).
  static const String iosAppSlug = 'good-to-grab';

  /// Country code for App Store URL (in, gb, us, etc.). Use one or add more.
  static const String iosAppStoreCountry = 'in';

  /// Full App Store URL for your app.
  static String get iosAppStoreUrl =>
      'https://apps.apple.com/$iosAppStoreCountry/app/$iosAppSlug/id$iosAppId';

  /// Optional: different country for "rate us" (e.g. gb). Else use iosAppStoreUrl.
  static String get iosAppStoreUrlForRating =>
      'https://apps.apple.com/gb/app/$iosAppSlug/id$iosAppId';
}
```

**In a new project:** Replace `com.good.grab`, `6451374378`, and `good-to-grab` with your app’s values.

---

## 4. Update Checker Service

This service compares the **current app version** with the **store version** and, if the store is newer, shows a mandatory update dialog and opens the store when the user taps "Update Now".

**File:** `lib/infrastructure/update/update_checker.dart`

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../infrastructure/constants/store_constants.dart';
import '../../presentation/widgets/mandatory_update_dialog.dart';

class UpdateCheckerService {
  static final UpdateCheckerService _instance = UpdateCheckerService._internal();
  factory UpdateCheckerService() => _instance;
  UpdateCheckerService._internal();

  bool _dialogShown = false;

  Future<bool> checkAndShowMandatoryUpdate() async {
    if (_dialogShown) return true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      String? storeVersion;
      String? storeUrl;

      if (Platform.isIOS) {
        storeVersion = await _getIOSStoreVersion();
        storeUrl = StoreConstants.iosAppStoreUrl;
      } else if (Platform.isAndroid) {
        final newVersion = NewVersionPlus(androidId: StoreConstants.androidPackageName);
        final VersionStatus? status = await newVersion.getVersionStatus();
        if (status != null) {
          storeVersion = status.storeVersion;
          storeUrl = status.appStoreLink; // Play Store URL from package
        }
      }

      if (storeVersion == null) {
        debugPrint('⚠️ Store version not found.');
        return false;
      }

      debugPrint('🟢 Current version: $currentVersion');
      debugPrint('🟢 Store version: $storeVersion');

      if (_isStoreVersionNewer(currentVersion, storeVersion)) {
        _dialogShown = true;
        await _showMandatoryDialog(storeUrl!);
        return true;
      }
    } catch (e) {
      debugPrint('❌ Update check error: $e');
    }

    return false;
  }

  Future<String?> _getIOSStoreVersion() async {
    try {
      final urls = [
        'https://itunes.apple.com/lookup?id=${StoreConstants.iosAppId}&country=${StoreConstants.iosAppStoreCountry}',
        'https://itunes.apple.com/lookup?id=${StoreConstants.iosAppId}&country=us',
        'https://itunes.apple.com/lookup?id=${StoreConstants.iosAppId}',
      ];

      for (final url in urls) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['resultCount'] > 0) {
            return jsonResponse['results'][0]['version'];
          }
        }
      }
    } catch (e) {
      debugPrint('Store version fetch error (iOS): $e');
    }
    return null;
  }

  bool _isStoreVersionNewer(String current, String store) {
    try {
      List<int> parse(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = parse(current);
      final storeParts = parse(store);

      for (int i = 0; i < storeParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (storeParts[i] > currentParts[i]) return true;
        if (storeParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint('Version comparison error: $e');
      return false;
    }
  }

  Future<void> _showMandatoryDialog(String storeUrl) async {
    await Get.dialog(
      MandatoryUpdateDialog(
        onUpdateNow: () async {
          final uri = Uri.parse(storeUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('⚠️ Could not open store URL.');
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  void reset() => _dialogShown = false;
}
```

**Behavior:**

- **iOS:** Version from iTunes lookup; store URL from `StoreConstants.iosAppStoreUrl`.
- **Android:** Version and Play Store URL from `new_version_plus` (using `StoreConstants.androidPackageName`).
- If store version is newer, a non-dismissible dialog is shown; "Update Now" opens the store via `url_launcher`.

---

## 5. Mandatory Update Dialog Widget

**File:** `lib/presentation/widgets/mandatory_update_dialog.dart`

```dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';

class MandatoryUpdateDialog extends StatelessWidget {
  final VoidCallback onUpdateNow;

  const MandatoryUpdateDialog({super.key, required this.onUpdateNow});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: UnconstrainedBox(
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          elevation: 10,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: SizedBox(
              width: Get.width * 0.78,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.system_update,
                          color: ColorsTheme.colPrimary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Update Required',
                        style: semiBoldTextStyle(
                            fontSize: dimen16, color: ColorsTheme.colBlack),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 60,
                    child: Lottie.asset(
                      Platform.isIOS ? Res.appstore : Res.playstore,
                      repeat: true,
                      animate: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A newer version of the app is available. Please update to continue using the app.',
                    textAlign: TextAlign.center,
                    style: regularTextStyle(
                        fontSize: dimen14, color: ColorsTheme.colBlack),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: onUpdateNow,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: ColorsTheme.colPrimary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'Update Now',
                              style: mediumTextStyle(
                                  fontSize: dimen15,
                                  color: ColorsTheme.colWhite),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

**Notes:**

- Replace `ColorsTheme`, `semiBoldTextStyle`, `regularTextStyle`, `mediumTextStyle`, `dimen*` with your theme/res names if different.
- `Res.appstore` and `Res.playstore` must point to Lottie JSON paths (see [Section 9](#9-lottie-assets-for-dialog)).

---

## 6. Splash Integration

Run the mandatory update check **before** navigating to home or deep link. If an update is required, show the dialog and do not navigate.

**File:** `lib/presentation/splash/splash_controller.dart` (or wherever splash logic lives)

```dart
import '../../infrastructure/update/update_checker.dart';

// Inside your method that runs after splash animation (e.g. changeScreen / onSplashComplete):

changeScreen() async {
  // 1. Mandatory update check first
  final bool updateDialogShown = await UpdateCheckerService().checkAndShowMandatoryUpdate();
  if (updateDialogShown) {
    return; // User must update; do not navigate
  }

  // 2. Then handle deep links, login, etc.
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();
  if (initialLink != null) {
    DynamicLinkService().initDynamicLinks(initialLink);
  } else {
    var isLoggedIn = await PrefManager.getBool(AppConstants.loggedIn);
    if (isLoggedIn) {
      navigateScreen();
    } else {
      Get.offNamed(Routes.intro);
    }
  }
}
```

**Important:** Call `checkAndShowMandatoryUpdate()` **before** any navigation or deep-link handling so the update dialog blocks the rest of the flow.

---

## 7. Rate Us (Profile / Me Screen)

Use the same store constants so "Rate us" opens the correct store listing.

**File:** `lib/presentation/home/views/me_view.dart` (or your profile screen)

```dart
import 'package:url_launcher/url_launcher.dart';
import '../../infrastructure/constants/store_constants.dart';

// In build(), for the "Rate us" / "Enjoy App! Rate us" tile:

GestureDetector(
  onTap: () async {
    if (Platform.isAndroid) {
      await launchUrl(
        Uri.parse(StoreConstants.playStoreUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      await launchUrl(
        Uri.parse(StoreConstants.iosAppStoreUrlForRating),
        mode: LaunchMode.externalApplication,
      );
    }
  },
  child: Container(
    margin: const EdgeInsets.only(left: 18, right: 18, bottom: 24),
    child: commonBodyWidget(
      image: Res.icProfileRating,
      title: 'Enjoy App! Rate us'.tr,
    ),
  ),
),
```

Add `import 'dart:io';` if you use `Platform.isAndroid`. Alternatively you can use your existing `CommonFunction.getDeviceType()` and branch on `"android"` vs else and keep using `StoreConstants.playStoreUrl` and `StoreConstants.iosAppStoreUrlForRating`.

---

## 8. Firebase Dynamic Links (Share)

When building share links, use the same package name and App Store ID from `StoreConstants` so that when the link is opened on a device, the correct store (or app) is used.

**File:** Where you build `DynamicLinkParameters` (e.g. `lib/presentation/home-details/home_details_page.dart`)

```dart
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';
import '../../infrastructure/constants/store_constants.dart';

// When user taps Share:

FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
var parameters = DynamicLinkParameters(
  uriPrefix: 'https://yourdomain',  // Your Dynamic Links prefix
  link: Uri.parse('https://yourdomain.com/path?resId=$resId&currency=$currency'),
  androidParameters: const AndroidParameters(
    packageName: StoreConstants.androidPackageName,
  ),
  socialMetaTagParameters: SocialMetaTagParameters(
    title: restaurantName,
    imageUrl: Uri.parse(imageUrl ?? ''),
  ),
  iosParameters: IOSParameters(
    bundleId: StoreConstants.androidPackageName, // or a separate iosBundleId constant
    appStoreId: StoreConstants.iosAppId,
  ),
);
var shortLink = await dynamicLinks.buildShortLink(
  parameters,
  shortLinkType: ShortDynamicLinkType.unguessable,
);
Share.share(shortLink.shortUrl.toString());
```

Use a separate `iosBundleId` in `StoreConstants` if your iOS bundle ID differs from the Android package name.

---

## 9. Lottie Assets for Dialog

The mandatory update dialog shows a small Lottie (App Store or Play Store icon). You need two JSON assets.

**In `pubspec.yaml`:**

```yaml
flutter:
  assets:
    - assets/
    - assets/appstore.json
    - assets/playstore.json
```

**In your resource file (e.g. `lib/res.dart`):**

```dart
static const String appstore = "assets/appstore.json";
static const String playstore = "assets/playstore.json";
```

Place `appstore.json` and `playstore.json` in `assets/`. You can download free store-icon Lottie files from LottieFiles or use simple placeholder JSON. If you prefer not to use Lottie, replace the `Lottie.asset` block with an `Icon` or `Image.asset`.

---

## 10. Implementation Checklist

Use this order in a **new setup**:

| Step | Task | File(s) |
|------|------|--------|
| 1 | Add dependencies | `pubspec.yaml` → `flutter pub get` |
| 2 | Create store constants | `lib/infrastructure/constants/store_constants.dart` |
| 3 | Create update checker | `lib/infrastructure/update/update_checker.dart` |
| 4 | Create mandatory update dialog | `lib/presentation/widgets/mandatory_update_dialog.dart` |
| 5 | Add Lottie assets and res entries | `assets/appstore.json`, `assets/playstore.json`, `res.dart` |
| 6 | Call update check from splash | Splash controller (before navigation) |
| 7 | Add "Rate us" using store constants | Profile / Me view |
| 8 | Use store constants in Dynamic Links | Share flow (e.g. home details) |

**Values to replace in new project:**

- `StoreConstants`: `androidPackageName`, `iosAppId`, `iosAppSlug`, `iosAppStoreCountry`, and optionally `iosAppStoreUrlForRating` (e.g. different country).
- Theme/style names in `MandatoryUpdateDialog` if your app uses different naming.
- `uriPrefix` and `link` in Dynamic Links for your domain and path.

After this, **Play Store URL** and **App Store URL** are used in three places: **mandatory update**, **rate us**, and **Dynamic Links**, with a single source of truth in `StoreConstants`.
