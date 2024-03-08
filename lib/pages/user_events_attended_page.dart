import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:ais_hackathon_better/widgets/other_useful_widgets.dart';
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
  Map<String, List<EventItem>> eventItemsMap = {};

  List<EventItem> userEventItemsAttended = [];
  List<EventItem> futureUserEventItemsToAttend = [];
  List<EventItem> allEventItemsAttendedOrToAttend = [];
  List<EventItem> passedEventsNotAttended = [];
  List<EventItem> allEvents = [];
  String selectedList = "list1";

  Future<void> _fetchUserEvents() async {
    userEvents = await getListOfUserEvents(widget.dbRef, widget.userId);
    events = await getMapOfEventsFromUserEventsList(widget.dbRef, userEvents);
    await _fetchEventItems();
  }

  Future<void> _fetchEventItems() async {
    eventItemsMap = await getMapOfEventItemsFromEventsMap(widget.dbRef, events);
    await sortEventItems();
    debugPrint("userEventItemsAttended: ${userEventItemsAttended.length}");
    debugPrint(
        "futureUserEventItemsToAttend: ${futureUserEventItemsToAttend.length}");
    debugPrint(
        "allEventItemsAttendedOrToAttend: ${allEventItemsAttendedOrToAttend.length}");
    // calendarItemsMap;
  }

  Future<void> sortEventItems() async {
    userEventItemsAttended.clear();
    futureUserEventItemsToAttend.clear();
    allEventItemsAttendedOrToAttend.clear();
    passedEventsNotAttended.clear();
    allEvents.clear();

    for (var userEvent in userEvents) {
      if (eventItemsMap[userEvent.eventId] == null) {
        continue;
      } else {
        allEvents.addAll(eventItemsMap[userEvent.eventId]!);
        if (userEvent.isAttended) {
          userEventItemsAttended.addAll(eventItemsMap[userEvent.eventId]!);
        }
        if (DateTime.parse(events[userEvent.eventId]!.eventStartTime.toString())
            .isAfter(DateTime.now())) {
          debugPrint(DateTime.now().toString());
          debugPrint(DateTime.parse(
                  events[userEvent.eventId]!.eventStartTime.toString())
              .toString());
          futureUserEventItemsToAttend
              .addAll(eventItemsMap[userEvent.eventId]!);
        }
        if (userEvent.isAttended ||
            DateTime.parse(events[userEvent.eventId]!.eventStartTime.toString())
                .isAfter(DateTime.now())) {
          allEventItemsAttendedOrToAttend
              .addAll(eventItemsMap[userEvent.eventId]!);
        }
        if (!userEvent.isAttended) {
          passedEventsNotAttended.addAll(eventItemsMap[userEvent.eventId]!);
        }
      }
    }
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
              title: Center(
                child: DropdownButton<String>(
                  value: selectedList,
                  onChanged: (newValue) {
                    setState(() {
                      selectedList = newValue!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(
                      value: 'list1',
                      child: Text('Events Attended'),
                    ),
                    DropdownMenuItem(
                      value: 'list2',
                      child: Text('Upcoming Events'),
                    ),
                    DropdownMenuItem(
                      value: 'list3',
                      child: Text('Attended + Upcoming Events'),
                    ),
                    DropdownMenuItem(
                      value: 'list4',
                      child: Text('Missed Events'),
                    ),
                    DropdownMenuItem(
                      value: 'list5',
                      child: Text('All Events'),
                    ),
                  ],
                ),
              ),
            ),
            body: Column(
              children: [
                const SizedBox(height: 20),
                if (selectedList == 'list1')
                  buildList(userEventItemsAttended)
                else if (selectedList == 'list2')
                  buildList(futureUserEventItemsToAttend)
                else if (selectedList == 'list3')
                  buildList(allEventItemsAttendedOrToAttend)
                else if (selectedList == 'list4')
                  buildList(passedEventsNotAttended)
                else if (selectedList == 'list5')
                  buildList(allEvents)
                else
                  const SizedBox(height: 0)
              ],
            ),
          );
        }
      },
    );
  }

  Widget buildList(List<EventItem> list) {
    return Expanded(
        child: ListView.builder(
            itemCount: list.length,
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
                  title: DatabaseEventItemText(
                    eventItem: list[index],
                    dbRef: widget.dbRef,
                    userId: widget.userId,
                  ),
                ),
              );
            }));
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
        password: snapshot.child('password').value.toString(),
        waiver: snapshot.child('waiver').value.toString(),
      )));
    }
  }

  return eventItemsMap;
}
