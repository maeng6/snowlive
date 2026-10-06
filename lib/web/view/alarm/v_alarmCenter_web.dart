import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_alarmCenterList.dart';
import 'package:com.snowlive/core/util/util_1.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/viewmodel/alarm/vm_alarmCenter_web.dart';
import 'package:com.snowlive/web/viewmodel/auth/vm_authcheck_web.dart';
import 'package:com.snowlive/web/widget/w_empty_state_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:com.snowlive/web/widget/w_web_toast_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 알림 목록 폭 — 설정 화면과 같은 좌측 정렬 한 열.
const double _kListMaxWidth = 600;

/// 스크롤이 바닥에서 이만큼 남으면 다음 페이지를 부른다.
const double _kLoadMoreExtent = 300;

/// 종류별 아이콘(앱 알림센터와 같은 에셋).
const Map<int, String> _kKindIcons = {
  AlarmKind.friendRequest: 'assets/imgs/icons/icon_moretab_friends.png',
  AlarmKind.guestbook: 'assets/imgs/icons/icon_moretab_bubble.png',
  AlarmKind.crewApply: 'assets/imgs/icons/icon_moretab_team.png',
  AlarmKind.fleamarketComment: 'assets/imgs/icons/icon_moretab_flea.png',
  AlarmKind.communityComment: 'assets/imgs/icons/icon_moretab_comm.png',
  AlarmKind.reply: 'assets/imgs/icons/icon_moretab_reply.png',
};

/// 웹 알림센터. `#/alarm`
///
/// 목업이 아직 없어 **앱 알림센터와 같은 정보**를 설정 화면과 같은 틀(흰 배경, 좌측 정렬
/// 한 열, 태블릿·모바일은 `← 알림`)에 담았다.
///
/// 줄: 종류 아이콘 + `종류명 · n분 전` / `닉네임 + 알림 문구` / 본문 미리보기.
/// 읽은 알림은 흐리게(앱과 같은 규칙). 앱의 스와이프 삭제 대신 줄 우측 `✕`
/// (데스크탑은 hover 때만, 터치 폭은 항상). 누르면 읽음 처리 후 해당 화면으로 간다.
class AlarmCenterViewWeb extends StatefulWidget {
  const AlarmCenterViewWeb({super.key});

  @override
  State<AlarmCenterViewWeb> createState() => _AlarmCenterViewWebState();
}

class _AlarmCenterViewWebState extends State<AlarmCenterViewWeb> {
  final AlarmCenterViewModelWeb _vm = Get.find<AlarmCenterViewModelWeb>();

  /// 자동로그인 확인이 늦게 끝나면 그때 다시 부른다. 테스트처럼 인증 VM이 없는
  /// 환경에서는 UserViewModel의 user_id만 본다.
  AuthCheckViewModelWeb? get _authVm =>
      Get.isRegistered<AuthCheckViewModelWeb>() ? Get.find<AuthCheckViewModelWeb>() : null;
  Worker? _authWorker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
    final auth = _authVm;
    if (auth != null) {
      _authWorker = ever<WebAuthStatus>(auth.statusRx, (status) {
        if (status == WebAuthStatus.authenticated) _load();
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _authWorker?.dispose();
    super.dispose();
  }

  void _load() {
    if (_vm.myUserId == null) return;
    _vm.refreshList();
    _vm.clearBadge();
  }

  bool get _isGuest {
    final auth = _authVm;
    if (auth != null) return auth.status == WebAuthStatus.unauthenticated;
    return _vm.myUserId == null;
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

  void _onTap(AlarmCenterModel alarm) {
    final target = alarmTapTarget(alarm, myUserId: _vm.myUserId, myCrewId: _vm.myCrewId);
    // 이동과 읽음 처리는 기다리지 않고 함께 — 앱도 이동 뒤에 읽음을 보낸다.
    _vm.markRead(alarm);
    if (target.route != null) {
      Get.toNamed(target.route!);
    } else if (target.message != null) {
      _toast(target.message!);
    }
  }

  Future<void> _onDelete(AlarmCenterModel alarm) async {
    final ok = await _vm.delete(alarm);
    if (!mounted) return;
    _toast(ok ? '알림을 삭제했어요.' : '잠시 후 다시 시도해 주세요.');
  }

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.extentAfter < _kLoadMoreExtent) _vm.loadMore();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;

    return ColoredBox(
      color: SDSColor.snowliveWhite,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: SingleChildScrollView(
          padding: webSubPagePadding(context),
          child: Align(
            alignment: Alignment.topLeft,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kListMaxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WebPageHeader(
                    title: '알림',
                    onBack: () => Get.back(),
                    showBack: !isDesktop,
                  ),
                  SizedBox(height: isMobile ? SDSSpacing.lg : SDSSpacing.xl),
                  _buildBody(),
                  const SizedBox(height: SDSSpacing.xxl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isGuest) {
      return WebEmptyState(
        message: '로그인이 필요해요.',
        actionLabel: '로그인하기',
        onAction: () => Get.toNamed(WebRoutes.login),
      );
    }
    return Obx(() {
      final items = _vm.items;
      final isLoaded = _vm.isLoaded;
      final hasError = _vm.hasError;
      final isLoadingMore = _vm.isLoadingMore;

      if (!isLoaded) {
        if (hasError) {
          return WebEmptyState(
            message: '알림을 불러오지 못했어요.',
            actionLabel: '다시 시도',
            onAction: _vm.refreshList,
          );
        }
        return const _AlarmListSkeleton();
      }
      if (items.isEmpty) return const WebEmptyState(message: '알림이 없어요.');

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final alarm in items)
            AlarmRowWeb(
              key: ValueKey(alarm.alarmCenterId),
              alarm: alarm,
              onTap: () => _onTap(alarm),
              onDelete: () => _onDelete(alarm),
            ),
          if (isLoadingMore)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: SDSSpacing.lg),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: SDSColor.gray300),
                ),
              ),
            ),
        ],
      );
    });
  }
}

