import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:snowlive3/screens/discover/v_discover_Calendar_Detail.dart';


class DiscoverScreen_Calendar extends StatefulWidget {
  @override
  _DiscoverScreen_CalendarState createState() => _DiscoverScreen_CalendarState();
}

class _DiscoverScreen_CalendarState extends State<DiscoverScreen_Calendar> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************

  List<Event> _events = [];

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  //TODO: Calendar**************************************************

  Future<void> _fetchEvents() async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - (today.weekday - 1)));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .doc('${_userModelController.favoriteResort}')
        .collection('1')
        .get();

    setState(() {
      _events = eventsSnapshot.docs.map((doc) {
        final title = doc['title'] as String;
        final date = (doc['date'] as Timestamp).toDate();
        return Event(title, date);
      }).toList();
    });
  }

  List<DateTime> _getWeekDates(DateTime selectedDate) {
    final List<DateTime> weekDates = [];
    final int dayOfWeek = selectedDate.weekday;

    final DateTime firstDayOfWeek = selectedDate.subtract(Duration(days: dayOfWeek - 1));

    for (int i = 0; i < 7; i++) {
      final DateTime day = firstDayOfWeek.add(Duration(days: i));
      weekDates.add(day);
    }

    return weekDates;
  }

  Map<DateTime, List<Event>> _getEventsForWeek(DateTime selectedDate) {
    final Map<DateTime, List<Event>> eventsForWeek = {};

    _events.forEach((event) {
      final eventDate = event.date;
      final startDate = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      final endDate = startDate.add(Duration(days: 6));

      if (eventDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          eventDate.isBefore(endDate.add(Duration(days: 1)))) {
        if (eventsForWeek.containsKey(DateTime(eventDate.year, eventDate.month, eventDate.day))) {
          eventsForWeek[DateTime(eventDate.year, eventDate.month, eventDate.day)]!.add(event);
        } else {
          eventsForWeek[DateTime(eventDate.year, eventDate.month, eventDate.day)] = [event];
        }
      }
    });

    return eventsForWeek;
  }

  Widget _buildDayCell(DateTime day) {
    final List<Event> events = _events.where((event) {
      final eventDate = event.date;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();

    final bool isToday = DateTime.now().day == day.day && DateTime.now().month == day.month && DateTime.now().year == day.year;
    final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final String weekday = weekdays[day.weekday - 1]; // 날짜의 요일 가져오기

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isToday ? Color(0xFF3D83ED) : Colors.transparent,
        ),
        height: 68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              weekday, // 요일 출력
              style: TextStyle(
                fontSize: 11,
                color: isToday ? Colors.white : Color(0xFF111111),
              ),
            ),
            SizedBox(height: 2),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Color(0xFF111111),
              ),
            ),
            SizedBox(height: 6),
            Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: events.isNotEmpty ? isToday ? Color(0xFFFFFFFF) : Color(0xFF666666) : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  } // 달력 날짜 표시 영역 위젯

  //TODO: Calendar**************************************************

  @override
  Widget build(BuildContext context) {

    final DateTime today = DateTime.now();
    final List<DateTime> weekDates = _getWeekDates(today);
    final Map<DateTime, List<Event>> eventsForWeek = _getEventsForWeek(today);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.zero,
                    topRight: Radius.zero,
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
              ),
              child: Padding(
                padding: EdgeInsets.only(top: 82),
                child: (_events.isNotEmpty)
                    ? Padding(
                  padding: EdgeInsets.only(right: 20, left: 20, top: 20),
                  child: Column(
                    children: eventsForWeek.entries.map((entry) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              height: 28,
                              width: 72,
                              child: Text(
                                '${entry.key.year}.${entry.key.month}.${entry.key.day}',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF3D83ED)
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: entry.value.map((event) => Container(
                                  height: 32,
                                  child: Transform.translate(
                                    offset: Offset(0,-19),
                                    child: ListTile(
                                      title: Text(event.title,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: Color(0xFF111111)
                                        ),),
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                )
                    : Center(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Text(
                          '일정이 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF111111),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                  color: Color(0xFFFAFAFB),
                  borderRadius: BorderRadius.circular(8)
              ),
              child: Row(
                children: weekDates.map((day) => _buildDayCell(day)).toList(),
              ),
            ),
          ],
        ),

      ],
    );
  }
}

class Event {
  final String title;
  final DateTime date;

  Event(this.title, this.date);
}