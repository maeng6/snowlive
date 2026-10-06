import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:flutter/material.dart';

/// 랭킹 홈·기록실이 함께 쓰는 "내 랭킹 / 크루 랭킹" 카드.
///
/// 두 화면이 따로 구현하고 있어서 기록실만 구 규격(패딩 20/16·라운드 12·구분선 1×32)
/// 으로 남고, 티어가 빠지는 리조트 필터에서 카드 높이가 달라졌다 → 한 곳으로 모은다.

/// 데스크탑·태블릿은 왼쪽에 카드 라벨을 두고 정보 그룹을 오른쪽 끝에 몰아 붙이고,
/// 모바일은 라벨을 빼고 그룹들이 카드 폭을 균등하게 나눠 갖는다(목업).
class RankingMyCardShell extends StatelessWidget {
  final String label;
  final bool isMobile;
  final List<Widget> groups;

  const RankingMyCardShell({required this.label, required this.isMobile, required this.groups});

  @override
  Widget build(BuildContext context) {
    return Container(
      // 카드가 숨겨질 때 아래 여백까지 같이 사라지도록 간격을 카드 안에 둔다.
      // 카드 ↔ 목록 30. 카드가 숨겨질 때 여백도 같이 사라지도록 카드 안에 둔다.
      // 모바일은 목록(좌우 16)보다 카드가 4 더 들어간다(목업).
      margin: EdgeInsets.only(bottom: 30, left: isMobile ? 4 : 0, right: isMobile ? 4 : 0),
      // PC·태블릿 목업(106:14734) — gray50 · 라운드 16 · 좌우 30 / 상하 7(높이 54)
      // 모바일 — 목업은 좌우 20 / 상하 13(높이 80)이지만, 세 묶음이 양끝까지 벌어져
      // 보여 좌우를 28로 넓혀 안쪽으로 모으고, 티어 아이콘(36)이 잡는 높이를 낮추려
      // 상하를 10으로 줄였다(사용자 확정). 카드만 페이지 여백(16)보다 4 더 들어간다.
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 28 : 30, vertical: isMobile ? 10 : 7),
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(16)),
      // 일간·리조트 필터에서는 티어 그룹이 빠지는데, 카드 높이를 결정하던 게
      // 티어 묶음이라 그때만 카드가 납작해진다 → 내용 최소 높이를 티어 묶음
      // 높이로 못 박아 누적과 같은 높이를 유지한다.
      // PC·태블릿: 아이콘 40 → 카드 7+40+7 = 54.
      // 모바일: 아이콘 32 + 간격 2 + 이름(12) 16 = 50 → 카드 10+50+10 = 70.
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: isMobile ? 50 : 40),
        child: Row(
          // 모바일은 그룹 폭이 서로 다르다(목업 70.5 / 70.5 / 76) — 3등분하면
          // 티어 이름이 잘린다. 각자 필요한 만큼 쓰게 두고 남는 공간만 균등 분배한다
          mainAxisAlignment:
              isMobile ? MainAxisAlignment.spaceBetween : MainAxisAlignment.start,
          children: [
            if (!isMobile) ...[
              Text(label, style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900)),
              const Spacer(),
            ],
            for (var i = 0; i < groups.length; i++) ...[
              if (i > 0)
                Container(
                  width: 1,
                  // 구분선 1×16, gray700 10% — 세 폭 공통(목업).
                  height: 16,
                  color: SDSColor.gray700.withValues(alpha: 0.1),
                  // PC·태블릿은 통계 사이 24 / 티어 그룹 앞 20.
                  // 모바일은 spaceBetween이 간격을 만들므로 margin을 주지 않는다.
                  margin: isMobile
                      ? EdgeInsets.zero
                      : EdgeInsets.only(
                          left: 24,
                          right: i == groups.length - 1 && groups.length >= 3 ? 20 : 24,
                        ),
                ),
              // 모바일 — 티어가 빠져 두 칸만 남으면(일간·리조트 필터) 반반으로
              // 나눠 구분선이 정확히 가운데 오고 각 텍스트는 제 칸의 중앙에 온다.
              // 세 칸일 때는 폭이 서로 달라서(티어가 더 넓다) 균등 분할하면
              // 티어 이름이 잘린다 → 필요한 만큼 쓰게 두고 남는 공간만 분배.
              if (isMobile)
                groups.length <= 2
                    // 반반으로 나누되 가운데에 몰려 보이지 않게 각자 바깥쪽으로
                    // 조금 밀어둔다(남는 여백의 30%).
                    ? Expanded(
                        child: Align(
                          alignment: Alignment(i == 0 ? -0.3 : 0.3, 0),
                          child: groups[i],
                        ),
                      )
                    : Flexible(child: groups[i])
              else
                groups[i],
            ],
          ],
        ),
      ),
    );
  }
}

class RankingMyStat extends StatelessWidget {
  final String label;
  final String value;

