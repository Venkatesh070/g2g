import 'package:good_grab/infrastructure/models/api_response_model.dart';
class HomeModel extends Serializable{
  List<RestaurantList>? restaurantList;
  int? currentPage;
  String? appCurrency;
  int? totalPage;
  int? totalItem;
  double? platformFee;
  double? platformGst;

  HomeModel(
    {
      this.restaurantList,
       this.currentPage,
        this.totalPage,
         this.totalItem,
         this.platformFee,
          this.platformGst
         });

  HomeModel.fromJson(Map<String, dynamic> json) {
    if (json['restaurant_list'] != null) {
      restaurantList = <RestaurantList>[];
      json['restaurant_list'].forEach((v) {
        restaurantList!.add(RestaurantList.fromJson(v));
      });
    }
    currentPage = json['current_page'];
    appCurrency = json['currency']??'';
    platformGst = double.parse((json['platform_gst'] ?? 0).toString());
    platformFee = double.parse((json['platform_fee'] ?? 0).toString());
    totalPage = json['total_page'];
    totalItem = json['total_item'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (restaurantList != null) {
      data['restaurant_list'] =
          restaurantList!.map((v) => v.toJson()).toList();
    }
    data['current_page'] = currentPage;
    data['currency'] = appCurrency;
    data['platform_fee'] = platformFee;
    data['platform_gst'] = platformGst;
    data['total_page'] = totalPage??1;
    data['total_item'] = totalItem;
    return data;
  }
}

class RestaurantList {
  int? id;
  dynamic userId;
  String? restaurantName;
  dynamic restaurantImage;
  dynamic restaurantCoverImage;
  String? restaurantLocation;
  String? distance;
  double? finalPrice;
  double? offerPrice;
  double? latitude;
  double? longitude;
  int? isVeg;
  String? menuName;
  int? quantity;
  String? isLiked;
  String? openAt;
  String? closeAt;
  double? rating;
  int? totalQuantity;
  bool? soldOutStatus;
  bool? isTodayAvailable;
  String? soldOutTxt;

  RestaurantList(
      {this.id,
        this.userId,
        this.restaurantName,
        this.restaurantImage,
        this.restaurantLocation,
        this.distance,
        this.finalPrice,
        this.offerPrice,
        this.menuName,
        this.quantity,
        this.isLiked,
        this.openAt,
        this.closeAt,
        this.rating,
        this.totalQuantity,
        this.isTodayAvailable,
        this.latitude,
        this.longitude,
        this.soldOutTxt,
        this.soldOutStatus
      });

  RestaurantList.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    restaurantName = json['restaurant_name'];
    restaurantImage = json['restaurant_image'];
    restaurantCoverImage = json['restaurant_cover_image'];
    restaurantLocation = json['restaurant_location']??'';
    distance = (json['distance']??'0').toString();
    finalPrice = double.parse((json['final_price']??0).toString());
    offerPrice = double.parse((json['offer_price']??0).toString());
    latitude = double.parse((json['latitude']??0).toString());
    longitude = double.parse((json['longitude']??0).toString());
    menuName = json['menu_name'];
    quantity = json['quantity']??0;
    isLiked = json['is_liked']??"0";
    isVeg = int.parse((json['is_veg']??"2").toString());
    openAt = json['open_at'];
    closeAt = json['close_at'];
    rating = double.parse((json['rating']??0).toString());
    totalQuantity = json['total_quantity']??0;
    isTodayAvailable = json['is_today_available']??false;
    soldOutTxt = json['sold_out_txt'];
    soldOutStatus = json['sold_out_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['user_id'] = userId;
    data['restaurant_name'] = restaurantName;
    data['restaurant_image'] = restaurantImage;
    data['restaurant_cover_image'] = restaurantCoverImage;
    data['restaurant_location'] = restaurantLocation;
    data['distance'] = distance;
    data['final_price'] = finalPrice;
    data['offer_price'] = offerPrice;
    data['menu_name'] = menuName;
    data['quantity'] = quantity;
    data['is_liked'] = isLiked;
    data['is_veg'] = isVeg;
    data['open_at'] = openAt;
    data['close_at'] = closeAt;
    data['rating'] = rating;
    data['total_quantity'] = totalQuantity;
    data['is_today_available'] = isTodayAvailable;
    data['sold_out_txt'] = soldOutTxt;
    data['sold_out_status'] = soldOutStatus;
    return data;
  }
}


