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
  Set<Event> events = {};
  Set<EventItem> eventItems = {};

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  Future<void> _fetchUserEvents() async {
    // Fetch the user's attendance data from the userEvents node in the
    // realtime database
    DataSnapshot userEventSnapshot = (await widget.dbRef
            .child('userEvents')
            .orderByChild('userID')
            .equalTo(widget.userId)
            .once())
        .snapshot;
    debugPrint("snapshot: ${userEventSnapshot.children.length}");

    // Loop through user's attendance data
    for (var element in userEventSnapshot.children) {
      userEvents.add(UserEvent(
        userEventId: element.key!,
        userId: element.child('userID').value.toString(),
        eventId: element.child('eventID').value.toString(),
        isAttended: (element.child('userID').value.toString() == "false")
            ? false
            : true,
        broughtPlusOne:
            (element.child('broughtPlusOne').value.toString() == "false")
                ? false
                : true,
        waiverSigned:
            (element.child('waiverSigned').value.toString() == "false")
                ? false
                : true,
      ));

      debugPrint("EventID: ${userEvents.last.eventId}");
      debugPrint(
        "Event info for user event: ${(await widget.dbRef.child('events/'
            '${userEvents.last.eventId}').once()).snapshot.children.length}",
      );
      debugPrint("\n\n");
      DataSnapshot eventSnapshot =
          (await widget.dbRef.child('events/${userEvents.last.eventId}').once())
              .snapshot;
      events.add(Event(
        eventId: eventSnapshot.key!,
        eventDescription:
            eventSnapshot.child('eventDescription').value.toString(),
        eventTitle: eventSnapshot.child('eventTitle').value.toString(),
        eventStartTime: DateTime.parse(
            eventSnapshot.child('eventStartTime').value.toString()),
        eventEndTime: DateTime.parse(
            eventSnapshot.child('eventEndTime').value.toString()),
        eventLocation: eventSnapshot.child('eventLocation').value.toString(),
        eventInfo: eventSnapshot.child('eventInfo').value.toString(),
      ));
      debugPrint("${events.last.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Events"),
      ),
      body: ListView.builder(
        itemCount: userEvents.length,
        itemBuilder: (context, index) {
          UserEvent event = userEvents[index];
          return ListTile(
            title: Text("Type${event.eventId}: ${event.eventId}"),
            subtitle: Text(event.userId),
          );
        },
      ),
    );
  }
}
