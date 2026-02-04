
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

  final Map<int, TextEditingController> _textControllers = {};
  final Map<String, TextEditingController> _otherTextControllers = {};

  TextEditingController getTextController(int questionId, String initialValue) {
    if (!_textControllers.containsKey(questionId)) {
      _textControllers[questionId] = TextEditingController(text: initialValue);
    }
    return _textControllers[questionId]!;
  }

  TextEditingController getOtherTextController(int questionId, String optionValue, String initialValue) {
    final key = "${questionId}_$optionValue";
    if (!_otherTextControllers.containsKey(key)) {
      _otherTextControllers[key] = TextEditingController(text: initialValue);
    }
    return _otherTextControllers[key]!;
  }

  static final String surveyUrl =
      '${ApiConstants().assetsBaseUrl}/survey.json';

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
    loadSurveyState();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (activeSurvey.value == null) {
        // Only load state if no active survey - loadSurveyState will check for skipped surveys
        loadSurveyState();
      } else {
        // If there's an active survey, verify it wasn't skipped before showing
        if (activeSurvey.value != null) {
          _checkAndShowSurveyIfNotSkipped();
        }
      }
    }
  }
  
  // Helper method to check if survey was skipped before showing
  Future<void> _checkAndShowSurveyIfNotSkipped() async {
    if (activeSurvey.value == null) return;
    
    String skippedJson = await PrefManager.getString(AppConstants.skippedSurveys);
    List<int> skippedIds = [];
    if (skippedJson.isNotEmpty) {
      skippedIds = List<int>.from(jsonDecode(skippedJson));
    }
    
    if (skippedIds.contains(activeSurvey.value!.surveyId)) {
      print("SurveyController: Survey ${activeSurvey.value!.surveyId} was skipped, clearing state.");
      await clearSurveyState();
      return;
    }
    
    // Survey not skipped, safe to show
    if (!Get.isDialogOpen!) {
      showSurveyPopup();
    }
  }

  // Load survey state from local storage
  Future<void> loadSurveyState() async {
    String surveyJson = await PrefManager.getString(AppConstants.activeSurvey);
    if (surveyJson.isNotEmpty) {
      final survey = SurveyModel.fromJson(jsonDecode(surveyJson));
      
      // CRITICAL: Check if this survey was already skipped before loading state
      String skippedJson = await PrefManager.getString(AppConstants.skippedSurveys);
      List<int> skippedIds = [];
      if (skippedJson.isNotEmpty) {
        skippedIds = List<int>.from(jsonDecode(skippedJson));
      }
      
      if (skippedIds.contains(survey.surveyId)) {
        print("SurveyController: Survey ${survey.surveyId} was skipped, clearing saved state.");
        // Survey was skipped, clear all saved state and don't show popup
        await clearSurveyState();
        return;
      }
      
      activeSurvey.value = survey;
      
      // Load current index
      currentIndex.value = await PrefManager.getInt(AppConstants.surveyCurrentIndex);
      
      // Load answers
      String answersJson = await PrefManager.getString(AppConstants.surveyAnswers);
      if (answersJson.isNotEmpty) {
        Map<String, dynamic> decodedAnswers = jsonDecode(answersJson);
        answers.value = decodedAnswers.map((key, value) => MapEntry(int.parse(key), value));
      }

      // Load other answers
      String otherAnswersJson = await PrefManager.getString("survey_other_answers");
      if (otherAnswersJson.isNotEmpty) {
        Map<String, dynamic> decoded = jsonDecode(otherAnswersJson);
        otherAnswers.value = Map<String, String>.from(decoded);
      }

      // Determine if we should show landing or jump straight to questions
      if (currentIndex.value > 0 || answers.isNotEmpty) {
        showLanding.value = false;
      } else {
        showLanding.value = true;
      }

      // Double-check skip status before showing (defensive check)
      // This prevents any race conditions or stale state
      String finalSkippedJson = await PrefManager.getString(AppConstants.skippedSurveys);
      List<int> finalSkippedIds = [];
      if (finalSkippedJson.isNotEmpty) {
        finalSkippedIds = List<int>.from(jsonDecode(finalSkippedJson));
      }
      
      if (finalSkippedIds.contains(activeSurvey.value!.surveyId)) {
        print("SurveyController: Final check - Survey ${activeSurvey.value!.surveyId} was skipped, clearing state.");
        await clearSurveyState();
        return;
      }

      // If we have an active survey, show the popup after a short delay
      // to ensure UI is ready (especially for app launch)
      Future.delayed(Duration(seconds: 1), () {
        // Final check before showing - ensure survey wasn't skipped in the meantime
        if (activeSurvey.value != null && !Get.isDialogOpen!) {
          _checkAndShowSurveyIfNotSkipped();
        }
      });
    }
  }

  // Save survey state to local storage
  Future<void> saveSurveyState() async {
    if (activeSurvey.value != null) {
      await PrefManager.putString(AppConstants.activeSurvey, jsonEncode(activeSurvey.value!.toJson()));
      await PrefManager.putInt(AppConstants.surveyCurrentIndex, currentIndex.value);
      await PrefManager.putString(AppConstants.surveyAnswers, jsonEncode(answers.map((key, value) => MapEntry(key.toString(), value))));
      await PrefManager.putString("survey_other_answers", jsonEncode(otherAnswers));
    }
  }

  // Clear survey state after completion or skip
  Future<void> clearSurveyState() async {
    activeSurvey.value = null;
    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
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
    String skippedJson = await PrefManager.getString(AppConstants.skippedSurveys);
    List<int> skippedIds = [];
    if (skippedJson.isNotEmpty) {
      skippedIds = List<int>.from(jsonDecode(skippedJson));
    }

    if (skippedIds.contains(survey.surveyId)) {
      print("SurveyController: Survey ${survey.surveyId} was already skipped. Ignoring new notification.");
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
      print("SurveyController: Clearing old survey state before starting new survey.");
      await clearSurveyState();
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
  Future<void> onOrderPicked(int? pickedOrderId, {int? pickedSurveyId, SurveyModel? survey}) async {
    print("SurveyController: onOrderPicked called for Order ID: $pickedOrderId, Survey ID: $pickedSurveyId");
    
    orderId.value = pickedOrderId;
    
    SurveyModel? finalSurvey;
    
    // If we have a survey ID, always try to fetch fresh data from remote
    if (pickedSurveyId != null) {
      print("SurveyController: Fetching survey data for ID: $pickedSurveyId");
      finalSurvey = await fetchSurveyData(pickedSurveyId);
      
      // If fetch failed but we have a survey object from notification, use it as fallback
      if (finalSurvey == null && survey != null) {
        print("SurveyController: Remote fetch failed, using fallback from notification.");
        finalSurvey = survey;
      }
    } else {
      finalSurvey = survey;
    }
    
    // CRITICAL: Check if this survey was already skipped before showing it
    if (finalSurvey != null) {
      String skippedJson = await PrefManager.getString(AppConstants.skippedSurveys);
      List<int> skippedIds = [];
      if (skippedJson.isNotEmpty) {
        skippedIds = List<int>.from(jsonDecode(skippedJson));
      }
      
      if (skippedIds.contains(finalSurvey.surveyId)) {
        print("SurveyController: Survey ${finalSurvey.surveyId} was already skipped, not showing.");
        // Clear any old state for this skipped survey
        if (activeSurvey.value?.surveyId == finalSurvey.surveyId) {
          await clearSurveyState();
        }
        return;
      }
      
      // IMPORTANT: Clear any old state before starting new survey
      // This ensures we don't show old/skipped survey data
      if (activeSurvey.value != null && activeSurvey.value!.surveyId != finalSurvey.surveyId) {
        print("SurveyController: Clearing old survey state before starting new survey from notification.");
        await clearSurveyState();
      }
    }
    
    activeSurvey.value = finalSurvey;
    print("SurveyController: Final activeSurvey: ${activeSurvey.value?.surveyId}");
    
    currentIndex.value = 0;
    answers.clear();
    otherAnswers.clear();
    showLanding.value = true;
    showThankYou.value = false;
    
    if (activeSurvey.value != null) {
      await saveSurveyState();
      showSurveyPopup();
    }
  }

  void startSurveyQuestions() {
    showLanding.value = false;
  }

  void closeSurvey() {
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
    if (activeSurvey.value != null && currentIndex.value < activeSurvey.value!.questions!.length - 1) {
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

  void saveAnswer(int questionId, dynamic answer) {
    answers[questionId] = answer;
    saveSurveyState();
  }

  void saveOtherAnswer(int questionId, String optionValue, String text) {
    otherAnswers["${questionId}_$optionValue"] = text;
    saveSurveyState();
  }

  Future<void> skipSurvey() async {
    if (activeSurvey.value != null) {
      int? surveyId = activeSurvey.value!.surveyId;
      if (surveyId != null) {
        // Persist skip decision
        String skippedJson = await PrefManager.getString(AppConstants.skippedSurveys);
        List<int> skippedIds = [];
        if (skippedJson.isNotEmpty) {
          skippedIds = List<int>.from(jsonDecode(skippedJson));
        }
        if (!skippedIds.contains(surveyId)) {
          skippedIds.add(surveyId);
          await PrefManager.putString(AppConstants.skippedSurveys, jsonEncode(skippedIds));
        }
      }
      await clearSurveyState();
      Get.back(); // Close modal
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
      Map<String, dynamic> params = {
        'survey_id': activeSurvey.value!.surveyId,
        'order_id': orderId.value ?? activeSurvey.value!.orderId,
        'answers': answers.entries.map((e) {
          final questionId = e.key;
          final answer = e.value;
          
          if (answer is List) {
            // Find the question to check options for allowsText
            final question = activeSurvey.value!.questions?.firstWhere((q) => q.questionId == questionId);
            
            return {
              'question_id': questionId,
              'answer': answer.map((optValue) {
                final option = question?.options?.firstWhere((o) => o.value == optValue);
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
        showThankYou.value = true;
        // The popup will now show the Thank You state
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
    print("SurveyController: showSurveyPopup called. activeSurvey: ${activeSurvey.value?.surveyId}");
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
