import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_affiliate_product.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart'
    show kFleamarketDefaultImage, kFleamarketPhotoRadius;
import 'package:com.snowlive/web/view/shop/coupang_widget.dart';
import 'package:com.snowlive/web/view/shop/shop_banner_image.dart';
import 'package:com.snowlive/web/view/shop/shop_sections_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// 카드 이미지(정사각) 아래 텍스트 블록의 고정 높이. 그리드·스켈레톤이 같은 값을
/// 써야 로딩 → 데이터 전환 때 레이아웃이 안 튄다. 모든 글자 줄높이를 1.5로 고정해
/// 계산한다: 간격 10 + 제목 1줄(13) 19.5 + 4 + 가격줄 24 = 57.5 → 58.
/// 가격이 없어도 가격줄 높이를 남겨 **모든 카드에서 가격 줄 위치가 똑같아** 눈으로
/// 비교하기 쉽다. (카드 전체가 쿠팡으로 연결되므로 'CTA 줄'은 두지 않는다.)
double shopCardTextBlockHeight() => 58;

/// 카드 안 모든 글자의 줄높이(위 계산과 같이 움직여야 한다).
const double _kLineHeight = 1.5;

final _shopPriceFormat = NumberFormat('###,###,###,###');

/// 추천 상품 카드 1개: 정사각 이미지 + 제목 2줄 + `브랜드 · 소분류` + `쿠팡에서 보기`.
/// 누르면 파트너스 링크를 **새 탭**으로 연다(상세 화면은 없다 — 규정상 가격·재고를
/// 우리가 들고 있을 수 없어서 쿠팡으로 바로 보낸다).
class ShopCardWeb extends StatefulWidget {
  final AffiliateProduct product;

  /// 테스트·GA 훅. 비우면 링크를 연다.
  final VoidCallback? onTap;

  const ShopCardWeb({super.key, required this.product, this.onTap});

  @override
  State<ShopCardWeb> createState() => _ShopCardWebState();
}

class _ShopCardWebState extends State<ShopCardWeb> {
  bool _hovered = false;

  AffiliateProduct get p => widget.product;

  Future<void> _open() async {
    if (!p.url.startsWith('http')) return; // 위젯형 등 링크 없으면 무시
    final uri = Uri.tryParse(p.url);
    if (uri == null) return;
    // 웹에서 externalApplication은 새 탭이다 — 우리 화면은 그대로 남는다.
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  /// 썸네일 좌상단 카테고리 배지 — 사진 위에서도 읽히게 반투명 검정 pill + 흰 글자.
  Widget _categoryBadge(String category) {
    if (category.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: SDSColor.gray900.withOpacity(0.72),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        category,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 11,
          height: 1.2,
          color: SDSColor.snowliveWhite,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ⚠️ 모바일(특히 인앱 브라우저)에서는 쿠팡 위젯 iframe·배너 DOM 플랫폼뷰를
    // 여러 개 띄우면 WebKit 프로세스가 메모리 한계로 반복 크래시한다
    // ("문제가 반복적으로 발생했습니다"). 모바일에서는 무거운 플랫폼뷰를 끄고
    // 가벼운 이미지 카드로 폴백한다(데스크톱은 그대로).
    final bool heavyOk = context.screenType != WebScreenType.mobile;

    // 다이나믹 배너(위젯)형 — 쿠팡이 실시간 가격까지 그려주는 iframe을 셀에 가득 채운다.
    // 커스텀 카드 대신 쿠팡 위젯이 그대로 보인다(이미지·제목·가격·버튼 전부 쿠팡 렌더).
    if (p.isWidget && heavyOk) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(kFleamarketPhotoRadius),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 0.5, color: SDSColor.gray100),
            borderRadius: BorderRadius.circular(kFleamarketPhotoRadius),
          ),
          child: coupangWidgetView(embedUrl: p.embedUrl),
        ),
      );
    }

    final Widget image;
    if (p.imageUrl.isEmpty) {
      image = Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover);
    } else if (shopIsBannerImage(p.imageUrl) && heavyOk) {
      // 어드민에서 붙여넣은 블로그용 태그의 배너(240×480) — DOM 안에서 상품 사진 구간만
      // 잘라 보인다(Flutter 쪽 클립은 iOS Safari의 DOM 이미지에 안 먹는다).
      image = shopBannerImageView(url: p.imageUrl, radius: kFleamarketPhotoRadius);
    } else {
      image = WebNetworkImage(
        // 212px 썸네일은 PC 셀에서 흐릿해 큰 사이즈로 요청. 없으면 원본으로.
        // 쿠팡 CDN은 CORS가 없어 프록시를 거쳐야 플랫폼뷰 폭주(iOS 크래시)를 막는다.
        url: shopProxiedImageUrl(shopImageUrlAt(p.imageUrl, kShopImageSize)),
        fit: BoxFit.cover,
        // 로딩 동안 정사각 스켈레톤 쉬머(셀이 1:1이라 비율 1).
        placeholderAspectRatio: 1,
        fallback: WebNetworkImage(
          url: shopProxiedImageUrl(p.imageUrl),
          fit: BoxFit.cover,
          placeholderAspectRatio: 1,
          fallback: Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
        ),
      );
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap ?? _open,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
              // 중고거래 카드와 같은 hover(라운드째 2% 축소).
              child: AnimatedScale(
                scale: _hovered ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(kFleamarketPhotoRadius),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(width: 0.5, color: SDSColor.gray100),
                      borderRadius: BorderRadius.circular(kFleamarketPhotoRadius),
                    ),
                    // 썸네일 좌상단에 카테고리 배지를 얹는다(가격 위가 아니라 이미지 위).
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        image,
                        Positioned(top: 8, left: 8, child: _categoryBadge(p.category)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // 제목: 항상 1줄 높이를 차지(말줄임) → 아래 가격 줄이 모든 카드에서 맞는다.
            SizedBox(
              height: 13 * _kLineHeight,
              child: Text(
                p.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 13,
                  height: _kLineHeight,
                  color: SDSColor.gray900,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 가격 줄: 가격이 없어도 같은 높이를 남긴다. 예약·이용권형은 쿠팡이 단일
            // 가격을 안 주므로 "쿠팡에서 확인"으로 안내(누르면 쿠팡으로 이동).
            SizedBox(
              height: 16 * _kLineHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: p.salesPrice != null
                    ? Text(
                        '${_shopPriceFormat.format(p.salesPrice)}원',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 16,
                          height: _kLineHeight,
                          color: SDSColor.gray900,
                        ),
                      )
                    : Text(
                        '쿠팡에서 확인',
                        style: SDSTextStyle.regular.copyWith(
                          fontSize: 13,
                          height: _kLineHeight,
                          color: SDSColor.gray400,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

