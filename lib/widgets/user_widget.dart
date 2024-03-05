import 'package:ais_hackathon_better/firebase/firebase_instance_objects.dart'
    as db_object;
import 'package:firebase_auth/firebase_auth.dart' as fb_user;
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
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

    // User to create default values of an authenticated user from their info.
    // If manual updates from the database are made, those will auto populate instead.
    var nameRegex = RegExp(r' ');
    var fname = user?.displayName?.split(nameRegex).first;
    var lname = user?.displayName?.split(nameRegex).last;
    // These users are microsoft users from a specific university.
    // The username will be their netID which is their microsoft email
    // excluding the @byu.edu or other email domains for that matter.
    var usernameRegex = RegExp(r'@[^@\s]+$');
    var username = user?.email?.replaceAll(usernameRegex, '');

    // Default user object
    userObjectMap = <String, dynamic>{
      'fname': "${fname}",
      'lname': "${lname}",
      'email': "${user?.email}",
      'username': "$username",
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
}
