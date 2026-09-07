import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/mobile/util/secure_storage_helper.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  /// 콜드 스타트 시 보류된 딥링크
  Uri? _pendingUri;

  /// iOS warm start 중복 방지용
  DateTime? _lastHandledAt;
  String? _lastHandledUrl;

  static const _nativeChannel = MethodChannel('deep_link_native');

  @override
  void onInit() {
    super.onInit();
    _appLinks = AppLinks();
    _listenDeepLinks();
    _listenNativeChannel();
    _handleInitialLink();
  }

  /// iOS AppDelegate에서 직접 전달하는 URL 수신 (warm start 보완)
  void _listenNativeChannel() {
    _nativeChannel.setMethodCallHandler((call) async {
      if (call.method == 'onDeepLink') {
        final url = call.arguments as String?;
        if (url != null) {
          _onUriWithDedup(Uri.parse(url));
        }
      }
    });
  }

  /// 중복 호출 방지 (app_links + native channel 동시 수신 대비)
  void _onUriWithDedup(Uri uri) {
    final now = DateTime.now();
    final url = uri.toString();
    if (_lastHandledUrl == url &&
        _lastHandledAt != null &&
        now.difference(_lastHandledAt!).inSeconds < 3) {
      return; // 3초 이내 같은 URL은 무시
    }
    _lastHandledUrl = url;
    _lastHandledAt = now;
    _onUri(uri);
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) {
        // 앱 UI가 아직 준비 안 됐을 수 있으므로 보류
        _pendingUri = uri;
      }
    } catch (_) {}
  }

  /// 앱 UI 준비 완료 후 호출 (예: 스플래시 → 홈/로그인 전환 시)
  void processPendingDeepLink() {
    if (_pendingUri != null) {
      final uri = _pendingUri!;
      _pendingUri = null;
      _onUri(uri);
    }
  }

  void _listenDeepLinks() {
    _sub = _appLinks.uriLinkStream.listen(_onUriWithDedup);
  }

  void _onUri(Uri uri) {
    if (uri.scheme == 'snowlive' && uri.host == 'paceface-link') {
      _handlePacefaceLink();
    }
  }

  Future<void> _handlePacefaceLink() async {
    final userIdStr = await getSecureStorage().read(key: 'user_id');
    if (userIdStr == null || userIdStr.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.dialog(
          AlertDialog(
            title: Text(
              'PaceFace 연동',
              style: SDSTextStyle.bold.copyWith(
                fontSize: 16,
                color: SDSColor.gray900,
              ),
            ),
            content: Text(
              '스노우라이브에 로그인 후\nPACEFACE 연동을 진행해 주세요.',
              style: SDSTextStyle.regular.copyWith(
                fontSize: 14,
                color: SDSColor.gray500,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  '확인',
                  style: SDSTextStyle.bold.copyWith(
                    color: SDSColor.snowliveBlue,
                  ),
                ),
              ),
            ],
          ),
        );
      });
      return;
    }

    final callbackUri = Uri.parse(
      'paceface://snowlive-callback?snowlive_user_id=$userIdStr',
    );
    await launchUrl(callbackUri, mode: LaunchMode.externalApplication);
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}