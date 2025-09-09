import 'dart:convert';

import 'package:good_grab/infrastructure/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class PrefManager {
  static putString(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static getString(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(key) ?? '';
  }

  static putBool(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static getBool(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? false;
  }

  static putInt(key, value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(key, value);
  }

  static getInt(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(key) ?? 0;
  }

  static putDouble(key, double value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(key, value) ;
  }

  static getDouble(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(key) ?? 0.0;
  }

  static remove(key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

// for get current user
  static Future<User?> getUser() async {
    String? json = await PrefManager.getString(AppConstants.userProfile) ?? '';
    print(json);
    if (json!.isNotEmpty) {

      return User.fromJson(jsonDecode(json));
    } else {
      return null;
    }
  }

  static Future<bool> clear() {
    final preference = SharedPreferences.getInstance();
    return preference.then((preference) => preference.clear());
  }

}


