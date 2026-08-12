import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_page_scaffold_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_profile_modal_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_row_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_search_field_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 친구 목록 빈 상태 아이콘. 정사각이 아니라서 `contain`으로 넣어야 찌그러지지 않는다.
const String _kFriendEmptyIcon = 'assets/imgs/icons/icon_no_member.png';

/// 친구 목록 행의 `···` 메뉴 항목.
enum _FriendMoreAction {
  block('친구 차단하기'),
  remove('친구 삭제하기');

  const _FriendMoreAction(this.label);
  final String label;
}

/// 친구 목록 화면.
///
/// 검색창은 **닉네임 전체일치 유저 조회**다(서버가 부분 일치를 지원하지 않는다).
/// 엔터를 누르면 찾은 유저의 프로필 팝업을 띄우고, 없으면 안내 다이얼로그를 띄운다.
/// 친구 목록 자체는 그대로 남는다(목업 장면과 동일).
class FriendHomeViewWeb extends StatefulWidget {
  const FriendHomeViewWeb({super.key});

  @override
  State<FriendHomeViewWeb> createState() => _FriendHomeViewWebState();
}

class _FriendHomeViewWebState extends State<FriendHomeViewWeb> {
  final FriendViewModelWeb _vm = Get.find<FriendViewModelWeb>();
  final FriendListViewModel _listVm = Get.find<FriendListViewModel>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();

  final TextEditingController _searchController = TextEditingController();

