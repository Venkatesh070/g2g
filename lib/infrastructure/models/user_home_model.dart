import 'package:good_grab/infrastructure/models/api_response_model.dart';
import 'package:video_player/video_player.dart';
class UserHomeModel extends Serializable{
  UserHomeDetails? userHomeDetails;

  UserHomeModel({this.userHomeDetails});

  UserHomeModel.fromJson(Map<String, dynamic> json) {
    userHomeDetails = json['userHomeDetails'] != null
        ? UserHomeDetails.fromJson(json['userHomeDetails'])
        : null;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (userHomeDetails != null) {
      data['userHomeDetails'] = userHomeDetails!.toJson();
    }
    return data;
  }
}

class UserHomeDetails {
  List<Banners>? banners;
  List<Orders>? orders;
  CartList? cartList;

  UserHomeDetails({this.banners, this.orders, this.cartList});

  UserHomeDetails.fromJson(Map<String, dynamic> json) {
    if (json['banners'] != null) {
      banners = <Banners>[];
      json['banners'].forEach((v) {
        banners!.add(Banners.fromJson(v));
      });
    }
    if (json['orders'] != null) {
      orders = <Orders>[];
      json['orders'].forEach((v) {
        orders!.add(Orders.fromJson(v));
      });
    }
    cartList = json['cartList'] != null
        ? CartList.fromJson(json['cartList'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (banners != null) {
      data['banners'] = banners!.map((v) => v.toJson()).toList();
    }
    if (orders != null) {
      data['orders'] = orders!.map((v) => v.toJson()).toList();
    }
    if (cartList != null) {
      data['cartList'] = cartList!.toJson();
    }
    return data;
  }
}

class Banners {
  int? id;
  int? restroId;
  String? mediaType;
  String? media;
  String? active;
  String? createdAt;
  String? updatedAt;
  VideoPlayerController? videoPlayerController;
  Banners(
      {this.id,
        this.restroId,
        this.mediaType,
        this.media,
        this.active,
        this.createdAt,
        this.updatedAt});

  Banners.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    restroId = json['restro_id'];
    mediaType = json['media_type'];
    media = json['media'];
    active = json['active'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['restro_id'] = restroId;
    data['media_type'] = mediaType;
    data['media'] = media;
    data['active'] = active;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    return data;
  }
}

class Orders {
  int? orderId;
  String? orderStatus;
  int? itemQuantity;
  RestaurantDetail? restaurantDetail;
  String? createdDate;
  String? createdTime;

  Orders(
      {this.orderId,
        this.orderStatus,
        this.itemQuantity,
        this.restaurantDetail,
        this.createdDate,
        this.createdTime});

  Orders.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderStatus = json['order_status'];
    itemQuantity = json['item_quantity'];
    restaurantDetail = json['restaurant_detail'] != null
        ? RestaurantDetail.fromJson(json['restaurant_detail'])
        : null;
    createdDate = json['created_date'];
    createdTime = json['created_time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['order_status'] = orderStatus;
    data['item_quantity'] = itemQuantity;
    if (restaurantDetail != null) {
      data['restaurant_detail'] = restaurantDetail!.toJson();
    }
    data['created_date'] = createdDate;
    data['created_time'] = createdTime;
    return data;
  }
}

class RestaurantDetail {
  int? restaurantId;
  String? restaurantName;
  String? restaurantProfile;
  String? restaurantCoverProfile;
  String? restaurantAddress;
  String? openAt;
  String? closeAt;
  String? soldOutTxt;

  RestaurantDetail(
      {
        this.restaurantId,
        this.restaurantName,
        this.restaurantProfile,
        this.restaurantCoverProfile,
        this.restaurantAddress,
        this.openAt,
        this.closeAt,
        this.soldOutTxt
      }
    );

  RestaurantDetail.fromJson(Map<String, dynamic> json) 
  {
    restaurantId = json['restaurant_id'];
    restaurantName = json['restaurant_name']??'';
    restaurantProfile = json['restaurant_profile']??'';
    restaurantCoverProfile = json['restaurant_cover_profile']??'';
    restaurantAddress = json['restaurant_address']??'';
    openAt = json['open_at'];
    closeAt = json['close_at'];
    soldOutTxt = json['sold_out_txt']??'';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_id'] = restaurantId;
    data['restaurant_name'] = restaurantName;
    data['restaurant_profile'] = restaurantProfile;
    data['restaurant_cover_profile'] = restaurantCoverProfile;
    data['restaurant_address'] = restaurantAddress;
    data['open_at'] = openAt;
    data['close_at'] = closeAt;
    data['sold_out_txt'] = soldOutTxt;
    return data;
  }
}

class CartList {
  int? cartId;
  RestaurantDetail? restroDetail;
  String? totalQuantity;

  CartList({this.cartId, this.restroDetail, this.totalQuantity});

  CartList.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    restroDetail = json['restro_detail'] != null
        ? RestaurantDetail.fromJson(json['restro_detail'])
        : null;
    totalQuantity = (json['total_quantity']??'0').toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    if (restroDetail != null) {
      data['restro_detail'] = restroDetail!.toJson();
    }
    data['total_quantity'] = totalQuantity;
    return data;
  }
}