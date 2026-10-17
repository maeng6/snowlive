import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart'
    show RankingFilter_season;
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_share_link.dart';
import 'package:com.snowlive/web/util/web_share_url.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart'
    show crewRecordSeasons;
import 'package:com.snowlive/web/view/profile/w_profile_calendar_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_guestbook_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_profileDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_back_icon_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// 프로필 콘텐츠 열 PC 최대폭 — 목업(1:7764) 실측 874.
/// 통계 카드 2열(423 + 간격 21 + 430)이 이 폭에 정확히 들어간다.
const double kProfileContentMaxWidth = 874;

/// 하단 고정 입력줄이 가리는 높이(세로 패딩 12+12 + 줄 48). 콘텐츠 마지막 글이
/// 입력줄 뒤로 숨지 않게 스크롤 영역 아래를 이만큼 비운다.
const double _kFloatingInputBarHeight = 76;

enum _ProfileTab { stats, guestbook, recordRoom }

enum _StatsMode { total, daily }

/// 프로필 상세. `#/profile?id=750`
///
/// 탭 3개(`라이딩 통계` · `방명록` · `시즌 기록실`)는 폭에 상관없이 같다.
/// 데이터는 `friend-detail-page` 한 번 호출로 헤더·랭킹·통계·일간 캘린더가 모두 오고,
/// 기록실만 같은 API의 `recordroom/`을 시즌별로 다시 부른다.
class ProfileDetailViewWeb extends StatefulWidget {
  const ProfileDetailViewWeb({super.key});

  @override
  State<ProfileDetailViewWeb> createState() => _ProfileDetailViewWebState();
}

class _ProfileDetailViewWebState extends State<ProfileDetailViewWeb> {
  final ProfileDetailViewModelWeb _vm = Get.find<ProfileDetailViewModelWeb>();
  final AuthCheckViewModelWeb _authVm = Get.find<AuthCheckViewModelWeb>();
  final TextEditingController _guestbookController = TextEditingController();

  int? _userId;
  _ProfileTab _tab = _ProfileTab.stats;

  /// 어떤 로그인 상태로 조회를 마쳤는지. 자동로그인 확인이 끝나면 **내 id로 다시** 받아야
  /// 친구 관계(`are_we_friend`)와 내 프로필 여부가 맞게 나온다.
  WebAuthStatus? _loadedForAuth;
  Worker? _authWorker;

  /// 헤더 버튼 상태(친구 요청은 한 번만 보낸다).
  bool _requestSent = false;
  bool _isSendingRequest = false;

