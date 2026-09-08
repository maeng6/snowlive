import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_page_scaffold_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_row_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String _kBlockEmptyIcon = 'assets/imgs/icons/icon_no_member.png';

/// 차단한 친구 관리. 목업에는 이 화면이 없어서 앱(`v_friendBlockList.dart`)의 구성을
/// 친구 목록과 같은 행 모양으로 옮겼다 — 설정에 막힌 길을 남기지 않으려고 함께 만든다.
class FriendBlockListViewWeb extends StatefulWidget {
  const FriendBlockListViewWeb({super.key});

  @override
  State<FriendBlockListViewWeb> createState() => _FriendBlockListViewWebState();
}

class _FriendBlockListViewWebState extends State<FriendBlockListViewWeb> {
  final FriendViewModelWeb _vm = Get.find<FriendViewModelWeb>();
  final FriendListViewModel _listVm = Get.find<FriendListViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.refreshBlockList());
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
      if (status != WebAuthStatus.authenticated) return;
      _vm.refreshBlockList();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }

  Future<void> _unblock(int blockUserId, String name) async {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '$name님의 차단을 해제하시겠어요?',
      confirmLabel: '해제하기',
    );
    if (!ok || !mounted) return;

    final done = await _vm.unblockUser(blockUserId);
    if (!mounted) return;
    if (done) await _vm.refreshBlockList();
    showWebToast(
      context,
      // ⚠️ 이 API는 body를 실은 DELETE라 서버 CORS가 막으면 여기로 떨어진다.
      done ? '차단을 해제했습니다.' : '잠시 후 다시 시도해 주세요.',
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FriendPageScaffoldWeb(
      title: '차단한 친구 관리',
      fallbackRoute: WebRoutes.friendSettings,
      child: _authVm.status == WebAuthStatus.unauthenticated
          ? WebEmptyState(
              message: '로그인이 필요해요.',
              actionLabel: '로그인하기',
              onAction: () => Get.toNamed(WebRoutes.login),
            )
          : Obx(() {
              final blocked = _listVm.blockUserList;
              // ⚠️ RxList를 변수에 담는 것만으로는 Obx 구독이 걸리지 않는다 →
              // 분기 전에 length를 읽어 확실히 등록시킨다.
              final count = blocked.length;
              if (count == 0) {
                return WebEmptyState(
                  message: '차단한 친구가 없습니다.',
                  iconAsset: _kBlockEmptyIcon,
                  iconWidth: 96,
                  iconFit: BoxFit.contain,
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final item in blocked)
                    FriendRowWeb(
                      avatarUrl: item.blockUserInfo.profileImageUrlUser,
                      userId: item.blockUserInfo.userId,
                      name: item.blockUserInfo.displayName,
                      stateMsg: item.blockUserInfo.stateMsg,
                      trailing: FriendRowActionButton(
                        label: '차단 해제',
                        onTap: () => _unblock(
                          item.blockUserInfo.userId,
                          item.blockUserInfo.displayName,
                        ),
                      ),
                    ),
                ],
              );
            }),
    );
  }
}
