import 'package:com.snowlive/core/model/m_affiliate_product.dart';

/// 추천 상품 화면의 가공 규칙(순수 함수). 위젯과 떼어 둬 테스트하기 쉽다.

/// GNB·타이틀에 쓰는 메뉴 이름. 바꾸려면 여기 하나만.
const String kShopMenuLabel = '추천 상품';

/// `전체` 칩 라벨.
const String kShopAllCategory = '전체';

/// 칩 순서. 데이터에 없는 카테고리는 칩을 만들지 않고, 데이터에만 있는 카테고리는
/// 이 순서 뒤에 붙는다(새 카테고리를 넣어도 화면이 깨지지 않게).
const List<String> kShopCategoryOrder = [
  '리프트권',
  '렌탈',
  '강습',
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

/// 가격 표시 여부. 백엔드 자동수집(sync_affiliate)이 하루 단위로 쿠팡 가격을 다시
/// 가져와 DB를 갱신하므로 켠다 — 완전 실시간은 아니지만 매일 최신에 가깝게 유지된다.
const bool kShopShowsPrice = true;

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

/// 카테고리 정렬 순위 — [kShopCategoryOrder] 위치. 순서표에 없으면 맨 뒤.
int _categoryRank(String category) {
  final i = kShopCategoryOrder.indexOf(category);
  return i < 0 ? kShopCategoryOrder.length : i;
}

/// 정렬 모드 — 추천순(기본, 카테고리·order) / 가격 낮은순 / 가격 높은순.
enum ShopSort { recommended, priceAsc, priceDesc }

/// 정렬 드롭다운 라벨.
String shopSortLabel(ShopSort s) {
  switch (s) {
    case ShopSort.recommended:
      return '추천순';
    case ShopSort.priceAsc:
      return '가격 낮은순';
    case ShopSort.priceDesc:
      return '가격 높은순';
  }
}

/// 현재 카테고리에서 고를 수 있는 **스키장(소분류)** 목록(가나다). 비어 있지 않은
/// `subCategory`만, 중복 제거. 2개 미만이면 드롭다운을 숨기는 판단에 쓴다.
List<String> shopResortOptions(List<AffiliateProduct> items, String category) {
  final seen = <String>{};
  for (final p in items) {
    if (category != kShopAllCategory && p.category != category) continue;
    final r = p.subCategory.trim();
    if (r.isNotEmpty) seen.add(r);
  }
  final out = seen.toList()..sort();
  return out;
}

/// 선택한 카테고리의 상품만. `전체` 탭에서도 **카테고리끼리 묶이게** 1차로 카테고리
/// 순서, 그 안에서 `order` 오름차순(같으면 id)으로 정렬한다. 특정 카테고리를
/// 고르면 1차 키가 상수라 사실상 order 정렬과 같다.
///
/// [resort]가 있으면 그 스키장(소분류)만, [sort]가 가격이면 가격순으로 재정렬한다
/// (가격 없는 항목은 항상 뒤로).
List<AffiliateProduct> shopVisibleItems(
  List<AffiliateProduct> items,
  String category, {
  String resort = '',
  ShopSort sort = ShopSort.recommended,
}) {
  var filtered = category == kShopAllCategory
      ? items.toList()
      : items.where((p) => p.category == category).toList();
  if (resort.isNotEmpty) {
    filtered = filtered.where((p) => p.subCategory == resort).toList();
  }
  if (sort == ShopSort.priceAsc || sort == ShopSort.priceDesc) {
    filtered.sort((a, b) {
      final ap = a.salesPrice, bp = b.salesPrice;
      if (ap == null && bp == null) return a.id.compareTo(b.id);
      if (ap == null) return 1; // 가격 없는 건 뒤로
      if (bp == null) return -1;
      final c = sort == ShopSort.priceAsc ? ap.compareTo(bp) : bp.compareTo(ap);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
    return filtered;
  }
  filtered.sort((a, b) {
    final byCat = _categoryRank(a.category).compareTo(_categoryRank(b.category));
    if (byCat != 0) return byCat;
    final byOrder = a.order.compareTo(b.order);
    return byOrder != 0 ? byOrder : a.id.compareTo(b.id);
  });
  return filtered;
}

/// 백엔드 호스트(이미지 프록시용).
const String _kShopApiBase = 'https://snowlive-api-c617725e2b78.herokuapp.com';

/// 쿠팡 CDN 이미지는 CORS 헤더가 없어, 웹(Flutter CanvasKit)이 바이트 디코드를
/// 못 하고 카드마다 `<img>` 플랫폼뷰로 폴백한다 → 상품이 많으면 iOS Safari/PWA가
/// 메모리로 **반복 크래시**. 백엔드 프록시(CORS 포함)를 거치게 해서 캔버스 디코드
/// 경로로 돌려 플랫폼뷰를 없앤다. 쿠팡 외 URL은 그대로 둔다.
String shopProxiedImageUrl(String url) {
  if (url.isEmpty) return url;
  if (!url.contains('coupangcdn.com') && !url.contains('coupang.com')) return url;
  return '$_kShopApiBase/api/affiliate/img/?u=${Uri.encodeComponent(url)}';
}

/// 쿠팡 CDN 썸네일 URL의 `212x212ex` 같은 크기 구간을 [size]로 바꾼다.
/// 크기 구간이 없는 URL은 그대로 돌려준다.
String shopImageUrlAt(String url, int size) {
  final re = RegExp(r'/(\d+)x(\d+)ex/');
  if (!re.hasMatch(url)) return url;
  return url.replaceFirst(re, '/${size}x${size}ex/');
}

/// 카드 보조 줄: `브랜드 · 소분류` — 비어 있는 쪽은 뺀다. 둘 다 비면(어드민에서
/// 쿠팡 코드만 붙여넣은 상품) 카테고리를 쓴다 — 빈 줄이 남으면 제목과 `쿠팡에서 보기`
/// 사이가 벌어져 다른 카드와 어긋나 보인다.
String shopCardMeta(AffiliateProduct p) {
  final meta = [p.brand, p.subCategory].where((s) => s.isNotEmpty).join(' · ');
  return meta.isEmpty ? p.category : meta;
}

/// 어드민에서 '블로그용 태그'를 붙여넣으면 이미지가 쿠팡 **배너**(120×240 @2x = 240×480)로
/// 온다 — 상품 사진 위아래로 쿠팡 로고·제목·로켓배지·'쇼핑하기' 버튼이 같이 그려진 그림.
/// 이걸 정사각 셀에 그대로 넣으면 글자가 잘려 보이고 상품도 작아진다.
bool shopIsBannerImage(String url) => url.contains('/image/affiliate/banner/');

/// 배너 안에서 상품 사진이 차지하는 정사각 구간(세로 비율). 실측(배너 7장): 로고가
/// 19~49, 제목이 316~337에 있고 사진은 그 사이 240×240 = **64~304**에 가운데 정렬.
/// 가로는 전체 폭(0~240)이다.
const double kShopBannerPhotoTop = 64 / 480;
const double kShopBannerPhotoHeight = 240 / 480;
