// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:bloodnation/constants.dart';
import 'package:bloodnation/backend/firebase.dart';

import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool textvisible1 = true, textvisible2 = true;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirmpassword = TextEditingController();

  String hintText = "Blood Group";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 30, 0, 0),
        child: Container(
          width: MediaQuery.of(context).size.width * .9,
          child: ListView(
            children: [
              Text(
                'Create An Account',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              SizedBox(height: 20),
              textField(
                  keyboardtype: TextInputType.emailAddress,
                  textEditingController: email,
                  text: "Email",
                  icon: Icons.email),
              SizedBox(height: 20),
              passwordField(
                  paswordcontroller: password,
                  labelText: 'Password',
                  textVisible: textvisible1,
                  textVisibleState: () {
                    setState(() {
                      textvisible1 = !textvisible1;
                    });
                  }),
              Text('Password must be at least 6 letters', style: text_style()),
              SizedBox(height: 20),
              passwordField(
                  paswordcontroller: confirmpassword,
                  labelText: 'Confirm Password',
                  textVisible: textvisible2,
                  textVisibleState: () {
                    setState(() {
                      textvisible2 = !textvisible2;
                    });
                  }),
              SizedBox(height: 20),
              Center(
                child: button(
                    function: () async {
                      final bool emailValid = RegExp(
                              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                          .hasMatch(email.text);

                      final bool passwordValid =
                          RegExp(r'^\S+$').hasMatch(password.text);
                      String? validatePassword(String value) {
                        if (value.isEmpty) {
                          return 'Please enter a password';
                        } else {
                          return 'Password cannot contain whitespace';
                        }
                      }

                      if (emailValid) {
                        if (password.text == confirmpassword.text &&
                            passwordValid) {
                          await createuser(
                              email: email.text, password: password.text);

                          Navigator.pushNamed(context, 'userinfo');
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10.0, 30, 10, 30),
                                  child: Text("Password  is not valid",
                                      textAlign: TextAlign.center,
                                      style: text_style(
                                          size: 20, text_color: main_color)),
                                ),
                              );
                            },
                          );
                        }
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              alignment: Alignment.center,
                              child: Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(10.0, 30, 10, 30),
                                child: Text("Must Be a valid email",
                                    textAlign: TextAlign.center,
                                    style: text_style(
                                        size: 20, text_color: main_color)),
                              ),
                            );
                          },
                        );
                      }
                    },

                    //   firestore.collection('userdata').add({
                    //     'Birth Date': birthdate.text,
                    //     'Blood Group': bgvalue,
                    //     'Location': lvalue,
                    //     'Last Donation': donationdate.text
                    //   });
                    // },
                    background_color: main_color,
                    context: context,
                    text: 'Create Account',
                    text_color: Colors.white,
                    text_size: 20),
              ),
              SizedBox(height: 20),
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
              //         Navigator.pushNamed(context, 'userinfo');
              //       },
              //       child: Container(
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //           children: [
              //             Image.asset('assets/google.png'),
              //             Text('Sign up with Google',
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
                  Text("Already have an account?",
                      style: text_style(
                          size: 12,
                          text_color: Color.fromARGB(200, 135, 126, 127))),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, 'login');
                    },
                    child: Text(
                      "Sign In",
                      style: text_style(size: 12, text_color: main_color),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      )),
    );
  }
}