  Worker? _authWorker;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _vm.refreshAll());
    // 자동로그인이 늦게 확정되면 최초 조회가 user_id 없이 조용히 실패해 빈 화면이 남는다.
    // 로그인 후 돌아온 경우에도 걸리므로 재조회와 함께 setState로 본문을 바꿔준다.
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
      if (status != WebAuthStatus.authenticated) return;
      _vm.refreshAll();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    // 해제하지 않으면 라우트를 왕복할 때마다 리스너가 쌓여 재조회가 여러 번 나간다.
    _authWorker?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isGuest => _authVm.status == WebAuthStatus.unauthenticated;

  Future<void> _onSearch(String raw) async {
    final keyword = raw.trim();
    if (keyword.isEmpty || _isSearching) return;

    setState(() => _isSearching = true);
    // 이전 결과가 남아 있으면 "없음" 판정이 어긋난다.
    await _listVm.resetSearchFriend();
    await _listVm.searchUser(keyword);
    if (!mounted) return;
    setState(() => _isSearching = false);

    // 서버는 못 찾아도 200을 주는 경우가 있어서 statusCode가 아니라 userId로 판정한다.
    final found = _listVm.searchFriend.userId;
    if (found == null) {
      await _showNotFoundDialog();
      return;
    }

    final sent = await showFriendProfileModal(
      context,
      friendUserId: found,
      initialName: _listVm.searchFriend.displayName,
      initialAvatarUrl: _listVm.searchFriend.profileImageUrlUser,
    );
    if (sent == true) await _vm.refreshAll();
  }

  Future<void> _showNotFoundDialog() {
    return showWebOverlayModal<void>(
      context: context,
      builder: (_, close) => Material(
        color: SDSColor.snowliveWhite,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '검색하신 친구가 없습니다.',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                ),
                const SizedBox(height: SDSSpacing.sm),
                Text(
                  '닉네임 전체를 정확히 입력해 주세요.',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                ),
                const SizedBox(height: SDSSpacing.md),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: close,
                    child: Text(
                      '확인',
                      style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveBlue),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onMoreAction(FriendListModel friend, _FriendMoreAction action) async {
    final info = friend.friendInfo;
    final name = info.displayName;

    if (action == _FriendMoreAction.remove) {
      final ok = await showWebConfirmDialog(
        context: context,
        title: '$name님을 친구 목록에서\n삭제하시겠어요?',
        confirmLabel: '삭제하기',
        isDestructive: true,
      );
      if (!ok || !mounted) return;
      final done = await _vm.removeFriend(friend.friendId);
      if (!mounted) return;
      if (done) await _vm.refreshAll();
      _toast(done ? '친구를 삭제했습니다.' : '잠시 후 다시 시도해 주세요.');
      return;
    }

    final ok = await showWebConfirmDialog(
      context: context,
      title: '$name님을 차단하시겠어요?',
      message: '차단하면 서로의 글이 보이지 않아요.\n차단 해제는 [설정 - 차단한 친구 관리]에서 할 수 있어요.',
      confirmLabel: '차단하기',
      isDestructive: true,
    );
    if (!ok || !mounted) return;
    final done = await _vm.blockUser(info.userId);
    if (!mounted) return;
    if (done) await _vm.refreshAll();
    _toast(done ? '차단했습니다.' : '잠시 후 다시 시도해 주세요.');
  }

  void _toast(String message) {
    showWebToast(
      context,
      message,
      // 목업: 데스크탑·태블릿은 상단, 모바일은 하단.
      alignment: context.screenType == WebScreenType.mobile
          ? Alignment.bottomCenter
          : Alignment.topCenter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kFriendContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._buildHeader(isDesktop),
                const SizedBox(height: SDSSpacing.md),
                if (_isGuest) _buildGuestBody() else Obx(_buildList),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 데스크탑은 `친구 [검색창] ⚙` 한 줄, 좁은 폭은 제목·톱니바퀴 줄 + 검색창 줄(목업).
  List<Widget> _buildHeader(bool isDesktop) {
    final title = Text(
      '친구',
      style: SDSTextStyle.extraBold.copyWith(
        fontSize: isDesktop ? 28 : 20,
        color: SDSColor.gray900,
      ),
    );
    final searchField = WebSearchField(
      controller: _searchController,
      hint: '친구 검색',
      onSubmitted: _onSearch,
    );
    final settingsButton = IconButton(
      onPressed: () => Get.toNamed(WebRoutes.friendSettings),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      icon: Image.asset('assets/imgs/icons/icon_settings.png', width: 22, height: 22),
    );

    if (isDesktop) {
      return [
        Row(
          children: [
            title,
            const SizedBox(width: SDSSpacing.lg),
            Expanded(child: searchField),
            const SizedBox(width: SDSSpacing.md),
            settingsButton,
          ],
        ),
      ];
    }
    return [
      Row(children: [title, const Spacer(), settingsButton]),
      const SizedBox(height: SDSSpacing.md),
      searchField,
    ];
  }

  /// 친구 데이터는 100% 로그인 전용이다(코어 뷰모델이 user_id 없으면 조용히 return).
  Widget _buildGuestBody() {
    return WebEmptyState(
      message: '로그인하고 친구를 추가해보세요.',
      iconAsset: _kFriendEmptyIcon,
      iconWidth: 96,
      iconFit: BoxFit.contain,
      actionLabel: '로그인하기',
      onAction: () => Get.toNamed(WebRoutes.login),
    );
  }

  Widget _buildList() {
    final friends = _listVm.friendList;
    // ⚠️ Obx 구독은 여기서 걸린다. RxList를 **변수에 담기만 하면 등록되지 않으므로**
    // 조건 분기 전에 값을 읽는 멤버(length)를 한 번 건드린다. 관찰 대상을 하나도
    // 읽지 않은 채 빌더가 끝나면 GetX가 "improper use of a GetX"로 화면을 죽인다.
    final count = friends.length;

    if (count == 0) {
      return WebEmptyState(
        message: '등록된 친구가 없습니다.',
        iconAsset: _kFriendEmptyIcon,
        iconWidth: 96,
        iconFit: BoxFit.contain,
        actionLabel: '친구 추가하기',
        // 검색창으로 유저를 찾아 추가하는 흐름이라 검색창에 포커스를 준다.
        onAction: () => FocusScope.of(context).requestFocus(FocusNode()),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final friend in friends)
          FriendRowWeb(
            avatarUrl: friend.friendInfo.profileImageUrlUser,
            name: friend.friendInfo.displayName,
            stateMsg: friend.friendInfo.stateMsg,
            onTap: () async {
              await showFriendProfileModal(
                context,
                friendUserId: friend.friendInfo.userId,
                initialName: friend.friendInfo.displayName,
                initialAvatarUrl: friend.friendInfo.profileImageUrlUser,
              );
            },
            trailing: _FriendMoreButton(
              onSelected: (action) => _onMoreAction(friend, action),
            ),
          ),
      ],
    );
  }
}

/// 행 우측 `···`. 데스크탑은 앵커 드롭다운, 좁은 폭은 딤 시트로 열린다
/// ([showWebFilterMenu]가 그 분기를 이미 갖고 있다).
///
/// 공용 [WebMoreButton]은 `actions`가 `List<WebMoreAction>`으로 고정돼 있어(신고/삭제 전용)
/// 친구 메뉴에 쓸 수 없다. 트리거만 같은 모양으로 두고 제네릭 메뉴를 직접 부른다.
class _FriendMoreButton extends StatefulWidget {
  final ValueChanged<_FriendMoreAction> onSelected;

  const _FriendMoreButton({required this.onSelected});

  @override
  State<_FriendMoreButton> createState() => _FriendMoreButtonState();
}

class _FriendMoreButtonState extends State<_FriendMoreButton> {
  /// 아이콘 자체에만 감는다 — 부모에 감으면 드롭다운 위치가 행 전체 기준으로 틀어진다.
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final picked = await showWebFilterMenu<_FriendMoreAction>(
      context: context,
      link: _link,
      values: _FriendMoreAction.values,
      labelOf: (v) => v.label,
      centerSheetOnTablet: true,
    );
    if (picked != null) widget.onSelected(picked);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open,
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: SvgPicture.asset(
              'assets/imgs/icons/icon_header_more_web.svg',
              width: 20,
              height: 20,
            ),
          ),
        ),
      ),
    );
  }
}
