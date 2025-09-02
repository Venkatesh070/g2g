import 'package:good_grab/infrastructure/models/api_response_model.dart';

class RestaurantAvailabilityModel extends Serializable {
  List<Availability>? availability;

  RestaurantAvailabilityModel({this.availability});

  RestaurantAvailabilityModel.fromJson(Map<String, dynamic> json) {
    if (json['availability'] != null) {
      availability = <Availability>[];
      json['availability'].forEach((v) {
        availability!.add(Availability.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (availability != null) {
      data['availability'] = availability!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Availability {
  String? date;
  bool? isAvailable;

  Availability({this.date, this.isAvailable});

  Availability.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    isAvailable = json['is_available'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['date'] = date;
    data['is_available'] = isAvailable??false;
    return data;
  }
}

class PickupDateModel{
  String? title;
  String? pickupDate;
  bool? isSelect;

  PickupDateModel({
    this.title,
    this.pickupDate,
    this.isSelect
  });
}