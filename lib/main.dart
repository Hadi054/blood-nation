// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'package:bloodnation/mainscreens/notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bloodnation/authenticationscreens/welcome.dart';
import 'package:bloodnation/authenticationscreens/login.dart';
import 'package:bloodnation/authenticationscreens/register.dart';
import 'package:bloodnation/mainscreens/screenskeleton.dart';
import 'package:bloodnation/authenticationscreens/uploadimage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'authenticationscreens/donorinfo.dart';
import 'package:bloodnation/authenticationscreens/userinfo.dart';
import 'package:bloodnation/backend/firebase.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:location/location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Location location = Location();
  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      throw Exception('Location service not enabled');
    }
  }
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  User? loggedInUser;
  initState() {
    setState(() {
      loggedInUser = getuser();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        routes: {
          'welcome': (context) => Welcome(),
          'login': (context) => LogIn(),
          'register': (context) => Register(),
          'home': (context) => Skeleton(),
          'userinfo': (context) => UseerInfo(),
          'uploadimage': (context) => UploadImage(),
          'donorinfo': (context) => DonorInfo(),
          'notofication': (context) => Notifications()
        },
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
        ),
        home: Splash(
          loggedInUser: loggedInUser,
        ));
  }
}

class Splash extends StatefulWidget {
  User? loggedInUser;

  Splash({this.loggedInUser});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    Timer(Duration(seconds: 3), () {
      if (widget.loggedInUser == null) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Welcome()));
      } else {
        Navigator.pushNamed(context, 'home');
      }
    });
  }

  Widget build(BuildContext context) {
    return Hero(
      tag: 'logo',
      child: Container(
        color: Colors.white,
        child: Image.asset('assets/img.png'),
      ),
    );
  }
}
