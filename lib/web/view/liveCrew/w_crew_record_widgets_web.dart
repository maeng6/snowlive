import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/core/model/m_crewMemberRankingList.dart';
import 'package:com.snowlive/core/model/m_crewRecordRoom.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/view/liveCrew/crew_record_sections_web.dart';
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_member_web.dart';
// 시간대 눈금 라벨은 크루홈 통계와 같은 상수를 쓴다(서버 `time_info` 순서).
import 'package:com.snowlive/web/view/liveCrew/w_crewhome_riding_stats_web.dart'
    show kCrewTimeBuckets;
import 'package:com.snowlive/web/view/liveCrew/w_crew_record_scaffold_web.dart';
import 'package:com.snowlive/web/widget/w_web_edge_fade_web.dart';
import 'package:com.snowlive/web/widget/w_skeleton_web.dart';
import 'package:com.snowlive/web/widget/w_web_stats_bar_web.dart';
import 'package:com.snowlive/web/widget/w_web_avatar_web.dart';
import 'package:com.snowlive/web/widget/w_web_overlay_modal_web.dart';
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

  const CrewRecordDayCard({
    super.key,
    required this.record,
    required this.date,
    required this.isToday,
    required this.crewName,
    required this.resortName,
  });

  @override
  Widget build(BuildContext context) {
    final members = record.todayMemberInfo ?? const <TodayMemberInfo>[];

    return Container(
      width: kCrewRecordCardWidth,
      height: kCrewRecordCardHeight,
      decoration: BoxDecoration(color: SDSColor.gray50, borderRadius: BorderRadius.circular(12)),
      // 목업(196:19627) — 패딩 16, 내용 폭 310.
      padding: const EdgeInsets.all(16),
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
          SizedBox(
            width: 24 + (faces.length - 1) * 20,
            height: 24,
            child: Stack(
              children: [
                for (var i = 0; i < faces.length; i++)
                  Positioned(
                    left: i * 20,
                    child: Container(
                      decoration: const BoxDecoration(shape: BoxShape.circle),
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
              // 목업 — 글줄 14(Regular 12), 아바타 묶음과 간격 8.
              style: SDSTextStyle.regular
                  .copyWith(fontSize: 12, height: 14 / 12, color: SDSColor.gray600),
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
                  // 목업(196:19649) — 배지 24×20, 라운드 20.
                  constraints: const BoxConstraints(minWidth: 24, minHeight: 20),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: SDSColor.gray900,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _numberFormat.format(count),
                    maxLines: 1,
                    softWrap: false,
                    style: SDSTextStyle.bold.copyWith(fontSize: 11, color: SDSColor.snowliveWhite),
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
Future<void> showCrewRecordMembersModal(
  BuildContext context, {
  required DateTime date,
  required List<TodayMemberInfo> members,
  required String? crewName,
  required String? resortName,
}) {
  return showWebOverlayModal<void>(
    context: context,
    builder: (_, close) => Material(
      color: SDSColor.snowliveWhite,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '라이딩 멤버 ${members.length}명',
                      style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                    ),
                  ),
                  InkWell(
                    onTap: close,
                    customBorder: const CircleBorder(),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(Icons.close, size: 18, color: SDSColor.gray400),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${date.month}월 ${crewRecordDayLabel(date)}',
                style: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.gray500),
              ),
              const SizedBox(height: SDSSpacing.md),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for (final member in members)
                        _MemberRow(member: member, crewName: crewName, resortName: resortName),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            WebAvatar(url: member.profileImageUrlUser, size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                member.displayName ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray900),
              ),
            ),
            const SizedBox(width: SDSSpacing.sm),
            Text(
              '${_numberFormat.format((member.totalScore ?? 0).round())}점',
              style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
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
    final offset = index * (kCrewRecordCardWidth + _kCardGap);
    _controller.animateTo(
      offset.clamp(0, _controller.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final activeDays = crewRecordDaysWithRecord(widget.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.month.title,
          // 목업(174:60479) 월 제목 줄 높이 33 → ExtraBold 24.
          style: SDSTextStyle.extraBold.copyWith(fontSize: 24, color: SDSColor.gray900),
        ),
        // 월 제목 ↔ 일자 줄 12 (목업 — 제목 33, 일자 줄 윗선 45).
        const SizedBox(height: 12),
        CrewRecordDayNumberRow(
          month: widget.month,
          activeDays: activeDays,
          onSelectDay: _scrollToDay,
        ),
        // 일자 줄 ↔ 카드 12 (목업 — 일자 줄 끝 838, 카드 850).
        const SizedBox(height: 12),
        SizedBox(
          height: kCrewRecordCardHeight,
          child: CrewRecordRailBleed(
            child: ListView.separated(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              // 양 끝 패딩 = bleed. 정지 상태의 첫 카드는 콘텐츠 좌측선에, 끝까지
              // 스크롤하면 마지막 카드 오른쪽이 콘텐츠 우측선에 선다.
              padding: EdgeInsets.symmetric(horizontal: CrewRecordBleed.of(context)),
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
    );
  }
}

/// 가로 레일을 **화면 좌우 끝까지** 넓혀 주는 래퍼.
///
/// `OverflowBox`로 콘텐츠 폭 바깥으로 `bleed`만큼 비져나가게 하고, 끝에서 카드가 흐릿하게
/// 사라지도록 흰 그라데이션을 덮는다. **안쪽 패딩은 자식(ListView)이 직접 든다** —
/// 그래야 스크롤 원점이 콘텐츠 좌측선과 맞는다([CrewRecordMonthSection] 참고).
///
/// 마우스 드래그 스크롤([WebHorizontalDragScroll])도 여기서 걸어 준다(웹 기본은 휠만 허용).
class CrewRecordRailBleed extends StatelessWidget {
  final Widget child;

  const CrewRecordRailBleed({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final double bleed = CrewRecordBleed.of(context);

    return LayoutBuilder(
      builder: (context, constraints) => OverflowBox(
        alignment: Alignment.center,
        minWidth: 0,
        maxWidth: constraints.maxWidth + bleed * 2,
        child: WebEdgeFade(
          // 페이드는 **여백 구간 안**에서만 번지게 폭을 묶는다 — 정지 상태의 첫 카드가
          // 희게 빠지지 않는다. 캡이 없으면 넓은 화면에서 그라데이션이 400px를 넘어
          // 카드가 반투명 유령처럼 보인다.
          fadeWidth: bleed.clamp(0.0, 64.0),
          child: WebHorizontalDragScroll(child: child),
        ),
      ),
    );
  }
}

/// `1 2 3 4 ... 31` 한 줄. 좁으면 옆으로 스크롤한다.
class CrewRecordDayNumberRow extends StatelessWidget {
  final CrewRecordMonth month;
  final Set<int> activeDays;
  final ValueChanged<int> onSelectDay;

  const CrewRecordDayNumberRow({
    super.key,
    required this.month,
    required this.activeDays,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final days = crewRecordDaysInMonth(month.year, month.month);

    return WebHorizontalDragScroll(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var day = 1; day <= days; day++)
              _DayNumber(
                day: day,
                isActive: activeDays.contains(day),
                // 기록이 없는 날은 갈 카드가 없다.
                onTap: activeDays.contains(day) ? () => onSelectDay(day) : null,
              ),
          ],
        ),
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
  final VoidCallback? onTap;

  const _DayNumber({required this.day, required this.isActive, required this.onTap});

  @override
  State<_DayNumber> createState() => _DayNumberState();
}

class _DayNumberState extends State<_DayNumber> {
  bool _hovered = false;

  /// hover 원 지름. 페이지네이션(32)보다 2 작게 — 일자 줄은 글자가 15로 더 작다.
  static const double _circle = 30;

  @override
  Widget build(BuildContext context) {
    // 기록 있는 날과 없는 날은 **색으로만** 구분한다(둘 다 Regular — 사용자 확정).
    final number = Text(
      '${widget.day}',
      style: SDSTextStyle.regular.copyWith(
        fontSize: 15,
        height: 19 / 15,
        color: widget.isActive ? SDSColor.gray900 : SDSColor.gray300,
      ),
    );

    final cell = SizedBox(
      // 줄 높이 36 = 글줄 19 + 상하 8.5 (목업 174:60481). 칸 사이 4.
      height: 36,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Center(
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
        ),
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

/// 기록실 상단 요약 — `시즌 통합 랭킹` / `시즌 총 점수` + `크루원 시즌 랭킹` 진입.
/// 규격은 크루홈 통계 바와 **같은 공용 지표 바**(`WebStatsBar`)를 쓴다(목업 174:60434).
///
/// 모바일 목업에는 랭킹 진입점이 없지만 그러면 그 화면이 고립되므로 바 아래에 둔다.
class CrewRecordSummaryCard extends StatelessWidget {
  final int? overallRank;
  final double? totalScore;
  final VoidCallback onOpenRanking;

  const CrewRecordSummaryCard({
    super.key,
    required this.overallRank,
    required this.totalScore,
    required this.onOpenRanking,
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
      trailing: WebStatsBarLink(label: '크루원 시즌 랭킹', onTap: onOpenRanking),
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
            // 실제 레일과 같이 화면 끝까지 넓힌다 — 로딩 중 좁았다가 데이터가 오면
            // 넓어지는 튐을 막는다. 넓어진 폭을 채우려면 자리도 더 필요하다(3 → 5장).
            child: CrewRecordRailBleed(
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    EdgeInsets.symmetric(horizontal: CrewRecordBleed.of(context)),
                children: [
                  for (var i = 0; i < 5; i++) ...[
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
