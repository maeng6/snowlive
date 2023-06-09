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
          title: Column(
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
          centerTitle: true,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          elevation: 0.0,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            TableCalendar(
              headerStyle: HeaderStyle(
                titleCentered: false,
                rightChevronIcon: Icon(Icons.arrow_forward_ios_sharp, size: 20, color: Color(0xFF444444),),
                leftChevronIcon: Icon(Icons.arrow_back_ios_sharp, size: 20, color: Color(0xFF444444),),
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF444444)
                ),
                rightChevronPadding: EdgeInsets.only(right: 5, top: 3),
                rightChevronMargin: EdgeInsets.only(right: 0),
                leftChevronMargin: EdgeInsets.only(left: 0),
                leftChevronPadding: EdgeInsets.only(left: 5, top: 3, right: 10),
                formatButtonVisible: false,
              ),
              daysOfWeekHeight: 48,
              rowHeight: 58,
              firstDay: DateTime.utc(2021),
              lastDay: DateTime.utc(2099),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              eventLoader: (day) {
                final dateTime = DateTime(day.year, day.month, day.day);
                return _events[dateTime] ?? [];
              },
              calendarStyle: CalendarStyle(
                markersMaxCount: 1,
                markerSize: 5,
                markerDecoration: BoxDecoration(
                  color: Color(0xFF3D83ED),
                  borderRadius: BorderRadius.circular(5)
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.transparent,
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: Color(0xFF3D83ED),
                  fontWeight: FontWeight.bold,
                  fontSize: 16
                ),
                selectedTextStyle: TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF3D83ED),
                  shape: BoxShape.circle,
                ),
                cellPadding: EdgeInsets.only(bottom: 2, left: 1),
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
                      return Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('월', style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF444444)
                        ),),
                      ),);
                    case 2:
                      return Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('화', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF444444)),),
                      ));
                    case 3:
                      return Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('수', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF444444)),),
                      ));
                    case 4:
                      return Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('목', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF444444)),),
                      ));
                    case 5:
                      return Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('금', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF444444)),),
                      ));
                    case 6:
                      return Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('토', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF444444)),),
                      ));
                    case 7:
                      return Center(child: Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text('일', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFFFF3726)),),
                      ));
                  }
                },
                defaultBuilder: (context, date, events) {
                  final isSelectedDay = isSameDay(_selectedDay, date);
                  final isToday = isSameDay(DateTime.now(), date);

                  return Center(
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelectedDay ? Color(0xFF3D83ED) : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${date.day}',
                          style: TextStyle().copyWith(
                            color: isToday ? Colors.white : Color(0xFF444444),
                            fontSize: isSelectedDay ? 15 : 15,
                            fontWeight: isSelectedDay ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)] != null
                    ? _events[DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)]!.map((event) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ListTile(
                      title: Padding(
                        padding: const EdgeInsets.only(bottom: 2, right: 6, left: 6),
                        child: Text(event.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111111)),),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(right: 6, left: 6),
                        child: Text(
                          '${event.date.day}/${event.date.month}/${event.date.year}',
                        ),
                      ),
                      contentPadding: EdgeInsets.only(top: 4, bottom: 4, right: 16, left: 16),
                    ),
                  );
                }).toList()
                    : [],
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