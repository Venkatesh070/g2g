# Signup Implementation – Detailed Guide

This document describes the **Sign up** flow in the G2G customer app: screens, API calls, request/response handling, validation, and post-signup behavior.

---

## 1. Overview

- **Screen**: Sign up uses the same **Login** screen (`LoginPage`) with `screenType == 'signup'`.
- **Flow**: Login Page (signup mode) → OTP Verify Page → Home or Allow Permission.
- **APIs used**: Get Countries, Check Mobile/Email Exists, Send OTP, Verify OTP, Sign Up.

---

## 2. Entry Points to Sign Up

- **Intro**: `Get.toNamed(Routes.login, arguments: {'screenType': 'signup'});`
- **Login screen**: User taps “Sign up Now” in the “You need to register now” bottom sheet → `onTapRegister()` sets `screenType = 'signup'` and checks mobile via API.

**File**: `lib/presentation/login/login_controller.dart`  
**File**: `lib/presentation/login/login_page.dart`  
**File**: `lib/infrastructure/navigation/routes.dart` (e.g. `Routes.login`, `Routes.otpVerify`)

---

## 3. Sign Up Screen (Login Page in Signup Mode)

### 3.1 UI (Login Page)

- **Title**: “Sign up” when `screenType == 'signup'`.
- **Subtitle**: `signup_title` (e.g. “Please enter your mobile number and full name”).
- **Fields** (signup only):
  - **Full Name** (required) – `nameController`
  - **Mobile Number** (required) – `numberController` + country code picker
  - **Email** (optional) – `emailAddressController`; if provided, must be valid and not already registered
- **Continue** button: enabled when validation and “number available” check pass (`isFillColor == true`).

**File**: `lib/presentation/login/login_page.dart`  
**File**: `lib/infrastructure/local/en.dart` (`signup_title`)

### 3.2 Controller Init

On `LoginController.onInit()`:

1. `screenType.value = Get.arguments['screenType']` (e.g. `'signup'`).
2. `getFcmToken()` – FCM token for device.
3. `getCountryList()` – loads countries for the country-code picker.

---

## 4. API #1: Get Country List

**Purpose**: Populate country picker for mobile number.

| Item | Value |
|------|--------|
| **Endpoint** | `GET /getCountrylist` |
| **Constant** | `apiGetCountries` in `ApiConstants` |
| **Client** | `DioClient.base().funGetCountriesApi()` |
| **Auth** | None (no Bearer) |

**Request**: No body/query.

**Response handling**:

- **Success**: `ApiResponseModel<CountryModel>.success == true`, `data.countryList` → `countryList.addAll(...)`.
- **Error**: `CustomHttpException` → `errorScreen(handleApiException(...))`; generic catch → `errorScreen('something_went_wrong'.tr)`.

**File**: `lib/infrastructure/network/dio_client.dart` (e.g. ~196–205)  
**File**: `lib/infrastructure/network/api_constants.dart`  
**File**: `lib/infrastructure/models/country_model.dart`

---

## 5. Validation and “Number/Email Exists” Check

### 5.1 When validation runs

- **Continue** tap → `isValid(context)`.
- For signup it checks: name non-empty, number non-empty, `checkNumberValid == true`, and if email is filled then `checkEmailValid == true` and valid format.

### 5.2 API #2: Check Mobile/Email Exists (email-exists)

**Purpose**: Ensure mobile (and optionally email) is not already registered so user can proceed with sign up.

| Item | Value |
|------|--------|
| **Endpoint** | `POST /email-exists` |
| **Constant** | `apiIsEmailNumber` |
| **Client** | `DioClient.base().funIsEmailNumberApi(params)` |
| **Auth** | None |

**Request body** (JSON):

- For **mobile** (signup):  
  `{ "type": "mobile", "source": "<numberController.text>" }`
- For **email** (when user fills email):  
  `{ "type": "email", "source": "<emailAddressController.text>" }`

**Response handling**:

