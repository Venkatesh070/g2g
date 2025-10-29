import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../presentation/widgets/mandatory_update_dialog.dart';

class UpdateCheckerService {
  static final UpdateCheckerService _instance = UpdateCheckerService._internal();
  factory UpdateCheckerService() => _instance;
  UpdateCheckerService._internal();

  bool _dialogShown = false;

  // --- App details ---
  final String _iosAppId = '6451374378';
  final String _iosAppStoreUrl = 'https://apps.apple.com/in/app/good-to-grab/id6451374378';
  final String _androidPackageName = 'com.good.grab';

  Future<bool> checkAndShowMandatoryUpdate() async {
    if (_dialogShown) return true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;
      String? storeVersion;
      String? storeUrl;

      if (Platform.isIOS) {
        // ✅ iOS — Use iTunes API (reliable)
        storeVersion = await _getIOSStoreVersion();
        storeUrl = _iosAppStoreUrl;
      } else if (Platform.isAndroid) {
        // ✅ Android — Use new_version_plus
        final newVersion = NewVersionPlus(androidId: _androidPackageName);
        final VersionStatus? status = await newVersion.getVersionStatus();
        if (status != null) {
          storeVersion = status.storeVersion;
          storeUrl = status.appStoreLink;
        }
      }

      if (storeVersion == null) {
        debugPrint('⚠️ Store version not found.');
        return false;
      }

      debugPrint('🟢 Current version: $currentVersion');
      debugPrint('🟢 Store version: $storeVersion');

      if (_isStoreVersionNewer(currentVersion, storeVersion)) {
        _dialogShown = true;
        await _showMandatoryDialog(storeUrl!);
        return true;
      }
    } catch (e) {
      debugPrint('❌ Update check error: $e');
    }

    return false;
  }

  // --- iOS version check ---
  Future<String?> _getIOSStoreVersion() async {
    try {
      final urls = [
        'https://itunes.apple.com/lookup?id=$_iosAppId&country=in',
        'https://itunes.apple.com/lookup?id=$_iosAppId&country=us',
        'https://itunes.apple.com/lookup?id=$_iosAppId',
      ];

      for (final url in urls) {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['resultCount'] > 0) {
            return jsonResponse['results'][0]['version'];
          }
        }
      }
    } catch (e) {
      debugPrint('Store version fetch error (iOS): $e');
    }
    return null;
  }

  // --- Compare versions ---
  bool _isStoreVersionNewer(String current, String store) {
    try {
      List<int> parse(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
      final currentParts = parse(current);
      final storeParts = parse(store);

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

  // --- Show dialog ---
  Future<void> _showMandatoryDialog(String storeUrl) async {
    await Get.dialog(
      MandatoryUpdateDialog(
        onUpdateNow: () async {
          final uri = Uri.parse(storeUrl);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            debugPrint('⚠️ Could not open store URL.');
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  void reset() => _dialogShown = false;
}
