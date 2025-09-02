import 'package:good_grab/infrastructure/models/api_response_model.dart';

class FilterModel extends Serializable {
  Filters? filters;

  FilterModel({this.filters});

  FilterModel.fromJson(Map<String, dynamic> json) {
    filters =
    json['filters'] != null ? Filters.fromJson(json['filters']) : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (filters != null) {
      data['filters'] = filters!.toJson();
    }
    return data;
  }
}

class Filters {
  List<FoodType>? foodType;
  List<FoodPrefrence>? foodPrefrence;
  String? distanceRange;
  PickupTime? pickupTime;

  Filters(
      {this.foodType, this.foodPrefrence, this.distanceRange, this.pickupTime});

  Filters.fromJson(Map<String, dynamic> json) {
    if (json['food_type'] != null) {
      foodType = <FoodType>[];
      json['food_type'].forEach((v) {
        foodType!.add(FoodType.fromJson(v));
      });
    }
    if (json['food_prefrence'] != null) {
      foodPrefrence = <FoodPrefrence>[];
      json['food_prefrence'].forEach((v) {
        foodPrefrence!.add(FoodPrefrence.fromJson(v));
      });
    }
    distanceRange = json['distance_range'];
    pickupTime = json['pickup_time'] != null
        ? PickupTime.fromJson(json['pickup_time'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (foodType != null) {
      data['food_type'] = foodType!.map((v) => v.toJson()).toList();
    }
    if (foodPrefrence != null) {
      data['food_prefrence'] =
          foodPrefrence!.map((v) => v.toJson()).toList();
    }
    data['distance_range'] = distanceRange;
    if (pickupTime != null) {
      data['pickup_time'] = pickupTime!.toJson();
    }
    return data;
  }
}

class FoodType {
  int? id;
  String? name;
  dynamic image;
  String? deleteStatus;
  String? active;
  String? createdAt;
  String? updatedAt;
  bool? isSelect = false;

  FoodType(
      {this.id,
        this.name,
        this.image,
        this.deleteStatus,
        this.active,
        this.createdAt,
        this.updatedAt});

  FoodType.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    deleteStatus = json['delete_status'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['delete_status'] = deleteStatus;
    data['active'] = active;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class FoodPrefrence {
  int? id;
  String? name;
  String? image;
  String? deleteStatus;
  String? active;
  String? createdAt;
  String? updatedAt;
  bool? isSelect = false;

  FoodPrefrence(
      {this.id,
        this.name,
        this.image,
        this.deleteStatus,
        this.active,
        this.createdAt,
        this.updatedAt});

  FoodPrefrence.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
    deleteStatus = json['delete_status'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    data['delete_status'] = deleteStatus;
    data['active'] = active;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class PickupTime {
  String? pickupStart;
  String? pickupEnd;

  PickupTime({this.pickupStart, this.pickupEnd});

  PickupTime.fromJson(Map<String, dynamic> json) {
    pickupStart = json['pickup_start'];
    pickupEnd = json['pickup_end'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['pickup_start'] = pickupStart;
    data['pickup_end'] = pickupEnd;
    return data;
  }
}

class PickupDay{
  String? title;
  String? image;
  bool? isSelect;

  PickupDay({
    this.title,
    this.image,
    this.isSelect
  });
}

