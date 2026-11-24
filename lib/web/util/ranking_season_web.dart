import 'package:cloud_firestore/cloud_firestore.dart';

/// 랭킹 API의 `season` 파라미터 값을 계산한다. 모바일은 이 값을
/// `FriendDetailViewModel.getCurrentSeason()`으로 계산하지만 그 클래스는
/// mobile 전용이라 웹에서는 이 파이어스토어 조회 로직만 작게 복제해서 쓴다.
/// 형식은 모바일과 동일하게 "$startDate, $endDate" (쉼표+공백).
Future<String?> fetchCurrentRankingSeason() async {
  try {
    // ⚠️ 일부 네트워크에서 Firestore 첫 get()이 응답 없이 멈추면 이 await가
    // 영영 끝나지 않아 크루홈 등 호출부가 '로딩 중'에 걸린다 → 타임아웃을 두고,
    // 못 받으면 null을 돌려 서버가 기본(현재) 시즌으로 처리하게 한다.
    final doc = await FirebaseFirestore.instance
        .collection('seasonInfo')
        .doc('seasonInfo')
        .get()
        .timeout(const Duration(seconds: 6));
    final data = doc.data();
    if (data == null) return null;
    final startDate = data['startDate'];
    final endDate = data['endDate'];
    if (startDate == null || endDate == null) return null;
    return '$startDate, $endDate';
  } catch (e) {
    print('[Ranking] 시즌 정보 조회 실패: $e');
    return null;
  }
}
