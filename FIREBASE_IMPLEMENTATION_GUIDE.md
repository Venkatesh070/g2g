# Firebase Implementation Guide — Good To Grab (g2g-customer-app)

This document describes the **entire Firebase integration** in this project so you can replicate it in a fresh Flutter app using the same architecture. It covers: **Firebase Core**, **Crashlytics**, **FCM (Push Notifications)**, **Firebase Dynamic Links**, **Firebase Auth**, and **Firebase Analytics**.

---

## 1. Architecture Overview

| Component | Purpose | Where it lives |
|-----------|---------|----------------|
| **Firebase Core** | Single `Firebase.initializeApp()` at app start | `lib/initializer.dart` |
| **Crashlytics** | Record Flutter fatal errors | `lib/initializer.dart` (FlutterError.onError) |
| **FCM** | Push notifications, token, background handler, in-app handling | `lib/infrastructure/firebase/push_firebase_notification.dart`, `lib/infrastructure/shared/firebase_messaging.dart` |
| **Dynamic Links** | Receive initial link on splash; build short links for sharing | `lib/infrastructure/firebase/dynamic_link_service.dart`, `lib/presentation/splash/splash_controller.dart`, `lib/presentation/home-details/home_details_page.dart` |
| **Firebase Auth** | Phone OTP, Google, Apple sign-in; exception mapping | `lib/presentation/intro/`, `lib/presentation/login/`, `lib/presentation/otp_verify/`, `lib/infrastructure/shared/app_exception_handle.dart` |
| **Analytics** | Screen tracking + custom events (first_install, app_open, login, add_to_cart, purchase, etc.) | `lib/main.dart` (observer), `lib/initializer.dart`, controllers |

**Initialization order (in `Initializer.init()`):**
1. Environment / BuildConfig  
2. LinkRunner (attribution — optional)  
3. **Firebase.initializeApp()**  
4. **FirebaseMessaging.onBackgroundMessage(handler)**  
5. **Crashlytics** (FlutterError.onError)  
6. Analytics first_install / app_open  
7. **AppNotification().init()** (FCM foreground, channels, initial message, token)

---

## 2. Dependencies (pubspec.yaml)

```yaml
dependencies:
  firebase_core:          # no version = use latest compatible
  firebase_auth: ^4.7.0
  firebase_messaging:     # FCM
  firebase_crashlytics: ^3.3.0
  firebase_analytics: ^10.7.1
  firebase_dynamic_links: ^5.3.4
  google_sign_in:         # for Google Sign-In with Firebase Auth
  sign_in_with_apple: ^5.0.0
  flutter_local_notifications: ^15.0.0  # for displaying FCM in foreground on Android
```

- **firebase_core** is required first; other Firebase packages depend on it.  
- **flutter_local_notifications** is used to show notifications when the app is in the foreground (FCM foreground messages don’t show a system notification by default on Android).

---

## 3. Firebase Core & Crashlytics

**File: `lib/initializer.dart`**

- Call **once** at app startup (after `WidgetsFlutterBinding.ensureInitialized()`):

```dart
await Firebase.initializeApp();
```

- No `FirebaseOptions` are passed; the project uses **default configuration** from:
  - **Android:** `android/app/google-services.json`
  - **iOS:** `ios/Runner/GoogleService-Info.plist`

**Crashlytics** — report Flutter framework errors to Crashlytics:

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// After Firebase.initializeApp()
FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
```

- Unhandled Flutter errors (e.g. in the framework) are sent to Firebase Crashlytics.  
- For custom errors you can use `FirebaseCrashlytics.instance.recordError(...)` (not used in this codebase but available).

---

## 4. FCM (Firebase Cloud Messaging) — Push Notifications

### 4.1 Constants & token storage

**File: `lib/infrastructure/constants/app_constants.dart`**

```dart
static String fcmToken = "fcmToken";
```

**File: `lib/infrastructure/shared/firebase_messaging.dart`**

- Single place to get and persist FCM token:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:good_grab/infrastructure/shared/pref_manager.dart';
import '../constants/app_constants.dart';

final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

Future<String?> getFcmToken() async {
  try {
    var fcmToken = await _firebaseMessaging.getToken();
    PrefManager.putString(AppConstants.fcmToken, fcmToken);
    return fcmToken;
  } catch (e) {
    return null; // or ' '
  }
}
```

