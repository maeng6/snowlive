import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_member_web.dart';
// 시간대 눈금 라벨은 크루홈 통계와 같은 상수를 쓴다(서버 `time_info` 순서).
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_riding_stats_web.dart'
    show kCrewTimeBuckets;
import 'package:com.snowlive/web/widget/w_web_edge_fade_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_stats_bar_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final _numberFormat = NumberFormat('###,###,###,###');

/// 목업 실측 카드 폭·높이. 카드는 항상 펼쳐진 채 **가로로 나열**된다(아코디언 아님).
const double kCrewRecordCardWidth = 342;
const double kCrewRecordCardHeight = 462;
const double _kCardGap = 12;

/// 카드에 얼굴을 보여줄 최대 인원. 나머지는 `+ N 멤버`로 접는다(목업).
const int kCrewRecordFaceCount = 4;

/// 하루 카드. 목업 구성 — `15일(토)` + `오늘` 배지 / `총 점수` · `라이딩 횟수` 2분할 /
/// 라이딩 멤버 아바타 스택 / 시간대별 라이딩 횟수 막대.
class CrewRecordDayCard extends StatelessWidget {
  final CrewRidingRecord record;
  final DateTime date;
  final bool isToday;

  /// 멤버 팝업에 넣을 소속(멤버 응답에는 소속이 없다).
  final String? crewName;
  final String? resortName;

  /// 카드 폭. null이면 공용 342(가로 레일). 모바일 아코디언은 화면 폭을 꽉 쓴다.
  final double? width;

  /// 모바일 아코디언에서 **접고 펴는 꺾쇠**를 머리줄 오른쪽에 둔다.
  /// null이면 꺾쇠를 그리지 않는다(가로 레일은 늘 펼친 상태).
  final VoidCallback? onToggle;

  const CrewRecordDayCard({
    super.key,
    required this.record,
    required this.date,
    required this.isToday,
    required this.crewName,
    required this.resortName,
    this.width,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final members = record.todayMemberInfo ?? const <TodayMemberInfo>[];

    return Container(
      width: width ?? kCrewRecordCardWidth,
      height: kCrewRecordCardHeight,
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(12)),
      // 목업(196:19627) — 좌우 16(내용 폭 310), 위 20.
      // ⚠️ 위 패딩은 **접힌 줄과 같은 20**이어야 한다 — 다르면 접었다 펼 때 날짜
      // 글자가 위아래로 튄다. 목업도 두 상태 모두 날짜가 카드 위에서 20이다
      // (펼침 196:19667 y=20 / 접힘 174:71531 카드 top+20).
      // 20 + 날짜 14 + 간격 24 = 58 → 점수 블록 위치도 목업과 맞는다.
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 날짜 줄 — 글줄 14, `오늘`과 간격 8(목업 — 날짜 44, 배지 x=52).
          SizedBox(
            height: 14,
            child: Row(
              children: [
                Text(
                  crewRecordDayLabel(date),
                  style: SDSTextStyle.bold
                      .copyWith(fontSize: 12, height: 14 / 12, color: SDSColor.gray900),
                ),
                if (isToday) ...[
                  const SizedBox(width: 8),
                  Text(
                    '오늘',
                    style: SDSTextStyle.regular
                        .copyWith(fontSize: 12, height: 14 / 12, color: SDSColor.gray400),
                  ),
                ],
                if (onToggle != null) ...[
                  const Spacer(),
                  _CardChevron(isOpen: true, onTap: onToggle!),
                ],
              ],
            ),
          ),
          // 날짜 줄 ↔ 점수 블록 24 (목업 — 날짜 y=20, 점수 y=58).
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MetricCell(
                  value: _numberFormat.format((record.totalScore ?? 0).round()),
                  label: '총 점수',
                ),
              ),
              // 세로선 1×43, 두 칸 사이 가운데(목업 — x=154.5, 칸 폭 138.5씩).
              Container(width: 1, height: 43, color: SDSColor.gray200),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: _MetricCell(
                    value: _numberFormat.format(record.totalCount ?? 0),
                    label: '라이딩 횟수',
                  ),
                ),
              ),
            ],
          ),
          // 점수 블록 ↔ 멤버 줄 20 (목업 — 점수 끝 109, 멤버 129).
          const SizedBox(height: 20),
          CrewRecordMemberStack(
            members: members,
            onTap: members.isEmpty
                ? null
                : () => showCrewRecordMembersModal(
                    context,
                    date: date,
                    members: members,
                    crewName: crewName,
                    resortName: resortName,
                  ),
          ),
          // 멤버 줄 ↔ 구분선 30 (목업 — 멤버 끝 153, 선 183), 선 ↔ 제목 31.
          const SizedBox(height: 30),
          Container(height: 1, color: SDSColor.gray100),
          const SizedBox(height: 31),
          Text(
            '시간대별 라이딩 횟수',
            style: SDSTextStyle.regular
                .copyWith(fontSize: 13, height: 16 / 13, color: SDSColor.gray500),
          ),
          // 제목 ↔ 차트 18 (목업 — 제목 y=214(16), 차트 y=248).
          const SizedBox(height: 18),
          Expanded(child: CrewRecordTimeChart(counts: crewRecordTimeCounts(record))),
        ],
      ),
    );
  }
}

