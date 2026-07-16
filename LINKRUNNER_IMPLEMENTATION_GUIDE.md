# LinkRunner Implementation Guide — Good To Grab (g2g-customer-app)

This document describes the **entire LinkRunner integration** in this project so you can replicate it in a fresh Flutter app using the same architecture. LinkRunner is used for **attribution** (install/source tracking), **Meta (Facebook) view-through conversions**, and optional **deeplink handling** from attribution data.

---

## 1. Architecture Overview

| Component | Purpose | Where it lives |
|-----------|---------|----------------|
| **SDK init** | Initialize with project token + platform-specific secret/key; enable Meta view-through | `lib/initializer.dart` — `_initLinkRunner()` |
| **User data** | Identify logged-in user for attribution (id, name, email, phone) | `lib/initializer.dart` — `_handleLinkRunnerUserData()` |
| **Deep link handler** | Optional: route from LinkRunner attribution deeplink (e.g. `resId`, `currency` → homeDetails) | `lib/infrastructure/linkrunner/linkrunner_service.dart` |
| **Constants** | Token, Android/iOS secret keys and key IDs | `lib/infrastructure/constants/app_constants.dart` |
| **Android** | Backup rules (from SDK), Facebook App ID for LinkRunner, intent-filters for LinkRunner subdomain/scheme | `android/app/src/main/AndroidManifest.xml`, `res/values/strings.xml` |
| **iOS** | Min version 15.0, ATT description; URL schemes overlap with deep linking | `ios/Podfile`, `ios/Runner/Info.plist` |

**Initialization order (in `Initializer.init()`):**

1. Environment / BuildConfig  
2. **LinkRunner** — `_initLinkRunner()` then `_handleLinkRunnerUserData()`  
3. Firebase, Crashlytics, Analytics, Notifications  

User data is set **once at startup** if a user is already logged in (from PrefManager). The project does **not** call `LinkRunner().signup()` on first sign-up; it only uses `setUserData()` for existing users. You can add `signup()` after onboarding if you want LinkRunner to track new signups.

---

## 2. Dependencies (pubspec.yaml)

```yaml
dependencies:
  linkrunner: ^3.6.2
```

- **facebook_app_events** is separate; LinkRunner uses the **Facebook App ID** from the app (Android manifest / iOS Info.plist) for Meta view-through attribution. You don’t have to use `facebook_app_events` for LinkRunner, but this app uses both.

---

## 3. Constants (credentials)

**File: `lib/infrastructure/constants/app_constants.dart`**

```dart
// LinkRunner — from https://dashboard.linkrunner.io/settings?s=sdk-signing
static const String linkrunnerToken = 'gWsDHO9F5aW5YLFgKGhqoghG';
static const String linkrunnerSecretKey = '2e768f22-5550-43bd-839d-3120dc953e89';
static const String linkrunnerKeyId = '019b7da1-0b1d-7ff1-92b3-4cbe1e9d53f1';
static const String linkrunnerIOSSecretKey = '4d5aee27-0372-4dcd-a346-c02eab03d5b6';
static const String linkrunnerIOSKeyId = '019b7da2-eccb-7993-b3ef-8d106fef626f';
```

- **linkrunnerToken** — Project token (same for both platforms).  
- **linkrunnerSecretKey** / **linkrunnerKeyId** — Android SDK signing.  
- **linkrunnerIOSSecretKey** / **linkrunnerIOSKeyId** — iOS SDK signing.  
- Get these from LinkRunner Dashboard → Settings → SDK Signing. Use your own values in a new project; do not commit production secrets to public repos.

---

## 4. Initialization

**File: `lib/initializer.dart`**

### 4.1 Imports

```dart
import 'dart:io';
import 'package:linkrunner/models/lr_user_data.dart';
import 'package:linkrunner/linkrunner.dart';
import 'infrastructure/constants/app_constants.dart';
import 'infrastructure/shared/pref_manager.dart';
import 'infrastructure/models/user_model.dart';
```

### 4.2 Init (platform-specific signing)

Called early in `Initializer.init()`, **before** Firebase:

```dart
static Future<void> _initLinkRunner() async {
  try {
    // Linkrunner SDK 3.6.2+ supports Meta view-through conversions
    // Meta install referrer is configured in AndroidManifest.xml
    // This enables attribution for installs where users view Meta ads but don't click
    await LinkRunner().init(
        AppConstants.linkrunnerToken,
        Platform.isIOS
            ? AppConstants.linkrunnerIOSSecretKey
            : AppConstants.linkrunnerSecretKey,
        Platform.isIOS
            ? AppConstants.linkrunnerIOSKeyId
            : AppConstants.linkrunnerKeyId,
        false, // disableIdfaCollection (Android: GAID still collected; iOS: IDFA if user allows ATT)
        false   // debug mode
    );

    debugPrint('[LinkRunner] Initialization successful');
    debugPrint('[LinkRunner] Meta view-through attribution enabled (SDK 3.6.2+)');
  } catch (e) {
    debugPrint('[LinkRunner] Initialization failed: $e');
  }
}
```

