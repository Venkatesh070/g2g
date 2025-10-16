import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../presentation/widgets/mandatory_update_dialog.dart';

class UpdateCheckerService {
  static final UpdateCheckerService _instance = UpdateCheckerService._internal();
  factory UpdateCheckerService() => _instance;
  UpdateCheckerService._internal();

  bool _dialogShown = false;

  Future<bool> checkAndShowMandatoryUpdate() async {
    if (_dialogShown) return true;

    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String currentVersion = packageInfo.version;

      final newVersion = NewVersionPlus(
        androidId: 'com.good.grab',
        iOSId: 'com.good.grab',
      );
      final VersionStatus? status = await newVersion.getVersionStatus();

      if (status == null) return false;
      final String storeVersion = status.storeVersion;

      if (_isStoreVersionNewer(currentVersion, storeVersion)) {
        _dialogShown = true;
        await _showMandatoryDialog(status.appStoreLink);
        return true;
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  bool _isStoreVersionNewer(String current, String store) {
    List<int> parse(String v) => v.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final a = parse(current);
    final b = parse(store);
    final int maxLen = a.length > b.length ? a.length : b.length;
    for (int i = 0; i < maxLen; i++) {
      final ai = i < a.length ? a[i] : 0;
      final bi = i < b.length ? b[i] : 0;
      if (bi > ai) return true;
      if (bi < ai) return false;
    }
    return false;
  }

  Future<void> _showMandatoryDialog(String appLink) async {
    await Get.dialog(
      MandatoryUpdateDialog(
        onUpdateNow: () async {
          final uri = Uri.parse(appLink);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
      ),
      barrierDismissible: false,
    );
  }
}