/// 모바일 아코디언에서 **접힌 날짜 한 줄**(목업 174:71491 — 342×54).
/// 눌러서 펼친다. 머리줄 구성은 펼친 카드와 같게 맞춘다(날짜 + `오늘` + 꺾쇠).
class CrewRecordDayRowCollapsed extends StatelessWidget {
  final DateTime date;
  final bool isToday;
  final double? width;
  final VoidCallback onTap;

  const CrewRecordDayRowCollapsed({
    super.key,
    required this.date,
    required this.isToday,
    required this.onTap,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: width,
          // 목업 — 높이 54 = 패딩 20 + 글줄 14 + 20.
          height: 54,
          decoration: BoxDecoration(
            color: SDSColor.gray50,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
              Text(
                crewRecordDayLabel(date),
                style: SDSTextStyle.bold
                    .copyWith(fontSize: 12, height: 14 / 12, color: SDSColor.gray900),
              ),
              if (isToday) ...[
                const SizedBox(width: 8),
                Text(
                  '오늘',
                  style: SDSTextStyle.regular
                      .copyWith(fontSize: 12, height: 14 / 12, color: SDSColor.gray400),
                ),
              ],
              const Spacer(),
              _CardChevron(isOpen: false, onTap: onTap),
            ],
          ),
        ),
      ),
    );
  }
}

/// 카드 접기/펴기 꺾쇠(목업 — 12×6). 펼친 상태면 위를 가리킨다
class _CardChevron extends StatelessWidget {
  final bool isOpen;
  final VoidCallback onTap;

  const _CardChevron({required this.isOpen, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Icon(
          isOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
          size: 24,
          color: SDSColor.gray900,
        ),
      ),
    );
  }
}

class _MetricCell extends StatelessWidget {
  final String value;
  final String label;

  const _MetricCell({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 목업(196:19631) — 값 줄 33(ExtraBold 24) / 라벨 14, 블록 51.
        Text(
          value,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          style: SDSTextStyle.extraBold
              .copyWith(fontSize: 24, height: 33 / 24, color: SDSColor.gray900),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          style: SDSTextStyle.regular
              .copyWith(fontSize: 12, height: 14 / 12, color: SDSColor.gray500),
        ),
      ],
    );
  }
}

/// 라이딩 멤버 아바타 스택 + `+ N 멤버`.
class CrewRecordMemberStack extends StatelessWidget {
  final List<TodayMemberInfo> members;
  final VoidCallback? onTap;

