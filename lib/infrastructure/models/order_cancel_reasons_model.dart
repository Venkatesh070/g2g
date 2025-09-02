

import 'package:good_grab/infrastructure/models/api_response_model.dart';

class OrderCancelReasonsModel extends Serializable{
  List<CancelReasons>? cancelReasons;

  OrderCancelReasonsModel({this.cancelReasons});

  OrderCancelReasonsModel.fromJson(Map<String, dynamic> json) {
    if (json['cancelReasons'] != null) {
      cancelReasons = <CancelReasons>[];
      json['cancelReasons'].forEach((v) {
        cancelReasons!.add(CancelReasons.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cancelReasons != null) {
      data['cancelReasons'] =
          cancelReasons!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CancelReasons {
  int? id;
  String? reason;
  String? status;
  String? isPopup;
  String? createdAt;
  String? updatedAt;
  String? reasonImage;

  CancelReasons(
      {this.id, this.reason, this.status,this.isPopup,this.createdAt, this.updatedAt});

  CancelReasons.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    reason = json['reason'];
    status = json['status'];
    isPopup = (json['is_popup']??'0').toString();
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['reason'] = reason;
    data['status'] = status;
    data['is_popup'] = isPopup;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}
