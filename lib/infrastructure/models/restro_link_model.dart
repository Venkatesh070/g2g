import 'package:good_grab/infrastructure/models/api_response_model.dart';

class RestroLinkModel extends Serializable{
  String? dynamicLink;

  RestroLinkModel({this.dynamicLink});

  RestroLinkModel.fromJson(Map<String, dynamic> json) {
    dynamicLink = json['dynamic_link'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dynamic_link'] = this.dynamicLink;
    return data;
  }
}
