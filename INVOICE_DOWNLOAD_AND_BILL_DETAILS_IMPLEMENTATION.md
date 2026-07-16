# Download Invoice & In-App Bill Details — Implementation Guide

This document describes how **download invoice** and **in-app bill details** are implemented in the Order Details flow so you can replicate them in another project.

---

## 1. Overview

| Feature | Description | Where |
|--------|-------------|--------|
| **In-app bill info** | Item charges, GST breakdown, platform fee, total pay shown in the Order Details screen; GST has an info dialog with detailed breakdown | `order_details_page.dart` — `billDetails()` |
| **Download invoice** | Button (visible only when order status is `completd_pick_up`) calls API, gets base64 PDF, saves to device, opens with system viewer | `order_details_controller.dart` — `funDownloadInvoice()`, `saveAndOpenPdf()`; `order_details_page.dart` — Invoice button |
| **Refund invoice** | Same flow for cancelled/refund orders; API and method exist; UI button is commented out | `funDownloadRefundInvoice()`, `apiDownloadRefundInvoice` |

There is **no in-app PDF viewer**. The PDF is always saved to storage and opened with the system/default app via `open_filex`.

---

## 2. Dependencies

**pubspec.yaml**

```yaml
dependencies:
  open_filex: ^4.4.0
  # path_provider is typically a transitive dependency; add explicitly if needed:
  # path_provider: ^2.1.0
```

- **open_filex** — Opens the saved PDF file with the system handler (e.g. PDF viewer / Files app).
- **path_provider** — Used for `getExternalStorageDirectory()` and `getApplicationDocumentsDirectory()` (often pulled in by other packages; add explicitly if you get missing import errors).

---

## 3. API Layer

### 3.1 Endpoints

**File: `lib/infrastructure/network/api_constants.dart`**

```dart
var apiDownloadInvoice = '/download-invoice';
var apiDownloadRefundInvoice = '/download-refund-invoice';
```

- Base URL is configured in your Dio client; these are path suffixes.

### 3.2 Request

- **Method:** POST  
- **Body (JSON):** `{ "order_id": <int> }`  
- **Headers:** Include auth (e.g. `accessToken` in your Dio client).

### 3.3 Response (backend contract)

Expected JSON shape:

```json
{
  "success": true,
  "message": "optional message",
  "data": {
    "order_id": 123,
    "file_name": "invoice_123.pdf",
    "pdf_base64": "<base64-encoded PDF string>"
  }
}
```

- **data** can also be a **string** (just the base64 PDF); the Dio client normalizes that into an object with `pdf_base64` and null `order_id`/`file_name`.
- Backend may use keys like `filename`, `name`, `pdf`, `base64`, `file`; the client maps them (see below).

---

## 4. Model

**File: `lib/infrastructure/models/order_details_model.dart`**

```dart
class InvoiceModel extends Serializable {
  int? orderId;
  String? fileName;
  String? pdfBase64;

  InvoiceModel({this.orderId, this.fileName, this.pdfBase64});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    fileName = json['file_name'];
    pdfBase64 = json['pdf_base64'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'file_name': fileName,
      'pdf_base64': pdfBase64,
    };
  }
}
```

---

## 5. Dio client (API calls)

**File: `lib/infrastructure/network/dio_client.dart`**

Both methods:

1. POST to the endpoint with `params = {'order_id': orderId}` (and auth via your base client).
2. Parse response: `success`, `message`, and `data`.
3. Normalize `data` into a map for `InvoiceModel`:
   - If `data` is a **String** → treat as `pdf_base64`, `order_id` and `file_name` null.
   - If `data` is a **Map** → use `order_id`, and map `file_name` from `file_name` / `filename` / `name`, and `pdf_base64` from `pdf_base64` / `pdf` / `base64` / `file`.
   - If payload is at **root** (no `data` object) but root has `pdf_base64`/`pdf`/`base64` → build the same map from root.

**Download order invoice**

