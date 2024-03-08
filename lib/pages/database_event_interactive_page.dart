import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firebase/firebase_instance_objects.dart';
import '../widgets/other_useful_widgets.dart';

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
        backgroundColor: const Color.fromRGBO(0, 87, 184, 1),
        centerTitle: true,
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double widthFactor =
            (constraints.maxWidth > 650) ? 650 / constraints.maxWidth : 1;
        double widthFactorModifier = (kIsWeb) ? .96 : .93;
        return Consumer(builder: (context, ref, _) {
          eventItemsMap = ref.watch(eventItemsMapProvider);
          getEventItemsFromDatabaseEvent(
                  widget.databaseEvent, widget.dbRef, ref, eventItemsMap)
              .then((value) {
            _selectedEventItems.value = _getEventItemsForEvent(widget.day);
          });
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
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
            ),
          );
        });
      }),
    );
  }
}