  @override
  void initState() {
    super.initState();
    _userId = int.tryParse(Get.parameters['id'] ?? '');
    // 알림센터의 `방명록` 알림은 `&tab=guestbook`으로 들어와 방명록 탭을 바로 연다.
    if (Get.parameters['tab'] == WebRoutes.userProfileTabGuestbook)
      _tab = _ProfileTab.guestbook;
    final id = _userId;
    if (id == null) return;

    // ⚠️ 자동로그인 확인이 끝나기 **전에** 조회하면 안 된다. 그때는 내 user_id가 아직
    // 없어서 비로그인 대체값(보고 있는 유저 id)으로 API를 부르게 되고, 서버가
    // `are_we_friend`를 자기 자신 기준으로 계산해 **이미 친구인데 false**가 나온다
    // (내 프로필도 남의 프로필처럼 보였다). 상태가 정해진 뒤에 받고, 로그인이
    // 확인되면 내 id로 다시 받는다.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadIfNeeded(id);
    });
    _authWorker = ever<WebAuthStatus>(_authVm.statusRx, (_) {
      if (!mounted) return;
      _loadIfNeeded(id);
      setState(() {});
    });
  }

  void _loadIfNeeded(int id) {
    final status = _authVm.status;
    if (status == WebAuthStatus.checking) return;
    if (_loadedForAuth == status) return;
    _loadedForAuth = status;
    _vm.load(id);
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    _guestbookController.dispose();
    super.dispose();
  }

  /// 뒤로가기 — 스택에 돌아갈 화면이 있으면 pop, **없으면 홈으로** 보낸다.
  ///
  /// 메뉴 → `마이페이지`나 헤더 프로필 사진으로 들어오면 루트 전환(`offAllNamed`)이라
  /// pop할 게 없다. 예전에는 그때 버튼을 아예 숨겼는데, 화면마다 뒤로가기가 있다
  /// 없다 해서 혼란스러웠다 → **항상 그리고** 갈 곳만 분기한다(사용자 확정,
  /// 크루홈·친구 하위 화면의 `goBackOr`와 같은 방식).
  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(WebRoutes.home);
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

  Future<void> _sendFriendRequest() async {
    final id = _userId;
    // 내 프로필이거나 이미 친구면 보낼 것이 없다(버튼이 뜨지 않지만 방어한다).
    if (id == null || _vm.isMe || _vm.areWeFriend) return;
    setState(() => _isSendingRequest = true);
    final ok = await Get.find<FriendViewModelWeb>().sendRequest(id);
    if (!mounted) return;
    setState(() {
      _isSendingRequest = false;
      _requestSent = ok;
    });
    _toast(ok ? '친구 요청을 보냈습니다.' : '이미 친구이거나 요청 중이에요.');
  }

  Future<void> _submitGuestbook(String text) async {
    final ok = await _vm.postGuestbook(text);
    if (!mounted) return;
    if (ok) {
      _guestbookController.clear();
      await _vm.refreshTalks();
    }
    if (!mounted) return;
    _toast(ok ? '방명록을 남겼습니다.' : '잠시 후 다시 시도해 주세요.');
  }

  /// 방명록 입력줄을 **뷰포트 하단에 고정**할지. 태블릿·모바일이 같다(사용자 확정) —
  /// 좁은 폭에서는 목록 위에 붙은 입력줄이 스크롤과 함께 사라져 쓰기 어렵다.
  /// PC는 목업대로 목록 위에 그대로 둔다.
  ///
  /// ⚠️ **내 프로필에는 입력줄 자체가 없다**(앱과 동일) → 바를 아예 그리지 않는다.
  /// 안 그러면 빈 바의 상단 라인과 상하 패딩만 남아 하단에 줄이 하나 그어진다
  /// (사용자 지적). 스크롤 아래 여백(76)도 같이 빠진다.
  bool _floatingInput(BuildContext context) =>
      !context.isDesktop && _tab == _ProfileTab.guestbook && !_vm.isMe;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final floatingInput = _floatingInput(context);

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통) — 바깥 Container에
        // 주면 스크롤바가 브라우저 우측 끝이 아니라 여백 안쪽에 뜬다.
        // 서브 페이지 공통 여백(좌우 40/20/16 · 상단 58/20/16).
        // 하단 입력줄이 떠 있으면 그만큼 아래를 비운다.
        padding: webSubPagePadding(
          context,
          bottom: floatingInput ? _kFloatingInputBarHeight : SDSSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            // PC만 목업 폭(874)으로 묶고 **태블릿·모바일은 페이지 여백만 두고 꽉
            // 채운다**(사용자 확정) — 좁은 폭에서 묶으면 양옆 여백만 커진다.
            // 서브 페이지 공통 규칙(`webSubPageColumnMaxWidth`)과 같은 처리다.
            constraints: BoxConstraints(
              maxWidth: context.isDesktop
                  ? kProfileContentMaxWidth
                  : double.infinity,
            ),
            child: Obx(_buildBody),
          ),
        ),
      ),
    );

    if (!floatingInput) return _withHomeFallbackPop(scrollArea);

    // 콘텐츠가 짧으면 셸의 표면색이 하단에 배어 나오므로 스택 전체에 흰 배경을 깐다
    // (크루 만들기·설정에서 겪은 것과 같은 처리).
    return _withHomeFallbackPop(Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          scrollArea,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                color: SDSColor.snowliveWhite,
                // 목업(1:6636) — 바 위에 **1px gray50(#F5F5F5)** 라인. 방명록이 길어
                // 바 뒤로 스크롤될 때 목록과 입력줄을 갈라 준다(사용자 요청).
                // ⚠️ 연회색 라인 공통값(gray100)보다 한 단계 연한 색이다 — 목업 값
                // 그대로 쓴다(바가 떠 있는 느낌을 해치지 않을 만큼만 구분).
                border: Border(top: BorderSide(color: SDSColor.gray50)),
              ),
              // 좌우는 **위 콘텐츠와 같은 선**에 맞춘다 — 페이지 여백과 같은 값
              // (모바일 16 · 태블릿 20, 목업 1:6622도 모바일 16). 상하 12는 공통.
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: 12,
              ),
              child: Obx(_buildGuestbookInput),
            ),
          ),
        ],
      ),
    ));
  }

  /// **브라우저 뒤로가기**도 화면 안 뒤로가기와 같게 만든다.
  ///
  /// 메뉴 → `마이페이지`처럼 루트로 열리면(`offAllNamed`) pop할 게 없어서 브라우저
  /// 뒤로가기를 눌러도 아무 일이 없었다(PC는 화면 안 뒤로가기도 없어 아예 못 나갔다).
  /// 스택이 비었을 때만 가로채서 홈으로 보낸다 — 쌓여 있으면 평소대로 pop한다.
  Widget _withHomeFallbackPop(Widget child) {
    return PopScope(
      canPop: Navigator.of(context).canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Get.offAllNamed(WebRoutes.home);
      },
      child: child,
    );
  }

  Widget _buildBody() {
    // ⚠️ 분기 전에 관찰값을 모두 읽어야 Obx 구독이 확실히 걸린다.
    final detail = _vm.detail;
    final isLoading = _vm.isLoading;
    final hasError = _vm.hasError;
    final talkCount = _vm.talks.length;
    final isHidden = _vm.isHidden;

    if (_userId == null) {
      return const WebEmptyState(message: '프로필을 찾을 수 없어요.');
    }
    if (detail == null) {
      if (hasError) return WebErrorState(onRetry: _vm.reload);
      return isLoading ? const _ProfileSkeleton() : const SizedBox(height: 240);
    }

    final info = detail.friendUserInfo;

    final bool isMobile = context.screenType == WebScreenType.mobile;
    final Widget? shareAction = _buildShareAction(info);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // PC는 사이드바·브라우저 뒤로가기가 있어 화면 안 뒤로가기를 두지 않는다
        // (목업 1:7764에도 없다 — WebPageHeader와 같은 규칙).
        //
        // 모바일은 헤더가 가운데 정렬 기둥이라 뒤로가기를 **윗줄**에 따로 둔다.
        // 태블릿은 목업(1:2423)에 뒤로가기가 없지만 웹에는 필요하므로 헤더 줄
        // **안쪽 프로필 사진 왼쪽**에 넣는다(사용자 확정) — 윗줄로 빼면 헤더가
        // 그만큼 내려가 다른 서브 페이지와 상단 여백이 어긋난다.
        // 모바일은 헤더가 가운데 정렬 기둥이라 **윗줄**을 따로 둔다 —
        // 왼쪽 뒤로가기 / 오른쪽 끝 공유(사용자 확정). 뒤로갈 곳이 없어도
        // 공유는 남으므로 줄 자체는 공유만으로도 그린다.
        if (isMobile) ...[
          Row(
            children: [
              WebIconButton(
                onTap: _goBack,
                padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                icon: const WebBackIcon(size: 24),
              ),
              const Spacer(),
              if (shareAction != null) shareAction,
            ],
          ),
          const SizedBox(height: 20),
        ],
        ProfileHeaderWeb(
          info: info,
          action: _buildHeaderAction(),
          mobileAction: _buildMobileHeaderAction(),
          // 모바일 공유는 위 줄로 올라갔다 → 헤더 아래에는 두지 않는다.
          share: isMobile ? null : shareAction,
          leading: (!context.isDesktop && !isMobile)
              ? WebIconButton(
                  onTap: _goBack,
                  // 서브 페이지 표준 — 좌측 히트 여백 0(화살표가 콘텐츠 좌측선에 붙는다).
                  padding: const EdgeInsets.fromLTRB(0, 0, 4, 0),
                  icon: const WebBackIcon(size: 30),
                )
              : null,
        ),
        // 목업 실측 — 헤더 바닥 → 탭 글줄 윗선.
        // PC·태블릿(1:7764): 161 → 192 = 31.
        // 모바일(1:6206/1:4839): 상태메시지 바닥 212 → 탭 글줄 250 = 38
        //   (헤더 프레임 아래 패딩 16 + 블록 간격 10 + 탭 프레임 위 패딩 12).
        // 여기 탭은 글줄만 그리므로 그 패딩들을 간격에 더해 둔다.
        SizedBox(height: isMobile ? 38 : 31),
        Align(
          alignment: Alignment.centerLeft,
          child: WebTextTabs<_ProfileTab>(
            values: _ProfileTab.values,
            selected: _tab,
            labelOf: _tabLabel,
            // 목업(1:7949) — bold 16, 비활성도 bold gray200,
            // 구분자는 1px 세로선, 좌우 간격 10(친구 요청 관리 탭과 같은 규격).
            fontSize: 16,
            inactiveBold: true,
            inactiveColor: SDSColor.gray200,
            lineDivider: true,
            dividerGap: 10,
            onSelected: (tab) {
              if (tab == _tab) return;
              setState(() => _tab = tab);
              // 기록실은 처음 열 때 최신 시즌을 받아온다.
              if (tab == _ProfileTab.recordRoom &&
                  _vm.record == null &&
                  !_vm.isRecordLoading) {
                _vm.loadRecord(crewRecordSeasons().first.dbSeason);
              }
            },
          ),
        ),
        // 목업 — 탭 글줄 바닥 211 → 다음 블록까지. 라이딩 통계/기록실은 랭킹 바가
        // 233에서 시작해 22(아래 패딩 12 + 간격 10), 방명록은 입력줄이 243이라 32다.
        SizedBox(height: _tabBottomGap(isMobile)),
        if (isHidden)
          const WebEmptyState(message: '프로필 비공개 유저입니다.')
        else
          switch (_tab) {
            _ProfileTab.stats => _StatsPane(
              key: const ValueKey('stats'),
              detail: detail,
              ownerName: info.displayName,
              ownerImageUrl: info.profileImageUrlUser,
              // 넓은 폭에서는 파란 바 왼쪽에 라벨. 내 프로필이면 `내 랭킹`, 남의 프로필이면 `랭킹`.
              leadingLabel: _vm.isMe ? '내 랭킹' : '랭킹',
            ),
            _ProfileTab.guestbook => _buildGuestbook(talkCount),
            _ProfileTab.recordRoom => _buildRecordRoom(info),
          },
      ],
    );
  }

  /// 탭 글줄 바닥 ↔ 아래 블록 윗선(목업 실측).
  /// - 라이딩 통계: 파란 바가 바로 온다 — 22 (PC 1:7764 · 모바일 1:4839).
  /// - 방명록: 입력줄(PC·태블릿) / 목록(모바일)이 와서 32 (1:8886 · 1:6206).
  /// - 기록실 **모바일**: 시즌 드롭다운(글줄 19)이 먼저 와서 42 (1:5520 — 269 → 311).
  ///   PC·태블릿은 드롭다운이 파란 바 **안**이라 통계 탭과 같은 22다.
  double _tabBottomGap(bool isMobile) {
    if (_tab == _ProfileTab.guestbook) return 32;
    if (isMobile && _tab == _ProfileTab.recordRoom) return 42;
    return 22;
  }

  String _tabLabel(_ProfileTab tab) => switch (tab) {
    _ProfileTab.stats => '라이딩 통계',
    _ProfileTab.guestbook => '방명록',
    // 목업(1:7957)은 `내 시즌 기록실`이지만 그건 **내 프로필** 화면이다 —
    // 남의 프로필에서 `내`가 붙으면 말이 안 되므로 그때는 뺀다(사용자 확정).
    _ProfileTab.recordRoom => _vm.isMe ? '내 시즌 기록실' : '시즌 기록실',
  };

  /// 내 프로필 편집 화면으로 갔다가 돌아오면 바뀐 정보로 다시 받는다.
  Future<void> _openEdit() async {
    await Get.toNamed(WebRoutes.profileEdit);
    if (mounted) await _vm.reload();
  }

  /// 모바일은 오른쪽 자리가 없다 — 내 프로필의 `프로필 편집`만 헤더 아래에 둔다
  /// (친구 추가는 모바일 목업에 없다 — 프로필 팝업에 이미 있다).
  Widget? _buildMobileHeaderAction() {
    if (context.screenType != WebScreenType.mobile) return null;
    if (_authVm.status == WebAuthStatus.checking || !_vm.isMe) return null;
    return _HeaderPill(label: '프로필 편집', onTap: _openEdit);
  }

  /// 공유 아이콘 — 로그인·친구 여부와 무관하게 늘 보인다. PC는 링크 복사,
  /// 태블릿·모바일은 OS 공유 시트(shareOrCopyLink). 카카오 미리보기(OG)를 위해
  /// 백엔드 share 링크를 쓴다.
  Widget? _buildShareAction(FriendUserInfo? info) {
    final id = _userId;
    if (id == null) return null;
    void onTap() => shareOrCopyLink(
      context,
      url: profileShareLink(id),
      title: '${(info?.displayName ?? '스노우라이브 유저').trim()} | 스라 프로필',
    );

    if (context.screenType == WebScreenType.mobile) {
      // 모바일은 **박스 없이 아이콘만** 뒤로가기 줄 우측 끝에 선다(사용자 확정).
      // 크기는 같은 줄의 뒤로가기(24)에 맞춘다.
      return WebIconButton(
        onTap: onTap,
        tooltip: '링크 복사',
        padding: EdgeInsets.zero,
        icon: SvgPicture.asset(
          'assets/imgs/icons/icon_header_share_web.svg',
          width: 24,
          height: 24,
        ),
      );
    }

    // PC·태블릿은 프로필 편집·친구 추가와 **같은 박스 버튼**(사용자 확정) —
    // 아이콘만 떠 있으면 옆 버튼과 높이·테두리가 안 맞아 따로 노는 것처럼 보인다.
    return _HeaderIconPill(
      tooltip: '링크 복사',
      onTap: onTap,
      // 박스(36×36)는 옆 버튼과 같게 두고 **아이콘만** 작게 — 26은 박스를 꽉 채워
      // 글자 버튼 옆에서 혼자 커 보였다(사용자 확정).
      icon: SvgPicture.asset(
        'assets/imgs/icons/icon_header_share_web.svg',
        width: 20,
        height: 20,
      ),
    );
  }

  Widget? _buildHeaderAction() {
    // 모바일은 [_buildMobileHeaderAction]이 맡는다.
    if (context.screenType == WebScreenType.mobile) return null;
    // 자동로그인 확인 중에는 판단할 근거가 없다 → 잘못된 버튼을 띄우지 않는다.
    if (_authVm.status == WebAuthStatus.checking) return null;
    if (_vm.isMe) return _HeaderPill(label: '프로필 편집', onTap: _openEdit);
    // 비로그인 방문자에게도 버튼을 보여주고, 누르면 로그인 화면으로 보낸다.
    if (!_vm.isLoggedIn) {
      return _HeaderPill(
        label: '친구 추가',
        onTap: () => Get.toNamed(WebRoutes.login),
      );
    }
    // 이미 친구거나 요청을 보냈으면 누를 것이 없다 → 버튼이 아니라 표시로 그린다.
    if (_vm.areWeFriend)
      return const WebProfileStateBadge(label: '내 친구', isPositive: true);
    if (_requestSent) return const WebProfileStateBadge(label: '요청 보냄');
    return _HeaderPill(
      label: _isSendingRequest ? '요청 중…' : '친구 추가',
      onTap: _isSendingRequest ? null : _sendFriendRequest,
    );
  }

  // ===== 방명록 =====

  Widget _buildGuestbook(int talkCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 태블릿·모바일은 입력줄이 하단에 고정된다 → 여기서는 그리지 않는다.
        if (!_floatingInput(context)) ...[
          _buildGuestbookInput(),
          // 목업(1:8886) — 입력줄(48) 바닥 291 → 목록 321 = 30.
          const SizedBox(height: 30),
        ],
        ProfileGuestbookListWeb(
          talks: _vm.talks,
          canDelete: (talk) => talk.authorUserId == _vm.myUserId || _vm.isMe,
          canReport: (talk) =>
              _vm.isLoggedIn && talk.authorUserId != _vm.myUserId,
          onDelete: (talk) async {
            final ok = await _vm.deleteGuestbook(
              talkId: talk.friendsTalkId,
              authorUserId: talk.authorUserId,
            );
            if (ok) await _vm.refreshTalks();
            return ok;
          },
          onReport: (talk) => mapWebActionResponse(
            () => _vm.reportGuestbook(talk.friendsTalkId),
          ),
          emptyHint: _guestbookLockedMessage(),
        ),
      ],
    );
  }

  Widget _buildGuestbookInput() {
    // ⚠️ 이 메서드는 Obx 빌더로도 쓰인다 → 분기보다 **먼저** 관찰값을 읽어야 한다.
    // 하나도 읽지 않고 반환하면 GetX가 "improper use of a GetX"로 죽는다.
    final isSubmitting = _vm.isSubmitting;
    final canWrite = _vm.canWriteGuestbook;

    // 내 프로필에는 입력줄을 두지 않는다(앱과 동일).
    if (_vm.isMe) return const SizedBox.shrink();
    return ProfileGuestbookInputWeb(
      controller: _guestbookController,
      isSubmitting: isSubmitting,
      onSubmit: canWrite ? _submitGuestbook : null,
      onLockedTap: () async {
        // 비로그인 → 커뮤니티·중고거래와 동일한 로그인 유도 다이얼로그.
        if (!_vm.isLoggedIn) {
          final goLogin = await showWebConfirmDialog(
            context: context,
            title: '로그인이 필요해요',
            message: '방명록은 로그인 후 남길 수 있어요.',
            confirmLabel: '로그인하기',
          );
          if (goLogin) Get.toNamed(WebRoutes.login);
          return;
        }
        final message = _guestbookLockedMessage();
        if (message != null) _toast(message);
      },
    );
  }

  String? _guestbookLockedMessage() {
    if (_vm.isMe || _vm.canWriteGuestbook) return null;
    if (!_vm.isLoggedIn) return '로그인이 필요해요.';
    // 로그인은 했는데 친구가 아니라 못 쓰는 경우 — 목업(1:9264)의 둘째 줄 문구.
    // 전에는 null이라 빈 상태에 이유가 안 나오고, 잠긴 줄을 눌러도 아무 말이 없었다.
    return kProfileGuestbookFriendOnlyHint;
  }

  // ===== 기록실 =====

  Widget _buildRecordRoom(FriendUserInfo info) {
    final record = _vm.record;
    final isRecordLoading = _vm.isRecordLoading;
    final season = _vm.recordSeason;

    if (record == null) {
      return isRecordLoading
          ? const _ProfileStatsSkeleton()
          : const WebEmptyState(message: '이 시즌 기록이 없어요.');
    }

    return _StatsPane(
      // 시즌을 바꾸면 누적/일간 선택과 표시 달을 새로 시작한다.
      key: ValueKey('record-$season'),
      detail: record,
      ownerName: info.displayName,
      ownerImageUrl: info.profileImageUrlUser,
      seasonSelectorBuilder: (color) => _SeasonSelector(
        season: season,
        color: color,
        onSelected: (value) => _vm.loadRecord(value),
      ),
    );
  }
}

