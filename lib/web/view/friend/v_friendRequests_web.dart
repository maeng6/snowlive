import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_requestFriendList.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_page_scaffold_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_row_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const String _kRequestEmptyIcon = 'assets/imgs/icons/icon_no_member.png';

enum _RequestTab { sent, received }

/// 친구 요청 관리. `보낸 요청 N` | `받은 요청 N` 두 탭.
///
/// 목업은 받은 요청에 `친구 추가`(수락)만 있는데 그것만으로는 원치 않는 요청을 치울
/// 방법이 없어 `거절`도 함께 둔다(서버는 삭제와 같은 `delete-friend/`를 쓴다).
class FriendRequestsViewWeb extends StatefulWidget {
  const FriendRequestsViewWeb({super.key});

  @override
  State<FriendRequestsViewWeb> createState() => _FriendRequestsViewWebState();
}

class _FriendRequestsViewWebState extends State<FriendRequestsViewWeb> {
  final FriendViewModelWeb _vm = Get.find<FriendViewModelWeb>();
  final FriendListViewModel _listVm = Get.find<FriendListViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  /// 목업 기본 탭은 `받은 요청`(활성 표시가 그쪽에 있다).
  _RequestTab _tab = _RequestTab.received;

  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
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

  void _toast(String message) {
    showWebToast(
      context,
      message,
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  /// 수락 확인(피그마 218:68503) — 웹 공용 박스 팝업.
  /// 파란 채움 `친구 추가하기` 아래에 텍스트 `다음에 하기`가 오는 구성이다.
  Future<bool> _confirmAccept(String name) {
    return showWebBoxPopup(
      context: context,
      title: '$name님을\n친구로 추가하시겠어요?',
      primaryLabel: '친구 추가하기',
      secondaryLabel: '다음에 하기',
    );
  }

  Future<void> _accept(RequestFriendList request) async {
    final name = request.friendUserInfo.displayName;

    if (!await _confirmAccept(name) || !mounted) return;
    final done = await _vm.acceptRequest(request.friendId);
    if (!mounted) return;
    if (done) await _vm.refreshAll();
    _toast(done ? '친구가 추가되었습니다.' : '잠시 후 다시 시도해 주세요.');
  }

  Future<void> _reject(RequestFriendList request) async {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '친구 요청을 거절하시겠어요?',
      confirmLabel: '거절하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final done = await _vm.rejectRequest(request.friendId);
    if (!mounted) return;
    if (done) await _vm.refreshRequests();
    _toast(done ? '요청을 거절했습니다.' : '잠시 후 다시 시도해 주세요.');
  }

  Future<void> _cancel(RequestFriendList request) async {
    final ok = await showWebConfirmDialog(
      context: context,
      title: '보낸 요청을 취소하시겠어요?',
      confirmLabel: '취소하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final done = await _vm.cancelRequest(request.friendId);
    if (!mounted) return;
    if (done) await _vm.refreshRequests();
    _toast(done ? '요청을 취소했습니다.' : '잠시 후 다시 시도해 주세요.');
  }

  @override
  Widget build(BuildContext context) {
    return FriendPageScaffoldWeb(
      title: '친구 요청 관리',
      fallbackRoute: WebRoutes.friendSettings,
      child: _authVm.status == WebAuthStatus.unauthenticated
          ? WebEmptyState(
              message: '로그인이 필요해요.',
              actionLabel: '로그인하기',
              onAction: () => Get.toNamed(WebRoutes.login),
            )
          : Obx(() {
              final sent = _listVm.myRequestList;
              final received = _listVm.friendsRequestList;
              // ⚠️ 구독은 이 빌더 안에서 값을 읽을 때만 걸린다. 탭 라벨(`labelOf`)은
              // WebTextTabs가 자기 build에서 부르므로 **여기 밖**이고, 목록은 선택된
              // 탭 하나만 읽는다 → 두 개수를 지금 읽어 양쪽 갱신을 다 받게 한다.
              final sentCount = sent.length;
              final receivedCount = received.length;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 목업은 탭 라벨 안에 개수를 넣는다(`받은 요청 12`).
                  WebTextTabs<_RequestTab>(
                    values: _RequestTab.values,
                    selected: _tab,
                    labelOf: (t) => t == _RequestTab.sent
                        ? '보낸 요청 $sentCount'
                        : '받은 요청 $receivedCount',
                    onSelected: (t) {
                      if (t == _tab) return;
                      setState(() => _tab = t);
                    },
                    // 목업(218:68213) — bold 16, 비활성도 bold gray200,
                    // 구분자는 1px 세로선, 좌우 간격 10.
                    fontSize: 16,
                    inactiveBold: true,
                    inactiveColor: SDSColor.gray200,
                    lineDivider: true,
                    dividerGap: 10,
                  ),
                  // 탭 줄 ↔ 목록 20(목업 218:68213 하단 여백).
                  const SizedBox(height: 20),
                  if (_tab == _RequestTab.received)
                    _buildList(
                      received,
                      emptyMessage: '받은 친구 요청이 없습니다.',
                      trailingOf: (request) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FriendRowActionButton(
                            label: '친구 추가',
                            onTap: () => _accept(request),
                          ),
                          const SizedBox(width: 6),
                          FriendRowActionButton(
                            label: '거절',
                            isDestructive: true,
                            onTap: () => _reject(request),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildList(
                      sent,
                      emptyMessage: '보낸 친구 요청이 없습니다.',
                      trailingOf: (request) => FriendRowActionButton(
                        label: '요청 취소',
                        onTap: () => _cancel(request),
                      ),
                    ),
                ],
              );
            }),
    );
  }

  Widget _buildList(
    List<RequestFriendList> items, {
    required String emptyMessage,
    required Widget Function(RequestFriendList request) trailingOf,
  }) {
    if (items.isEmpty) {
      return WebEmptyState(
        message: emptyMessage,
        iconAsset: _kRequestEmptyIcon,
        iconWidth: 96,
        iconFit: BoxFit.contain,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final request in items)
          FriendRowWeb(
            // 보낸 요청이든 받은 요청이든 화면에 보여야 하는 건 **상대방**이다.
            avatarUrl: request.friendUserInfo.profileImageUrlUser,
            userId: request.friendUserInfo.userId,
            name: request.friendUserInfo.displayName,
            stateMsg: request.friendUserInfo.stateMsg,
            trailing: trailingOf(request),
          ),
      ],
    );
  }
}
