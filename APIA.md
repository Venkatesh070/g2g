# Network & API Guidelines (Replica-ready)

This document explains the network architecture, API conventions, error handling, and integration patterns used by the reference project. Drop this file into a replica project to implement APIs consistently across modules/screens.

Contents
- Architecture overview
- Core components & files to implement
- ApiConstants (endpoints)
- ApiResponseModel & typing
- Clients: base, multipart, map
- Interceptors & token refresh
- Error handling & mapping
- Endpoint reference (method, path, params, response, usage)
- Response normalization (edge cases)
- Usage examples
- Best-practices & checklist
- Tests to add

---

## 1. Architecture overview
- Single network layer class (DioClient) handling all API calls.
- Centralized endpoints file (`ApiConstants`).
- Responses wrapped in a common envelope: `{ success, message, data }`.
- Errors normalized into `CustomHttpException` with a `type` flag and handled via `handleApiException`.
- Controllers/services follow a standard try/catch pattern to present user-friendly messages.

---

## 2. Core components to include in replica
- ApiConstants — all endpoint URIs + baseUrl.
- Network client with three configs:
  - `base` (JSON, Authorization bearer if token)
  - `multipart` (multipart/form-data)
  - `map` (Google Maps base)
- Logging interceptor and queued interceptor (X-App-Version, token refresh, 403 handling).
- ApiResponseModel<T> and Serializable interface.
- CustomHttpException and handleApiException mapping.
- PrefManager (token & user persistence).

---

## 3. ApiConstants (structure)
- Keep baseUrl, mapBaseUrl, and per-endpoint strings in one class to reuse across the app.

Example:
```dart
class ApiConstants {
  var baseUrl = 'https://api.example.com/api/v1';
  var mapBaseUrl = 'https://maps.googleapis.com/maps/api/';
  var apiLogin = "/login";
  var apiSignup = "/sign-up";
  var apiPlaceOrder = "/order";
  // ...
}
```

---

## 4. ApiResponseModel<T>
- Standard wrapper used by most APIs:
```dart
class ApiResponseModel<T extends Serializable> {
  bool? success;
  String? message;
  T? data;
}
```
- Controllers check `resp.success` and `resp.data` for business-level handling.

---

## 5. Clients to implement
- `baseClient(accessToken?)`: JSON endpoints, timeout 10s, sets Authorization header if token.
- `multipartClient(accessToken?)`: Content-Type multipart/form-data, timeout 30s.
- `mapClient()`: Google Maps base URL, no Authorization.
- Each client adds:
  - Logging interceptor
  - Queued interceptor for app-version header + token refresh + 403 logout
  - Options: receiveDataWhenStatusError = true

---

## 6. Interceptors & token refresh pattern
- Interceptor responsibilities:
  - Add `X-App-Version` header.
  - Log request/response/error (dev).
  - On 401:
    - Pause/queue outgoing requests.
    - Call refresh endpoint once using a separate client instance.
    - If refresh succeeds: update stored token, update original request's Authorization header, retry and resolve.
    - If refresh fails: propagate error (controllers handle logout).
  - On 403:
    - Clear stored user & tokens and navigate to login/intro.
- Important: implement a queue/lock to avoid concurrent token refresh calls.

---

## 7. Error normalization (catchErrorHandler pattern)
- Map Dio errors into `CustomHttpException` with `type`:
  - SocketException -> type `'socketError'` (no internet)
  - Timeout -> type `'connectionTimeout'`
  - HTTP error -> extract backend message (`response.data['message']`) and throw type `'error'`
- Controllers do:
```dart
} on CustomHttpException catch (ex) {
  final msg = handleApiException(ex.code, ex.response, ex.exception, type: ex.type);
  showError(msg);
}
```

---

## 8. Endpoint reference — examples and sample JSON responses
Notes:
- All success responses follow the envelope: `{ "success": bool, "message": string, "data": ... }`.
- Error responses often contain a `message` field; interceptors extract it.
- Some endpoints may return inconsistent shapes; client must normalize (invoice, order id).

Below are key endpoints with inferred request and response examples based on models in `lib/infrastructure/models`.