- Token is stored in **PrefManager** under `AppConstants.fcmToken` and also sent to your backend as `device_token` on login/register (see below).

### 4.2 Background message handler (top-level function)

**File: `lib/infrastructure/firebase/push_firebase_notification.dart`**

- **Must** be a **top-level** function (not a class method):

```dart
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Optional: ensure Firebase is initialized in background isolate
  // await Firebase.initializeApp();

  dynamic surveyDataRaw = message.data['payload'] ?? message.data;
  if (surveyDataRaw is String) {
    try { surveyDataRaw = jsonDecode(surveyDataRaw); } catch (_) {}
  }
  if (surveyDataRaw is Map &&
      (surveyDataRaw['survey_id'] != null || surveyDataRaw['id'] != null)) {
    await PrefManager.putString(
        AppConstants.activeSurvey, jsonEncode(surveyDataRaw));
  }
}
```

- Registered in **initializer** (must be before any FCM usage):

```dart
FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
```

### 4.3 Notification initialization (AppNotification)

**Same file: `lib/infrastructure/firebase/push_firebase_notification.dart`**

- **AppNotification().init()** is called from `Initializer.init()` and does:

1. **iOS:** Request notification permission:
   ```dart
   if (Platform.isIOS) {
     await FirebaseMessaging.instance.requestPermission(
       alert: true, badge: true, sound: true,
     );
   }
   ```

2. **Foreground presentation (iOS):**
   ```dart
   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
     alert: true, badge: true, sound: true,
   );
   ```

3. **Android:** Create a high-importance notification channel (e.g. id `'Good To Grab'`) via **flutter_local_notifications**.

4. **Token:** Get FCM token and save to PrefManager:
   ```dart
   FirebaseMessaging.instance.getToken().then((value) async {
     await PrefManager.putString(AppConstants.fcmToken, value);
   });
   ```

5. **Initial message** (app opened from notification when **killed**):
   - `FirebaseMessaging.instance.getInitialMessage()` then handle `data['type']` (e.g. `order_confirmed`, `order_picked`/`order_pick`) and navigate (e.g. `Routes.orderDetails`, `Routes.orderPicked`) with a short delay so the app is ready.

6. **Foreground:** `FirebaseMessaging.onMessage.listen((RemoteMessage message))`:
   - Use `message.data['type']` to decide behavior:
     - `order_confirmed` → show in-app dialog/snackbar, refresh order list / order details.
     - `order_cancelled` → same pattern.
     - `order_picked` / `order_pick` → **navigate automatically** to Order Picked screen (e.g. `Get.offAllNamed(Routes.orderPicked, arguments: {...})`).
     - Survey payload → store or pass to SurveyController.
   - For other types, optionally show a **local notification** via `flutter_local_notifications` so the user sees something when the app is in foreground.

7. **Opened from notification (background/terminated):** `FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message))`:
   - Same `data['type']` handling: navigate to order details or order picked, or handle survey.

8. **flutter_local_notifications** is initialized with `onDidReceiveNotificationResponse` (e.g. for tap on notification); in this project it’s minimal (e.g. print only).

**Notification data contract (backend):**

- `data['type']`: `order_place` | `order_confirmed` | `order_cancelled` | `order_picked` | `order_pick` | survey-related.
- `data['order_id']` (or `orderId`, etc.) for order screens.
- Optional `data['payload']` (JSON string or map) for survey or extra data.
- Optional `message.notification?.body` merged into handling as `message` for order picked.

### 4.4 Where FCM token is sent to backend

- **Login (phone):** `lib/presentation/login/login_controller.dart` — before login API call, `await getFcmToken()`, then `params['device_token'] = await PrefManager.getString(AppConstants.fcmToken)`.
- **Intro (Google / Apple):** `lib/presentation/intro/intro_controller.dart` — after sign-in, same: get or refresh FCM token, then `params['device_token'] = fcmToken` in social login API.
- **OTP verify:** `lib/presentation/otp_verify/otp_verify_controller.dart` — after successful verification, if `params['device_token']` is empty, `params['device_token'] = await getFcmToken()` then send to backend.

So the backend receives **device_token** (FCM token) on login/register and can use it to send FCM messages to that device.

---

## 5. Firebase Dynamic Links

### 5.1 Receiving initial link (cold start from link)

**File: `lib/presentation/splash/splash_controller.dart`**

- After splash animation (or when deciding next screen):

