import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/web/util/responsive_web.dart';
import 'package:com.snowlive/web/util/web_drag_scroll_web.dart';
import 'package:com.snowlive/web/widget/w_web_edge_fade_web.dart';
import 'package:com.snowlive/web/widget/w_web_icon_button_web.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

const List<String> kProfileWeekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

/// 그 달의 일수.
int profileDaysInMonth(int year, int month) => DateTime(
  month == 12 ? year + 1 : year,
  month == 12 ? 1 : month + 1,
  1,
).subtract(const Duration(days: 1)).day;

/// 일간 통계 캘린더.
///
/// 목업: **모바일은 7열 월간 그리드, 태블릿·데스크탑은 한 줄 가로 스트립.** 기록이 있는
/// 날은 연한 파란 칸에 라이딩 횟수를 함께 적고, 고른 날은 검정 칸으로 채운다.
class ProfileDailyCalendarWeb extends StatelessWidget {
  /// 표시 중인 달(일자는 무시한다).
  final DateTime month;

  /// 그 달의 일별 라이딩 횟수. 없는 날은 키가 없다.
  final Map<int, int> countsByDay;
  final int? selectedDay;
  final DateTime today;
  final ValueChanged<int> onSelectDay;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;

  const ProfileDailyCalendarWeb({
    super.key,
    required this.month,
    required this.countsByDay,
    required this.selectedDay,
    required this.today,
    required this.onSelectDay,
    required this.onPrevMonth,
    required this.onNextMonth,
  });

  bool _isToday(int day) =>
      today.year == month.year &&
      today.month == month.month &&
      today.day == day;

