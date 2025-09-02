import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:get/get.dart';

import '../navigation/routes.dart';

class DynamicLinkService {
  // FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  Future<void> initDynamicLinks(PendingDynamicLinkData initialLink) async {
    final Uri deepLink = initialLink.link;

    String url = deepLink.toString();
    Uri uri = Uri.parse(url);
    String? resId = uri.queryParameters['resId'].toString();
    String? currency = uri.queryParameters['currency'];

    Get.offAllNamed(Routes.homeDetails,
        arguments: {'resId': int.parse(resId.toString()), 'currency': currency, 'type': 'deeplink'});
  }
}
