import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_friendDetail.dart';
import 'package:com.snowlive/web/routes/routes_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_riding_stats_web.dart'
    show
        CrewRidingEmptyState,
        CrewSlopeBarRow,
        CrewTimeCountCard,
        kCrewTimeBuckets;
import 'package:com.snowlive/web/widget/w_network_image_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_image_viewer_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 카드에 보여줄 슬로프 개수(목업 7줄). 전체는 모달에서 본다.
const int kProfileTopSlopeCount = 7;

/// 프로필 헤더.
///
/// 목업: **모바일은 가운데 정렬로 쌓고, 태블릿·데스크탑은 한 줄**(왼쪽 아바타+이름,
/// 오른쪽 소속·상태메시지 + 친구 추가). 모바일 목업에는 친구 추가 버튼이 없다 —
/// 프로필 팝업에 이미 있어서 그대로 따른다.
class ProfileHeaderWeb extends StatelessWidget {
  final FriendUserInfo? info;

  /// 오른쪽(모바일은 없음) 액션. null이면 그리지 않는다.
  final Widget? action;

  /// 모바일 전용 액션 — 오른쪽 자리가 없어서 상태메시지 아래 가운데에 둔다
  /// (내 프로필의 `프로필 편집`. 앱도 정보 아래에 `프로필 수정` 버튼이 있다).
  final Widget? mobileAction;

  /// 공유 아이콘. 로그인·친구 여부와 무관하게 항상 보인다. PC·태블릿은 오른쪽
  /// 액션 옆, 모바일은 액션과 함께 헤더 아래 가운데에 둔다.
  final Widget? share;

  const ProfileHeaderWeb({
    super.key,
    required this.info,
    this.action,
    this.mobileAction,
    this.share,
  });

