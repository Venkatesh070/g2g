
import 'package:good_grab/infrastructure/models/api_response_model.dart';
class CountryModel implements Serializable{
  List<CountryList>? countryList;

  CountryModel({this.countryList});

  CountryModel.fromJson(Map<String, dynamic> json) {
    if (json['countryList'] != null) {
      countryList = <CountryList>[];
      json['countryList'].forEach((v) {
        countryList!.add(CountryList.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (countryList != null) {
      data['countryList'] = countryList!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CountryList {
  int? id;
  String? country;
  String? countryCode;
  String? dialingCode;
  String? currency;
  String? code;
  String? symbol;
  String? priceRate;
  String? status;

  CountryList(
      {this.id,
        this.country,
        this.countryCode,
        this.dialingCode,
        this.currency,
        this.code,
        this.symbol,
        this.priceRate,
        this.status});

  CountryList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    country = json['country'];
    countryCode = json['country_code'];
    dialingCode = json['dialing_code'];
    currency = json['currency'];
    code = json['code'];
    symbol = json['symbol'];
    priceRate = json['price_rate'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['country'] = country;
    data['country_code'] = countryCode;
    data['dialing_code'] = dialingCode;
    data['currency'] = currency;
    data['code'] = code;
    data['symbol'] = symbol;
    data['price_rate'] = priceRate;
    data['status'] = status;
    return data;
  }
}