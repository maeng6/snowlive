import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';

/// 목록이 비었을 때 쓰는 공용 빈 상태.
///
/// 기존엔 중고거래는 아이콘+문구, 랭킹은 문구만 쓰는 등 화면마다 달랐다.
/// 중고거래 그리드의 스타일(아이콘 + 회색 문구)을 기준으로 통일한다.
class WebEmptyState extends StatelessWidget {
  final String message;
  final String iconAsset;

  /// 있으면 문구 아래에 버튼을 하나 그린다(예: '중고거래 목록으로').
  final String? actionLabel;
  final VoidCallback? onAction;

  /// 아이콘 폭. 기본 64는 정사각 에셋 기준이다.
  final double iconWidth;

  /// 비정사각 에셋(친구 화면의 스마일 등)은 `contain`으로 넣어야 찌그러지지 않는다.
  final BoxFit iconFit;

  const WebEmptyState({
    super.key,
    required this.message,
    this.iconAsset = 'assets/imgs/icons/icon_nodata.png',
    this.actionLabel,
    this.onAction,
    this.iconWidth = 64,
    this.iconFit = BoxFit.fill,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 정사각 에셋 기준이므로 높이도 iconWidth를 따라간다(높이 고정 시 fill에서 찌그러짐).
            Image.asset(iconAsset, width: iconWidth, height: iconWidth, fit: iconFit),
            // 목업(218:67694) — 아이콘 ↔ 문구 10.
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              // 목업 — Regular 14, 줄높이 20, #666(gray600).
              style: SDSTextStyle.regular
                  .copyWith(fontSize: 14, height: 20 / 14, color: SDSColor.gray600),
            ),
            if (actionLabel != null && onAction != null) ...[
              // 문구 ↔ 버튼 16 (목업).
              const SizedBox(height: SDSSpacing.md),
              // 목업(218:67785) — 흰 알약 버튼. 높이 34 = 상하 9 + 글줄 16,
              // 좌우 12 · 라운드 20 · 테두리 gray200 · ExtraBold 13 gray900.
              // 라인 버튼 hover는 웹 공통 — 테두리·글자는 그대로, 면이 gray50이 된다.
              OutlinedButton(
                onPressed: onAction,
                style: ButtonStyle(
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                  animationDuration: Duration.zero,
                  side: WidgetStatePropertyAll(BorderSide(color: SDSColor.gray200)),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.hovered)
                        ? SDSColor.gray50
                        : SDSColor.snowliveWhite,
                  ),
                  padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 12, vertical: 9)),
                  minimumSize: const WidgetStatePropertyAll(Size.zero),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  // 웹 기본 compact density가 최소 크기를 깎지 않게 표준으로 못 박는다.
                  visualDensity: VisualDensity.standard,
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 13, height: 16 / 13, color: SDSColor.gray900),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 조회가 **실패**했을 때 쓰는 상태. "데이터 없음"과 구분해서 보여줘야
/// 사용자가 다시 시도할 수 있다(빈 상태만 보여주면 실패인지 알 수 없다).
class WebErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const WebErrorState({
    super.key,
    this.message = '정보를 불러오지 못했어요.',
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return WebEmptyState(
      message: message,
      actionLabel: '다시 시도',
      onAction: onRetry,
    );
  }
}