```dart
final PendingDynamicLinkData? initialLink =
    await FirebaseDynamicLinks.instance.getInitialLink();

if (initialLink != null) {
  DynamicLinkService().initDynamicLinks(initialLink);
} else {
  // Normal flow: check logged in → home or intro
}
```

**File: `lib/infrastructure/firebase/dynamic_link_service.dart`**

```dart
Future<void> initDynamicLinks(PendingDynamicLinkData initialLink) async {
  final Uri deepLink = initialLink.link;
  String url = deepLink.toString();
  Uri uri = Uri.parse(url);
  String? resId = uri.queryParameters['resId'];
  String? currency = uri.queryParameters['currency'];

  Get.offAllNamed(Routes.homeDetails,
      arguments: {
        'resId': int.parse(resId ?? '0'),
        'currency': currency,
        'type': 'deeplink',
      });
}
```

- So the **link format** is expected to include query params **resId** and **currency** and leads to **homeDetails** (restaurant details).

### 5.2 Building short links (share restaurant)

**File: `lib/presentation/home-details/home_details_page.dart`**

- When user taps share, build a **short dynamic link** and share it:

```dart
FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;
var parameters = DynamicLinkParameters(
  uriPrefix: 'https://goodtograb',   // Your Firebase Dynamic Links prefix
  link: Uri.parse(
    'https://goodtograb.com/homeDetails?resId=${controller.resId}&currency=${controller.currency}',
  ),
  androidParameters: const AndroidParameters(
    packageName: "com.good.grab",
  ),
  socialMetaTagParameters: SocialMetaTagParameters(
    title: controller.homeData.value.restaurantName,
    imageUrl: Uri.parse(controller.homeData.value.restaurantProfile ?? ''),
  ),
  iosParameters: const IOSParameters(
    bundleId: "com.good.grab",
    appStoreId: '6451374378',
  ),
);
var dynamicUrl = await dynamicLinks.buildLink(parameters);
var shortLink = await dynamicLinks.buildShortLink(
  parameters,
  shortLinkType: ShortDynamicLinkType.unguessable,
);
var shortUrl = shortLink.shortUrl;
Share.share(shortUrl.toString());
```

- **uriPrefix** and domains must match your Firebase Console Dynamic Links setup (and optionally App Links / Associated Domains for open-in-app behavior).

### 5.3 Backend model (optional)

**File: `lib/infrastructure/models/restro_link_model.dart`**

- Some API returns `dynamic_link`; this model parses it. Sharing in this app is done by building the link in the client (above), not necessarily from this model.

---

## 6. Firebase Auth (Phone, Google, Apple)

### 6.1 Where it’s used

- **Phone OTP:** `lib/presentation/otp_verify/otp_verify_controller.dart` — `FirebaseAuth.instance.signInWithCredential(PhoneAuthProvider.credential(...))`.
- **Google / Apple:** `lib/presentation/intro/intro_controller.dart` — `FirebaseAuth.instance.signInWithCredential(oauthCredential)`; then backend is called with `social_id: _firebaseAuth.currentUser!.uid`, name, email, and `device_token` (FCM).

### 6.2 Exception handling

**File: `lib/infrastructure/shared/app_exception_handle.dart`**

```dart
handleFirebaseException(errorCode) {
  switch (errorCode) {
    case "too-many-requests":
      return "firebase_too_many_request".tr;
    case "invalid-phone-number":
      return "firebase_invalid_phone_number".tr;
    case "invalid-verification-code":
      return "firebase_invalid_code".tr;
    case "session-expired":
      return "firebase_session_expired".tr;
    case "network-request-failed":
    case "network_error":
      return "no_internet_connection".tr;
    // ... other cases
    default:
      return "something_went_wrong".tr;
  }
}
```

- Used in catch blocks for `FirebaseAuthException` (e.g. `handleFirebaseException(authException.code)`).
- Strings like `firebase_too_many_request` are localization keys in `lib/infrastructure/local/en.dart`.

---

## 7. Firebase Analytics

### 7.1 Navigator observer (automatic screen tracking)

**File: `lib/main.dart`**

```dart
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';

GetMaterialApp(
  navigatorObservers: [
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
  ],
  // ...
);
```

### 7.2 First install & app open

**File: `lib/initializer.dart`**

```dart
final analytics = FirebaseAnalytics.instance;
final prefs = await SharedPreferences.getInstance();
final firstInstall = prefs.getBool('has_installed') ?? false;

if (!firstInstall) {
  await analytics.logEvent(name: 'first_install');
  await prefs.setBool('has_installed', true);
}
await analytics.logAppOpen();
```

