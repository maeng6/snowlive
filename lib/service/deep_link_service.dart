import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:com.snowlive/util/secure_storage_helper.dart';

class DeepLinkService extends GetxService {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _sub;

  @override
  void onInit() {
    super.onInit();
    _appLinks = AppLinks();
    _listenDeepLinks();
    _handleInitialLink();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri != null) _onUri(uri);
    } catch (_) {}
  }

  void _listenDeepLinks() {
    _sub = _appLinks.uriLinkStream.listen(_onUri);
  }

  void _onUri(Uri uri) {
    if (uri.scheme == 'snowlive' && uri.host == 'paceface-link') {
      _handlePacefaceLink();
    }
  }

  Future<void> _handlePacefaceLink() async {
    final userIdStr = await getSecureStorage().read(key: 'user_id');
    if (userIdStr == null || userIdStr.isEmpty) return;

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