import 'package:ais_hackathon_better/pages/signup_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({super.key});

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
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
      return Scaffold(
        body: SingleChildScrollView(
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
                        decoration:
                            const InputDecoration(labelText: "Password"),
                        obscureText: true,
                      ),
                    ),
                  ),
                  if (errorMessage != "")
                    Column(
                      children: [
                        const SizedBox(height: 20),
                        Center(
                          child: Text(
                            errorMessage,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  // Container(height: 20),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     const Text("Don't have an account? "),
                  //     GestureDetector(
                  //       onTap: () {
                  //         Navigator.push(
                  //             context,
                  //             MaterialPageRoute(
                  //                 builder: (context) => const SignUpWidget()));
                  //       },
                  //       child: const Text(
                  //         "Sign Up",
                  //         style: TextStyle(
                  //           decoration: TextDecoration.underline,
                  //         ),
                  //       ),
                  //     )
                  //   ],
                  // ),
                  Container(height: 20),
                  // Generic Login Button
                  Container(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth / 2,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: SocialLoginButton(
                        onPressed: () {
                          _loginWithEmail(
                            emailController.text,
                            passwordController.text,
                          );
                          setState(() {});
                        },
                        // onPressed: () {},
                        buttonType: SocialLoginButtonType.generalLogin,
                        backgroundColor: const Color.fromRGBO(0, 87, 184, 1),
                      ),
                    ),
                  ),
                  Container(height: 10),
                  // Microsoft Login Button
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
                  // Sign Up Button
                  Container(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth / 2,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor,
                      // TODO move this implementation to a new screen with password verification through multiline string check
                      child: SocialLoginButton(
                        // onPressed: () => _signUpWithEmail(
                        //   emailController.text,
                        //   passwordController.text,
                        // ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpWidget(),
                            ),
                          );
                        },
                        buttonType: SocialLoginButtonType.generalLogin,
                        backgroundColor: const Color.fromRGBO(0, 46, 93, 1),
                        text: "Sign Up",
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  _loginWithEmail(String email, String password) async {
    try {
      UserCredential cred =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      checkAndAddUserToDatabase(cred);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "${e.code} - ${e.message}";
      });
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
      checkAndAddUserToDatabase(cred);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "${e.code} - ${e.message}";
        debugPrint(errorMessage);
      });
    }
  }
}

checkAndAddUserToDatabase(
  UserCredential cred, {
  String? firstNameToSet,
  String? lastNameToSet,
}) async {
  try {
    // Sets the user info in the database if it doesn't currently exist
    var user = cred.user;
    // These users are microsoft users from a specific university.
    // The fname and lname will always be the first and last words in the
    // display name string of the user.
    var nameRegex = RegExp(r' ');
    var fname = (firstNameToSet == null)
        ? user?.displayName?.split(nameRegex).first
        : firstNameToSet;
    var lname = (lastNameToSet == null)
        ? user?.displayName?.split(nameRegex).last
        : lastNameToSet;
    // These users are microsoft users from a specific university.
    // The username will be their netID which is their microsoft email
    // excluding the @byu.edu or other email domains for that matter.
    var usernameRegex = RegExp(r'@[^@\s]+$');
    var username = user?.email?.replaceAll(usernameRegex, '');
    // Registers the now authenticated user to the firebase database if said
    // user doesn't already exist within the database.
    if ((await FirebaseDatabase.instance
            .ref()
            .child('users/${user?.uid}')
            .get())
        .exists) {
      debugPrint(
          "User already exists in database, no need to change their data");
    } else {
      debugPrint("User not in database yet, adding them now...");
      FirebaseDatabase.instance.ref().child('users/${user?.uid}').set({
        "email": "${user?.email}",
        "username": "$username",
        "fname": "$fname",
        "lname": "$lname",
        "isAdmin": false,
      });
    }
  } on FirebaseException catch (e) {
    debugPrint("${e.code} - ${e.message}");
  }
}