/// 헤더 버튼과 **같은 껍데기**(테두리 gray200 · 라운드 5 · 높이 36)에 아이콘만 담는다.
/// 공유처럼 글자가 없는 액션용 — 패딩 5 + 아이콘 26이라 정확히 36×36 정사각이 된다.
class _HeaderIconPill extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;
  final String? tooltip;

  const _HeaderIconPill({required this.icon, this.onTap, this.tooltip});

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onTap,
      style: _headerButtonStyle(
        padding: const EdgeInsets.all(5),
        // 아이콘이 작아도 박스는 36×36 — 옆 글자 버튼과 윗선·아랫선이 맞는다
        // (ButtonStyleButton이 남는 공간에 아이콘을 가운데로 둔다).
        minimumSize: const Size(36, 36),
      ),
      child: icon,
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

/// 헤더 라인 버튼(프로필 편집 · 친구 추가 · 공유) 공통 스타일.
///
/// hover는 **웹 라인 버튼 공통** — 테두리·글자는 그대로, 면이 흰색 → gray50으로
/// 어두워진다. 리플·그림자·전환 애니메이션은 쓰지 않는다
/// (`WebSectionLinkButton` · `WebProfilePillButton` · 라이브크루 필터 칩과 같은 규칙).
/// Material 기본값을 그대로 두면 리플과 보라 오버레이가 떠서 다른 화면과 어긋난다.
///
/// ⚠️ `visualDensity: standard` — 웹 기본(compact)은 패딩을 상하좌우 4씩 깎아
/// 36이어야 할 버튼을 28로 만든다.
ButtonStyle _headerButtonStyle({
  required EdgeInsets padding,
  required Size minimumSize,
  /// 모서리를 **완전히 둥글게**(알약) 할지 — 모바일 `프로필 편집`만 true(사용자 확정).
  bool stadium = false,
}) {
  return ButtonStyle(
    splashFactory: NoSplash.splashFactory,
    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    shadowColor: const WidgetStatePropertyAll(Colors.transparent),
    elevation: const WidgetStatePropertyAll(0),
    animationDuration: Duration.zero,
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.hovered)
          ? SDSColor.gray50
          : SDSColor.snowliveWhite,
    ),
    // 목업(1:7851) — 테두리 gray200, 라운드 5.
    side: const WidgetStatePropertyAll(BorderSide(color: SDSColor.gray200)),
    padding: WidgetStatePropertyAll(padding),
    visualDensity: VisualDensity.standard,
    minimumSize: WidgetStatePropertyAll(minimumSize),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    shape: WidgetStatePropertyAll(
      stadium
          ? const StadiumBorder()
          : RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
  );
}

