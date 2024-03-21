import 'package:flutter/material.dart';
import 'package:bloodnation/constants.dart';

class Welcome extends StatelessWidget {
  const Welcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'assets/img.png',
                height: MediaQuery.of(context).size.height * .6,
              ),
            ),
            button(
                text_size: 20,
                function: () {
                  Navigator.pushNamed(context, 'login');
                },
                text: "Log In",
                context: context,
                background_color: Colors.white,
                text_color: main_color),
            button(
                text_size: 20,
                function: () {
                  Navigator.pushNamed(context, 'register');
                },
                text: "Create Account",
                context: context,
                background_color: main_color,
                text_color: Colors.white)
          ],
        ),
      )),
    );
  }
}
