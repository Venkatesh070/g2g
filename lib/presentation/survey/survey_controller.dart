import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import '../../infrastructure/constants/app_constants.dart';
import '../../infrastructure/models/api_response_model.dart';
import '../../infrastructure/models/survey_model.dart';
import '../../infrastructure/network/api_constants.dart';
import '../../infrastructure/network/dio_client.dart';
import '../../infrastructure/shared/pref_manager.dart';
import '../../infrastructure/shared/progress_dialog.dart';
import '../../infrastructure/shared/snackbar.util.dart';
import '../../infrastructure/shared/app_exception_handle.dart';
import '../../infrastructure/shared/http_exception.dart';
import 'survey_popup.dart';

class SurveyController extends GetxController with WidgetsBindingObserver {
  var activeSurvey = Rxn<SurveyModel>();
  var orderId = Rxn<int>();
  var currentIndex = 0.obs;
  var answers = <int, dynamic>{}.obs; // question_id -> answer
  var otherAnswers = <String, String>{}.obs; // "questionId_optionValue" -> text
  var isSubmitting = false.obs;
  var showLanding = true.obs;
  var showThankYou = false.obs;
  
  // Callback for survey completion (used for inline surveys)
  VoidCallback? onSurveyCompleteCallback;
  
  // Flag to indicate if survey should be shown inline (not as popup)
  var isInlineMode = false.obs;

  final Map<int, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _otherTextControllers = {};
  
  void setOnSurveyCompleteCallback(VoidCallback callback) {
    onSurveyCompleteCallback = callback;
  }

  TextEditingController getTextController(int questionId, String initialValue) {
    if (!_textControllers.containsKey(questionId)) {
      _textControllers[questionId] = TextEditingController(text: initialValue);
    }
    return _textControllers[questionId]!;
  }

  TextEditingController getOtherTextController(
      int questionId, String optionValue, String initialValue) {
    final key = "${questionId}_$optionValue";
    if (!_otherTextControllers.containsKey(key)) {
      _otherTextControllers[key] = TextEditingController(text: initialValue);
    }
    return _otherTextControllers[key]!;
  }

  static final String surveyUrl = '${ApiConstants().assetsBaseUrl}/survey.json';

