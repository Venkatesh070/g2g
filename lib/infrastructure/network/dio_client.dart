import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:get/get.dart' as Get;
import 'package:dio/dio.dart';
// import 'package:get/get_core/src/get_main.dart';
import 'package:good_grab/infrastructure/models/app_content_model.dart';
import 'package:good_grab/infrastructure/models/cart_model.dart';
import 'package:good_grab/infrastructure/models/country_model.dart';
import 'package:good_grab/infrastructure/models/fav_model.dart';
import 'package:good_grab/infrastructure/models/filter_model.dart';
import 'package:good_grab/infrastructure/models/home_details_model.dart';
import 'package:good_grab/infrastructure/models/home_model.dart';
import 'package:good_grab/infrastructure/models/order_cancel_reasons_model.dart';
import 'package:good_grab/infrastructure/models/order_details_model.dart';
import 'package:good_grab/infrastructure/models/order_model.dart';
import 'package:good_grab/infrastructure/models/place_search_model.dart';
import 'package:good_grab/infrastructure/models/restaurant_availability_model.dart';
import 'package:good_grab/infrastructure/models/user_home_model.dart';
import 'package:good_grab/infrastructure/models/user_model.dart';
import '../constants/app_constants.dart';
import 'package:good_grab/infrastructure/shared/common_functions.dart';
import '../models/api_response_model.dart';
import '../models/create_intent_model.dart';
import '../models/earning_model.dart';
import '../models/notification_model.dart';
import '../models/restro_link_model.dart';
import '../models/order_data.dart';
import '../navigation/routes.dart';
// import '../shared/error_screen.dart';
import '../shared/http_exception.dart';
import '../shared/pref_manager.dart';
// import '../shared/snackbar.util.dart';
import 'api_constants.dart';
import 'interceptors/logging_interceptor.dart';

class DioClient {
  Dio _dio = Dio();
  DioException? _dioError;
  var apiEndPoints = ApiConstants();
  var tag = 'ApiProvider';

  DioClient.base({remoteBaseUrl, accessToken}) {
    var baseUrl = remoteBaseUrl ?? apiEndPoints.baseUrl;
    BaseOptions dioOptions = BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        // 10 seconds
        receiveTimeout: const Duration(seconds: 10),
        receiveDataWhenStatusError: true,
        followRedirects: false,
        baseUrl: baseUrl);
    _dio = Dio(dioOptions);

    if (accessToken != null && accessToken.toString().isNotEmpty) {
      _dio.options.headers = {
        'Authorization': 'Bearer $accessToken',
        'content-type': 'application/json',
      };
    } else {
      _dio.options.headers = {'content-type': 'application/json'};
    }

    _dio.interceptors.addAll([
      LoggerInterceptor(),
      QueuedInterceptorsWrapper(onRequest: (RequestOptions options, handler) async {
        try {
          final version = await CommonFunction.getAppVersion();
          options.headers['X-App-Version'] = version;
        } catch (_) {}
        return handler.next(options);
      }, onResponse: (Response response, handler) {
        return handler.next(response);
      }, onError: (DioException error, handler) async {
        _dioError = error;

        if (error.response!.statusCode == 401) {
          print('error check');
          String? newAccessToken = await funUpdateTokeApi(
              _dio.options.baseUrl, accessToken, _dioError!.response!, handler);
          if (newAccessToken != null) {
            _dioError!.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';
            return handler.resolve(await _dio.fetch(_dioError!.requestOptions));
          } else {
            return handler.next(_dioError!);
          }
        } else if (error.response!.statusCode == 403) {
          PrefManager.remove(AppConstants.userProfile);
          PrefManager.putBool(AppConstants.loggedIn, false);
          PrefManager.clear();
          Get.Get.offAllNamed(Routes.intro);
        } else {
          return handler.next(error);
        }
      })
    ]);
  }

  //multipart
  DioClient.multipartBase({remoteBaseUrl, accessToken}) {
    var baseUrl = remoteBaseUrl ?? apiEndPoints.baseUrl;
    BaseOptions dioOptions = BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        receiveDataWhenStatusError: true,
        followRedirects: false,
        baseUrl: baseUrl);
    _dio = Dio(dioOptions);
    if (accessToken != null && accessToken.toString().isNotEmpty) {
      _dio.options.headers = {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'multipart/form-data'
      };
    } else {
      _dio.options.headers = {'Content-Type': 'multipart/form-data'};
    }
    _dio.interceptors.addAll([
      LoggerInterceptor(),
      QueuedInterceptorsWrapper(onRequest: (RequestOptions options, handler) async {
        try {
          final version = await CommonFunction.getAppVersion();
          options.headers['X-App-Version'] = version;
        } catch (_) {}
        return handler.next(options);
      }, onResponse: (Response response, handler) {
        return handler.next(response);
      }, onError: (DioException error, handler) async {
        _dioError = error;
        if (error.response!.statusCode == 401) {
          String? newAccessToken = await funUpdateTokeApi(
              _dio.options.baseUrl, accessToken, error.response!, handler);
          if (newAccessToken != null) {
            _dioError!.requestOptions.headers['Authorization'] =
                'Bearer $newAccessToken';
            return handler.resolve(await _dio.fetch(_dioError!.requestOptions));
          } else {
            return handler.next(error);
          }
        } else if (error.response!.statusCode == 403) {
          PrefManager.remove(AppConstants.userProfile);
          PrefManager.putBool(AppConstants.loggedIn, false);
          PrefManager.clear();
          Get.Get.offAllNamed(Routes.intro);
        } else {
          return handler.next(error);
        }
      })
    ]);
  }

  DioClient.mapBase() {
    var baseUrl = apiEndPoints.mapBaseUrl;
    BaseOptions dioOptions = BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        // 10 seconds
        receiveTimeout: const Duration(seconds: 10),
        receiveDataWhenStatusError: true,
        followRedirects: false,
        baseUrl: baseUrl);
    _dio = Dio(dioOptions);
    _dio.interceptors.addAll([
      LoggerInterceptor(),
      QueuedInterceptorsWrapper(onRequest: (RequestOptions options, handler) async {
        try {
          final version = await CommonFunction.getAppVersion();
          options.headers = {
            'content-type': 'application/json',
            'X-App-Version': version,
          };
        } catch (_) {
          options.headers = {'content-type': 'application/json'};
        }
        return handler.next(options);
      }, onResponse: (Response response, handler) {
        return handler.next(response);
      }, onError: (DioException error, handler) async {
        _dioError = error;
        return handler.next(error);
      })
    ]);
  }

