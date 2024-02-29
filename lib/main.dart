import 'package:ais_hackathon_better/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase setup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const TestDBHelped(title: "Testing Database Helper"),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Something went wrong!'),
              );
            } else if (snapshot.hasData) {
              return const HomePage();
            } else {
              return const MicrosoftLoginWidget();
              // return const LoginWidget();
            }
          }),
    );
  }
}

class MicrosoftLoginWidget extends StatefulWidget {
  const MicrosoftLoginWidget({super.key});

  @override
  State<MicrosoftLoginWidget> createState() => _MicrosoftLoginWidgetState();
}

class _MicrosoftLoginWidgetState extends State<MicrosoftLoginWidget> {
  _loginWithMicrosoft() async {
    try {
      final provider = OAuthProvider("microsoft.com");
      provider.setCustomParameters({
        // This allows people under BYU org to sign in w/ BYU microsoft accounts
        "tenant": "common",
        // This allows people to verify the account they signed in with
        "prompt": "select_account",
        // Other types of custom params include:
        //    {prompt, login}, {prompt, consent}, {login_hint},
        //    {domain_hint}, and {scope}
      });

      // MicrosoftAuthCredential mAuth = Credential();
      debugPrint("Trying to pop-up microsoft login");
      UserCredential cred;
      // var cred = (kIsWeb)
      //     ? await FirebaseAuth.instance.signInWithPopup(provider)
      //     : await FirebaseAuth.instance
      //         .signInWithCredential(provider.credential());
      if (kIsWeb) {
        debugPrint("On the web");
        FirebaseAuth.instance.signOut();
        cred = await FirebaseAuth.instance.signInWithPopup(provider);
        debugPrint(cred.user?.displayName);
        debugPrint(cred.user?.email);
      } else {
        debugPrint("Not on web");
        try {
          // TODO implement normal sign in without microsoft
          // await FirebaseAuth.instance.signInWithEmailAndPassword(
          //   email: "jackestes10@yahoo.com",
          //   password: "3210JTE06",
          // );
          // debugPrint("User: ");
          // cred = await FirebaseAuth.instance.currentUser!
          //     .linkWithProvider(provider);
          // debugPrint(cred.user?.displayName);
          // debugPrint(cred.user?.email);
        } on FirebaseAuthException catch (e) {
          debugPrint("${e.code} -${e.message}");
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint("${e.code} - ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => _loginWithMicrosoft(),
        // onPressed: () {},
        child: const Text('Log in with Microsoft'),
      ),
    );
  }
}
