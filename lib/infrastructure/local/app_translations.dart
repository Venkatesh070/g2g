import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'en.dart';

class AppTranslations extends Translations {

  // Default locale
  static const locale = Locale('en', 'US');
  //Get.deviceLocale

  // fallbackLocale saves the day when the locale gets in trouble
  static const fallbackLocale = Locale('en', 'US');

  // Supported languages
  // Needs to be same order with locales
  static final languages = [
    'en'
  ];

  // Supported locales
  // Needs to be same order with languages
  static final locales = [
    const Locale('en', 'US')
  ];

  // Keys and their translations
  // Translations are separated maps in `lang` file
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': enLang,
  };

  // Gets locale from language, and updates the locale
  void changeLocale(String lang) {
    final locale = _getLocaleFromLanguage(lang);
    Get.updateLocale(locale);
  }

  // Finds language in `languages` list and returns it as Locale
  Locale _getLocaleFromLanguage(String lang) {
    for (int i = 0; i < languages.length; i++) {
      if (lang == languages[i]) return locales[i];
    }
    return Get.locale!;
  }
}
