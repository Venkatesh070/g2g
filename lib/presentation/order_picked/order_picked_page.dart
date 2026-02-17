import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:lottie/lottie.dart';
import '../../infrastructure/core/base/base_view.dart';
import '../../infrastructure/models/survey_model.dart'
    show SurveyQuestionModel, SurveyOption;
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
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
  Color pageBackgroundColor() => ColorsTheme.colF5F5F5;

  @override
  AppBar? appBar() => null;

  @override
  Widget body(BuildContext context) {
    return Container(
      color: ColorsTheme.colF5F5F5,
      child: Column(
        children: [
          Obx(() => _buildAppBar(context)),
          Expanded(
            child: Obx(() {
              if (controller.showSurvey.value &&
                  Get.isRegistered<SurveyController>()) {
                final surveyController = Get.find<SurveyController>();
                if (surveyController.showThankYou.value) {
                  return _buildThankYouPage();
                }
                return _buildSurveyContent();
              }
              return _buildInitialOrderScreen();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    // Check if ThankYou page is currently being displayed
    final showThankYou = controller.showSurvey.value &&
        Get.isRegistered<SurveyController>() &&
        Get.find<SurveyController>().showThankYou.value;

    // ONLY hide app bar when ThankYou page is shown
    if (showThankYou) {
      return const SizedBox.shrink();
    }

    // Show app bar for all other scenarios (initial order screen, survey form, etc.)
    final showSurvey = controller.showSurvey.value;

    if (showSurvey) {
      // App bar for survey screen
      return Container(
        color: ColorsTheme.colF5F5F5,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 4,
          right: 4,
          bottom: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios_new,
                  color: ColorsTheme.colPrimary, size: 20),
              onPressed: () => controller.skipToHome(),
            ),
            IconButton(
              icon: Icon(Icons.close, color: ColorsTheme.colPrimary, size: 24),
              onPressed: () async {
                if (Get.isRegistered<SurveyController>()) {
                  await Get.find<SurveyController>().skipSurvey();
                  controller.navigateToOrderListing();
                }
              },
            ),
          ],
        ),
      );
    }

    // App bar for initial order picked screen (rating section)
    return Container(
      color: ColorsTheme.colF5F5F5,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 4,
        right: 8,
        bottom: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: ColorsTheme.colBlack, size: 20),
            onPressed: () => controller.skipToHome(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 8),
          Text(
            'Your Order'.tr,
            style:
                boldTextStyle(fontSize: dimen18, color: ColorsTheme.colBlack),
          ),
        ],
      ),
    );
  }

  /// Initial screen (Image 1): Green rating card + White order details card + Need help?
  Widget _buildInitialOrderScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildGreenRatingCard(),
          const SizedBox(height: 16),
          Obx(() {
            if (controller.isLoadingOrderDetails.value) {
              return Container(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child:
                      CircularProgressIndicator(color: ColorsTheme.colPrimary),
                ),
              );
            }
            if (controller.orderDetailsModel != null) {
              return _buildOrderDetailsCardImage1();
            }
            return const SizedBox.shrink();
          }),
          const SizedBox(height: 24),
          _buildNeedHelp(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  /// Green card: "How was your experience?" + 5 white stars (Image 1)
  Widget _buildGreenRatingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: ColorsTheme.colPrimary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'How was your experience?'.tr,
            style: semiBoldTextStyle(
              fontSize: dimen16,
              color: ColorsTheme.colWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          controller.isRated.value
              ? _buildRatedStarsWhite()
              : _buildRatingStarsWhite(),
        ],
      ),
    );
  }

  Widget _buildRatingStarsWhite() {
    return RatingBar(
      initialRating: 0,
      minRating: 0,
      direction: Axis.horizontal,
      allowHalfRating: false,
      itemCount: 5,
      itemSize: 36,
      itemPadding: const EdgeInsets.symmetric(horizontal: 6),
      ratingWidget: RatingWidget(
        full: Icon(Icons.star, color: ColorsTheme.colWhite),
        empty: Icon(Icons.star_border, color: ColorsTheme.colWhite),
        half: Icon(Icons.star_half, color: ColorsTheme.colWhite),
      ),
      onRatingUpdate: (r) => controller.submitRating(r),
    );
  }

  Widget _buildRatedStarsWhite() {
    final rating = controller.rating.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isRated = starValue <= rating;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: isRated
              ? Icon(Icons.star, color: ColorsTheme.colWhite, size: 36)
              : Container(
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.star_border,
                    color: ColorsTheme.colWhite,
                    size: 32,
                  ),
                ),
        );
      }),
    );
  }

  /// Custom rating indicator for survey header with unrated stars showing red background
  Widget _buildCustomRatingIndicator() {
    final rating = controller.rating.value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        final isRated = starValue <= rating;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: isRated
              ? Icon(Icons.star, color: ColorsTheme.colPrimary, size: 28)
              : Container(
                  decoration: BoxDecoration(
                    // color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    Icons.star_border,
                    color: ColorsTheme.colPrimary,
                    size: 24,
                  ),
                ),
        );
      }),
    );
  }

  /// Need help? with question mark in green circle (Image 1)
  Widget _buildNeedHelp() {
    return Center(
      child: GestureDetector(
        onTap: () => controller.navigateToContactScreen(),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // color: ColorsTheme.colPrimary.withOpacity(0.15),
                border: Border.all(color: ColorsTheme.colPrimary),
              ),
              child: Icon(Icons.question_mark,
                  color: ColorsTheme.colPrimary, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              'Need help?'.tr,
              style: regularTextStyle(
                  fontSize: dimen14, color: ColorsTheme.col475751),
            ),
          ],
        ),
      ),
    );
  }

  /// White order details card (Image 1): Collected, logo, name, address, two columns
  Widget _buildOrderDetailsCardImage1() {
    final order = controller.orderDetailsModel!;
    final rest = order.restaurantDetail;
    final restaurantName = rest?.restaurantName ?? 'Restaurant'.tr;
    final address = rest?.restaurantAddress ?? '';
    final paymentMethodRaw = order.paymentMethod ?? 'N/A';
    final paymentMethod = paymentMethodRaw.isNotEmpty
        ? paymentMethodRaw[0].toUpperCase() +
            paymentMethodRaw.substring(1).toLowerCase()
        : 'N/A';
    final totalPaid = order.totalPaid ?? '0';
    final orderIdStr = '${order.orderId}';
    final date = order.pickupDate ?? order.createdDate ?? '';
    final itemName = order.menuDetails != null && order.menuDetails!.isNotEmpty
        ? (order.menuDetails!.first.menuName ?? 'Item'.tr)
        : 'Item'.tr;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorsTheme.colWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ColorsTheme.colD2D3D4, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: ColorsTheme.colPrimary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Collected'.tr,
                style: semiBoldTextStyle(
                    fontSize: dimen14, color: ColorsTheme.colPrimary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: ColorsTheme.colPrimary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: rest?.restaurantProfile != null &&
                        rest!.restaurantProfile!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: CachedNetworkImage(
                          imageUrl: rest.restaurantProfile!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: ColorsTheme.colWhite,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Center(
                            child: Text(
                              restaurantName.isNotEmpty
                                  ? restaurantName[0].toUpperCase()
                                  : 'R',
                              style: semiBoldTextStyle(
                                  fontSize: dimen18,
                                  color: ColorsTheme.colWhite),
                            ),
                          ),
                        ),
                      )
                    : Center(
                        child: Text(
                          restaurantName.isNotEmpty
                              ? restaurantName[0].toUpperCase()
                              : 'R',
                          style: semiBoldTextStyle(
                              fontSize: dimen18, color: ColorsTheme.colWhite),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurantName,
                      style: boldTextStyle(
                          fontSize: dimen14, color: ColorsTheme.colBlack),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        address,
                        style: regularTextStyle(
                            fontSize: dimen12, color: ColorsTheme.col475751),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(height: 1, color: ColorsTheme.colD2D3D4),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _orderLabel('COLLECTED'.tr),
                    Text(date,
                        style: regularTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack)),
                    const SizedBox(height: 12),
                    _orderLabel('ITEM NAME'.tr),
                    Text(itemName,
                        style: regularTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack)),
                    const SizedBox(height: 12),
                    _orderLabel('PAYMENT METHOD'.tr),
                    Text(paymentMethod,
                        style: regularTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _orderLabel('ORDER ID'.tr),
                    Text(orderIdStr,
                        style: regularTextStyle(
                            fontSize: dimen13, color: ColorsTheme.colBlack)),
                    const SizedBox(height: 12),
                    _orderLabel('TOTAL'.tr),
                    Text('₹$totalPaid',
                        style: semiBoldTextStyle(
                            fontSize: dimen14, color: ColorsTheme.colBlack)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _orderLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style:
            regularTextStyle(fontSize: dimen11, color: ColorsTheme.col8FA19C),
      ),
    );
  }

  /// Survey header (Image 2): Emoji based on rating in green circle outline + restaurant name + 5 stars + green line
  Widget _buildRestaurantHeader() {
    final restaurant = controller.orderDetailsModel?.restaurantDetail;
    final name = restaurant?.restaurantName ?? 'Restaurant'.tr;
    final rating = controller.rating.value.toInt();
    final emoji = rating >= 4
        ? '😊'
        : rating <= 2
            ? '😔'
            : '😑';

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          // decoration: BoxDecoration(
          //   shape: BoxShape.circle,
          //   color: Colors.transparent,
          //   // border: Border.all(color: ColorsTheme.colPrimary, width: 2.5),
          // ),
          alignment: Alignment.center,
          child: Text(
            emoji,
            style: const TextStyle(fontSize: 45),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style:
              semiBoldTextStyle(fontSize: dimen16, color: ColorsTheme.colBlack),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),
        _buildCustomRatingIndicator(),
        const SizedBox(height: 7),
        // Container(
        //   height: 4,
        //   margin: const EdgeInsets.symmetric(horizontal: 48),
        //   decoration: BoxDecoration(
        //     color: ColorsTheme.colPrimary,
        //     borderRadius: BorderRadius.circular(2),
        //   ),
        // ),
      ],
    );
  }

  /// Survey screen (Image 2/3): Header + white card (progress, question, options) + Skip at bottom
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
          // Header section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: _buildRestaurantHeader(),
          ),
          // White background section - full width and extends to bottom
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorsTheme.colWhite,
                // borderRadius: const BorderRadius.only(
                //   topLeft: Radius.circular(16),
                //   topRight: Radius.circular(16),
                // ),
                // border: Border.all(color: ColorsTheme.colD2D3D4),
                // boxShadow: [
                //   BoxShadow(
                //     color: Colors.black.withOpacity(0.06),
                //     blurRadius: 8,
                //     offset: const Offset(0, -2),
                //   ),
                // ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Progress bar as top border
                          _buildSurveyProgressBarOnly(
                              currentIndex, totalQuestions),
                          const SizedBox(height: 20),
                          // Question content
                          Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildSurveyQuestion(
                                    currentQuestion, surveyController),
                                if (currentIndex == totalQuestions - 1) ...[
                                  const SizedBox(height: 34),
                                  _buildSubmitButton(
                                      currentQuestion, surveyController),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Skip Question at bottom of screen
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          await surveyController.skipSurvey();
                          controller.navigateToOrderListing();
                        },
                        child: Text(
                          "Skip Question".tr,
                          style: regularTextStyle(
                              fontSize: dimen14, color: ColorsTheme.col475751),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildSubmitButton(
      SurveyQuestionModel currentQuestion, SurveyController surveyController) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.5,
            ),
            child: GestureDetector(
              onTap: () {
                final answer =
                    surveyController.answers[currentQuestion.questionId];
                final isValid = answer != null &&
                    !(answer is List && answer.isEmpty) &&
                    !(answer is String && answer.isEmpty);
                if (currentQuestion.isMandatory == true && !isValid) return;
                surveyController.submitSurvey();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: ColorsTheme.colPrimary,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: Obx(() {
                  if (surveyController.isSubmitting.value) {
                    return SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(ColorsTheme.colWhite),
                      ),
                    );
                  }
                  return Text(
                    "Submit".tr,
                    style: semiBoldTextStyle(
                        fontSize: dimen16, color: ColorsTheme.colWhite),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Thank you screen (Image 4): Dark teal background, icon, "Thank you!" yellow, white text, Close button
  Widget _buildThankYouPage() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF01563F),
            Color(0xFF014030),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.sentiment_very_satisfied_outlined,
                    color: ColorsTheme.colWhite, size: 95),
                // Positioned(
                //   top: 10,
                //   right: 20,
                //   child: Icon(Icons.favorite_outline,
                //       color: ColorsTheme.colPrimary, size: 24),
                // ),
              ],

              // SizedBox(
              //   width: 200,
              //   height: 200,
              //   child: Lottie.asset(
              //     'assets/orderConfirmed.json',
              //     fit: BoxFit.contain,
              //   ),
            ),
            const SizedBox(height: 32),
            Text(
              "Thank You!",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.amber.shade300,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "We love hearing from you and will use your\nfeedback to improve what we do."
                    .tr,
                style: regularTextStyle(
                  fontSize: dimen15,
                  color: ColorsTheme.colWhite,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(flex: 2),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => controller.closeThankYouAndNavigate(),
                  style: TextButton.styleFrom(
                    backgroundColor: ColorsTheme.colWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    "Close".tr,
                    style: semiBoldTextStyle(
                      fontSize: dimen16,
                      color: ColorsTheme.colPrimary,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildSurveyProgressBar(int currentIndex, int totalQuestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Question ${currentIndex + 1} of $totalQuestions".tr,
          style:
              regularTextStyle(fontSize: dimen12, color: ColorsTheme.col8FA19C),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: (currentIndex + 1) / totalQuestions,
            backgroundColor: ColorsTheme.colE7F8F3,
            valueColor: AlwaysStoppedAnimation<Color>(ColorsTheme.colPrimary),
            minHeight: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildSurveyProgressBarOnly(int currentIndex, int totalQuestions) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: LinearProgressIndicator(
        value: (currentIndex + 1) / totalQuestions,
        backgroundColor: ColorsTheme.colE7F8F3,
        valueColor: AlwaysStoppedAnimation<Color>(ColorsTheme.colPrimary),
        minHeight: 4,
      ),
    );
  }

  Widget _buildSurveyQuestion(
      SurveyQuestionModel question, SurveyController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: question.text ?? "",
                style: boldTextStyle(
                    fontSize: dimen16, color: ColorsTheme.colBlack),
              ),
              if (question.isMandatory == true)
                const TextSpan(
                    text: " *",
                    style: TextStyle(color: Colors.red, fontSize: 15)),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 35),
        _renderSurveyOptions(question, ctrl),
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ColorsTheme.colD2D3D4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextField(
        controller: textController,
        onChanged: (val) => controller.saveAnswer(question.questionId!, val,
            autoAdvance: false),
        onSubmitted: (val) =>
            controller.saveAnswer(question.questionId!, val, autoAdvance: true),
        maxLines: 4,
        textInputAction: TextInputAction.done,
        style: regularTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack),
        decoration: InputDecoration(
          hintText: "Describe the contents here".tr,
          hintStyle:
              regularTextStyle(fontSize: dimen14, color: ColorsTheme.col8FA19C),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
          SurveyOption(label: "No", value: "NO")
        ];
    final currentAnswer = controller.answers[question.questionId];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: options.map((option) {
        final isSelected = currentAnswer == option.value;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: GestureDetector(
            onTap: () =>
                controller.saveAnswer(question.questionId!, option.value),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              decoration: BoxDecoration(
                color:
                    isSelected ? ColorsTheme.colPrimary : ColorsTheme.colWhite,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: ColorsTheme.colPrimary,
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Text(
                  option.label ?? "",
                  style: semiBoldTextStyle(
                    fontSize: dimen14,
                    color: isSelected
                        ? ColorsTheme.colWhite
                        : ColorsTheme.colPrimary,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorsTheme.colPrimary
                      : ColorsTheme.colWhite,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ColorsTheme.colPrimary,
                    width: 1,
                  ),
                ),
                child: Text(
                  option.label ?? "",
                  style: mediumTextStyle(
                    fontSize: dimen13,
                    color: isSelected
                        ? ColorsTheme.colWhite
                        : ColorsTheme.colPrimary,
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
            margin: const EdgeInsets.only(top: 14),
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
            ),
            decoration: BoxDecoration(
              color: ColorsTheme.colF5F5F5,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColorsTheme.colD2D3D4),
            ),
            child: TextField(
              controller: otherController,
              onChanged: (val) => controller.saveOtherAnswer(
                  question.questionId!, opt.value!, val),
              maxLines: 3,
              textInputAction: TextInputAction.newline,
              style: regularTextStyle(
                  fontSize: dimen13, color: ColorsTheme.colBlack),
              decoration: InputDecoration(
                hintText: opt.placeholder ?? "Please specify".tr,
                hintStyle: regularTextStyle(
                    fontSize: dimen13, color: ColorsTheme.col8FA19C),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}
