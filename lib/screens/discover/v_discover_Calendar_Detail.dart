import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:snowlive3/controller/vm_userModelController.dart';
import 'package:table_calendar/table_calendar.dart';

class Discover_Calendar_Detail_Screen extends StatefulWidget {
  @override
  _Discover_Calendar_Detail_ScreenState createState() => _Discover_Calendar_Detail_ScreenState();
}

class _Discover_Calendar_Detail_ScreenState extends State<Discover_Calendar_Detail_Screen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  //TODO: Dependency Injection**************************************************



  late CalendarFormat _calendarFormat;
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  Map<DateTime, List<Event>> _events = {};

  @override
  void initState() {
    super.initState();
    _calendarFormat = CalendarFormat.month;
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    final eventsSnapshot = await FirebaseFirestore.instance
        .collection('schedule')
        .doc('${_userModelController.favoriteResort}')
        .collection('1')
        .get();

    setState(() {
      _events = eventsSnapshot.docs.fold({}, (Map<DateTime, List<Event>> map, doc) {
        final title = doc['title'] as String;
        final date = (doc['date'] as Timestamp).toDate();
        final event = Event(title, date);
        final dateTime = DateTime(date.year, date.month, date.day);

        if (map.containsKey(dateTime)) {
          map[dateTime]!.add(event);
        } else {
          map[dateTime] = [event];
        }

        return map;
      });
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: AppBar(
          leading: GestureDetector(
            child: Image.asset(
              'assets/imgs/icons/icon_snowLive_back.png',
              scale: 4,
              width: 26,
              height: 26,
            ),
            onTap: () {
              Get.back();
            },
          ),
          title: Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Column(
              children: [
                Text(
                  '캘린더',
                  style: GoogleFonts.notoSans(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.w900,
                      fontSize: 20),
                ),
              ],
            ),
          ),
          centerTitle: true,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronVisible: false,
              rightChevronVisible: false,
            ),
            daysOfWeekHeight: 30,
            rowHeight: 50,
            firstDay: DateTime.utc(2021),
            lastDay: DateTime.utc(2099),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: (day) {
              final dateTime = DateTime(day.year, day.month, day.day);
              return _events[dateTime] ?? [];
            },
            calendarStyle: CalendarStyle(
              markerSize: 5,
              markerMargin: EdgeInsets.only(top: 3),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5)
              ),
              todayDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            calendarBuilders: CalendarBuilders(
              dowBuilder: (context, day) {
                switch(day.weekday){
                  case 1:
                    return Center(child: Text('월'),);
                  case 2:
                    return Center(child: Text('화'),);
                  case 3:
                    return Center(child: Text('수'),);
                  case 4:
                    return Center(child: Text('목'),);
                  case 5:
                    return Center(child: Text('금'),);
                  case 6:
                    return Center(child: Text('토', style: TextStyle(color: Colors.blue),),);
                  case 7:
                    return Center(child: Text('일',style: TextStyle(color: Colors.red),),);
                }
              },
              defaultBuilder: (context, date, events) {
                final isSelectedDay = isSameDay(_selectedDay, date);
                final isToday = isSameDay(DateTime.now(), date);

                return Center(
                  child: Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.all(4.0),
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelectedDay ? Colors.blue : Colors.transparent,
                        width: isSelectedDay ? 2.0 : 0.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${date.day}',
                        style: TextStyle().copyWith(
                          color: isToday ? Colors.red : Colors.black,
                          fontSize: isSelectedDay ? 16.0 : 14.0,
                          fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 15),
          Expanded(
            child: ListView(
              children: _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] != null
                  ? _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]!.map((event) {
                return ListTile(
                  title: Text(event.title),
                  subtitle: Text(
                    '${event.date.day}/${event.date.month}/${event.date.year}',
                  ),
                );
              }).toList()
                  : [],
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