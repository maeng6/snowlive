import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_page_scaffold_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/viewmodel/paid/vm_paidVisibility_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_settings_row_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업(218:68126) 행 간격 16 = 글줄 위아래 8.
const double _kRowVerticalPadding = 8;

/// 친구 설정 화면.
///
/// GNB 사이드바의 `설정`(앱 전역 설정 자리)과는 다른 화면이다 — 친구 목록의
/// 톱니바퀴로만 들어온다. 목업 제목도 그냥 `설정`이다.
class FriendSettingsViewWeb extends StatefulWidget {
  const FriendSettingsViewWeb({super.key});

  @override
  State<FriendSettingsViewWeb> createState() => _FriendSettingsViewWebState();
}

class _FriendSettingsViewWebState extends State<FriendSettingsViewWeb> {
  final FriendViewModelWeb _vm = Get.find<FriendViewModelWeb>();
  final FriendListViewModel _listVm = Get.find<FriendListViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    // 배지(받은 요청 개수)를 채우려면 요청 목록이 필요하다. 요청 관리 화면에서
    // 수락/거절하고 돌아왔을 때도 최신값이어야 하므로 진입할 때마다 다시 받는다.
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.refreshRequests());
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
      if (status != WebAuthStatus.authenticated) return;
      _vm.refreshRequests();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FriendPageScaffoldWeb(
      title: '설정',
      child: _authVm.status == WebAuthStatus.unauthenticated
          ? WebEmptyState(
              message: '로그인이 필요해요.',
              actionLabel: '로그인하기',
              onAction: () => Get.toNamed(WebRoutes.login),
            )
          // 목업(218:68126) — 구분선 없이 글줄 27 + 상하 8(피치 43)로만 나눈다.
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 유료기능 출시 전에는 테스트 대상에게만 노출.
                Obx(() => PaidVisibilityControllerWeb.isVisible
                    ? WebSettingsRow(
                        label: '실시간 위치 공유',
                        verticalPadding: _kRowVerticalPadding,
                        onTap: () => Get.toNamed(WebRoutes.friendLocationShare),
                      )
                    : const SizedBox.shrink()),
                Obx(() => WebSettingsRow(
                      label: '친구 요청 관리',
                      badgeCount: _listVm.friendsRequestList.length,
                      verticalPadding: _kRowVerticalPadding,
                      onTap: () async {
                        await Get.toNamed(WebRoutes.friendRequests);
                        // 돌아왔을 때 배지가 옛 개수로 남지 않게 한다.
                        if (!mounted) return;
                        await _vm.refreshRequests();
                      },
                    )),
                WebSettingsRow(
                  label: '차단한 친구 관리',
                  verticalPadding: _kRowVerticalPadding,
                  onTap: () => Get.toNamed(WebRoutes.friendBlockList),
                ),
              ],
            ),
    );
  }
}
