import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../../../viewmodel/vm_friendDetail.dart';  // 날짜 형식 변환을 위해 추가

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

    ridingHistory = {
      for (var info in _friendDetailViewModel.friendDetailModel.calendarInfo)
        DateTime(DateTime.parse(info.date).year, DateTime.parse(info.date).month, DateTime.parse(info.date).day): info.daily_total_count,
    };

    print(ridingHistory);

    // 가장 최근 날짜로 초기 포커스를 설정
    focusedDay = ridingHistory.keys.first;
    selectedDay = focusedDay;

    // 처음 로딩 시 허용된 월로 자동 이동
    if (!_isMonthAllowed(focusedDay)) {
      focusedDay = _getClosestAllowedMonth(focusedDay);
    }

    super.initState();
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
            // 이전 페이지로 이동한 경우, 이전 해의 3월로 이동
            focusedDay = DateTime(newFocusedDay.year, 3, 1);
          } else {
            // 다음 페이지로 이동한 경우, 다음 해의 11월로 이동
            focusedDay = DateTime(newFocusedDay.year, 11, 1);
          }
        } else {
          // 허용된 월(11, 12, 1, 2, 3)로 이동
          focusedDay = _getClosestAllowedMonth(newFocusedDay);
        }
      } else {
        // 허용된 월인 경우 그냥 업데이트
        focusedDay = newFocusedDay;
      }
    });
  }

  List<int> _getEventsFromDay(DateTime date) {
    return [ridingHistory[date] ?? 0];
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

        // selectDay의 시간 부분을 00:00:00으로 설정
        DateTime selectDayWithoutTime = DateTime(selectDay.year, selectDay.month, selectDay.day);

        // 인덱스를 계산해서 뷰모델의 메서드를 호출
        int index = ridingHistory.keys.toList().indexOf(selectDayWithoutTime);
        print(ridingHistory);
        print(index);
        if (index != -1) {
          _friendDetailViewModel.updateSelectedDailyIndex(index);
        } else {
          print('선택된 날짜가 ridingHistory에 없습니다.');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      focusedDay: focusedDay,
      firstDay: DateTime(1900, 11, 1), // 범위를 매우 넓게 설정
      lastDay: DateTime(2100, 3, 31), // 범위를 매우 넓게 설정
      calendarFormat: format,
      onPageChanged: _handlePageChanged,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      daysOfWeekVisible: true,
      onDaySelected: _onDaySelected, // 날짜 선택 시 호출되는 함수
      selectedDayPredicate: (DateTime date) {
        return isSameDay(selectedDay, date);
      },
      eventLoader: _getEventsFromDay,
      calendarStyle: CalendarStyle(
        isTodayHighlighted: true,
        selectedDecoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        selectedTextStyle: TextStyle(color: Colors.white),
        todayDecoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: true,
        titleCentered: true,
        formatButtonShowsNext: false,
      ),
      calendarBuilders: CalendarBuilders<int>(
        defaultBuilder: (context, date, focusedDay) {
          if (ridingHistory[date] != null) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Column(
                children: [
                  Text(
                    '${date.day}',
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(color: Colors.black),
              ),
            );
          }
        },
        markerBuilder: (context, date, _) {
          if (ridingHistory[date] != null) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 60,
                child: Text(
                  '${ridingHistory[date]}',
                  style: TextStyle(fontSize: 10, color: Colors.black),
                ),
              ),
            );
          }
          return SizedBox.shrink();
        },
      ),
    );
  }
}


