import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

/// 원형 프로필 이미지.
///
/// `ClipOval` + [WebNetworkImage] + 회색 원 폴백 조합이 웹 곳곳(라이브톡 피드·댓글,
/// 중고거래 댓글·판매자, 랭킹, 커뮤니티 댓글 등 10곳 가까이)에 복붙돼 있었다.
/// 친구 화면은 아바타가 목록 전체를 채우므로 여기서 하나로 묶는다.
///
/// 폴백은 웹 관례를 따른다 — `Icons.person` + `gray100` 원.
/// (모바일 앱은 `img_profile_default_circle.png`를 쓰지만 웹은 이 방식으로 통일돼 있다.)
class WebAvatar extends StatelessWidget {
  final String? url;
  final double size;

  /// 리조트 실시간 접속 표시처럼 테두리를 줄 때 사용.
  final Color? borderColor;
  final double borderWidth;

  const WebAvatar({
    super.key,
    required this.url,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = WebNetworkImage(
      url: url,
      width: size,
      height: size,
      isCircle: true,
      fallback: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: SDSColor.gray100),
        // 지름에 비례해 아이콘을 키운다(원본들이 28→16, 88→44로 대략 절반이었다).
        child: Icon(Icons.person, size: size * 0.5, color: SDSColor.gray400),
      ),
    );

    if (borderColor == null) return avatar;
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: borderColor!, width: borderWidth),
      ),
      child: Padding(padding: EdgeInsets.all(borderWidth), child: avatar),
    );
  }
}
