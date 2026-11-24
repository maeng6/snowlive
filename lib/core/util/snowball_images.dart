import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 번들 에셋 파일명 → 어드민이 관리하는 이미지 영역 키(카탈로그).
/// 여기 없는 파일은 항상 번들 에셋을 쓴다(오버라이드 대상 아님).
const Map<String, String> kSnowAssetToKey = {
  'img_snowballshop_store.png': 'hero_bg',
  'icon_snowballshop_store_title.png': 'hero_title',
  'icon_snowballshop_bubble.png': 'gold_bubble',
  'icon_snowballshop_store_brand.png': 'brand_banner',
  'icon_snowballshop_arrow_b.png': 'brand_arrow',
  'icon_snowballshop_store_box_1.png': 'record_box_bg',
  'icon_snowballshop_store_banner.png': 'use_store_banner',
  'img_snowballshop_store_bottom_image2.png': 'story_bg',
  'img_snowballshop_store_premium.png': 'store_premium',
  'img_snowballshop_store_public.png': 'store_public',
  'icon_snowballshop_whiteball.png': 'white_ball',
  'icon_snowballshop_goldball.png': 'gold_ball',
};

/// 눈송이 상점 이미지 오버라이드(어드민이 바꾼 것만)를 구독하는 전역 서비스.
///
/// Firestore `snowball_market/images`에는 **변경된 영역만** 담긴다. 기본 상태에선
/// 맵이 비어 있어 모든 이미지가 번들 에셋으로 렌더된다(네트워크 로딩 0, 오프라인 OK).
/// 어드민이 특정 영역을 교체한 경우에만 그 이미지가 네트워크(Storage)에서 로드된다.
class SnowballImages extends GetxService {
  final RxMap<String, String> overrides = <String, String>{}.obs;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _sub = FirebaseFirestore.instance
        .collection('snowball_market')
        .doc('images')
        .snapshots()
        .listen((snap) {
      final data = snap.data() ?? const <String, dynamic>{};
      overrides.assignAll(data.map((k, v) => MapEntry(k, '$v')));
    });
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  /// 에셋 경로에 해당하는 오버라이드 URL. 없으면 null(→ 번들 에셋 사용).
  String? urlForAsset(String assetPath) {
    final file = assetPath.split('/').last;
    final key = kSnowAssetToKey[file];
    if (key == null) return null;
    final v = overrides[key];
    return (v != null && v.isNotEmpty) ? v : null;
  }
}

SnowballImages? _svc() {
  try {
    return Get.find<SnowballImages>();
  } catch (_) {
    return null;
  }
}

/// 에셋 경로 → 오버라이드가 있으면 (디스크 캐시) 네트워크 이미지, 없으면 AssetImage.
/// DecorationImage 등 ImageProvider가 필요한 곳에서 `AssetImage(x)` 대체로 쓴다.
/// 오버라이드 이미지는 첫 로드 때 기기에 저장되고 이후엔 로컬에서 읽는다.
/// URL이 곧 버전이라(어드민이 바꾸면 새 URL) 바뀐 이미지만 자동으로 다시 받는다.
ImageProvider snowImageProvider(String assetPath, {double scale = 1.0}) {
  final url = _svc()?.urlForAsset(assetPath);
  if (url != null) return ExtendedNetworkImageProvider(url, cache: true, scale: scale);
  return AssetImage(assetPath);
}

/// `Image.asset(x, ...)` 대체. 오버라이드가 있으면 디스크 캐시 네트워크 이미지(첫 로드 중/
/// 실패 시 번들 에셋 표시), 없으면 번들 에셋 그대로. 기본 상태에선 Image.asset과 동일.
Widget snowImage(String assetPath,
    {double? width, double? height, BoxFit? fit, double? scale}) {
  final url = _svc()?.urlForAsset(assetPath);
  if (url != null) {
    return ExtendedImage.network(
      url,
      cache: true, // 기기 디스크에 저장 → 다음부터 로컬 로딩(오프라인 OK)
      width: width,
      height: height,
      fit: fit,
      loadStateChanged: (state) {
        // 첫 다운로드 중/실패 시 번들 에셋을 보여줘 빈 화면을 피한다.
        if (state.extendedImageLoadState == LoadState.completed) return null;
        return Image.asset(assetPath, width: width, height: height, fit: fit);
      },
    );
  }
  return Image.asset(assetPath,
      width: width, height: height, fit: fit, scale: scale ?? 1.0);
}
