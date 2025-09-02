class ApiResponseModel<T extends Serializable> {
  bool? success;
  String? message;
  T? data;

  ApiResponseModel({this.success, this.message, this.data});

  factory ApiResponseModel.fromJson(Map<String, dynamic> json, Function(Map<String, dynamic>) create) {
    return ApiResponseModel<T>(
      success: json["success"],
      message: json["message"],
      data: json["data"] != null && json["data"].isNotEmpty?create(json['data']):null,
    );
  }

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data!.toJson(),
  };
}

abstract class Serializable {
  Map<String, dynamic> toJson();
}