### 7.3 Custom events (examples from this project)

- **Login/Sign-up:**  
  `FirebaseAnalytics.instance.logLogin(loginMethod: method)` / `logSignUp(signUpMethod: method)` in `lib/presentation/otp_verify/otp_verify_controller.dart`.
- **Add to cart:**  
  `FirebaseAnalytics.instance.logAddToCart(...)` in cart and home_details controllers.
- **Begin checkout:**  
  `FirebaseAnalytics.instance.logBeginCheckout(...)` in cart controller.
- **Purchase:**  
  `FirebaseAnalytics.instance.logPurchase(...)` in cart controller after successful order.

Use the same pattern in a fresh project: get `FirebaseAnalytics.instance` and call the relevant `log*` methods with your parameters.

---

## 8. Android native configuration

### 8.1 Gradle

**Root `android/build.gradle`:**

```groovy
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

**App `android/app/build.gradle`:**

- Apply plugin **after** other plugins:
  ```groovy
  apply plugin: 'com.android.application'
  apply plugin: 'com.google.gms.google-services'
  ```
- Place **google-services.json** in `android/app/` (from Firebase Console).

### 8.2 AndroidManifest.xml

- **FCM default notification icon** (optional but recommended):
  ```xml
  <meta-data
      android:name="com.google.firebase.messaging.default_notification_icon"
      android:resource="@mipmap/ic_launcher" />
  ```

- **Deep links / App Links** (for Dynamic Links or direct HTTPS links to your app):
  - **Website (goodtograb.com):**
    ```xml
    <intent-filter android:autoVerify="true">
      <action android:name="android.intent.action.VIEW" />
      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />
      <data android:scheme="https" android:host="goodtograb.com" />
    </intent-filter>
    ```
  - **Custom scheme (goodtograb):**
    ```xml
    <intent-filter>
      <action android:name="android.intent.action.VIEW" />
      <category android:name="android.intent.category.DEFAULT" />
      <category android:name="android.intent.category.BROWSABLE" />
      <data android:scheme="goodtograb" />
    </intent-filter>
    ```
  - If you use Firebase Dynamic Links short domain (e.g. goodtograb.page.link), add an intent-filter for `android:host="goodtograb.page.link"` (in this project that filter is commented out; they use goodtograb.com and custom scheme).

- **Flutter deep linking:**
  ```xml
  <meta-data android:name="flutter_deeplinking_enabled" android:value="true" />
  ```

---

## 9. iOS native configuration

### 9.1 GoogleService-Info.plist

- Add **GoogleService-Info.plist** from Firebase Console to the Xcode project (e.g. under Runner) and ensure it’s in the **Runner** target’s “Copy Bundle Resources” build phase.

### 9.2 Info.plist

- **Firebase / FCM (swizzling disabled in this app):**
  ```xml
  <key>FirebaseAppDelegateProxyEnabled</key>
  <false/>
  ```
  With this, the Flutter Firebase plugins handle token and notifications; no extra native code is required in AppDelegate for FCM in this project.

- **Background modes** (for background FCM):
  ```xml
  <key>UIBackgroundModes</key>
  <array>
    <string>remote-notification</string>
  </array>
  ```

- **URL schemes** (for Dynamic Links / deep links):
  - Custom scheme `goodtograb` and optionally `app.goodtograb` (or your domain scheme) so links like `goodtograb://...` open the app.
  - Example for `goodtograb`:
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
    </array>
    ```

### 9.3 AppDelegate

- This project does **not** add any Firebase-specific code in AppDelegate; `GeneratedPluginRegistrant.register(with: self)` is enough. If you use `FirebaseAppDelegateProxyEnabled = true` elsewhere, you might need to pass the APNs token to FCM in AppDelegate — not needed with the current setup.

### 9.4 Capabilities

- Enable **Push Notifications** for the Runner target in Xcode.
- For **Sign in with Apple**, add the “Sign in with Apple” capability.

---

## 10. File structure (Firebase-related)

```
lib/
  main.dart                          # FirebaseAnalyticsObserver
  initializer.dart                   # Firebase init, Crashlytics, onBackgroundMessage, Analytics first_install/app_open, AppNotification.init
  infrastructure/
    constants/
      app_constants.dart             # fcmToken key, activeSurvey, etc.
    firebase/
      push_firebase_notification.dart # FCM: background handler, AppNotification (init, onMessage, onMessageOpenedApp, channels)
      dynamic_link_service.dart      # Handle initial dynamic link → homeDetails
    shared/
      firebase_messaging.dart        # getFcmToken()
      app_exception_handle.dart     # handleFirebaseException()
  presentation/
    splash/
      splash_controller.dart         # getInitialLink() → DynamicLinkService
    home-details/
      home_details_page.dart         # Build short link and share
    intro/
      intro_controller.dart         # Firebase Auth (Google/Apple), FCM token to backend
    login/
      login_controller.dart          # getFcmToken(), device_token in login API
    otp_verify/
      otp_verify_controller.dart     # Firebase Auth phone, Analytics logLogin/logSignUp, device_token