```dart
Future<ApiResponseModel<InvoiceModel>> funDownloadInvoiceApi(params) async {
  try {
    Response response = await _dio.post(
      apiEndPoints.apiDownloadInvoice,
      data: json.encode(params),
    );
    final raw = response.data as Map<String, dynamic>;
    final success = raw['success'] == true;
    final message = raw['message'];
    final dynamic d = raw['data'];
    Map<String, dynamic> dataMap = {};

    if (d is String) {
      dataMap = {
        'order_id': null,
        'file_name': null,
        'pdf_base64': d,
      };
    } else if (d is Map<String, dynamic>) {
      dataMap = {
        'order_id': d['order_id'],
        'file_name': d['file_name'] ?? d['filename'] ?? d['name'],
        'pdf_base64': d['pdf_base64'] ?? d['pdf'] ?? d['base64'] ?? d['file'],
      };
    } else {
      if (raw.containsKey('pdf_base64') ||
          raw.containsKey('pdf') ||
          raw.containsKey('base64')) {
        dataMap = {
          'order_id': raw['order_id'],
          'file_name': raw['file_name'] ?? raw['filename'] ?? raw['name'],
          'pdf_base64': raw['pdf_base64'] ?? raw['pdf'] ?? raw['base64'] ?? raw['file'],
        };
      }
    }

    return ApiResponseModel<InvoiceModel>(
      success: success,
      message: message,
      data: dataMap.isEmpty ? null : InvoiceModel.fromJson(dataMap),
    );
  } catch (error) {
    catchErrorHandler();
  }
  return ApiResponseModel<InvoiceModel>();
}
```

**Download refund invoice** — Same logic with `apiEndPoints.apiDownloadRefundInvoice` and a method like `funDownloadRefundInvoiceApi(params)`.

---

## 6. Controller logic

**File: `lib/presentation/order_details/order_details_controller.dart`**

### 6.1 Imports

```dart
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
```

### 6.2 Download order invoice

```dart
funDownloadInvoice() async {
  final progressDialog = ProgressDialog();
  progressDialog.show();
  var accessToken = await PrefManager.getString(AppConstants.accessToken);
  try {
    Map<String, dynamic> params = {'order_id': orderId};
    final ApiResponseModel<InvoiceModel> invoiceModel =
        await DioClient.base(accessToken: accessToken)
            .funDownloadInvoiceApi(params);

    if (invoiceModel.success == true && invoiceModel.data != null) {
      String? pdfBase64 = invoiceModel.data!.pdfBase64;
      final String fileName =
          (invoiceModel.data!.fileName ?? 'invoice_$orderId').toString();

      if (pdfBase64 == null || pdfBase64.isEmpty) {
        progressDialog.dismiss();
        errorScreen(error: 'Invoice data missing'.tr);
        return;
      }

      // Strip data URL prefix if present (e.g. "data:application/pdf;base64,...")
      final int commaIndex = pdfBase64.indexOf(',');
      if (commaIndex > 0 &&
          pdfBase64.substring(0, commaIndex).contains('base64')) {
        pdfBase64 = pdfBase64.substring(commaIndex + 1);
      }

      final Uint8List bytes = base64Decode(pdfBase64);
      await saveAndOpenPdf(
          bytes, fileName.endsWith('.pdf') ? fileName : '$fileName.pdf');

      progressDialog.dismiss();
      SnackBarUtil.showSuccess(message: 'Invoice downloaded'.tr);
    } else {
      progressDialog.dismiss();
      errorScreen(
          error: (invoiceModel.message ?? 'Failed to download invoice').tr);
    }
  } on CustomHttpException catch (exception) {
    progressDialog.dismiss();
    errorScreen(
        error: handleApiException(
            exception.code, exception.response, exception.exception,
            type: exception.type));
  } catch (exception) {
    progressDialog.dismiss();
    errorScreen(error: 'something_went_wrong'.tr);
  }
}
```

### 6.3 Download refund invoice

