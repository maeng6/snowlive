import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:flutter/material.dart';

/// 프로필 미리보기 카드에 필요한 값만 담은 VO.
///
/// 랭킹(`RankingUser`)과 친구 상세(`FriendDetailModel`)는 같은 정보를 **다른 필드명**으로
/// 갖고 있다(리조트가 `resort_nickname` vs `favorite_resort`). 카드가 두 모델을 다 알면
/// 지저분해지므로 호출자가 이 VO로 변환해서 넘긴다.
class WebProfileCardData {
  final int? userId;
  final String? avatarUrl;
  final String? displayName;
  final String? resortName;
  final String? crewName;

  /// 랭킹 응답에는 없다(모델에 `state_msg`가 없음) → null이면 줄을 그리지 않는다.
  final String? stateMsg;

  const WebProfileCardData({
    this.userId,
    this.avatarUrl,
    this.displayName,
    this.resortName,
    this.crewName,
    this.stateMsg,
  });

  /// `휘닉스파크 · ALLDOMAN`. 한쪽만 있으면 구분점 없이 그것만, 둘 다 없으면 빈 문자열.
  String get affiliationLine => [
        if (resortName?.isNotEmpty ?? false) resortName!,
        if (crewName?.isNotEmpty ?? false) crewName!,
      ].join(' · ');
}

/// 프로필 미리보기 카드 본문.
///
/// 랭킹 목록과 친구 목록이 같은 카드를 쓴다. 팝업 호스트(중앙 모달 / 바텀시트)는
/// 호출자가 정하고, 이 위젯은 **카드 내용만** 그린다.
///
/// ⚠️ Overlay에 직접 꽂히는 구조라 Dialog가 주던 `Material` 조상이 없다 →
/// 카드 표면을 `Material`이 직접 칠하게 한다. 안 그러면 안쪽 `InkWell`이
/// "No Material widget found"로 죽는다.
class WebProfileCard extends StatelessWidget {
  final WebProfileCardData data;

  /// null이면 액션 버튼을 그리지 않는다(자기 자신을 볼 때 등).
  final Widget? action;

  /// 하단 전체폭 버튼. null이면 안 그린다.
  final Widget? footer;

  /// 우상단 닫기 버튼. 바텀시트에서는 드래그 핸들을 쓰므로 null로 둔다.
  final VoidCallback? onClose;

  /// 바텀시트는 상단 라운드만 두고 폭을 화면에 맡긴다.
  final bool isSheet;

  const WebProfileCard({
    super.key,
    required this.data,
    this.action,
    this.footer,
    this.onClose,
    this.isSheet = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Material(
      color: SDSColor.snowliveWhite,
      borderRadius: isSheet
          ? const BorderRadius.vertical(top: Radius.circular(20))
          : BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: isSheet ? double.infinity : 340,
        padding: const EdgeInsets.all(SDSSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSheet)
              // 목업 모바일은 닫기 X 대신 드래그 핸들이다.
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: SDSSpacing.md),
                decoration: BoxDecoration(
                  color: SDSColor.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            else if (onClose != null)
              // 닫기 버튼은 자리를 차지하게 둔다. 크기 없는 Stack에 음수 Positioned를
              // 주면 Stack의 기본 clipBehavior(hardEdge)에 잘려 아예 안 보인다.
              Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: onClose,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(Icons.close, size: 20, color: SDSColor.gray400),
                  ),
                ),
              ),
            WebAvatar(url: data.avatarUrl, size: 88),
            const SizedBox(height: SDSSpacing.md),
            Text(
              data.displayName ?? '',
              style: SDSTextStyle.bold.copyWith(fontSize: 18, color: SDSColor.gray900),
            ),
            if (data.affiliationLine.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                data.affiliationLine,
                style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray500),
              ),
            ],
            if (data.stateMsg?.isNotEmpty ?? false) ...[
              const SizedBox(height: 4),
              Text(
                data.stateMsg!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray400),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: SDSSpacing.md),
              action!,
            ],
            // 점수·통합랭킹·티어 3분할은 뺐다(요청). 카드는 신원 + 하단 버튼만 남긴다.
            if (footer != null) ...[
              const SizedBox(height: SDSSpacing.lg),
              SizedBox(width: double.infinity, child: footer!),
            ],
          ],
        ),
      ),
    );

    // 짧은 뷰포트에서 카드가 넘치면 스크롤되게 한다.
    return SingleChildScrollView(child: card);
  }
}

/// 프로필 카드의 알약 액션 버튼(`친구 추가` 등).
class WebProfilePillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const WebProfilePillButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: SDSColor.gray200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900)),
    );
  }
}

/// 프로필 카드 하단의 전체폭 회색 버튼(`프로필 보러가기`).
class WebProfileFooterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  const WebProfileFooterButton({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: SDSColor.gray50,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray700)),
    );
  }
}