class _HeaderPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _HeaderPill({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      // 목업(1:7851) — 패딩 16/10 + 글줄 16 = 80×36.
      // 모바일만 모서리를 완전히 둥글게 쓴다(사용자 확정).
      style: _headerButtonStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: const Size(0, 36),
        stadium: context.screenType == WebScreenType.mobile,
      ),
      child: Text(
        label,
        // 줄높이 16 고정 — 목업 버튼 높이 36(패딩 10+10 + 글줄 16)에 맞춘다.
        style: SDSTextStyle.bold.copyWith(
          fontSize: 13,
          height: 16 / 13,
          color: SDSColor.gray700,
        ),
      ),
    );
  }
}

/// `25/26 시즌 랭킹 ⌄` 드롭다운(목업). 서버가 23/24는 거부하므로 두 시즌만 준다.
class _SeasonSelector extends StatefulWidget {
  final String season;
  final ValueChanged<String> onSelected;

  /// 파란 바 안에서는 흰색, 모바일처럼 흰 배경 위에 놓일 때는 검정으로 그린다.
  final Color color;

  const _SeasonSelector({
    required this.season,
    required this.onSelected,
    required this.color,
  });

  @override
  State<_SeasonSelector> createState() => _SeasonSelectorState();
}

class _SeasonSelectorState extends State<_SeasonSelector> {
  final LayerLink _link = LayerLink();

