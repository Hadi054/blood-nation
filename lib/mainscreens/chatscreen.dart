import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/backend/firebase.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  String? receiver;
  ChatScreen({required this.receiver});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  late String message;
  final auth = FirebaseAuth.instance;
  User? user = getuser();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController chatting = TextEditingController();
  late List<Map<String, dynamic>> maplist;
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  void dispose() {
    updateDisposalTime();

    super.dispose();
  }

  updateDisposalTime() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('lastchat opened', DateTime.now().toIso8601String());
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDocumentSnapshot(id: widget.receiver),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data.data();

            return Scaffold(
              appBar: AppBar(
                backgroundColor: main_color.withOpacity(.1),
                leading: IconButton(
                    icon: Icon(Icons.arrow_back_outlined), onPressed: () {}),
                title: Container(
                  decoration: BoxDecoration(
                      // border: Border.all(color: main_color, width: 0),
                      borderRadius: BorderRadius.all(Radius.circular(15))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(data['name'], style: text_style(size: 16)),
                        ],
                      ),
                      CircleAvatar(
                        foregroundImage: (data['photourl'] == null)
                            ? NetworkImage(
                                'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png')
                            : NetworkImage(data['photourl']),
                        radius: 25,
                      ),
                      SizedBox(width: 10),
                    ],
                  ),
                ),
              ),
              // resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                  child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(children: [
                    Container(
                      // decoration: BoxDecoration(
                      //     border: Border.all(color: main_color),
                      //     borderRadius: BorderRadius.all(Radius.circular(10))),
                      height: MediaQuery.of(context).size.height * .78,
                      child: StreamBuilder(
                        stream: firestore
                            .collection('messages')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                  color: Colors.amber),
                            );
                          }
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              messages = snapshot.data!.docs;
                          messages.sort((a, b) {
                            DateTime? timeA = a['time'].toDate() as DateTime?;
                            DateTime? timeB = b['time'].toDate() as DateTime?;
                            if (timeA == null && timeB == null) {
                              return 0;
                            } else if (timeA == null) {
                              return 1;
                            } else if (timeB == null) {
                              return -1;
                            }
                            return timeB.compareTo(timeA); // descending order
                          });

                          List<Widget> messagewidget = [];
                          for (QueryDocumentSnapshot<Map<String, dynamic>> m
                              in messages) {
                            if ((m['sender'] == user!.uid &&
                                    m['receiver'] == data['id']) ||
                                (m['receiver'] == user!.uid &&
                                    m['sender'] == data['id'])) {
                              final text = m['text'];
                              final sender = m['sender'];
                              bool isMe = false;
                              if (sender == user!.uid) {
                                isMe = true;
                              }
                              final messageBubble = Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: Column(
                                    crossAxisAlignment: (isMe)
                                        ? CrossAxisAlignment.start
                                        : CrossAxisAlignment.end,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: (isMe)
                                                ? Colors.amberAccent
                                                : Colors.blue),
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Text(
                                            text,
                                            style: text_style(
                                                text_color: (isMe)
                                                    ? Colors.black
                                                    : Colors.white,
                                                size: 16),
                                          ),
                                        ),
                                      ),
                                      (isMe)
                                          ? Text(
                                              'You',
                                              style: text_style(size: 10),
                                            )
                                          : Text(
                                              data['name'],
                                              style: text_style(size: 10),
                                            )
                                    ]),
                              );
                              messagewidget.add(messageBubble);
                            }
                          }
                          return ListView(
                            reverse: true,
                            children: messagewidget,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            // border: Border.all(color: main_color, width: 0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(.2), //color of shadow
                                spreadRadius: 1, //spread radius
                                blurRadius: 1, // blur radius
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                            borderRadius:
                                BorderRadius.all(Radius.circular(15))),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: MediaQuery.of(context).size.width * .7,
                              child: TextFormField(
                                controller: chatting,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  hintText: 'Type your message here...',
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(color: Colors.black),
                                onChanged: (value) {
                                  setState(() {
                                    message = value;
                                  });
                                },
                              ),
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(main_color)),
                              onPressed: () async {
                                await firestore
                                    .collection('userdata')
                                    .where('id', isEqualTo: user!.uid)
                                    .get()
                                    .then((snap) {
                                  snap.docs.forEach((doc) {
                                    doc.reference.update({
                                      'chats':
                                          FieldValue.arrayUnion([data['id']])
                                    });
                                  });
                                });
                                await firestore
                                    .collection('userdata')
                                    .where('id', isEqualTo: data['id'])
                                    .get()
                                    .then((snap) {
                                  snap.docs.forEach((doc) {
                                    doc.reference.update({
                                      'chats':
                                          FieldValue.arrayUnion([user!.uid])
                                    });
                                  });
                                });
                                setState(() {
                                  chatting.text = '';
                                });
                                await firestore.collection("messages").add({
                                  "text": message,
                                  'sender': user!.uid,
                                  'receiver': data['id'],
                                  'time': DateTime.now()
                                });
                              },
                              child: Text(
                                'Send',
                                style: text_style(text_color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
              )),
            );
          } else {
            return Container();
          }
        });
  }
}
