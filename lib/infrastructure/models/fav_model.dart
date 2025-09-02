import 'package:good_grab/infrastructure/models/api_response_model.dart';

class FavoriteModel extends Serializable {
  List<FavouriteList>? favouritList;
  int? currentPage;
  int? totalPage;
  int? totalItem;

  FavoriteModel({this.favouritList, this.currentPage, this.totalPage, this.totalItem});

  FavoriteModel.fromJson(Map<String, dynamic> json) {
    if (json['favouritList'] != null) {
      favouritList = <FavouriteList>[];
      json['favouritList'].forEach((v) {
        favouritList!.add(FavouriteList.fromJson(v));
      });
    }
    currentPage = json['current_page'];
    totalPage = json['total_page'];
    totalItem = json['total_item'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (favouritList != null) {
      data['favouritList'] = favouritList!.map((v) => v.toJson()).toList();
    }
    data['current_page'] = currentPage;
    data['total_page'] = totalPage;

    data['total_item'] = totalItem;
    return data;
  }
}

class FavouriteList {
  int? favouriteId;
  int? userId;
  String? restaurantName;
  int? restaurantId;
  dynamic restaurantImage;
  dynamic restaurantCoverImage;
  String? restaurantLocation;
  String? distance;
  double? finalPrice;
  double? offerPrice;
  int? isVeg;
  String? menuName;
  int? quantity;
  String? isLiked;
  String? openTime;
  String? closeTime;
  String? rating;

  FavouriteList(
      {this.favouriteId,
      this.userId,
      this.restaurantName,
      this.restaurantId,
      this.restaurantImage,
      this.restaurantCoverImage,
      this.restaurantLocation,
      this.distance,
      this.finalPrice,
      this.offerPrice,
      this.isVeg,
      this.menuName,
      this.quantity,
      this.isLiked,
      this.openTime,
      this.closeTime,
      this.rating});

  FavouriteList.fromJson(Map<String, dynamic> json) {
    favouriteId = json['favourite_id'];
    userId = json['user_id'];
    restaurantName = json['restaurant_name'];
    restaurantId = json['restaurant_id'];
    restaurantImage = json['restaurant_image'];
    restaurantCoverImage = json['restaurant_cover_image'];
    restaurantLocation = json['restaurant_location'];
    distance = json['distance'];
    finalPrice = double.parse((json['final_price'] ?? 0).toString());
    offerPrice = double.parse((json['offer_price'] ?? 0).toString());
    isVeg = int.parse((json['is_veg'] ?? "2").toString());
    menuName = json['menu_name'];
    quantity = json['quantity'];
    isLiked = json['is_liked'];
    openTime = json['open_time'];
    closeTime = json['close_time'];
    rating = (json['rating'] ?? '0').toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['favourite_id'] = favouriteId;
    data['user_id'] = userId;
    data['restaurant_name'] = restaurantName;
    data['restaurant_id'] = restaurantId;
    data['restaurant_image'] = restaurantImage;
    data['restaurant_cover_image'] = restaurantCoverImage;
    data['restaurant_location'] = restaurantLocation;
    data['distance'] = distance;
    data['final_price'] = finalPrice;
    data['offer_price'] = offerPrice;
    data['menu_name'] = menuName;
    data['quantity'] = quantity;
    data['is_veg'] = isVeg;
    data['is_liked'] = isLiked;
    data['open_time'] = openTime;
    data['close_time'] = closeTime;
    data['rating'] = rating;
    return data;
  }
}
