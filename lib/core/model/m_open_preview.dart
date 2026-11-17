/// 홈 '개장 미리보기' 항목 1건 — 어드민에서 입력한 스키장·슬로프명·웹캠 URL.
class OpenPreviewItem {
  final int id;
  final String resort; // 스키장
  final String slopeName; // 슬로프명
  final String webcamUrl; // 웹캠 URL

  const OpenPreviewItem({
    required this.id,
    required this.resort,
    this.slopeName = '',
    this.webcamUrl = '',
  });

  /// 깨진 항목(스키장 없음)은 null → 호출 쪽이 건너뛴다.
  static OpenPreviewItem? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final resort = raw['resort'];
    if (id is! num) return null;
    if (resort is! String || resort.isEmpty) return null;
    return OpenPreviewItem(
      id: id.toInt(),
      resort: resort,
      slopeName: raw['slope_name'] is String ? raw['slope_name'] as String : '',
      webcamUrl: raw['webcam_url'] is String ? raw['webcam_url'] as String : '',
    );
  }
}