  /// 모바일: 값 위 / 라벨 아래로 쌓는다. 그 외: 라벨 왼쪽 / 값 오른쪽 한 줄
  final bool stacked;

  const RankingMyStat({required this.label, required this.value, this.stacked = false});

  @override
  Widget build(BuildContext context) {
    // 목업(106:14739/14740) — 라벨 regular 15·검정 50%·폭 56 가운데, 값 bold 18.
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: stacked ? TextAlign.center : TextAlign.center,
      style: SDSTextStyle.regular.copyWith(
        fontSize: stacked ? 12 : 14,
        color: stacked ? SDSColor.gray500 : SDSColor.gray900.withValues(alpha: 0.5),
      ),
    );
    final valueText = Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.bold.copyWith(fontSize: stacked ? 17 : 17, color: SDSColor.gray900),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [valueText, const SizedBox(height: 2), labelText],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ⚠️ 폭을 고정하면(목업 프레임 56) Pretendard 실측이 조금만 넘어도 라벨이
        // 말줄임된다. 목업의 56은 텍스트 자연 폭이라 그대로 흐르게 둔다.
        labelText,
        const SizedBox(width: 11),
        valueText,
      ],
    );
  }
}

/// 티어 아이콘 + 티어명 그룹(개인랭킹 카드).
class RankingTierBadge extends StatelessWidget {
  final String? iconUrl;
  final String name;
  final bool stacked;

  const RankingTierBadge({required this.iconUrl, required this.name, required this.stacked});

  @override
  Widget build(BuildContext context) {
    final hasIcon = iconUrl?.isNotEmpty ?? false;
    // 티어 PNG에 파란 글로우가 이미 들어 있어서(목업과 동일) 그림자를 따로 넣지 않는다.
    Widget icon(double size) =>
        WebNetworkImage(url: iconUrl, width: size, height: size, fit: BoxFit.contain, showPlaceholder: false);
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: SDSTextStyle.bold.copyWith(fontSize: stacked ? 12 : 13, color: SDSColor.gray900),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 모바일 아이콘 32 — 목업은 36이지만 이게 카드 높이를 잡아서 줄였다.
          // (사용자 확정). 아이콘↔이름 간격은 통계와 같은 2.
          if (hasIcon) icon(32),
          if (hasIcon) const SizedBox(height: 2),
          nameText,
        ],
      );
    }
    // 목업(106:14757) 순서는 이름 → 아이콘. 이름 폭 76을 고정해 두면 티어 이름
    // 길이가 달라도 아이콘 위치가 흔들리지 않는다. 아이콘 40.
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 폭 고정(목업 프레임 76)은 말줄임을 유발한다 — 자연 폭으로 둔다.
        nameText,
        if (hasIcon) ...[
          const SizedBox(width: 8),
          icon(40),
        ],
      ],
    );
  }
}

/// 크루명 + 크루 로고 + 크루 화면 진입 버튼 그룹(크루랭킹 카드).
class RankingCrewIdentity extends StatelessWidget {
  final String name;
  final String? logoUrl;
  final bool stacked;
  /// null이면 누를 수 없다(크루 id가 없는 경우).
  final VoidCallback? onTap;

  const RankingCrewIdentity({required this.name, required this.logoUrl, required this.stacked, this.onTap});

  @override
  Widget build(BuildContext context) {
    // 로고 36 · 라운드 5 (목업 106:44561은 36에 라운드 5.14).
    final logo = (logoUrl?.isNotEmpty ?? false)
        ? WebNetworkImage(
            url: logoUrl,
            width: stacked ? 20 : 28,
            height: stacked ? 20 : 28,
            borderRadius: 5,
            // 목록의 크루 로고와 동일하게 칸을 꽉 채운다.
            fit: BoxFit.cover,
          )
        : Icon(Icons.groups_outlined, size: stacked ? 18 : 24, color: SDSColor.gray400);
    final nameText = Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.bold.copyWith(fontSize: stacked ? 13 : 13, color: SDSColor.gray900),
    );

    if (stacked) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          logo,
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: nameText),
              const SizedBox(width: 4),
              RankingCircleArrowButton(onTap: onTap),
            ],
          ),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        nameText,
        // 이름 ↔ 로고 8, 로고 ↔ 화살표 16 (목업 106:44554/44555).
        const SizedBox(width: 8),
        logo,
        const SizedBox(width: 16),
        RankingCircleArrowButton(onTap: onTap),
      ],
    );
  }
}

class RankingCircleArrowButton extends StatelessWidget {
  /// null이면 누를 수 없다(크루 id가 없는 경우).
  final VoidCallback? onTap;

  const RankingCircleArrowButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    // 목업(106:44574) — 검정 원 지름 16, 안에 흰 화살표.
    return SizedBox(
      width: 16,
      height: 16,
      child: Material(
        color: SDSColor.gray900,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: const Icon(Icons.chevron_right, size: 12, color: Colors.white),
        ),
      ),
    );
  }
}