android/
  app/
    google-services.json             # From Firebase Console
    build.gradle                     # apply plugin google-services
  build.gradle                       # classpath google-services
  app/src/main/AndroidManifest.xml   # FCM icon, intent-filters for deep links
ios/
  Runner/
    GoogleService-Info.plist         # From Firebase Console
    Info.plist                       # FirebaseAppDelegateProxyEnabled, UIBackgroundModes, CFBundleURLTypes
  Podfile                            # No extra Firebase line; Flutter plugins add pods
```

---

## 11. Fresh project setup checklist

1. **Firebase Console**
   - Create project (or use existing).
   - Add Android app (package e.g. `com.good.grab`) and download **google-services.json** → `android/app/`.
   - Add iOS app (bundle id e.g. `com.good.grab`) and download **GoogleService-Info.plist** → add to Xcode Runner target.
   - Enable: **Authentication** (Phone, Google, Apple if needed), **Cloud Messaging**, **Crashlytics**, **Analytics**, **Dynamic Links** (configure domain/prefix).

2. **Flutter**
   - Add dependencies (firebase_core, firebase_auth, firebase_messaging, firebase_crashlytics, firebase_analytics, firebase_dynamic_links, flutter_local_notifications, etc.).
   - Run `flutter pub get`.

3. **Initialization**
   - In a central initializer (before runApp):
     - `await Firebase.initializeApp();`
     - `FirebaseMessaging.onBackgroundMessage(yourTopLevelHandler);`
     - `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;`
     - Then your FCM init (channels, permission, getToken, getInitialMessage, onMessage, onMessageOpenedApp).

4. **FCM**
   - Implement a top-level `firebaseMessagingBackgroundHandler`.
   - Store FCM token (e.g. PrefManager + AppConstants.fcmToken) and send as `device_token` on login/register.
   - Handle `getInitialMessage`, `onMessage`, `onMessageOpenedApp` and map `data['type']` to navigation or in-app UI (order_confirmed, order_cancelled, order_picked, survey, etc.).
   - Android: notification channel + optional default_notification_icon in manifest; iOS: requestPermission + setForegroundNotificationPresentationOptions + UIBackgroundModes remote-notification.

5. **Dynamic Links**
   - Splash (or root): `getInitialLink()` → parse query params → navigate (e.g. DynamicLinkService → homeDetails).
   - Share: build `DynamicLinkParameters` with uriPrefix, link URL, AndroidParameters, IOSParameters, SocialMetaTagParameters; buildShortLink → share.

6. **Auth**
   - Use Firebase Auth for phone OTP and/or Google/Apple; catch `FirebaseAuthException` and map `e.code` with something like `handleFirebaseException(e.code)` and show localized message.

7. **Analytics**
   - Add `FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance)` to your navigator observers.
   - Log first_install (once) and app_open in your initializer; add logLogin, logSignUp, logAddToCart, logPurchase, etc. where appropriate.

8. **Android**
   - Apply `com.google.gms.google-services` in app build.gradle; classpath in root build.gradle.
   - Add intent-filters and meta-data (FCM icon, flutter_deeplinking_enabled) as above.

9. **iOS**
   - Add GoogleService-Info.plist to Runner.
   - Info.plist: FirebaseAppDelegateProxyEnabled, UIBackgroundModes (remote-notification), CFBundleURLTypes for your scheme(s).
   - Enable Push Notifications capability.

After that, your fresh project will mirror this app’s Firebase architecture: Core, Crashlytics, FCM (with token and notification handling), Dynamic Links (receive + build), Auth (with centralized error handling), and Analytics (observer + key events).