  const CrewRecordMemberStack({super.key, required this.members, this.onTap});

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return Text(
        '라이딩 멤버 없음',
        style: SDSTextStyle.regular.copyWith(fontSize: 13, color: SDSColor.gray400),
      );
    }

    final faces = members.take(kCrewRecordFaceCount).toList();
    final rest = members.length - faces.length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          // 얼굴을 겹쳐 놓는다(목업 196:19670 — 24 아바타, 피치 20 → 4 겹침).
          // 겹치는 폭만큼 전체 너비를 줄여야 한다.
          //
          // 겹친 사진끼리 구분되게 **카드 배경색과 같은 테두리**를 두른다(목업) —
          // 흰 선을 쓰면 회색 카드 위에서 흰 띠로 떠 보인다. 테두리는 바깥으로
          // 그리므로(`strokeAlign: outside`) 사진이 깎이지 않는다.
          SizedBox(
            width: 24 + (faces.length - 1) * 20,
            height: 24,
            child: Stack(
              // 테두리가 칸 밖으로 2px 번져도 잘리지 않게.
              clipBehavior: Clip.none,
              children: [
                for (var i = 0; i < faces.length; i++)
                  Positioned(
                    left: i * 20,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: SDSColor.gray50,
                          width: 2,
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                      child: WebAvatar(url: faces[i].profileImageUrlUser, size: 24),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              rest > 0 ? '+ $rest 멤버' : '${members.length} 멤버',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // 목업은 Regular 12인데 작아서 잘 안 보여 **Bold**로 바꿨다(사용자 확정).
              // 글줄 14 · 검정 · 아바타 묶음과 간격 8은 목업 그대로.
              style: SDSTextStyle.bold
                  .copyWith(fontSize: 12, height: 14 / 12, color: SDSColor.gray900),
            ),
          ),
        ],
      ),
    );
  }
}

/// 카드 안 시간대 막대. 최댓값만 파란 막대 + 검정 배지로 강조한다(목업).
class CrewRecordTimeChart extends StatelessWidget {
  final List<int> counts;

  const CrewRecordTimeChart({super.key, required this.counts});

  @override
  Widget build(BuildContext context) {
    final max = counts.fold<int>(0, (a, b) => b > a ? b : a);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var i = 0; i < counts.length; i++)
          Expanded(
            child: _TimeBar(
              label: kCrewTimeBuckets[i],
              count: counts[i],
              maxCount: max,
              isTop: max > 0 && counts[i] == max,
            ),
          ),
      ],
    );
  }
}

class _TimeBar extends StatelessWidget {
  final String label;
  final int count;
  final int maxCount;
  final bool isTop;

  const _TimeBar({
    required this.label,
    required this.count,
    required this.maxCount,
    required this.isTop,
  });

  @override
  Widget build(BuildContext context) {
    final ratio = maxCount <= 0 ? 0.0 : (count / maxCount).clamp(0.0, 1.0);
    // 라벨(2줄)과 숫자 자리를 뺀 만큼만 막대가 쓴다.
    final parts = label.split('-');

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (count > 0)
          isTop
              ? Container(
                  // 목업대로 최소 폭 24 · 높이 20, 좌우 패딩 4.
                  // 한 자리 숫자는 최소 폭이 만들고, 두세 자리에서만 패딩이 쓰인다.
                  //
                  // ⚠️ `alignment`를 주면 안 된다 — Container는 alignment가 있으면
                  // **부모가 준 폭까지 늘어난다**. 막대 한 칸(34쯤)을 그대로 먹어서
                  // minWidth를 줄여도 타원이 안 줄었다(실측). 세로 가운데는 alignment
                  // 대신 **상하 패딩**으로, 가로 가운데는 `textAlign`으로 맞춘다.
                  constraints: const BoxConstraints(minWidth: 24),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  decoration: BoxDecoration(
                    color: SDSColor.gray900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _numberFormat.format(count),
                    maxLines: 1,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 11, height: 14 / 11, color: SDSColor.snowliveWhite),
                  ),
                )
              : Text(
                  _numberFormat.format(count),
                  maxLines: 1,
                  softWrap: false,
                  style: SDSTextStyle.bold.copyWith(fontSize: 11, color: SDSColor.gray900),
                )
        else
          const SizedBox(height: 20),
        const SizedBox(height: 3),
        // 남은 높이를 다 쓰되 비율만큼만 채운다. Flexible + FractionallySizedBox 조합이라
        // LayoutBuilder(고유 높이 질문에 답할 수 없어 예전에 화면을 깨뜨렸다)가 필요 없다.
        Flexible(
          child: FractionallySizedBox(
            heightFactor: count > 0 ? (ratio < 0.04 ? 0.04 : ratio) : 0.0,
            alignment: Alignment.bottomCenter,
            child: Container(
              // 목업(196:19640) — 카드 안 막대는 16(크루홈 큰 차트는 14).
              width: 16,
              decoration: BoxDecoration(
                color: isTop ? SDSColor.snowliveBlue : SDSColor.gray200,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ),
          ),
        ),
        // 막대 ↔ 라벨 8 (목업 — 막대 끝 406, 라벨 414).
        const SizedBox(height: 8),
        // 목업은 슬롯이 좁아 라벨을 `00 -` / `08` 두 줄로 쓴다(두 줄 합 26).
        Text(
          '${parts.first} -',
          maxLines: 1,
          softWrap: false,
          style: SDSTextStyle.regular
              .copyWith(fontSize: 11, height: 13 / 11, color: SDSColor.gray400),
        ),
        Text(
          parts.last,
          maxLines: 1,
          softWrap: false,
          style: SDSTextStyle.regular
              .copyWith(fontSize: 11, height: 13 / 11, color: SDSColor.gray400),
        ),
      ],
    );
  }
}

