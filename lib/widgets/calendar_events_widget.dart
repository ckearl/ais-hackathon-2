import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:ais_hackathon_better/widgets/riverpod_stuff.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';

import 'other_useful_widgets.dart';

final eventsMapProvider =
    StateNotifierProvider<EventsMapNotifier, Map<DateTime, List<Event>>>(
  (ref) => EventsMapNotifier(),
);

class CalendarEventsPage extends StatefulWidget {
  final DatabaseReference dbRef;
  final String userId;
  final WidgetRef ref;
  const CalendarEventsPage({
    super.key,
    required this.dbRef,
    required this.userId,
    required this.ref,
  });

  @override
  State<CalendarEventsPage> createState() => _CalendarEventsPageState();
}

class _CalendarEventsPageState extends State<CalendarEventsPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<Event>> eventsMap = {};
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    getEventsFromDatabase(widget.dbRef, widget.ref, eventsMap);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This allows us to update the information on the page without reloading the entire thing
    return LayoutBuilder(builder: (context, constraints) {
      double widthFactor =
          (constraints.maxWidth > 650) ? 650 / constraints.maxWidth : 1;
      double widthFactorModifier = (kIsWeb) ? .96 : .93;
      return Consumer(
        builder: (context, ref, _) {
          eventsMap = ref.watch(eventsMapProvider);
          getEventsFromDatabase(widget.dbRef, ref, eventsMap);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FractionallySizedBox(
                widthFactor: widthFactor * widthFactorModifier,
                child: TableCalendar(
                  rowHeight: (constraints.maxHeight * .3) / 6,
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
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ValueListenableBuilder<List<Event>>(
                  valueListenable: _selectedEvents,
                  builder: (context, value, _) {
                    return ListView.builder(
                      itemCount: value.length,
                      itemBuilder: (context, index) {
                        return FractionallySizedBox(
                          widthFactor: widthFactor * widthFactorModifier,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 4.0,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: ListTile(
                              onTap: () {},
                              title: Column(
                                children: [
                                  DatabaseEventText(
                                    databaseEvent: value[index],
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 2, 0, 2),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DatabaseEventInteractiveWidget(
                                              databaseEvent: value[index],
                                              dbRef: widget.dbRef,
                                              ref: ref,
                                              day: _focusedDay,
                                            ),
                                          ),
                                        );
                                      },
                                      child: const Text(
                                        "More Info",
                                        style: TextStyle(
                                            color:
                                                Color.fromRGBO(0, 46, 93, 1)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      );
    });
  }

  // });

  List<Event> _getEventsForDay(DateTime day) {
    List<Event> events = [];
    for (var event in eventsMap.keys) {
      if (eventsMap[event] != null) {
        for (var item in eventsMap[event]!) {
          if (isSameDay(item.eventStartTime, day) ||
              (item.eventEndTime.isAfter(day) &&
                  item.eventStartTime.isBefore(day))) {
            events.add(item);
          }
        }
      }
    }
    return events;
  }
}

Future<Map<DateTime, List<Event>>> getEventsFromDatabase(
  DatabaseReference dbRef,
  WidgetRef? ref,
  Map<DateTime, List<Event>> eventsMap,
) async {
  DataSnapshot eventsSnapshot = (await dbRef.child('events').once()).snapshot;

  for (var event in eventsSnapshot.children) {
    if (eventsMap[
            DateTime.parse(event.child('eventStartTime').value.toString())] ==
        null) {
      eventsMap[
              DateTime.parse(event.child('eventStartTime').value.toString())] =
          <Event>[];
    }

    Event eventToAdd = Event(
      eventId: event.key!,
      eventDescription: event.child('eventDescription').value.toString(),
      eventTitle: event.child('eventTitle').value.toString(),
      eventStartTime:
          DateTime.parse(event.child('eventStartTime').value.toString()),
      eventEndTime:
          DateTime.parse(event.child('eventEndTime').value.toString()),
      eventLocation: event.child('eventLocation').value.toString(),
      eventInfo: event.child('eventInfo').value.toString(),
    );

    List<Event> compList = eventsMap[
            DateTime.parse(event.child('eventStartTime').value.toString())] ??
        [];
    bool foundMatch = false;
    if (compList.isNotEmpty) {
      for (var checkEvent in compList) {
        if (eventToAdd.toString() == checkEvent.toString()) foundMatch = true;
      }
    }

    if (!foundMatch) {
      eventsMap[DateTime.parse(event.child('eventStartTime').value.toString())]!
          .add(eventToAdd);
    }
  }

  ref?.read(eventsMapProvider.notifier).setEvents(eventsMap);
  return eventsMap;
}
