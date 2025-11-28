import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sizer/sizer.dart';
import 'package:upgrader/upgrader.dart';

import 'infrastructure/local/app_translations.dart';
import 'infrastructure/navigation/navigation.dart';
import 'infrastructure/navigation/routes.dart';
import 'infrastructure/theme/theme.dart';
import 'initializer.dart';
import 'infrastructure/analytics/meta_pixel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Initializer.init();
  await Upgrader.clearSavedSettings();

  runApp(const Main());

  WidgetsBinding.instance.addPostFrameCallback((_) {
    AnalyticsService.logAppOpen();
  });
}

class Main extends StatelessWidget {
  const Main({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: GetMaterialApp(
          initialRoute: Routes.splash,
          getPages: AppPages.pageList,
          debugShowCheckedModeBanner: false,
          theme: themeData,
          navigatorObservers: [
            FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
          ],
          builder: (context, Widget? child) {
            final MediaQueryData data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(textScaleFactor: 1.1),
              child: child!,
            );
          },
          supportedLocales: AppTranslations.locales,
          locale: AppTranslations.locale,
          fallbackLocale: AppTranslations.fallbackLocale,
          translations: AppTranslations(),
        ),
      );
    });
  }
}
