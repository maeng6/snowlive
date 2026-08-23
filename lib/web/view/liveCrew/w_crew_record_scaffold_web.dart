import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// 기록 화면들이 공유하는 골격. 셸(WebAppShell)이 상단바·사이드바를 그리므로
/// 자체 `Scaffold`/`AppBar`는 두지 않는다(다른 크루 하위 화면과 동일).
class CrewRecordScaffoldWeb extends StatelessWidget {
  final String title;
  final Widget child;
  final double maxWidth;

  /// 뒤로 갈 화면이 없을 때(URL 직접 진입) 갈 곳.
  final String fallbackRoute;

  const CrewRecordScaffoldWeb({
    super.key,
    required this.title,
    required this.child,
    required this.fallbackRoute,
    this.maxWidth = 1136,
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
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => _goBack(context),
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(Icons.arrow_back, size: 24, color: SDSColor.gray900),
                      ),
                    ),
                    const SizedBox(width: SDSSpacing.sm),
                    Expanded(
                      child: Text(
                        title,
                        style: SDSTextStyle.extraBold
                            .copyWith(fontSize: isDesktop ? 28 : 22, color: SDSColor.gray900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SDSSpacing.lg),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
