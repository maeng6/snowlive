import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:com.snowlive/web/view/shop/shop_sections_web.dart';
import 'package:flutter/material.dart';

/// 플랫폼뷰(factory)는 viewType마다 한 번만 등록할 수 있어, 이미 등록한 건 건너뛴다.
final Set<String> _registered = {};

/// 배너 테두리 1px이 셀 좌우에 선으로 비치지 않게 살짝 키운다.
const double _zoom = 1.04;

/// 쿠팡 배너(240×480)를 셀 크기의 DOM 상자에 넣고, 상자 안에서 **상품 사진 구간**만 보이게
/// CSS로 자른다. 상자(플랫폼뷰)는 셀과 같은 크기라 Flutter 쪽 클립이 없어도 넘치지 않는다.
///
/// 배너를 셀 폭×[_zoom]으로, 세로는 그 2배(1:2)로 그리고, 사진 구간의 가운데
/// ([kShopBannerPhotoTop] + 높이/2)가 셀 가운데에 오게 위로 민다.
/// `pointer-events:none`이라 탭은 아래 Flutter 카드(GestureDetector)로 간다.
Widget shopBannerImageView({required String url, required double radius}) {
  final viewType = 'shop-banner-${url.hashCode}';
  if (_registered.add(viewType)) {
    const widthPct = _zoom * 100;
    const heightPct = widthPct * 2;
    const photoCenterPct =
        (kShopBannerPhotoTop + kShopBannerPhotoHeight / 2) * heightPct;
    const topPct = 50 - photoCenterPct;
    const leftPct = (100 - widthPct) / 2;
    ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
      final img = html.ImageElement(src: url)
        ..alt = ''
        ..draggable = false
        ..style.cssText = 'position:absolute;left:$leftPct%;top:$topPct%;'
            'width:$widthPct%;height:$heightPct%;max-width:none;display:block;'
            'pointer-events:none;user-select:none;-webkit-user-select:none;';
      return html.DivElement()
        ..style.cssText = 'position:relative;width:100%;height:100%;overflow:hidden;'
            'border-radius:${radius}px;background:#fff;pointer-events:none;'
        ..append(img);
    });
  }
  // ⚠️ IgnorePointer가 없으면 카드 탭이 안 먹는다(실측). HtmlElementView의 렌더박스는
  // 히트테스트에 자기 제스처 인식기를 올리는데, 트리에서 더 깊어 제스처 아레나에 먼저
  // 들어가고, 손을 떼는 순간 아레나가 "먼저 들어온 쪽"에게 승리를 줘 바깥 카드의
  // GestureDetector(탭 → 쿠팡 새 탭)가 진다. 이미지는 탭을 받을 일이 없으니 빼 버린다.
  return IgnorePointer(child: HtmlElementView(viewType: viewType));
}