  bool get canGoNext {
    if (activeSurvey.value == null) return false;
    final currentQuestion = activeSurvey.value!.questions![currentIndex.value];
    if (currentQuestion.isMandatory == true) {
      final answer = answers[currentQuestion.questionId];
      if (answer == null) return false;
      if (answer is List && answer.isEmpty) return false;
      if (answer is String && answer.isEmpty) return false;
    }
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Don't load survey state on init - only load when app resumes if user was in the middle
    // This prevents showing survey popup on app start if user closed/skipped
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background - if survey has no answers, clear it (user closed/skipped)
      if (activeSurvey.value != null && answers.isEmpty) {
        print("SurveyController: App backgrounded with no answers, clearing survey state.");
        clearSurveyState();
      }
    } else if (state == AppLifecycleState.resumed) {
      if (activeSurvey.value == null) {
        // Only load state if no active survey - but only if user was in the middle (has answers)
        loadSurveyState();
      } else {
        // If there's an active survey, only show if user was in the middle (has answers)
        if (activeSurvey.value != null && answers.isNotEmpty) {
          _checkAndShowSurveyIfNotSkipped();
        } else {
          // No answers means user closed/skipped, clear state
          print("SurveyController: Survey active but no answers, clearing state.");
          clearSurveyState();
        }
      }
    }
  }

  // Helper method to check if survey was skipped before showing
  Future<void> _checkAndShowSurveyIfNotSkipped() async {
    if (activeSurvey.value == null) return;
    
    // Don't show popup if in inline mode
    if (isInlineMode.value) {
      print("SurveyController: Inline mode active, not showing popup.");
      return;
    }

    String skippedJson =
        await PrefManager.getString(AppConstants.skippedSurveys);
    List<int> skippedIds = [];
    if (skippedJson.isNotEmpty) {
      skippedIds = List<int>.from(jsonDecode(skippedJson));
    }

    if (skippedIds.contains(activeSurvey.value!.surveyId)) {
      print(
          "SurveyController: Survey ${activeSurvey.value!.surveyId} was skipped, clearing state.");
      await clearSurveyState();
      return;
    }

    // Survey not skipped, safe to show (only if not in inline mode)
    if (!Get.isDialogOpen! && !isInlineMode.value) {
      showSurveyPopup();
    }
  }

  // Load survey state from local storage
  // ONLY restore if user was in the middle of survey (has answers)
  Future<void> loadSurveyState() async {
    String surveyJson = await PrefManager.getString(AppConstants.activeSurvey);
    if (surveyJson.isNotEmpty) {
      final survey = SurveyModel.fromJson(jsonDecode(surveyJson));

      // CRITICAL: Check if this survey was already skipped before loading state
      String skippedJson =
          await PrefManager.getString(AppConstants.skippedSurveys);
      List<int> skippedIds = [];
      if (skippedJson.isNotEmpty) {
        skippedIds = List<int>.from(jsonDecode(skippedJson));
      }

      if (skippedIds.contains(survey.surveyId)) {
        print(
            "SurveyController: Survey ${survey.surveyId} was skipped, clearing saved state.");
        // Survey was skipped, clear all saved state and don't show popup
        await clearSurveyState();
        return;
      }

      // Load answers FIRST to check if user was in the middle
      String answersJson =
          await PrefManager.getString(AppConstants.surveyAnswers);
      Map<int, dynamic> loadedAnswers = {};
      if (answersJson.isNotEmpty) {
        Map<String, dynamic> decodedAnswers = jsonDecode(answersJson);
        loadedAnswers =
            decodedAnswers.map((key, value) => MapEntry(int.parse(key), value));
      }

      // CRITICAL: Only restore survey if user was in the middle (has at least one answer)
      // If no answers, user closed/skipped app, so clear state forever
      if (loadedAnswers.isEmpty) {
        print(
            "SurveyController: Survey ${survey.surveyId} has no answers, user closed/skipped app. Clearing state forever.");
        await clearSurveyState();
        return;
      }

      // User was in the middle, restore survey state
      activeSurvey.value = survey;

      // Load current index
      currentIndex.value =
          await PrefManager.getInt(AppConstants.surveyCurrentIndex);

      // Set loaded answers
      answers.value = loadedAnswers;

      // Load other answers
      String otherAnswersJson =
          await PrefManager.getString("survey_other_answers");
      if (otherAnswersJson.isNotEmpty) {
        Map<String, dynamic> decoded = jsonDecode(otherAnswersJson);
        otherAnswers.value = Map<String, String>.from(decoded);
      }

      // Jump straight to questions since user was in the middle
      showLanding.value = false;

      // Double-check skip status before showing (defensive check)
      String finalSkippedJson =
          await PrefManager.getString(AppConstants.skippedSurveys);
      List<int> finalSkippedIds = [];
      if (finalSkippedJson.isNotEmpty) {
        finalSkippedIds = List<int>.from(jsonDecode(finalSkippedJson));
      }

      if (finalSkippedIds.contains(activeSurvey.value!.surveyId)) {
        print(
            "SurveyController: Final check - Survey ${activeSurvey.value!.surveyId} was skipped, clearing state.");
        await clearSurveyState();
        return;
      }

      // Only show popup if user was in the middle AND not in inline mode
      // Don't show popup automatically - only restore state for inline surveys
      if (!isInlineMode.value && answers.isNotEmpty) {
        Future.delayed(Duration(seconds: 1), () {
          // Final check before showing - ensure survey wasn't skipped in the meantime
          if (activeSurvey.value != null && !Get.isDialogOpen! && answers.isNotEmpty) {
            _checkAndShowSurveyIfNotSkipped();
          }
        });
      }
    }
  }

  // Save survey state to local storage
  Future<void> saveSurveyState() async {
    if (activeSurvey.value != null) {
      await PrefManager.putString(
          AppConstants.activeSurvey, jsonEncode(activeSurvey.value!.toJson()));
      await PrefManager.putInt(
          AppConstants.surveyCurrentIndex, currentIndex.value);
      await PrefManager.putString(
          AppConstants.surveyAnswers,
          jsonEncode(
              answers.map((key, value) => MapEntry(key.toString(), value))));
      await PrefManager.putString(
          "survey_other_answers", jsonEncode(otherAnswers));
    }
  }

  // Clear survey state after completion or skip
  Future<void> clearSurveyState() async {
    activeSurvey.value = null;
    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
    isInlineMode.value = false; // Reset inline mode flag
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
    for (var controller in _otherTextControllers.values) {
      controller.dispose();
    }
    _otherTextControllers.clear();
    await PrefManager.remove(AppConstants.activeSurvey);
    await PrefManager.remove(AppConstants.surveyCurrentIndex);
    await PrefManager.remove(AppConstants.surveyAnswers);
    await PrefManager.remove("survey_other_answers");
  }

  // Start a new survey from notification
  Future<void> startSurvey(SurveyModel survey) async {
    print("SurveyController: startSurvey called for ID: ${survey.surveyId}");

    // CRITICAL: First check if this survey was already skipped
    String skippedJson =
        await PrefManager.getString(AppConstants.skippedSurveys);
    List<int> skippedIds = [];
    if (skippedJson.isNotEmpty) {
      skippedIds = List<int>.from(jsonDecode(skippedJson));
    }

    if (skippedIds.contains(survey.surveyId)) {
      print(
          "SurveyController: Survey ${survey.surveyId} was already skipped. Ignoring new notification.");
      // Clear any old state that might exist for this skipped survey
      if (activeSurvey.value?.surveyId == survey.surveyId) {
        await clearSurveyState();
      }
      return;
    }

    // Ignore if same survey is already active (to prevent duplicate popups)
    if (activeSurvey.value?.surveyId == survey.surveyId) {
      print("SurveyController: Survey ${survey.surveyId} is already active.");
      return;
    }

    // IMPORTANT: Clear any old state before starting new survey
    // This ensures we don't show old/skipped survey data
    if (activeSurvey.value != null) {
      print(
          "SurveyController: Clearing old survey state before starting new survey.");
      await clearSurveyState();
    }

    // Validate survey has questions before starting
    if (survey.questions == null || survey.questions!.isEmpty) {
      print("SurveyController: Survey ${survey.surveyId} has no questions. Cannot start.");
      return;
    }

    // Now start the new survey
    activeSurvey.value = survey;
    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
    showLanding.value = true;
    showThankYou.value = false;
    await saveSurveyState();
    
    // Trigger UI to show survey
    showSurveyPopup();
  }

  // Handle Order Picked notification (with or without survey)
  Future<void> onOrderPicked(int? pickedOrderId,
      {int? pickedSurveyId, SurveyModel? survey}) async {
    print(
        "SurveyController: onOrderPicked called for Order ID: $pickedOrderId, Survey ID: $pickedSurveyId");

    orderId.value = pickedOrderId;

    SurveyModel? finalSurvey;

    // If we have a survey ID, always try to fetch fresh data from remote
    if (pickedSurveyId != null) {
      print("SurveyController: Fetching survey data for ID: $pickedSurveyId");
      finalSurvey = await fetchSurveyData(pickedSurveyId);

      // If fetch failed but we have a survey object from notification, use it as fallback
      if (finalSurvey == null && survey != null) {
        print(
            "SurveyController: Remote fetch failed, using fallback from notification.");
        finalSurvey = survey;
      }
    } else {
      finalSurvey = survey;
    }

    // CRITICAL: Check if this survey was already skipped before showing it
    if (finalSurvey != null) {
      String skippedJson =
          await PrefManager.getString(AppConstants.skippedSurveys);
      List<int> skippedIds = [];
      if (skippedJson.isNotEmpty) {
        skippedIds = List<int>.from(jsonDecode(skippedJson));
      }

      if (skippedIds.contains(finalSurvey.surveyId)) {
        print(
            "SurveyController: Survey ${finalSurvey.surveyId} was already skipped, not showing.");
        // Clear any old state for this skipped survey
        if (activeSurvey.value?.surveyId == finalSurvey.surveyId) {
          await clearSurveyState();
        }
        return;
      }

      // IMPORTANT: Clear any old state before starting new survey
      // This ensures we don't show old/skipped survey data
      if (activeSurvey.value != null &&
          activeSurvey.value!.surveyId != finalSurvey.surveyId) {
        print(
            "SurveyController: Clearing old survey state before starting new survey from notification.");
        await clearSurveyState();
      }
    }

    activeSurvey.value = finalSurvey;
    print(
        "SurveyController: Final activeSurvey: ${activeSurvey.value?.surveyId}");

    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
    showLanding.value = true;
    showThankYou.value = false;

    if (activeSurvey.value != null) {
      await saveSurveyState();
      // Don't show popup if in inline mode
      if (!isInlineMode.value) {
        showSurveyPopup();
      }
    }
  }

  void startSurveyQuestions() {
    showLanding.value = false;
  }

  // Start survey from rating (skip landing page, go directly to questions)
  Future<void> startSurveyFromRating(
      SurveyModel survey, int? orderIdParam) async {
    print(
        "SurveyController: startSurveyFromRating called for ID: ${survey.surveyId}");

    // CRITICAL: First check if this survey was already skipped
    String skippedJson =
        await PrefManager.getString(AppConstants.skippedSurveys);
    List<int> skippedIds = [];
    if (skippedJson.isNotEmpty) {
      skippedIds = List<int>.from(jsonDecode(skippedJson));
    }

    if (skippedIds.contains(survey.surveyId)) {
      print(
          "SurveyController: Survey ${survey.surveyId} was already skipped. Not showing.");
      return;
    }

    // Ignore if same survey is already active
    if (activeSurvey.value?.surveyId == survey.surveyId) {
      print("SurveyController: Survey ${survey.surveyId} is already active.");
      return;
    }

    // Clear any old state before starting new survey
    if (activeSurvey.value != null) {
      print(
          "SurveyController: Clearing old survey state before starting survey from rating.");
      await clearSurveyState();
    }

    // Set order ID
    if (orderIdParam != null) {
      orderId.value = orderIdParam;
    } else if (survey.orderId != null) {
      orderId.value = survey.orderId;
    }

    // Validate survey has questions before starting
    if (survey.questions == null || survey.questions!.isEmpty) {
      print("SurveyController: Survey ${survey.surveyId} has no questions. Cannot start.");
      return;
    }

    // Set inline mode flag to prevent popup
    isInlineMode.value = true;

    // Start the survey directly at questions (skip landing)
    activeSurvey.value = survey;
    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
    showLanding.value = false; // Skip landing page
    showThankYou.value = false;
    await saveSurveyState();
    
    // Don't show popup if in inline mode
    if (!isInlineMode.value) {
      showSurveyPopup();
    }
  }
  
  // Start survey from rating inline (no popup, for Order Picked screen)
  Future<void> startSurveyFromRatingInline(
      SurveyModel survey, int? orderIdParam) async {
    print(
        "SurveyController: startSurveyFromRatingInline called for ID: ${survey.surveyId}");

    // CRITICAL: First check if this survey was already skipped
    String skippedJson =
        await PrefManager.getString(AppConstants.skippedSurveys);
    List<int> skippedIds = [];
    if (skippedJson.isNotEmpty) {
      skippedIds = List<int>.from(jsonDecode(skippedJson));
    }

    if (skippedIds.contains(survey.surveyId)) {
      print(
          "SurveyController: Survey ${survey.surveyId} was already skipped. Not showing.");
      return;
    }

    // Ignore if same survey is already active
    if (activeSurvey.value?.surveyId == survey.surveyId) {
      print("SurveyController: Survey ${survey.surveyId} is already active.");
      return;
    }

    // Clear any old state before starting new survey
    if (activeSurvey.value != null) {
      print(
          "SurveyController: Clearing old survey state before starting survey inline.");
      await clearSurveyState();
    }

    // Set order ID
    if (orderIdParam != null) {
      orderId.value = orderIdParam;
    } else if (survey.orderId != null) {
      orderId.value = survey.orderId;
    }

    // Validate survey has questions before starting
    if (survey.questions == null || survey.questions!.isEmpty) {
      print("SurveyController: Survey ${survey.surveyId} has no questions. Cannot start.");
      return;
    }

    // Start the survey directly at questions (skip landing, no popup)
    activeSurvey.value = survey;
    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
    showLanding.value = false; // Skip landing page
    showThankYou.value = false;
    await saveSurveyState();
    
    // Don't show popup - survey will be displayed inline
  }
  
  // Start survey from rating inline WITHOUT skip check (user just rated, they should see survey)
  Future<void> startSurveyFromRatingInlineNoSkipCheck(
      SurveyModel survey, int? orderIdParam) async {
    print(
        "SurveyController: startSurveyFromRatingInlineNoSkipCheck called for ID: ${survey.surveyId}");

    // Ignore if same survey is already active
    if (activeSurvey.value?.surveyId == survey.surveyId) {
      print("SurveyController: Survey ${survey.surveyId} is already active.");
      return;
    }

    // Clear any old state before starting new survey
    if (activeSurvey.value != null) {
      print(
          "SurveyController: Clearing old survey state before starting survey inline (no skip check).");
      await clearSurveyState();
    }

    // Set order ID - prioritize orderIdParam (from notification), then survey.orderId
    if (orderIdParam != null && orderIdParam > 0) {
      orderId.value = orderIdParam;
      print("SurveyController: Set orderId from parameter: $orderIdParam");
    } else if (survey.orderId != null && survey.orderId! > 0) {
      orderId.value = survey.orderId;
      print("SurveyController: Set orderId from survey model: ${survey.orderId}");
    } else {
      print("SurveyController: WARNING - No orderId available! orderIdParam: $orderIdParam, survey.orderId: ${survey.orderId}");
    }

    // Validate survey has questions before starting
    if (survey.questions == null || survey.questions!.isEmpty) {
      print("SurveyController: Survey ${survey.surveyId} has no questions. Cannot start.");
      return;
    }

    // Set inline mode flag to prevent popup from showing
    isInlineMode.value = true;

    // Start the survey directly at questions (skip landing, no popup, no skip check)
    activeSurvey.value = survey;
    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
    showLanding.value = false; // Skip landing page
    showThankYou.value = false;
    await saveSurveyState();
    
    // Don't show popup - survey will be displayed inline
  }

  void closeSurvey() async {
    // When user closes survey popup, mark as skipped and clear state forever
    if (activeSurvey.value != null) {
      int? surveyId = activeSurvey.value!.surveyId;
      if (surveyId != null) {
        // Mark survey as skipped forever
        String skippedJson =
            await PrefManager.getString(AppConstants.skippedSurveys);
        List<int> skippedIds = [];
        if (skippedJson.isNotEmpty) {
          skippedIds = List<int>.from(jsonDecode(skippedJson));
        }
        if (!skippedIds.contains(surveyId)) {
          skippedIds.add(surveyId);
          await PrefManager.putString(
              AppConstants.skippedSurveys, jsonEncode(skippedIds));
        }
      }
      // Clear all survey state - user closed, don't show again
      await clearSurveyState();
    }
    Get.back();
  }

  Future<SurveyModel?> fetchSurveyData(int surveyId) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(surveyUrl));
      final response = await request.close();

      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        final Map<String, dynamic> data = jsonDecode(content);

        // Find the survey by ID key
        if (data.containsKey(surveyId.toString())) {
          return SurveyModel.fromJson(data[surveyId.toString()]);
        }
      }
    } catch (e) {
      print("SurveyController: Error fetching survey data: $e");
    }
    return null;
  }

  void nextQuestion() {
    if (activeSurvey.value != null &&
        currentIndex.value < activeSurvey.value!.questions!.length - 1) {
      currentIndex.value++;
      saveSurveyState();
    }
  }

  void previousQuestion() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      saveSurveyState();
    }
  }

  void saveAnswer(int questionId, dynamic answer, {bool autoAdvance = true}) {
    answers[questionId] = answer;
    saveSurveyState();

    // Auto-advance to next question if enabled and valid answer
    if (autoAdvance && activeSurvey.value != null) {
      final currentQuestionIndex = activeSurvey.value!.questions!
          .indexWhere((q) => q.questionId == questionId);

      if (currentQuestionIndex >= 0) {
        final currentQuestion =
            activeSurvey.value!.questions![currentQuestionIndex];
        final isLastQuestion =
            currentQuestionIndex == activeSurvey.value!.questions!.length - 1;

        // Validate answer
        bool isValidAnswer = answer != null &&
            !(answer is List && answer.isEmpty) &&
            !(answer is String && answer.isEmpty);

        // For mandatory questions, ensure answer is valid before advancing
        if (currentQuestion.isMandatory == true && !isValidAnswer) {
          return; // Don't advance if mandatory question not answered
        }

        // Auto-advance or submit
        if (isLastQuestion) {
          // Last question - DON'T auto-submit if it's MULTI_SELECT (user needs to click Submit button)
          // For other question types, auto-submit if valid
          if (currentQuestion.type == "MULTI_SELECT") {
            // Don't auto-submit for multi-select - user will click Submit button
            return;
          } else {
            // Auto-submit for other question types
            if (isValidAnswer || currentQuestion.isMandatory != true) {
              Future.delayed(const Duration(milliseconds: 500), () {
                submitSurvey();
              });
            }
          }
        } else {
          // Not last question - auto-advance if valid answer or non-mandatory
          if (isValidAnswer || currentQuestion.isMandatory != true) {
            Future.delayed(const Duration(milliseconds: 300), () {
              nextQuestion();
            });
          }
        }
      }
    }
  }

  void saveOtherAnswer(int questionId, String optionValue, String text) {
    otherAnswers["${questionId}_$optionValue"] = text;
    saveSurveyState();
  }

  Future<void> skipSurvey() async {
    if (activeSurvey.value != null) {
      int? surveyId = activeSurvey.value!.surveyId;
      if (surveyId != null) {
        // Persist skip decision - mark survey as skipped forever
        String skippedJson =
            await PrefManager.getString(AppConstants.skippedSurveys);
        List<int> skippedIds = [];
        if (skippedJson.isNotEmpty) {
          skippedIds = List<int>.from(jsonDecode(skippedJson));
        }
        if (!skippedIds.contains(surveyId)) {
          skippedIds.add(surveyId);
          await PrefManager.putString(
              AppConstants.skippedSurveys, jsonEncode(skippedIds));
        }
      }
      // Clear all survey state - user skipped, don't show again
      await clearSurveyState();
      
      // Only close modal if not in inline mode
      if (!isInlineMode.value) {
        Get.back(); // Close modal
      }
    }
  }

  Future<void> submitSurvey() async {
    if (activeSurvey.value == null) return;

    // Validate if all mandatory questions are answered
    bool allMandatoryAnswered = activeSurvey.value!.questions!.every((q) {
      if (q.isMandatory == true) {
        final answer = answers[q.questionId];
        if (answer == null) return false;
        if (answer is List && answer.isEmpty) return false;
        if (answer is String && answer.isEmpty) return false;
      }
      return true;
    });

    if (!allMandatoryAnswered) {
      SnackBarUtil.showError(message: "Please answer all mandatory questions.");
      return;
    }

    var progressDialog = ProgressDialog();
    progressDialog.show();
    isSubmitting.value = true;

    var accessToken = await PrefManager.getString(AppConstants.accessToken);
    try {
      // Ensure orderId is set - prioritize orderId.value, then survey.orderId
      final finalOrderId = orderId.value ?? activeSurvey.value!.orderId;
      if (finalOrderId == null || finalOrderId == 0) {
        SnackBarUtil.showError(message: "Order ID is missing. Cannot submit survey.");
        progressDialog.dismiss();
        isSubmitting.value = false;
        return;
      }
      print("SurveyController: Submitting survey with orderId: $finalOrderId (orderId.value: ${orderId.value}, survey.orderId: ${activeSurvey.value!.orderId})");
      
      Map<String, dynamic> params = {
        'survey_id': activeSurvey.value!.surveyId,
        'order_id': finalOrderId,
        'answers': answers.entries.map((e) {
          final questionId = e.key;
          final answer = e.value;

          if (answer is List) {
            // Find the question to check options for allowsText
            final question = activeSurvey.value!.questions
                ?.firstWhere((q) => q.questionId == questionId);

            return {
              'question_id': questionId,
              'answer': answer.map((optValue) {
                final option =
                    question?.options?.firstWhere((o) => o.value == optValue);
                if (option?.allowsText == true) {
                  return {
                    'option': optValue,
                    'text': otherAnswers["${questionId}_$optValue"] ?? "",
                  };
                }
                return optValue;
              }).toList(),
            };
          }

          return {
            'question_id': questionId,
            'answer': answer,
          };
        }).toList(),
      };

      ApiResponseModel<EmptyResponse>? baseModel =
          await DioClient.base(accessToken: accessToken)
              .funSubmitSurveyApi(params);

      if (baseModel?.success == true) {
        progressDialog.dismiss();
        await clearSurveyState();
        
        // If inline survey mode, call completion callback instead of showing thank you
        if (onSurveyCompleteCallback != null) {
          onSurveyCompleteCallback!();
        } else {
          showThankYou.value = true;
          // The popup will now show the Thank You state
        }
      } else {
        progressDialog.dismiss();
        SnackBarUtil.showError(
            message: baseModel?.message ?? "Failed to submit survey.");
      }
    } on CustomHttpException catch (exception) {
      progressDialog.dismiss();
      SnackBarUtil.showError(
          message: handleApiException(
              exception.code, exception.response, exception.exception,
              type: exception.type));
    } catch (exception) {
      progressDialog.dismiss();
      SnackBarUtil.showError(message: 'something_went_wrong'.tr);
    } finally {
      isSubmitting.value = false;
    }
  }

  void showSurveyPopup() {
    // Don't show popup if in inline mode (for Order Picked screen)
    if (isInlineMode.value) {
      print("SurveyController: Inline mode active, not showing popup.");
      return;
    }
    
    print(
        "SurveyController: showSurveyPopup called. activeSurvey: ${activeSurvey.value?.surveyId}");
    if (Get.isDialogOpen == true) {
      print("SurveyController: Dialog already open, skipping.");
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback((_) {
      print("SurveyController: Executing Get.dialog");
      Get.dialog(
        const SurveyPopup(),
        barrierDismissible: false,
      );
    });
  }
}