/// 하루의 라이딩 멤버 목록 팝업(카드의 아바타 스택을 누르면 열린다).
/// 하루의 라이딩 멤버 목록 팝업(카드의 아바타 스택을 누르면 열린다).
///
/// 목업 196:22989 — 카드 390 · 라운드 16 · ✕ 26(우상단 16/16) ·
/// 타이틀 Bold 16 **가운데** · 목록 좌우 30 · 행 32(피치 42) ·
/// 아바타 32 + 간격 10 + 이름 Regular 15 / 점수 Bold 17 우측 정렬.
/// 날짜는 목업에 없지만 어느 날인지 알아야 해서 **타이틀 아래 가운데**에 둔다(사용자 확정).
///
/// **모바일은 하단 시트**로 올라온다(웹 공통 — 라이브톡 올리기·필터 메뉴와 같은 처리).
/// 좁은 화면에서 가운데 카드로 띄우면 좌우에 못 쓰는 여백만 남는다.
Future<void> showCrewRecordMembersModal(
  BuildContext context, {
  required DateTime date,
  required List<TodayMemberInfo> members,
  required String? crewName,
  required String? resortName,
}) {
  final isMobile = context.screenType == WebScreenType.mobile;

  return showWebOverlayModal<void>(
    context: context,
    alignment: isMobile ? Alignment.bottomCenter : Alignment.center,
    // 시트는 화면 폭을 꽉 쓰고 바닥에 붙는다(좌우·아래 여백 0).
    padding: isMobile
        ? EdgeInsets.zero
        : const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    builder: (ctx, close) => Material(
      color: SDSColor.snowliveWhite,
      // 시트는 위쪽 모서리만 둥글다(라이브톡 시트와 같은 16).
      borderRadius: isMobile
          ? const BorderRadius.vertical(top: Radius.circular(16))
          : BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? double.infinity : 390,
          // 멤버가 많으면 목록만 스크롤한다(화면 80%까지).
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ✕ 줄 — 26 아이콘이 우상단 16/16에 선다(줄 높이 26 → 타이틀이 42에서 시작).
            Padding(
              padding: const EdgeInsets.only(top: 16, right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: WebIconButton(
                  onTap: close,
                  padding: EdgeInsets.zero,
                  // 팝업 닫기 공통 — 26 · gray900 50%(크루 프로필 카드·라이브톡 모달과 동일).
                  icon: Icon(Icons.close,
                      size: 26, color: SDSColor.gray900.withValues(alpha: 0.5)),
                ),
              ),
            ),
            Text(
              '라이딩 멤버 ${members.length}',
              textAlign: TextAlign.center,
              style: SDSTextStyle.bold
                  .copyWith(fontSize: 16, height: 19 / 16, color: SDSColor.gray900),
            ),
            const SizedBox(height: 4),
            Text(
              '${date.month}월 ${crewRecordDayLabel(date)}',
              textAlign: TextAlign.center,
              style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
            ),
            // 타이틀 블록 ↔ 목록 20 (목업은 날짜 줄이 없어 30이다).
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                // 목록 좌우 30 · 아래 30 (목업). 모바일 시트는 페이지 여백과 같은 16,
                // 아래는 홈 인디케이터에 닿지 않게 더 둔다.
                padding: isMobile
                    ? const EdgeInsets.fromLTRB(16, 0, 16, 28)
                    : const EdgeInsets.fromLTRB(30, 0, 30, 30),
                child: Column(
                  children: [
                    for (final (index, member) in members.indexed) ...[
                      // 행 사이 14 (목업 10에서 4 넓힘 — 사용자 확정).
                      if (index > 0) const SizedBox(height: 14),
                      _MemberRow(
                          member: member, crewName: crewName, resortName: resortName),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _MemberRow extends StatelessWidget {
  final TodayMemberInfo member;
  final String? crewName;
  final String? resortName;

  const _MemberRow({required this.member, required this.crewName, required this.resortName});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // 프로필 팝업은 크루홈·멤버 목록과 같은 것을 쓴다. 일별 응답의 멤버는 타입이
      // 달라서(TodayMemberInfo) 팝업이 받는 CrewRanking으로 옮겨 담는다.
      onTap: () => showCrewMemberProfileModal(
        context,
        member: CrewRanking(
          userId: member.userId,
          displayName: member.displayName,
          profileImageUrlUser: member.profileImageUrlUser,
          totalScore: member.totalScore,
        ),
        crewName: crewName,
        resortName: resortName,
      ),
      child: SizedBox(
        // 행 높이 32 = 아바타 크기(목업).
        height: 32,
        child: Row(
          children: [
            WebAvatar(url: member.profileImageUrlUser, size: 32),
            // 아바타 ↔ 이름 10 (목업 — 아바타 32, 이름 x=42).
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                member.displayName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 15, height: 18 / 15, color: SDSColor.gray900),
              ),
            ),
            const SizedBox(width: SDSSpacing.sm),
            // 점수 열은 최소 72로 잡아 행끼리 오른쪽 선이 맞는다(목업 x=258~330)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 72),
              child: Text(
                '${_numberFormat.format((member.totalScore ?? 0).round())}점',
                maxLines: 1,
                textAlign: TextAlign.right,
                style: SDSTextStyle.regular
                    .copyWith(fontSize: 17, height: 22 / 17, color: SDSColor.gray900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 월 섹션 — `1월` 제목 + 일자 숫자 한 줄 + 하루 카드 가로 스크롤.
///
/// 일자 숫자는 칩이 아니라 글자만이다(목업). 기록이 있는 날은 진하게, 없는 날은 흐리게
/// 두고, 누르면 그 카드로 스크롤한다.
class CrewRecordMonthSection extends StatefulWidget {
  final CrewRecordMonth month;
  final String? crewName;
  final String? resortName;
  final DateTime today;

  const CrewRecordMonthSection({
    super.key,
    required this.month,
    required this.crewName,
    required this.resortName,
    required this.today,
  });

  @override
  State<CrewRecordMonthSection> createState() => _CrewRecordMonthSectionState();
}

class _CrewRecordMonthSectionState extends State<CrewRecordMonthSection> {
  final ScrollController _controller = ScrollController();

  /// 마지막으로 고른 날짜. 그 숫자만 Bold로 표시한다(처음에는 없음).
  int? _selectedDay;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 목업 카드 순서는 왼쪽이 최신이다(서버 응답이 날짜 내림차순이라 그대로 쓴다).
  List<({CrewRidingRecord record, DateTime date})> get _entries {
    final out = <({CrewRidingRecord record, DateTime date})>[];
    for (final record in widget.month.records) {
      final date = crewRecordDateOf(record);
      if (date != null) out.add((record: record, date: date));
    }
    return out;
  }

  void _scrollToDay(int day) {
    final entries = _entries;
    final index = entries.indexWhere((e) => e.date.day == day);
    if (index < 0 || !_controller.hasClients) return;

    setState(() => _selectedDay = day);

    final position = _controller.position;
    const double pitch = kCrewRecordCardWidth + _kCardGap;
    // 고른 카드를 **레일 가운데**에 세운다 — 왼쪽에 붙이면 끝 그라데이션에 가린다.
    // 양 끝 카드는 clamp에 걸려 가장자리에 서는데, 그쪽은 그라데이션도 꺼지므로
    // 가려질 일이 없다.
    final double target =
        index * pitch - (position.viewportDimension - kCrewRecordCardWidth) / 2;
    _controller.animateTo(
      target.clamp(0.0, position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final activeDays = crewRecordDaysWithRecord(widget.month);
    final bool isMobile = context.screenType == WebScreenType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.month.title,
          // 월 제목 줄 높이 — PC·태블릿 33(ExtraBold 24) / 모바일 24(ExtraBold 20).
          style: SDSTextStyle.extraBold
              .copyWith(fontSize: isMobile ? 20 : 24, color: SDSColor.gray900),
        ),
        // 모바일은 **일자 줄이 없고** 카드가 세로 아코디언이다(목업 174:71291)
        if (isMobile) ...[
          // 월 제목 ↔ 첫 카드 16 (목업 — 제목 24, 카드 40).
          const SizedBox(height: 12),
          _buildMobileAccordion(entries),
          // 월 섹션 사이 48 (목업 — 1월 블록 832, 12월 880).
          const SizedBox(height: 48),
        ] else ...[
        // 월 제목 ↔ 일자 줄 12 (목업 — 제목 33, 일자 줄 윗선 45)
        const SizedBox(height: 12),
        CrewRecordDayNumberRow(
          month: widget.month,
          activeDays: activeDays,
          selectedDay: _selectedDay,
          onSelectDay: _scrollToDay,
        ),
        // 일자 줄 ↔ 카드 12 (목업 — 일자 줄 끝 838, 카드 850)
        const SizedBox(height: 12),
        SizedBox(
          height: kCrewRecordCardHeight,
          child: CrewRecordRail(
            controller: _controller,
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              // 카드가 많아(한 달 30장) 화면 밖은 그리지 않게 builder로 만든다.
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(width: _kCardGap),
              itemBuilder: (_, i) => CrewRecordDayCard(
                record: entries[i].record,
                date: entries[i].date,
                isToday: crewRecordIsToday(entries[i].date, widget.today),
                crewName: widget.crewName,
                resortName: widget.resortName,
              ),
            ),
          ),
        ),
        // 월 섹션 사이 50 (목업 — 월 블록 피치 605, 블록 내용 555).
        const SizedBox(height: 50),
        ],
      ],
    );
  }

  /// 모바일 — 날짜 카드를 **세로로 쌓고 한 장만 펼친다**(목업 174:71291).
  /// 가로 레일은 좁은 폭에서 한 장도 제대로 안 보여서 구성을 바꿘다.
  Widget _buildMobileAccordion(
      List<({CrewRidingRecord record, DateTime date})> entries) {
    // 아직 고른 게 없으면 **맨 앞(가장 최근)** 날짜를 펼쳐 둔다.
    final int openDay = _selectedDay ?? (entries.isEmpty ? -1 : entries.first.date.day);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, entry) in entries.indexed) ...[
          // 카드 사이 12 (목업 — 접힌 카드 54, 다음 카드 66).
          if (index > 0) const SizedBox(height: 8),
          if (entry.date.day == openDay)
            CrewRecordDayCard(
              record: entry.record,
              date: entry.date,
              isToday: crewRecordIsToday(entry.date, widget.today),
              crewName: widget.crewName,
              resortName: widget.resortName,
              // 화면 폭을 꽉 쓴다(공용 342 대신).
              width: double.infinity,
              onToggle: () => setState(() => _selectedDay = -1),
            )
          else
            CrewRecordDayRowCollapsed(
              date: entry.date,
              isToday: crewRecordIsToday(entry.date, widget.today),
              width: double.infinity,
              onTap: () => setState(() => _selectedDay = entry.date.day),
            ),
        ],
      ],
    );
  }
}

/// 가로 레일 공통 래퍼 — 끝에서 카드가 **흐릿하게 사라지게** 하고 마우스 드래그
/// 스크롤을 걸어 준다(웹 기본은 휠만 허용)
///
/// 레일은 콘텐츠 폭 안에 머문다(사용자 확정 — 한때 화면 끝까지 흘렸다가 되돌렸다).
/// 그래서 그라데이션은 **그쪽에 더 볼 게 있을 때만** 켠다 — 늘 켜 두면 목록 처음에
/// 첫 카드 왼쪽이, 끝에서 마지막 카드 오른쪽이 괜히 희게 빠진다.
class CrewRecordRail extends StatefulWidget {
  final Widget child;

  /// 레일의 스크롤 컨트롤러. 주면 양 끝 그라데이션이 스크롤 위치를 따라 켜진다.
  /// 없으면(스켈레톤 등) 오른쪽만 켠다 — 자리가 넘친다는 뜻만 준다.
  final ScrollController? controller;

  const CrewRecordRail({super.key, required this.child, this.controller});

  @override
  State<CrewRecordRail> createState() => _CrewRecordRailState();
}

class _CrewRecordRailState extends State<CrewRecordRail> {
  bool _showStart = false;
  bool _showEnd = true;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_sync);
    // 첫 프레임 뒤에야 스크롤 범위를 알 수 있다(카드 수가 적으면 끝 그라데이션도 꺼야 한다).
    WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(covariant CrewRecordRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_sync);
      widget.controller?.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_sync);
    super.dispose();
  }

  void _sync() {
    final controller = widget.controller;
    if (!mounted || controller == null || !controller.hasClients) return;
    final position = controller.position;
    // 1px 여유 — 끝에 딱 붙었을 때 반올림 오차로 그라데이션이 깜빡이지 않게.
    final bool start = position.pixels > 1;
    final bool end = position.pixels < position.maxScrollExtent - 1;
    if (start != _showStart || end != _showEnd) {
      setState(() {
        _showStart = start;
        _showEnd = end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebEdgeFade(
      showStart: _showStart,
      showEnd: _showEnd,
      child: WebHorizontalDragScroll(child: widget.child),
    );
  }
}

/// `1 2 3 4 ... 31` 한 줄. 좁으면 옆으로 스크롤한다.
class CrewRecordDayNumberRow extends StatelessWidget {
  final CrewRecordMonth month;
  final Set<int> activeDays;
  final ValueChanged<int> onSelectDay;

  /// 고른 날짜. 그 숫자만 Bold로 표시한다(없으면 전부 Regular).
  final int? selectedDay;

  const CrewRecordDayNumberRow({
    super.key,
    required this.month,
    required this.activeDays,
    required this.onSelectDay,
    this.selectedDay,
  });

  @override
  Widget build(BuildContext context) {
    final days = crewRecordDaysInMonth(month.year, month.month);
    final numbers = [
      for (var day = 1; day <= days; day++)
        _DayNumber(
          day: day,
          isActive: activeDays.contains(day),
          isSelected: day == selectedDay,
          // 기록이 없는 날은 갈 카드가 없다.
          onTap: activeDays.contains(day) ? () => onSelectDay(day) : null,
        ),
    ];

    // 좁은 폭은 **줄바꿈**한다(목업 174:66609 — 25개 + 5개 두 줄).
    // 한 줄로 밀어 넣으면 가로 스크롤이 하나 더 생겨 카드 레일과 헷갈린다.
    if (!context.isDesktop) {
      return Wrap(children: numbers);
    }

    return WebHorizontalDragScroll(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: numbers),
      ),
    );
  }
}

/// 일자 줄 숫자 한 칸. 기록이 있는 날만 누를 수 있고, hover에서 **페이지네이션과 같은
/// 원형**이 깔린다(`w_numbered_pagination_web.dart`의 32 원과 같은 모양 언어).
///
/// 원이 숫자마다 같은 크기로 보이려면 칸이 **정사각**이어야 해서, 목업의 글자폭 기준 피치
/// (한 자리 24 / 두 자리 33)가 아니라 **30 원 + 간격 4 = 피치 34**로 고르게 선다.
/// 줄 높이 36은 목업 그대로 유지한다(원을 그 안에 세로 가운데로 둔다).
class _DayNumber extends StatefulWidget {
  final int day;
  final bool isActive;

  /// 고른 날짜면 Bold. 기록 유무(색)와는 별개 축이다.
  final bool isSelected;

  final VoidCallback? onTap;

  const _DayNumber({
    required this.day,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_DayNumber> createState() => _DayNumberState();
}

class _DayNumberState extends State<_DayNumber> {
  bool _hovered = false;

  /// hover 원 지름. 페이지네이션(32)보다 2 작게 — 일자 줄은 글자가 15로 더 작다.
  static const double _circle = 30;

  @override
  Widget build(BuildContext context) {
    // 기록 있는 날과 없는 날은 **색으로만** 구분한다(사용자 확정).
    // 굵기는 **고른 날짜**를 알리는 데만 쓴다.
    final number = Text(
      '${widget.day}',
      style: (widget.isSelected ? SDSTextStyle.bold : SDSTextStyle.regular).copyWith(
        fontSize: 15,
        height: 19 / 15,
        color: widget.isActive ? SDSColor.gray900 : SDSColor.gray300,
      ),
    );

    // ⚠️ `Center`로 감싸면 안 된다 — 느슨한 제약에서 **가용 폭을 다 먹어** 한 줄에
    // 하나씩만 들어간다(줄바꿈 레이아웃에서 날짜가 세로로 쌓였다). 칸 크기를
    // 원(30) + 패딩으로 직접 만든다 → 34 × 36.
    final cell = Padding(
      // 줄 높이 36 = 원 30 + 상하 3. 칸 사이 4 = 좌우 2씩.
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
      child: Container(
        width: _circle,
        height: _circle,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          // 웹 공통 hover 틴트 — 원형 gray50(아이콘 버튼과 같은 규칙).
          color: _hovered ? SDSColor.gray50 : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: number,
      ),
    );

    // 기록이 없는 날은 갈 카드가 없어 hover도 주지 않는다.
    if (widget.onTap == null) return cell;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: cell,
      ),
    );
  }
}

/// 월 섹션 목록. 기록실·일별 현황 두 화면이 같은 목록을 쓴다.
class CrewRecordMonthList extends StatelessWidget {
  final List<CrewRidingRecord> records;
  final String? crewName;
  final String? resortName;

  /// `오늘` 배지 판정 기준. 테스트에서 고정할 수 있게 주입받는다.
  final DateTime? now;

  const CrewRecordMonthList({
    super.key,
    required this.records,
    required this.crewName,
    required this.resortName,
    this.now,
  });

  @override
  Widget build(BuildContext context) {
    final months = groupCrewRecordsByMonth(records);
    final today = now ?? DateTime.now();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final month in months)
          CrewRecordMonthSection(
            key: ValueKey(month.key),
            month: month,
            crewName: crewName,
            resortName: resortName,
            today: today,
          ),
      ],
    );
  }
}

