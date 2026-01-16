class AppConstants {
  static const int loggerLineLength = 120;
  static const int loggerErrorMethodCount = 8;
  static const int loggerMethodCount = 2;

  static String deviceId = "deviceId";
  static String userId = "userId";
  static String cartId = "cartId";
  static String currency = "currency";
  static String platformFee = "platformFee";
  static String platformGst = "platformGst";

  static String fcmToken = "fcmToken";
  static String accessToken = "accessToken";
  static String loggedIn = "loggedIn";

  static String userProfile = "userProfile";

  static String mapKey = 'AIzaSyCwosLydPkofKtiKCgoUGz7jx-g4uP_1b0';

  static String apiVersion = 'v1';

  static String phonePeMerchantId = 'M1XGI31IO36A'; // Product
  //static String phonePeMerchantId = 'PGTESTPAYUAT'; // sandbox
  static String phonePePayUrl = 'https://api.phonepe.com/apis/hermes/pg/v1/pay';
  static String phonePeSaltKey =
      '9ebc501d-eaae-4ec2-9de0-9b03dff81478'; // production
  //static String phonePeSaltKey = '099eb0cd-02cf-4e2a-8aca-3e6c6aff0399' ; // sandbox
  static String phonePeSaltIndex = '1';

  static String phonePeTestPayUrl =
      'https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/pay';

  static String phonePeCheckStatusUrl =
      'https://api.phonepe.com/apis/hermes/pg/v1/status';
  //static String phonePeCheckStatusUrl = 'https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/status';

  static String phonePeRefundUrl =
      'https://api.phonepe.com/apis/hermes/pg/v1/refund';
  static String phonePeRefundTestUrl =
      'https://api-preprod.phonepe.com/apis/pg-sandbox/pg/v1/refund';
  static String phonePeCheckVPA =
      'https://api.phonepe.com/apis/hermes/pg/v1/vpa/validate';

  static String environmentValue = 'PRODUCTION';
  //static String environmentValue = 'SANDBOX';

  static String? appId = null;
  static bool enableLogging = true;

  static const String linkrunnerToken = 'gWsDHO9F5aW5YLFgKGhqoghG';
  static const String linkrunnerSecretKey = '2e768f22-5550-43bd-839d-3120dc953e89';
  static const String linkrunnerKeyId = '019b7da1-0b1d-7ff1-92b3-4cbe1e9d53f1';
  static const String linkrunnerIOSSecretKey = '4d5aee27-0372-4dcd-a346-c02eab03d5b6';
  static const String linkrunnerIOSKeyId = '019b7da2-eccb-7993-b3ef-8d106fef626f';

  static const String activeSurvey = "activeSurvey";
  static const String surveyAnswers = "surveyAnswers";
  static const String surveyCurrentIndex = "surveyCurrentIndex";
  static const String skippedSurveys = "skippedSurveys";

}
