import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class ProfilePageCalendar extends StatefulWidget {
  @override
  _ProfilePageCalendarState createState() => _ProfilePageCalendarState();
}

class _ProfilePageCalendarState extends State<ProfilePageCalendar> {
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  late Map<DateTime, int> ridingHistory;
  CalendarFormat format = CalendarFormat.month;
  late DateTime selectedDay;
  late DateTime focusedDay;
  String selectedDateFormatted = ''; // 선택된 날짜를 저장할 변수
  late DateTime firstDay;  // 시즌 시작 날짜 (예: 2024년 11월 1일)
  late DateTime lastDay;   // 시즌 종료 날짜 (예: 2025년 3월 31일)

  @override
  void initState() {
    super.initState();

    // 시즌 데이터에서 firstDay와 lastDay 설정
    firstDay = DateTime.parse(_friendDetailViewModel.seasonStartDate);  // 시즌 시작일 설정
    lastDay = DateTime.parse(_friendDetailViewModel.seasonEndDate);    // 시즌 종료일 설정

    // 라이딩 기록을 초기화
    if (_friendDetailViewModel.friendDetailModel.calendarInfo.isNotEmpty) {
      ridingHistory = {
        for (var info in _friendDetailViewModel.friendDetailModel.calendarInfo)
          DateTime(DateTime.parse(info.date).year, DateTime.parse(info.date).month, DateTime.parse(info.date).day): info.daily_total_count,
      };
    } else {
      ridingHistory = {}; // 비어 있는 경우 빈 맵으로 초기화
    }

    // ridingHistory가 비어 있지 않은 경우, 가장 최근 날짜로 초기 포커스를 설정
    focusedDay = ridingHistory.isNotEmpty ? ridingHistory.keys.first : DateTime.now().toLocal();
    selectedDay = focusedDay;
  }

  List<int> _getEventsFromDay(DateTime date) {
    DateTime dateTime = DateTime(date.year, date.month, date.day);
    return [ridingHistory[dateTime] ?? 0]; // 이벤트가 없는 날은 0을 반환
  }

  void _onDaySelected(DateTime selectDay, DateTime focusDay) {
    setState(() {
      selectedDay = DateTime(selectDay.year, selectDay.month, selectDay.day);
      focusedDay = DateTime(focusDay.year, focusDay.month, focusDay.day);
      selectedDateFormatted = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(selectedDay);

      DateTime selectDayWithoutTime = selectedDay;

      int index = ridingHistory.keys.toList().indexOf(selectDayWithoutTime);
      if (index != -1) {
        _friendDetailViewModel.updateSelectedDailyIndex(index);
      } else {
        _friendDetailViewModel.updateSelectedDailyIndex(-1);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      availableGestures: AvailableGestures.horizontalSwipe,
      focusedDay: focusedDay,
      firstDay: firstDay,    // 시즌 시작일 (예: 2024년 11월 1일)
      lastDay: lastDay,      // 시즌 종료일 (예: 2025년 3월 31일)
      calendarFormat: format,
      onPageChanged: (newFocusedDay) {
        setState(() {
          focusedDay = newFocusedDay; // 페이지가 전환되면 새로 포커스된 날짜로 업데이트
        });
      },
      startingDayOfWeek: StartingDayOfWeek.sunday,
      daysOfWeekVisible: true,
      onDaySelected: _onDaySelected,
      eventLoader: _getEventsFromDay,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        isTodayHighlighted: true,
        selectedDecoration: BoxDecoration(
          color: SDSColor.gray900,
          borderRadius: BorderRadius.circular(8.0),
        ),
        selectedTextStyle: SDSTextStyle.bold.copyWith(
          color: SDSColor.snowliveWhite,
        ),
        todayTextStyle: SDSTextStyle.bold.copyWith(
            color: SDSColor.snowliveBlue),
      ),
      headerStyle: HeaderStyle(
        headerPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 50),
        titleTextStyle: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            color: SDSColor.gray900),
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) => DateFormat('yyyy년 M월', 'ko').format(date),
        formatButtonShowsNext: false,
        leftChevronIcon: Image.asset(
          'assets/imgs/icons/icon_profile_calendar_btn_left.png',
          fit: BoxFit.cover,
          width: 30,
          height: 30,
        ),
        rightChevronIcon: Image.asset(
          'assets/imgs/icons/icon_profile_calendar_btn.png',
          fit: BoxFit.cover,
          width: 30,
          height: 30,
        ),
      ),
      daysOfWeekHeight: 40,
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: SDSTextStyle.regular.copyWith(
            color: SDSColor.gray500,
            fontSize: 13),
        weekendStyle: SDSTextStyle.regular.copyWith(
            color: SDSColor.red,
            fontSize: 13),
        dowTextFormatter: (date, locale) {
          return DateFormat.E('ko_KR').format(date).substring(0, 1); // '월', '화', '수', '목', '금', '토', '일' 표기
        },
        decoration: BoxDecoration(
          color: SDSColor.snowliveWhite,
        ),
      ),
      calendarBuilders: CalendarBuilders<int>(
        defaultBuilder: (context, date, focusedDay) {
          DateTime dateTime = DateTime(date.year, date.month, date.day);
          int? ridingCount = ridingHistory[dateTime];

          bool hasData = ridingHistory[dateTime] != null;

          return Container(
            margin: const EdgeInsets.all(2),
            padding: EdgeInsets.only(top: 5, bottom: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color:
              (isSameDay(selectedDay, dateTime)) ?
              SDSColor.gray900
                  : hasData ? SDSColor.blue50 : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${date.day}',
                  style: SDSTextStyle.bold.copyWith(
                      color:
                      (isSameDay(selectedDay, dateTime))
                          ? SDSColor.snowliveBlue
                          : SDSColor.gray900,
                      fontSize: 14),
                ),
                if (hasData)
                  Text(
                    '${ridingHistory[dateTime]}',
                    style: SDSTextStyle.regular.copyWith(
                        fontSize: 13,
                        color:
                        (isSameDay(selectedDay, dateTime))
                            ? SDSColor.snowliveWhite
                            : SDSColor.gray500),
                  )
                else
                  Container()
              ],
            ),
          );
        },
        markerBuilder: (context, date, _) {
          return SizedBox.shrink();
        },
      ),
    );
  }
}