Same structure: use `funDownloadRefundInvoiceApi(params)`, same validation and `saveAndOpenPdf`. Use when order is cancelled and you want a refund invoice.

### 6.4 Save and open PDF

```dart
Future<void> saveAndOpenPdf(Uint8List pdfBytes, String fileName) async {
  try {
    Directory dir;

    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory())!;
      // Use public Download folder so user can find it in Downloads app
      dir = Directory('${dir.path.split("Android")[0]}Download');
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = '${dir.path}/$fileName';
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes, flush: true);

    await OpenFilex.open(filePath);
  } catch (e) {
    print('Error saving/opening PDF: $e');
  }
}
```

- **Android:** Saves to the **public Download** directory (derived from external storage path, then `Download`).
- **iOS:** Saves to app documents directory; `OpenFilex.open()` opens it with the system viewer.

---

## 7. UI — Bill details and invoice button

**File: `lib/presentation/order_details/order_details_page.dart`**

### 7.1 Where it appears

The **Bill Details** block is built by `billDetails()`. It includes:

1. A **header row**: left = "Bill Details", right = **Invoice** button (only when `orderStatus == 'completd_pick_up'`).
2. A **bordered container** with:
   - Item Charges (original price strikethrough + discounted price)
   - Total GST (with info icon that opens a dialog)
   - Platform Fee (with subtitle)
   - Divider
   - Total Pay

### 7.2 Invoice button (download)

Only shown when the order is in **completed pickup** state:

```dart
(controller.orderStatus.value == 'completd_pick_up'
    ? Container(
        decoration: BoxDecoration(
          border: Border.all(color: ColorsTheme.colC4D9D4, width: 1),
          borderRadius: BorderRadius.circular(30),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: GestureDetector(
          onTap: () {
            if (controller.orderStatus.value == 'completd_pick_up') {
              controller.funDownloadInvoice();
            }
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Invoice'.tr, style: semiBoldTextStyle(...)),
              SizedBox(width: 5),
              Icon(Icons.download, size: 16, color: ColorsTheme.colPrimary),
            ],
          ),
        ),
      )
    : const SizedBox(width: 0))
```

- Tapping runs `funDownloadInvoice()` → API → save → open with `OpenFilex`.

### 7.3 In-app bill breakdown (data source)

Controller observables used in `billDetails()`:

| Observable | Source | Usage in UI |
|------------|--------|-------------|
| `subTotalPrice` | `orderModel.data!.totalPaid` | Item charges (discounted) value |
| `subTotalOfferPrice` | `orderModel.data!.price` | Item charges (original, strikethrough) |
| `otherTotalPrice` | `orderModel.data!.gstCharge` | GST on item charges (in GST dialog) |
| `platformFee` | `PrefManager.getDouble(AppConstants.platformFee)` | Platform fee row |
| `platformGst` | `PrefManager.getDouble(AppConstants.platformGst)` | GST on platform fee (in dialog) |
| `combinedGst` | `otherTotalPrice + platformGst` | Total GST row and dialog total |
| `totalPrice` | `subTotalPrice + combinedGst + platformFee` | Total Pay row |
| `currency` | From arguments / order | Prefix for all amounts |

Filled in **getOrderDetails()** after a successful order details API call:

```dart
subTotalPrice.value = double.parse(orderModel.data!.totalPaid.toString());
subTotalOfferPrice.value = double.parse(orderModel.data!.price.toString());
otherTotalPrice.value = double.parse(orderModel.data!.gstCharge.toString());
platformFee.value = await PrefManager.getDouble(AppConstants.platformFee);
platformGst.value = await PrefManager.getDouble(AppConstants.platformGst);
combinedGst.value = otherTotalPrice.value + platformGst.value;
totalPrice.value = subTotalPrice.value + combinedGst.value + platformFee.value;
```

### 7.4 Bill details container (structure)