  /// 파란 바 안의 링크는 **hover에서 밑줄**이 공통이다(`WebStatsBarLink`·지표 칸과
  /// 같은 규칙) — 바 위에 배경 틴트를 깔면 색이 겹쳐 잘 안 보인다.
  bool _hovered = false;

  String _label(RankingFilter_season season) =>
      '${season.korean.replaceAll('시즌', '')} 시즌 랭킹';

  Future<void> _open() async {
    final selected = await showWebFilterMenu<RankingFilter_season>(
      context: context,
      link: _link,
      values: crewRecordSeasons(),
      labelOf: _label,
      centerSheetOnTablet: true,
    );
    if (selected == null) return;
    widget.onSelected(selected.dbSeason);
  }

  @override
  Widget build(BuildContext context) {
    final current = crewRecordSeasons().firstWhere(
      (s) => s.dbSeason == widget.season,
      orElse: () => crewRecordSeasons().first,
    );

    return CompositedTransformTarget(
      link: _link,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _open,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _label(current),
                  // 라이딩 통계 탭의 `내 랭킹`과 **같은 자리·같은 크기**(Bold 16).
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 16,
                    color: widget.color,
                    decoration: _hovered
                        ? TextDecoration.underline
                        : TextDecoration.none,
                    decorationColor: widget.color,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(Icons.expand_more, size: 18, color: widget.color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 파란 랭킹 바 + `누적 통계`/`일간 통계` + (일간이면) 캘린더 + 라이딩 통계.
///
/// 라이딩 통계 탭과 기록실 탭이 같은 구성을 쓰고 데이터원만 다르다(목업).
class _StatsPane extends StatefulWidget {
  final FriendDetailModel detail;
  final String ownerName;
  final String? ownerImageUrl;

  /// 넓은 폭에서 파란 바 왼쪽에 붙는 라벨(`내 랭킹`).
  final String? leadingLabel;

  /// 기록실에서는 라벨 자리에 시즌 드롭다운이 온다. 놓이는 배경색이 폭에 따라
  /// 달라서(파란 바 / 흰 배경) 글자색을 받아 만드는 빌더로 넘긴다.
  final Widget Function(Color color)? seasonSelectorBuilder;

  const _StatsPane({
    super.key,
    required this.detail,
    required this.ownerName,
    required this.ownerImageUrl,
    this.leadingLabel,
    this.seasonSelectorBuilder,
  });

  @override
  State<_StatsPane> createState() => _StatsPaneState();
}

class _StatsPaneState extends State<_StatsPane> {
  _StatsMode _mode = _StatsMode.total;
  late DateTime _month;
  int? _selectedDay;

  /// 날짜별 기록. 서버는 날짜 내림차순으로 준다.
  late final Map<String, CalendarInfo> _byDate = {
    for (final info in widget.detail.calendarInfo) info.date: info,
  };

  @override
  void initState() {
    super.initState();
    // 가장 최근 기록이 있는 달을 먼저 보여준다(빈 달로 시작하면 아무것도 안 보인다).
    final latest = widget.detail.calendarInfo.isEmpty
        ? null
        : DateTime.tryParse(widget.detail.calendarInfo.first.date);
    final now = DateTime.now();
    _month = DateTime(latest?.year ?? now.year, latest?.month ?? now.month);
    _selectedDay = latest?.day;
  }

  Map<int, int> get _countsByDay {
    final out = <int, int>{};
    _byDate.forEach((date, info) {
      final parsed = DateTime.tryParse(date);
      if (parsed == null) return;
      if (parsed.year == _month.year && parsed.month == _month.month) {
        out[parsed.day] = info.daily_total_count;
      }
    });
    return out;
  }

  CalendarInfo? get _selected {
    final day = _selectedDay;
    if (day == null) return null;
    final key =
        '${_month.year}-${_month.month.toString().padLeft(2, '0')}'
        '-${day.toString().padLeft(2, '0')}';
    return _byDate[key];
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
      // 옮긴 달에 기록이 있으면 그 달의 가장 이른 날을 고른다.
      final days = _countsByDay.keys.toList()..sort();
      _selectedDay = days.isEmpty ? null : days.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final season = widget.detail.seasonRankingInfo;
    final hasRecord =
        season.overallTotalCount > 0 || season.countInfo.isNotEmpty;

    final leading =
        widget.seasonSelectorBuilder?.call(SDSColor.snowliveWhite) ??
        (widget.leadingLabel == null
            ? null
            : Text(
                widget.leadingLabel!,
                // 목업(1:7959) — `내 랭킹` Bold 16, 글줄 19.
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  height: 19 / 16,
                  color: SDSColor.snowliveWhite,
                ),
              ));

    if (!hasRecord) {
      // 목업(1:6994) — 기록이 없으면 **파란 랭킹 바도 통계 토글도 그리지 않고**
      // 빈 상태만 보여준다(점수가 전부 `-`인 바는 알려 주는 게 없다).
      //
      // 예외: 기록실은 시즌 드롭다운이 **파란 바 안**에 있는 폭(PC·태블릿)에서만
      // 바를 남긴다 — 빼 버리면 시즌을 바꿀 방법이 사라진다. 모바일은 드롭다운이
      // 바 위에 따로 서므로 목업대로 바를 없앤다.
      final keepBarForSeasonPicker =
          widget.seasonSelectorBuilder != null && !isMobile;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isMobile && widget.seasonSelectorBuilder != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: widget.seasonSelectorBuilder!(SDSColor.gray900),
            ),
            // 목업(1:5520) — 드롭다운(19) 바닥 330 → 파란 바 350 = 20.
            const SizedBox(height: 20),
          ],
          if (keepBarForSeasonPicker) ...[
            ProfileRankBarWeb(
              leading: leading,
              score: null,
              rank: null,
              tierName: null,
              tierIconUrl: null,
              empty: true,
            ),
            const SizedBox(height: SDSSpacing.xxl),
          ],
          const WebEmptyState(message: '아직 라이딩 기록이 없어요'),
        ],
      );
    }

