import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 목업 실측 800(설정 폼·목록이 한 열로 눕는다).
const double kCrewSettingContentMaxWidth = 800;

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
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;
    final hasAction = actionLabel != null;

    final scrollArea = Container(
      color: SDSColor.snowliveWhite,
      padding: EdgeInsets.fromLTRB(
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        32,
        isDesktop ? SDSSpacing.xl : SDSSpacing.md,
        isMobile && hasAction ? _kMobileBarHeight : SDSSpacing.xl,
      ),
      child: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kCrewSettingContentMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (showBack) ...[
                      InkWell(
                        onTap: () => _goBack(context),
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.arrow_back, size: 24, color: SDSColor.gray900),
                        ),
                      ),
                      const SizedBox(width: SDSSpacing.sm),
                    ],
                    Expanded(
                      child: Text(
                        title,
                        style: SDSTextStyle.extraBold
                            .copyWith(fontSize: 28, color: SDSColor.gray900),
                      ),
                    ),
                    if (hasAction && !isMobile) _buildActionButton(fullWidth: false),
                  ],
                ),
                const SizedBox(height: SDSSpacing.xl),
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

  Widget _buildActionButton({required bool fullWidth}) {
    return ElevatedButton(
      onPressed: onAction,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.snowliveBlue,
        disabledBackgroundColor: SDSColor.gray300,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: fullWidth ? 0 : 24, vertical: 13),
        minimumSize: fullWidth ? const Size(double.infinity, 48) : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(
        actionLabel!,
        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.snowliveWhite),
      ),
    );
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
