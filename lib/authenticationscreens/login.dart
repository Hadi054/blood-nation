// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'dart:async';
import 'dart:ffi';
import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bloodnation/authenticationscreens/welcome.dart';
import 'package:bloodnation/authenticationscreens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

class LogIn extends StatefulWidget {
  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool textvisible = true;
  late TextEditingController email = TextEditingController();
  late TextEditingController password = TextEditingController();
  final auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 40, 0, 0),
        child: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * .8,
            width: MediaQuery.of(context).size.width * .9,
            child: ListView(
              children: [
                Text(
                  'Welcome Back!',
                  style: text_style(
                      text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: email,
                  style: text_style(
                      size: 16, text_color: Color.fromARGB(255, 25, 24, 24)),
                  decoration: InputDecoration(
                      label: Text(
                    'E-mail',
                    style: text_style(
                        size: 12,
                        text_color: Color.fromARGB(255, 135, 126, 127)),
                  )),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: password,
                  obscureText: textvisible,
                  style: text_style(
                      size: 16, text_color: Color.fromARGB(255, 25, 24, 24)),
                  decoration: InputDecoration(
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(
                            () {
                              if (textvisible)
                                textvisible = false;
                              else
                                textvisible = true;
                            },
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                          child: Icon(
                            Icons.visibility,
                            size: 20,
                          ),
                        ),
                      ),
                      label: Text(
                        'Password',
                        style: text_style(
                          size: 12,
                          text_color: Color.fromARGB(255, 135, 126, 127),
                        ),
                      )),
                ),
                SizedBox(height: 20),
                Container(
                  width: double.maxFinite,
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    textAlign: TextAlign.end,
                    'Forgot Password',
                    style: text_style(size: 12, text_color: main_color),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: button(
                      background_color: main_color,
                      context: context,
                      text: 'Log In',
                      text_color: Colors.white,
                      text_size: 20,
                      function: () async {
                        try {
                          final userCredential = await login(
                              email: email.text, password: password.text);
                          final user = userCredential.user;

                          if (user != null) {
                            Navigator.pushNamed(context, 'home');
                          }
                        } catch (error) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                child: Padding(
                                  padding: const EdgeInsets.all(50.0),
                                  child: Text("Log in Failed",
                                      style: text_style(size: 25)),
                                ),
                              );
                            },
                          );
                        }
                      }),
                ),
                SizedBox(height: 50),
                // Center(
                //   child: Row(
                //     children: [
                //       Container(
                //         color: Color.fromARGB(200, 135, 126, 127),
                //         height: 2,
                //         width: MediaQuery.of(context).size.width * .4,
                //       ),
                //       SizedBox(
                //         width: MediaQuery.of(context).size.width * .02,
                //       ),
                //       Text(
                //         'OR',
                //         style: text_style(
                //           size: MediaQuery.of(context).size.width * .03,
                //           text_color: Color.fromARGB(200, 135, 126, 127),
                //         ),
                //       ),
                //       SizedBox(width: MediaQuery.of(context).size.width * .02),
                //       Container(
                //         color: Color.fromARGB(200, 135, 126, 127),
                //         height: 2,
                //         width: MediaQuery.of(context).size.width * .4,
                //       ),
                //     ],
                //   ),
                // ),
                // SizedBox(height: 50),
                // Center(
                //   child: TextButton(
                //       onPressed: () async {
                //         await signUpWithGoogle();
                //         Navigator.pushNamed(context, 'home');
                //       },
                //       child: Container(
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //           children: [
                //             Image.asset('assets/google.png'),
                //             Text('Sign In with Google',
                //                 textAlign: TextAlign.center,
                //                 style: text_style(
                //                     text_color:
                //                         Color.fromARGB(200, 135, 126, 127),
                //                     size: 18)),
                //             SizedBox(
                //               width: 20,
                //             )
                //           ],
                //         ),
                //         height: MediaQuery.of(context).size.height * .07,
                //         width: MediaQuery.of(context).size.width * .8,
                //         decoration: BoxDecoration(
                //             boxShadow: [
                //               BoxShadow(
                //                 color: Color.fromARGB(200, 135, 126, 127),
                //                 offset: const Offset(
                //                   0.0,
                //                   3.0,
                //                 ),
                //                 blurRadius: 5.0,
                //                 //spreadRadius: 2.0,
                //               )
                //             ],
                //             borderRadius: BorderRadius.all(Radius.circular(2)),
                //             color: Colors.white),
                //       )),
                // ),
                // SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account?",
                        style: text_style(
                            size: 12,
                            text_color: Color.fromARGB(200, 135, 126, 127))),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, 'register');
                      },
                      child: Text(
                        "Sign Up",
                        style: text_style(size: 12, text_color: main_color),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }
}