**Parameters (in order):**

1. **token** — Project token.  
2. **secretKey** — iOS secret key on iOS, Android secret key on Android.  
3. **keyId** — iOS key ID on iOS, Android key ID on Android.  
4. **disableIdfaCollection** — `false` = collect IDFA (iOS) when allowed; set `true` if you don’t want to collect (e.g. child app).  
5. **debug** — `false` for production.

Initialization does not return attribution; use `LinkRunner().getAttributionData()` when you need it (e.g. on splash or after init).

---

## 5. User data (setUserData)

**Same file: `lib/initializer.dart`**

Called right after `_initLinkRunner()` so that returning users are identified:

```dart
static Future<void> _handleLinkRunnerUserData() async {
  try {
    final user = await PrefManager.getUser();
    if (user != null) {
      await LinkRunner().setUserData(
        userData: LRUserData(
          id: user.id.toString(),
          name: user.username,
          email: user.email,
          phone: user.mobile,
          // Add additional fields if available, e.g., userCreatedAt: user.createdAt
        ),
      );
      debugPrint('LinkRunner user data set for existing user');
    }
  } catch (e) {
    debugPrint('Error setting LinkRunner user data: $e');
  }
}
```

- **LRUserData** is from `package:linkrunner/models/lr_user_data.dart`.  
- **id** is required; **name**, **email**, **phone** are optional but recommended for attribution and integrations.  
- Optional: **userCreatedAt**, **isFirstTimeUser**, **mixpanelDistinctId**, **amplitudeDeviceId**, **posthogDistinctId** if you use those platforms.

**When to call setUserData**

- This project calls it **once at app startup** if `PrefManager.getUser()` is non-null.  
- LinkRunner recommends calling it **each time the app opens and the user is logged in**. So you can also call it after login/signup when you save the user (e.g. in login/OTP/social success handlers) so the very first session after signup is also identified.

**Optional: signup() for new users**

- After first-time signup/onboarding, you can call `LinkRunner().signup(userData: LRUserData(...), data: {})` once. This project does not use `signup()`; it only uses `setUserData()` for existing users at startup.

---

## 6. Deep link from attribution (LinkRunnerService)

**File: `lib/infrastructure/linkrunner/linkrunner_service.dart`**

This service parses LinkRunner attribution **deeplink** (from `getAttributionData()`) and navigates to the same screen as Firebase Dynamic Links (homeDetails with `resId` and `currency`):

```dart
import 'package:get/get.dart';
import '../navigation/routes.dart';

class LinkRunnerService {
  Future<void> handleLinkRunnerDeepLink(
      Map<dynamic, dynamic> attributionData) async {
    if (!attributionData.containsKey('deeplink')) return;

    final String? deepLinkUrl = attributionData['deeplink'];
    if (deepLinkUrl == null || deepLinkUrl.isEmpty) return;

    final Uri uri = Uri.parse(deepLinkUrl);
    final String? resId = uri.queryParameters['resId'];
    final String? currency = uri.queryParameters['currency'];

    if (resId != null) {
      Get.offAllNamed(
        Routes.homeDetails,
        arguments: {
          'resId': int.parse(resId),
          'currency': currency,
          'type': 'deeplink',
        },
      );
    }
  }
}
```

**How to use it**

- **Not used from Splash in this project.** Splash only checks **Firebase Dynamic Links** `getInitialLink()`.  
- To use LinkRunner attribution deeplinks: after `LinkRunner().init()`, call `LinkRunner().getAttributionData()` (returns an object with `deeplink` and campaign data). If you want to route by that deeplink, convert the result to a map or read its `deeplink` field and call:

  ```dart
  final attribution = await LinkRunner().getAttributionData();
  // If attribution has deeplink and you want to open it:
  await LinkRunnerService().handleLinkRunnerDeepLink({
    'deeplink': attribution.deeplink,
  });
  ```

- You can do this on splash: e.g. if there is no Firebase initial link, optionally check LinkRunner attribution and, if it contains a deeplink, call `handleLinkRunnerDeepLink` instead of going to home/intro. This project leaves that optional; the service is ready for when you add that flow.

