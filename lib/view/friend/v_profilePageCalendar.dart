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

  @override
  void initState() {
    super.initState();

    // ridingHistory 초기화 및 예외 처리
    if (_friendDetailViewModel.friendDetailModel.calendarInfo.isNotEmpty) {
      ridingHistory = {
        for (var info in _friendDetailViewModel.friendDetailModel.calendarInfo)
          DateTime(DateTime.parse(info.date).year, DateTime.parse(info.date).month, DateTime.parse(info.date).day): info.daily_total_count,
      };
    } else {
      ridingHistory = {}; // 비어 있는 경우 빈 맵으로 초기화
    }

    print(ridingHistory);

    // ridingHistory가 비어 있지 않은 경우, 가장 최근 날짜로 초기 포커스를 설정
    if (ridingHistory.isNotEmpty) {
      focusedDay = ridingHistory.keys.first;
    } else {
      focusedDay = DateTime.now().toLocal(); // 기본값으로 현재 날짜를 설정
    }

    selectedDay = focusedDay;

    // 처음 로딩 시 허용된 월로 자동 이동
    if (!_isMonthAllowed(focusedDay)) {
      focusedDay = _getClosestAllowedMonth(focusedDay);
    }
  }

  bool _isMonthAllowed(DateTime date) {
    // 11월, 12월, 1월, 2월, 3월만 허용
    return date.month == 11 ||
        date.month == 12 ||
        date.month == 1 ||
        date.month == 2 ||
        date.month == 3;
  }

  DateTime _getClosestAllowedMonth(DateTime date) {
    // 현재 날짜에서 가까운 허용된 월로 이동
    int year = date.year;
    if (date.month >= 4 && date.month <= 10) {
      return DateTime(year, 11, 1); // 11월로 이동
    } else if (date.month > 3 && date.month < 11) {
      return DateTime(year, 11, 1); // 11월로 이동
    }
    return DateTime(year, date.month, 1);
  }

  void _handlePageChanged(DateTime newFocusedDay) {
    setState(() {
      if (!_isMonthAllowed(newFocusedDay)) {
        if (newFocusedDay.month > 3 && newFocusedDay.month < 11) {
          // 4월에서 10월로 이동한 경우, 이전 또는 다음 허용 월로 이동
          if (newFocusedDay.isBefore(focusedDay)) {
            focusedDay = DateTime(newFocusedDay.year, 3, 1);
          } else {
            focusedDay = DateTime(newFocusedDay.year, 11, 1);
          }
        } else {
          // 허용된 월로 이동
          focusedDay = _getClosestAllowedMonth(newFocusedDay);
        }
      } else {
        focusedDay = newFocusedDay;
      }
    });
  }

  List<int> _getEventsFromDay(DateTime date) {
    DateTime dateTime = DateTime(date.year, date.month, date.day);

    return [ridingHistory[dateTime] ?? 0]; // 이벤트가 없는 날은 0을 반환
  }

  void _onDaySelected(DateTime selectDay, DateTime focusDay) {

    setState(() {
      if (_isMonthAllowed(selectDay)) {
        selectedDay = DateTime(selectDay.year, selectDay.month, selectDay.day);
        focusedDay = DateTime(focusDay.year, focusDay.month, focusDay.day);
        selectedDateFormatted = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(selectedDay);
        print('Selected date: $selectedDateFormatted');

        DateTime selectDayWithoutTime = selectedDay;

        // 디버깅을 위한 코드
        ridingHistory.forEach((key, value) {
          print('Key: $key, Value: $value');
          if (key == selectDayWithoutTime) {
            print('Match found for $selectDayWithoutTime');
          }
        });

        int index = ridingHistory.keys.toList().indexOf(selectDayWithoutTime);
        print('Index found: $index');

        if (index != -1) {
          _friendDetailViewModel.updateSelectedDailyIndex(index);

          print('Selected Day Local: $selectedDay');
          print('Selected Day Without Time Local: $selectDayWithoutTime');

        } else {
          _friendDetailViewModel.updateSelectedDailyIndex(-1);
          print('선택된 날짜가 ridingHistory에 없습니다.');

        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      availableGestures: AvailableGestures.horizontalSwipe,
      focusedDay: focusedDay,
      firstDay: DateTime(1900, 11, 1),
      lastDay: DateTime(2100, 3, 31),
      calendarFormat: format,
      onPageChanged: _handlePageChanged,
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
            color: SDSColor.snowliveBlue
        ),
      ),
      headerStyle: HeaderStyle(
        headerPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 50),
        titleTextStyle: SDSTextStyle.bold.copyWith(
            fontSize: 16,
            color: SDSColor.gray900
        ),
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
            fontSize: 13
        ),
        weekendStyle: SDSTextStyle.regular.copyWith(
            color: SDSColor.red,
            fontSize: 13
        ),
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

          print('Date: $dateTime, Riding Count: $ridingCount');

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