  /// 목업 `휘닉스파크 · 올두맹`. 프로필 팝업과 같은 순서(리조트 · 크루)를 쓴다.
  String get _affiliation {
    final parts = [
      info?.favoriteResort,
      info?.crewName,
    ].where((e) => (e ?? '').trim().isNotEmpty).cast<String>();
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;
    final name = info?.displayName ?? '';
    final stateMsg = info?.stateMsg?.trim() ?? '';
    final crewId = info?.crewId;

    if (isMobile) {
      return Column(
        children: [
          WebAvatar(
            url: info?.profileImageUrlUser,
            size: 72,
            // 프로필 화면에서는 사진을 누르면 확대해서 본다(앱과 동일).
            onTap: () => showWebPhotoViewer(
              context,
              url: info?.profileImageUrlUser,
              title: name,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 18,
              color: SDSColor.gray900,
            ),
          ),
          if (_affiliation.isNotEmpty) ...[
            const SizedBox(height: 4),
            _AffiliationLine(
              text: _affiliation,
              crewId: crewId,
              centered: true,
            ),
          ],
          if (stateMsg.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              stateMsg,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: SDSTextStyle.regular.copyWith(
                fontSize: 13,
                color: SDSColor.gray400,
              ),
            ),
          ],
          if (share != null || mobileAction != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (share != null) share!,
                if (share != null && mobileAction != null)
                  const SizedBox(width: SDSSpacing.sm),
                if (mobileAction != null) mobileAction!,
              ],
            ),
          ],
        ],
      );
    }

    return Row(
      children: [
        // ⚠️ 남는 폭은 **왼쪽 그룹이 전부** 흡수해야 한다. 오른쪽 블록에 Expanded를
        // 주면 이름과 여백을 반씩 나눠 가져서 소속·상태메시지가 화면 가운데로 밀린다
        // (실측). 목업은 소속줄이 `친구 추가` 바로 옆에 붙는다.
        Expanded(
          child: Row(
            children: [
              WebAvatar(
                url: info?.profileImageUrlUser,
                size: 48,
                // 프로필 화면에서는 사진을 누르면 확대해서 본다(앱과 동일).
                onTap: () => showWebPhotoViewer(
                  context,
                  url: info?.profileImageUrlUser,
                  title: name,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // 목업(1:7842) — 닉네임 Bold 24.
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 24,
                    color: SDSColor.gray900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: SDSSpacing.md),
        // 상태메시지가 길어도 오른쪽 블록이 화면을 다 먹지 않게 상한을 둔다.
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_affiliation.isNotEmpty)
                _AffiliationLine(
                  text: _affiliation,
                  crewId: crewId,
                  centered: false,
                ),
              if (stateMsg.isNotEmpty) ...[
                // 목업(1:7843) — 소속줄 ↔ 상태메시지 4.
                const SizedBox(height: 4),
                Text(
                  stateMsg,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // 목업(1:7850) — Regular 13, 검정 50%.
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: SDSColor.snowliveBlack.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (share != null || action != null) ...[
          // 목업 — 소속 블록 ↔ 버튼 24.
          const SizedBox(width: SDSSpacing.lg),
          if (share != null) share!,
          if (share != null && action != null)
            const SizedBox(width: SDSSpacing.sm),
          if (action != null) action!,
        ],
      ],
    );
  }
}

/// `휘닉스파크 · 올두맹 ❯`. 크루가 있으면 크루홈으로 가는 화살표를 붙인다(목업).
class _AffiliationLine extends StatelessWidget {
  final String text;
  final int? crewId;
  final bool centered;

  const _AffiliationLine({
    required this.text,
    required this.crewId,
    required this.centered,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      // 목업(1:7846) — 소속줄 Regular 14.
      style: SDSTextStyle.regular.copyWith(
        fontSize: 14,
        color: SDSColor.gray900,
      ),
    );
    if (crewId == null || crewId == 0) return label;

    return InkWell(
      onTap: () => Get.toNamed('${WebRoutes.crewHome}?id=$crewId'),
      borderRadius: BorderRadius.circular(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: centered
            ? MainAxisAlignment.center
            : MainAxisAlignment.end,
        children: [
          Flexible(child: label),
          const SizedBox(width: 4),
          // 목업(1:7847)에서 추출한 에셋 — 검정 원 + 흰 `>` 꺾쇠 16.
          SvgPicture.asset(
            'assets/imgs/icons/icon_profile_affiliation_arrow.svg',
            width: 16,
            height: 16,
          ),
        ],
      ),
    );
  }
}

/// 파란 랭킹 바. `개인 점수` · `개인 랭킹` · 티어.
///
/// [leading]은 데스크탑·태블릿에서 바 왼쪽에 놓이는 라벨이다(`내 랭킹`, 또는 기록실의
/// 시즌 드롭다운). 모바일에서는 바 위에 따로 놓아야 해서 화면이 직접 그린다(목업).
class ProfileRankBarWeb extends StatelessWidget {
  final Widget? leading;
  final double? score;
  final int? rank;
  final String? tierName;
  final String? tierIconUrl;

  /// 기록 없는 시즌: 점수·랭킹·티어를 '-'로 표시.
  final bool empty;

  const ProfileRankBarWeb({
    super.key,
    this.leading,
    required this.score,
    required this.rank,
    required this.tierName,
    required this.tierIconUrl,
    this.empty = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    final cells = <Widget>[
      _RankCell(
        label: '개인 점수',
        value: empty ? '-' : _numberFormat.format((score ?? 0).round()),
        isMobile: isMobile,
      ),
      _RankCell(
        label: '개인 랭킹',
        value: empty ? '-' : _numberFormat.format(rank ?? 0),
        isMobile: isMobile,
      ),
      _TierCell(
        name: empty ? null : tierName,
        iconUrl: empty ? null : tierIconUrl,
        isMobile: isMobile,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: SDSColor.snowliveBlue,
        // 목업(1:7958) — 라운드 12.
        borderRadius: BorderRadius.circular(12),
      ),
      // 목업(1:7958) — 바 874×54, 좌우 패딩 30. 콘텐츠(티어 뱃지 40)가 가장 높아
      // 세로 패딩 7이면 바 높이가 정확히 54가 된다.
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? SDSSpacing.md : 30,
        vertical: isMobile ? 16 : 7,
      ),
      child: Row(
        children: [
          if (!isMobile && leading != null) ...[leading!, const Spacer()],
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                // 목업 — 구분선 1×16, 좌우 간격 30.
                height: isMobile ? 28 : 16,
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 30),
                color: SDSColor.snowliveWhite.withValues(alpha: 0.2),
              ),
            // 모바일은 3칸을 균등 분할하고, 넓은 폭에서는 내용 폭만 차지한다(목업).
            if (isMobile) Expanded(child: cells[i]) else cells[i],
          ],
        ],
      ),
    );
  }
}

class _RankCell extends StatelessWidget {
  final String label;
  final String value;
  final bool isMobile;