---

## 7. Android native configuration

### 7.1 Permissions

Already required for the app; LinkRunner also needs them:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

The LinkRunner SDK adds the **AD_ID** permission by default (for GAID). For child/family apps, see LinkRunner docs on disabling AAID and use `tools:node="remove"` for `com.google.android.gms.permission.AD_ID` if needed.

### 7.2 Backup configuration (install/reinstall accuracy)

In `android/app/src/main/AndroidManifest.xml`, on the `<application>` tag:

```xml
<application
    android:fullBackupContent="@xml/linkrunner_backup_descriptor"
    android:dataExtractionRules="@xml/linkrunner_backup_rules"
    ...>
```

- **linkrunner_backup_descriptor** and **linkrunner_backup_rules** are **provided by the LinkRunner plugin** (merged from the plugin’s resources). You do **not** create these files yourself; just reference them so the SDK can exclude its SharedPreferences from backup and get accurate new install vs reinstall detection.

### 7.3 Meta (Facebook) App ID for LinkRunner

LinkRunner uses the same Facebook App ID as your app for Meta view-through attribution. In this project:

**`android/app/src/main/res/values/strings.xml`:**

```xml
<string name="facebook_app_id">746836057691724</string>
<string name="facebook_client_token">e63f081dc4e3727b70ae462513551999</string>
```

**`AndroidManifest.xml` (inside `<application>`):**

```xml
<meta-data
    android:name="com.facebook.sdk.ApplicationId"
    android:value="@string/facebook_app_id" />
<meta-data
    android:name="com.linkrunner.FacebookApplicationId"
    android:value="@string/facebook_app_id" />
```

Use your own Meta App ID and client token in a new project. LinkRunner SDK 3.6.2+ reads the Facebook App ID from `com.facebook.sdk.ApplicationId`; duplicating it in `com.linkrunner.FacebookApplicationId` is done here for clarity.

### 7.4 Deep links (LinkRunner subdomain and custom scheme)

So that links like `https://app.goodtograb.com/...` and `goodtograb://...` open the app (e.g. for LinkRunner or marketing links):

**LinkRunner subdomain (App Links):**

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data
        android:scheme="https"
        android:host="app.goodtograb.com" />
</intent-filter>
```

**Custom URI scheme:**

```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="goodtograb" />
</intent-filter>
```

Replace `app.goodtograb.com` and `goodtograb` with your LinkRunner/marketing domain and scheme if different.

### 7.5 Flutter deep linking

```xml
<meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
```

### 7.6 minSdkVersion

LinkRunner requires **minSdkVersion 21** (Android 5.0). This project uses 21+.

---

## 8. iOS native configuration

### 8.1 Podfile

```ruby
platform :ios, '15.0'
```

LinkRunner requires iOS 15.0+.

### 8.2 App Tracking Transparency (ATT)

For IDFA collection (when you pass `disableIdfaCollection: false`), add in `Info.plist`:

```xml
<key>NSUserTrackingUsageDescription</key>
<string>This identifier will be used to deliver personalized ads and improve your app experience.</string>
```

### 8.3 URL schemes (for LinkRunner / marketing links)

This app uses the same schemes for Firebase Dynamic Links and LinkRunner. Example for custom scheme `goodtograb` and subdomain `app.goodtograb`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>goodtograb</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>goodtograb</string>
    </array>
  </dict>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>goodtograb</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>app.goodtograb</string>
    </array>
  </dict>
</array>
```

Use your own scheme and URL name in a new project.

### 8.4 Meta / SKAdNetwork

For Meta and SKAdNetwork (e.g. view-through), configure your Meta App in LinkRunner dashboard and, if required, grant access to LinkRunner (e.g. `access@linkrunner.io`) in Meta Business Manager. The app’s `Info.plist` already has Facebook keys (FacebookAppID, FacebookClientToken, etc.); LinkRunner uses the same app for attribution.

---

## 9. File structure (LinkRunner-related)

```
lib/
  initializer.dart                           # _initLinkRunner(), _handleLinkRunnerUserData()
  infrastructure/
    constants/
      app_constants.dart                     # linkrunnerToken, linkrunnerSecretKey, linkrunnerKeyId, iOS variants
    linkrunner/
      linkrunner_service.dart                # handleLinkRunnerDeepLink(attributionData)
  presentation/
    splash/
      splash_controller.dart                 # imports LinkRunner + LinkRunnerService (optional use of getAttributionData + handleLinkRunnerDeepLink)
android/
  app/src/main/
    AndroidManifest.xml                     # fullBackupContent, dataExtractionRules, Facebook ID, com.linkrunner.FacebookApplicationId, intent-filters (app.goodtograb.com, goodtograb)
    res/values/
      strings.xml                           # facebook_app_id, facebook_client_token
ios/
  Runner/
    Info.plist                              # NSUserTrackingUsageDescription, CFBundleURLTypes (goodtograb, app.goodtograb)
  Podfile                                   # platform :ios, '15.0'
```