/// 기록실 상단 요약 — `시즌 통합 랭킹` / `시즌 총 점수`.
/// 규격은 크루홈 통계 바와 **같은 공용 지표 바**(`WebStatsBar`)를 쓴다(목업 174:60434).
///
/// `크루원 시즌 랭킹` 진입은 **타이틀 줄 오른쪽 끝**에 있다(스캐폴드 `headerActions`).
class CrewRecordSummaryCard extends StatelessWidget {
  final int? overallRank;
  final double? totalScore;

  const CrewRecordSummaryCard({
    super.key,
    required this.overallRank,
    required this.totalScore,
  });

  @override
  Widget build(BuildContext context) {
    return WebStatsBar(
      items: [
        WebStatItem(
          label: '시즌 통합 랭킹',
          value: _numberFormat.format(overallRank ?? 0),
        ),
        WebStatItem(
          label: '시즌 총 점수',
          value: _numberFormat.format((totalScore ?? 0).round()),
        ),
      ],
    );
  }
}

/// 월 섹션 로딩 자리. **실제와 같은 크기**(월 제목 + 일자 줄 + 카드 3장)로 두어야
/// 로딩 중임이 눈에 보인다(얇은 막대만 두면 안 보인다는 피드백을 받았다).
class CrewRecordListSkeleton extends StatelessWidget {
  const CrewRecordListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // ⚠️ 색은 SkeletonShimmer가 입힌다 — 안 감싸면 흰 배경에 흰 박스라 안 보인다.
    return SkeletonShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 실제 월 섹션과 같은 자리 — 제목 33 · 12 · 일자 줄 36 · 12.
          const SkeletonBox(width: 60, height: 33, radius: 6),
          const SizedBox(height: 12),
          const SkeletonBox(height: 36, radius: 6),
          const SizedBox(height: 12),
          SizedBox(
            height: kCrewRecordCardHeight,
            // 실제 레일과 같은 래퍼를 써서 로딩 중/후 모양이 같게 한다.
            child: CrewRecordRail(
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    if (i > 0) const SizedBox(width: _kCardGap),
                    const SkeletonBox(
                        width: kCrewRecordCardWidth,
                        height: kCrewRecordCardHeight,
                        radius: 12),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
