import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../viewmodel/vm_friendDetail.dart';  // 날짜 형식 변환을 위해 추가

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
      focusedDay = DateTime.now(); // 기본값으로 현재 날짜를 설정
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
    print(selectDay);
    print(focusDay);
    setState(() {
      if (_isMonthAllowed(selectDay)) {
        selectedDay = selectDay;
        focusedDay = focusDay;
        selectedDateFormatted = DateFormat('yyyy-MM-dd').format(selectDay);
        print('Selected date: $selectedDateFormatted');

        DateTime selectDayWithoutTime = DateTime(selectDay.year, selectDay.month, selectDay.day);

        int index = ridingHistory.keys.toList().indexOf(selectDayWithoutTime);
        print(ridingHistory);
        print(index);
        if (index != -1) {
          _friendDetailViewModel.updateSelectedDailyIndex(index);
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
      focusedDay: focusedDay,
      firstDay: DateTime(1900, 11, 1),
      lastDay: DateTime(2100, 3, 31),
      calendarFormat: format,
      onPageChanged: _handlePageChanged,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      daysOfWeekVisible: true,
      onDaySelected: _onDaySelected,
      selectedDayPredicate: (DateTime date) {
        return isSameDay(selectedDay, date);
      },
      eventLoader: _getEventsFromDay,
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayDecoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextFormatter: (date, locale) => DateFormat('yyyy년 M월', 'ko').format(date),
        formatButtonShowsNext: false,
      ),
      calendarBuilders: CalendarBuilders<int>(
        defaultBuilder: (context, date, focusedDay) {
          DateTime dateTime = DateTime(date.year, date.month, date.day);

          bool hasData = ridingHistory[dateTime] != null;

          return Container(
            margin: const EdgeInsets.all(6.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: hasData ? Color(0xFFF0F6FF) : Colors.transparent,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${date.day}',
                  style: TextStyle(color: Colors.black),
                ),
                if (hasData)
                  Text(
                    '${ridingHistory[dateTime]}',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                  )
                else
                  SizedBox(height: 15),
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
