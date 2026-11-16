import 'dart:convert';

import 'package:com.snowlive/core/model/m_affiliate_product.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;

/// 추천 상품 목록을 가져오는 곳. 뷰모델은 이 인터페이스만 본다.
///
/// 지금은 [AssetAffiliateProductRepository](하드코딩 JSON)만 있다. 서버 API가 생기면
/// 같은 인터페이스로 `ApiAffiliateProductRepository`를 만들어 바인딩에서 바꿔 끼우면
/// 화면·뷰모델은 손대지 않는다.
abstract class AffiliateProductRepository {
  Future<List<AffiliateProduct>> fetchAll();
}

/// 하드코딩 소스 — `assets/json/affiliate_products.json`.
/// 파일 모양이 곧 서버 응답 제안이다: `{"products": [ {…}, … ]}`.
class AssetAffiliateProductRepository implements AffiliateProductRepository {
  static const String assetPath = 'assets/json/affiliate_products.json';

  const AssetAffiliateProductRepository();

  @override
  Future<List<AffiliateProduct>> fetchAll() async {
    final text = await rootBundle.loadString(assetPath);
    return parseAffiliateProducts(jsonDecode(text));
  }
}

/// 서버 소스 — `GET /api/affiliate/products/`. 어드민 '추천상품 관리'에서 등록한
/// 쿠팡 상품을 받아온다. 응답 모양은 [AssetAffiliateProductRepository]와 동일하다.
class ApiAffiliateProductRepository implements AffiliateProductRepository {
  static const String url =
      'https://snowlive-api-c617725e2b78.herokuapp.com/api/affiliate/products/';

  const ApiAffiliateProductRepository();

  @override
  Future<List<AffiliateProduct>> fetchAll() async {
    // Heroku dyno가 잠들었다 깨면(콜드스타트) 첫 응답이 느리거나 503이 날 수 있다.
    // 타임아웃을 두고 **지수 백오프로 몇 번 재시도**해 그 1회 깨우기를 흡수한다.
    // (타임아웃·재시도가 없으면 콜드스타트 한 번에 바로 에러 화면으로 빠진다.)
    const timeout = Duration(seconds: 12);
    const maxAttempts = 3;
    Object? lastError;
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final res = await http.get(Uri.parse(url)).timeout(timeout);
        // 5xx(부팅 중 503 등)는 재시도 대상. 4xx는 바로 던진다.
        if (res.statusCode >= 500) {
          throw Exception('추천 상품 조회 실패: HTTP ${res.statusCode}');
        }
        if (res.statusCode != 200) {
          throw Exception('추천 상품 조회 실패: HTTP ${res.statusCode}');
        }
        return parseAffiliateProducts(jsonDecode(utf8.decode(res.bodyBytes)));
      } catch (e) {
        lastError = e;
        if (attempt == maxAttempts - 1) break;
        // 0.6s → 1.2s → … 백오프.
        await Future.delayed(Duration(milliseconds: 600 * (1 << attempt)));
      }
    }
    throw Exception('추천 상품 조회 실패: $lastError');
  }
}

/// 응답(또는 목업 파일) → 모델 목록. 깨진 항목은 건너뛰고 `active`가 꺼진 건 뺀다.
List<AffiliateProduct> parseAffiliateProducts(Object? body) {
  final list = body is Map ? body['products'] : body;
  if (list is! List) return const [];
  return [
    for (final raw in list)
      if (AffiliateProduct.tryParse(raw) case final p?)
        if (p.active) p,
  ];
}
