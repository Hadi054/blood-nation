// ignore_for_file: prefer_const_constructors, prefer_interpolation_to_compose_strings, sort_child_properties_last

import 'package:bloodnation/backend/location.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/backend/firebase.dart';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UseerInfo extends StatefulWidget {
  const UseerInfo({super.key});

  @override
  State<UseerInfo> createState() => _UseerInfoState();
}

class _UseerInfoState extends State<UseerInfo> {
  TextEditingController name = TextEditingController();
  TextEditingController contact = TextEditingController();

  TextEditingController birthdate = TextEditingController();
  TextEditingController donationdate = TextEditingController();
  String bgvalue = "";
  String gender = "";
  TextEditingController location = TextEditingController();
  TextEditingController locationDistrict = TextEditingController();

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

  void locationState(locationController, address, district) {
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
                        Navigator.pushNamed(context, 'uploadimage');
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
                'Set up your Profile',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              SizedBox(height: 15),

              textField(
                  keyboardtype: TextInputType.name,
                  textEditingController: name,
                  text: "Name",
                  icon: Icons.perm_identity),
              // calender(
              //     calenderState: calenderState,
              //     calenderText: 'Last Donation Date',
              //     dateController: donationdate),
              //
              SizedBox(height: 15),
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
              calender(
                  calenderState: calenderState,
                  calenderText: 'Date of Birth',
                  dateController: birthdate),
              SizedBox(height: 15),
              dropDown(
                  onValueChanged: (newValue) {
                    setState(() {
                      gender = newValue;
                    });
                  },
                  labelIcon: Icons.man_2,
                  labelText: "Gender",
                  list: ['Male', 'Female']),
              SizedBox(height: 15),

              dropDown(
                  onValueChanged: (newValue) {
                    setState(() {
                      bgvalue = newValue;
                    });
                  },
                  labelIcon: Icons.bloodtype,
                  labelText: "Blood Group",
                  list: bloodgroups),
              SizedBox(height: 15),
              textField(
                  keyboardtype: TextInputType.phone,
                  textEditingController: contact,
                  text: "Contact No",
                  icon: Icons.phone),
              SizedBox(height: 20),
              button(
                  function: () {
                    User? user = getuser();
                    Timestamp? timestamp = Timestamp.fromDate(dondate!);
                    final data = {
                      'id': user!.uid,
                      'email': user!.email,
                      'name': name.text,
                      'address': location.text,
                      'birthdate': timestamp,
                      'gender': gender,
                      'blood group': bgvalue,
                      'contact': contact.text,
                      'rating': {},
                      'district': locationDistrict.text,
                      'avgrating': 0.0
                    };
                    addData(collectionName: 'userdata', data: data);
                    Navigator.pushNamed(context, 'uploadimage');
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
