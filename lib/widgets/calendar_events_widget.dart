import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarEventsPage extends StatefulWidget {
  final DatabaseReference dbRef;
  final String userId;
  const CalendarEventsPage({
    super.key,
    required this.dbRef,
    required this.userId,
  });

  @override
  State<CalendarEventsPage> createState() => _CalendarEventsPageState();
}

class _CalendarEventsPageState extends State<CalendarEventsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, Event> eventsMap = {};
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getEventsFromDatabase(widget.dbRef),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While the future is loading, show a loading indicator
            return const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              ],
            );
          } else if (snapshot.hasError) {
            // If there's an error in the future, display an error message
            return Text('Error: ${snapshot.error}');
          } else {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2010, 10, 16),
                  lastDay: DateTime.utc(2050, 3, 14),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay =
                          focusedDay; // update `_focusedDay` here as well
                      _selectedEvents.value = _getEventsForDay(selectedDay);
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    // No need to call `setState()` here
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    return _getEventsForDay(day);
                  },
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return ListView.builder(
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              onTap: () => debugPrint("${value[index]}"),
                              title: Text("${value[index]}"),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        });
  }

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> events = [];
    for (var event in eventsMap.keys) {
      if (isSameDay(event, day)) {
        events.add(eventsMap[event]!);
      }
    }
    return events;
  }

  Future<void> _getEventsFromDatabase(DatabaseReference dbRef) async {
    DataSnapshot eventsSnapshot = (await dbRef.child('events').once()).snapshot;

    for (var event in eventsSnapshot.children) {
      eventsMap[
              DateTime.parse(event.child('eventStartTime').value.toString())] =
          (Event(
        eventId: event.key!,
        eventDescription: event.child('eventDescription').value.toString(),
        eventTitle: event.child('eventTitle').value.toString(),
        eventStartTime:
            DateTime.parse(event.child('eventStartTime').value.toString()),
        eventEndTime:
            DateTime.parse(event.child('eventEndTime').value.toString()),
        eventLocation: event.child('eventLocation').value.toString(),
        eventInfo: event.child('eventInfo').value.toString(),
      ));
    }

    return;
  }
}
