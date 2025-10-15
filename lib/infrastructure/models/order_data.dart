import 'package:good_grab/infrastructure/models/api_response_model.dart';

class OrderSuccessData implements Serializable {
  int? orderId;

  OrderSuccessData({this.orderId});

  OrderSuccessData.fromJson(Map<String, dynamic> json) {
   orderId = int.parse(json['order_id'].toString());
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
    };
  }
}

