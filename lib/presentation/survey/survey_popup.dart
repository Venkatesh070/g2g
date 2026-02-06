import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';
import '../../infrastructure/theme/colors.theme.dart';
import '../../infrastructure/theme/text.theme.dart';
import 'survey_controller.dart';
import '../../infrastructure/models/survey_model.dart';

class SurveyPopup extends StatelessWidget {
  const SurveyPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SurveyController>();

    return PopScope(
      canPop: false, // Prevent dismissal by back button
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: Get.width * 0.85,
            constraints: BoxConstraints(
              maxHeight: Get.height * 0.8,
            ),
            padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.5.h),
            decoration: BoxDecoration(
              color: ColorsTheme.colWhite,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: Obx(() {
              // If neither thank you nor landing (nor active survey) is true, something is wrong
              if (controller.showThankYou.value) {
                return _buildThankYouState(controller);
              }

              return SingleChildScrollView(
                child: controller.showLanding.value
                    ? _buildLandingState(controller)
                    : controller.activeSurvey.value != null
                        ? _buildSurveyQuestionsState(controller)
                        : SizedBox.shrink(),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildLandingState(SurveyController controller) {
    final hasSurvey = controller.activeSurvey.value != null;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle,
                    color: ColorsTheme.colPrimary, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Order Picked Up!',
                  style: semiBoldTextStyle(
                      fontSize: dimen16, color: ColorsTheme.colBlack),
                ),
              ],
            ),
            GestureDetector(
              onTap: () => controller.closeSurvey(),
              child: Icon(Icons.close, color: ColorsTheme.col8FA19C, size: 20),
            )
          ],
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 100,
          child: Lottie.asset(
            'assets/successOrder.json',
            repeat: true,
            animate: true,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          hasSurvey
              ? "Thank you for picking up your order 🙌\nHope everything went well.\n\nWould you like to share quick feedback? It takes less than a minute."
              : "Thank you for picking up your order.\nWe hope you enjoy your meal 🍽️",
          textAlign: TextAlign.center,
          style:
              regularTextStyle(fontSize: dimen14, color: ColorsTheme.colBlack),
        ),
        SizedBox(height: 3.h),
        if (hasSurvey)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.skipSurvey(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: ColorsTheme.colWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: ColorsTheme.colPrimary),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Later',
                      style: mediumTextStyle(
                          fontSize: dimen13, color: ColorsTheme.colPrimary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => controller.startSurveyQuestions(),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: ColorsTheme.colPrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Give Feedback',
                      style: mediumTextStyle(
                          fontSize: dimen13, color: ColorsTheme.colWhite),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => controller.closeSurvey(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: ColorsTheme.colPrimary,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Close',
                  style: mediumTextStyle(
                      fontSize: dimen13, color: ColorsTheme.colWhite),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildThankYouState(SurveyController controller) {
    return Container(
      width: Get.width * 0.85,
      decoration: BoxDecoration(
        color: ColorsTheme.colPrimary, // Dark teal/green background
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => controller.closeSurvey(),
                child: Icon(Icons.close, color: ColorsTheme.colWhite, size: 20),
              )
            ],
          ),
          SizedBox(height: 2.h),
          // Smiley face icon with heart
          Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.sentiment_very_satisfied_outlined,
                size: 80,
                color: ColorsTheme.colWhite,
              ),
              Positioned(
                top: 10,
                right: 20,
                child: Icon(
                  Icons.favorite_outline,
                  size: 24,
                  color: ColorsTheme.colWhite,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          // "Thank you!" text in yellow/gold
          Text(
            "Thank you!",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.amber.shade300, // Yellow/gold color
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          // Descriptive text in white
          Text(
            "We love hearing from you and will use your feedback to improve what we do.",
            style: regularTextStyle(
              fontSize: dimen14,
              color: ColorsTheme.colWhite,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          // Close button with white background and dark teal text
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: () => controller.closeSurvey(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: ColorsTheme.colWhite,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Close",
                  style: mediumTextStyle(
                    fontSize: dimen14,
                    color: ColorsTheme.colPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyQuestionsState(SurveyController controller) {
    final survey = controller.activeSurvey.value;
    if (survey == null) {
      return SizedBox.shrink();
    }

    final currentIndex = controller.currentIndex.value;
    final totalQuestions = survey.questions?.length ?? 0;

    // Safety checks for questions and currentIndex
    if (totalQuestions == 0 || survey.questions == null) {
      return SizedBox.shrink();
    }

    if (currentIndex < 0 || currentIndex >= totalQuestions) {
      return SizedBox.shrink();
    }

    final currentQuestion = survey.questions![currentIndex];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(controller),
        SizedBox(height: 2.h),
        _buildProgressBar(currentIndex, totalQuestions),
        SizedBox(height: 2.h),
        _buildQuestion(currentQuestion, controller),
        SizedBox(height: 3.h),
        _buildNavigationButtons(controller, currentIndex, totalQuestions),
      ],
    );
  }

  Widget _buildHeader(SurveyController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Feedback",
          style:
              semiBoldTextStyle(fontSize: dimen16, color: ColorsTheme.colBlack),
        ),
        GestureDetector(
          onTap: () => controller.closeSurvey(),
          child: Icon(Icons.close, color: ColorsTheme.col8FA19C, size: 20),
        ),
      ],
    );
  }

  Widget _buildProgressBar(int currentIndex, int totalQuestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Que ${currentIndex + 1} of $totalQuestions",
          style:
              regularTextStyle(fontSize: dimen12, color: ColorsTheme.col8FA19C),
        ),
        SizedBox(height: 0.8.h),
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

  Widget _buildQuestion(
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
                    fontSize: dimen14, color: ColorsTheme.colBlack),
              ),
              if (question.isMandatory == true)
                TextSpan(
                  text: " *",
                  style: TextStyle(color: Colors.red, fontSize: dimen14),
                ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        _renderOptions(question, controller),
      ],
    );
  }

  Widget _renderOptions(
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
      padding: EdgeInsets.symmetric(horizontal: 3.w),
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
          hintText: "Write your feedback here...",
          hintStyle:
              regularTextStyle(fontSize: dimen13, color: ColorsTheme.col8FA19C),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 1.5.h),
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
            padding: EdgeInsets.symmetric(horizontal: 1.w),
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
              margin: EdgeInsets.symmetric(horizontal: 1.w),
              padding: EdgeInsets.symmetric(vertical: 1.h),
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
          spacing: 2.w,
          runSpacing: 1.h,
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
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
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
            margin: EdgeInsets.only(top: 1.5.h),
            padding: EdgeInsets.symmetric(horizontal: 3.w),
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
                hintText: opt.placeholder ?? "Please specify",
                hintStyle: regularTextStyle(
                    fontSize: dimen12, color: ColorsTheme.col8FA19C),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 1.h),
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildNavigationButtons(
      SurveyController controller, int currentIndex, int totalQuestions) {
    final isFirst = currentIndex == 0;

    // Only show back button, no next button (auto-advance enabled)
    return Row(
      children: [
        if (!isFirst)
          Expanded(
            child: GestureDetector(
              onTap: () => controller.previousQuestion(),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: ColorsTheme.colWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorsTheme.colPrimary),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Back",
                  style: mediumTextStyle(
                      fontSize: dimen13, color: ColorsTheme.colPrimary),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
