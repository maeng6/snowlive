import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/api/api_locationShare.dart';
import 'package:com.snowlive/core/model/m_bestFriendListModel.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_page_scaffold_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_profile_modal_web.dart';
import 'package:com.snowlive/web/view/friend/w_friend_row_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/viewmodel/paid/vm_paidVisibility_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart';
import 'package:com.snowlive/web/widget/w_web_search_field_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 친구 목록 빈 상태 아이콘. 정사각이 아니라서 `contain`으로 넣어야 찌그러지지 않는다.
const String _kFriendEmptyIcon = 'assets/imgs/icons/icon_no_member.png';

/// 친구 목록 행의 `···` 메뉴 항목.
enum _FriendMoreAction {
  shareLocation('위치공유 신청'),
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
  final UserViewModel _userVm = Get.find<UserViewModel>();
  final LocationShareAPI _locationApi = LocationShareAPI();

  /// 위치공유 신청은 유료(시즌권) 전용 → 미소지자는 메뉴에서 회색 비활성.
  bool _isPaid = false;

  /// 내 user_id. 친구 목록에 내가 섞여 와도 나에겐 ···(삭제/차단)을 띄우지 않기 위함.
  int? get _myUserId {
    final id = _userVm.user?.user_id;
    if (id is int) return id;
    return int.tryParse('$id');
  }

  final TextEditingController _searchController = TextEditingController();

