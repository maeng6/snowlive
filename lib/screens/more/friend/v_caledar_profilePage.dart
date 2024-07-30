import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfilePageCalendar extends StatefulWidget {
  @override
  _ProfilePageCalendarState createState() => _ProfilePageCalendarState();
}

class _ProfilePageCalendarState extends State<ProfilePageCalendar> {
  late Map<DateTime, List<Event>> selectedEvents;
  CalendarFormat format = CalendarFormat.month;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();

  @override
  void initState() {
    selectedEvents = {
      DateTime.utc(2024, 7, 13): [Event('32점'),],
      DateTime.utc(2024, 7, 20): [Event('19점')],
    };
    super.initState();
  }

  List<Event> _getEventsFromDay(DateTime date) {
    return selectedEvents[date] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar<Event>(
      focusedDay: focusedDay,
      firstDay: DateTime(1990),
      lastDay: DateTime(2100),
      calendarFormat: format,
      onFormatChanged: (CalendarFormat _format) {
        setState(() {
          format = _format;
        });
      },
      startingDayOfWeek: StartingDayOfWeek.sunday,
      daysOfWeekVisible: true,
      onDaySelected: (DateTime selectDay, DateTime focusDay) {
        setState(() {
          selectedDay = selectDay;
          focusedDay = focusDay;
        });
      },
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
      calendarBuilders: CalendarBuilders<Event>(
        defaultBuilder: (context, date, focusedDay) {
          if (selectedEvents[date] != null && selectedEvents[date]!.isNotEmpty) {
            return Container(
              margin: const EdgeInsets.all(6.0),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                '${date.day}',
                style: TextStyle(color: Colors.black),
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
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return Positioned(
              bottom: 1,
              child: Container(
                width: 60,
                child: Column(
                  children: events.map((event) {
                    return Text(
                      event.title,
                      style: TextStyle(fontSize: 10, color: Colors.black),
                    );
                  }).toList(),
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

class Event {
  final String title;
  Event(this.title);
}
