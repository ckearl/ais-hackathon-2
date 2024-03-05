import 'package:ais_hackathon_better/widgets/user_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../widgets/user_events_attended_page.dart';

class NavigationBarApp extends StatelessWidget {
  final String uid;
  const NavigationBarApp({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: NavigationExample(uid: uid),
    );
  }
}

class NavigationExample extends StatefulWidget {
  final String uid;
  const NavigationExample({super.key, required this.uid});

  @override
  State<NavigationExample> createState() => _NavigationExampleState();
}

class _NavigationExampleState extends State<NavigationExample> {
  final dbRef = FirebaseDatabase.instance.ref();
  int currentPageIndex = 0;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();

    FirebaseDatabase.instance
        .ref()
        .child("users/${widget.uid}")
        .child('isAdmin')
        .onValue
        .listen((event) {
      if (mounted) {
        setState(() {
          (event.snapshot.value.toString() == 'false')
              ? isAdmin = false
              : isAdmin = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: <Widget>[
          const NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Badge(child: Icon(Icons.settings_outlined)),
            label: 'Settings',
          ),
          const NavigationDestination(
            selectedIcon: Icon(Icons.event),
            icon: Badge(child: Icon(Icons.event_outlined)),
            label: 'Events',
          ),
          if (isAdmin)
            const NavigationDestination(
              selectedIcon: Icon(Icons.admin_panel_settings),
              icon: Badge(
                child: Icon(Icons.admin_panel_settings_outlined),
              ),
              label: 'Admin Stuff',
            ),
        ],
      ),
      body: <Widget>[
        /// Home page
        Card(
          shadowColor: Colors.transparent,
          margin: const EdgeInsets.all(8.0),
          child: SizedBox.expand(
            child: Center(
              child: Text(
                'Home page',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
        ),

        /// User Settings page
        const UserInfoPage(),

        /// Messages page
        // TODO change this to a list view for each event in the database
        // TODO maybe make it a calendar view and have it be selectable
        UserEventsAttendedPage(
          dbRef: dbRef,
          userId: FirebaseAuth.instance.currentUser!.uid,
        ),

        // ListView.builder(
        //   reverse: true,
        //   itemCount: 2,
        //   itemBuilder: (BuildContext context, int index) {
        //     if (index == 0) {
        //       return Align(
        //         alignment: Alignment.centerRight,
        //         child: Container(
        //           margin: const EdgeInsets.all(8.0),
        //           padding: const EdgeInsets.all(8.0),
        //           decoration: BoxDecoration(
        //             color: theme.colorScheme.primary,
        //             borderRadius: BorderRadius.circular(8.0),
        //           ),
        //           child: Text(
        //             'Hello',
        //             style: theme.textTheme.bodyLarge!
        //                 .copyWith(color: theme.colorScheme.onPrimary),
        //           ),
        //         ),
        //       );
        //     }
        //     return Align(
        //       alignment: Alignment.centerLeft,
        //       child: Container(
        //         margin: const EdgeInsets.all(8.0),
        //         padding: const EdgeInsets.all(8.0),
        //         decoration: BoxDecoration(
        //           color: theme.colorScheme.primary,
        //           borderRadius: BorderRadius.circular(8.0),
        //         ),
        //         child: Text(
        //           'Hi!',
        //           style: theme.textTheme.bodyLarge!
        //               .copyWith(color: theme.colorScheme.onPrimary),
        //         ),
        //       ),
        //     );
        //   },
        // ),

        /// Admin page
        if (isAdmin)
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text("You are an admin!")],
              )
            ],
          )
      ][currentPageIndex],
    );
  }
}