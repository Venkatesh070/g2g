import 'package:good_grab/infrastructure/models/api_response_model.dart';


class EarningModel extends Serializable {
  Earning? earning;

  EarningModel({this.earning});

  EarningModel.fromJson(Map<String, dynamic> json) {
    earning =
    json['earning'] != null ? Earning.fromJson(json['earning']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (earning != null) {
      data['earning'] = earning!.toJson();
    }
    return data;
  }
}

class Earning {
  Money? money;
  Co2? co2;

  Earning({this.money, this.co2});

  Earning.fromJson(Map<String, dynamic> json) {
    money = json['money'] != null ? Money.fromJson(json['money']) : null;
    co2 = json['co2'] != null ? Co2.fromJson(json['co2']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (money != null) {
      data['money'] = money!.toJson();
    }
    if (co2 != null) {
      data['co2'] = co2!.toJson();
    }
    return data;
  }
}

class Money {
  String? bag;
  String? orignalValue;
  String? totalPaid;
  String? savedMoney;

  Money({this.bag, this.orignalValue, this.totalPaid, this.savedMoney});

  Money.fromJson(Map<String, dynamic> json) {
    bag = (json['bag']??"0").toString();
    orignalValue = (json['orignal_value']??"0").toString();
    totalPaid = (json['total_paid']??"0").toString();
    savedMoney = (json['saved_money']??"0").toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['bag'] = bag;
    data['orignal_value'] = orignalValue;
    data['total_paid'] = totalPaid;
    data['saved_money'] = savedMoney;
    return data;
  }
}

class Co2 {
  String? savedCo2;
  String? electricity;
  String? phoneCharges;
  String? cupOfCoffee;
  String? hotShower;

  Co2(
      {this.savedCo2,
        this.electricity,
        this.phoneCharges,
        this.cupOfCoffee,
        this.hotShower});

  Co2.fromJson(Map<String, dynamic> json) {
    savedCo2 = (json['saved_co2']??"0.0").toString();
    electricity = (json['electricity']??"0").toString();
    phoneCharges = (json['phone_charges']??"0").toString();
    cupOfCoffee =( json['cup_of_coffee']??"0").toString();
    hotShower =( json['hot_shower']??"0").toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['saved_co2'] = savedCo2;
    data['electricity'] = electricity;
    data['phone_charges'] = phoneCharges;
    data['cup_of_coffee'] = cupOfCoffee;
    data['hot_shower'] = hotShower;
    return data;
  }
}