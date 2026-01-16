
class SurveyModel {
  int? surveyId;
  String? surveyType;
  int? orderId;
  List<SurveyQuestionModel>? questions;

  SurveyModel({
    this.surveyId,
    this.surveyType,
    this.orderId,
    this.questions,
  });

  SurveyModel.fromJson(Map<String, dynamic> json) {
    surveyId = int.tryParse((json['survey_id'] ?? json['id']).toString());
    surveyType = json['survey_type'] ?? json['survey_code'];
    orderId = int.tryParse(
        (json['order_id'] ?? json['Order_id'] ?? json['orderId'])?.toString() ??
            "");
    if (json['questions'] != null) {
      questions = <SurveyQuestionModel>[];
      json['questions'].forEach((v) {
        questions!.add(SurveyQuestionModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['survey_id'] = surveyId;
    data['survey_type'] = surveyType;
    data['Order_id'] = orderId;
    data['order_id'] = orderId;
    if (questions != null) {
      data['questions'] = questions!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SurveyQuestionModel {
  int? questionId;
  String? type;
  String? text;
  bool? isMandatory;
  List<SurveyOption>? options;

  SurveyQuestionModel({
    this.questionId,
    this.type,
    this.text,
    this.isMandatory,
    this.options,
  });

  SurveyQuestionModel.fromJson(Map<String, dynamic> json) {
    questionId = int.tryParse((json['question_id'] ?? json['id']).toString());
    type = json['type'] ?? json['question_type'];
    text = json['text'] ?? json['question_text'];
    isMandatory = json['is_mandatory'] ?? false;
    if (json['options'] != null) {
      if (json['options'] is List && json['options'].isNotEmpty && json['options'].first is Map) {
        options = List<SurveyOption>.from(json['options'].map((v) => SurveyOption.fromJson(v)));
      } else if (json['options'] is List) {
        options = List<String>.from(json['options']).map((o) => SurveyOption(label: o, value: o)).toList();
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['question_id'] = questionId;
    data['type'] = type;
    data['text'] = text;
    data['is_mandatory'] = isMandatory;
    if (options != null) {
      data['options'] = options!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SurveyOption {
  String? label;
  String? value;
  bool? allowsText;
  String? placeholder;

  SurveyOption({this.label, this.value, this.allowsText, this.placeholder});

  SurveyOption.fromJson(Map<String, dynamic> json) {
    label = json['label']?.toString() ?? json['value']?.toString();
    value = json['value']?.toString();
    allowsText = json['allows_text'] ?? false;
    placeholder = json['placeholder']?.toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['label'] = label;
    data['value'] = value;
    data['allows_text'] = allowsText;
    data['placeholder'] = placeholder;
    return data;
  }
}
