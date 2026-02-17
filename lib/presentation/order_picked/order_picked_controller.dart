import 'dart:async';
import 'package:get/get.dart';
import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/order_details_model.dart';
import '../../infrastructure/models/survey_model.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/error_screen.dart';
import '../../infrastructure/shared/http_exception.dart';
import '../../infrastructure/shared/pref_manager.dart';
import '../../infrastructure/shared/progress_dialog.dart';
import '../../infrastructure/shared/snackbar.util.dart';
import '../../infrastructure/navigation/routes.dart';
import '../survey/survey_controller.dart';

class OrderPickedController extends GetxController {
  var orderId = 0;
  var resId = 0;
  var rating = 0.0.obs;
  var isRated = false.obs;
  var isLoading = false.obs;
  var isLoadingOrderDetails = false.obs;

  // Order details
  OrderDetailsModel? orderDetailsModel;

  // Survey data from notification
  SurveyModel? surveyData;
  int? surveyId;

  // Survey state
  var showSurvey = false.obs;

  // Thank you timer
  Timer? thankYouTimer;

  @override
  void onInit() {
    super.onInit();
    orderId = Get.arguments['orderId'] ?? 0;
    resId = Get.arguments['resId'] ?? 0;

    // Get survey data from arguments
    final surveyDataArg = Get.arguments['surveyData'];
    final surveyIdArg = Get.arguments['surveyId'];

    if (surveyDataArg != null) {
      try {
        surveyData = SurveyModel.fromJson(surveyDataArg);
      } catch (e) {
        print("Error parsing survey data: $e");
      }
    }

    if (surveyIdArg != null) {
      surveyId = surveyIdArg;
    }

    // Fetch order details
    if (orderId > 0) {
      getOrderDetails();
    }
  }

  Future<void> getOrderDetails() async {
    if (orderId == 0) return;

    isLoadingOrderDetails.value = true;
    var accessToken = await PrefManager.getString(AppConstants.accessToken);

    try {
      Map<String, dynamic> params = {'order_id': orderId};
      ApiResponseModel<OrderDetailsModel> orderModel =
          await DioClient.base(accessToken: accessToken)
              .funGetOrderDetailsApi(params);

      if (orderModel.success! && orderModel.data != null) {
        orderDetailsModel = orderModel.data!;
        isLoadingOrderDetails.value = false;
      } else {
        isLoadingOrderDetails.value = false;
        print("Failed to load order details: ${orderModel.message}");
      }
    } on CustomHttpException catch (exception) {
      isLoadingOrderDetails.value = false;
      print(
          "Error loading order details: ${exception.response ?? exception.exception.toString()}");
    } catch (exception) {
      isLoadingOrderDetails.value = false;
      print("Error loading order details: $exception");
    }
  }

  Future<void> submitRating(double selectedRating) async {
    if (isRated.value || isLoading.value) return;

    rating.value = selectedRating;
    isLoading.value = true;

    var progressDialog = ProgressDialog();
    progressDialog.show();

    var accessToken = await PrefManager.getString(AppConstants.accessToken);

    try {
      Map<String, dynamic> params = {
        'order_id': orderId,
        'restro_id': resId,
        'rating': selectedRating,
      };

      ApiResponseModel baseModel =
          await DioClient.base(accessToken: accessToken)
              .funAddOrderRatingApi(params);

      if (baseModel.success!) {
        progressDialog.dismiss();
        isRated.value = true;
        isLoading.value = false;

        // Show success message briefly
        SnackBarUtil.showSuccess(
            message: baseModel.message ?? 'Rating submitted successfully!');

        // Check if survey data exists and show survey inline
        if (surveyData != null || surveyId != null) {
          // Small delay to show success feedback, then show survey inline
          await Future.delayed(const Duration(milliseconds: 300));
          await _startSurveyInline();
        } else {
          // No survey data, show ThankYou page directly
          await Future.delayed(const Duration(milliseconds: 500));
          _showThankYouAndNavigate();
        }
      } else {
        progressDialog.dismiss();
        isLoading.value = false;
        errorScreen(error: baseModel.message!);
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      isLoading.value = false;
      errorScreen(
          error: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      isLoading.value = false;
      errorScreen(error: 'something_went_wrong'.tr);
    }
  }

  Future<void> _startSurveyInline() async {
    // Ensure SurveyController is registered
    if (!Get.isRegistered<SurveyController>()) {
      Get.put(SurveyController());
    }

    final surveyController = Get.find<SurveyController>();

    // Set completion callback to show thank you page, then navigate
    surveyController.setOnSurveyCompleteCallback(() {
      _showThankYouAndNavigate();
    });

    // Always fetch survey from JSON URL using surveyId (don't use surveyData from notification)
    if (surveyId != null) {
      print(
          "OrderPickedController: Fetching survey from JSON URL for surveyId: $surveyId, orderId: $orderId");
      // Fetch survey data from JSON URL
      final fetchedSurvey = await surveyController.fetchSurveyData(surveyId!);
      if (fetchedSurvey != null &&
          fetchedSurvey.questions != null &&
          fetchedSurvey.questions!.isNotEmpty) {
        print(
            "OrderPickedController: Survey fetched successfully, starting inline with orderId: $orderId");
        // Ensure orderId is set in survey model (from notification payload)
        if (orderId > 0) {
          fetchedSurvey.orderId = orderId;
        }
        // Use a method that doesn't check for skipped surveys (user just rated, they should see survey)
        // Pass orderId explicitly to ensure it's set
        await surveyController.startSurveyFromRatingInlineNoSkipCheck(
            fetchedSurvey, orderId);
        showSurvey.value = true;
      } else {
        print(
            "OrderPickedController: Survey fetch failed or has no questions, navigating to order listing");
        // Survey fetch failed or no questions, navigate to order listing
        _navigateToOrderListing();
      }
    } else {
      print(
          "OrderPickedController: No surveyId available, navigating to order listing");
      // No survey ID, navigate to order listing
      _navigateToOrderListing();
    }
  }

  void _showThankYouAndNavigate() {
    // Ensure SurveyController is registered to show ThankYou page
    if (!Get.isRegistered<SurveyController>()) {
      Get.put(SurveyController());
    }

    final surveyController = Get.find<SurveyController>();
    surveyController.showThankYou.value = true;

    // Set showSurvey to true so the page shows ThankYou content
    showSurvey.value = true;

    // Cancel any existing timer
    thankYouTimer?.cancel();

    // Auto-close after 10 seconds
    thankYouTimer = Timer(const Duration(seconds: 10000000), () {
      _navigateToOrderListing();
    });
  }

  void closeThankYouAndNavigate() {
    // Cancel timer if user closes manually
    thankYouTimer?.cancel();
    _navigateToOrderListing();
  }

  @override
  void onClose() {
    // Cancel timer when controller is disposed
    thankYouTimer?.cancel();
    super.onClose();
  }

  void _navigateToOrderListing() {
    // Navigate to order listing (Orders tab)
    Get.offAllNamed(Routes.home, arguments: {
      'permission': 1,
      'selectedIndex': 2, // Orders tab
    });
  }

  // Make this method public for skip functionality
  void navigateToOrderListing() {
    _navigateToOrderListing();
  }

  void skipToHome() {
    Get.offAllNamed(Routes.home, arguments: {
      'permission': 1,
      'selectedIndex': 2,
    });
  }

  void navigateToContactScreen() {
    Get.toNamed(Routes.appContents, arguments: {
      'title': 'Contact us'.tr,
      'flag': 'contact'
    });
  }
}
