import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/crew_visual_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:com.snowlive/web/widget/w_web_profile_tap_web.dart';
import 'package:flutter/material.dart';

/// 프로필 미리보기 카드에 필요한 값만 담은 VO.
///
/// 랭킹(`RankingUser`)과 친구 상세(`FriendDetailModel`)는 같은 정보를 **다른 필드명**으로
/// 갖고 있다(리조트가 `resort_nickname` vs `favorite_resort`). 카드가 두 모델을 다 알면
/// 지저분해지므로 호출자가 이 VO로 변환해서 넘긴다.
/// 멤버 수 줄의 고정 높이(Bold 14의 줄 상자). 값이 늦게 와도 카드가 안 커지게
/// 자리를 먼저 잡아 둔다.
const double _kExtraLineHeight = 18;

class WebProfileCardData {
  final int? userId;
  final String? avatarUrl;
  final String? displayName;
  final String? resortName;
  final String? crewName;

  /// 랭킹 응답에는 없다(모델에 `state_msg`가 없음) → null이면 줄을 그리지 않는다.
  /// 크루 팝업에서는 크루 소개글이 이 자리에 온다.
  final String? stateMsg;

  /// 아바타 모양. null이면 원형(유저), 값을 주면 그 라운드의 사각(크루 로고).
  final double? avatarRadius;

  /// 아바타 한 변. 유저 82 / 크루 72 (목업).
  final double avatarSize;

  /// 소속 줄 **아래, 소개글 위**에 들어가는 한 줄(크루 팝업의 `24명`).
  /// null이면 줄을 그리지 않는다.
  final String? extraLine;

  /// 줄 사이를 한 단계 좁힌다(크루 팝업 — 줄이 더 많아 목업 간격이 성기어 보인다).
  /// 이름↔소속·소속↔멤버수 6 → 4, 그 아래 소개글 12 → 8.
  final bool compactLines;

  /// [extraLine] 값이 **나중에 오는** 경우(크루 가입하기 — 멤버 수는 상세 API에서
  /// 온다) true로 둔다. 그 줄 자리를 **미리 비워 두고** 스켈레톤을 깔아서, 값이
  /// 도착해도 카드 높이가 변하지 않는다(열린 뒤 팝업이 커지는 것을 막는다).
  final bool isExtraLineLoading;

