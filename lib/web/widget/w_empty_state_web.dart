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

  const WebEmptyState({
    super.key,
    required this.message,
    this.iconAsset = 'assets/imgs/icons/icon_nodata.png',
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(iconAsset, width: 64, height: 64),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SDSSpacing.lg),
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: SDSColor.gray200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  actionLabel!,
                  style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
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