  Worker? _authWorker;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.refreshAll();
      _loadPaid();
    });
    // 자동로그인이 늦게 확정되면 최초 조회가 user_id 없이 조용히 실패해 빈 화면이 남는다.
    // 로그인 후 돌아온 경우에도 걸리므로 재조회와 함께 setState로 본문을 바꿔준다.
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (status) {
      if (status != WebAuthStatus.authenticated) return;
      _vm.refreshAll();
      _loadPaid();
      if (mounted) setState(() {});
    });
  }

  /// 시즌권 보유 여부 조회(위치공유 메뉴 활성/비활성 판단용).
  Future<void> _loadPaid() async {
    final uid = _myUserId;
    if (uid == null) return;
    final res = await _locationApi.list(userId: uid);
    if (!mounted) return;
    if (res.success && res.data is Map) {
      setState(() => _isPaid = res.data['is_paid'] == true);
    }
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

    // ⚠️ 검색 API는 `requesting_user_id`를 필수로 받는다. 비로그인 상태에서 그대로
    // 부르면 서버가 500을 주고(실측) 화면은 "검색하신 친구가 없습니다."를 띄워서
    // 로그인이 필요한 건지 정말 없는 건지 구분할 수 없다 → 아예 부르지 않고 안내한다.
    if (_isGuest) {
      await _showLoginRequiredDialog();
      return;
    }

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

  /// 비로그인 검색 안내 — 웹 공용 박스 팝업(로그인하기 / 다음에 하기).
  Future<void> _showLoginRequiredDialog() async {
    final goLogin = await showWebBoxPopup(
      context: context,
      title: '로그인이 필요해요.',
      message: '친구 검색은 로그인한 뒤에 할 수 있어요.',
      primaryLabel: '로그인하기',
      secondaryLabel: '다음에 하기',
    );
    if (goLogin) Get.toNamed(WebRoutes.login);
  }

  /// 검색 결과 없음 안내(피그마 218:68675).
  /// 고를 것이 없는 안내라 `확인` 한 개 · 채움 없는 버튼이다.
  Future<void> _showNotFoundDialog() async {
    await showWebBoxPopup(
      context: context,
      title: '검색하신 친구가 없습니다.',
      message: '닉네임 전체를 정확히 입력해 주세요.',
      primaryLabel: '확인',
      filledPrimary: false,
    );
  }

  Future<void> _onMoreAction(FriendListModel friend, _FriendMoreAction action) async {
    final info = friend.friendInfo;
    final name = info.displayName;

    if (action == _FriendMoreAction.shareLocation) {
      final uid = _myUserId;
      final fid = info.userId;
      if (uid == null || fid == null) {
        _toast('로그인이 필요해요.');
        return;
      }
      final res =
          await LocationShareAPI().request(userId: uid, friendUserId: fid);
      if (!mounted) return;
      if (res.success) {
        final st = (res.data is Map) ? res.data['status'] : null;
        _toast(st == 'ACCEPTED'
            ? '서로 수락되어 위치공유가 시작됐어요.'
            : '$name님에게 위치공유를 신청했어요.');
      } else {
        _toast(res.data is Map && res.data['message'] != null
            ? '${res.data['message']}'
            : '위치공유 신청에 실패했어요.');
      }
      return;
    }

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
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;

    return Container(
      color: SDSColor.snowliveWhite,
      // 홈 공통 여백(중고거래 홈 기준).
      // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통) — 바깥에 주면
      // 스크롤바가 여백 안쪽에 생겨 브라우저 오른쪽 끝에 붙지 않는다.
      child: SingleChildScrollView(
        padding: webHomePagePadding(context),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: friendContentMaxWidth(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ..._buildHeader(isDesktop),
                // 헤더 ↔ 목록: PC 29(목업 218:68675 — 타이틀 블록 pb19 + 목록 top 10),
                // 태블릿·모바일 26(목업 218:71076 / 218:69162 — 검색창 끝에서 목록까지).
                SizedBox(height: isDesktop ? 29 : 26),
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
      // 홈 타이틀 공통: PC 32 / 태블릿·모바일 24 (중고거래 홈 기준).
      style: SDSTextStyle.extraBold.copyWith(
        fontSize: webHomeTitleSize(context),
        color: SDSColor.gray900,
      ),
    );
    final searchField = WebSearchField(
      controller: _searchController,
      // 목업(218:67555) 문구 — 닉네임 전체일치로 **유저**를 찾는 검색이라 `친구 검색`이
      // 아니다(친구가 아닌 사람도 찾는다).
      hint: '유저 검색',
      borderRadius: 6,
      onSubmitted: _onSearch,
    );
    // 목업(218:67561) — 헤더 아이콘 26. 누를 여백은 **좌측에만** 둬서 아이콘
    // 오른쪽 끝이 콘텐츠 우측선에 붙는다(뒤로가기가 좌측선에 붙는 것과 같은 처리).
    // `IconButton`은 자체 최소 크기·여백이 있어 우측에 11이 남았다 → 공용 버튼으로.
    // ⚠️ 세로 여백은 0 — 주면 줄 높이가 아이콘(26) + 여백이 되어 태블릿·모바일에서
    // 타이틀 줄이 목업(26)보다 두꺼워지고 아래 검색창·목록이 전부 밀린다.
    final settingsButton = WebIconButton(
      onTap: () => Get.toNamed(WebRoutes.friendSettings),
      padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
      icon: Image.asset('assets/imgs/icons/icon_settings.png', width: 26, height: 26),
    );

    if (isDesktop) {
      return [
        Row(
          children: [
            title,
            // 타이틀 ↔ 검색창 36 (목업 218:67550 gap).
            const SizedBox(width: 36),
            // 검색창은 **260 고정**이다(목업 218:67552) — 늘리면 설정 아이콘까지
            // 붙어서 목업의 여백이 사라진다.
            SizedBox(width: 260, child: searchField),
            const Spacer(),
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
      // 목업(218:67789) — 73.
      iconWidth: 73,
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
        // 목업(218:67789) — 73.
      iconWidth: 73,
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
          // 내 자신 행은 완전히 비활성 — ···(삭제/차단)도, 행 탭(프로필 팝업)도 없앤다.
          // (아이콘만 숨기면 탭 영역이 남아 눌리는 문제가 있었다.)
          Builder(builder: (_) {
            final isMe = friend.friendInfo.userId == _myUserId;
            return FriendRowWeb(
              avatarUrl: friend.friendInfo.profileImageUrlUser,
              name: friend.friendInfo.displayName,
              stateMsg: friend.friendInfo.stateMsg,
              onTap: isMe
                  ? null
                  : () async {
                      await showFriendProfileModal(
                        context,
                        friendUserId: friend.friendInfo.userId,
                        initialName: friend.friendInfo.displayName,
                        initialAvatarUrl: friend.friendInfo.profileImageUrlUser,
                        // 친구 목록에서 열었으니 관계는 이미 안다.
                        initialAreWeFriend: true,
                      );
                    },
              trailing: isMe
                  ? null
                  : _FriendMoreButton(
                      isPaid: _isPaid,
                      // 위치공유는 이번 시즌 내부 테스트 중이라 신청 항목 자체를 숨김(플래그).
                      showShareLocation:
                          PaidVisibilityControllerWeb.locationShareEnabled &&
                              PaidVisibilityControllerWeb.isVisible,
                      onSelected: (action) => _onMoreAction(friend, action),
                    ),
            );
          }),
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

  /// 위치공유 신청은 유료 전용. false면 그 항목만 회색 비활성으로 표시한다.
  final bool isPaid;

  /// 위치공유 신청 항목을 메뉴에 노출할지(출시 전엔 테스트 대상만 true).
  final bool showShareLocation;

  const _FriendMoreButton({
    required this.onSelected,
    this.isPaid = false,
    this.showShareLocation = false,
  });

  @override
  State<_FriendMoreButton> createState() => _FriendMoreButtonState();
}

class _FriendMoreButtonState extends State<_FriendMoreButton> {
  /// 아이콘 자체에만 감는다 — 부모에 감으면 드롭다운 위치가 행 전체 기준으로 틀어진다.
  final LayerLink _link = LayerLink();

  Future<void> _open() async {
    final values = widget.showShareLocation
        ? _FriendMoreAction.values
        : _FriendMoreAction.values
            .where((v) => v != _FriendMoreAction.shareLocation)
            .toList();
    final picked = await showWebFilterMenu<_FriendMoreAction>(
      context: context,
      link: _link,
      values: values,
      labelOf: (v) => v.label,
      // 위치공유 신청은 시즌권 보유자만 활성(미소지자는 회색 비활성).
      enabledOf: (v) =>
          v == _FriendMoreAction.shareLocation ? widget.isPaid : true,
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
          // 목업(218:67574) — `···` 26. 누를 여백은 좌·상·하로만 두어
          // **아이콘 오른쪽 끝이 콘텐츠 우측선에 붙는다**(목업 정렬).
          child: Padding(
            padding: const EdgeInsets.fromLTRB(6, 6, 0, 6),
            child: SvgPicture.asset(
              'assets/imgs/icons/icon_header_more_web.svg',
              width: 26,
              height: 26,
              // 목업은 점이 #B7B7B7(gray400)이다. 에셋 자체는 gray900이라
              // **여기서만** 덧칠한다 — 같은 에셋을 쓰는 공용 ⋯ 메뉴
              // (`w_web_more_menu_web.dart`)는 진한 색 그대로다.
              colorFilter: const ColorFilter.mode(SDSColor.gray400, BlendMode.srcIn),
            ),
          ),
        ),
      ),
    );
  }
}
