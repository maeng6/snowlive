import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/web/view/friend/w_friend_profile_modal_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 프로필 사진 탭 → 프로필 미리보기 팝업.
///
/// 랭킹에서 프로필을 눌렀을 때 뜨는 것과 **같은 팝업**([showFriendProfileModal])이고,
/// 웹의 모든 프로필 사진(댓글·피드·목록·판매자·방명록 등)이 이 한 곳을 거친다.
///
/// [name]/[avatarUrl]은 넘기면 상세 응답을 기다리는 동안에도 누구인지 보인다.
Future<void> openWebProfilePopup(
  BuildContext context, {
  required int userId,
  String? name,
  String? avatarUrl,
}) {
  _ensurePopupViewModels();
  return showFriendProfileModal(
    context,
    friendUserId: userId,
    initialName: name,
    initialAvatarUrl: avatarUrl,
  );
}

/// 팝업이 쓰는 뷰모델을 보장한다.
///
/// 프로필 사진은 이제 **모든 화면**에 있어서(중고거래 판매자·댓글, 라이브톡 피드 등)
/// 라우트 바인딩마다 등록해 두는 방식으로는 한 곳만 빠져도 `"FriendViewModelWeb" not
/// found`로 화면이 죽는다(실제로 중고거래 상세에서 터졌다) → 여기서 한 번에 챙긴다.
/// lazyPut이라 팝업을 열지 않으면 아무것도 만들어지지 않는다.
void _ensurePopupViewModels() {
  if (!Get.isRegistered<FriendListViewModel>() && !Get.isPrepared<FriendListViewModel>()) {
    Get.lazyPut(() => FriendListViewModel(), fenix: true);
  }
  if (!Get.isRegistered<FriendViewModelWeb>() && !Get.isPrepared<FriendViewModelWeb>()) {
    Get.lazyPut(() => FriendViewModelWeb(), fenix: true);
  }
}

/// 이미 그려진 프로필 사진 위젯([child])에 탭 동작만 얹는다.
///
/// 아바타 모양이 화면마다 조금씩 달라서(폴백 색·크기·테두리) 모양은 그대로 두고
/// 탭만 붙이는 쪽으로 통일했다. [WebAvatar]도 내부에서 이걸 쓴다.
class WebProfileTap extends StatelessWidget {
  final Widget child;

  /// 누르면 이 유저의 프로필 팝업이 뜬다. null이면 탭하지 않는다.
  final int? userId;
  final String? name;
  final String? avatarUrl;

  /// 팝업 대신 다른 동작을 붙일 때 쓴다(프로필 화면에서 사진 확대). [userId]보다 우선.
  final VoidCallback? onTap;

  const WebProfileTap({
    super.key,
    required this.child,
    this.userId,
    this.name,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final id = userId;
    final effectiveOnTap = onTap ??
        (id == null
            ? null
            : () => openWebProfilePopup(context, userId: id, name: name, avatarUrl: avatarUrl));
    if (effectiveOnTap == null) return child;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        // 기본값(deferToChild)이면 자식이 히트테스트를 먹지 않는 경우(빈 SizedBox,
        // 투명 영역) 탭이 그냥 지나간다 → 아바타 박스 전체를 탭 대상으로 잡는다.
        behavior: HitTestBehavior.opaque,
        onTap: effectiveOnTap,
        child: child,
      ),
    );
  }
}
