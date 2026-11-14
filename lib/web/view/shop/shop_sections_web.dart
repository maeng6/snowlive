import 'package:com.snowlive/core/model/m_affiliate_product.dart';

/// 추천 상품 화면의 가공 규칙(순수 함수). 위젯과 떼어 둬 테스트하기 쉽다.

/// GNB·타이틀에 쓰는 메뉴 이름. 바꾸려면 여기 하나만.
const String kShopMenuLabel = '추천 상품';

/// `전체` 칩 라벨.
const String kShopAllCategory = '전체';

/// 칩 순서. 데이터에 없는 카테고리는 칩을 만들지 않고, 데이터에만 있는 카테고리는
/// 이 순서 뒤에 붙는다(새 카테고리를 넣어도 화면이 깨지지 않게).
const List<String> kShopCategoryOrder = [
  '리프트권·렌탈',
  '스키',
  '보드',
  '보호장비',
  '의류',
  '액세서리',
  '여행·차량',
];

/// 쿠팡 파트너스 활동 고지 — 상품이 보이는 화면마다 **반드시** 들어가야 한다
/// (공정위 심사지침·파트너스 약관). 문구를 바꾸지 말 것.
const String kShopDisclosure =
    '이 포스팅은 쿠팡 파트너스 활동의 일환으로, 이에 따른 일정액의 수수료를 제공받습니다.';

/// 가격 표시 여부. 지금은 수동 수집이라 **끈다** — 쿠팡 가격이 바뀌면 틀려진다.
/// 서버 API가 실시간 가격을 주기 시작하면 켠다.
const bool kShopShowsPrice = false;

/// 카드 이미지 요청 크기. 파트너스 썸네일은 212px이라 PC 셀(최대 250)에서 흐릿해
/// 쿠팡 CDN의 큰 사이즈로 바꿔 요청한다. 없으면 원본(212)으로 폴백.
const int kShopImageSize = 492;

/// `전체` + 데이터에 실제로 있는 카테고리만, [kShopCategoryOrder] 순서로.
List<String> shopCategories(List<AffiliateProduct> items) {
  final present = {for (final p in items) p.category};
  final ordered = [
    for (final c in kShopCategoryOrder)
      if (present.remove(c)) c,
    ...present, // 순서표에 없는 새 카테고리는 뒤에
  ];
  return [kShopAllCategory, ...ordered];
}

/// 선택한 카테고리의 상품만, `order` 오름차순(같으면 id).
List<AffiliateProduct> shopVisibleItems(
  List<AffiliateProduct> items,
  String category,
) {
  final filtered = category == kShopAllCategory
      ? items.toList()
      : items.where((p) => p.category == category).toList();
  filtered.sort((a, b) {
    final byOrder = a.order.compareTo(b.order);
    return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
  });
  return filtered;
}

/// 쿠팡 CDN 썸네일 URL의 `212x212ex` 같은 크기 구간을 [size]로 바꾼다.
/// 크기 구간이 없는 URL은 그대로 돌려준다.
String shopImageUrlAt(String url, int size) {
  final re = RegExp(r'/(\d+)x(\d+)ex/');
  if (!re.hasMatch(url)) return url;
  return url.replaceFirst(re, '/${size}x${size}ex/');
}

/// 카드 보조 줄: `브랜드 · 소분류` — 비어 있는 쪽은 뺀다.
String shopCardMeta(AffiliateProduct p) =>
    [p.brand, p.subCategory].where((s) => s.isNotEmpty).join(' · ');