    final daily = _selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 모바일은 목업처럼 시즌 드롭다운을 파란 바 위에 따로 놓는다(흰 배경이라 검정 글씨).
        if (isMobile && widget.seasonSelectorBuilder != null) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: widget.seasonSelectorBuilder!(SDSColor.gray900),
          ),
          // 목업(1:5520) — 드롭다운(19) 바닥 330 → 파란 바 350 = 20.
          const SizedBox(height: 20),
        ],
        ProfileRankBarWeb(
          leading: leading,
          score: season.overallTotalScore,
          rank: season.overallRank,
          tierName: season.tierNameKor,
          tierIconUrl: season.overallTierIconUrl,
        ),
        // 목업 — 랭킹 바 ↔ 통계 토글: PC·태블릿 40 / 모바일 30(1:4994→1:5025).
        SizedBox(height: isMobile ? 30 : 40),
        Row(
          children: [
            _ModePill(
              label: '누적 통계',
              isActive: _mode == _StatsMode.total,
              onTap: () => setState(() => _mode = _StatsMode.total),
            ),
            const SizedBox(width: SDSSpacing.sm),
            _ModePill(
              label: '일간 통계',
              isActive: _mode == _StatsMode.daily,
              onTap: () => setState(() => _mode = _StatsMode.daily),
            ),
          ],
        ),
        if (_mode == _StatsMode.daily) ...[
          // 목업 — 토글 ↔ 월 네비게이션: PC·태블릿 24 / 모바일 40(1:5025→1:5279).
          SizedBox(height: isMobile ? 40 : SDSSpacing.lg),
          ProfileDailyCalendarWeb(
            month: _month,
            countsByDay: _countsByDay,
            selectedDay: _selectedDay,
            today: DateTime.now(),
            onSelectDay: (day) => setState(() => _selectedDay = day),
            onPrevMonth: () => _shiftMonth(-1),
            onNextMonth: () => _shiftMonth(1),
          ),
        ],
        // 목업 — 날짜 스트립(또는 토글) ↔ 라이딩 통계: PC·태블릿 40 / 모바일 30
        SizedBox(height: isMobile ? 24 : 32),
        if (_mode == _StatsMode.total)
          ProfileRidingStatsWeb(
            totalCount: season.overallTotalCount,
            slopes: season.countInfo,
            timeCounts: profileTimeCounts(season.timeInfo),
            ownerName: widget.ownerName,
            ownerImageUrl: widget.ownerImageUrl,
          )
        else if (daily == null)
          const WebEmptyState(message: '이 날은 라이딩 기록이 없어요')
        else
          ProfileRidingStatsWeb(
            totalCount: daily.daily_total_count,
            slopes: daily.dailyInfo,
            timeCounts: profileTimeCounts(daily.timeInfo),
            ownerName: widget.ownerName,
            ownerImageUrl: widget.ownerImageUrl,
          ),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ModePill({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isActive ? SDSColor.snowliveBlack : SDSColor.snowliveWhite;
    // 목업(1:7991) — 비활성 테두리 gray100.
    final border = isActive ? SDSColor.snowliveBlack : SDSColor.gray100;

    return ElevatedButton(
      onPressed: onTap,
      // hover는 **토글 칩 공통 규칙**(라이브크루 필터 칩과 동일) — 테두리는 고정하고
      // 면만 어두워진다: 미선택은 흰색 → gray50, 선택됨은 배경에 검정 10%.
      // 리플·그림자·전환 애니메이션은 쓰지 않는다(웹 공통).
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        animationDuration: Duration.zero,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (!states.contains(WidgetState.hovered)) return background;
          return isActive
              ? Color.alphaBlend(Colors.black.withValues(alpha: 0.1), background)
              : SDSColor.gray50;
        }),
        side: WidgetStatePropertyAll(BorderSide(color: border)),
        // 목업(1:7991) — 패딩 좌 14 / 우 12 / 상하 10, Bold 14 글줄 16 → 78×36.
        padding: const WidgetStatePropertyAll(EdgeInsets.fromLTRB(14, 10, 12, 10)),
        // ⚠️ 웹 기본 visualDensity(compact)가 패딩을 4씩 깎는다.
        visualDensity: VisualDensity.standard,
        minimumSize: const WidgetStatePropertyAll(Size(0, 36)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(
          fontSize: 14,
          height: 16 / 14,
          color: isActive ? SDSColor.snowliveWhite : SDSColor.snowliveBlack,
        ),
      ),
    );
  }
}

