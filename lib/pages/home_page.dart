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
  int _currentIndex = 0;
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
    debugPrint("setting current index to $_currentIndex");
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      debugPrint("setting current index to $_currentIndex");
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      Card(
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.all(8.0),
        child: SizedBox.expand(
          child: Center(
            child: Text(
              'Home page',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
      ),
      const UserInfoPage(),
      UserEventsAttendedPage(
        dbRef: dbRef,
        userId: FirebaseAuth.instance.currentUser!.uid,
      ),
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
    ];

    return Scaffold(
      body: pages[_currentIndex],
      // For some reason, this padding needs to surround the bottom nav bar
      // to work properly on small iOS devices (i.e. iPhone SE)
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(.000001, 0, .000001, 0),
        child: BottomNavigationBar(
          onTap: _onTabTapped,
          currentIndex: _currentIndex,
          items: [
            const BottomNavigationBarItem(
              activeIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              activeIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: 'Settings',
            ),
            const BottomNavigationBarItem(
              activeIcon: Icon(Icons.event),
              icon: Icon(Icons.event_outlined),
              label: 'Events',
            ),
            if (isAdmin)
              const BottomNavigationBarItem(
                activeIcon: Icon(Icons.admin_panel_settings),
                icon: Icon(Icons.admin_panel_settings_outlined),
                label: 'Admin Stuff',
              ),
          ],
        ),
      ),
    );
  }
}
