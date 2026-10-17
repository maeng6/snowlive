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
import 'package:com.snowlive/web/widget/w_web_section_link_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/widget/w_web_popup_web.dart'
    show WebPopupCloseButton;
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

  /// 프로필 사진 **왼쪽**에 붙는 내용(태블릿 뒤로가기). 목업에는 없지만 웹에는
  /// 뒤로가기가 필요해서, 별도 줄로 띄우지 않고 헤더 줄 안에 넣는다(사용자 확정) —
  /// 그래야 헤더 상단 여백이 다른 서브 페이지와 같은 값(태블릿 20)으로 유지된다.
  final Widget? leading;

  const ProfileHeaderWeb({
    super.key,
    required this.info,
    this.action,
    this.mobileAction,
    this.share,
    this.leading,
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
            // 목업(1:4914) — 모바일 아바타 64.
            size: 64,
            // 프로필 화면에서는 사진을 누르면 확대해서 본다(앱과 동일).
            onTap: () => showWebPhotoViewer(
              context,
              url: info?.profileImageUrlUser,
              title: name,
            ),
          ),
          // 목업(1:4915) — 아바타 ↔ 글 16, 닉네임 Bold 16, 줄 사이 2.
          const SizedBox(height: 16),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: SDSTextStyle.bold.copyWith(
              fontSize: 16,
              color: SDSColor.gray900,
            ),
          ),
          if (_affiliation.isNotEmpty) ...[
            const SizedBox(height: 2),
            _AffiliationLine(
              text: _affiliation,
              crewId: crewId,
              centered: true,
              // 목업(1:4920) — 모바일 소속줄 13(PC·태블릿은 14).
              fontSize: 13,
            ),
          ],
          if (stateMsg.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              stateMsg,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              // 목업(1:4921) — Regular 13, 검정 50%(PC와 같은 색).
              style: SDSTextStyle.regular.copyWith(
                fontSize: 13,
                color: SDSColor.snowliveBlack.withValues(alpha: 0.5),
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
        if (leading != null) ...[
          leading!,
          // 서브 페이지 헤더 표준 — 뒤로가기 ↔ 다음 요소 3.
          const SizedBox(width: 3),
        ],
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
        // 목업(1:7837) — 이름 블록 ↔ 소속 블록 12(이름이 짧으면 남는 폭이 다
        // 사이로 들어가므로 이 값은 '최소 간격'으로만 보인다).
        const SizedBox(width: 12),
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

  /// 글자 크기 — PC·태블릿 14(목업 1:7846) / 모바일 13(목업 1:4920).
  final double fontSize;

  const _AffiliationLine({
    required this.text,
    required this.crewId,
    required this.centered,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: SDSTextStyle.regular.copyWith(
        fontSize: fontSize,
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
      // 좌우 여백 — PC·태블릿 30(목업) / **모바일 20**(사용자 확정, 목업 30은
      // 좁은 폭에서 세 칸을 눌렀다). 세로는 PC·태블릿 7 / 모바일 11(바 54 / 80).
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 30,
        vertical: isMobile ? 11 : 7,
      ),
      child: Row(
        children: [
          if (!isMobile && leading != null) ...[leading!, const Spacer()],
          for (var i = 0; i < cells.length; i++) ...[
            if (i > 0)
              Container(
                width: 1,
                // 목업(1:7960/1:5001) — 구분선 1×16(폭 공통). 좌우 간격은 30이지만
                // **마지막 구분선 → 티어만 24**다(점수 126 → 선 156 → 랭킹 187 →
                // 선 307 → 티어 332). 왼쪽은 늘 30.
                // 모바일은 칸이 균등 분할이라 간격을 8로 줄인다(30이면 글자가 눌린다).
                height: 16,
                margin: EdgeInsets.only(
                  left: isMobile ? 8 : 30,
                  right: isMobile ? 8 : (i == cells.length - 1 ? 24 : 30),
                ),
                color: SDSColor.snowliveWhite.withValues(alpha: 0.2),
              ),
            // 모바일은 **세 칸이 같은 폭**을 갖는다(flex 1 균등 분할 — 사용자 확정).
            // 넓은 폭에서는 목업대로 내용 폭만 차지한다.
            if (isMobile)
              Expanded(child: Center(child: cells[i]))
            else
              cells[i],
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
    // 목업대로 — PC·태블릿(1:7962) 라벨 Regular 15 · 값 Bold 18 · 라벨↔값 11,
    // 모바일(1:4998) 라벨 Regular 12 · 값 Bold 18 · 값↔라벨 4. 라벨은 흰색 70%.
    // 글줄은 못 박아 바 높이(모바일 80 / 그 외 54)가 폰트에 따라 흔들리지 않게 한다.
    final labelStyle = SDSTextStyle.regular.copyWith(
      fontSize: isMobile ? 12 : 15,
      height: isMobile ? 14 / 12 : 18 / 15,
      color: SDSColor.snowliveWhite.withValues(alpha: 0.7),
    );
    final valueStyle = SDSTextStyle.bold.copyWith(
      fontSize: 18,
      height: 21 / 18,
      color: SDSColor.snowliveWhite,
    );

    if (isMobile) {
      // 목업(1:4998) — 값(위) · 라벨(아래), 사이 4.
      // ⚠️ `min`이 없으면 높이가 정해진 부모 안에서 칸이 세로로 늘어난다.
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, maxLines: 1, softWrap: false, style: valueStyle),
          const SizedBox(height: 4),
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
      // 모바일은 아이콘 **아래 줄**이라 `개인 점수`·`개인 랭킹`과 같은 규격 —
      // **Regular 12 · 흰색 70%**(사용자 확정, 목업의 Bold 12 흰색 대신).
      // PC·태블릿은 아이콘 옆에 서는 이름이라 목업대로 Bold 14 흰색이다.
      // (모바일: 아이콘 40 + 2 + 글줄 14 = 56 → 바 높이 78.)
      style: (isMobile ? SDSTextStyle.regular : SDSTextStyle.bold).copyWith(
        fontSize: isMobile ? 12 : 14,
        height: isMobile ? 14 / 12 : 17 / 14,
        color: SDSColor.snowliveWhite.withValues(alpha: isMobile ? 0.7 : 1),
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
              // 목업(1:5017/1:7983) — 티어 뱃지는 폭 상관없이 40이다(모바일 바 높이
              // 80 = 11 + (40 + 4 + 14) + 11이 여기서 나온다).
              child: _TierIcon(slot: 40, url: iconUrl!),
            ),
          );

    if (isMobile) {
      // 아이콘(위) · 이름(아래), 사이 **2**(사용자 확정 — 목업 1:5016은 4였다).
      // 아이콘 40 + 2 + 글줄 14 = 56 → 모바일 바 높이 78(세로 패딩 11+11).
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [icon, const SizedBox(height: 2), label],
      );
    }
    // 넓은 폭에서는 목업처럼 이름 뒤에 아이콘이 온다.
    return Row(children: [label, const SizedBox(width: 8), icon]);
  }
}

/// 티어 뱃지. 목업(1:7983/1:7989)은 **칸 40에 원본을 44.44로 키워 넣고 40으로 잘라낸다**
/// (= 111% 확대 크롭). 칸 크기 그대로 `contain`으로 그리면 원본의 투명 여백까지 칸에
/// 들어가서 마크가 목업보다 작아 보인다 — 레이아웃 칸은 40 그대로 두고 그림만 키운다.
class _TierIcon extends StatelessWidget {
  final double slot;
  final String url;

  const _TierIcon({required this.slot, required this.url});

  @override
  Widget build(BuildContext context) {
    final art = slot * 44.444 / 40;
    return SizedBox(
      width: slot,
      height: slot,
      child: ClipRect(
        child: OverflowBox(
          minWidth: 0,
          minHeight: 0,
          maxWidth: art,
          maxHeight: art,
          child: WebNetworkImage(
            url: url,
            width: art,
            height: art,
            fit: BoxFit.contain,
            showPlaceholder: false,
            smoothDownscale: true,
          ),
        ),
      ),
    );
  }
}

/// 프로필의 `시간대별 기록` 카드 — 목업(1:7925)대로 좌측 카드와 같은 껍데기를 쓴다
/// (크루홈 기본값은 blue50·라운드 16이라 여기서만 바꿔 넘긴다).
CrewTimeCountCard _profileTimeCard(List<int> timeCounts) => CrewTimeCountCard(
  timeCounts: timeCounts,
  backgroundColor: SDSColor.gray50,
  borderRadius: 12,
  cardPadding: SDSSpacing.lg,
  // 목업(1:7929) — 회색 카드 위라 막대도 gray200이다(크루홈의 파란 카드와 다르다).
  barColor: SDSColor.gray200,
  titleStyle: SDSTextStyle.regular.copyWith(
    fontSize: 14,
    color: SDSColor.gray900.withValues(alpha: 0.4),
  ),
);

/// `라이딩 통계` — 좌: 슬로프별 가로 막대 / 우: 시간대별 세로 막대.
/// 크루홈 통계와 같은 줄 위젯([CrewSlopeBarRow], [CrewTimeCountCard])을 그대로 쓴다.
class ProfileRidingStatsWeb extends StatefulWidget {
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
  State<ProfileRidingStatsWeb> createState() => _ProfileRidingStatsWebState();
}

class _ProfileRidingStatsWebState extends State<ProfileRidingStatsWeb> {
  /// 모바일에서 슬로프 목록을 전부 펼쳤는지. 좁은 화면에서는 팝업이 화면을 거의
  /// 다 덮어 맥락이 끊겨서, 크루홈과 같이 **그 자리에서 아래로 펼친다**.
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.isDesktop;
    final isMobile = context.screenType == WebScreenType.mobile;
    final slopes = widget.slopes;
    final max = ProfileRidingStatsWeb.maxCountOf(slopes);
    // 모바일에서 펼친 상태면 상위 N개가 아니라 전부 그린다(크루홈과 같은 처리).
    final visibleSlopes = (isMobile && _expanded)
        ? slopes
        : slopes.take(kProfileTopSlopeCount).toList();
    final hasMore = slopes.length > kProfileTopSlopeCount;
    final left = _SlopeCard(
      totalCount: widget.totalCount,
      slopes: visibleSlopes,
      maxCount: max,
    );
    final right = _profileTimeCard(widget.timeCounts);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ⚠️ 제목 줄 높이를 **버튼 높이(36)로 못 박는다**(목업 1:7889/1:5349도 36).
        // 안 그러면 버튼이 있을 때는 줄 높이가 36(제목이 가운데 8.5 내려감),
        // 없을 때는 글줄 19가 되어 제목이 위아래로 튄다(사용자 지적 —
        // 모바일에서 슬로프가 7개 이하면 버튼이 사라진다).
        SizedBox(
          height: 36,
          child: Row(
            children: [
              Text(
                widget.title,
                // 목업(1:7891) — Bold 16.
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  color: SDSColor.gray900,
                ),
              ),
              const Spacer(),
              // 크루홈 `전체 슬로프 보기`와 **같은 공용 버튼**(목업 1:7892와 규격 동일 —
              // 테두리 gray100·라운드 6·패딩 12/10·높이 36·Bold 13). 직접 OutlinedButton을
              // 쓰면 웹 기본 visualDensity(compact)에 높이가 28로 깎이고 hover도 달라진다.
              //
              // 모바일은 팝업 대신 **그 자리에서 펼친다**(크루홈과 같은 동작) —
              // 더 보여줄 슬로프가 없으면 버튼 자체를 그리지 않는다.
              if (!isMobile || hasMore)
                WebSectionLinkButton(
                  label: isMobile
                      ? (_expanded ? '슬로프 접기' : '전체 슬로프 보기')
                      : '전체 슬로프 보기',
                  onTap: () {
                    if (isMobile) {
                      setState(() => _expanded = !_expanded);
                      return;
                    }
                    showProfileSlopesModal(
                      context,
                      ownerName: widget.ownerName,
                      ownerImageUrl: widget.ownerImageUrl,
                      totalCount: widget.totalCount,
                      slopes: slopes,
                      timeCounts: widget.timeCounts,
                    );
                  },
                ),
            ],
          ),
        ),
        // 목업(1:7888) 실측 — 제목 줄(36) 바닥 → 카드 윗선 12.
        const SizedBox(height: 12),
        if (context.screenType != WebScreenType.mobile)
          // ⚠️ 크루홈과 같은 이유로 IntrinsicHeight로 높이를 먼저 정한다(무한 높이 stretch 금지).
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // PC 목업 — 두 카드는 **같은 폭이 아니다**(좌 423 / 우 430, 사이 21 = 874).
                // 태블릿 목업(1:2881)은 370 : 20 : 370으로 **반반**이다.
                Expanded(flex: isDesktop ? 423 : 1, child: left),
                SizedBox(width: isDesktop ? 21 : 20),
                Expanded(flex: isDesktop ? 430 : 1, child: right),
              ],
            ),
          )
        else
          Column(
            children: [
              left,
              // 목업(1:5348) — 모바일 카드 사이 20.
              const SizedBox(height: 20),
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
            // 목업(1:7899) — Regular 14, #111 40%.
            style: SDSTextStyle.regular.copyWith(
              fontSize: 14,
              color: SDSColor.gray900.withValues(alpha: 0.4),
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
                // 1등 슬로프만 진한 파랑 + 검정 배지, 나머지는 gray200(목업 1:7910).
                isTop: i == 0,
                barColor: SDSColor.gray200,
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
        child: Stack(
          children: [
            Padding(
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
                      // 우상단에 띄운 닫기 X 자리 — 이름이 X 밑으로 들어가지 않게 비워둔다
                      // (X 왼쪽 끝이 카드 오른쪽에서 42라 내용 영역을 22 파고든다).
                      const SizedBox(width: 30),
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
                                    color: SDSColor.gray900.withValues(
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
                                      barColor: SDSColor.gray200,
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
            // 닫기 X — 웹 팝업 공통(26 · gray900 50% · 우상단 16/16).
            WebPopupCloseButton(onTap: close),
          ],
        ),
      ),
    ),
  );
}

/// 서버 `time_info` Map을 [kCrewTimeBuckets] 순서의 9칸으로 만든다.
List<int> profileTimeCounts(Map<String, dynamic>? raw) => [
  for (final label in kCrewTimeBuckets) (raw?[label] as num?)?.toInt() ?? 0,
];