/// 첫 로딩 자리표시 — **실제 레이아웃과 같은 높이·간격**으로 잡는다.
/// 하나라도 다르면 데이터가 도착하는 순간 화면이 튄다(크루홈 스켈레톤과 같은 원칙).
class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    // 헤더 — 모바일은 아바타 64 가운데 기둥(16 + 19 + 2 + 16 + 2 + 16 = 135),
    // PC·태블릿은 한 줄(아바타 48 + 이름 / 소속·상태 / 버튼 80×36 = 48).
    final header = isMobile
        ? Column(
            children: const [
              SkeletonBox(width: 64, height: 64, isCircle: true),
              SizedBox(height: 16),
              SkeletonBox(width: 120, height: 19),
              SizedBox(height: 2),
              SkeletonBox(width: 180, height: 16),
              SizedBox(height: 2),
              SkeletonBox(width: 220, height: 16),
            ],
          )
        : Row(
            children: const [
              SkeletonBox(width: 48, height: 48, isCircle: true),
              SizedBox(width: 12),
              SkeletonBox(width: 160, height: 29),
              Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SkeletonBox(width: 140, height: 16),
                  SizedBox(height: 4),
                  SkeletonBox(width: 200, height: 16),
                ],
              ),
              SizedBox(width: SDSSpacing.lg),
              SkeletonBox(width: 80, height: 36, radius: 5),
            ],
          );

    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 모바일 뒤로가기·공유 줄(24) + 아래 간격 8.
          if (isMobile) ...[
            const SkeletonBox(width: 24, height: 24, radius: 4),
            const SizedBox(height: SDSSpacing.sm),
          ],
          header,
          // 헤더 ↔ 탭(모바일 38 / 그 외 31).
          SizedBox(height: isMobile ? 38 : 31),
          // 탭 세 개 묶음 — 목업 폭 248, 글줄 19.
          const SkeletonBox(width: 248, height: 19),
          // 탭 ↔ 랭킹 바 22.
          const SizedBox(height: 22),
          const _ProfileStatsSkeleton(nested: true),
        ],
      ),
    );
  }
}