  const _RankCell({
    required this.label,
    required this.value,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    // 목업(1:7962) — 라벨 Regular 15(흰색 70%), 값 Bold 18, 라벨↔값 11.
    final labelStyle = SDSTextStyle.regular.copyWith(
      fontSize: isMobile ? 12 : 15,
      color: SDSColor.snowliveWhite.withValues(alpha: isMobile ? 0.8 : 0.7),
    );
    final valueStyle = isMobile
        ? SDSTextStyle.extraBold.copyWith(
            fontSize: 20,
            color: SDSColor.snowliveWhite,
          )
        : SDSTextStyle.bold.copyWith(
            fontSize: 18,
            color: SDSColor.snowliveWhite,
          );

    if (isMobile) {
      return Column(
        children: [
          Text(value, maxLines: 1, softWrap: false, style: valueStyle),
          const SizedBox(height: 2),
          Text(label, maxLines: 1, style: labelStyle),
        ],
      );
    }
    return Row(
      children: [
        Text(label, maxLines: 1, style: labelStyle),
        const SizedBox(width: 11),
        Text(value, maxLines: 1, softWrap: false, style: valueStyle),
      ],
    );
  }
}

class _TierCell extends StatelessWidget {
  final String? name;
  final String? iconUrl;
  final bool isMobile;

  const _TierCell({
    required this.name,
    required this.iconUrl,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      (name ?? '').isEmpty ? '-' : name!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      // 목업(1:7982) — 티어 라벨 Bold 14.
      style: SDSTextStyle.bold.copyWith(
        fontSize: isMobile ? 13 : 14,
        color: SDSColor.snowliveWhite,
      ),
    );
    final icon = (iconUrl ?? '').isEmpty
        ? const SizedBox.shrink()
        : MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => showWebTierImageViewer(
                context,
                url: iconUrl,
                tierNameKor: name,
              ),
              child: WebNetworkImage(
                url: iconUrl,
                // 목업(1:7983) — 넓은 폭 티어 뱃지 40.
                width: isMobile ? 28 : 40,
                height: isMobile ? 28 : 40,
                fit: BoxFit.contain,
                showPlaceholder: false,
                smoothDownscale: true,
              ),
            ),
          );

    if (isMobile) {
      return Column(children: [icon, const SizedBox(height: 2), label]);
    }
    // 넓은 폭에서는 목업처럼 이름 뒤에 아이콘이 온다.
    return Row(children: [label, const SizedBox(width: 8), icon]);
  }
}

/// 프로필의 `시간대별 기록` 카드 — 목업(1:7925)대로 좌측 카드와 같은 껍데기를 쓴다
/// (크루홈 기본값은 blue50·라운드 16이라 여기서만 바꿔 넘긴다).
CrewTimeCountCard _profileTimeCard(List<int> timeCounts) => CrewTimeCountCard(
  timeCounts: timeCounts,
  backgroundColor: SDSColor.gray50,
  borderRadius: 12,
  cardPadding: SDSSpacing.lg,
  titleStyle: SDSTextStyle.regular.copyWith(
    fontSize: 14,
    color: SDSColor.snowliveBlack.withValues(alpha: 0.4),
  ),
);

/// `라이딩 통계` — 좌: 슬로프별 가로 막대 / 우: 시간대별 세로 막대.
/// 크루홈 통계와 같은 줄 위젯([CrewSlopeBarRow], [CrewTimeCountCard])을 그대로 쓴다.
class ProfileRidingStatsWeb extends StatelessWidget {
  final String title;
  final int? totalCount;
  final List<SlopeCountInfo> slopes;
  final List<int> timeCounts;

  /// `전체 슬로프 보기` 모달 헤더에 쓰는 사람 정보.
  final String ownerName;
  final String? ownerImageUrl;

  const ProfileRidingStatsWeb({
    super.key,
    this.title = '라이딩 통계',
    required this.totalCount,
    required this.slopes,
    required this.timeCounts,
    required this.ownerName,
    this.ownerImageUrl,
  });

