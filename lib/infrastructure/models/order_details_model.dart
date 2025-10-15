import 'package:flutter/foundation.dart';
import 'package:good_grab/infrastructure/models/api_response_model.dart';
class OrderDetailsModel extends Serializable{
  int? orderId;
  List<MenuDetails>? menuDetails;
  String? orderStatus;
  String? totalPaid;
  dynamic? price;
  String? gstCharge;
  RefundData? refundData;
  RestaurantDetail? restaurantDetail;
  bool? isRated;
  double? rating;
  String? paymentMethod;
  String? createdDate;
  String? pickupDate;
  String? pickupTime;
  String? pickupEndTime;
  String? createdTime;
  int? pickupCode;
  int? itemQty;
  String? orderCancelReason;
  

  OrderDetailsModel(
      {this.orderId,
        this.menuDetails,
        this.orderStatus,
        this.totalPaid,
        this.price,
        this.gstCharge,
        this.refundData,
        this.restaurantDetail,
        this.isRated,
        this.rating,
        this.paymentMethod,
        this.createdDate,
        this.pickupDate,
        this.pickupTime,
        this.pickupEndTime,
        this.createdTime,
        this.pickupCode,
        this.itemQty,
        this.orderCancelReason
        });

  OrderDetailsModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    if (json['menu_details'] != null) {
      menuDetails = <MenuDetails>[];
      if (json['menu_details'] is Map<String, dynamic>) {
        menuDetails!.add(MenuDetails.fromJson(json['menu_details']));
      } else if (json['menu_details'] is List) {
        json['menu_details'].forEach((v) {
          menuDetails!.add(MenuDetails.fromJson(v));
        });
      }
    }

    debugPrint('menuDetails ${menuDetails}');

    orderStatus = json['order_status'];
    totalPaid = json['total_paid'];
    price = json['price'];
    gstCharge = json['gst_charge'].toString();
   refundData = (json['refund_data'] != null && json['refund_data'] != "Null")
    ? RefundData.fromJson(json['refund_data'])
    : null;
    restaurantDetail = json['restaurant_detail'] != null
        ? RestaurantDetail.fromJson(json['restaurant_detail'])
        : null;
    isRated = json['is_rated']??false;

    rating = (json['rating'] != null && json['rating'] != "Null")
        ? double.parse(json['rating'].toString())
        : 0.0;
    
    paymentMethod = json['payment_method'];
    createdDate = json['created_date'];
    createdTime = json['created_time'];
    pickupDate = json['pickup_date'];
    pickupTime = json['pickup_time'];
    pickupEndTime = json['pickup_end_time'];
    pickupCode = double.parse(json['pickup_code']).round().toInt();
    itemQty = json['item_quantity'];
    orderCancelReason = json['order_cancel_reason'];
    // pickupCode=5690;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    if (menuDetails != null) {
      data['menu_details'] = menuDetails!.map((v) => v.toJson()).toList();
    }
    data['order_status'] = orderStatus;
    data['total_paid'] = totalPaid;
    data['price'] = price;
    data['gst_charge'] = gstCharge;
    data['refund_data'] = refundData;
    if (refundData != null) {
      data['refund_data'] = refundData!.toJson();
    }
    if (restaurantDetail != null) {
      data['restaurant_detail'] = restaurantDetail!.toJson();
    }
    data['is_rated'] = isRated;
    data['rating'] = rating;
    data['payment_method'] = paymentMethod;
    data['created_date'] = createdDate;
    data['created_time'] = createdTime;
    data['pickup_date'] = pickupDate;
    data['pickup_time'] = pickupTime;
    data['pickup_end_time'] = pickupEndTime;
    data['pickup_code'] = pickupCode;
    data['item_quantity'] = itemQty;
    data['order_cancel_reason'] = orderCancelReason;
    return data;
  }
}

class MenuDetails {
  int? menuId;
  String? menuName;
  int? quantity;
  int? offerPrice;
  int? finalPrice;
  String? foodPreference;
  String? menuType;

  MenuDetails(
      {this.menuId,
        this.menuName,
        this.quantity,
        this.offerPrice,
        this.finalPrice,
        this.foodPreference,
      });

  MenuDetails.fromJson(Map<String, dynamic> json) {
    menuId = json['menu_id'];
    menuName = json['menu_name'];
    menuType = json['menu_type']??'';
    quantity = json['quantity'];
    offerPrice = json['offer_price'] != null ? int.parse(json['offer_price'].toString()) : 0;
    finalPrice = json['final_price'] != null ? int.parse(json['final_price'].toString()) : 0;
    foodPreference = json['food_prefrence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['menu_id'] = menuId;
    data['menu_name'] = menuName;
    data['menu_type'] = menuType;
    data['quantity'] = quantity;
    data['offer_price'] = offerPrice;
    data['final_price'] = finalPrice;
    data['food_prefrence'] = foodPreference;
    return data;
  }
}

class RestaurantDetail {
  String? restaurantName;
  String? restaurantProfile;
  String? restaurantCoverProfile;
  double? avgRating;
  String? restaurantAddress;
  int? totalReview;
  int? isVeg;
  double? latitude;
  double? longitude;

  RestaurantDetail(
      {this.restaurantName,
        this.restaurantProfile,
        this.restaurantCoverProfile,
        this.avgRating,
        this.restaurantAddress,
        this.totalReview,
        this.isVeg,
        this.latitude,
        this.longitude
      });

  RestaurantDetail.fromJson(Map<String, dynamic> json) {
    restaurantName = json['restaurant_name'];
    restaurantProfile = json['restaurant_profile'];
    restaurantCoverProfile = json['restaurant_cover_profile'];
    avgRating = double.parse((json['avg_rating']??0).toString());
    restaurantAddress = json['restaurant_address'];
    totalReview = json['total_review']??0;
    isVeg = int.parse((json['is_veg']??0).toString());
    latitude = double.parse((json['latitude']??0).toString());
    longitude = double.parse((json['longitude']??0).toString());
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['restaurant_name'] = restaurantName;
    data['restaurant_profile'] = restaurantProfile;
    data['restaurant_cover_profile'] = restaurantCoverProfile;
    data['avg_rating'] = avgRating;
    data['restaurant_address'] = restaurantAddress;
    data['total_review'] = totalReview;
    data['is_veg'] = isVeg;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    return data;
  }
}

class RefundData {
  int? refundId;
  String? reasonId;
  String? reason;
  String? refundStatus;
  String? refundImage;

  RefundData(
      {this.refundId,
        this.reasonId,
        this.reason,
        this.refundStatus,
        this.refundImage});

  RefundData.fromJson(Map<String, dynamic> json) {
    refundId = json['refund_id'];
    reasonId = json['reason_id'];
    reason = json['reason']??'';
    refundStatus = json['refund_status'];
    refundImage = json['refund_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['refund_id'] = refundId;
    data['reason_id'] = reasonId;
    data['reason'] = reason;
    data['refund_status'] = refundStatus;
    data['refund_image'] = refundImage;
    return data;
  }
}

class InvoiceModel extends Serializable {
  int? orderId;
  String? fileName;
  String? pdfBase64;

  InvoiceModel({this.orderId, this.fileName, this.pdfBase64});

  InvoiceModel.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    fileName = json['file_name'];
    pdfBase64 = json['pdf_base64'];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
      'file_name': fileName,
      'pdf_base64': pdfBase64,
    };
  }
}

