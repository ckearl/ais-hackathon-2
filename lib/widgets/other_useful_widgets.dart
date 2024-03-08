import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart';
import 'package:ais_hackathon_better/widgets/riverpod_stuff.dart';
import 'package:firebase_database/firebase_database.dart';
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

class DatabaseEventItemText extends StatefulWidget {
  final EventItem eventItem;
  final DatabaseReference dbRef;
  final String userId;
  const DatabaseEventItemText({
    super.key,
    required this.eventItem,
    required this.dbRef,
    required this.userId,
  });

  @override
  State<DatabaseEventItemText> createState() => _DatabaseEventItemTextState();
}

class _DatabaseEventItemTextState extends State<DatabaseEventItemText> {
  late bool moreInfo;
  late bool isAttended;
  late bool userActuallyAttended;
  late bool needToCreateUserEventEntry;
  String errorMessage = "";
  final passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    moreInfo = false;
    isAttended = false;
    userActuallyAttended = false;
    needToCreateUserEventEntry = true;
  }

  @override
  void dispose() {
    passwordController.dispose();
    super.dispose();
  }

  Future<bool> userEventExistsAndWasAttended() async {
    DataSnapshot userEventsSnapshot =
        (await widget.dbRef.child('userEvents').once()).snapshot;
    List userEventsForCurrentUser =
        userEventsSnapshot.children.where((element) {
      if (element.child('eventID').value == widget.eventItem.eventId &&
          element.child('userID').value == widget.userId) {
        return true;
      } else {
        return false;
      }
    }).toList();

    if (userEventsForCurrentUser.isEmpty) {
      debugPrint("User event DNE..");
    } else {
      for (var element in userEventsForCurrentUser) {
        needToCreateUserEventEntry = false;
        if (element.child('isAttended').value.toString() == "true") {
          debugPrint("Returning true, user already attended");
          userActuallyAttended = true;
          return true;
        } else {
          debugPrint(
              "Returning false, user hasn't already attended but event exists");
          return false;
        }
      }
    }

    needToCreateUserEventEntry = true;
    debugPrint("Returning false, user did not attend and event DNE");
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("MM-dd-yy HH:mm");
    return FutureBuilder(
        future: userEventExistsAndWasAttended(),
        builder: (context, snapshot) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  widget.eventItem.eventItemTitle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "\n${widget.eventItem.eventItemInfo}"
                  "\nLocation: ${widget.eventItem.eventItemLocation}"
                  "\nStart Time: ${dateFormat.format(widget.eventItem.eventItemStartTime)}"
                  "\nEnd Time: ${dateFormat.format(widget.eventItem.eventItemEndTime)}",
                  textAlign: TextAlign.start,
                ),
                if (moreInfo) moreInfoWidget(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        moreInfo = !moreInfo;
                      });
                    },
                    child: Text(
                      (moreInfo) ? "Less Info" : "More Info / Mark Attendance",
                      style:
                          const TextStyle(color: Color.fromRGBO(0, 46, 93, 1)),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget moreInfoWidget() {
    if (!userActuallyAttended) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Padding(padding: EdgeInsets.all(4.0)),
          GestureDetector(
            onTap: () {
              setState(() {
                isAttended = !isAttended;
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Checkbox(
                  activeColor: const Color.fromRGBO(0, 46, 93, 1),
                  value: isAttended,
                  onChanged: (bool? value) {
                    setState(() {
                      isAttended = value!;
                    });
                  },
                ),
                const Text('Did you attend this event?')
              ],
            ),
          ),
          if (moreInfo &&
              isAttended &&
              DateTime.now().isBefore(widget.eventItem.eventItemEndTime) &&
              DateTime.now().isAfter(widget.eventItem.eventItemStartTime))
            const Text("Verify location if during event"),
          if (moreInfo && isAttended) verifyPasswordWidget(),
        ],
      );
    } else {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text("You've attended this event!"),
      );
    }
  }

  Widget verifyPasswordWidget() {
    return FractionallySizedBox(
      widthFactor: .9,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            child: FractionallySizedBox(
              widthFactor: .9,
              child: TextField(
                controller: passwordController,
                cursorColor: Colors.black,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: "Event Password",
                  labelStyle: TextStyle(color: Color.fromRGBO(0, 87, 184, 1)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color.fromRGBO(0, 87, 184, 1)),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (errorMessage != "")
            Text(
              errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 2, 0, 2),
            child: ElevatedButton(
              onPressed: () {
                debugPrint(widget.eventItem.password);
                debugPrint(
                    "${widget.eventItem.password == passwordController.text}");
                if (passwordController.text != widget.eventItem.password) {
                  setState(() {
                    errorMessage = "Invalid Password! Try Again..";
                  });
                } else {
                  if (userActuallyAttended == false) {
                    if (needToCreateUserEventEntry == true) {
                      // TODO
                      debugPrint("Need to create user entry");
                    } else {
                      // TODO
                      debugPrint(
                          "Need to update database entry that already exists");
                    }
                  }
                  // widget.dbRef.child('userEvent')
                  setState(() {
                    errorMessage = "";
                  });
                }
              },
              child: const Text(
                "Check Password",
                style: TextStyle(color: Color.fromRGBO(0, 46, 93, 1)),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
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
        password: eventItem.child('password').value.toString(),
        waiver: eventItem.child('waiver').value.toString(),
      ));
    }
  }

  ref?.read(eventItemsMapProvider.notifier).setEventItems(eventItemsMap);
  return eventItemsMap;
}
