import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/mainscreens/chatscreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bloodnation/mainscreens/modal.dart';

class Buttonbar extends StatefulWidget {
  final String? user;
  User? current;
  dynamic doc;
  Buttonbar({
    required this.user,
    this.doc,
    this.current,
  });

  @override
  _ButtonBarWidgetState createState() => _ButtonBarWidgetState();
}

class _ButtonBarWidgetState extends State<Buttonbar> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Widget build(BuildContext context) {
    List<Widget> everyone = [
      ButtonBarElement(
        user: widget.user,
        icon: Icons.star,
        text: "Respond",
        function: () async {
          bool responded = await isResponded(
              docId: widget.doc.id, userId: widget.current!.uid);
          if (!responded) {
            confirmationDialogue(
                context: context,
                docId: widget.doc.id,
                userId: widget.current!.uid);
          } else {
            deletionDialogue(
                context: context,
                docId: widget.doc.id,
                userId: widget.current!.uid);
          }
        },
      ),
      ButtonBarElement(
          user: widget.user,
          icon: Icons.chat,
          text: "Chat",
          function: () {
            showDialog(
                context: context,
                builder: (context) {
                  return ChatScreen(
                    receiver: widget.user,
                  );
                });
          })
    ];

    List<Widget> me = [
      ButtonBarElement(
          user: widget.user,
          icon: Icons.edit,
          text: "Edit",
          function: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog.fullscreen(
                    child: post(
                        current: widget.current,
                        doc: widget.doc,
                        docId: widget.doc.id,
                        user: widget.user),
                    insetAnimationCurve: Curves.bounceIn,
                  );
                });
          }),
      ButtonBarElement(
          user: widget.user,
          icon: Icons.delete,
          text: "Delete",
          function: () {
            deleteDocument('post', widget.doc.id);
          })
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: (widget.current!.uid.toString() == widget.user.toString())
            ? me
            : everyone,
      ),
    );
  }
}

Widget ButtonBarElement({pressed = false, user, icon, text, function}) {
  MaterialStateProperty<Color> background_color =
      MaterialStateProperty.all(main_color);
  Color text_color = Colors.white;
  if (pressed == null) {
    pressed = false;
  }

  return ElevatedButton(
      style: ButtonStyle(
          backgroundColor: (pressed)
              ? MaterialStateProperty.all(Colors.white)
              : background_color),
      onPressed: function,
      child: Row(
        children: [
          Icon(icon, color: (pressed) ? main_color : Colors.white, size: 25),
          Text(text,
              style: text_style(
                  size: 15, text_color: (pressed) ? main_color : Colors.white)),
        ],
      ));
}

confirmationDialogue({context, userId, docId, state}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: MediaQuery.of(context).size.height * .4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Are You Sure about attending as a donor??",
                    style: text_style(size: 25)),
                Column(
                  children: [
                    button(
                        context: context,
                        text: "Yes",
                        function: () async {
                          await firestore.collection('post').doc(docId).update({
                            'responded': FieldValue.arrayUnion([userId])
                          });

                          Navigator.pop(context);
                        },
                        background_color: main_color,
                        text_color: Colors.white,
                        text_size: 20),
                    button(
                        function: () {
                          Navigator.pop(context);
                        },
                        context: context,
                        text: "No",
                        background_color: Colors.white,
                        text_color: main_color,
                        text_size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

deletionDialogue({context, userId, docId, state}) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            height: MediaQuery.of(context).size.height * .4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Are you sure about removing your response??",
                    style: text_style(size: 25)),
                Column(
                  children: [
                    button(
                        context: context,
                        text: "Yes",
                        function: () async {
                          await firestore.collection('post').doc(docId).update({
                            'responded': FieldValue.arrayRemove([userId])
                          });
                          Navigator.pop(context);
                        },
                        background_color: main_color,
                        text_color: Colors.white,
                        text_size: 20),
                    button(
                        function: () {
                          Navigator.pop(context);
                        },
                        context: context,
                        text: "No",
                        background_color: Colors.white,
                        text_color: main_color,
                        text_size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