---

## 10. Optional: signup() and setUserData after login

**Current behavior:** Only `setUserData()` at startup when user exists.

**Optional improvements:**

1. **Call setUserData after every login/signup**  
   Where you save the user (e.g. after OTP verify or social login), also call:
   ```dart
   final user = await PrefManager.getUser();
   if (user != null) {
     await LinkRunner().setUserData(
       userData: LRUserData(
         id: user.id.toString(),
         name: user.username,
         email: user.email,
         phone: user.mobile,
       ),
     );
   }
   ```

2. **Call signup() once for new users**  
   After first-time signup/onboarding success:
   ```dart
   await LinkRunner().signup(
     userData: LRUserData(
       id: user.id.toString(),
       name: user.username,
       email: user.email,
       phone: user.mobile,
       isFirstTimeUser: true,
     ),
     data: {},
   );
   ```

3. **Route from LinkRunner attribution deeplink on splash**  
   If you want installs that came from a LinkRunner link to open a specific screen (e.g. homeDetails):
   - After `_initLinkRunner()` (or on splash), call `LinkRunner().getAttributionData()`.
   - If the result has a `deeplink` and you want it to take precedence (or use when Firebase initial link is null), call `LinkRunnerService().handleLinkRunnerDeepLink(...)` with that data.

---

## 11. Optional: events and revenue

LinkRunner also supports:

- **trackEvent(eventName, eventData)** — e.g. `purchase_completed` with `amount` (number) for ad network revenue sharing.  
- **capturePayment(capturePayment: LRCapturePayment)** — payment amount, userId, paymentId, type (e.g. FIRST_PAYMENT), status.  
- **removePayment(removePayment: LRRemovePayment)** — for refunds/cancellations.  

This project does not use these; add them where you complete purchases or need to share revenue with Meta/Google.

---

## 12. Fresh project setup checklist

1. **LinkRunner Dashboard**  
   - Create/link project; get **project token** and **SDK signing** keys (Android + iOS) from Settings → SDK Signing.

2. **Flutter**  
   - Add `linkrunner: ^3.6.2` (or latest) to `pubspec.yaml`; run `flutter pub get`.

3. **Constants**  
   - Add `linkrunnerToken`, `linkrunnerSecretKey`, `linkrunnerKeyId`, `linkrunnerIOSSecretKey`, `linkrunnerIOSKeyId` to your constants (or env); never commit production secrets to public repos.

4. **Init**  
   - In your central initializer (before Firebase): call `LinkRunner().init(token, secretKey, keyId, disableIdfa, debug)` with `Platform.isIOS` for secret/key. Catch and log errors.

5. **User data**  
   - After init: if a user is already logged in, call `LinkRunner().setUserData(userData: LRUserData(id: ..., name: ..., email: ..., phone: ...))`. Optionally call after every login/signup and use `signup()` once for new users.

6. **Android**  
   - minSdkVersion 21.  
   - Manifest: `android:fullBackupContent="@xml/linkrunner_backup_descriptor"` and `android:dataExtractionRules="@xml/linkrunner_backup_rules"` on `<application>`.  
   - Add `com.facebook.sdk.ApplicationId` and `com.linkrunner.FacebookApplicationId` with your Meta App ID (and strings.xml).  
   - Add intent-filters for your LinkRunner/marketing domain and custom scheme; `flutter_deeplinking_enabled` if you use Flutter deep linking.

7. **iOS**  
   - Podfile: `platform :ios, '15.0'`.  
   - Info.plist: `NSUserTrackingUsageDescription`; CFBundleURLTypes for your scheme(s).  
   - Configure Meta/SKAdNetwork in LinkRunner/Meta as needed.

8. **Optional**  
   - Implement `LinkRunnerService.handleLinkRunnerDeepLink` and call it from splash (or elsewhere) when you have attribution data with a deeplink.  
   - Add `trackEvent` / `capturePayment` / `removePayment` where you track conversions and payments.

After that, your fresh project will mirror this app’s LinkRunner setup: init with platform-specific signing, user identification at startup (and optionally at login/signup), Meta view-through support, Android backup rules and Facebook ID, iOS ATT and URL schemes, and an optional deeplink handler for attribution.
