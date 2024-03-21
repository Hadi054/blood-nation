import 'dart:io';

import 'package:bloodnation/backend/location.dart';
import 'package:bloodnation/backend/upload.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/backend/firebase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';

class EditPhoto extends StatefulWidget {
  var profileimage;
  EditPhoto({this.profileimage});

  @override
  State<EditPhoto> createState() => _EditPhotoState();
}

class _EditPhotoState extends State<EditPhoto> {
  File? selectedImage = null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          child: Padding(
        padding: const EdgeInsets.fromLTRB(15.0, 40, 15, 15),
        child: ListView(
          children: [
            Row(
              children: [
                Container(width: MediaQuery.of(context).size.width * .7),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
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
            SizedBox(height: 20),
            Text(
              textAlign: TextAlign.center,
              'Upload your Profile Image',
              style: text_style(
                  text_color: Color.fromARGB(255, 73, 0, 8), size: 25.0),
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTap: () async {
                File? file = await pickImage();
                setState(() {
                  selectedImage = file;
                });
              },
              child: CircleAvatar(
                backgroundImage: (selectedImage != null)
                    ? FileImage(selectedImage!)
                    : Image.network(widget.profileimage).image,
                radius: 100,
              ),
            ),
            SizedBox(height: 30),
            button(
                function: () async {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (_) {
                        return Dialog(
                          backgroundColor: Color.fromARGB(255, 28, 23, 43),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "Loading...",
                                style: TextStyle(color: Colors.white),
                              ),
                            ]),
                          ),
                        );
                      });

                  try {
                    var uploadtask = await upload(image: selectedImage);
                    var downloadurl =
                        await (await uploadtask).ref.getDownloadURL();
                    User? user = getuser();
                    String? docid = await getDocumentId(id: user!.uid);
                    await updateData(
                        collection: 'userdata',
                        docId: docid,
                        data: {'photourl': downloadurl});
                  } finally {
                    Navigator.pop(context);
                  }
                  Navigator.pop(context);
                },
                background_color: main_color,
                context: context,
                text: "Submit",
                text_color: Colors.white,
                text_size: 20)
          ],
        ),
      )),
    );
  }
}

class EditName extends StatefulWidget {
  String username;
  EditName({this.username = ""});

  @override
  State<EditName> createState() => _EditNameState();
}

