# FCM order_picked Fixes for New Codebase

Your new implementation is correct for `order_confirmed` and `order_cancelled`. For **order_picked** to match the OLD app in all states (including foreground), apply the following changes.

---

## 1. Handle both `order_picked` and `order_pick` in foreground (`onMessage`)

**Current (only one variant):**
```dart
case 'order_picked':
  _handleOrderPicked(data, notification?.body, container);
  break;
```

**Replace with:**
```dart
case 'order_picked':
case 'order_pick':
  _handleOrderPicked(data, notification?.body, container);
  break;
```

---

## 2. Pass notification body when handling initial message and tap

**Current:** `_handleNotificationData` only receives `data`, so when you call `_handleOrderPicked(data, null, container)` from initial/tap, the body is never used and orderId cannot be extracted from "Order #123" text.

**Change the signature of `_handleNotificationData`** to accept an optional body:

```dart
void _handleNotificationData(
  Map<String, dynamic> data,
  ProviderContainer container, {
  required bool isInitial,
  String? notificationBody,
}) {
  final type = data['type']?.toString() ?? '';
  // ... rest unchanged until order_picked block ...
```

**In the order_picked block**, pass the body into `_handleOrderPicked`:

```dart
    if (type == 'order_picked' || type == 'order_pick') {
      _handleOrderPicked(
        data,
        notificationBody ?? data['message']?.toString(),
        container,
      );
      return;
    }
```

**When calling `_handleNotificationData`:**

- From **initial message**:
```dart
  if (initialMessage != null) {
    AppLogger.logInfo(
      'FCM(initialMessage) received: ${jsonEncode(initialMessage.data)}',
      name: 'fcm.initial',
    );
    _handleNotificationData(
      initialMessage.data,
      container,
      isInitial: true,
      notificationBody: initialMessage.notification?.body,
    );
  }
```

- From **onMessageOpenedApp**:
```dart
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage? message) {
    if (message != null) {
      AppLogger.logInfo(
        'FCM(onMessageOpenedApp) data=${jsonEncode(message.data)}',
        name: 'fcm.opened',
      );
      _handleNotificationData(
        message.data,
        container,
        isInitial: false,
        notificationBody: message.notification?.body,
      );
    }
  });
```

---

## 3. Optional: small delay for foreground navigation (matches OLD app)

In the `onMessage` listener, for order_picked/order_pick you can add a short delay so the navigator is ready:

```dart
case 'order_picked':
case 'order_pick':
  Future.microtask(() {
    _handleOrderPicked(data, notification?.body, container);
  });
  // Or: Future.delayed(const Duration(milliseconds: 100), () { ... });
  break;
```

If you already see navigation working in foreground without delay, you can keep a direct call.

---

## Checklist after applying

- [ ] Foreground: both `type == 'order_picked'` and `type == 'order_pick'` trigger `_handleOrderPicked` (no fall-through to default/local notification).
- [ ] Initial message (app killed, opened via notification): `notificationBody` is passed so `_handleOrderPicked` can parse orderId from body text if needed.
- [ ] Tap from background: same as above, `notificationBody` passed from `message.notification?.body`.
- [ ] `_handleNotificationData` uses `type == 'order_picked' || type == 'order_pick'` so tap/initial both route to order-picked screen.

---

## Why foreground might have “not received” the notification

- If the **backend sends `order_pick`** (no "ed"), your current switch only handles `order_picked`, so the message goes to `default` and only a local notification is shown (and no auto-navigation). Adding `case 'order_pick':` fixes that.
- If the **payload has no `order_id`** in `data` and the order number is only in the notification body (e.g. "Order #38932 has been picked!"), then in **foreground** you already pass `notification?.body` so extraction works. For **tap/initial** it only works after you pass `notificationBody` as above.

After these changes, order_picked behavior in the new app matches the OLD app for foreground, background tap, and killed-state open.
