import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// ⚠️ QA 데모 전용 플래그. true면 이벤트 페이지에서 더미 당첨자 행 + 상품받기 버튼이
/// 로그인/당첨 여부와 무관하게 보이고, 클레임 폼도 인증·백엔드 없이 렌더된다(제출은
/// 실제로 안 보냄). **데모 확인용으로만 켜고 확인 후 반드시 false로 되돌릴 것.**
const bool kPhoenixClaimDemo = false;

/// QA 데모 전용 — 데모에서 '제출'한 당첨자 winner_id. 이벤트 페이지가 이걸 보고
/// 해당 행 버튼을 '신청완료'로 바꾼다(백엔드 없이 전환을 보여주기 위함).
final Set<int> kDemoClaimedWinnerIds = <int>{};

/// 휘팍 콜라보 이벤트 API.
/// - landing: 공개(인증 불필요). open이면 실시간 리더보드, announced면 수상자 포함.
/// - claim(GET/POST): Firebase ID 토큰으로 본인 검증. PII 제출.
class PhoenixAPI {
  static const String _base =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/collab';

  static Future<Map<String, dynamic>> fetchLanding() async {
    final res = await http.get(Uri.parse('$_base/landing/'));
    if (res.statusCode == 200) {
      return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    }
    return {'ok': false, 'events': []};
  }

  static Future<String?> _idToken() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return user.getIdToken();
  }

  /// 내 클레임 상태 조회. {ok, claim_open, claim}
  static Future<Map<String, dynamic>> fetchMyClaim(int winnerId) async {
    final token = await _idToken();
    if (token == null) return {'ok': false, 'error': '로그인이 필요해요.'};
    final res = await http.get(
      Uri.parse('$_base/claim/$winnerId/'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }

  /// 상품 받기 제출/수정.
  static Future<Map<String, dynamic>> submitClaim({
    required int winnerId,
    required String name,
    required String phone,
    required String address,
    String addressDetail = '',
    String postcode = '',
    required bool consent,
  }) async {
    final token = await _idToken();
    if (token == null) return {'ok': false, 'error': '로그인이 필요해요.'};
    final res = await http.post(
      Uri.parse('$_base/claim/$winnerId/'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'address': address,
        'address_detail': addressDetail,
        'postcode': postcode,
        'consent': consent,
      }),
    );
    return jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
  }
}