// calling api function

  Future funGetPlacesApi(placeName) async {
    try {
      Response response = await _dio.get('${apiEndPoints.apiPlace}$placeName');
      return PlaceSearchModel.fromJson(response.data!);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  /// auth
  Future funGetCountriesApi() async {
    try {
      Response response = await _dio.get(apiEndPoints.apiGetCountries);
      return ApiResponseModel<CountryModel>.fromJson(
          response.data!, (data) => CountryModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funLoginUserApi(Map<String, dynamic> params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiLogin, data: json.encode(params));
      return ApiResponseModel<UserModel>.fromJson(
          response.data!, (data) => UserModel.fromJson(data));
    } catch (error) {
      print("jsdfkll ${error}");
      catchErrorHandler();
    }
    return null;
  }

  Future funSignupUserApi(Map<String, dynamic> params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiSignup, data: json.encode(params));
      return ApiResponseModel<UserModel>.fromJson(
          response.data!, (data) => UserModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funSocialLoginApi(Map<String, dynamic> params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiSocialLogin,
          data: json.encode(params));
      return ApiResponseModel<UserModel>.fromJson(
          response.data!, (data) => UserModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  ///utils
  Future funAppContentApi() async {
    try {
      Response response = await _dio.get(
        apiEndPoints.apiAppContent,
      );
      return ApiResponseModel<AppContentModel>.fromJson(
          response.data!, (data) => AppContentModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funUpdateLocationApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiUpdateLocation,
          data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetGeoCodeApi(placeName) async {
    try {
      Response response =
          await _dio.get('${apiEndPoints.apiGeoCode}$placeName');
      return response.data!;
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funFiltersApi() async {
    try {
      Response response = await _dio.get(apiEndPoints.apiFilters);
      return ApiResponseModel<FilterModel>.fromJson(
          response.data!, (data) => FilterModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  ///Home
  Future funHomeApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiHome, data: json.encode(params));

      return ApiResponseModel<HomeModel>.fromJson(
          response.data!, (data) => HomeModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future removeCartApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.removeCart, data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funUserHomeApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiUserHome, data: json.encode(params));
      return ApiResponseModel<UserHomeModel>.fromJson(
          response.data!, (data) => UserHomeModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funHomeDetailsApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiNewHomeDetails,
          data: json.encode(params));

      return ApiResponseModel<HomeDetailsModel>.fromJson(
          response.data!, (data) => HomeDetailsModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  // cart
  Future funAddCartApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiAddCart, data: json.encode(params));
      return ApiResponseModel<CartModel>.fromJson(
          response.data!, (data) => CartModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetCartApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiGetCarts, data: json.encode(params));
      return ApiResponseModel<CartModel>.fromJson(
          response.data!, (data) => CartModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  // order

  Future funGetOrdersApi(params) async {
    try {
      Response response =
          await _dio.get(apiEndPoints.apiMyOrders, data: json.encode(params));
      log("aaya 123 ${response} ");
      return ApiResponseModel<OrderModel>.fromJson(
          response.data!, (data) => OrderModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetOrderDetailsApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiOrderDetails,
          data: json.encode(params));
      return ApiResponseModel<OrderDetailsModel>.fromJson(
          response.data!, (data) => OrderDetailsModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funPlaceOrderApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiPlaceOrder,
          data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  // Future funPlaceOrderPaymentApi(params) async {
  //   try {
  //     Response response = await _dio.post(apiEndPoints.apiPlaceOrderPayment,
  //         data: json.encode(params));
  //     return ApiResponseModel.fromJson(response.data!, (data) => null);
  //   } catch (error) {
  //     catchErrorHandler();
  //   }
  //   return null;
  // }

//new method
  Future<ApiResponseModel<OrderSuccessData>> funPlaceOrderPaymentApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiPaymentSuccess,
          data: json.encode(params));
      return ApiResponseModel<OrderSuccessData>.fromJson(
          response.data!, (data) => OrderSuccessData.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return ApiResponseModel<OrderSuccessData>();
  }

  Future funPlaceOrderWithoutPaymentApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiPlaceOrder,
          data: json.encode(params));
      log("response  ${response.data!['data']['order_id']}");
      return response.data!['data']['order_id'];
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funPlaceCompleteOrderApi(params) async {
    try {
      Response response = await _dio.post(
          apiEndPoints.apiPlaceOrderWithTransaction,
          data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funCreateIntentApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiCreateIntent,
          data: json.encode(params));
      return ApiResponseModel<CreateIntentModel>.fromJson(
          response.data!, (data) => CreateIntentModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funCheckIntentStatusApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiCheckIntentStatus,
          data: json.encode(params));
      return ApiResponseModel<CreateIntentModel>.fromJson(
          response.data!, (data) => CreateIntentModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetOrderCancelReasonsApi() async {
    try {
      Response response = await _dio.get(apiEndPoints.apiOrderCancelReasons);
      return ApiResponseModel<OrderCancelReasonsModel>.fromJson(
          response.data!, (data) => OrderCancelReasonsModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetNotificationReasonsApi(params) async {
    try {
      Response response = await _dio.get(apiEndPoints.apiGetNotification,
          data: json.encode(params));
      return ApiResponseModel<NotificationResponseModel>.fromJson(
          response.data!, (data) => NotificationResponseModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funOrderCancelApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiOrderCancel, data: params);

      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future<ApiResponseModel<InvoiceModel>> funDownloadInvoiceApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiDownloadInvoice, data: json.encode(params));
      final raw = response.data as Map<String, dynamic>;
      final success = raw['success'] == true;
      final message = raw['message'];
      final dynamic d = raw['data'];
      Map<String, dynamic> dataMap = {};
      if (d is String) {
        dataMap = {
          'order_id': null,
          'file_name': null,
          'pdf_base64': d,
        };
      } else if (d is Map<String, dynamic>) {
        // normalize potential alternate keys
        dataMap = {
          'order_id': d['order_id'],
          'file_name': d['file_name'] ?? d['filename'] ?? d['name'],
          'pdf_base64': d['pdf_base64'] ?? d['pdf'] ?? d['base64'] ?? d['file'],
        };
      } else {
        // Some backends return payload at root instead of under 'data'
        if (raw.containsKey('pdf_base64') || raw.containsKey('pdf') || raw.containsKey('base64')) {
          dataMap = {
            'order_id': raw['order_id'],
            'file_name': raw['file_name'] ?? raw['filename'] ?? raw['name'],
            'pdf_base64': raw['pdf_base64'] ?? raw['pdf'] ?? raw['base64'] ?? raw['file'],
          };
        }
      }

      return ApiResponseModel<InvoiceModel>(
        success: success,
        message: message,
        data: dataMap.isEmpty ? null : InvoiceModel.fromJson(dataMap),
      );
    } catch (error) {
      catchErrorHandler();
    }
    return ApiResponseModel<InvoiceModel>();
  }

   Future<ApiResponseModel<InvoiceModel>> funDownloadRefundInvoiceApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiDownloadRefundInvoice, data: json.encode(params));
      final raw = response.data as Map<String, dynamic>;
      final success = raw['success'] == true;
      final message = raw['message'];
      final dynamic d = raw['data'];
      Map<String, dynamic> dataMap = {};
      if (d is String) {
        dataMap = {
          'order_id': null,
          'file_name': null,
          'pdf_base64': d,
        };
      } else if (d is Map<String, dynamic>) {
        // normalize potential alternate keys
        dataMap = {
          'order_id': d['order_id'],
          'file_name': d['file_name'] ?? d['filename'] ?? d['name'],
          'pdf_base64': d['pdf_base64'] ?? d['pdf'] ?? d['base64'] ?? d['file'],
        };
      } else {
        // Some backends return payload at root instead of under 'data'
        if (raw.containsKey('pdf_base64') || raw.containsKey('pdf') || raw.containsKey('base64')) {
          dataMap = {
            'order_id': raw['order_id'],
            'file_name': raw['file_name'] ?? raw['filename'] ?? raw['name'],
            'pdf_base64': raw['pdf_base64'] ?? raw['pdf'] ?? raw['base64'] ?? raw['file'],
          };
        }
      }

      return ApiResponseModel<InvoiceModel>(
        success: success,
        message: message,
        data: dataMap.isEmpty ? null : InvoiceModel.fromJson(dataMap),
      );
    } catch (error) {
      catchErrorHandler();
    }
    return ApiResponseModel<InvoiceModel>();
  }

  Future funAddOrderRatingApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiOrderRating, data: params);

      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funRestaurantAvailabilityApi(params) async {
    try {
      Response response = await _dio.post(
          apiEndPoints.apiRestaurantAvailability,
          data: json.encode(params));
      return ApiResponseModel<RestaurantAvailabilityModel>.fromJson(
          response.data!, (data) => RestaurantAvailabilityModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  // fav

  Future funAddFavApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiAddFavourites,
          data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetFavApi(params) async {
    try {
      Response response = await _dio.get(apiEndPoints.apiGetFavourites,
          data: json.encode(params));
      return ApiResponseModel<FavoriteModel>.fromJson(
          response.data!, (data) => FavoriteModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  // profile

  Future funLogoutAccountApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiLogout, data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funDeleteAccountApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiDelete, data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funUpdateAccountApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiUpdateProfile, data: params);
      return ApiResponseModel<UserModel>.fromJson(
          response.data!, (data) => UserModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetMyProfileApi() async {
    try {
      Response response = await _dio.get(apiEndPoints.apiMyProfile);
      return ApiResponseModel<UserModel>.fromJson(
          response.data!, (data) => UserModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funGetEarning() async {
    try {
      Response response = await _dio.get(apiEndPoints.apiEarning);
      return ApiResponseModel<EarningModel>.fromJson(
          response.data!, (data) => EarningModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funSendOtpApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiSendOtp, data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funSendNOtpApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiSendNOtp, data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funVerifyNOtpApi(params) async {
    try {
      Response response =
          await _dio.post(apiEndPoints.apiVerifyOtp, data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funVerifyOtpApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiVerifyEmailOtp,
          data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future funIsEmailNumberApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.apiIsEmailNumber,
          data: json.encode(params));
      return ApiResponseModel.fromJson(response.data!, (data) => null);
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  Future getRestroLinkApi(params) async {
    try {
      Response response = await _dio.post(apiEndPoints.getRestroLink,
          data: json.encode(params));
      return ApiResponseModel<RestroLinkModel>.fromJson(
          response.data!, (data) => RestroLinkModel.fromJson(data));
    } catch (error) {
      catchErrorHandler();
    }
    return null;
  }

  /// update token

  funUpdateTokeApi(baseurl, apiToken, res, h1) async {
    try {
      var user = await PrefManager.getUser();
      Map<String, dynamic> param = {"user_id": user!.id};
      Dio dio1 = Dio();

      dio1.options = BaseOptions(
          baseUrl: baseurl, headers: {'content-type': 'application/json'});
      var response = await dio1.post(apiEndPoints.apiUpdateToken, data: param);
      if (response.data['success']! && response.data['data'] != null) {
        PrefManager.putString(
            AppConstants.accessToken, response.data['data']['token']);
        return response.data['data']['token'];
      }
      return;
    } catch (_) {}
  }

// error handler

  catchErrorHandler() {
    if (_checkSocketException(_dioError!)) {
      throw CustomHttpException('', 000, _dioError!, 'socketError');
    } else if (_dioError!.type == DioExceptionType.receiveTimeout ||
        _dioError!.type == DioExceptionType.connectionTimeout) {
      throw CustomHttpException('', 200, _dioError!, 'connectionTimeout');
    } else {
      throw CustomHttpException(
          _dioError!.response!.data['message'] ?? 'Something went wrong',
          _dioError!.response!.statusCode,
          _dioError!,
          'error');
    }
  }

  bool _checkSocketException(DioException err) {
    return err.type == DioExceptionType.unknown && err.error is SocketException;
  }
}
