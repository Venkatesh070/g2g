import 'package:good_grab/infrastructure/models/api_response_model.dart';

class OrderModel extends Serializable {
  List<OrdersList>? ordersList;
  var currentPage;
  var totalPage;
  var totalItem;

  OrderModel(
      {this.ordersList, this.currentPage, this.totalPage, this.totalItem});

  OrderModel.fromJson(Map<String, dynamic> json) {
    if (json['orders_list'] != null) {
      ordersList = <OrdersList>[];
      json['orders_list'].forEach((v) {
        ordersList!.add(OrdersList.fromJson(v));
      });
    }
    currentPage = json['current_page'] ?? 1;
    totalPage = json['total_page'] ?? 1;
    totalItem = json['total_item'] ?? 0;
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (ordersList != null) {
      data['orders_list'] = ordersList!.map((v) => v.toJson()).toList();
    }
    data['current_page'] = currentPage;
    data['total_page'] = totalPage;
    data['total_item'] = totalItem;
    return data;
  }
}

class OrdersList {
  var orderId;
  var restaurantId;
  var restaurantName;
  var restaurantProfile;
  var restaurantCoverProfile;
  var restaurantAddress;
  var createdAt;
  var totalPaid;
  var gst;
  var currency;
  var orderStatus;

  OrdersList(
      {this.orderId,
      this.restaurantId,
      this.restaurantName,
      this.restaurantProfile,
      this.restaurantCoverProfile,
      this.restaurantAddress,
      this.createdAt,
      this.totalPaid,
      this.gst,
      this.currency,
      this.orderStatus});

  OrdersList.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    restaurantId = json['restaurant_id'] is int
        ? json['restaurant_id']
        : int.tryParse(json['restaurant_id'].toString() ?? "0");
    restaurantName = json['restaurant_name'];
    restaurantProfile = json['restaurant_profile'];
    restaurantCoverProfile = json['restaurant_cover_profile'];
    restaurantAddress = json['restaurant_address'];
    createdAt = json['created_at'];
    totalPaid = (json['total_paid'] ?? 0).toString();
    gst = (json['gst_charge'] ?? 0).toString();
    currency = json['currency'];
    orderStatus = json['order_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['restaurant_id'] = restaurantId;
    data['restaurant_name'] = restaurantName;
    data['restaurant_profile'] = restaurantProfile;
    data['restaurant_cover_profile'] = restaurantCoverProfile;
    data['restaurant_address'] = restaurantAddress;
    data['created_at'] = createdAt;
    data['total_paid'] = totalPaid;
    data['gst_charge'] = gst;
    data['currency'] = currency;
    data['order_status'] = orderStatus;
    return data;
  }
}