/// 알림 한 줄.
class AlarmRowWeb extends StatefulWidget {
  final AlarmCenterModel alarm;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const AlarmRowWeb({
    super.key,
    required this.alarm,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<AlarmRowWeb> createState() => _AlarmRowWebState();
}

class _AlarmRowWebState extends State<AlarmRowWeb> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final alarm = widget.alarm;
    // 데스크탑은 hover 때만 `✕`, 터치 폭은 hover가 없어 항상 보인다.
    final showDelete = !context.isDesktop || _hovered;
    final icon = _kKindIcons[alarm.alarmInfo.alarmInfoId];
    final textMain = alarm.textMain?.trim() ?? '';
    final textSub = alarm.textSub?.trim() ?? '';

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: SizedBox(
            width: 26,
            height: 26,
            child: icon == null ? null : Image.asset(icon, width: 26),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      alarm.alarmInfo.alarmInfoName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    TimeStamp().getAgo(alarm.date),
                    style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: alarm.otherUserInfo.displayName),
                  TextSpan(text: alarm.alarmInfo.alarmText),
                ]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray900),
              ),
              if (textMain.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    textMain,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                  ),
                ),
              if (textSub.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    ': $textSub',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: SDSSpacing.sm),
        // 자리는 항상 잡아 두고 보이기만 바꾼다(hover 때 글줄이 밀리지 않게).
        Visibility(
          visible: showDelete,
          maintainSize: true,
          maintainAnimation: true,
          maintainState: true,
          child: WebIconButton(
            icon: const Icon(Icons.close, size: 18, color: SDSColor.gray400),
            tooltip: '삭제',
            onTap: showDelete ? widget.onDelete : null,
          ),
        ),
      ],
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          padding: const EdgeInsets.symmetric(horizontal: SDSSpacing.sm, vertical: 14),
          decoration: BoxDecoration(
            color: _hovered ? SDSColor.gray50 : null,
            borderRadius: BorderRadius.circular(8),
          ),
          // 읽은 알림은 흐리게 — 앱은 흰 70% 막을 덮는다(= 불투명도 0.3).
          child: Opacity(opacity: alarm.active ? 1 : 0.3, child: content),
        ),
      ),
    );
  }
}

/// 첫 페이지를 받기 전 자리 — 알림 줄 모양 5개.
class _AlarmListSkeleton extends StatelessWidget {
  const _AlarmListSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Column(
        children: [
          for (var i = 0; i < 5; i++)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: SDSSpacing.sm, vertical: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonBox(width: 26, height: 26, isCircle: true),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonBox(width: 120, height: 16),
                        SizedBox(height: 6),
                        SkeletonBox(height: 14),
                        SizedBox(height: 6),
                        SkeletonBox(width: 200, height: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
