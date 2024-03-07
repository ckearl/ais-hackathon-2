import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserEventsAttendedPage extends StatefulWidget {
  final DatabaseReference dbRef;
  final String userId;
  const UserEventsAttendedPage({
    super.key,
    required this.dbRef,
    required this.userId,
  });

  @override
  State<UserEventsAttendedPage> createState() => _UserEventsAttendedPageState();
}

class _UserEventsAttendedPageState extends State<UserEventsAttendedPage> {
  List<UserEvent> userEvents = [];
  Map<String, Event> events = {};
  Set<EventItem> eventItems = {};
  Map<String, List<EventItem>> eventItemsMap = {};

  Future<void> _fetchUserEvents() async {
    userEvents = await getListOfUserEvents(widget.dbRef, widget.userId);
    events = await getMapOfEventsFromUserEventsList(widget.dbRef, userEvents);
    await _fetchEventItems();
  }

  Future<void> _fetchEventItems() async {
    eventItemsMap = await getMapOfEventItemsFromEventsMap(widget.dbRef, events);
    // calendarItemsMap;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _fetchUserEvents(),
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
          // If the future has completed successfully, you can build your UI
          // using the data fetched by _fetchUserEvents()
          return Scaffold(
            appBar: AppBar(
              title: const Center(
                child: Text(
                  "User Events",
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            body: Center(
              child: SizedBox(
                child: ListView.builder(
                  itemCount: userEvents.length,
                  itemBuilder: (context, index) {
                    UserEvent userEvent = userEvents[index];
                    // If event has been attended or hasn't occurred yet, show it in the list.
                    if (userEvent.isAttended ||
                        DateTime.parse(events[userEvent.eventId]!
                                .eventStartTime
                                .toString())
                            .isAfter(DateTime.now())) {
                      return ListTile(
                        // TODO change this to Event Title: Type
                        title: Text(
                          "Type ${eventItemsMap[userEvent.eventId]?.first.eventItemTitle}: "
                          "${EventItemType(
                            eventItemTypeId: eventItemsMap[userEvent.eventId]!
                                .first!
                                .eventItemType,
                            typeName: "Discover",
                          ).typeName}", //(widget.dbRef.child('eventTypes').once()).snapshot.child('typeName/${eventItems.firstWhere((element) => element.eventId == userEvent.eventId).eventItemType}').value.toString()).typeName}",
                          textAlign: TextAlign.center,
                        ),
                        subtitle: Text(
                          eventItemsMap[userEvent.eventId]!
                              .first!
                              .eventItemInfo,
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

Future<List<UserEvent>> getListOfUserEvents(
  DatabaseReference dbRef,
  String userID,
) async {
  List<UserEvent> userEvents = [];
  DataSnapshot userEventSnapshot = (await dbRef
          .child('userEvents')
          .orderByChild('userID')
          .equalTo(userID)
          .once())
      .snapshot;

  for (var element in userEventSnapshot.children) {
    userEvents.add(UserEvent(
      userEventId: element.key!,
      userId: element.child('userID').value.toString(),
      eventId: element.child('eventID').value.toString(),
      isAttended: (element.child('isAttended').value.toString() == "false")
          ? false
          : true,
      broughtPlusOne:
          (element.child('broughtPlusOne').value.toString() == "false")
              ? false
              : true,
      waiverSigned: (element.child('waiverSigned').value.toString() == "false")
          ? false
          : true,
    ));
  }

  return userEvents;
}

Future<Map<String, Event>> getMapOfEventsFromUserEventsList(
  DatabaseReference dbRef,
  List<UserEvent> userEvents,
) async {
  Map<String, Event> eventsMap = {};

  for (var event in userEvents) {
    DataSnapshot eventSnapshot =
        (await dbRef.child('events/${event.eventId}').once()).snapshot;

    eventsMap[eventSnapshot.key!] = (Event(
      eventId: eventSnapshot.key!,
      eventDescription:
          eventSnapshot.child('eventDescription').value.toString(),
      eventTitle: eventSnapshot.child('eventTitle').value.toString(),
      eventStartTime: DateTime.parse(
          eventSnapshot.child('eventStartTime').value.toString()),
      eventEndTime:
          DateTime.parse(eventSnapshot.child('eventEndTime').value.toString()),
      eventLocation: eventSnapshot.child('eventLocation').value.toString(),
      eventInfo: eventSnapshot.child('eventInfo').value.toString(),
    ));
  }

  return eventsMap;
}

Future<Map<String, List<EventItem>>> getMapOfEventItemsFromEventsMap(
  DatabaseReference dbRef,
  Map<String, Event> events,
) async {
  Map<String, List<EventItem>> eventItemsMap = {};

  DataSnapshot eventItemsSnapshot =
      (await dbRef.child('eventItems').once()).snapshot;
  for (var snapshot in eventItemsSnapshot.children) {
    if (events[snapshot.child('eventID').value.toString()] != null) {
      if (eventItemsMap[snapshot.child('eventID').value.toString()] == null) {
        eventItemsMap[snapshot.child('eventID').value.toString()] = [];
      }

      eventItemsMap[snapshot.child('eventID').value.toString()]?.add((EventItem(
        eventItemId: snapshot.key!,
        eventItemTitle: snapshot.child('eventItemTitle').value.toString(),
        eventItemLocation: snapshot.child('eventItemLocation').value.toString(),
        eventItemInfo: snapshot.child('eventItemInfo').value.toString(),
        eventId: snapshot.child('eventID').value.toString(),
        eventItemStartTime: DateTime.parse(
            snapshot.child('eventItemStartTime').value.toString()),
        eventItemEndTime:
            DateTime.parse(snapshot.child('eventItemEndTime').value.toString()),
        eventItemType: snapshot.child('eventItemType').value.toString(),
        waiver: snapshot.child('waiver').value.toString(),
      )));
    }
  }

  return eventItemsMap;
}