/// 랭킹 바 + 통계 토글 + 라이딩 통계 자리표시. 기록실 탭은 이것만 따로 쓴다.
class _ProfileStatsSkeleton extends StatelessWidget {
  /// 위에서 이미 [SkeletonShimmer]로 감쌌는지. 단독으로 쓰일 때만 자기 shimmer를 갖는다.
  final bool nested;

  const _ProfileStatsSkeleton({this.nested = false});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final isDesktop = context.isDesktop;
    const card = SkeletonBox(height: 310, radius: 12);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 랭킹 바 — 모바일 80(값·라벨 2줄 + 티어 40) / 그 외 54.
        SkeletonBox(height: isMobile ? 78 : 54, radius: 12),
        SizedBox(height: isMobile ? 30 : 40),
        // 누적/일간 토글 78×36, 사이 8.
        const Row(
          children: [
            SkeletonBox(width: 78, height: 36, radius: 20),
            SizedBox(width: SDSSpacing.sm),
            SkeletonBox(width: 78, height: 36, radius: 20),
          ],
        ),
        SizedBox(height: isMobile ? 30 : 40),
        // 라이딩 통계 제목 줄(36) — 제목 + 우측 `전체 슬로프 보기` 109×36.
        const SizedBox(
          height: 36,
          child: Row(
            children: [
              SkeletonBox(width: 100, height: 19),
              Spacer(),
              SkeletonBox(width: 109, height: 36, radius: 6),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (isMobile)
          const Column(children: [card, SizedBox(height: 20), card])
        else
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: isDesktop ? 423 : 1, child: card),
                SizedBox(width: isDesktop ? 21 : 20),
                Expanded(flex: isDesktop ? 430 : 1, child: card),
              ],
            ),
          ),
      ],
    );

    return nested ? body : SkeletonShimmer(child: body);
  }
}
