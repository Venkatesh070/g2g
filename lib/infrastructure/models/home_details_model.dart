import 'package:good_grab/infrastructure/models/api_response_model.dart';

class HomeDetailsModel extends Serializable {
  RestroDetail? restroDetail;

  HomeDetailsModel({this.restroDetail});

  HomeDetailsModel.fromJson(Map<String, dynamic> json) {
    restroDetail = json['restroDetail'] != null
        ? RestroDetail.fromJson(json['restroDetail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restroDetail != null) {
      data['restroDetail'] = restroDetail!.toJson();
    }
    return data;
  }
}

class RestroDetail {
  int? restaurantId;
  String? restaurantName;
  int? restaurantStatus;
  String? restaurantAddress;
  String? restaurantProfile;
  String? restaurantCoverProfile;
  double? latitude;
  double? longitude;
  String? openTime;
  String? closeTime;
  String? isLiked;
  int? isVeg;
  double? avgRating;
  int? totalReview;
  //List<MenuData>? menuData;
  MPMenuData? menuData;
  List<RestaurantContent>? restaurantContent;

  RestroDetail(
      {this.restaurantId,
      this.restaurantName,
      this.restaurantStatus,
      this.restaurantAddress,
      this.restaurantProfile,
      this.restaurantCoverProfile,
      this.latitude,
      this.longitude,
      this.isVeg,
      this.openTime,
      this.closeTime,
      this.avgRating,
      this.totalReview,
      this.menuData,
      this.restaurantContent});

