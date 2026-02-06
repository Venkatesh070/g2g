import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../infrastructure/core/base/base_view.dart';
import '../../infrastructure/models/order_details_model.dart';
import '../../infrastructure/models/survey_model.dart'
    show SurveyModel, SurveyQuestionModel, SurveyOption;
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import '../../res.dart';
import '../survey/survey_controller.dart';
import 'order_picked_controller.dart';

class OrderPickedPage extends BaseView<OrderPickedController> {
  OrderPickedPage({super.key});

  @override
  bool onBackPressed() {
    // Prevent back navigation, user must rate or skip
    return false;
  }

  @override
  Widget body(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorsTheme.colPrimary.withOpacity(0.1),
              ColorsTheme.colWhite,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => controller.skipToHome(),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: ColorsTheme.colWhite,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        color: ColorsTheme.colBlack,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Obx(() {
                // Check if survey is active and show thank you or survey questions
                if (controller.showSurvey.value &&
                    Get.isRegistered<SurveyController>()) {
                  final surveyController = Get.find<SurveyController>();

                  // Show thank you page if survey is completed
                  if (surveyController.showThankYou.value) {
                    return _buildThankYouPage();
                  }

                  // Show survey questions below rating section
                  return _buildSurveyContent();
                }

                // Otherwise show order picked content
                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 1),

                      // Rating section at TOP
                      _buildRatingSection(),

                      SizedBox(height: 20),

                      // Success animation
                      SizedBox(
                        height: 150,
                        child: Lottie.asset(
                          'assets/successOrder.json',
                          repeat: true,
                          animate: true,
                        ),
                      ),

                      SizedBox(height: 30),

                      // "Order Picked" message
                      Text(
                        'Order Picked! 🎉'.tr,
                        style: boldTextStyle(
                          fontSize: dimen24,
                          color: ColorsTheme.colBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 16),

                      // Catchy text with Order ID
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Your order '.tr,
                              style: semiBoldTextStyle(
                                fontSize: dimen16,
                                color: ColorsTheme.colBlack.withOpacity(0.7),
                              ),
                            ),
                            TextSpan(
                              text: '#${controller.orderId}',
                              style: boldTextStyle(
                                fontSize: dimen18,
                                color: ColorsTheme.colPrimary,
                              ),
                            ),
                            TextSpan(
                              text: ' has been picked up successfully!'.tr,
                              style: semiBoldTextStyle(
                                fontSize: dimen16,
                                color: ColorsTheme.colBlack.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 12),

                      Text(
                        'Thank you for choosing us. We hope you enjoy your meal! 😊'
                            .tr,
                        style: regularTextStyle(
                          fontSize: dimen14,
                          color: ColorsTheme.col475751,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20),

                      // Order Details Card at bottom
                      Obx(() => controller.isLoadingOrderDetails.value
                          ? Container(
                              padding: const EdgeInsets.all(20),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: ColorsTheme.colPrimary,
                                ),
                              ),
                            )
                          : controller.orderDetailsModel != null
                              ? _buildOrderDetailsCard()
                              : SizedBox.shrink()),

                      SizedBox(height: 20),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderDetailsCard() {
    final order = controller.orderDetailsModel!;
    final restaurantName =
        order.restaurantDetail?.restaurantName ?? 'Restaurant';
    final paymentMethodRaw = order.paymentMethod ?? 'N/A';
    final paymentMethod = paymentMethodRaw.isNotEmpty
        ? paymentMethodRaw[0].toUpperCase() +
            paymentMethodRaw.substring(1).toLowerCase()
        : 'N/A';
    final totalPaid = order.totalPaid ?? '0';
    final itemQty = order.itemQty ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorsTheme.colWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsTheme.colC4D9D4,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Restaurant Name
          Row(
            children: [
              Icon(
                Icons.restaurant,
                color: ColorsTheme.colPrimary,
                size: 18,
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  restaurantName,
                  style: semiBoldTextStyle(
                    fontSize: dimen14,
                    color: ColorsTheme.colBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Price and Quantity Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Final Paid Price
              Row(
                children: [
                  Text(
                    'Paid : '.tr,
                    style: regularTextStyle(
                      fontSize: dimen12,
                      color: ColorsTheme.col475751,
                    ),
                  ),
                  Text(
                    '₹$totalPaid',
                    style: semiBoldTextStyle(
                      fontSize: dimen14,
                      color: ColorsTheme.colPrimary,
                    ),
                  ),
                ],
              ),
              // Quantity
              Row(
                children: [
                  Text(
                    'Qty : '.tr,
                    style: regularTextStyle(
                      fontSize: dimen12,
                      color: ColorsTheme.col475751,
                    ),
                  ),
                  Text(
                    '$itemQty',
                    style: semiBoldTextStyle(
                      fontSize: dimen14,
                      color: ColorsTheme.colBlack,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8),

          // Price
          // Row(
          //   children: [
          //     Text(
          //       'Price: '.tr,
          //       style: regularTextStyle(
          //         fontSize: dimen12,
          //         color: ColorsTheme.col475751,
          //       ),
          //     ),
          //     Text(
          //       '₹$price',
          //       style: semiBoldTextStyle(
          //         fontSize: dimen13,
          //         color: ColorsTheme.colBlack,
          //       ),
          //     ),
          //   ],
          // ),

          SizedBox(height: 8),

          // Payment Method - Compact
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.payment,
                color: ColorsTheme.colPrimary,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Payment : '.tr,
                style: regularTextStyle(
                  fontSize: dimen11,
                  color: ColorsTheme.col475751,
                ),
              ),
              Text(
                paymentMethod,
                style: semiBoldTextStyle(
                  fontSize: dimen12,
                  color: ColorsTheme.colBlack,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemRow(MenuDetails menuItem) {
    final hasDiscount = menuItem.offerPrice != null &&
        menuItem.finalPrice != null &&
        menuItem.offerPrice! > menuItem.finalPrice!;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food preference icon
          Container(
            margin: const EdgeInsets.only(right: 10, top: 2),
            child: Image.asset(
              menuItem.foodPreference == 'non-veg'
                  ? Res.icNonVeg
                  : menuItem.foodPreference == 'egg'
                      ? Res.icEgg
                      : Res.icVeg,
              width: 16,
              height: 16,
            ),
          ),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${menuItem.menuName ?? 'Item'}${menuItem.menuType != null && menuItem.menuType!.isNotEmpty ? ' : ${menuItem.menuType}' : ''}',
                  style: semiBoldTextStyle(
                    fontSize: dimen13,
                    color: ColorsTheme.colBlack,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    if (hasDiscount) ...[
                      Text(
                        '₹${menuItem.offerPrice ?? 0}',
                        style: TextStyle(
                          fontSize: dimen11,
                          color: ColorsTheme.col5dD6E68,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      SizedBox(width: 8),
                    ],
                    Text(
                      '₹${menuItem.finalPrice ?? menuItem.offerPrice ?? 0}',
                      style: semiBoldTextStyle(
                        fontSize: dimen13,
                        color: ColorsTheme.colPrimary,
                      ),
                    ),
                    if (menuItem.quantity != null &&
                        menuItem.quantity! > 1) ...[
                      SizedBox(width: 8),
                      Text(
                        'x${menuItem.quantity}',
                        style: regularTextStyle(
                          fontSize: dimen11,
                          color: ColorsTheme.col475751,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        // color: ColorsTheme.colPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorsTheme.colPrimary,
          width: 0.5,
        ),
        // boxShadow: [
        //   BoxShadow(
        //     color: ColorsTheme.colPrimary.withOpacity(0.05),
        //     blurRadius: 15,
        //     spreadRadius: 3,
        //     offset: const Offset(0, 4),
        //   ),
        // ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon(
              //   Icons.star,
              //   color: ColorsTheme.colPrimary,
              //   size: 24,
              // ),
              // SizedBox(width: 8),
              Text(
                'Rate Your Experience'.tr,
                style: boldTextStyle(
                  fontSize: dimen14,
                  color: ColorsTheme.colBlack,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),

          SizedBox(height: 8),

          Text(
            'How was your experience?'.tr,
            style: regularTextStyle(
              fontSize: dimen12,
              color: ColorsTheme.col475751,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: 12),

          // Rating stars
          controller.isRated.value ? _buildRatedStars() : _buildRatingStars(),

          SizedBox(height: 3),

          // Skip button (only show if not rated)
          // if (!controller.isRated.value)
          //   TextButton(
          //     onPressed: () => controller.skipToHome(),
          //     child: Text(
          //       'Skip for now'.tr,
          //       style: mediumTextStyle(
          //         fontSize: dimen14,
          //         color: ColorsTheme.col475751,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }

  Widget _buildRatingStars() {
    return RatingBar(
      initialRating: 0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: 30,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      ratingWidget: RatingWidget(
        full: Icon(
          Icons.star,
          color: ColorsTheme.colPrimary,
        ),
        empty: Icon(
          Icons.star_border,
          color: ColorsTheme.colPrimary.withOpacity(0.5),
        ),
        half: Container(),
      ),
      onRatingUpdate: (rating) {
        controller.submitRating(rating);
      },
    );
  }

  Widget _buildRatedStars() {
    return RatingBarIndicator(
      rating: controller.rating.value,
      itemSize: 30,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (BuildContext context, int index) {
        return Icon(
          Icons.star,
          color: ColorsTheme.colPrimary,
        );
      },
    );
  }

  Widget _buildRestaurantHeader() {
    final restaurant = controller.orderDetailsModel?.restaurantDetail;

    return Column(
      children: [
        // Restaurant icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ColorsTheme.colWhite,
            border: Border.all(
              color: ColorsTheme.colPrimary,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipOval(
            child: restaurant?.restaurantProfile != null &&
                    restaurant!.restaurantProfile!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: restaurant.restaurantProfile!,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        color: ColorsTheme.colPrimary,
                        strokeWidth: 2,
                      ),
                    ),
                    errorWidget: (context, url, error) => Icon(
                      Icons.restaurant,
                      size: 40,
                      color: ColorsTheme.colPrimary,
                    ),
                  )
                : Icon(
                    Icons.restaurant,
                    size: 40,
                    color: ColorsTheme.colPrimary,
                  ),
          ),
        ),

        SizedBox(height: 16),

        // Restaurant name
        Text(
          restaurant?.restaurantName ?? 'Restaurant'.tr,
          style: semiBoldTextStyle(
            fontSize: dimen18,
            color: ColorsTheme.colBlack,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSurveyContent() {
    if (!Get.isRegistered<SurveyController>()) {
      return Center(
          child: CircularProgressIndicator(color: ColorsTheme.colPrimary));
    }

    final surveyController = Get.find<SurveyController>();

    return Obx(() {
      final survey = surveyController.activeSurvey.value;
      if (survey == null) {
        return Center(
            child: CircularProgressIndicator(color: ColorsTheme.colPrimary));
      }

      final currentIndex = surveyController.currentIndex.value;
      final totalQuestions = survey.questions?.length ?? 0;

      // Safety checks
      if (totalQuestions == 0 || survey.questions == null) {
        return Center(
          child: Text(
            'No questions available'.tr,
            style: regularTextStyle(
                fontSize: dimen14, color: ColorsTheme.colBlack),
          ),
        );
      }

      if (currentIndex < 0 || currentIndex >= totalQuestions) {
        return Center(
          child: Text(
            'Invalid question index'.tr,
            style: regularTextStyle(
                fontSize: dimen14, color: ColorsTheme.colBlack),
          ),
        );
      }

      final currentQuestion = survey.questions![currentIndex];

      return Column(
        children: [
          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20),

                  // Restaurant icon and name (after rating is submitted)
                  Obx(() {
                    if (controller.isRated.value) {
                      return _buildRestaurantHeader();
                    }
                    return const SizedBox.shrink();
                  }),

                  SizedBox(height: 30),

                  // Survey Questions Card with white background - Centered
                  Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 500),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: ColorsTheme.colWhite,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: ColorsTheme.colC4D9D4,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress bar
                          _buildSurveyProgressBar(currentIndex, totalQuestions),

                          SizedBox(height: 30),

                          // Question
                          _buildSurveyQuestion(
                              currentQuestion, surveyController),

                          SizedBox(height: 20),

                          // Submit button for final question (especially if multi-select)
                          if (currentIndex == totalQuestions - 1)
                            GestureDetector(
                              onTap: () {
                                // Validate if answer is provided
                                final answer = surveyController
                                    .answers[currentQuestion.questionId];
                                final isValidAnswer = answer != null &&
                                    !(answer is List && answer.isEmpty) &&
                                    !(answer is String && answer.isEmpty);

                                if (currentQuestion.isMandatory == true &&
                                    !isValidAnswer) {
                                  // Show error if mandatory question not answered
                                  return;
                                }

                                // Submit survey
                                surveyController.submitSurvey();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: ColorsTheme.colPrimary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Obx(() {
                                  if (surveyController.isSubmitting.value) {
                                    return SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                ColorsTheme.colWhite),
                                      ),
                                    );
                                  }
                                  return Text(
                                    "Submit".tr,
                                    style: semiBoldTextStyle(
                                      fontSize: dimen14,
                                      color: ColorsTheme.colWhite,
                                    ),
                                  );
                                }),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Skip option fixed at bottom of screen
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.transparent,
            ),
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  await surveyController.skipSurvey();
                  controller.navigateToOrderListing();
                },
                child: Text(
                  "Skip Question".tr,
                  style: regularTextStyle(
                    fontSize: dimen14,
                    color: ColorsTheme.col475751,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildThankYouPage() {
    return Container(
      // decoration: BoxDecoration(
      //   // gradient: LinearGradient(
      //   //   begin: Alignment.topCenter,
      //   //   end: Alignment.bottomCenter,
      //   //   colors: [
      //   //     ColorsTheme.colPrimary.withOpacity(0.1),
      //   //     ColorsTheme.colWhite,
      //   //   ],
      //   // ),
      // ),
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 60),

                // Success animation
                SizedBox(
                  height: 200,
                  child: Lottie.asset(
                    'assets/successOrder.json',
                    repeat: true,
                    animate: true,
                  ),
                ),

                SizedBox(height: 30),

                // "Thank you!" text in yellow/gold
                Text(
                  "Thank you!",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: ColorsTheme.colPrimary,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 16),

                // Descriptive text
                Text(
                  "We value your feedback!".tr,
                  style: semiBoldTextStyle(
                    fontSize: dimen18,
                    color: ColorsTheme.colPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12),

                Text(
                  "We love hearing from you and will use your feedback to improve what we do."
                      .tr,
                  style: regularTextStyle(
                    fontSize: dimen14,
                    color: ColorsTheme.col475751,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 40),
              ],
            ),
          ),

          // Close icon positioned at top right (absolute)
          // Positioned(
          //   top: 16,
          //   right: 16,
          //   child: GestureDetector(
          //     onTap: () => controller.closeThankYouAndNavigate(),
          //     child: Container(
          //       padding: const EdgeInsets.all(8),
          //       decoration: BoxDecoration(
          //         color: ColorsTheme.colWhite,
          //         shape: BoxShape.circle,
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.1),
          //             blurRadius: 4,
          //             spreadRadius: 1,
          //           ),
          //         ],
          //       ),
          //       child: Icon(
          //         Icons.close,
          //         color: ColorsTheme.colBlack,
          //         size: 20,
          //       ),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSurveyProgressBar(int currentIndex, int totalQuestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question ${currentIndex + 1} of $totalQuestions".tr,
          style: regularTextStyle(
            fontSize: dimen12,
            color: ColorsTheme.col8FA19C,
          ),
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / totalQuestions,
            backgroundColor: ColorsTheme.colE7F8F3,
            valueColor: AlwaysStoppedAnimation<Color>(ColorsTheme.colPrimary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyQuestion(
      SurveyQuestionModel question, SurveyController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: question.text ?? "",
                style: mediumTextStyle(
                  fontSize: dimen14,
                  color: ColorsTheme.colBlack,
                ),
              ),
              if (question.isMandatory == true)
                TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red, fontSize: dimen14),
                ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _renderSurveyOptions(question, controller),
      ],
    );
  }

  Widget _renderSurveyOptions(
      SurveyQuestionModel question, SurveyController controller) {
    if (question.type == "YES_NO") {
      return _buildYesNoOptions(question, controller);
    } else if (question.type == "MULTI_SELECT") {
      return _buildMultiSelectOptions(question, controller);
    } else if (question.type == "TEXT" ||
        question.type == "OPEN_TEXT" ||
        question.type == "INPUT") {
      return _buildTextOptions(question, controller);
    } else if (question.type == "STAR_RATING") {
      return _buildStarRatingOptions(question, controller);
    }
    return SizedBox.shrink();
  }

  Widget _buildTextOptions(
      SurveyQuestionModel question, SurveyController controller) {
    final currentAnswer =
        controller.answers[question.questionId]?.toString() ?? "";
    final textController =
        controller.getTextController(question.questionId!, currentAnswer);

    return Container(
      decoration: BoxDecoration(
        color: ColorsTheme.colF5F5F5,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorsTheme.colC4D9D4),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        controller: textController,
        onChanged: (val) => controller.saveAnswer(question.questionId!, val,
            autoAdvance: false),
        onSubmitted: (val) {
          controller.saveAnswer(question.questionId!, val, autoAdvance: true);
        },
        maxLines: 4,
        textInputAction: TextInputAction.done,
        style: regularTextStyle(fontSize: dimen13, color: ColorsTheme.colBlack),
        decoration: InputDecoration(
          hintText: "Write your feedback here...".tr,
          hintStyle:
              regularTextStyle(fontSize: dimen13, color: ColorsTheme.col8FA19C),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStarRatingOptions(
      SurveyQuestionModel question, SurveyController controller) {
    final currentAnswer = int.tryParse(
            controller.answers[question.questionId]?.toString() ?? "0") ??
        0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isSelected = starValue <= currentAnswer;
        return GestureDetector(
          onTap: () => controller.saveAnswer(question.questionId!, starValue),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isSelected ? Icons.star_rounded : Icons.star_outline_rounded,
              color: isSelected ? Colors.orange : ColorsTheme.colC4D9D4,
              size: 40,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildYesNoOptions(
      SurveyQuestionModel question, SurveyController controller) {
    final options = question.options ??
        [
          SurveyOption(label: "Yes", value: "YES"),
          SurveyOption(label: "No", value: "NO"),
        ];
    final currentAnswer = controller.answers[question.questionId];

    return Row(
      children: options.map((option) {
        final isSelected = currentAnswer == option.value;
        return Expanded(
          child: GestureDetector(
            onTap: () =>
                controller.saveAnswer(question.questionId!, option.value),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4),
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color:
                    isSelected ? ColorsTheme.colPrimary : ColorsTheme.colWhite,
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: isSelected
                      ? ColorsTheme.colPrimary
                      : ColorsTheme.colC4D9D4,
                ),
              ),
              child: Center(
                child: Text(
                  option.label ?? "",
                  style: semiBoldTextStyle(
                    fontSize: dimen14,
                    color: isSelected
                        ? ColorsTheme.colWhite
                        : ColorsTheme.colBlack,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMultiSelectOptions(
      SurveyQuestionModel question, SurveyController controller) {
    final options = question.options ?? [];
    final currentAnswers =
        controller.answers[question.questionId] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = currentAnswers.contains(option.value);
            return GestureDetector(
              onTap: () {
                List<dynamic> newAnswers = List.from(currentAnswers);
                if (isSelected) {
                  newAnswers.remove(option.value);
                } else {
                  newAnswers.add(option.value);
                }
                controller.saveAnswer(question.questionId!, newAnswers);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorsTheme.colPrimary
                      : ColorsTheme.colWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? ColorsTheme.colPrimary
                        : ColorsTheme.colC4D9D4,
                  ),
                ),
                child: Text(
                  option.label ?? "",
                  style: mediumTextStyle(
                    fontSize: dimen12,
                    color: isSelected
                        ? ColorsTheme.colWhite
                        : ColorsTheme.colBlack,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        ...options
            .where(
                (o) => o.allowsText == true && currentAnswers.contains(o.value))
            .map((opt) {
          final otherText =
              controller.otherAnswers["${question.questionId}_${opt.value}"] ??
                  "";
          final otherController = controller.getOtherTextController(
              question.questionId!, opt.value!, otherText);

          return Container(
            margin: EdgeInsets.only(top: 12),
            padding: EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: ColorsTheme.colF5F5F5,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: ColorsTheme.colC4D9D4),
            ),
            child: TextField(
              controller: otherController,
              onChanged: (val) => controller.saveOtherAnswer(
                  question.questionId!, opt.value!, val),
              style: regularTextStyle(
                  fontSize: dimen12, color: ColorsTheme.colBlack),
              decoration: InputDecoration(
                hintText: opt.placeholder ?? "Please specify".tr,
                hintStyle: regularTextStyle(
                    fontSize: dimen12, color: ColorsTheme.col8FA19C),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
