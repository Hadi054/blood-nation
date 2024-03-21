// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/backend/upload.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/mainscreens/donorlist.dart';
import 'package:bloodnation/mainscreens/home.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'posts.dart';
import 'package:bloodnation/mainscreens/modal.dart';
import 'profile.dart';

class Skeleton extends StatefulWidget {
  const Skeleton({super.key});

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> {
  int selectedIndex = 0;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  late List<Notification> notifications;

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey<ScaffoldState>();
  void drawerState() {
    if (_drawerKey.currentState!.isDrawerOpen)
      _drawerKey.currentState!.openEndDrawer();
    else
      _drawerKey.currentState!.openDrawer();
  }

  Future<int> fetchNotifications() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('notifications').get();
    int unseenCount = 0;
    querySnapshot.docs.forEach((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (data.containsKey('isSeen') && data['isSeen'] == false) {
        unseenCount++;
      }
    });
    return unseenCount;
  }

  @override
  void initState() {
    super.initState();
  }

  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   // var postCollection = firestore.collection('notifications');
  //   // print('object');

  //   // postCollection.snapshots().listen((QuerySnapshot snapshot) {
  //   //   if (snapshot.docChanges.isNotEmpty) {
  //   //     print('object');
  //   //     showNewEntryToast();
  //   //   }
  //   // });
  // }
  int seen = 0;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragDown: (details) async {
        var count = await fetchNotifications();
        setState(() {
          seen = count;
        });
      },
      child: Scaffold(
        key: _drawerKey,
        drawer: Drawer(
            child: Scaffold(
          appBar: appbar(context: context, drawerState: drawerState),
          body: Column(
            children: [
              ElevatedButton(
                child: Row(
                  children: [Icon(Icons.logout), Text("Logout")],
                ),
                onPressed: () {
                  setState(() {
                    logOut();
                    Navigator.pushNamed(context, 'welcome');
                  });
                },
              ),
            ],
          ),
        )),
        appBar: appbar(context: context, drawerState: drawerState, count: seen),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: main_color,
          unselectedItemColor: text_color,
          currentIndex: selectedIndex,
          onTap: (value) {
            setState(() {
              selectedIndex = value;
            });
          },
          selectedLabelStyle: text_style(),
          unselectedLabelStyle: text_style(size: 11, text_color: text_color),
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.feed), label: "Posts"),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: "Donors"),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: "Profile")
          ],
          type: BottomNavigationBarType.fixed,
        ),
        floatingActionButton: Tooltip(
          decoration: BoxDecoration(color: Colors.white),
          textStyle: text_style(text_color: main_color),
          message: "Add Blood Request",
          child: FloatingActionButton(
            splashColor: main_color.withOpacity(.3),
            backgroundColor: Colors.white,
            shape: CircleBorder(),
            onPressed: () {
              Modal(context);
            },
            child: Icon(
              Icons.add,
              color: main_color,
              size: 30,
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        body: GestureDetector(
            onTap: () {
              setState(() {});
            },
            child: changeScreen(selectedIndex: selectedIndex)),
      ),
    );
  }
}

Widget changeScreen({selectedIndex}) {
  if (selectedIndex == 1) {
    return Post();
  } else if (selectedIndex == 2)
    return DonorList();
  else if (selectedIndex == 3)
    return Profile();
  else
    return Home();
}

AppBar appbar({drawerState, context, count}) {
  return AppBar(
    toolbarHeight: MediaQuery.of(context).size.height * .1,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
      ),
    ),
    actions: [
      IconButton(
          onPressed: () {
            Navigator.pushNamed(context, 'notofication');
          },
          icon: Icon(
            size: 30,
            Icons.notifications_on,
            color:
                (count == 0) ? Colors.white : Color.fromARGB(255, 5, 242, 250),
          ))
    ],
    backgroundColor: main_color,
    leading: IconButton(onPressed: drawerState, icon: Icon(Icons.menu)),
    title: Text(
      "BloodNation",
      style: text_style(size: 30, text_color: Colors.white),
    ),
  );
}

// void showNewEntryToast() {
//   print('Hu Hu');
//   Fluttertoast.showToast(
//     msg: 'New entry added!',
//     toastLength: Toast.LENGTH_LONG,
//     gravity: ToastGravity.BOTTOM,
//     timeInSecForIosWeb: 1,
//     backgroundColor: Colors.black,
//     textColor: Colors.white,
//     fontSize: 16.0,
//   );
// }