1) Login (POST `/login`)
- Request:
```json
{
  "type":"mobile",
  "source":"9876543210",
  "device_type":"android",
  "device_token":"fcm_token_value",
  "country_code":"91",
  "version":"1.0.0"
}
```
- Success:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "user": {
      "id": 123,
      "username": "John Doe",
      "email": "john@example.com",
      "mobile": "9876543210",
      "country_code": "91",
      "access_token": "jwt-token-string",
      "co2": 12.34,
      "saved_money": 56.78,
      "created_at": "2025-01-01 12:00:00"
    }
  }
}
```

2) Signup (POST `/sign-up`)
- Request & response: same user model as login.

3) Social Login (POST `/social-login`)
- Request sample:
```json
{
  "provider":"google",
  "social_id":"google_id_abc123",
  "email":"john@example.com",
  "username":"John Doe",
  "device_type":"android",
  "device_token":"fcm_token"
}
```

4) Send OTP (POST `/send-otp` or `/send-email-otp`)
- Request (phone):
```json
{ "mobile":"9876543210", "country_code":"91", "type":"mobile" }
```
- Success:
```json
{ "success": true, "message": "OTP sent", "data": {} }
```

5) Verify OTP (POST `/verify-otp` or `/check-email-otp`)
- Request:
```json
{ "type":"mobile", "source":"9876543210", "otp":"123456" }
```

6) Get Countries (GET `/getCountrylist`)
- Success:
```json
{
  "success": true,
  "message": "Countries list",
  "data": {
    "countryList": [
      { "id":1, "country":"India", "dialing_code":"91", "currency":"INR" },
      { "id":2, "country":"United States", "dialing_code":"1", "currency":"USD" }
    ]
  }
}
```

7) App Content (GET `/getappcontent`)
- Success (example):
```json
{ "success": true, "message": "App content", "data": { "terms":"...", "privacy":"..." } }
```

8) Places Autocomplete (Google Maps query)
- Request: mapBase autocomplete with `input=...`
- Success (simplified):
```json
{ "predictions":[{"description":"Delhi, India","place_id":"xyz"}], "status":"OK" }
```

9) Geocode (Google Maps geocode)
- Success (client returns raw response.data).

10) Home feed (POST `/home`)
- Request: location, filters, page.
- Success:
```json
{
  "success": true,
  "message": "Home data",
  "data": {
    "restaurant_list": [
      { "id":101, "restaurant_name":"Tasty Bites", "final_price":150.0, "offer_price":120.0 }
    ],
    "current_page":1, "currency":"INR", "platform_fee":10.0, "platform_gst":5.0
  }
}
```

11) Restaurant details (POST `/magic-restaurant-details`)
- Request: `{ "restro_id": 101 }`
- Success: ApiResponseModel<HomeDetailsModel> (restaurant + menus)

12) Add to cart (POST `/add-cart`)
- Request:
```json
{
  "restro_id": 101,
  "menu_data": [ { "menu_id": 201, "quantity": 2 } ],
  "cart_id": 555
}
```
- Success: ApiResponseModel<CartModel>, sample:
```json
{
  "success": true,
  "message": "Cart updated",
  "data": {
    "cartDetails": {
      "cart_id": 555,
      "menu_detail":[ { "menu_id":201, "menu_name":"Paneer", "menu_final_price":120.0, "menu_selected_quantity":2 } ],
      "offer_price":240.0,
      "final_price":240.0,
      "gst_charge":12.0,
      "phonepe": true,
      "razorpay": true
    },
    "callback_url":"https://goodtograb.com/callback-url",
    "resorpay_api_key":"rzp_test_XXXX"
  }
}
```

13) Get cart detail (POST `/get-cart-detail`)
- Request: `{ "cart_id": 555 }`
- Success: CartModel (same shape as above).

14) Restaurant availability (POST `/restaurant-availability`)
- Request: `{ "restro_id": 101 }`
- Success:
```json
{ "success": true, "message":"Availability", "data": { "availability":[{"date":"2026-02-19","isAvailable":true}] } }
```

15) Remove cart (POST `/remove-cart`)
- Request: `{ "cart_id":555, "menu_id":201 }`
- Success: `{ "success": true, "message":"Item removed", "data": {} }`

16) Create pending order (POST `/order`) — used before payment
- Request:
```json
{
  "restro_id":101,
  "cart_id":555,
  "price":240.0,
  "total_paid":240.0,
  "pickup_date":"2026-02-19",
  "payment_status":"pending",
  "payment_method":"phonePe",
  "payment_id":"pg_txn_123"
}
```
- Success (note: client extracts `data.order_id` — int or string):
```json
{ "success": true, "message":"Order created", "data": { "order_id": 1001 } }
```

17) Create payment intent (POST `/createIntent`)
- Success (ApiResponseModel<CreateIntentModel>):
```json
{
  "success": true,
  "message":"Intent created",
  "data": { "payment": { "transaction_id":9876, "payment_id":"pi_abc123", "intentUrl":"https://..." } }
}
```

18) Check intent status (POST `/checks-intent-status`)
- Request: `{ "payment_id":"pi_abc123" }`
- Success: payment status object in `data`.

19) Confirm payment success (POST `/order-payment-success`)
- Request:
```json
{
  "order_id":1001,
  "payment_status":"paid",
  "original_transaction_id":9876,
  "cart_id":555,
  "payment_id":"pg_txn_123",
  "payment_method":"phonePe"
}
```
- Success:
```json
{ "success": true, "message":"Payment confirmed", "data": { "order_id":1001, "status":"confirmation_pending" } }
```

20) Payment fail (POST `/order-payment-failed`)
- Request: `{ "order_id":1001, "payment_status":"Failed" }`
- Success: `{ "success": true, "message":"Failure recorded", "data": {} }`

21) Complete order with transaction (POST `/place-order-with-transaction`)
- Request:
```json
{ "original_transaction_id":9876, "merchant_transaction_id":"merchant_abc123" }
```
- Success: `{ "success": true, "message":"Order completed", "data": {} }`

22) Orders list (GET `/my-orders`) and order details (POST `/order-detail`)
- Orders list: returns ApiResponseModel<OrderModel> with `orders_list`.
- Order detail: ApiResponseModel<OrderDetailsModel> with menu details, restaurant details, pickup code, rating status, etc.

23) Download invoice (POST `/download-invoice`, `/download-refund-invoice`)
- Request: `{ "order_id": 1001 }`
- Backend shapes:
  - `data` may be a base64 string (pdf) OR an object with `pdf_base64` / `file_name` etc.
- Client normalization returns `InvoiceModel { order_id, file_name, pdf_base64 }`.

24) Submit survey (POST `/submit-survey`)
- Accepts both `success` or `status` keys to infer success.

25) Add rating (POST `/add-rating`), Order cancel (POST `/order-cancel`), Favourites, Profile endpoints, Get restro link, Earning, etc. — follow same envelope and typing.

---

## 9. Response normalization & edge cases
- Invoice endpoints: handle string vs object in `data`.
- Order creation: `order_id` may be string or int — coerce safely in controllers.
- Survey endpoint: `success` or `status` both indicate success in some backends.

---

## 10. Usage examples (controller pattern)
```dart
try {
  final resp = await DioClient.base(accessToken: token).funGetCartApi({'cart_id': cartId});
  if (resp != null && resp.success == true && resp.data != null) {
    // success
  } else {
    showError(resp?.message ?? 'Unknown error');
  }
} on CustomHttpException catch (ex) {
  final msg = handleApiException(ex.code, ex.response, ex.exception, type: ex.type);
  showError(msg);
} catch (e) {
  showError('something_went_wrong'.tr);
}
```

---

## 11. Best practices & checklist
- [ ] Implement ApiConstants and ApiResponseModel.
- [ ] Implement CustomHttpException and handleApiException mapping.
- [ ] Implement DioClient with base/multipart/map, logging and queued interceptor.
- [ ] Make token refresh atomic & queued.
- [ ] Normalize inconsistent payloads (invoice, order id).
- [ ] Controllers follow consistent try → CustomHttpException → generic catch pattern.
- [ ] Add unit tests for refresh logic, socket/timeouts, and invoice normalization.

---

## 12. Recommended tests
- Token refresh success: original request is retried and returns expected value.
- SocketException: client throws CustomHttpException(type: 'socketError').
- Timeout: client throws CustomHttpException(type: 'connectionTimeout').
- Invoice normalization: returns InvoiceModel for both string and object payloads.
- Integration: place-order, payment confirmation, and order detail flows.

---

If you want, I can:
- Add this README file to the repo (done).
- Generate a ready-to-drop `network/` folder implementing `DioClient`, interceptors, ApiConstants and models normalization.
- Expand the sample JSON set further by auto-generating full examples from all model files.

Tell me which next step you'd like.

# good_grab

Application used for order magical box

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