  const WebProfileCardData({
    this.userId,
    this.avatarUrl,
    this.displayName,
    this.resortName,
    this.crewName,
    this.stateMsg,
    this.avatarRadius,
    this.avatarSize = 82,
    this.extraLine,
    this.compactLines = false,
    this.isExtraLineLoading = false,
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

  /// 유저는 원형 아바타, 크루는 라운드 사각 로고. 둘 다 누르면 확대된다.
  Widget _avatar(BuildContext context) {
    final onTap = (data.avatarUrl?.isNotEmpty ?? false)
        ? () => showWebPhotoViewer(
              context,
              url: data.avatarUrl,
              title: data.displayName ?? '',
            )
        : null;
    // 크루 로고 라운드는 **한 변의 0.2**(공용 비율). 호출자가 값을 주면 그걸 쓴다.
    final radius = data.avatarRadius == null ? null : crewLogoRadius(data.avatarSize);
    if (radius == null) {
      return WebAvatar(url: data.avatarUrl, size: data.avatarSize, onTap: onTap);
    }
    return WebProfileTap(
      onTap: onTap,
      child: Container(
        width: data.avatarSize,
        height: data.avatarSize,
        decoration: BoxDecoration(
          color: SDSColor.gray100,
          borderRadius: BorderRadius.circular(radius),
          // 기본 크루 마크는 **흰 카드** 이미지라 테두리가 없으면 흰 팝업 배경에
          // 묻혀 경계가 안 보인다(목록 행과 같은 gray100 선을 두른다).
          border: Border.all(color: SDSColor.gray100),
        ),
        clipBehavior: Clip.antiAlias,
        child: (data.avatarUrl?.isNotEmpty ?? false)
            ? WebNetworkImage(
                url: data.avatarUrl, width: data.avatarSize, height: data.avatarSize)
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 목업(106:18082) 기준 — 라운드 16, 콘텐츠는 상단 50에서 시작하고 폭 248,
    // 콘텐츠 ↔ 하단 버튼 24, 버튼 영역 좌우 16 · 상하 10, 카드 하단 21.
    // 카드 폭만 목업 390 대신 **360**(사용자 확정) → 좌우 여백은 (360-248)/2 = 56.
    // 소개글이 없으면 이름 바로 아래가 버튼이라 목업 간격(20·24)이 과해 보인다.
    final hasStateMsg = data.stateMsg?.isNotEmpty ?? false;
    final lineGap = data.compactLines ? 4.0 : 6.0;
    final blockGap = data.compactLines ? 8.0 : 12.0;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 팝업 안의 사진도 누르면 확대된다(프로필 화면과 동일).
        _avatar(context),
        const SizedBox(height: 16),
        Text(
          data.displayName ?? '',
          textAlign: TextAlign.center,
          // 목업은 20이지만 커 보여 16으로 낮춘다(사용자 확정) — 유저 닉네임·크루명 공통.
          style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
        ),
        if (data.affiliationLine.isNotEmpty) ...[
          SizedBox(height: lineGap),
          Text(
            data.affiliationLine,
            textAlign: TextAlign.center,
            // 목업은 소속도 본문과 같은 검정(gray900)이다 — 회색은 상태메시지만.
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray900),
          ),
        ],
        if ((data.extraLine?.isNotEmpty ?? false) || data.isExtraLineLoading) ...[
          SizedBox(height: lineGap),
          // 글자 높이를 **못 박아** 로딩 중이든 값이 왔든 줄 높이가 같다.
          SizedBox(
            height: _kExtraLineHeight,
            child: (data.extraLine?.isNotEmpty ?? false)
                ? Text(
                    data.extraLine!,
                    textAlign: TextAlign.center,
                    // 목업은 12지만 멤버 수는 한눈에 보이는 값이라 14로 키웠다(사용자 확정).
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 14,
                      height: _kExtraLineHeight / 14,
                      color: SDSColor.gray900,
                    ),
                  )
                // 값이 오기 전에는 **빈 자리**만 잡아둔다(깜빡이는 자리표시 없이
                // 그대로 글자로 바뀐다).
                : const SizedBox.shrink(),
          ),
        ],
        if (data.stateMsg?.isNotEmpty ?? false) ...[
          SizedBox(height: blockGap),
          Text(
            data.stateMsg!,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
          ),
        ],
        if (action != null) ...[
          SizedBox(height: hasStateMsg ? 20 : 12),
          action!,
        ],
      ],
    );

    final card = Material(
      color: SDSColor.snowliveWhite,
      borderRadius: isSheet
          ? const BorderRadius.vertical(top: Radius.circular(20))
          : BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: isSheet ? double.infinity : 360,
        child: Stack(
          children: [
            // Stack 기본 정렬이 좌상단이라 폭을 꽉 채워야 내용이 가운데로 온다
            // (하단 버튼이 없는 호출자에서 왼쪽으로 쏠렸다).
            SizedBox(
              width: double.infinity,
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSheet)
                  // 목업 모바일은 닫기 X 대신 드래그 핸들이다.
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: SDSSpacing.md, bottom: SDSSpacing.lg),
                    decoration: BoxDecoration(
                      color: SDSColor.gray200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )
                else
                  const SizedBox(height: 50),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSheet ? SDSSpacing.lg : 56),
                  child: content,
                ),
                // 소개글이 없으면(비로그인이라 상세를 못 받았거나 빈 값) 이름 바로 아래가
                // 버튼이 되어 24가 과해 보인다 → 그때만 16으로 줄인다.
                SizedBox(height: hasStateMsg ? 24 : 16),
                // 점수·통합랭킹·티어 3분할은 뺐다. 카드는 신원 + 하단 버튼만 남긴다.
                if (footer != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: SizedBox(width: double.infinity, child: footer!),
                  ),
                SizedBox(height: footer != null ? 21 : 0),
              ],
              ),
            ),
            // 닫기 X — 목업은 26에 50% 불투명도, 우상단 16/16.
            if (!isSheet && onClose != null)
              Positioned(
                top: 16,
                right: 16,
                child: Opacity(
                  opacity: 0.5,
                  child: InkWell(
                    onTap: onClose,
                    customBorder: const CircleBorder(),
                    child: Icon(Icons.close, size: 26, color: SDSColor.gray900),
                  ),
                ),
              ),
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
    // 목업(106:18091) — 72×34. 패딩 12/9 + 글자 줄높이 16 = 34.
    // ⚠️ 줄높이를 안 묶으면 Pretendard가 17~18로 잡아 높이가 36으로 커지고,
    // 웹 기본 visualDensity도 버튼 높이를 건드려서 SizedBox로 겉에서 못 박는다.
    return SizedBox(
      height: 34,
      child: OutlinedButton(
      onPressed: onTap,
      // 흰 배경 · 테두리 gray200 · 라운드 20 · 패딩 12/9 · ExtraBold 13.
      // 라인 버튼 hover는 **면이 어두워진다**(흰 배경 → gray50) — 테두리·글자는 그대로.
      // 그림자·리플·전환 애니메이션은 쓰지 않는다.
      style: ButtonStyle(
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
        side: const WidgetStatePropertyAll(BorderSide(color: SDSColor.gray200)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 9)),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      child: Text(label,
          style: SDSTextStyle.extraBold
              .copyWith(fontSize: 13, height: 16 / 13, color: SDSColor.gray900)),
      ),
    );
  }
}

