import 'social_oauth_popup_types.dart';
export 'social_oauth_popup_types.dart';

/// 비웹 플랫폼: 소셜 로그인 리다이렉트 미지원(앱은 네이티브 SDK + /social-login 사용).
void startSocialLoginRedirect(String startUrl) {}

bool captureSocialRedirectAtBootstrap() => false;

SocialLoginResult? readSocialRedirectResult() => null;

void saveReturnRoute(String? route) {}

String? takeReturnRoute() => null;

void registerUnloadDiscard(String discardUrl, String uid) {}

void clearUnloadDiscard() {}
