import 'dart:async';

import 'package:ais_hackathon_better/firebase_instance_objects.dart'
    as db_object;
import 'package:firebase_auth/firebase_auth.dart' as fb_user;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  bool stateAlreadySet = false;
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dbRef = FirebaseDatabase.instance.ref();
  late final DatabaseReference dbUserRef;
  late fb_user.User user;
  late Map<String, dynamic> userObjectMap;

  @override
  void initState() {
    super.initState();
    final user = fb_user.FirebaseAuth.instance.currentUser;
    var userId = user?.uid;
    DatabaseReference dbUserRef = dbRef.child('users/$userId');

    // Default user object
    userObjectMap = <String, dynamic>{
      'fname': "FirstNameNotSet",
      'lname': "LastNameNotSet",
      'email': "email@domain.lol",
      'username': "email@domain.lol",
      'isAdmin': false,
    };

    setListeners(dbUserRef);
  }

  // Sets all listeners so that user info can be updated manually from the
  // realtime database side and be auto updated on the user interface.
  void setListeners(DatabaseReference dbUserRef) {
    // Listener which checks if the firebase realtime database has any manual
    // changes on its end for this user's first name.
    dbUserRef.child('fname').onValue.listen((event) {
      if (mounted) {
        setState(() {
          userObjectMap['fname'] = event.snapshot.value.toString();
        });
      }
    });

    // Listener which checks if the firebase realtime database has any manual
    // changes on its end for this user's last name.
    dbUserRef.child('lname').onValue.listen((event) {
      if (mounted) {
        setState(() {
          userObjectMap['lname'] = event.snapshot.value.toString();
        });
      }
    });

    // Listener which checks if the firebase realtime database has any manual
    // changes on its end for this user's username.
    dbUserRef.child('username').onValue.listen((event) {
      if (mounted) {
        setState(() {
          userObjectMap['username'] = event.snapshot.value.toString();
        });
      }
    });

    // Listener which checks if the firebase realtime database has any manual
    // changes on its end for this user's email.
    dbUserRef.child('email').onValue.listen((event) {
      if (mounted) {
        setState(() {
          userObjectMap['email'] = event.snapshot.value.toString();
        });
      }
    });

    // Listener which checks if the firebase realtime database has any manual
    // changes on its end for this user's admin privileges.
    dbUserRef.child('isAdmin').onValue.listen((event) {
      if (mounted) {
        setState(() {
          userObjectMap['isAdmin'] =
              (event.snapshot.value.toString() == 'false') ? false : true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // User is signed in. Get the reference of the user from the database.
    // Does this in real time and auto updates if the database is changed manually.

    // customObj.User currentUser;
    // dbUserRef.once(DatabaseEventType.value).then((value) {
    //   debugPrint(value.snapshot.value.toString());
    //   currentUser =
    //       customObj.User.fromJson(jsonDecode(jsonEncode(value.snapshot.value)));
    //   debugPrint("User: ${currentUser.toString()}");
    // });

    // dbUserRef.onValue.listen((event) {
    //   setState(() {
    //     debugPrint("Showing user data");
    //     debugPrint(event.snapshot.value.toString());
    //   });
    // });

    // // Get the user's last name from the database
    // dbUserRef.child('lname').onValue.listen((event) {
    //   setState(() {
    //     lastName = event.snapshot.value.toString();
    //   });
    // });
    // // Get the user's username from the database
    // dbUserRef.child('username').onValue.listen((event) {
    //   setState(() {
    //     username = event.snapshot.value.toString();
    //   });
    // });
    // // Get the user's email from the database
    // dbUserRef.child('email').onValue.listen((event) {
    //   setState(() {
    //     email = event.snapshot.value.toString();
    //   });
    // });
    // // Determine user's permissions from database value
    // dbUserRef.child('isAdmin').onValue.listen((event) {
    //   setState(() {
    //     if (event.snapshot.value.toString() == "false") {
    //       isAdmin = false;
    //     } else {
    //       isAdmin = true;
    //     }
    //   });
    // });

    // if (snapshot.hasData)
    db_object.User currUser = db_object.User.fromJson(userObjectMap);
    String firstName = currUser.fname;
    String lastName = currUser.lname;
    String username = currUser.username;
    String email = currUser.email;
    bool isAdmin = currUser.isAdmin;
    // TODO use later

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Signed In as:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              "Email: $email",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Username: $username",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "First Name: $firstName",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Last Name: $lastName",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "Admin Privileges: $isAdmin",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(
                Icons.arrow_back,
                size: 32,
              ),
              label: const Text(
                'Sign Out',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () async {
                fb_user.FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Future<Map<String, dynamic>> fetchUser(DatabaseReference dbUserRef) async {
  //   Completer<Map<String, dynamic>> userObjectMap =
  //       Completer<Map<String, dynamic>>();
  //
  //   dbUserRef.onValue.listen((event) async {
  //     String firstName = await fetchUserFirstName(dbUserRef);
  //     debugPrint("First name from User: $firstName");
  //
  //     String lastName = await fetchUserLastName(dbUserRef);
  //     debugPrint("Last name from User: $lastName");
  //
  //     String email = await fetchUserEmail(dbUserRef);
  //     debugPrint("Email from User: $email");
  //
  //     String username = await fetchUserUsername(dbUserRef);
  //     debugPrint("Username from User: $username");
  //
  //     bool isAdmin = await fetchUserAdminPrivilege(dbUserRef);
  //     debugPrint("Admin privilege from User: $isAdmin");
  //
  //     userObjectMap.complete({
  //       'fname': firstName,
  //       'lname': lastName,
  //       'email': email,
  //       'username': username,
  //       'isAdmin': isAdmin,
  //     });
  //   });
  //
  //   return userObjectMap.future;
  // }

  Future<String> fetchUserFirstName(DatabaseReference dbUserRef) async {
    Completer<String> completer = Completer<String>();
    // Get the user's first name from the database
    dbUserRef.child('fname').onValue.listen((event) {
      String firstName = event.snapshot.value.toString();
      completer.complete(firstName);
    });
    return completer.future;
  }

  Future<String> fetchUserLastName(DatabaseReference dbUserRef) async {
    Completer<String> completer = Completer<String>();
    // Get the user's first name from the database
    dbUserRef.child('lname').onValue.listen((event) {
      String lastName = event.snapshot.value.toString();
      completer.complete(lastName);
    });
    return completer.future;
  }

  Future<String> fetchUserEmail(DatabaseReference dbUserRef) async {
    Completer<String> completer = Completer<String>();
    // Get the user's first name from the database
    dbUserRef.child('email').onValue.listen((event) {
      String email = event.snapshot.value.toString();
      completer.complete(email);
    });
    return completer.future;
  }

  Future<String> fetchUserUsername(DatabaseReference dbUserRef) async {
    Completer<String> completer = Completer<String>();
    // Get the user's first name from the database
    dbUserRef.child('username').onValue.listen((event) {
      String username = event.snapshot.value.toString();
      completer.complete(username);
    });
    return completer.future;
  }

  Future<bool> fetchUserAdminPrivilege(DatabaseReference dbUserRef) async {
    Completer<bool> completer = Completer<bool>();
    // Get the user's first name from the database
    dbUserRef.child('isAdmin').onValue.listen((event) {
      String isAdmin = event.snapshot.value.toString();
      if (isAdmin == "false") {
        completer.complete(false);
      } else {
        completer.complete(true);
      }
    });
    return completer.future;
  }
}