  static int maxCountOf(List<SlopeCountInfo> slopes) {
    var max = 0;
    for (final s in slopes) {
      if (s.count > max) max = s.count;
    }
    return max;
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final max = maxCountOf(slopes);
    final left = _SlopeCard(
      totalCount: totalCount,
      slopes: slopes.take(kProfileTopSlopeCount).toList(),
      maxCount: max,
    );
    final right = _profileTimeCard(timeCounts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              // 목업(1:7891) — Bold 16.
              style: SDSTextStyle.bold.copyWith(
                fontSize: 16,
                color: SDSColor.gray900,
              ),
            ),
            const Spacer(),
            OutlinedButton(
              onPressed: () => showProfileSlopesModal(
                context,
                ownerName: ownerName,
                ownerImageUrl: ownerImageUrl,
                totalCount: totalCount,
                slopes: slopes,
                timeCounts: timeCounts,
              ),
              style: OutlinedButton.styleFrom(
                // 목업(1:7892) — 테두리 gray100, 패딩 12/10, 라운드 6.
                side: BorderSide(color: SDSColor.gray100),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                '전체 슬로프 보기',
                // 줄높이 16 고정 — 목업(1:7894)과 같고, 폰트 메트릭에 따라
                // 버튼 높이(36)가 흔들리지 않는다.
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 13,
                  height: 16 / 13,
                  color: SDSColor.gray900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SDSSpacing.md),
        if (isDesktop)
          // ⚠️ 크루홈과 같은 이유로 IntrinsicHeight로 높이를 먼저 정한다(무한 높이 stretch 금지).
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: left),
                // 목업 — 카드 사이 21.
                const SizedBox(width: 21),
                Expanded(child: right),
              ],
            ),
          )
        else
          Column(
            children: [
              left,
              const SizedBox(height: SDSSpacing.md),
              right,
            ],
          ),
      ],
    );
  }
}

class _SlopeCard extends StatelessWidget {
  final int? totalCount;
  final List<SlopeCountInfo> slopes;
  final int maxCount;

  const _SlopeCard({
    required this.totalCount,
    required this.slopes,
    required this.maxCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 목업(1:7898) — 카드 gray50, 라운드 12, 패딩 24.
      decoration: BoxDecoration(
        color: SDSColor.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(SDSSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 목업(1:7899) — Regular 14, 검정 40%.
          Text(
            '총 라이딩 횟수',
            style: SDSTextStyle.regular.copyWith(
              fontSize: 14,
              color: SDSColor.snowliveBlack.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_numberFormat.format(totalCount ?? 0)}회',
            style: SDSTextStyle.extraBold.copyWith(
              fontSize: 24,
              color: SDSColor.gray900,
            ),
          ),
          // 목업 — 총 횟수 ↔ 슬로프 목록 24.
          const SizedBox(height: SDSSpacing.lg),
          if (slopes.isEmpty)
            // 옆 시간대별 카드와 같은 빈 상태(공용) — 문구·아이콘이 한 화면에서 갈리지 않게.
            const CrewRidingEmptyState()
          else
            for (var i = 0; i < slopes.length; i++) ...[
              // 목업 — 줄 피치 28(막대 14 + 간격 14).
              if (i > 0) const SizedBox(height: 14),
              CrewSlopeBarRow(
                label: slopes[i].slope,
                count: slopes[i].count,
                maxCount: maxCount,
                // 1등 슬로프만 진한 파랑 + 검정 배지(목업).
                isTop: i == 0,
              ),
            ],
        ],
      ),
    );
  }
}

/// `전체 슬로프 보기` 모달.
Future<void> showProfileSlopesModal(
  BuildContext context, {
  required String ownerName,
  String? ownerImageUrl,
  required int? totalCount,
  required List<SlopeCountInfo> slopes,
  required List<int> timeCounts,
}) {
  final max = ProfileRidingStatsWeb.maxCountOf(slopes);
  return showWebOverlayModal<void>(
    context: context,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
    builder: (ctx, close) => Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 620),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  WebAvatar(url: ownerImageUrl, size: 28),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      ownerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: close,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: SDSColor.gray400,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SDSSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: SDSColor.gray50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(SDSSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '총 라이딩 횟수',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: SDSColor.snowliveBlack.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_numberFormat.format(totalCount ?? 0)}회',
                              style: SDSTextStyle.extraBold.copyWith(
                                fontSize: 24,
                                color: SDSColor.gray900,
                              ),
                            ),
                            const SizedBox(height: SDSSpacing.md),
                            if (slopes.isEmpty)
                              const CrewRidingEmptyState()
                            else
                              for (var i = 0; i < slopes.length; i++) ...[
                                if (i > 0) const SizedBox(height: 14),
                                CrewSlopeBarRow(
                                  label: slopes[i].slope,
                                  count: slopes[i].count,
                                  maxCount: max,
                                  isTop: i == 0,
                                ),
                              ],
                          ],
                        ),
                      ),
                      const SizedBox(height: SDSSpacing.md),
                      _profileTimeCard(timeCounts),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// 서버 `time_info` Map을 [kCrewTimeBuckets] 순서의 9칸으로 만든다.
List<int> profileTimeCounts(Map<String, dynamic>? raw) => [
  for (final label in kCrewTimeBuckets) (raw?[label] as num?)?.toInt() ?? 0,
];
