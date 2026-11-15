/// 추천 상품(쿠팡 파트너스 제휴 상품) 한 건.
///
/// 지금은 `assets/json/affiliate_products.json`(하드코딩)에서 읽지만, 필드명은
/// **서버 API 응답과 같은 snake_case**로 맞춰 뒀다 — 서버가 붙으면 이 모델은 그대로
/// 두고 읽어오는 곳만 바꾼다(`AffiliateProductRepository` 참고).
class AffiliateProduct {
  final int id;

  /// 노출 방식 — `link`(우리 커스텀 카드) · `widget`(쿠팡 다이나믹 배너 iframe, 실시간 가격).
  final String kind;
  final String title;

  /// 대분류 — `리프트권·렌탈` · `스키` · `보드` · `보호장비` · `의류` · `액세서리` · `여행·차량`.
  final String category;

  /// 소분류(고글·헬멧·렌탈샵 등). 카드의 보조 줄에 쓴다.
  final String subCategory;
  final String brand;

  /// 파트너스가 제공하는 쿠팡 CDN 썸네일(212x212). 상품 페이지 사진을 직접 복사하지 않는다.
  final String imageUrl;

  /// 파트너스 단축 링크(`https://link.coupang.com/a/…`). 새 탭으로 연다.
  final String url;

  /// 쿠팡 다이나믹 배너 위젯 iframe src(`ads-partners.coupang.com/widgets.html?…`).
  /// `kind == 'widget'`일 때만 채워지며, 이게 있으면 카드 대신 쿠팡 위젯을 iframe으로
  /// 렌더해 **실시간 가격**을 쿠팡이 직접 그려준다(정책상 안전).
  final String embedUrl;

  /// 한 줄 추천 이유(선택).
  final String note;

  /// 수집 시점 가격. **화면에는 쓰지 않는다** — 수동 수집이라 쿠팡 가격이 바뀌면
  /// 틀려진다. API가 실시간 가격을 주면 그때 [kShopShowsPrice]를 켠다.
  final int? originPrice;
  final int? salesPrice;
  final int order;
  final bool active;

  const AffiliateProduct({
    required this.id,
    this.kind = 'link',
    required this.title,
    required this.category,
    required this.subCategory,
    this.brand = '',
    required this.imageUrl,
    required this.url,
    this.embedUrl = '',
    this.note = '',
    this.originPrice,
    this.salesPrice,
    this.order = 0,
    this.active = true,
  });

  /// 쿠팡 위젯(다이나믹 배너)으로 띄워야 하는 상품인가.
  bool get isWidget => kind == 'widget' && embedUrl.isNotEmpty;

  /// 깨진 항목(필수값 누락)은 null — 호출 쪽이 건너뛴다(한 건 때문에 목록 전체가
  /// 안 뜨지 않게, 커뮤니티 목록과 같은 방어).
  static AffiliateProduct? tryParse(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final category = raw['category'];
    final url = _str(raw['url']);
    final embedUrl = _str(raw['embed_url']);
    final kind = _str(raw['kind']).isEmpty ? 'link' : _str(raw['kind']);
    if (id is! num) return null;
    if (category is! String || category.isEmpty) return null;
    // 링크형은 상품 url이, 위젯형은 embed_url이 있어야 유효(둘 중 하나는 http여야).
    final hasLink = url.startsWith('http');
    final hasEmbed = embedUrl.startsWith('http');
    if (!hasLink && !hasEmbed) return null;
    // 제목은 링크형에서만 필수(위젯형은 쿠팡이 직접 그려줌).
    final title = _str(raw['title']);
    if (kind != 'widget' && title.isEmpty) return null;
    return AffiliateProduct(
      id: id.toInt(),
      kind: kind,
      title: title,
      category: category,
      subCategory: _str(raw['sub_category']),
      brand: _str(raw['brand']),
      imageUrl: _str(raw['image_url']),
      url: url,
      embedUrl: embedUrl,
      note: _str(raw['note']),
      originPrice: _int(raw['origin_price']),
      salesPrice: _int(raw['sales_price']),
      order: _int(raw['order']) ?? 0,
      active: raw['active'] != false,
    );
  }

  static String _str(Object? v) => v is String ? v : '';

  static int? _int(Object? v) => v is num ? v.toInt() : null;
}
