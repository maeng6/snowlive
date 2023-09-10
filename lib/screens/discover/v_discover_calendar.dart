import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/discover/v_discover_Calendar_Detail.dart';

class DiscoverScreen_Calendar extends StatefulWidget {
  @override
  _DiscoverScreen_CalendarState createState() => _DiscoverScreen_CalendarState();
}

class _DiscoverScreen_CalendarState extends State<DiscoverScreen_Calendar> {
  UserModelController _userModelController = Get.find<UserModelController>();

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final DateTime endOfWeek = startOfWeek.add(Duration(days: 6));

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('schedule')
          .doc('${_userModelController.instantResort}')
          .collection('1')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfWeek))
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final eventsSnapshot = snapshot.data!;
        final events = eventsSnapshot.docs.map((doc) {
          final title = doc['title'] as String;
          final date = (doc['date'] as Timestamp).toDate();
          return Event(title, date);
        }).toList();

        final List<DateTime> weekDates = _getWeekDates(today);
        final Map<DateTime, List<Event>> eventsForWeek = _getEventsForWeek(weekDates, events);

        final List<DateTime> datesWithEvents = eventsForWeek.keys.toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                      bottomRight: Radius.circular(14),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 82),
                    child: (events.isNotEmpty)
                        ? Padding(
                      padding: EdgeInsets.only(right: 20, left: 20, top: 20),
                      child: Column(
                        children: weekDates.map((day) {
                          final bool hasEvents = datesWithEvents.contains(day);
                          final List<Event> dayEvents = eventsForWeek[day] ?? [];
                          return hasEvents
                              ? Padding(
                            padding: EdgeInsets.only(bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  height: 28,
                                  width: 72,
                                  child: Text(
                                    '${day.year}.${day.month}.${day.day}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3D83ED),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: dayEvents.map((event) => Container(
                                      height: 32,
                                      child: Transform.translate(
                                        offset: Offset(0, -19),
                                        child: ListTile(
                                          title: Text(
                                            event.title,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                              color: Color(0xFF111111),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )).toList(),
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Container(); // 이벤트가 없는 경우에는 빈 컨테이너 반환
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
                                color: Color(0xFF949494),
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
                    color: Color(0xFF3D83ED).withOpacity(0.16),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(14),
                      topRight: Radius.circular(14),
                      bottomLeft: Radius.zero,
                      bottomRight: Radius.zero,
                    ),
                  ),
                  child: Row(
                    children: weekDates.map((day) {
                      final bool hasEvents = datesWithEvents.contains(day);
                      return _buildDayCell(day, hasEvents);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
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

  Map<DateTime, List<Event>> _getEventsForWeek(List<DateTime> weekDates, List<Event> events) {
    final Map<DateTime, List<Event>> eventsForWeek = {};

    weekDates.forEach((day) {
      final List<Event> dayEvents = events.where((event) =>
      event.date.year == day.year &&
          event.date.month == day.month &&
          event.date.day == day.day).toList();
      if (dayEvents.isNotEmpty) {
        eventsForWeek[day] = dayEvents;
      }
    });

    return eventsForWeek;
  }

  Widget _buildDayCell(DateTime day, bool hasEvents) {
    final DateTime now = DateTime.now();
    final bool isToday = now.day == day.day && now.month == day.month && now.year == day.year;
    final List<String> weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final String weekday = weekdays[day.weekday - 1];

    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: isToday ? Color(0xFF3D83ED) : Colors.transparent,
        ),
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                weekday,
                style: TextStyle(
                  fontSize: 11,
                  color: isToday ? Colors.white : Color(0xFF111111),
                ),
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
            SizedBox(height: 2),
            Container(
              height: 4,
              width: 4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: hasEvents ? (isToday ? Color(0xFFFFFFFF) : Color(0xFF666666)) : Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Event {
  final String title;
  final DateTime date;

  Event(this.title, this.date);
}
