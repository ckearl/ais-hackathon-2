import 'package:ais_hackathon_better/pages/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_login_buttons/social_login_buttons.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({super.key});

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final password2Controller = TextEditingController();
  final fNameController = TextEditingController();
  final lNameController = TextEditingController();
  String errorMessage = "";

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    password2Controller.dispose();
    fNameController.dispose();
    lNameController.dispose();

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
                  const SizedBox(height: 4),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth / 2,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor * widthFactorModifier,
                      child: TextField(
                        controller: password2Controller,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                            labelText: "Re-Enter Password"),
                        obscureText: true,
                      ),
                    ),
                  ),
                  // First name input
                  const SizedBox(height: 4),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth / 2,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor * widthFactorModifier,
                      child: TextField(
                        controller: fNameController,
                        textInputAction: TextInputAction.next,
                        decoration:
                            const InputDecoration(labelText: "First Name"),
                      ),
                    ),
                  ),
                  // Last name input
                  const SizedBox(height: 4),
                  Container(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth / 2,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor * widthFactorModifier,
                      child: TextField(
                        controller: lNameController,
                        textInputAction: TextInputAction.next,
                        decoration:
                            const InputDecoration(labelText: "Last Name"),
                      ),
                    ),
                  ),

                  Container(height: 20),
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
                  // Nav back to sign in
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      GestureDetector(
                        onTap: () {
                          // pop navigates us back to the login page by
                          // getting rid of the current page view and
                          // going back to the login page view
                          Navigator.pop(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginWidget()),
                          );
                        },
                        child: const Text(
                          "Sign In",
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      )
                    ],
                  ),
                  Container(height: 20),
                  // Sign Up Button
                  Container(
                    constraints: BoxConstraints(
                      minWidth: constraints.maxWidth / 2,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: FractionallySizedBox(
                      widthFactor: widthFactor,
                      child: SocialLoginButton(
                        onPressed: () {
                          debugPrint(
                              "${passwordController.text} vs ${password2Controller.text} - ${passwordController.text == password2Controller.text}");
                          if (passwordController.text !=
                              password2Controller.text) {
                            setState(() {
                              errorMessage = "Passwords Don't Match!";
                            });
                          } else if (fNameController.text == "") {
                            setState(() {
                              errorMessage = "Enter a first name";
                            });
                          } else if (lNameController.text == "") {
                            setState(() {
                              errorMessage = "Enter a last name";
                            });
                          } else {
                            _signUpWithEmail(
                              emailController.text,
                              passwordController.text,
                              fNameController.text,
                              lNameController.text,
                            );
                            Navigator.pop(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LoginWidget()),
                            );
                          }
                        },
                        buttonType: SocialLoginButtonType.generalLogin,
                        backgroundColor: const Color.fromRGBO(0, 46, 93, 1),
                        text: "Sign Up",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  _signUpWithEmail(
      String email, String password, String fname, String lname) async {
    try {
      UserCredential cred =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      checkAndAddUserToDatabase(cred,
          firstNameToSet: fname, lastNameToSet: lname);
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = "${e.code} - ${e.message}";
        debugPrint(errorMessage);
      });
    }
  }
}
