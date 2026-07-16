# Social Login – Step-by-Step Implementation Guide

This document describes **every step and API call** for implementing **Google** and **Apple** social login in a fresh setup of the Good to Grab (G2G) customer app, so you can replicate it in a new project or environment.

---

## Table of Contents

1. [Overview & Flow](#1-overview--flow)
2. [Dependencies](#2-dependencies)
3. [Backend API Contract](#3-backend-api-contract)
4. [API Calls in Order](#4-api-calls-in-order)
5. [Project Structure & Files](#5-project-structure--files)
6. [Step-by-Step Implementation](#6-step-by-step-implementation)
7. [Platform Configuration](#7-platform-configuration)
8. [Error Handling](#8-error-handling)
9. [Comparison: Mobile Login vs Social Login](#9-comparison-mobile-login-vs-social-login)

---

## 1. Overview & Flow

### 1.1 Social login vs mobile login

| Aspect | Mobile login | Social login (Google / Apple) |
|--------|--------------|-------------------------------|
| **Entry** | Login page → phone number → OTP screen | Intro page → tap Google/Apple → no OTP |
| **Verification** | Backend sends OTP → user enters OTP → backend verify-otp | Firebase/SDK verifies identity → app sends tokens to your backend |
| **Backend** | `email-exists` → `send-otp` → `verify-otp` → `login` or `sign-up` | Single **social-login** API |
| **Session** | Same: backend returns `User` + `access_token`; app stores in prefs and uses for API calls |

### 1.2 Social login high-level flow

```
User taps "Google" or "Apple" on Intro
    → (Optional) Ensure FCM token is available
    → Trigger Google Sign-In or Sign in with Apple (native/Firebase)
    → On success: get social_id, email, name
    → Call backend POST /social-login with these + device info
    → Backend returns user + access_token (same shape as /login)
    → Save user + token in PrefManager, set loggedIn = true
    → Navigate to Home or Allow Permission screen
```

There is **only one backend API** involved in the social flow: **POST `/social-login`**. No OTP, no separate “check exists” or “send OTP” calls.

---

## 2. Dependencies

Add these in `pubspec.yaml`:

```yaml
dependencies:
  # Firebase (required for both Google and Apple auth)
  firebase_core: ...
  firebase_auth: ^4.7.0

  # Google Sign-In
  google_sign_in: ...

  # Apple Sign-In (required on iOS for apps that offer other social logins)
  sign_in_with_apple: ^5.0.0

  # For Apple nonce (SHA256)
  crypto: ^3.0.3

  # Already used for FCM token (needed for device_token in social-login)
  firebase_messaging: ...
```

Run:

```bash
flutter pub get
```

---

## 3. Backend API Contract

### 3.1 Social login – single API

- **Endpoint:** `POST /api/{apiVersion}/social-login`  
  (e.g. `POST https://dev.goodtograb.com/g2g-staging/api/v1/social-login`)
- **Headers:** `Content-Type: application/json` (no `Authorization`; user is not logged in yet).
- **Body (JSON):** same structure for both Google and Apple; only `login_type` and `social_id` source differ.

#### Request body (all fields used in current app)

| Key | Type | Required | Description |
|-----|------|----------|-------------|
| `social_id` | string | Yes | Google: `GoogleSignInAccount.id` / Apple: `FirebaseAuth.currentUser!.uid` |
| `username` | string | Yes | Display name (Google: `displayName` / Apple: `displayName` or `"User"`) |
| `email` | string | No* | Email from provider (empty string if not provided, e.g. Apple hide-my-email) |
| `login_type` | string | Yes | `"Google"` or `"Apple"` (exact casing as used in app) |
| `device_type` | string | Yes | e.g. `"android"` / `"ios"` |
| `device_token` | string | Yes | FCM token for push notifications |
| `version` | string | No | App version string (e.g. from package_info) |

Example (Google):

```json
{
  "social_id": "103547318597142817347",
  "username": "John Doe",
  "email": "john@gmail.com",
  "login_type": "Google",
  "device_type": "ios",
  "device_token": "fcm_token_here...",
  "version": "1.0.37"
}
```

Example (Apple):

```json
{
  "social_id": "001234.abc123def456.7890",
  "username": "User",
  "email": "",
  "login_type": "Apple",
  "device_type": "ios",
  "device_token": "fcm_token_here...",
  "version": "1.0.37"
}
```

#### Response body (success)

Same structure as your existing **login** API (so you can reuse `UserModel` and parsing).

- **HTTP:** 200 OK  
- **Body:** standard API wrapper with `success`, `message`, `data` where `data` is the same user object as in `/login` / `/sign-up`.

Example:

```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 12345,
      "username": "John Doe",
      "email": "john@gmail.com",
      "mobile": "",
      "country_code": "",
      "device_type": "ios",
      "login_type": "Google",
      "device_token": "fcm_...",
      "device_id": "uuid-...",
      "country_id": 0,
      "social_id": "103547318597142817347",
      "profile": "",
      "is_active": "1",
      "language": "",
      "access_token": "eyJ0eXAiOiJKV1...",
      "co2": 0,
      "saved_money": 0,
      "created_at": "..."
    }
  }
}
```

- **Failure:** `success: false`, `message` with error text; optional `data` null or omitted.  
- **HTTP 4xx/5xx:** Your app treats these via Dio (e.g. `CustomHttpException`) and shows a generic or server message.

Backend must:

1. Accept `social_id` + `login_type` and identify or create the user.
2. Return the same `user` object (including `access_token`, `login_type`, `social_id`) so the app can store profile and token and call other APIs.

---

## 4. API Calls in Order

In the **social login** flow, only **one** backend API is called:

| Step | Who | API / Action | Purpose |
|------|-----|--------------|---------|
| 1 | App | (Optional) Ensure FCM token | So `device_token` is not empty when calling social-login |
| 2 | App | Google Sign-In or Sign in with Apple | Get identity (id, email, name) and (for Apple) nonce verification |
| 3 | App | **POST /social-login** | Send `social_id`, `username`, `email`, `login_type`, `device_type`, `device_token`, `version` |
| 4 | Backend | — | Validate/create user; return `user` + `access_token` |
| 5 | App | — | Save `user` and `access_token` in PrefManager; set `loggedIn = true`; navigate |

No other backend auth APIs (e.g. `email-exists`, `send-otp`, `verify-otp`, `login`, `sign-up`) are used in the social flow.

---

## 5. Project Structure & Files

Relevant files for social login in a fresh setup:

```
lib/
├── infrastructure/
│   ├── constants/
│   │   └── app_constants.dart          # apiVersion, fcmToken, userProfile, etc.
│   ├── models/
│   │   ├── api_response_model.dart     # ApiResponseModel<T>, Serializable
│   │   └── user_model.dart             # UserModel, User (loginType, socialId)
│   ├── network/
│   │   ├── api_constants.dart          # baseUrl, apiSocialLogin = "/social-login"
│   │   ├── dio_client.dart             # funSocialLoginApi(params)
│   │   └── ...
│   └── shared/
│       ├── pref_manager.dart          # putString(getString(accessToken, userProfile), putBool(loggedIn))
│       ├── firebase_messaging.dart     # getFcmToken()
│       ├── app_exception_handle.dart   # handleFirebaseException, handleApiException
│       └── ...
├── presentation/
│   ├── intro/
│   │   ├── intro_controller.dart       # signInWithGmail(), signInWithApple(), successLogin(), getFcmToken
│   │   ├── intro_page.dart            # Google / Apple buttons
│   │   └── intro_binding.dart
│   └── login/
│       ├── login_controller.dart      # mobile flow only (optional: can add social here too)
│       ├── login_page.dart
│       └── login_binding.dart
└── main.dart                          # Firebase.initializeApp()
```

---

## 6. Step-by-Step Implementation

### Step 1: API constants

In `lib/infrastructure/network/api_constants.dart`:

- Base URL and version (e.g. `AppConstants.apiVersion`).
- Add or confirm:

```dart
// auth
var apiSocialLogin = "/social-login";
```

So full URL = `baseUrl + apiSocialLogin` (e.g. `https://dev.goodtograb.com/g2g-staging/api/v1/social-login`).

---

### Step 2: DioClient – social login method

In `lib/infrastructure/network/dio_client.dart`:

- Use **unauthenticated** client: `DioClient.base()` (no `accessToken`).
- Implement:

```dart
Future funSocialLoginApi(Map<String, dynamic> params) async {
  try {
    Response response = await _dio.post(
      apiEndPoints.apiSocialLogin,
      data: json.encode(params),
    );
    return ApiResponseModel<UserModel>.fromJson(
      response.data!,
      (data) => UserModel.fromJson(data),
    );
  } catch (error) {
    catchErrorHandler(); // or your global error handler
  }
  return null;
}
```

- Ensure `UserModel.fromJson` supports the same `user` structure as your login API (id, username, email, mobile, login_type, social_id, access_token, etc.). Your current `User` model already has `loginType` and `socialId`.

---

### Step 3: User model

In `lib/infrastructure/models/user_model.dart` ensure `User` has at least:

- `id`, `username`, `email`, `mobile`, `countryCode`, `deviceType`, `loginType`, `deviceToken`, `deviceId`, `countryId`, `socialId`, `profile`, `isActive`, `language`, `accessToken`, and any app-specific fields.

Your existing model already includes `login_type` and `social_id`; no change needed if backend returns the same keys (`login_type`, `social_id`, `access_token`, etc.).

---

### Step 4: FCM token helper

In `lib/infrastructure/shared/firebase_messaging.dart` (or equivalent):

```dart
getFcmToken() async {
  try {
    var fcmToken = await FirebaseMessaging.instance.getToken();
    PrefManager.putString(AppConstants.fcmToken, fcmToken ?? '');
    return fcmToken ?? '';
  } catch (e) {
    return '';
  }
}
```

Used so social-login request can send a non-empty `device_token`.

---

### Step 5: Intro controller – Google Sign-In

In `lib/presentation/intro/intro_controller.dart`:

1. **Dependencies and state**

- `FirebaseAuth _firebaseAuth = FirebaseAuth.instance`
- `GoogleSignIn _googleSignIn = GoogleSignIn()`
- Progress dialog for loading

2. **Optional: ensure FCM token before starting**

- In `onInit` or at start of `signInWithGmail`:  
  `await getFcmToken();`  
  So when you build params for social-login, `PrefManager.getString(AppConstants.fcmToken)` or a direct `await getFcmToken()` is not empty.

3. **Google flow**

- Show progress.
- Optionally sign out first: `if (await _googleSignIn.isSignedIn()) await _googleSignIn.signOut();`
- `GoogleSignInAccount? googleUser = await _googleSignIn.signIn();`
- If user cancelled: dismiss progress and return (no error).
- Get auth tokens: `GoogleSignInAuthentication googleAuth = await googleUser!.authentication;`
- Create credential: `AuthCredential credential = GoogleAuthProvider.credential(accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);`
- Sign in to Firebase: `await _firebaseAuth.signInWithCredential(credential);` (so you have a consistent auth state if needed).
- Build params:

  - `social_id` = `googleUser.id`
  - `username` = `googleUser.displayName ?? 'User'`
  - `email` = `googleUser.email ?? ''`
  - `device_type` = from your `CommonFunction.getDeviceType()` (e.g. "ios" / "android")
  - `login_type` = `"Google"`
  - `device_token` = FCM token (from prefs or `await getFcmToken()`)
  - `version` = from `CommonFunction.getVersionDetails()` (app version string)

4. **Single API call**

- `ApiResponseModel<UserModel> userModel = await DioClient.base().funSocialLoginApi(params);`

5. **Handle response**

- If `userModel.success == true` and `userModel.data?.user != null`: call `successLogin(userModel.data!)`, then dismiss progress.
- Else: dismiss progress and show `userModel.message` (or generic error) via `errorScreen(error: ...)`.

6. **Catch errors**

- `FirebaseAuthException` / `PlatformException`: dismiss progress, show `handleFirebaseException(exception.code)`.
- `CustomHttpException`: dismiss progress, show `handleApiException(...)`.
- Generic: dismiss progress, show generic message.

---

### Step 6: Intro controller – Apple Sign-In

Apple requires a nonce (SHA256 hash) for security. Use the same controller.

1. **Nonce helpers** (in same controller or a util):

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

String generateNonce([int length = 32]) {
  const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

String sha256ofString(String input) {
  final bytes = utf8.encode(input);
  final digest = sha256.convert(bytes);
  return digest.toString();
}
```

2. **Apple flow**

- Show progress.
- `rawNonce = generateNonce()`, `nonce = sha256ofString(rawNonce)`.
- Call Sign in with Apple:

  - Scopes: `email`, `fullName`.
  - `nonce: nonce`.
  - iOS: use default; for web/Android you may need `clientId` and `redirectUri` (your current app uses `clientId: 'com.good.grab.applesignin'`, `redirectUri: Uri.parse('https://appentus.com/callbacks/sign_in_with_apple')`).

- Get credential: `OAuthProvider('apple.com').credential(idToken: appleCredential.identityToken, rawNonce: rawNonce)`.
- Sign in to Firebase: `await _firebaseAuth.signInWithCredential(oauthCredential);`
- Build params:
  - `social_id` = `_firebaseAuth.currentUser!.uid`
  - `username` = `_firebaseAuth.currentUser!.displayName ?? 'User'`
  - `email` = `_firebaseAuth.currentUser!.email ?? ''`
  - `device_type`, `login_type` = `"Apple"`, `device_token`, `version` as above.

3. **Same single API call**

- `ApiResponseModel<UserModel> userModel = await DioClient.base().funSocialLoginApi(params);`

4. **Same success/error handling** as Google (successLogin / errorScreen), and handle `SignInWithAppleAuthorizationException` (e.g. user cancel) without showing a generic error.

---

### Step 7: Success login – store session and navigate

In intro controller, after successful social-login response:

```dart
void successLogin(UserModel userModel) {
  PrefManager.putString(AppConstants.userProfile, json.encode(userModel.user));
  PrefManager.putString(AppConstants.deviceId, userModel.user!.deviceId.toString());
  PrefManager.putInt(AppConstants.userId, userModel.user!.id!);
  PrefManager.putString(AppConstants.accessToken, userModel.user!.accessToken!);
  PrefManager.putBool(AppConstants.loggedIn, true);
  navigateScreen();
}

void navigateScreen() async {
  var locationStatus = await getLocationPermissionStatus();
  var notificationStatus = await getNotificationPermissionStatus();
  if (locationStatus == 1 && notificationStatus == 1) {
    Get.offAllNamed(Routes.home, arguments: {'permission': 1});
  } else {
    Get.offAllNamed(Routes.allowPermission);
  }
}
```

Use the same navigation logic as after mobile login so behaviour is consistent.

---

### Step 8: Intro page – Google and Apple buttons

In `lib/presentation/intro/intro_page.dart`:

- **Google:** one button that calls `controller.signInWithGmail();`
- **Apple:** on iOS (and optionally Android), one button that calls `controller.signInWithApple();`

Example layout (concept only; adjust to your UI):

- Row with “Sign up Now” and “Log in” (navigate to login page with `screenType`).
- Divider with “or”.
- Row: Google icon button → `controller.signInWithGmail();`; if iOS (or always), Apple icon button → `controller.signInWithApple();`

Ensure `IntroController` is registered (e.g. in `IntroBinding`) and `IntroPage` is a `GetView<IntroController>` or uses `Get.find<IntroController>()`.

---

### Step 9: Login page and binding (optional)

Your current **login flow** is phone-based (number → OTP → verify → login/sign-up). You do **not** need to change it for social login to work; social login is handled entirely from the Intro screen.

If you want social buttons on the **login page** as well:

- In `login_page.dart` add the same Google/Apple buttons.
- In `login_controller.dart` either:
  - Call the same logic (e.g. put `signInWithGmail` / `signInWithApple` in a shared service and call from both Intro and Login), or
  - Navigate to Intro and trigger social login from there.

`login_binding.dart` only needs to register `LoginController`; no change for social login unless you add the above.

---

## 7. Platform Configuration

### 7.1 Firebase

- Create a Firebase project; add Android and iOS apps (package name / bundle ID).
- Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) and place them as per FlutterFire docs.
- In `main.dart`: `await Firebase.initializeApp();` before `runApp(...)`.
- In Firebase Console enable:
  - **Authentication → Sign-in method → Google** (and optionally Apple if you use Firebase for Apple too).

### 7.2 Google Sign-In

- **Android:** SHA-1 (debug/release) added in Firebase; same in Google Cloud Console for the OAuth client used by the app.
- **iOS:** In Xcode, URL scheme for reversed client ID from `GoogleService-Info.plist`; in Apple Developer, enable “Sign in with Apple” for the app.

### 7.3 Sign in with Apple

- **Apple Developer:** App ID has “Sign in with Apple” capability; same for the provisioning profile.
- **iOS:** Capability “Sign in with Apple” in Xcode.
- **Android (optional):** If you offer Apple on Android, configure `clientId` and `redirectUri` in `SignInWithApple.getAppleIDCredential(...)` (as in your current app).

---

## 8. Error Handling

- **User cancels Google/Apple:** Do not show error; just dismiss progress and return.
- **Firebase auth errors:** Use `handleFirebaseException(authException.code)` (e.g. `network-request-failed` → “no_internet_connection”).
- **Backend social-login failure:** Show `userModel.message` or a generic “Login failed” via `errorScreen(error: ...)`.
- **Dio/HTTP errors:** Use your existing `CustomHttpException` and `handleApiException` so timeouts and network errors show a consistent message.

---

## 9. Comparison: Mobile Login vs Social Login

| Step | Mobile (login/signup) | Social (Google/Apple) |
|------|------------------------|------------------------|
| 1 | Get country list (optional) | Get FCM token (optional) |
| 2 | **POST /email-exists** (type=mobile, source=number) | — |
| 3 | Navigate to OTP screen with params | — |
| 4 | **POST /send-otp** (type=mobile, mobile=number) | — |
| 5 | User enters OTP | User completes Google/Apple UI |
| 6 | **POST /verify-otp** (mobile, otp) | — |
| 7 | **POST /login** or **POST /sign-up** (mobile, device_type, login_type, etc.) | **POST /social-login** (social_id, username, email, login_type, device_type, device_token, version) |
| 8 | Save user + token; navigate | Same |

So: **mobile flow uses 4 backend APIs** (email-exists → send-otp → verify-otp → login/sign-up); **social flow uses 1 API** (social-login). After that, both use the same session (user profile + access_token) and the same navigation and API usage (Bearer token in `DioClient.base(accessToken: ...)`).

---

## 10. Quick checklist for a fresh setup

- [ ] Firebase project + Android/iOS apps; `google-services.json` / `GoogleService-Info.plist`; `Firebase.initializeApp()` in `main.dart`.
- [ ] `pubspec.yaml`: firebase_core, firebase_auth, google_sign_in, sign_in_with_apple, crypto.
- [ ] API: `apiSocialLogin = "/social-login"`; `DioClient.funSocialLoginApi(params)`.
- [ ] User model supports `login_type`, `social_id`, `access_token` and rest of user object.
- [ ] FCM: `getFcmToken()` and pass as `device_token` in social-login.
- [ ] Intro: `signInWithGmail()` and `signInWithApple()` build same param set and call `funSocialLoginApi`; on success call `successLogin(userModel.data!)`.
- [ ] `successLogin`: save user, deviceId, userId, accessToken, loggedIn; then `navigateScreen()` (home or allow permission).
- [ ] Intro page: Google and Apple buttons wired to controller.
- [ ] Error handling: Firebase, backend message, Dio exceptions; user cancel = no error.
- [ ] Backend: POST /social-login accepts request body above and returns same user/access_token structure as /login.

Once these are in place, social login is end-to-end: one tap on Intro → one backend call → same logged-in experience as mobile login.
