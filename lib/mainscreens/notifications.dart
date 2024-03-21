import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/backend/upload.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/mainscreens/donorlist.dart';
import 'package:bloodnation/mainscreens/home.dart';
import 'package:bloodnation/mainscreens/posthelper.dart';

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

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestore.collection('notifications').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var documents = snapshot.data!.docs;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: main_color.withOpacity(.2),
              leading: IconButton(
                  icon: Icon(Icons.arrow_back_outlined),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              title: Container(
                  decoration: BoxDecoration(
                      // border: Border.all(color: main_color, width: 0),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Text(
                    'Notifications',
                    style: text_style(),
                  )),
            ),
            body: ListView(
              children: documents.map((doc) {
                var posttime = doc['time'].toDate();
                String time = "";
                if (posttime.difference(DateTime.now()).inHours >= 24) {
                  DateFormat format = DateFormat('MMMM d, yyyy');
                  time = format.format(posttime);
                } else {
                  DateFormat format = DateFormat('hh:mm a');
                  time = 'Today, ' + format.format(posttime);
                }
                return FutureBuilder(
                    future: getDocumentSnapshot(id: doc['user']),
                    builder: (context, usersnapshot) {
                      if (usersnapshot.hasData) {
                        var userdata = usersnapshot.data.data();
                        return StreamBuilder(
                            stream: firestore
                                .collection('post')
                                .doc(doc['Id'])
                                .snapshots(),
                            builder: (context, postsnapshot) {
                              if (postsnapshot.hasData) {
                                var postdata = postsnapshot.data;
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      updateData(
                                          collection: 'notifications',
                                          data: {'isSeen': true},
                                          docId: doc.id);
                                      extendmodal(
                                          context: context,
                                          current: getuser(),
                                          doc: postdata,
                                          requestor: userdata['name'],
                                          url: userdata['photourl'],
                                          user: postdata!['user']);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  .2), //color of shadow
                                              spreadRadius: 1, //spread radius
                                              blurRadius: 1, // blur radius
                                              offset: Offset(0,
                                                  2), // changes position of shadow
                                            ),
                                          ],
                                          color: (doc['isSeen'])
                                              ? Colors.white
                                              : Colors.blue,
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12))),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: [
                                          CircleAvatar(
                                            foregroundImage: NetworkImage(
                                                userdata['photourl']),
                                            radius: 30,
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(doc['type'],
                                                  style: text_style(size: 15)),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .7,
                                                  child: Text(doc['notice'],
                                                      style: text_style(
                                                          weight:
                                                              FontWeight.bold,
                                                          size: 13))),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text('Posted, ' + time,
                                                  style: text_style(size: 10))
                                            ],
                                          )
                                        ]),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            });
                      } else
                        return Container();
                    });
              }).toList(),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }
}
