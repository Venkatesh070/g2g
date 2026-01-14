import 'package:get/get.dart';
import '../navigation/routes.dart';

class LinkRunnerService {
  Future<void> handleLinkRunnerDeepLink(
      Map<dynamic, dynamic> attributionData) async {
    if (!attributionData.containsKey('deeplink')) return;

    final String? deepLinkUrl = attributionData['deeplink'];
    if (deepLinkUrl == null || deepLinkUrl.isEmpty) return;

    final Uri uri = Uri.parse(deepLinkUrl);
    final String? resId = uri.queryParameters['resId'];
    final String? currency = uri.queryParameters['currency'];

    if (resId != null) {
      Get.offAllNamed(
        Routes.homeDetails,
        arguments: {
          'resId': int.parse(resId),
          'currency': currency,
          'type': 'deeplink',
        },
      );
    }
  }
}
