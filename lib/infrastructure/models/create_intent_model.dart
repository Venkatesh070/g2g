import 'package:good_grab/infrastructure/models/api_response_model.dart';

class CreateIntentModel extends Serializable{
  Payment? payment;

  CreateIntentModel({this.payment});

  CreateIntentModel.fromJson(Map<String, dynamic> json) {
    payment =
    json['payment'] != null ? new Payment.fromJson(json['payment']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.payment != null) {
      data['payment'] = this.payment!.toJson();
    }
    return data;
  }
}

class Payment {
  int? transactionId;
  String? paymentId;
  String? intentUrl;
  bool? success;
  String? status;
  Payment({this.transactionId, this.paymentId, this.intentUrl,this.success, this.status});

  Payment.fromJson(Map<String, dynamic> json) {
    transactionId = json['transaction_id'];
    paymentId = json['payment_id'];
    intentUrl = json['intentUrl'];
    success = json['success'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transaction_id'] = this.transactionId;
    data['payment_id'] = this.paymentId;
    data['intentUrl'] = this.intentUrl;
    data['success'] = this.success;
    data['status'] = this.status;
    return data;
  }
}