- **Item Charges:** Label left; right side: strikethrough `currency + subTotalOfferPrice`, then `currency + subTotalPrice`.
- **Total GST:** Label left; right side: info icon (opens dialog) + `currency + combinedGst`.  
  **Dialog:** Title text, divider, then:
  - GST on Item Charges → `otherTotalPrice`
  - GST on Platform Fee → `platformGst`
  - Total GST → `combinedGst`
  - OK button.
- **Platform Fee:** Label + subtitle “(This keeps us maintaining our service)”; value `currency + platformFee`.
- **Divider.**
- **Total Pay:** `currency + totalPrice`.

Use your existing `semiBoldTextStyle`, `regularTextStyle`, `dimen12`, `ColorsTheme`, etc. for consistency.

---

## 8. Flow summary

1. User opens **Order Details** for an order; **getOrderDetails()** loads order and fills bill observables (and order status).
2. **Bill Details** section shows the breakdown in-app (item charges, GST, platform fee, total).
3. When **orderStatus == 'completd_pick_up'**, the **Invoice** button is visible.
4. User taps **Invoice** → **funDownloadInvoice()**:
   - Show progress dialog.
   - POST `/download-invoice` with `{ "order_id": orderId }`.
   - Parse response; if `data.pdf_base64` is missing → show “Invoice data missing”.
   - Optional: strip `data:...;base64,` prefix from the string.
   - Base64-decode → `Uint8List`.
   - **saveAndOpenPdf(bytes, fileName)**:
     - Android: save to public `Download` folder; iOS: app documents.
     - Call **OpenFilex.open(filePath)** to open in system viewer.
   - Dismiss progress, show “Invoice downloaded” success (or API error message).

Refund invoice is the same flow with **funDownloadRefundInvoice()** and **apiDownloadRefundInvoice**; you can show a “Refund invoice” or “Download refund invoice” button when the order is cancelled and enable that flow.

---

## 9. Optional: show PDF inside the app

Currently the app does **not** render the PDF in-app; it only saves and opens externally. To add an in-app viewer you could:

1. After decoding base64 to `Uint8List`, write to a temp file and pass the path to a viewer (e.g. **pdfx**, **syncfusion_flutter_pdfviewer**, or a WebView with a data URL / file URL).
2. Or use a package that accepts `Uint8List` (e.g. **pdfx** with `PdfDocument.openData(bytes)`) and show it in a full-screen dialog or new route.

The existing **saveAndOpenPdf** and **OpenFilex.open()** stay as-is for “download and open in system app”; the in-app viewer would be an extra option (e.g. “View” vs “Download”).

---

## 10. File reference

| File | Responsibility |
|------|----------------|
| `lib/infrastructure/network/api_constants.dart` | `apiDownloadInvoice`, `apiDownloadRefundInvoice` |
| `lib/infrastructure/network/dio_client.dart` | `funDownloadInvoiceApi`, `funDownloadRefundInvoiceApi` (parse response, map to `InvoiceModel`) |
| `lib/infrastructure/models/order_details_model.dart` | `InvoiceModel` (orderId, fileName, pdfBase64) |
| `lib/presentation/order_details/order_details_controller.dart` | `funDownloadInvoice()`, `funDownloadRefundInvoice()`, `saveAndOpenPdf()`; bill observables and `getOrderDetails()` |
| `lib/presentation/order_details/order_details_page.dart` | `billDetails()` — Bill Details header, Invoice button, item charges, GST (with dialog), platform fee, total pay |

---

## 11. Backend expectations (for your API)

- **POST /download-invoice** (and optionally **/download-refund-invoice**):
  - Body: `{ "order_id": 123 }`.
  - Response: `{ "success": true, "message": null, "data": { "order_id": 123, "file_name": "invoice_123.pdf", "pdf_base64": "<base64>" } }`.
  - Or `"data": "<base64>"` only; or payload at root with `pdf_base64` / `pdf` / `base64` — the client normalizes these.
- Ensure the PDF is generated server-side and encoded as base64; the app does not build the PDF itself.

This is the full implementation of **download invoice** and **in-app bill details** as used in Order Details; you can mirror it in a fresh project using the same structure.
