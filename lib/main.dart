import 'package:ais_hackathon_better/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

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
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorMessage = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      debugPrint("Width: ${constraints.maxWidth} px");
      double widthFactor =
          (constraints.maxWidth > 650) ? 650 / constraints.maxWidth : 1;
      double widthFactorModifier = (kIsWeb) ? .96 : .93;
      return SingleChildScrollView(
        padding: const EdgeInsets.all(6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  constraints: BoxConstraints(
                    // minWidth: constraints.maxWidth / 2,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor * widthFactorModifier,
                    child: TextField(
                      controller: emailController,
                      cursorColor: Colors.black,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: "Email"),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth / 2,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor * widthFactorModifier,
                    child: TextField(
                      controller: passwordController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: "Password"),
                      obscureText: true,
                    ),
                  ),
                ),
                Container(height: 20),
                Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth / 2,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: SocialLoginButton(
                      onPressed: () {
                        _loginWithEmail();
                        setState(() {});
                      },
                      // onPressed: () {},
                      buttonType: SocialLoginButtonType.generalLogin,
                      backgroundColor: const Color.fromRGBO(0, 87, 184, 1),
                    ),
                  ),
                ),
                Container(height: 10),
                Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth / 2,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: SocialLoginButton(
                      onPressed: () {
                        _loginWithMicrosoft();
                        setState(() {});
                      },
                      // onPressed: () {},
                      buttonType: SocialLoginButtonType.microsoft,
                    ),
                  ),
                ),
                Container(height: 10),
                Container(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth / 2,
                    maxWidth: constraints.maxWidth,
                  ),
                  child: FractionallySizedBox(
                    widthFactor: widthFactor,
                    child: SocialLoginButton(
                      onPressed: () => _signUpWithEmail(),
                      // onPressed: () {},
                      buttonType: SocialLoginButtonType.generalLogin,
                      backgroundColor: const Color.fromRGBO(0, 46, 93, 1),
                      text: "Sign Up",
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                if (errorMessage != "")
                  Column(
                    children: [
                      Center(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  _signUpWithEmail() async {}

  _loginWithEmail() async {
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

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: "jackestes10@yahoo.com",
        password: "Jellyfish",
      );
    } on FirebaseAuthException catch (e) {
      errorMessage = "${e.code} - ${e.message}";
      debugPrint(errorMessage);
    }
  }

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
      debugPrint("Trying to pop-up microsoft login");
      UserCredential cred;
      final microsoftProvider = MicrosoftAuthProvider();
      microsoftProvider.setCustomParameters({
        // This allows people under BYU org to sign in w/ BYU microsoft accounts
        "tenant": "common",
        // This allows people to verify the account they signed in with
        "prompt": "select_account",
      });
      if (kIsWeb) {
        cred = await FirebaseAuth.instance.signInWithPopup(
          provider,
        );
      } else {
        cred = await FirebaseAuth.instance.signInWithProvider(
          microsoftProvider,
        );
      }
    } on FirebaseAuthException catch (e) {
      errorMessage = "${e.code} - ${e.message}";
      debugPrint(errorMessage);
    }
  }
}