/// 누를 것이 없는 상태 표시(`친구`, `요청 보냄`).
///
/// 이미 친구인 사람에게 버튼 모양을 그리면 아직 추가할 수 있는 것처럼 보인다 →
/// 테두리 없는 배지로 구분한다. [isPositive]면 파랑, 아니면 회색.
class WebProfileStateBadge extends StatelessWidget {
  final String label;
  final bool isPositive;

  const WebProfileStateBadge({super.key, required this.label, this.isPositive = false});

  @override
  Widget build(BuildContext context) {
    // 같은 슬롯에 들어가므로 알약 버튼과 같은 높이(34)로 맞춘다.
    return Container(
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isPositive ? SDSColor.blue50 : SDSColor.gray50,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPositive) ...[
            Icon(Icons.check, size: 16, color: SDSColor.snowliveBlue),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: SDSTextStyle.extraBold.copyWith(
              fontSize: 13,
              height: 16 / 13,
              color: isPositive ? SDSColor.snowliveBlue : SDSColor.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 프로필 카드 하단의 전체폭 회색 버튼(`프로필 보러가기`).
class WebProfileFooterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;

  /// 기본은 연회색 보조 버튼. 파란 주 버튼으로 쓰려면 색을 넘긴다
  /// (크루 가입하기 팝업처럼 버튼이 둘인 경우).
  final Color background;
  final Color foreground;

  const WebProfileFooterButton({
    super.key,
    required this.label,
    this.onTap,
    this.background = SDSColor.gray50,
    this.foreground = SDSColor.gray900,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
      onPressed: onTap,
      // 목업(106:18119, comp_button) — 높이 48 · 라운드 5 · Bold 16.
      // ⚠️ 웹 기본 visualDensity가 높이를 깎으므로 SizedBox로 겉에서 못 박는다.
      // hover는 배경에 검정 블렌드 — 파란 버튼 10%, 연회색은 4%(10%는 너무 진하다).
      // 그림자·리플·전환 애니메이션 없음(웹 공통).
      style: ButtonStyle(
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        animationDuration: Duration.zero,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          // 연회색 버튼은 비활성이어도 색을 바꾸지 않는다(기존 동작 유지).
          if (states.contains(WidgetState.disabled) && background != SDSColor.gray50) {
            return SDSColor.gray300;
          }
          if (!states.contains(WidgetState.hovered)) return background;
          final tint = background == SDSColor.gray50 ? 0.04 : 0.1;
          return Color.alphaBlend(Colors.black.withValues(alpha: tint), background);
        }),
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
      ),
      child: Text(label,
          style: SDSTextStyle.bold.copyWith(fontSize: 16, height: 20 / 16, color: foreground)),
      ),
    );
  }
}
