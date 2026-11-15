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
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) {
      throw Exception('추천 상품 조회 실패: HTTP ${res.statusCode}');
    }
    return parseAffiliateProducts(jsonDecode(utf8.decode(res.bodyBytes)));
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
