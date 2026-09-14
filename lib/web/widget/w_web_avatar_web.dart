import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
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
///
/// [userId]를 주면 **어느 화면이든 프로필 사진을 누르면 프로필 미리보기 팝업**이
/// 뜬다(랭킹에서 프로필을 눌렀을 때와 같은 팝업). 이미 행 전체가 팝업을 여는
/// 목록(친구 목록·크루 멤버 등)에서는 넘기지 않아도 된다.
class WebAvatar extends StatelessWidget {
  final String? url;
  final double size;

  /// 리조트 실시간 접속 표시처럼 테두리를 줄 때 사용.
  final Color? borderColor;
  final double borderWidth;

  /// 누르면 이 유저의 프로필 미리보기 팝업을 띄운다. null이면 탭하지 않는다.
  final int? userId;

  /// 팝업 대신 다른 동작을 붙일 때(프로필 화면의 사진 확대 등). [userId]보다 우선.
  final VoidCallback? onTap;

  const WebAvatar({
    super.key,
    required this.url,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 2,
    this.userId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = WebNetworkImage(
      url: url,
      width: size,
      height: size,
      isCircle: true,
      // 모바일 앱과 동일한 기본 프로필 이미지로 폴백한다.
      fallback: ClipOval(
        child: Image.asset(
          'assets/imgs/profile/img_profile_default_circle.png',
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );

    final Widget bordered = borderColor == null
        ? avatar
        : Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: borderColor!, width: borderWidth),
            ),
            child: Padding(padding: EdgeInsets.all(borderWidth), child: avatar),
          );

    return WebProfileTap(userId: userId, avatarUrl: url, onTap: onTap, child: bordered);
  }
}
