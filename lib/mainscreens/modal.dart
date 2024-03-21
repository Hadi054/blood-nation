// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:bloodnation/backend/upload.dart';
import 'package:bloodnation/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bloodnation/authenticationscreens/welcome.dart';
import 'package:bloodnation/authenticationscreens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:bloodnation/backend/location.dart';
import 'package:intl/intl.dart';
import 'package:bloodnation/backend/firebase.dart';

void Modal(BuildContext context) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog.fullscreen(
          child: post(),
          insetAnimationCurve: Curves.bounceIn,
        );
      });
}

class post extends StatefulWidget {
  final String? user, docId;
  dynamic doc;
  User? current;
  post({this.current, this.docId, this.user, this.doc});
  @override
  State<post> createState() => _postState();
}

class _postState extends State<post> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool textvisible1 = true, textvisible2 = true;
  TextEditingController donationtime = TextEditingController();
  TextEditingController location = TextEditingController();
  TextEditingController contact = TextEditingController();

  TextEditingController donationdate = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController locationDistrict = TextEditingController();

  File? selectedImage = null;
  String bgvalue = "";
  String lvalue = "";
  final auth = FirebaseAuth.instance;
  String hintText = "Blood Group";
  List<String> locations = [
    'Dhaka',
    'Chittagong',
    'Barisal',
    'Rangpur',
    'Rajshahi',
    'Sylhet',
    'Khulna',
  ];
  List<String> bloodgroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'o+', 'O-'];

  DateTime? selectedDate;
  void textVisibleState(bool textvisible) {
    setState(
      () {
        textvisible = !textvisible;
      },
    );
  }

  void locationState(locationController, address, district) {
    setState(() {
      locationController.text = address;
    });
  }

  DateTime? dondate;
  TimeOfDay? dontime;
  void calenderState(dateController) async {
    DateTime? sel = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1920, 1, 1),
      lastDate: DateTime(2099, 12, 31),
    );
    setState(() {
      if (sel != null) {
        dondate = sel;
        DateFormat format = DateFormat('MMMM d,yyyy');
        dateController.text = format.format(sel);
      }
    });
  }

  void timeState(timeController) async {
    TimeOfDay? sel = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        useRootNavigator: false);
    setState(() {
      if (sel != null) {
        dontime = sel;
        DateFormat format = DateFormat('hh:mm a');
        timeController.text =
            format.format(DateTime(2000, 01, 01, sel.hour, sel.minute));
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.doc != null) {
      des.text = widget.doc['Description'];
      location.text = widget.doc['Location'];
      DateFormat format = DateFormat('hh:mm a');
      donationtime.text = format.format(DateTime(
          2000,
          01,
          01,
          widget.doc['Donation DateTime'].toDate().hour,
          widget.doc['Donation DateTime'].toDate().minute));
      DateFormat dateformat = DateFormat('MMMM d,yyyy');
      donationdate.text =
          dateformat.format(widget.doc['Donation DateTime'].toDate());
      bgvalue = widget.doc['Blood Group'];
      contact.text = widget.doc['contact'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 30, 0, 0),
      child: Container(
        width: MediaQuery.of(context).size.width * .9,
        child: ListView(
          children: [
            Text(
              'Create Post',
              style: text_style(
                  text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
            ),
            SizedBox(height: 10),
            Container(
              height: MediaQuery.of(context).size.height * .3,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Align(
                      child: TextFormField(
                        controller: des,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        minLines: null,
                        maxLines: null,
                        textAlignVertical: TextAlignVertical.top,
                        style: text_style(),
                        decoration: InputDecoration(
                          alignLabelWithHint: true,
                          contentPadding: EdgeInsets.all(10),
                          label: label(Icons.description, "Descriptrion"),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            time(
                timeController: donationtime,
                timeState: timeState,
                timeText: "Donation Time"),
            SizedBox(height: 20),
            calender(
                calenderState: calenderState,
                calenderText: 'Donation Date',
                dateController: donationdate),
            SizedBox(height: 20),
            textField(
                keyboardtype: TextInputType.text,
                suffixicon: getLocation(
                    context: context,
                    textEditingController: location,
                    textState: locationState),
                textEditingController: location,
                text: "Address",
                icon: Icons.location_on),
            SizedBox(height: 15),
            textField(
                keyboardtype: TextInputType.text,
                suffixicon: getDistrict(
                    context: context,
                    textEditingController: locationDistrict,
                    textState: locationState),
                textEditingController: locationDistrict,
                text: "District",
                icon: Icons.location_on),
            Text('Enter District for better filter', style: text_style()),
            SizedBox(height: 15),
            dropDown(
                value: (widget.doc != null) ? widget.doc['Blood Group'] : null,
                onValueChanged: (newValue) {
                  setState(() {
                    bgvalue = newValue;
                  });
                },
                labelIcon: Icons.bloodtype,
                labelText: "Blood Group",
                list: bloodgroups),
            SizedBox(height: 20),
            textField(
                keyboardtype: TextInputType.text,
                textEditingController: contact,
                text: "Contact Info",
                icon: Icons.phone),
            ElevatedButton(
              onPressed: () async {
                File file = await pickImage();
                setState(() {
                  selectedImage = file;
                });
              },
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Upload Image',
                      style: text_style(),
                    ),
                  ]),
            ),
            (selectedImage == null && widget.doc == null)
                ? Container()
                : (selectedImage != null)
                    ? Container(
                        height: MediaQuery.of(context).size.height * .2,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: (selectedImage != null)
                              ? Image.file(
                                  selectedImage!,
                                  fit: BoxFit.fitWidth,
                                )
                              : null,
                        ),
                      )
                    : (widget.doc != null)
                        ? Container(
                            height: MediaQuery.of(context).size.height * .2,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: (widget.doc['image'] != null)
                                  ? Image.network(
                                      widget.doc['image'],
                                      fit: BoxFit.fitWidth,
                                    )
                                  : null,
                            ),
                          )
                        : Container(),
            Center(
              child: button(
                  function: () async {
                    var downloadurl;
                    if (selectedImage != null) {
                      var uploadtask = await upload(image: selectedImage);
                      downloadurl =
                          await (await uploadtask).ref.getDownloadURL();
                    }
                    if (widget.doc == null) {
                      Timestamp timestamp = Timestamp.now();
                      if (dondate != null && dontime != null) {
                        timestamp = Timestamp.fromDate(DateTime(
                            dondate!.year,
                            dondate!.month,
                            dondate!.day,
                            dontime!.hour,
                            dontime!.minute));
                      }

                      DocumentReference documentReference =
                          await firestore.collection('post').add({
                        'Blood Group': bgvalue,
                        'Location': location.text,
                        'Donation DateTime': timestamp,
                        'Description': des.text,
                        'Post Time': DateTime.now(),
                        'user': auth.currentUser!.uid,
                        'image': (downloadurl),
                        'contact': contact.text,
                        'responded': [],
                        'district': locationDistrict.text
                      });
                      DateTime d = timestamp!.toDate();
                      var diff = d.difference(DateTime.now()).inHours;
                      if (diff <= 6 && diff >= 0) {
                        firestore.collection('notifications').add({
                          'user': auth.currentUser!.uid,
                          'notice': bgvalue +
                              ' blood needed at ' +
                              location.text +
                              ' in ' +
                              diff.toString() +
                              ' hours Today.',
                          'type': 'Emergency Request',
                          'Id': documentReference.id,
                          'time': timestamp,
                          'isSeen': false
                        });
                      }
                    } else {
                      Timestamp? timestamp;
                      DateTime fetched_time =
                          widget.doc['Donation DateTime'].toDate();
                      if (dondate == null && dontime == null) {
                        timestamp = widget.doc['Donation DateTime'];
                      } else {
                        if (dondate != null && dontime != null) {
                          timestamp = Timestamp.fromDate(DateTime(
                              dondate!.year,
                              dondate!.month,
                              dondate!.day,
                              dontime!.hour,
                              dontime!.minute));
                        } else {
                          if (dondate != null) {
                            timestamp = Timestamp.fromDate(DateTime(
                                dondate!.year,
                                dondate!.month,
                                dondate!.day,
                                fetched_time.hour,
                                fetched_time.minute));
                          }
                          if (dontime != null) {
                            timestamp = Timestamp.fromDate(DateTime(
                                fetched_time.year,
                                fetched_time.month,
                                fetched_time.day,
                                dondate!.hour,
                                dondate!.minute));
                          }
                        }
                      }

                      updateData(
                          collection: 'post',
                          docId: widget.doc.id,
                          data: {
                            'Blood Group': bgvalue,
                            'Location': location.text,
                            'Donation DateTime': timestamp,
                            'Description': des.text,
                            'image': (downloadurl == null)
                                ? widget.doc['image']
                                : downloadurl,
                            'contact': contact.text
                          });
                    }
                    Navigator.of(context).pop();
                  },
                  background_color: main_color,
                  context: context,
                  text: 'Post',
                  text_color: Colors.white,
                  text_size: 20),
            ),
          ],
        ),
      ),
    ));
  }
}
