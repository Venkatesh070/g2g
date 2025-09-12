import 'package:good_grab/infrastructure/models/api_response_model.dart';

class OrderSuccessData implements Serializable {
  int? orderId;

  OrderSuccessData({this.orderId});

  OrderSuccessData.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id']; // ✅ should match API field
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'order_id': orderId,
    };
  }
}

