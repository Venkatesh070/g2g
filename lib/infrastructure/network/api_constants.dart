import 'package:good_grab/infrastructure/constants/app_constants.dart';

class ApiConstants {
  // var baseUrl = 'http://13.126.64.76/api/${AppConstants.apiVersion}';
  
  //Miraki end points
  //  var baseUrl = 'http://13.203.248.52/g2g-staging/api/${AppConstants.apiVersion}';
  var baseUrl = 'http://13.203.248.52/api/${AppConstants.apiVersion}';
  // var baseUrl = 'https://goodtograb.com/api/${AppConstants.apiVersion}';
  // var baseUrl = 'http://goodtograb.com/public/new_code/G2G-NEW/api/${AppConstants.apiVersion}';

  //Miraki end points

  // var baseUrl ='https://goodtograb.com/public/new_code/G2G-NEW/api/${AppConstants.apiVersion}';

  // var baseUrl = 'http://13.201.191.193/api/${AppConstants.apiVersion}';

  // var baseUrl = 'http://13.126.133.231/api/${AppConstants.apiVersion}';
  var mapBaseUrl = 'https://maps.googleapis.com/maps/api/';
  var apiGeoCode = '/geocode/json?key=${AppConstants.mapKey}&address=';

  // place search api
  var apiPlace =
      'place/queryautocomplete/json?key=${AppConstants.mapKey}&input=';

  // auth
  var apiGetCountries = "/getCountrylist";
  var apiSocialLogin = "/social-login";
  var apiLogin = "/login";
  var apiSignup = "/sign-up";
  var apiUpdateToken = "/update-token";

  // utils
  var apiAppContent = '/getappcontent';
  var apiUpdateLocation = '/update-location';
  var apiFilters = '/get-filters-data';
  var getRestroLink = '/get-restro-link';

  // profile
  var apiLogout = '/logout';
  var apiDelete = '/deleteprofile';
  var apiUpdateProfile = '/update-profile';
  var apiIsEmailNumber = '/email-exists';
  var apiSendOtp = '/send-email-otp';

  /// new apis
  var apiSendNOtp = '/send-otp';
  var apiVerifyOtp = '/verify-otp';

  var apiVerifyEmailOtp = '/check-email-otp';
  var apiMyProfile = '/my-profile';
  var apiEarning = '/earning';

  // home
  var apiHome = '/home';
  var apiUserHome = '/user-home-details';
  var apiHomeDetails = '/restaurant-details';
  var apiNewHomeDetails = '/magic-restaurant-details';
  var apiGetNotification = '/get-notifications';
  var removeCart = '/remove-cart';

  // order
  var apiRestaurantAvailability = '/restaurant-availability';
  var apiAddCart = '/add-cart';
  var apiGetCarts = '/get-cart-detail';
  var apiPlaceOrder = '/order';
  var apiPlaceOrderPayment = '/place-order-payment';

  var apiPaymentSuccess = '/order-payment-success';
  var apiPaymentFail = '/order-payment-failed';

  var apiPlaceOrderWithoutPayment = '/place-order-without-payment';
  var apiPlaceOrderWithTransaction = '/place-order-with-transaction';
  var apiCreateIntent = '/createIntent';
  var apiCheckIntentStatus = '/checks-intent-status';
  var apiMyOrders = '/my-orders';
  var apiOrderDetails = '/order-detail';
  var apiOrderCancelReasons = '/cancel-reasons';
  var apiOrderCancel = '/order-cancel';
  var apiOrderRating = '/add-rating';
  var apiDownloadInvoice = '/download-invoice';
  var apiDownloadRefundInvoice = '/download-refund-invoice';

  //fav
  var apiAddFavourites = '/add-favourites';
  var apiGetFavourites = '/get-favourites-list';
}