- **Success** (`baseModel.success == true`): number/email **not** registered → `checkNumberValid` or `checkEmailValid` set to `true`.
- **Failure** (`success == false`): number/email **already exists** → set corresponding check to `false`.
- **CustomHttpException** or other error → set check to `false`.

After this, `changeButtonColor()` is called so Continue enables only when checks pass.

**Trigger**:

- **Mobile**: Debounced (500 ms) on number field `onChanged` in signup mode; also on “Sign up Now” in bottom sheet (`onTapRegister()`).
- **Email**: Debounced (500 ms) when email field changes and format is valid.

**File**: `lib/presentation/login/login_controller.dart` (`isCheckNumberApi`, `onTapRegister`, `changeButtonColor`, `isValid`)  
**File**: `lib/infrastructure/network/dio_client.dart` (`funIsEmailNumberApi` ~780–789)  
**File**: `lib/infrastructure/network/api_constants.dart` (`apiIsEmailNumber`)

---

## 6. Continue to OTP Screen

When user taps **Continue** and `isValid()` passes:

1. `CommonFunction.keyboardDismiss(context)`.
2. Build `params`:
   - `mobile`, `device_type`, `login_type: 'mobile'`, `device_token` (FCM), `country_code`, `country_id`, `version`.
   - For signup only: `username` (name), `email` (optional).
3. Navigate:  
   `Get.toNamed(Routes.otpVerify, arguments: {'screenType': screenType.value, 'params': params});`

**File**: `lib/presentation/login/login_controller.dart` (`onContinue`)

---

## 7. OTP Verify Screen

### 7.1 Init

- `screenType = Get.arguments['screenType']` (`'signup'`).
- `params = Get.arguments['params']` (same map built on login page).
- For `screenType == 'login' || 'signup'`: `sendNumberOtp(number.value)` with `params['mobile']` (and country from params for display).

**File**: `lib/presentation/otp_verify/otp_verify_controller.dart` (`onInit`)

### 7.2 API #3: Send OTP (Mobile)

**Purpose**: Send OTP to the given mobile number before verify + signup.

| Item | Value |
|------|--------|
| **Endpoint** | `POST /send-otp` |
| **Constant** | `apiSendNOtp` |
| **Client** | `DioClient.base().funSendNOtpApi(nParams)` |
| **Auth** | None |

**Request body** (JSON):

```json
{ "type": "mobile", "mobile": "<mobile_number>" }
```

**Response handling**:

- **Success**: Dismiss loader, `initTimer()` (60 s resend countdown).
- **Failure** (`success == false`): Dismiss loader, `errorScreen(baseModel.message)`.
- **CustomHttpException**: Dismiss loader, `errorScreen(handleApiException(...))`.
- **Other**: Dismiss loader, `errorScreen('something_went_wrong'.tr)`.

**File**: `lib/presentation/otp_verify/otp_verify_controller.dart` (`sendNumberOtp`)  
**File**: `lib/infrastructure/network/dio_client.dart` (`funSendNOtpApi` ~747–756)  
**File**: `lib/infrastructure/network/api_constants.dart` (`apiSendNOtp`)

---

## 8. Verify OTP and Complete Sign Up

User enters 6-digit OTP and taps Verify. For login/signup with mobile, `verifyOtp(code)` calls `verifyOtpNumber(code)` (not email path).

### 8.1 API #4: Verify OTP (Mobile)

**Purpose**: Confirm OTP so the app can call login or signup with the same mobile.

| Item | Value |
|------|--------|
| **Endpoint** | `POST /verify-otp` |
| **Constant** | `apiVerifyOtp` |
| **Client** | `DioClient.base().funVerifyNOtpApi(emailParams)` |
| **Auth** | None |

**Request body** (JSON):

```json
{ "mobile": "<mobile_number>", "otp": "<6_digit_code>" }
```

**Response handling**:

- **Success**: Call `verifyAndLogin()` (see below).
- **Failure**: Dismiss loader, `errorScreen(baseModel.message)`.
- **CustomHttpException**: Dismiss loader, `errorScreen(handleApiException(...))`.
- **Other**: Dismiss loader, `errorScreen('something_went_wrong'.tr)`.

**File**: `lib/presentation/otp_verify/otp_verify_controller.dart` (`verifyOtp`, `verifyOtpNumber`)  
**File**: `lib/infrastructure/network/dio_client.dart` (`funVerifyNOtpApi` ~758–767)  
**File**: `lib/infrastructure/network/api_constants.dart` (`apiVerifyOtp`)

### 8.2 API #5: Sign Up

**Purpose**: Create user account after OTP is verified.

| Item | Value |
|------|--------|
| **Endpoint** | `POST /sign-up` |
| **Constant** | `apiSignup` |
| **Client** | `DioClient.base().funSignupUserApi(params)` |
| **Auth** | None |

**When it’s called**: Inside `verifyAndLogin()` when `screenType == 'signup'`. Same `params` from login page are used; if `device_token` is empty, FCM token is fetched first.

**Request body** (JSON, from `params`):

- `mobile` – from login screen
- `device_type` – from `CommonFunction.getDeviceType()`
- `login_type` – `'mobile'`
- `device_token` – FCM token
- `country_code`, `country_id` – from picker
- `version` – app version
- **Signup-only**: `username` (full name), `email` (optional)

**Response**: Same as login – `ApiResponseModel<UserModel>`.

**Backend response shape (expected)**:

- `success`: boolean  
- `message`: string  
- `data`: object containing `user` with at least:  
  `id`, `username`, `email`, `mobile`, `country_code`, `device_type`, `login_type`, `device_token`, `device_id`, `country_id`, `social_id`, `profile`, `is_active`, `language`, **`access_token`**, `co2`, `saved_money`, `created_at`

**Response handling in app**:

- **Success** (`userModel.success == true` and `userModel.data?.user != null`):
  - Dismiss loader.
  - `successLoginSignup(userModel.data!)` (saves user, token, logs analytics, then navigates).
- **Failure**: Dismiss loader, `errorScreen(userModel.message)`.
- **CustomHttpException**: Dismiss loader, `errorScreen(handleApiException(...))`.
- **Other**: Dismiss loader, `errorScreen('something_went_wrong'.tr)`.

**File**: `lib/presentation/otp_verify/otp_verify_controller.dart` (`verifyAndLogin`, `successLoginSignup`)  
**File**: `lib/infrastructure/network/dio_client.dart` (`funSignupUserApi` ~220–230)  
**File**: `lib/infrastructure/network/api_constants.dart` (`apiSignup`)  
**File**: `lib/infrastructure/models/user_model.dart` (`UserModel`, `User`)

---

## 9. Post–Sign Up Success

### 9.1 successLoginSignup(UserModel)

1. **Persistence** (PrefManager):
   - `AppConstants.userProfile` ← JSON of `user`
   - `AppConstants.deviceId` ← `user.deviceId`
   - `AppConstants.userId` ← `user.id`
   - `AppConstants.accessToken` ← `user.accessToken`
   - `AppConstants.loggedIn` ← `true`
2. **Analytics**:
   - Firebase: `FirebaseAnalytics.instance.logSignUp(signUpMethod: method)` (e.g. `'phone'`).
   - Meta: `AnalyticsService.logSignUp(method: method)` (inside try/catch).
3. **Navigation**: `navigateScreen()`.

### 9.2 navigateScreen()

- If location and notification permissions both granted → `Get.offAllNamed(Routes.home, arguments: {'permission': 1})`.
- Otherwise → `Get.offAllNamed(Routes.allowPermission)`.

**File**: `lib/presentation/otp_verify/otp_verify_controller.dart` (`successLoginSignup`, `navigateScreen`)

---

## 10. Error Handling Summary

### 10.1 API / network (DioClient)

