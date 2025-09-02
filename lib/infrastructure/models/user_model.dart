import 'package:good_grab/infrastructure/models/api_response_model.dart';

class UserModel extends Serializable{
  User? user;

  UserModel({this.user});

  UserModel.fromJson(Map<String, dynamic> json) {
    user = json['user'] != null ? User.fromJson(json['user']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['user'] = user!.toJson();
    }
    return data;
  }
}

class User {
  int? id;
  String? username;
  String? email;
  String? mobile;
  String? countryCode;
  String? deviceType;
  String? loginType;
  String? deviceToken;
  String? deviceId;
  int? countryId;
  dynamic socialId;
  dynamic profile;
  String? isActive;
  String? language;
  String? accessToken;
  double? co2;
  double? savedMoney;
  String? createdAt;

  User(
      {this.id,
        this.username,
        this.email,
        this.mobile,
        this.countryCode,
        this.deviceType,
        this.loginType,
        this.deviceToken,
        this.deviceId,
        this.countryId,
        this.socialId,
        this.profile,
        this.isActive,
        this.language,
        this.accessToken,
        this.co2,
        this.savedMoney,
        this.createdAt});

  User.fromJson(Map<String, dynamic> json) {
    id = json['id']??0;
    username = json['username']??"";
    email = json['email']??"";
    mobile = (json['mobile']??"").toString();
    countryCode = (json['country_code']??'').toString();
    deviceType = json['device_type']??"";
    loginType = json['login_type']??"";
    deviceToken = json['device_token']??"";
    deviceId = json['device_id']!=null ?json['device_id'].toString() :"";
    countryId = json['country_id']??0;
    socialId = json['social_id']??"";
    profile = json['profile']??"";
    isActive = json['is_active']??false;
    language = json['language']??"";
    accessToken = json['access_token']??"";
    co2 = double.parse((json['co2']??0).toString());
    savedMoney = double.parse((json['saved_money']??0).toString());
    createdAt = json['created_at']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['username'] = username;
    data['email'] = email;
    data['mobile'] = mobile;
    data['country_code'] = countryCode;
    data['device_type'] = deviceType;
    data['login_type'] = loginType;
    data['device_token'] = deviceToken;
    data['device_id'] = deviceId;
    data['country_id'] = countryId;
    data['social_id'] = socialId;
    data['profile'] = profile;
    data['is_active'] = isActive;
    data['language'] = language;
    data['access_token'] = accessToken;
    data['co2'] = co2;
    data['saved_money'] = savedMoney;
    data['created_at'] = createdAt;
    return data;
  }
}