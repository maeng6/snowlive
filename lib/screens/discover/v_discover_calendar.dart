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

  List<Event> _getEventsForWeek(DateTime selectedDate) {
    final List<Event> eventsForWeek = _events.where((event) {
      final eventDate = event.date;
      final startDate = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
      final endDate = startDate.add(Duration(days: 6));
      return eventDate.isAfter(startDate.subtract(Duration(days: 1))) &&
          eventDate.isBefore(endDate.add(Duration(days: 1)));
    }).toList();

    eventsForWeek.sort((a, b) => a.date.compareTo(b.date));

    return eventsForWeek;
  }

  List<Event> _getEventsForDay(DateTime day) {
    return _events.where((event) {
      final eventDate = event.date;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();
  }

  Widget _buildDayCell(DateTime day) {
    final List<Event> events = _getEventsForDay(day);
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
                fontSize: 11
              ),
            ),
            SizedBox(height: 2),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isToday ? Colors.white : Colors.black,
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
    final List<Event> eventsForWeek = _getEventsForWeek(today);

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Text(
                  '캘린더',
                  style: TextStyle(
                    color: Color(0xFF111111),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  Get.to(()=>Discover_Calendar_Detail_Screen());
                },
                child: Container(
                  child: Text(
                    '일정 더보기 >',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              children: weekDates.map((day) => _buildDayCell(day)).toList(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                decoration: BoxDecoration(
                    color: Color(0xFFFAFAFB),
                    borderRadius: BorderRadius.circular(8)
                ),
                child:
                (_events.isNotEmpty)
                ? Column(
                  children: eventsForWeek.map((event) => ListTile(
                    title: Text(event.title),
                    subtitle: Text(
                      '${event.date.day}/${event.date.month}/${event.date.year}',
                    ),
                  )).toList(),
                )
                : Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Image.asset(
                        'assets/imgs/icons/icon_nodata.png',
                        scale: 4,
                        width: 73,
                        height: 73,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text('일정이 없습니다.',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                            color: Color(0xFF949494)
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String title;
  final DateTime date;

  Event(this.title, this.date);
}