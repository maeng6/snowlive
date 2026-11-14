import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_affiliate_product.dart';
import 'package:com.snowlive/web/view/fleamarket/w_fleamarket_card_web.dart'
    show kFleamarketDefaultImage, kFleamarketPhotoRadius;
import 'package:com.snowlive/web/view/shop/shop_sections_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// 카드 이미지(정사각) 아래 텍스트 블록(제목 2줄 + 보조 줄 + 링크 줄)의 고정 높이.
/// 그리드와 스켈레톤이 같은 값을 써야 로딩 → 데이터 전환 때 레이아웃이 안 튄다.
/// 텍스트 줄높이를 전부 1.5로 **고정**해서 계산한다(글꼴 기본 줄높이에 맡기면 0.5px씩
/// 넘쳐 줄무늬가 뜬다): 간격 10 + 제목 2줄 39 + 2 + 보조 18 + 6 + 링크 18 = 93 → 94.
/// 가격을 켜면([kShopShowsPrice]) 2 + 가격 24 = 26 더.
double shopCardTextBlockHeight() => kShopShowsPrice ? 120 : 94;

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
    final uri = Uri.tryParse(p.url);
    if (uri == null) return;
    // 웹에서 externalApplication은 새 탭이다 — 우리 화면은 그대로 남는다.
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final image = p.imageUrl.isEmpty
        ? Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover)
        : WebNetworkImage(
            // 212px 썸네일은 PC 셀에서 흐릿해 큰 사이즈로 요청. 없으면 원본으로.
            url: shopImageUrlAt(p.imageUrl, kShopImageSize),
            fit: BoxFit.cover,
            fallback: WebNetworkImage(
              url: p.imageUrl,
              fit: BoxFit.cover,
              fallback: Image.asset(kFleamarketDefaultImage, fit: BoxFit.cover),
            ),
          );

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
                    child: image,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              p.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(
                fontSize: 13,
                height: _kLineHeight,
                color: SDSColor.gray900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              shopCardMeta(p),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(
                fontSize: 12,
                height: _kLineHeight,
                color: SDSColor.gray500,
              ),
            ),
            if (kShopShowsPrice && p.salesPrice != null) ...[
              const SizedBox(height: 2),
              Text(
                '${_shopPriceFormat.format(p.salesPrice)}원',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  height: _kLineHeight,
                  color: SDSColor.gray900,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '쿠팡에서 보기',
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 12,
                    height: _kLineHeight,
                    color: _hovered ? SDSColor.snowliveBlue : SDSColor.gray700,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.open_in_new_rounded,
                  size: 12,
                  color: _hovered ? SDSColor.snowliveBlue : SDSColor.gray700,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
