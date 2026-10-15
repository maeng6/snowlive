import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/widget/w_web_page_header_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 모바일 하단 고정 버튼 영역 높이(패딩 8+16 + 버튼 48).
const double _kMobileBarHeight = 72;

/// 크루 설정 화면들이 공유하는 골격.
///
/// 셸(WebAppShell)이 이미 상단바·사이드바를 그리므로 자체 `Scaffold`/`AppBar`는 두지 않는다.
/// 진행 버튼은 폭에 따라 자리가 바뀐다(다른 웹 화면들과 같은 규칙) —
/// 데스크탑·태블릿은 **제목 줄 우측**, 모바일은 **하단 고정 전체폭**.
class CrewSettingScaffoldWeb extends StatelessWidget {
  final String title;
  final Widget child;

  /// 우상단(모바일은 하단)에 놓을 진행 버튼 라벨. null이면 버튼이 없는 화면이다.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// 저장 중이면 버튼 라벨 **앞에 스피너**를 끼운다(커뮤니티 글쓰기와 같은 처리).
  /// 라벨을 스피너로 바꾸지 않는 이유는 버튼 폭이 튀기 때문이다.
  ///
  /// ⚠️ 이 화면들의 `build`는 `Obx` 안이 아니라서 **bool로 받으면 다시 안 그려진다**
  /// → Rx를 그대로 받아 **버튼만** 구독한다(커뮤니티도 버튼만 Obx로 감쌌다).
  final RxBool? submitting;

  /// 뒤로 갈 화면이 없을 때(URL 직접 진입) 갈 곳.
  final String fallbackRoute;

  /// 제목 왼쪽 뒤로가기 화살표를 그릴지. 허브는 그리지 않는다(목업).
  final bool showBack;

  const CrewSettingScaffoldWeb({
    super.key,
    required this.title,
    required this.child,
    required this.fallbackRoute,
    this.actionLabel,
    this.onAction,
    this.submitting,
    this.showBack = false,
  });

  void _goBack(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    Get.offAllNamed(fallbackRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final hasAction = actionLabel != null;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      child: SingleChildScrollView(
        // ⚠️ 페이지 여백은 **스크롤 영역 안쪽**에 둔다(웹 공통) — 바깥 Container에
        // 주면 스크롤바가 여백 안쪽에 생겨 브라우저 오른쪽 끝에 붙지 않는다.
        // 서브 페이지 공통 여백(중고거래 상세·폼 기준) + 모바일 하단바 확보.
        padding: webSubPagePadding(
          context,
          bottom: isMobile && hasAction ? _kMobileBarHeight : SDSSpacing.xl,
        ),
        child: Center(
          child: ConstrainedBox(
            // 블록 폭 제한은 **PC만** — 태블릿·모바일은 좌우 여백(20/16)만 두고 꽉
            // 채운다(웹 공통). 상한을 그대로 두면 폭이 넓은 태블릿에서 가운데 정렬
            // 때문에 여백이 20보다 넓어진다(기록 스캐폴드와 같은 처리).
            constraints: BoxConstraints(
              maxWidth: context.isDesktop ? kWebSubPageMaxWidth : double.infinity,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 서브 페이지 공통 헤더(뒤로 30 + 12 + bold 30).
                WebPageHeader(
                  title: title,
                  onBack: () => _goBack(context),
                  showBack: showBack,
                  // 크루 설정 계열은 사이드바에 진입점이 없다 — 새 탭·새로고침으로
                  // 들어오면 브라우저 뒤로가기도 갈 곳이 없어 PC에도 남긴다.
                  showBackOnDesktop: true,
                  actions: [
                    if (hasAction && !isMobile) _buildActionButton(fullWidth: false),
                  ],
                ),
                // 헤더 ↔ 본문 42 (목업 174:86001 — 타이틀 끝 151, 목록 193).
                const SizedBox(height: 42),
                child,
              ],
            ),
          ),
        ),
      ),
    );

    if (!isMobile || !hasAction) return scrollArea;

    // 콘텐츠가 짧으면 스크롤 영역이 뷰포트를 못 채워 셸의 표면색이 하단에 배어 나온다
    // → 스택 전체에 흰 배경을 깔아 막는다(크루 만들기에서 겪은 것과 같은 처리).
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
              padding: const EdgeInsets.fromLTRB(
                  SDSSpacing.md, SDSSpacing.sm, SDSSpacing.md, SDSSpacing.md),
              child: _buildActionButton(fullWidth: true),
            ),
          ),
        ],
      ),
    );
  }

  /// 진행 버튼 — **커뮤니티 글쓰기·중고거래 올리기와 같은 규격**(그쪽에서 확정한 값).
  /// 헤더(PC·태블릿): 높이 40 · 좌우 16 · 라운드 5 · Bold 16.
  /// 하단 바(모바일): 높이 48 · 전체폭 · 라운드 6 · Bold 15.
  /// 비활성은 **gray200 배경 + 흰 글자**(gray300이 아니다 — 중고거래 `판매하기` 기준).
  Widget _buildActionButton({required bool fullWidth}) {
    final rx = submitting;
    if (rx == null) return _actionButton(fullWidth: fullWidth, isSubmitting: false);
    return Obx(() => _actionButton(fullWidth: fullWidth, isSubmitting: rx.value));
  }

  Widget _actionButton({required bool fullWidth, required bool isSubmitting}) {
    final button = ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray200,
        elevation: 0,
        shadowColor: Colors.transparent,
        overlayColor: Colors.transparent,
        minimumSize:
            fullWidth ? const Size(double.infinity, 48) : const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fullWidth ? 6 : 5),
        ),
      ),
      // 라벨을 스피너로 "교체"하면 버튼 폭이 튀므로, 라벨은 두고 앞에 끼워 넣는다.
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSubmitting) ...[
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(SDSColor.snowliveWhite),
              ),
            ),
            const SizedBox(width: SDSSpacing.sm),
          ],
          Text(
            actionLabel!,
            // 비활성도 흰 글자(gray200 배경) — 중고거래 판매하기와 동일.
            style: SDSTextStyle.bold.copyWith(
              fontSize: fullWidth ? 15 : 16,
              color: SDSColor.snowliveWhite,
            ),
          ),
        ],
      ),
    );
    // visualDensity(웹 기본 compact)가 minimumSize 높이를 깎으므로 강제한다.
    return SizedBox(height: fullWidth ? 48 : 40, child: button);
  }
}

/// 크루 설정 화면들의 공통 진입 판정 — 로그인 + 크루원 여부.
/// 권한이 없으면 본문 대신 이 안내를 그린다.
class CrewSettingGuard extends StatelessWidget {
  final bool isLoggedIn;
  final bool canOpen;
  final Widget child;

  const CrewSettingGuard({
    super.key,
    required this.isLoggedIn,
    required this.canOpen,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return _Message(
        message: '로그인이 필요해요.',
        actionLabel: '로그인하기',
        onAction: () => Get.toNamed(WebRoutes.login),
      );
    }
    if (!canOpen) {
      return const _Message(message: '이 크루를 관리할 권한이 없어요.');
    }
    return child;
  }
}

class _Message extends StatelessWidget {
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Message({required this.message, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Text(
            message,
            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
          ),
          if (actionLabel != null) ...[
            const SizedBox(height: SDSSpacing.md),
            OutlinedButton(
              onPressed: onAction,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: SDSColor.gray200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: Text(
                actionLabel!,
                style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