  @override
  Widget build(BuildContext context) {
    final isMobile = context.screenType == WebScreenType.mobile;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MonthNavigator(month: month, onPrev: onPrevMonth, onNext: onNextMonth),
        const SizedBox(height: SDSSpacing.md),
        if (isMobile) _buildGrid() else _buildStrip(),
      ],
    );
  }

  Widget _buildCell(int day, {bool isOutside = false}) {
    final count = countsByDay[day];
    return _DayCell(
      day: day,
      count: isOutside ? null : count,
      isSelected: !isOutside && selectedDay == day,
      isToday: !isOutside && _isToday(day),
      isOutside: isOutside,
      // 기록이 없는 날은 보여줄 통계가 없다.
      onTap: (!isOutside && count != null) ? () => onSelectDay(day) : null,
    );
  }

  /// 모바일 — 월요일 시작 7열 그리드. 마지막 주의 빈칸은 다음 달 날짜를 흐리게 채운다(목업).
  Widget _buildGrid() {
    final days = profileDaysInMonth(month.year, month.month);
    final leading = DateTime(month.year, month.month, 1).weekday - 1; // 월=0
    final cells = <Widget>[
      for (var i = 0; i < leading; i++) const _EmptyCell(),
      for (var day = 1; day <= days; day++) _buildCell(day),
    ];
    final trailing = (7 - cells.length % 7) % 7;
    for (var i = 1; i <= trailing; i++) {
      cells.add(
        _DayCell(
          day: i,
          count: null,
          isSelected: false,
          isToday: false,
          isOutside: true,
          onTap: null,
        ),
      );
    }

    return Column(
      children: [
        Row(
          children: [
            for (final label in kProfileWeekdayLabels)
              Expanded(
                child: Center(child: _WeekdayLabel(label: label)),
              ),
          ],
        ),
        const SizedBox(height: 8),
        for (var week = 0; week * 7 < cells.length; week++)
          Row(
            children: [
              for (var i = week * 7; i < week * 7 + 7; i++)
                Expanded(
                  child: i < cells.length ? cells[i] : const _EmptyCell(),
                ),
            ],
          ),
      ],
    );
  }

  /// 태블릿·데스크탑 — 한 줄. 요일 라벨이 날짜마다 위에 붙고, 좁으면 옆으로 스크롤한다.
  Widget _buildStrip() {
    final days = profileDaysInMonth(month.year, month.month);
    // 마우스로 끌어서도 넘길 수 있게 한다(웹 기본값은 휠만 허용).
    // 좌우 끝은 흰 그라데이션으로 덮어 스트립이 잘려 끝나지 않게 한다(사용자 확정).
    return WebEdgeFade(
      fadeWidth: 40,
      child: WebHorizontalDragScroll(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var day = 1; day <= days; day++)
                SizedBox(
                  width: 52,
                  child: Column(
                    children: [
                      _WeekdayLabel(
                        label:
                            kProfileWeekdayLabels[DateTime(
                                  month.year,
                                  month.month,
                                  day,
                                ).weekday -
                                1],
                      ),
                      // 목업 — 요일 줄 ↔ 날짜 칸 4.
                      const SizedBox(height: 4),
                      _buildCell(day),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthNavigator extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _MonthNavigator({
    required this.month,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ArrowButton(
          asset: 'assets/imgs/icons/icon_profile_calendar_prev.svg',
          onTap: onPrev,
        ),
        // 목업(1:8244) — 화살표 ↔ 라벨 31.
        const SizedBox(width: 31),
        Text(
          '${month.year}년 ${month.month}월',
          style: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            color: SDSColor.gray900,
          ),
        ),
        const SizedBox(width: 31),
        _ArrowButton(
          asset: 'assets/imgs/icons/icon_profile_calendar_next.svg',
          onTap: onNext,
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final String asset;
  final VoidCallback onTap;

  const _ArrowButton({required this.asset, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // 목업(1:8245)에서 추출한 에셋 — gray100 테두리 원 + 검정 꺾쇠 24.
    return WebIconButton(
      onTap: onTap,
      padding: EdgeInsets.zero,
      icon: SvgPicture.asset(asset, width: 24, height: 24),
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  final String label;

  const _WeekdayLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    // 목업(1:8001) — 요일 칸 높이 24, 글자는 가운데.
    return SizedBox(
      height: 24,
      child: Center(
        child: Text(
          label,
          // 목업(1:8003) — Regular 10, 검정 60%.
          style: SDSTextStyle.regular.copyWith(
            fontSize: 10,
            color: SDSColor.snowliveBlack.withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}

class _EmptyCell extends StatelessWidget {
  const _EmptyCell();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 52);
}

class _DayCell extends StatelessWidget {
  final int day;
  final int? count;
  final bool isSelected;
  final bool isToday;

  /// 다음 달 날짜(그리드 마지막 주 채우기).
  final bool isOutside;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.count,
    required this.isSelected,
    required this.isToday,
    required this.isOutside,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasRecord = count != null;
    final background = isSelected
        ? SDSColor.gray900
        : hasRecord
        ? SDSColor.blue50
        : Colors.transparent;
    final dayColor = isSelected
        ? SDSColor.snowliveWhite
        : isOutside
        ? SDSColor.gray300
        : isToday
        ? SDSColor.snowliveBlue
        : SDSColor.gray900;

    return Padding(
      // 목업 — 칸 46, 칸 사이 6(열 폭 52).
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            // 목업 — 칸 높이 52.
            height: 52,
            // ⚠️ 폭을 주지 않으면 Material이 글자 너비에 맞춰 줄어들어 칸이 알약처럼
            // 보인다(실측). 목업은 열 폭을 채운 **둥근 사각형**이다.
            width: double.infinity,
            child: Padding(
              // 목업(1:8092) — 글자 블록은 위에서 10에 붙는다. 가운데 정렬로 두면
              // 기록 없는 날의 날짜만 아래로 내려가 줄이 어긋난다.
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$day',
                    maxLines: 1,
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 15,
                      color: dayColor,
                    ),
                  ),
                  if (hasRecord) ...[
                    // 목업(1:8096) — 날짜 ↔ 횟수 4, 횟수 Regular 12 검정 50%.
                    const SizedBox(height: 4),
                    Text(
                      '$count',
                      maxLines: 1,
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 12,
                        color: isSelected
                            ? SDSColor.snowliveWhite.withValues(alpha: 0.8)
                            : SDSColor.snowliveBlack.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
