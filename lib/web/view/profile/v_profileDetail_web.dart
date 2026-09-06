import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/core/model/m_friendsTalk.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_rankingList_recordRoom.dart'
    show RankingFilter_season;
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart'
    show crewRecordSeasons;
import 'package:com.snowlive/web/view/profile/w_profile_calendar_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_guestbook_web.dart';
import 'package:com.snowlive/web/view/profile/w_profile_widgets_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_friend_web.dart';
import 'package:com.snowlive/web/viewmodel/friend/vm_profileDetail_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_web_filter_menu_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_more_menu_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_card_web.dart';
import 'package:com.snowlive/web/widget/w_web_text_tabs_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 폭(통계 카드가 2열로 눕는다).
const double kProfileContentMaxWidth = 1136;

/// 모바일 하단 고정 입력줄 높이(패딩 12+12 + 줄 48).
const double _kMobileInputBarHeight = 76;

enum _ProfileTab { stats, guestbook, recordRoom }

enum _StatsMode { total, daily }

/// 프로필 상세. `#/profile?id=750`
///
/// 탭 3개(`라이딩 통계` · `방명록` · `시즌 기록실`)는 폭에 상관없이 같다(사용자 확정).
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

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        // 모바일 방명록 탭은 하단 입력줄이 떠 있어 그만큼 여백을 둔다.
        isMobile && _tab == _ProfileTab.guestbook ? _kMobileInputBarHeight : SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kProfileContentMaxWidth),
            child: Obx(_buildBody),
          ),
        ),
      ),
    );

    if (!isMobile || _tab != _ProfileTab.guestbook) return scrollArea;

    // 콘텐츠가 짧으면 셸의 표면색이 하단에 배어 나오므로 스택 전체에 흰 배경을 깐다
    // (크루 만들기·설정에서 겪은 것과 같은 처리).
    return Container(
      color: SDSColor.snowliveWhite,
      child: Stack(
        children: [
          scrollArea,
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: SDSColor.snowliveWhite,
              padding: const EdgeInsets.all(12),
              child: Obx(_buildGuestbookInput),
            ),
          ),
        ],
      ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileHeaderWeb(info: info, action: _buildHeaderAction()),
        const SizedBox(height: SDSSpacing.lg),
        Align(
          alignment: Alignment.centerLeft,
          child: WebTextTabs<_ProfileTab>(
            values: _ProfileTab.values,
            selected: _tab,
            labelOf: _tabLabel,
            onSelected: (tab) {
              if (tab == _tab) return;
              setState(() => _tab = tab);
              // 기록실은 처음 열 때 최신 시즌을 받아온다.
              if (tab == _ProfileTab.recordRoom && _vm.record == null && !_vm.isRecordLoading) {
                _vm.loadRecord(crewRecordSeasons().first.dbSeason);
              }
            },
          ),
        ),
        const SizedBox(height: SDSSpacing.lg),
        if (isHidden)
          const WebEmptyState(message: '프로필 비공개 유저입니다.')
        else
          switch (_tab) {
            _ProfileTab.stats => _StatsPane(
                key: const ValueKey('stats'),
                detail: detail,
                ownerName: info.displayName,
                ownerImageUrl: info.profileImageUrlUser,
                // 목업: 넓은 폭에서는 파란 바 왼쪽에 `내 랭킹`.
                leadingLabel: '내 랭킹',
              ),
            _ProfileTab.guestbook => _buildGuestbook(talkCount),
            _ProfileTab.recordRoom => _buildRecordRoom(info),
          },
      ],
    );
  }

  String _tabLabel(_ProfileTab tab) => switch (tab) {
        _ProfileTab.stats => '라이딩 통계',
        _ProfileTab.guestbook => '방명록',
        // 남의 프로필에서도 어색하지 않게 `내`를 뺀다(사용자 지시).
        _ProfileTab.recordRoom => '시즌 기록실',
      };

  Widget? _buildHeaderAction() {
    // 모바일 목업에는 버튼이 없다(프로필 팝업에 이미 있다).
    if (context.screenType == WebScreenType.mobile) return null;
    // 자동로그인 확인 중에는 판단할 근거가 없다 → 잘못된 버튼을 띄우지 않는다.
    if (_authVm.status == WebAuthStatus.checking) return null;
    if (_vm.isMe) return null;
    // 비로그인 방문자에게도 버튼을 보여주고, 누르면 로그인 화면으로 보낸다(사용자 지시).
    if (!_vm.isLoggedIn) {
      return _HeaderPill(
        label: '친구 추가',
        onTap: () => Get.toNamed(WebRoutes.login),
      );
    }
    // 이미 친구거나 요청을 보냈으면 누를 것이 없다 → 버튼이 아니라 표시로 그린다.
    if (_vm.areWeFriend) return const WebProfileStateBadge(label: '친구', isPositive: true);
    if (_requestSent) return const WebProfileStateBadge(label: '요청 보냄');
    return _HeaderPill(
      label: _isSendingRequest ? '요청 중…' : '친구 추가',
      onTap: _isSendingRequest ? null : _sendFriendRequest,
    );
  }

  // ===== 방명록 =====

  Widget _buildGuestbook(int talkCount) {
    final isMobile = context.screenType == WebScreenType.mobile;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 모바일은 입력줄이 하단에 고정된다(목업) → 여기서는 그리지 않는다.
        if (!isMobile) ...[
          _buildGuestbookInput(),
          const SizedBox(height: SDSSpacing.lg),
        ],
        ProfileGuestbookListWeb(
          talks: _vm.talks,
          canDelete: (talk) => talk.authorUserId == _vm.myUserId || _vm.isMe,
          canReport: (talk) => _vm.isLoggedIn && talk.authorUserId != _vm.myUserId,
          onDelete: (talk) async {
            final ok = await _vm.deleteGuestbook(
              talkId: talk.friendsTalkId,
              authorUserId: talk.authorUserId,
            );
            if (ok) await _vm.refreshTalks();
            return ok;
          },
          onReport: (talk) =>
              mapWebActionResponse(() => _vm.reportGuestbook(talk.friendsTalkId)),
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
      onLockedTap: () {
        final message = _guestbookLockedMessage();
        if (message != null) _toast(message);
      },
    );
  }

  String? _guestbookLockedMessage() {
    if (_vm.isMe || _vm.canWriteGuestbook) return null;
    if (!_vm.isLoggedIn) return '로그인이 필요해요.';
    return '안부 인사를 남기기 위해서는 먼저 친구가 되어야해요.';
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

class _HeaderPill extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const _HeaderPill({required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: SDSColor.gray200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        label,
        style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
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

  String _label(RankingFilter_season season) => '${season.korean.replaceAll('시즌', '')} 시즌 랭킹';

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
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _label(current),
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: widget.color),
              ),
              const SizedBox(width: 2),
              Icon(Icons.expand_more, size: 18, color: widget.color),
            ],
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
    final key = '${_month.year}-${_month.month.toString().padLeft(2, '0')}'
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
    final hasRecord = season.overallTotalCount > 0 || season.countInfo.isNotEmpty;

    if (!hasRecord) {
      return const WebEmptyState(message: '아직 라이딩 기록이 없어요');
    }

    final leading = widget.seasonSelectorBuilder?.call(SDSColor.snowliveWhite) ??
        (widget.leadingLabel == null
            ? null
            : Text(
                widget.leadingLabel!,
                style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
              ));

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
          const SizedBox(height: 12),
        ],
        ProfileRankBarWeb(
          leading: leading,
          score: season.overallTotalScore,
          rank: season.overallRank,
          tierName: season.tierNameKor,
          tierIconUrl: season.overallTierIconUrl,
        ),
        const SizedBox(height: SDSSpacing.lg),
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
          const SizedBox(height: SDSSpacing.xl),
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
        const SizedBox(height: SDSSpacing.xl),
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

  const _ModePill({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? SDSColor.snowliveBlack : SDSColor.snowliveWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isActive ? SDSColor.snowliveBlack : SDSColor.gray200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            label,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 13,
              color: isActive ? SDSColor.snowliveWhite : SDSColor.gray900,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 56, radius: 10),
        SizedBox(height: SDSSpacing.lg),
        SkeletonBox(height: 20, radius: 6),
        SizedBox(height: SDSSpacing.lg),
        _ProfileStatsSkeleton(),
      ],
    );
  }
}

class _ProfileStatsSkeleton extends StatelessWidget {
  const _ProfileStatsSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(height: 64, radius: 10),
        SizedBox(height: SDSSpacing.lg),
        SkeletonBox(height: 240, radius: 10),
      ],
    );
  }
}
