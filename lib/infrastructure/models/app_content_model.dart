import 'package:good_grab/infrastructure/models/api_response_model.dart';

class AppContentModel extends Serializable{
  Content? content;

  AppContentModel({this.content});

  AppContentModel.fromJson(Map<String, dynamic> json) {
    content =
    json['content'] != null ? Content.fromJson(json['content']) : null;
  }
 
  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (content != null) {
      data['content'] = content!.toJson();
    }
    return data;
  }
}

class Content {
  Aboutus? aboutus;
  Aboutus? termsAndCondition;
  Aboutus? privacyPolicy;
  ContactUs? contactUs;
  List<HelpCenter>? helpCenter;

  Content(
      {this.aboutus,
        this.termsAndCondition,
        this.privacyPolicy,
        this.contactUs,
        this.helpCenter});

  Content.fromJson(Map<String, dynamic> json) {
    aboutus =
    json['aboutus'] != null ? Aboutus.fromJson(json['aboutus']) : null;
    termsAndCondition = json['terms_and_condition'] != null
        ? Aboutus.fromJson(json['terms_and_condition'])
        : null;
    privacyPolicy = json['privacy_policy'] != null
        ? Aboutus.fromJson(json['privacy_policy'])
        : null;
    contactUs = json['contact_us'] != null
        ? ContactUs.fromJson(json['contact_us'])
        : null;
    if (json['help_center'] != null) {
      helpCenter = <HelpCenter>[];
      json['help_center'].forEach((v) {
        helpCenter!.add(HelpCenter.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (aboutus != null) {
      data['aboutus'] = aboutus!.toJson();
    }
    if (termsAndCondition != null) {
      data['terms_and_condition'] = termsAndCondition!.toJson();
    }
    if (privacyPolicy != null) {
      data['privacy_policy'] = privacyPolicy!.toJson();
    }
    if (contactUs != null) {
      data['contact_us'] = contactUs!.toJson();
    }
    if (helpCenter != null) {
      data['help_center'] = helpCenter!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Aboutus {
  int? id;
  String? pageType;
  String? content;
  String? createdAt;
  String? updatedAt;

  Aboutus(
      {this.id, this.pageType, this.content, this.createdAt, this.updatedAt});

  Aboutus.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pageType = json['page_type'];
    content = json['content'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['page_type'] = pageType;
    data['content'] = content;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class ContactUs {
  String? email;
  String? mobile;

  ContactUs({this.email, this.mobile});

  ContactUs.fromJson(Map<String, dynamic> json) {
    email = json['email']??'';
    mobile = json['mobile']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['email'] = email;
    data['mobile'] = mobile;
    return data;
  }
}

class HelpCenter {
  int? id;
  String? faqQuestion;
  String? faqAnswer;
  String? status;
  String? createdAt;
  String? updatedAt;
  bool? isSelect = false;

  HelpCenter(
      {this.id,
        this.faqQuestion,
        this.faqAnswer,
        this.status,
        this.createdAt,
        this.updatedAt});

  HelpCenter.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    faqQuestion = json['faq_question'];
    faqAnswer = json['faq_answer'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['faq_question'] = faqQuestion;
    data['faq_answer'] = faqAnswer;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
