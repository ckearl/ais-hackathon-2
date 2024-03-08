import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:ais_hackathon_better/widgets/riverpod_stuff.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final eventItemsMapProvider =
    StateNotifierProvider<EventItemsMapNotifier, Map<DateTime, EventItem>>(
  (ref) => EventItemsMapNotifier(),
);

class DatabaseEventText extends StatelessWidget {
  final Event databaseEvent;
  const DatabaseEventText({super.key, required this.databaseEvent});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("MM-dd-yy HH:mm");
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text(
          databaseEvent.eventTitle,
          textAlign: TextAlign.center,
        ),
        Text(
          "\n${databaseEvent.eventInfo}"
          "\nLocation: ${databaseEvent.eventLocation}"
          "\nStart Time: ${dateFormat.format(databaseEvent.eventStartTime)}"
          "\nEnd Time: ${dateFormat.format(databaseEvent.eventEndTime)}",
          textAlign: TextAlign.start,
        ),
      ],
    );
  }
}

class DatabaseEventItemText extends StatelessWidget {
  final EventItem eventItem;
  const DatabaseEventItemText({super.key, required this.eventItem});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("MM-dd-yy HH:mm");
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Text(
            eventItem.eventItemTitle,
            textAlign: TextAlign.center,
          ),
          Text(
            "\n${eventItem.eventItemInfo}"
            "\nLocation: ${eventItem.eventItemLocation}"
            "\nStart Time: ${dateFormat.format(eventItem.eventItemStartTime)}"
            "\nEnd Time: ${dateFormat.format(eventItem.eventItemEndTime)}",
            textAlign: TextAlign.start,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
            child: ElevatedButton(
              onPressed: () {},
              child: const Text(
                "More Info",
                style: TextStyle(color: Color.fromRGBO(0, 46, 93, 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DatabaseEventInteractiveWidget extends StatefulWidget {
  final Event databaseEvent;
  final DatabaseReference dbRef;
  final WidgetRef ref;
  final DateTime day;
  const DatabaseEventInteractiveWidget({
    super.key,
    required this.databaseEvent,
    required this.dbRef,
    required this.ref,
    required this.day,
  });

  @override
  State<DatabaseEventInteractiveWidget> createState() =>
      _DatabaseEventInteractiveWidgetState();
}

class _DatabaseEventInteractiveWidgetState
    extends State<DatabaseEventInteractiveWidget> {
  Map<DateTime, EventItem> eventItemsMap = {};
  late final ValueNotifier<List<EventItem>> _selectedEventItems;

  @override
  void initState() {
    super.initState();

    _selectedEventItems = ValueNotifier(_getEventItemsForEvent(widget.day));
    getEventItemsFromDatabaseEvent(
        widget.databaseEvent, widget.dbRef, widget.ref, eventItemsMap);
    debugPrint("Day: ${widget.day}");
  }

  @override
  void dispose() {
    _selectedEventItems.dispose();
    super.dispose();
  }

  List<EventItem> _getEventItemsForEvent(DateTime day) {
    debugPrint("Get event items for event called");
    debugPrint("Keys: ${eventItemsMap.keys.length}");
    List<EventItem> eventItems = [];
    for (var item in eventItemsMap.keys) {
      if (eventItemsMap[item]?.eventId == widget.databaseEvent.eventId) {
        eventItems.add(eventItemsMap[item]!);
      }
    }
    return eventItems;
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _selectedEventItems.value = _getEventItemsForEvent(widget.day);
      debugPrint("${_selectedEventItems.value}");
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.databaseEvent.eventTitle),
        centerTitle: true,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double widthFactor =
            (constraints.maxWidth > 650) ? 650 / constraints.maxWidth : 1;
        double widthFactorModifier = (kIsWeb) ? .96 : .93;
        return Consumer(builder: (context, ref, _) {
          eventItemsMap = ref.watch(eventItemsMapProvider);
          debugPrint("eventItemsMap: $eventItemsMap");
          getEventItemsFromDatabaseEvent(
                  widget.databaseEvent, widget.dbRef, ref, eventItemsMap)
              .then((value) {
            _selectedEventItems.value = _getEventItemsForEvent(widget.day);
          });
          return Center(
            child: Column(
              children: [
                DatabaseEventText(databaseEvent: widget.databaseEvent),
                const SizedBox(height: 8),
                Expanded(
                  child: ValueListenableBuilder<List<EventItem>>(
                    valueListenable: _selectedEventItems,
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
                                onTap: () {
                                  debugPrint("${value[index]}");
                                },
                                title: DatabaseEventItemText(
                                  eventItem: value[index],
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
            ),
          );
        });
      }),
    );
  }
}

Future<Map<DateTime, EventItem>> getEventItemsFromDatabaseEvent(
  Event event,
  DatabaseReference dbRef,
  WidgetRef? ref,
  Map<DateTime, EventItem> eventItemsMap,
) async {
  final eventID = event.eventId;
  DataSnapshot eventItemsSnapshot =
      (await dbRef.child('eventItems').once()).snapshot;

  for (var eventItem in eventItemsSnapshot.children) {
    if (eventItem.child('eventID').value == eventID) {
      eventItemsMap[DateTime.parse(
          eventItem.child('eventItemStartTime').value.toString())] = (EventItem(
        eventItemId: eventItem.key!,
        eventItemTitle: eventItem.child('eventItemTitle').value.toString(),
        eventItemStartTime: DateTime.parse(
            eventItem.child('eventItemStartTime').value.toString()),
        eventItemEndTime: DateTime.parse(
            eventItem.child('eventItemEndTime').value.toString()),
        eventItemLocation:
            eventItem.child('eventItemLocation').value.toString(),
        eventItemInfo: eventItem.child('eventItemInfo').value.toString(),
        eventId: eventItem.child('eventID').value.toString(),
        eventItemType: eventItem.child('eventItemType').value.toString(),
        waiver: eventItem.child('waiver').value.toString(),
      ));
    }
  }

  ref?.read(eventItemsMapProvider.notifier).setEventItems(eventItemsMap);
  return eventItemsMap;
}
