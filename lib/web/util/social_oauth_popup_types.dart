/// 소셜 로그인 팝업 결과.
/// customToken 수신 성공 / 사용자가 취소(팝업 닫음) / 오류 세 갈래.
class SocialLoginResult {
  final String? customToken;
  final String? email;
  final String? nickname;
  final String? error;
  final bool cancelled;

  const SocialLoginResult({
    this.customToken,
    this.email,
    this.nickname,
    this.error,
    this.cancelled = false,
  });

  bool get ok => customToken != null;
}