- On error, `catchErrorHandler()` throws `CustomHttpException` with:
  - **Socket/network**: `type: 'socketError'` → message from `handleApiException` → e.g. `no_internet_connection`.
  - **Timeout**: `type: 'connectionTimeout'` → `connection_timeout_exception`.
  - **Other**: `type: 'error'`, message from `response.data['message']` or fallback.

**File**: `lib/infrastructure/network/dio_client.dart` (`catchErrorHandler`, `_checkSocketException`)  
**File**: `lib/infrastructure/shared/http_exception.dart` (`CustomHttpException`)  
**File**: `lib/infrastructure/shared/app_exception_handle.dart` (`handleApiException`)

### 10.2 UI layer

- Controllers use `on CustomHttpException catch (exception)` and call `errorScreen(handleApiException(exception.code, exception.response, exception.exception, type: exception.type))`.
- Generic `catch` → `errorScreen('something_went_wrong'.tr)`.
- Business failure (e.g. `success == false`) → `errorScreen(baseModel.message)`.

---

## 11. Signup API Call Sequence (Summary)

1. **GET /getCountrylist** – On login page init (shared with login).
2. **POST /email-exists** – When checking mobile (and optionally email) for signup; can be called multiple times (debounced).
3. **POST /send-otp** – On OTP screen init (and on Resend when timer is 0).
4. **POST /verify-otp** – When user submits OTP.
5. **POST /sign-up** – After OTP success, with full params (mobile, username, email, device, country, version, etc.).

---

## 12. File Reference

| Layer | File |
|-------|------|
| **API constants** | `lib/infrastructure/network/api_constants.dart` |
| **API client** | `lib/infrastructure/network/dio_client.dart` |
| **Response / user models** | `lib/infrastructure/models/api_response_model.dart`, `lib/infrastructure/models/user_model.dart` |
| **Login (signup) UI** | `lib/presentation/login/login_page.dart` |
| **Login (signup) logic** | `lib/presentation/login/login_controller.dart` |
| **OTP UI** | `lib/presentation/otp_verify/otp_verify_page.dart` |
| **OTP + verify + signup** | `lib/presentation/otp_verify/otp_verify_controller.dart` |
| **Errors** | `lib/infrastructure/shared/http_exception.dart`, `lib/infrastructure/shared/app_exception_handle.dart` |
| **Prefs** | `lib/infrastructure/shared/pref_manager.dart` |
| **Routes** | `lib/infrastructure/navigation/routes.dart` |

---

## 13. Request/Response Examples (Reference)

### POST /email-exists (mobile check)

**Request:**

```json
{ "type": "mobile", "source": "9876543210" }
```

**Success (number available):** `{ "success": true, "message": "..." }`  
**Already exists:** `{ "success": false, "message": "..." }`

### POST /send-otp

**Request:**

```json
{ "type": "mobile", "mobile": "9876543210" }
```

**Response:** `{ "success": true, "message": "..." }` (no user object needed).

### POST /verify-otp

**Request:**

```json
{ "mobile": "9876543210", "otp": "123456" }
```

**Response:** `{ "success": true, "message": "..." }`.

### POST /sign-up

**Request:**

```json
{
  "mobile": "9876543210",
  "device_type": "android",
  "login_type": "mobile",
  "device_token": "<fcm_token>",
  "country_code": "91",
  "country_id": "India",
  "version": "1.0.0",
  "username": "John Doe",
  "email": "john@example.com"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Success",
  "data": {
    "user": {
      "id": 1,
      "username": "John Doe",
      "email": "john@example.com",
      "mobile": "9876543210",
      "country_code": "91",
      "device_type": "android",
      "login_type": "mobile",
      "device_token": "<fcm_token>",
      "device_id": "...",
      "country_id": 1,
      "access_token": "<jwt_or_token>",
      "is_active": "1",
      "co2": 0,
      "saved_money": 0,
      "created_at": "..."
    }
  }
}
```

This matches the parsing in `UserModel.fromJson` / `User.fromJson` in `lib/infrastructure/models/user_model.dart`.
