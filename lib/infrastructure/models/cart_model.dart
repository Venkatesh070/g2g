import 'package:good_grab/infrastructure/models/api_response_model.dart';

class CartModel extends Serializable{
  CartDetails? cartDetails;
  String? callBackUrl;
  String? rApiKey;
  double? platformFee;
  CartModel({this.cartDetails});

  CartModel.fromJson(Map<String, dynamic> json) {
    cartDetails = json['cartDetails'] != null
        ? CartDetails.fromJson(json['cartDetails'])
        : null;
    callBackUrl = json['callback_url']??'';
    rApiKey = json['resorpay_api_key']??'';
    // platformFee = json['platform_fee']??'';
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (cartDetails != null) {
      data['cartDetails'] = cartDetails!.toJson();
    }
    data['callback_url'] = callBackUrl;
    data['resorpay_api_key'] = rApiKey;
    // data['platform_fee'] = platformFee;
    return data;
  }
}

class CartDetails {
  int? cartId;
  List<MenuDetail>? menuDetail;
  int? restroId;
  double? offerPrice;
  double? finalPrice;
  double? gstCharge;
  double? platformFee;
  bool? phonePe;
  bool? razorPay;

  CartDetails(
      {this.cartId,
        this.menuDetail,
        this.restroId,
        this.offerPrice,
        this.finalPrice,
        this.gstCharge,
        this.platformFee,
        this.phonePe,
        this.razorPay,
      });

  CartDetails.fromJson(Map<String, dynamic> json) {
    cartId = json['cart_id'];
    if (json['menu_detail'] != null) {
      menuDetail = <MenuDetail>[];
      json['menu_detail'].forEach((v) {
        menuDetail!.add(MenuDetail.fromJson(v));
      });
    }
    restroId = json['restro_id'];
    offerPrice = double.parse((json['offer_price']??0).toString());
    finalPrice = double.parse((json['final_price']??0).toString());
    gstCharge = double.parse((json['gst_charge']??0).toString());
    platformFee = double.parse((json['platform_fee']??0).toString());
    phonePe = json['phonepe'] ??  true;
    razorPay = json['razorpay'] ??  true;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cart_id'] = cartId;
    if (menuDetail != null) {
      data['menu_detail'] = menuDetail!.map((v) => v.toJson()).toList();
    }
    data['restro_id'] = restroId;
    data['offer_price'] = offerPrice;
    data['final_price'] = finalPrice;
    data['gst_charge'] = gstCharge;
    data['platform_fee'] = platformFee;
    data['phonepe'] = phonePe;
    data['razorpay'] = razorPay;
    return data;
  }
}

class MenuDetail {
  int? menuId;
  String? menuName;
  String? menuStartTime;
  String? menuEndTime;
  double? menuOfferPrice;
  double? menuFinalPrice;
  int? menuQuantity;
  String? foodPrefrence;
  int? menuSelectedQuantity;
  String? menuType;

  MenuDetail(
      {this.menuId,
        this.menuName,
        this.menuOfferPrice,
        this.menuFinalPrice,
        this.menuQuantity,
        this.menuStartTime,
        this.menuEndTime,
        this.foodPrefrence,
        this.menuSelectedQuantity,
        this.menuType
      });

  MenuDetail.fromJson(Map<String, dynamic> json) {
    menuId = json['menu_id'];
    menuName = json['menu_name'];
    menuStartTime = json['menu_start_time'];
    menuEndTime = json['menu_end_time'];
    menuOfferPrice = double.parse((json['menu_offer_price']??'0').toString());
    menuFinalPrice = double.parse((json['menu_final_price']??'0').toString());
    menuQuantity = json['menu_quantity'];
    menuSelectedQuantity = json['menu_selected_quantity'];
    foodPrefrence = json['food_prefrence'];
    menuType = json['menu_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['menu_id'] = menuId;
    data['menu_name'] = menuName;
    data['menu_start_time'] = menuStartTime;
    data['menu_end_time'] = menuEndTime;
    data['menu_offer_price'] = menuOfferPrice;
    data['menu_final_price'] = menuFinalPrice;
    data['menu_quantity'] = menuQuantity;
    data['menu_selected_quantity'] = menuSelectedQuantity;
    data['food_prefrence'] = foodPrefrence;
    data['menu_type'] = menuType;
    return data;
  }
}



