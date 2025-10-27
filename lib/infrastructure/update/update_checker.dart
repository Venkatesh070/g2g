import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../presentation/widgets/mandatory_update_dialog.dart';

class UpdateCheckerService {
  static final UpdateCheckerService _instance = UpdateCheckerService._internal();
  factory UpdateCheckerService() => _instance;
  UpdateCheckerService._internal();

  bool _dialogShown = false;
  final String _iosAppId = '6451374378';
  final String _appStoreUrl = 'https://apps.apple.com/in/app/good-to-grab/id6451374378';

  Future<bool> checkAndShowMandatoryUpdate() async {
    if (_dialogShown) return true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      final String? storeVersion = await _getStoreVersion();
      
      if (storeVersion != null && _isStoreVersionNewer(currentVersion, storeVersion)) {
        _dialogShown = true;
        await _showMandatoryDialog();
        return true;
      }
    } catch (e) {
      debugPrint('Update check error: $e');
    }

    return false;
  }

  Future<String?> _getStoreVersion() async {
    try {
      const List<String> urls = [
        'https://itunes.apple.com/lookup?id=6451374378&country=in',
        'https://itunes.apple.com/lookup?id=6451374378&country=us',
        'https://itunes.apple.com/lookup?id=6451374378',
      ];

      for (final url in urls) {
        final String? version = await _fetchVersionFromUrl(url);
        if (version != null) return version;
      }
    } catch (e) {
      debugPrint('Store version fetch error: $e');
    }
    
    return null;
  }

  Future<String?> _fetchVersionFromUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['resultCount'] > 0) {
          return jsonResponse['results'][0]['version'];
        }
      }
    } catch (e) {
      debugPrint('URL fetch error: $e');
    }
    
    return null;
  }

  bool _isStoreVersionNewer(String current, String store) {
    try {
      List<int> parse(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final List<int> currentParts = parse(current);
      final List<int> storeParts = parse(store);
      
      for (int i = 0; i < storeParts.length; i++) {
        if (i >= currentParts.length) return true;
        if (storeParts[i] > currentParts[i]) return true;
        if (storeParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint('Version comparison error: $e');
      return false;
    }
  }

  Future<void> _showMandatoryDialog() async {
    await Get.dialog(
      MandatoryUpdateDialog(
        onUpdateNow: () async {
          try {
            final uri = Uri.parse(_appStoreUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          } catch (e) {
            debugPrint('App Store launch error: $e');
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  void reset() {
    _dialogShown = false;
  }
}