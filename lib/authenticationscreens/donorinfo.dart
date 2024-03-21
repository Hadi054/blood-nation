import 'package:bloodnation/backend/location.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/backend/firebase.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DonorInfo extends StatefulWidget {
  const DonorInfo({super.key});

  @override
  State<DonorInfo> createState() => _DonorInfoState();
}

class _DonorInfoState extends State<DonorInfo> {
  TextEditingController donationcount = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController weight = TextEditingController();
  TextEditingController donationdate = TextEditingController();
  String health = "";
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

  DateTime? dondate;

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

  void locationState(locationController, address) {
    setState(() {
      locationController.text = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15.0, 40, 15, 15),
          child: ListView(
            children: [
              Row(
                children: [
                  Container(width: MediaQuery.of(context).size.width * .7),
                  TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, 'home');
                      },
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                        child: Text("Skip",
                            style: text_style(text_color: Colors.white)),
                      ),
                      style: ButtonStyle(
                          backgroundColor: MaterialStateColor.resolveWith(
                              (states) => main_color))),
                ],
              ),
              Text(
                'Do you want to be a donor?',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              SizedBox(height: 15),
              calender(
                  calenderState: calenderState,
                  calenderText: 'Last donation date',
                  dateController: donationdate),
              SizedBox(height: 15),
              textField(
                  keyboardtype: TextInputType.number,
                  textEditingController: donationcount,
                  text: "Number of previous Donations",
                  icon: Icons.numbers),

              SizedBox(height: 15),
              textField(
                  keyboardtype: TextInputType.number,
                  textEditingController: weight,
                  text: "Weight",
                  icon: Icons.face),
              SizedBox(height: 15),

              dropDown(
                  onValueChanged: (newValue) {
                    setState(() {
                      health = newValue;
                    });
                  },
                  labelIcon: Icons.health_and_safety,
                  labelText: "Existing Health Conditions",
                  list: [
                    'None',
                    'Cancer',
                    'Diabetes',
                    'Hypertension',
                    'Transmittable disease',
                  ]),
              SizedBox(height: 15),

              textField(
                  keyboardtype: TextInputType.phone,
                  textEditingController: contact,
                  text: "Emergency Contact No",
                  icon: Icons.phone),
              // ignore: prefer_const_constructors
              SizedBox(height: 20),
              button(
                  function: () async {
                    Timestamp? timestamp = Timestamp.fromDate(dondate!);

                    final data = {
                      'last donation': timestamp,
                      'no of donations': donationcount.text,
                      'weight': weight.text,
                      'health conditions': health,
                      'emergency contact': contact.text
                    };
                    User? user = getuser();
                    String? docid = await getDocumentId(id: user!.uid);
                    await updateData(
                        collection: 'userdata', docId: docid, data: data);
                    Navigator.pushNamed(context, 'home');
                  },
                  background_color: main_color,
                  context: context,
                  text: "Submit",
                  text_color: Colors.white,
                  text_size: 20)
            ],
          ),
        ),
      ),
    );
  }
}