class _EditNameState extends State<EditName> {
  TextEditingController name = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name.text = widget.username;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Name',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              textField(
                  keyboardtype: TextInputType.name,
                  textEditingController: name,
                  text: "Name",
                  icon: Icons.perm_identity),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    final data = {
                      'name': name.text.toString(),
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditNumber extends StatefulWidget {
  String number;

  EditNumber({this.number = ""});

  @override
  State<EditNumber> createState() => _EditNumberState();
}

class _EditNumberState extends State<EditNumber> {
  TextEditingController numberController = TextEditingController();
  void initState() {
    // TODO: implement initState
    super.initState();
    numberController.text = widget.number;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Number',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              textField(
                  keyboardtype: TextInputType.phone,
                  textEditingController: numberController,
                  text: "Contact No",
                  icon: Icons.phone),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    final data = {
                      'contact': numberController.text,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditEmail extends StatefulWidget {
  String email;
  EditEmail({this.email = "hadi@gmail.com"});

  @override
  State<EditEmail> createState() => _EditEmailState();
}

class _EditEmailState extends State<EditEmail> {
  TextEditingController emailController = TextEditingController();
  void initState() {
    // TODO: implement initState
    super.initState();
    emailController.text = widget.email;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Email',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              textField(
                  keyboardtype: TextInputType.emailAddress,
                  textEditingController: emailController,
                  text: "Email",
                  icon: Icons.email),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    final data = {
                      'email': emailController.text,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditAddress extends StatefulWidget {
  String Address;

  EditAddress({this.Address = ""});

  @override
  State<EditAddress> createState() => _EditAddressState();
}

class _EditAddressState extends State<EditAddress> {
  TextEditingController location = TextEditingController();
  TextEditingController locationDistrict = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    location.text = widget.Address;
  }

  void locationState(locationController, address, district) {
    setState(() {
      locationController.text = address;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 500.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Address',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
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
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    final data = {
                      'address': location.text,
                      'district': locationDistrict.text
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditBirth extends StatefulWidget {
  var bday;
  EditBirth({this.bday});

  @override
  State<EditBirth> createState() => _EditBirthState();
}

class _EditBirthState extends State<EditBirth> {
  DateTime? dondate;
  TextEditingController birthdate = TextEditingController();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var birthday = widget.bday.toDate();
    DateFormat format = DateFormat('MMMM d, yyyy');
    var age = (birthday.difference(DateTime.now()).inDays ~/ 365) * -1;
    birthday = format.format(birthday);
    birthdate.text = birthday.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Birtdate',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              SizedBox(height: 15),
              calender(
                  calenderState: calenderState,
                  calenderText: 'Date of Birth',
                  dateController: birthdate),
              Text('Enter District for better filter', style: text_style()),
              SizedBox(height: 15),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    Timestamp? timestamp = Timestamp.fromDate(dondate!);

                    final data = {
                      'birthdate': timestamp,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditGender extends StatefulWidget {
  String gen;
  EditGender({this.gen = 'Male'});

  @override
  State<EditGender> createState() => _EditGenderState();
}

class _EditGenderState extends State<EditGender> {
  String gender = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    gender = widget.gen;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Gender',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              SizedBox(height: 15),
              dropDown(
                  value: gender,
                  onValueChanged: (newValue) {
                    setState(() {
                      gender = newValue;
                    });
                  },
                  labelIcon: Icons.man_2,
                  labelText: "Gender",
                  list: ['Male', 'Female']),
              SizedBox(height: 15),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);

                    final data = {
                      'gender': gender,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditBG extends StatefulWidget {
  String bg;
  EditBG({this.bg = 'A+'});

  @override
  State<EditBG> createState() => _EditBGState();
}

class _EditBGState extends State<EditBG> {
  String bgvalue = "";
  List<String> bloodgroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'o+', 'O-'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bgvalue = widget.bg;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Gender',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
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
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);

                    final data = {
                      'blood group': bgvalue,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditDonDate extends StatefulWidget {
  var bday;
  EditDonDate({this.bday});

  @override
  State<EditDonDate> createState() => _EditDonDateState();
}

class _EditDonDateState extends State<EditDonDate> {
  DateTime? dondate;
  TextEditingController donationdate = TextEditingController();

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    var birthday = widget.bday.toDate();
    DateFormat format = DateFormat('MMMM d, yyyy');
    var age = (birthday.difference(DateTime.now()).inDays ~/ 365) * -1;
    birthday = format.format(birthday);
    donationdate.text = birthday.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Last Donation Date',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              SizedBox(height: 15),
              calender(
                  calenderState: calenderState,
                  calenderText: 'Last donation date',
                  dateController: donationdate),
              SizedBox(height: 15),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    Timestamp? timestamp = Timestamp.fromDate(dondate!);

                    final data = {
                      'last donation': timestamp,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditWeight extends StatefulWidget {
  String w;
  EditWeight({this.w = '50'});

  @override
  State<EditWeight> createState() => _EditWeightState();
}

class _EditWeightState extends State<EditWeight> {
  TextEditingController weight = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    weight.text = widget.w;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Weight',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              textField(
                  keyboardtype: TextInputType.number,
                  textEditingController: weight,
                  text: "Weight",
                  icon: Icons.face),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    final data = {
                      'weight': weight.text,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditCondition extends StatefulWidget {
  String condition;
  EditCondition({this.condition = 'None'});

  @override
  State<EditCondition> createState() => _EditConditionState();
}

class _EditConditionState extends State<EditCondition> {
  String health = "";
  List<String> bloodgroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'o+', 'O-'];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    health = widget.condition;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Gender',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
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
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);

                    final data = {
                      'health conditions': health,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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

class EditEmergencyNumber extends StatefulWidget {
  String number;

  EditEmergencyNumber({this.number = ""});

  @override
  State<EditEmergencyNumber> createState() => _EditEmergencyNumberState();
}

class _EditEmergencyNumberState extends State<EditEmergencyNumber> {
  TextEditingController numberController = TextEditingController();
  void initState() {
    // TODO: implement initState
    super.initState();
    numberController.text = widget.number;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 300.0, // Set the height
        width: 400.0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Edit Number',
                style: text_style(
                    text_color: Color.fromARGB(255, 73, 0, 8), size: 30.0),
              ),
              textField(
                  keyboardtype: TextInputType.phone,
                  textEditingController: numberController,
                  text: "Contact No",
                  icon: Icons.phone),
              button(
                  function: () async {
                    User? user = getuser();
                    var docId = await getDocumentId(id: user!.uid);
                    final data = {
                      'emergency contact': numberController.text,
                    };
                    updateData(
                        collection: 'userdata', data: data, docId: docId);
                    Navigator.pop(context);
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
