import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/app_constants.dart';

class CommonFunction {
  static String greetingMessage() {
    var timeNow = DateTime.now().hour;
    if (timeNow <= 12) {
      return 'Good Morning';
    } else if ((timeNow > 12) && (timeNow <= 16)) {
      return 'Good Afternoon';
    } else if ((timeNow > 16) && (timeNow < 20)) {
      return 'Good Evening';
    } else {
      return 'Hello';
    }
  }

  static getHeight() {
    if (Get.height <= 300) {
      return Get.height * 0.65;
    } else if (Get.height <= 400 && Get.height > 300) {
      return Get.height * 0.5;
    } else if (Get.height <= 500 && Get.height > 400) {
      return Get.height * 0.4;
    } else if (Get.height <= 600 && Get.height > 500) {
      return Get.height * 0.35;
    } else if (Get.height <= 700 && Get.height > 600) {
      return Get.height * 0.3;
    } else if (Get.height <= 800 && Get.height > 700) {
      return Get.height * 0.25;
    } else if (Get.height <= 900 && Get.height > 800) {
      return Get.height * 0.25;
    } else if (Get.height <= 1000 && Get.height > 900) {
      return Get.height * 0.2;
    } else if (Get.height <= 1100 && Get.height > 1000) {
      return Get.height * 0.2;
    } else if (Get.height <= 1200 && Get.height > 1100) {
      return Get.height * 0.18;
    } else if (Get.height > 1200) {
      return Get.height * 0.15;
    } else {
      return 200;
    }
  }

  static keyboardDismiss(context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }
  }

  static getDeviceType() {
    if (GetPlatform.isAndroid) {
      return 'android';
    } else if (GetPlatform.isIOS) {
      return 'ios';
    } else {
      return 'unknown';
    }
  }

  static getVersionDetails() async {
    var appVersion = await getAppVersion();
    return "{'app_version' : $appVersion,'api_version' : ${AppConstants.apiVersion}}";
  }

  static getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    print('version $version');
    return version;
  }

  static formatPickupTime(String time) {
    return DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(time));
  }

  static dateTimeFormat(data) {
      final df = DateFormat('dd MMM, hh:mm a');
      var dateFormat = df.format(DateTime.fromMillisecondsSinceEpoch(data * 1000).toLocal());
      return dateFormat;
  }

  static formatOrderPickupDate(String strDate) {
    List months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    List weeks = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    var date = DateFormat('yyyy-MM-dd').parse(strDate);
    print(date.month);
    print(date.weekday);
    if (isToday(date.day, date.month, date.year)) {
      return 'Today | ${weeks[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    } else if (isTomorrow(date.day, date.month, date.year)) {
      return 'Tomorrow | ${weeks[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    } else {
      return '${weeks[date.weekday - 1]}, ${date.day} ${months[date.month - 1]}';
    }
  }

  static bool isToday(day, month, year) {
    final now = DateTime.now();
    return now.day == day && now.month == month && now.year == year;
  }

  static bool isTomorrow(day, month, year) {
    final now = DateTime.now();
    return now.day + 1 == day && now.month == month && now.year == year;
  }

  static getTotalHour(String strDate1, String strDate2) {
    var date1 = DateFormat('HH:mm:ss').parse(strDate1);
    var date2 = DateFormat('HH:mm:ss').parse(strDate2);
    return date1.difference(date2).inHours.abs().toString();
  }

  //Differnce in Minutes
   static int getDiffMinutesFromDateTime(String createdDateStr, String createdTimeStr) {
  try {
    createdDateStr = createdDateStr.trim(); // e.g. Sep 02,2025
    String timeStr = createdTimeStr.trim(); // e.g. 16:04 PM
    String combinedStr = '$createdDateStr $timeStr';

    // Fix case like "16:04 PM" → "04:04 PM"
    final timeParts = timeStr.split(':');
    if (timeParts.isNotEmpty) {
      int hour = int.tryParse(timeParts[0]) ?? 0;
      if (hour > 12) {
        hour -= 12;
        timeStr = '${hour.toString().padLeft(2, '0')}:${timeParts[1]}';
        combinedStr = '$createdDateStr $timeStr';
      }
    }

    // ✅ Correct parser (12h + AM/PM)
    final createdDateTime = DateFormat('MMM dd,yyyy hh:mm a').parse(combinedStr);
    final now = DateTime.now();

    return now.difference(createdDateTime).inMinutes;
  } catch (e) {
    debugPrint("Error parsing datetime: $e");
    return 0;
  }
}


// common_functions.dart
// Update the parsePickupDateTime method to handle the API format
static DateTime parsePickupDateTime(String dateStr, String timeStr) {
  try {
    // Parse date (format: "2025-09-12")
    final dateParts = dateStr.split('-');
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    
    // Parse time (format: "16:54:00")
    final timeParts = timeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    // Create DateTime object
    return DateTime(year, month, day, hour, minute);
  } catch (e) {
    print('Error parsing pickup time: $e');
    return DateTime.now(); // Fallback to current time
  }
}

// Add this method to format time for display
static String formatTimeForDisplay(String timeStr) {
  try {
    final timeParts = timeStr.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);
    
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  } catch (e) {
    return timeStr; // Return original if parsing fails
  }
}
}
