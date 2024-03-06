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

  Future<void> _fetchUserEvents() async {
    debugPrint("Fetching user events");
    debugPrint(
        "awaiting: ${await widget.dbRef.child('userEvents').orderByChild('userID').equalTo(widget.userId).once()}");
    // Fetch the user's attendance data from the userEvents node in the
    // realtime database
    DataSnapshot userEventSnapshot = (await widget.dbRef
            .child('userEvents')
            .orderByChild('userID')
            .equalTo(widget.userId)
            .once())
        .snapshot;
    debugPrint("Total expected loops: ${userEventSnapshot.children.length}");

    // Loop through user's attendance data
    for (var element in userEventSnapshot.children) {
      debugPrint("Looping");
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

      DataSnapshot eventSnapshot =
          (await widget.dbRef.child('events/${userEvents.last.eventId}').once())
              .snapshot;
      events[eventSnapshot.key!] = (Event(
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
    }
    debugPrint("User Events: ${userEvents.length}");

    debugPrint("Looking for event items");
    await _fetchEventItems();
    debugPrint("Event items found");
  }

  Future<void> _fetchEventItems() async {
    debugPrint("Fetching event items");
    DataSnapshot eventItemsSnapshot =
        (await widget.dbRef.child('eventItems').once()).snapshot;
    for (var snapshot in eventItemsSnapshot.children) {
      if (events[snapshot.child('eventID').value.toString()] != null) {
        debugPrint(
            "Event found matching the ID: ${snapshot.child('eventID').value}");
        eventItems.add(EventItem(
          eventItemId: snapshot.key!,
          eventItemTitle: snapshot.child('eventItemTitle').value.toString(),
          eventItemLocation:
              snapshot.child('eventItemLocation').value.toString(),
          eventItemInfo: snapshot.child('eventItemInfo').value.toString(),
          eventId: snapshot.child('eventID').value.toString(),
          eventItemStartTime: DateTime.parse(
              snapshot.child('eventItemStartTime').value.toString()),
          eventItemEndTime: DateTime.parse(
              snapshot.child('eventItemEndTime').value.toString()),
          waiver: snapshot.child('waiver').value.toString(),
        ));
      }
      debugPrint(eventItems.last.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("User Events: ${userEvents.length}");
    debugPrint("Events: ${events.length}");
    debugPrint("Event Items: ${eventItems.length}");
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
                    UserEvent event = userEvents[index];
                    return ListTile(
                      title: Text(
                        "Type${event.eventId}: ${event.eventId}",
                        textAlign: TextAlign.center,
                      ),
                      subtitle: Text(
                        event.userId,
                        textAlign: TextAlign.center,
                      ),
                    );
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