  RestroDetail.fromJson(Map<String, dynamic> json) {
    restaurantId = json['restaurant_id'];
    restaurantName = json['restaurant_name'];
    restaurantStatus = json['restaurant_status'];
    restaurantAddress = json['restaurant_address'];
    restaurantProfile = json['restaurant_profile'];
    restaurantCoverProfile = json['restaurant_cover_profile'];
    openTime = json['open_time'];
    closeTime = json['close_time'];
    avgRating = double.parse((json['avg_rating'] ?? 0).toString());
    totalReview = int.parse((json['total_review'] ?? 0).toString());
    isVeg = int.parse((json['is_veg'] ?? "2").toString());
    isLiked = (json['is_liked'] ?? "0").toString();
    latitude = double.parse((json['latitude'] ?? "0").toString());
    longitude = double.parse((json['longitude'] ?? "0").toString());
    // if (json['menu_data'] != null) {
    //   menuData = <MenuData>[];
    //   json['menu_data'].forEach((v) {
    //     menuData!.add(MenuData.fromJson(v));
    //   });
    // }

    menuData = json['menu_data'] != null
        ? MPMenuData.fromJson(json['menu_data'])
        : null;

    if (json['restaurant_content'] != null) {
      restaurantContent = <RestaurantContent>[];
      json['restaurant_content'].forEach((v) {
        restaurantContent!.add(RestaurantContent.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_id'] = restaurantId;
    data['restaurant_name'] = restaurantName;
    data['restaurant_status'] = restaurantStatus;
    data['restaurant_address'] = restaurantAddress;
    data['restaurant_profile'] = restaurantProfile;
    data['restaurant_cover_profile'] = restaurantCoverProfile;
    data['open_time'] = openTime;
    data['close_time'] = closeTime;
    data['avg_rating'] = avgRating;
    data['total_review'] = totalReview;
    data['is_veg'] = isVeg;
    data['is_liked'] = isLiked;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    // if (menuData != null) {
    //   data['menu_data'] = menuData!.map((v) => v.toJson()).toList();
    // }
    if (menuData != null) {
      data['menu_data'] = menuData!.toJson();
    }

    if (restaurantContent != null) {
      data['restaurant_content'] =
          restaurantContent!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MenuData {
  String? title;
  String? foodPrefrence;
  int? food_preference_type;
  bool? isOpen = false;
  List<MenuDataList>? list;

  MenuData({
    this.title,
    this.list,
    this.foodPrefrence,
    this.food_preference_type,
  });

  MenuData.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    food_preference_type = json['food_preference_type'];
    foodPrefrence = json['food_prefrence'] ?? '';
    // if (json['list'] != null) {
    //   list = <MenuDataList>[];
    //   json['list'].forEach((v) {
    //     list!.add(MenuDataList.fromJson(v));
    //   });
    // }
    if (json['data'] != null) {
      list = <MenuDataList>[];
      json['data'].forEach((v) {
        list!.add(MenuDataList.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    // if (list != null) {
    //   data['list'] = list!.map((v) => v.toJson()).toList();
    // }
    if (list != null) {
      data['data'] = list!.map((v) => v.toJson()).toList();
    }
    data['food_prefrence'] = foodPrefrence;
    return data;
  }
}

class MenuDataList {
  int? menuId;
  String? menuName;
  String? menuDescription;
  String? menuNote;
  String? foodType;
  double? finalPrice;
  double? offerPrice;
  int? quantity;
  int? selectedQuantity;
  String? foodPrefrence;
  String? menuImage;
  String? startTime;
  bool isTapImage = false;
  String? endTime;

  String? categoryId;
  String? menuType;

  MenuDataList(
      {this.menuId,
      this.menuName,
      this.menuDescription,
      this.foodType,
      this.finalPrice,
      this.offerPrice,
      this.quantity,
      this.menuImage,
      this.startTime,
      required this.isTapImage,
      this.endTime,
      this.foodPrefrence,
      this.categoryId,
      this.menuType});

  MenuDataList.fromJson(Map<String, dynamic> json) {
    menuId = json['menu_id'];
    menuName = json['menu_name'];
    menuDescription = json['menu_description'];
    menuNote = json['note'];
    foodType = json['food_type'];
    finalPrice = double.parse((json['final_price'] ?? 0).toString());
    offerPrice = double.parse((json['offer_price'] ?? 0).toString());
    quantity = int.parse((json['quantity'] ?? 0).toString());
    selectedQuantity = int.parse((json['selected_quantity'] ?? 0).toString());
    foodPrefrence = json['food_prefrence'] ?? '';
    menuImage = json['menu_image'] ?? '';
    startTime = json['start_time'] ?? '';
    endTime = json['end_time'] ?? '';
    categoryId = json['category_id'];
    menuType = json['menu_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['menu_id'] = menuId;
    data['menu_name'] = menuName;
    data['menu_description'] = menuDescription;
    data['note'] = menuNote;
    data['food_type'] = foodType;
    data['final_price'] = finalPrice;
    data['offer_price'] = offerPrice;
    data['quantity'] = quantity;
    data['selected_quantity'] = selectedQuantity;
    data['food_prefrence'] = foodPrefrence;
    data['menu_image'] = menuImage;
    data['start_time'] = startTime;
    data['end_time'] = endTime;
    data['category_id'] = categoryId;
    data['menu_type'] = menuType;
    return data;
  }
}

class RestaurantContent {
  int? contentId;
  int? contentTypeId;
  String? contentType;
  String? description;

  RestaurantContent(
      {this.contentId, this.contentTypeId, this.contentType, this.description});

  RestaurantContent.fromJson(Map<String, dynamic> json) {
    contentId = json['content_id'];
    contentTypeId = json['content_type_id'];
    contentType = json['content_type'];
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['content_id'] = contentId;
    data['content_type_id'] = contentTypeId;
    data['content_type'] = contentType;
    data['description'] = description;
    return data;
  }
}

class MPMenuData {
  List<MenuData>? magic;
  List<MenuData>? preDefined;

  MPMenuData({this.magic, this.preDefined});

  MPMenuData.fromJson(Map<String, dynamic> json) {
    if (json['magic'] != null) {
      magic = <MenuData>[];
      json['magic'].forEach((v) {
        magic!.add(MenuData.fromJson(v));
      });
    }
    if (json['pre_defined'] != null) {
      preDefined = <MenuData>[];
      json['pre_defined'].forEach((v) {
        preDefined!.add(MenuData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (magic != null) {
      data['magic'] = magic!.map((v) => v.toJson()).toList();
    }
    if (preDefined != null) {
      data['pre_defined'] = preDefined!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
