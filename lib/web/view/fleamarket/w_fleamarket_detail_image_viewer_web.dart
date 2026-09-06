import 'package:com.snowlive/core/model/m_fleamarket.dart';
import 'package:com.snowlive/core/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 상세화면 이미지 클릭 시 뜨는 풀스크린 뷰어(라이트박스).
///
/// 실제 뷰어는 커뮤니티와 공용인 [showWebImageViewer]다 — 썸네일 스트립, 확대/축소/맞춤,
/// `1/N` 인디케이터, 키보드 ←/→/Esc가 모두 붙어 있고 브레이크포인트별로 구성이 갈린다.
/// 여기서는 중고거래 전용 사정 두 가지만 얹는다:
///  - `Photo` 목록 → URL 목록 변환
///  - 인덱스 변경을 뒤에 있는 캐러셀 점 인디케이터와 동기화
Future<void> showFleamarketImageViewerWeb({
  required BuildContext context,
  required List<Photo> photos,
  required int initialIndex,
  String title = '',
}) {
  final urls = [
    for (final p in photos)
      if (p.urlFleaPhoto?.isNotEmpty ?? false) p.urlFleaPhoto!,
  ];
  if (urls.isEmpty) return Future.value();

  return showWebImageViewer(
    context: context,
    title: title,
    imageUrls: urls,
    initialIndex: initialIndex,
    onIndexChanged: (index) {
      // 커뮤니티 라우트에서도 이 뷰어 코드가 로드되므로 등록 여부를 확인한다.
      if (Get.isRegistered<FleamarketDetailViewModel>()) {
        Get.find<FleamarketDetailViewModel>().updateCurrentIndex(index);
      }
    },
  );
}
