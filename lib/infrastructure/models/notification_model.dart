import 'package:good_grab/infrastructure/models/api_response_model.dart';

class NotificationResponseModel extends Serializable{
  int? currentPage;
  int? lastPage;

  int? total;
  List<NotificationData>? data;

  NotificationResponseModel(
      {this.currentPage,
        this.lastPage,

        this.total,
        this.data});

  NotificationResponseModel.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];

    total = json['total'];
    if (json['data'] != null) {
      data = <NotificationData>[];
      json['data'].forEach((v) {
        data!.add(NotificationData.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = currentPage;
    data['last_page'] = lastPage;

    data['total'] = total;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class NotificationData {
  int? id;
  String? title;
  String? message;
  String? type;
  int? createdAt;

  NotificationData({this.id, this.title, this.message, this.type, this.createdAt});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'] ?? "";
    message = json['message'] ?? "";
    type = json['type'] ?? "";
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['message'] = message;
    data['type'] = type;
    data['created_at'] = createdAt;
    return data;
  }
}
