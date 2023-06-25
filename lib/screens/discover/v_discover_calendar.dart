import 'package:carousel_slider/carousel_slider.dart';
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
  List<Event> _events2 = [];
  List<Event> _events3 = [];

  late final PageController _controller;
  int _current = 0;



  @override
  void initState() {
    super.initState();
    _fetchEvents();
    _fetchEvents2();
    _fetchEvents3();
    super.initState();
    _controller = PageController(initialPage: _current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  //TODO: Calendar_week1**************************************************

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

  //TODO: Calendar_week1**************************************************

 //TODO: Calendar_week2**************************************************

  Future<void> _fetchEvents2() async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final startOfNextWeek = startOfWeek.add(Duration(days: 7));
    final endOfNextWeek = endOfWeek.add(Duration(days: 7));

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .doc('${_userModelController.favoriteResort}')
        .collection('1')
        .where('date', isGreaterThanOrEqualTo: startOfNextWeek, isLessThanOrEqualTo: endOfNextWeek)
        .get();

    setState(() {
      _events2 = eventsSnapshot.docs.map((doc) {
        final title = doc['title'] as String;
        final date = (doc['date'] as Timestamp).toDate();
        return Event(title, date);
      }).toList();
    });
  }

  List<DateTime> _getNextWeekDates(DateTime selectedDate) {
    final List<DateTime> weekDates2 = [];
    final DateTime firstDayOfNextWeek = selectedDate.add(Duration(days: 7 - selectedDate.weekday + 1));

    for (int i = 0; i < 7; i++) {
      final DateTime day = firstDayOfNextWeek.add(Duration(days: i));
      weekDates2.add(day);
    }

    return weekDates2;
  }

  Map<DateTime, List<Event>> _getEventsForWeek2(DateTime selectedDate) {
    final Map<DateTime, List<Event>> eventsForWeek2 = {};

    final startOfNextWeek = selectedDate.add(Duration(days: 7 - selectedDate.weekday + 1));
    final endOfNextWeek = startOfNextWeek.add(Duration(days: 6));

    _events2.forEach((event) {
      final eventDate = event.date;

      if (eventDate.isAfter(startOfNextWeek.subtract(Duration(days: 1))) &&
          eventDate.isBefore(endOfNextWeek.add(Duration(days: 1)))) {
        if (eventsForWeek2.containsKey(DateTime(eventDate.year, eventDate.month, eventDate.day))) {
          eventsForWeek2[DateTime(eventDate.year, eventDate.month, eventDate.day)]!.add(event);
        } else {
          eventsForWeek2[DateTime(eventDate.year, eventDate.month, eventDate.day)] = [event];
        }
      }
    });

    return eventsForWeek2;
  }
  Widget _buildDayCell2(DateTime day) {
    final List<Event> events = _events2.where((event) {
      final eventDate = event.date;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();

    final bool isToday =
        DateTime.now().day == day.day && DateTime.now().month == day.month && DateTime.now().year == day.year;
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
  }

 //TODO: Calendar_week2**************************************************

  //TODO: Calendar_week3**************************************************

  Future<void> _fetchEvents3() async {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final startOfNextNextWeek = startOfWeek.add(Duration(days: 14));
    final endOfNextNextWeek = endOfWeek.add(Duration(days: 14));

    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .doc('${_userModelController.favoriteResort}')
        .collection('1')
        .where('date', isGreaterThanOrEqualTo: startOfNextNextWeek, isLessThanOrEqualTo: endOfNextNextWeek)
        .get();

    setState(() {
      _events3 = eventsSnapshot.docs.map((doc) {
        final title = doc['title'] as String;
        final date = (doc['date'] as Timestamp).toDate();
        return Event(title, date);
      }).toList();
    });
  }

  List<DateTime> _getNextNextWeekDates(DateTime selectedDate) {
    final List<DateTime> weekDates3 = [];
    final DateTime firstDayOfNextNextWeek = selectedDate.add(Duration(days: 14 - selectedDate.weekday + 1));

    for (int i = 0; i < 7; i++) {
      final DateTime day = firstDayOfNextNextWeek.add(Duration(days: i));
      weekDates3.add(day);
    }

    return weekDates3;
  }

  Map<DateTime, List<Event>> _getEventsForWeek3(DateTime selectedDate) {
    final Map<DateTime, List<Event>> eventsForWeek3 = {};

    final startOfNextNextWeek = selectedDate.add(Duration(days: 14 - selectedDate.weekday + 1));
    final endOfNextNextWeek = startOfNextNextWeek.add(Duration(days: 6));

    _events3.forEach((event) {
      final eventDate = event.date;

      if (eventDate.isAfter(startOfNextNextWeek.subtract(Duration(days: 1))) &&
          eventDate.isBefore(endOfNextNextWeek.add(Duration(days: 1)))) {
        if (eventsForWeek3.containsKey(DateTime(eventDate.year, eventDate.month, eventDate.day))) {
          eventsForWeek3[DateTime(eventDate.year, eventDate.month, eventDate.day)]!.add(event);
        } else {
          eventsForWeek3[DateTime(eventDate.year, eventDate.month, eventDate.day)] = [event];
        }
      }
    });

    return eventsForWeek3;
  }
  Widget _buildDayCell3(DateTime day) {
    final List<Event> events = _events3.where((event) {
      final eventDate = event.date;
      return eventDate.year == day.year &&
          eventDate.month == day.month &&
          eventDate.day == day.day;
    }).toList();

    final bool isToday =
        DateTime.now().day == day.day && DateTime.now().month == day.month && DateTime.now().year == day.year;
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
  }

//TODO: Calendar_week3**************************************************


  Widget buildIndicator(int index) {
    return Container(
      margin: EdgeInsets.only(top: 12, right: 6),
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _current == index ? Color(0xFF949494) : Color(0xFFDEDEDE),  // 현재 인덱스에 따라 색상을 변경합니다.
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    final DateTime today = DateTime.now();
    final List<DateTime> weekDates = _getWeekDates(today);
    final List<DateTime> weekDates2 = _getNextWeekDates(today);
    final List<DateTime> weekDates3 = _getNextNextWeekDates(today);

    final Map<DateTime, List<Event>> eventsForWeek = _getEventsForWeek(today);
    final Map<DateTime, List<Event>> eventsForWeek2 = _getEventsForWeek2(today);
    final Map<DateTime, List<Event>> eventsForWeek3 = _getEventsForWeek3(today);


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
                    fontSize: 16,
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    padding: EdgeInsets.zero,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Color(0xFFF5f5f5)
                    ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                          onPressed: (){},
                          icon: Icon(Icons.arrow_back_ios_sharp, size: 14, color: Color(0xFF777777),)
                      )
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Container(
                      width: 32,
                      height: 32,
                      padding: EdgeInsets.zero,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: Color(0xFFf5f5f5)
                      ),
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: (){},
                          icon: Icon(Icons.arrow_forward_ios_sharp, size: 14, color: Color(0xFF777777),)
                      )
                  )
                ],
              )
            ],
          ),
          SizedBox(height: 10),
          CarouselSlider(
            items: [
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 82),
                    child: (_events.isNotEmpty)
                        ? Padding(
                      padding: EdgeInsets.only(right: 20, left: 20, top: 20),
                      child: CustomScrollView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                var entry = eventsForWeek.entries.elementAt(index);
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
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: eventsForWeek.entries.length,
                            ),
                          ),
                        ],
                      ),
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
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
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: weekDates.map((day) => _buildDayCell(day)).toList(),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 82),
                    child: (_events2.isNotEmpty)
                        ? Padding(
                      padding: EdgeInsets.only(right: 20, left: 20, top: 20),
                      child: CustomScrollView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                var entry = eventsForWeek2.entries.elementAt(index);
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
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: eventsForWeek2.entries.length,
                            ),
                          ),
                        ],
                      ),
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
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
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: weekDates2.map((day) => _buildDayCell2(day)).toList(),
                  ),
                ),
              ],
            ),
            Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                      color: Color(0xFFFAFAFB),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 82),
                    child: (_events3.isNotEmpty)
                        ? Padding(
                      padding: EdgeInsets.only(right: 20, left: 20, top: 20),
                      child: CustomScrollView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        slivers: <Widget>[
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                var entry = eventsForWeek3.entries.elementAt(index);
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
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: eventsForWeek3.entries.length,
                            ),
                          ),
                        ],
                      ),
                    )
                        : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
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
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: Row(
                    children: weekDates3.map((day) => _buildDayCell3(day)).toList(),
                  ),
                ),
              ],
            ),
          ], options: CarouselOptions(
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            initialPage: 0,
            viewportFraction: 1,
            onPageChanged: (index, reason){
              setState(() {
                _current = index;
              });
            }
          ),),
          SizedBox(height: 5),
          Row(
           mainAxisAlignment: MainAxisAlignment.center,
           children: List.generate(3, (index) => buildIndicator(index))), // 3은 슬라이드의 총 개수입니다.
          ElevatedButton(
            onPressed: () {
              Get.to(()=>Discover_Calendar_Detail_Screen());
            },
            child: Padding(
              padding: const EdgeInsets.only(bottom: 1),
              child: Text(
                '전체 일정 보기',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            style: TextButton.styleFrom(
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                ),
                elevation: 0,
                splashFactory: InkRipple.splashFactory,
                minimumSize: Size(1000, 42),
                backgroundColor: Color(0xff3D83ED),
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

