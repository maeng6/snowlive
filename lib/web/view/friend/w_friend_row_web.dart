import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:flutter/material.dart';

/// 친구 화면 4종이 공유하는 사람 한 줄.
///
/// `아바타 / 닉네임 / 상태메시지` 는 같고 **우측만 화면마다 다르다**
/// (`···` 더보기 / `친구 추가`·`거절` / `요청 취소` / `차단 해제`) → [trailing] 슬롯으로 받는다.
class FriendRowWeb extends StatelessWidget {
  final String? avatarUrl;
  final String name;

  /// 비어 있으면 줄을 만들지 않는다(목업에서 상태메시지 없는 유저는 한 줄로 보인다).
  final String? stateMsg;

  final Widget? trailing;

  /// 행 전체 탭(프로필 팝업). null이면 탭을 받지 않는다.
  final VoidCallback? onTap;

  const FriendRowWeb({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.stateMsg,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasStateMsg = stateMsg?.isNotEmpty ?? false;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            WebAvatar(url: avatarUrl, size: 40),
            const SizedBox(width: SDSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                  ),
                  if (hasStateMsg) ...[
                    const SizedBox(height: 2),
                    Text(
                      stateMsg!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: SDSSpacing.sm),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// 행 우측의 회색 알약 액션 버튼(`친구 추가` / `요청 취소` / `차단 해제` / `거절`).
class FriendRowActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  /// 거절처럼 되돌릴 수 없는 동작은 글자를 빨갛게 둔다.
  final bool isDestructive;

  const FriendRowActionButton({
    super.key,
    required this.label,
    this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SDSColor.gray50,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            maxLines: 1,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 13,
              color: isDestructive ? SDSColor.red : SDSColor.gray900,
            ),
          ),
        ),
      ),
    );
  }
}
