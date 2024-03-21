// ignore_for_file: sort_child_properties_last

import 'dart:io';

import 'package:bloodnation/backend/location.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/backend/firebase.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../backend/upload.dart';

class UploadImage extends StatefulWidget {
  const UploadImage({super.key});

  @override
  State<UploadImage> createState() => _UploadImageState();
}

class _UploadImageState extends State<UploadImage> {
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
                // TextButton(
                //     onPressed: () {
                //       Navigator.pushNamed(context, 'donorinfo');
                //     },
                //     child: Padding(
                //       padding: const EdgeInsets.fromLTRB(8.0, 0, 8, 0),
                //       child: Text("Skip",
                //           style: text_style(text_color: Colors.white)),
                //     ),
                //     style: ButtonStyle(
                //         backgroundColor: MaterialStateColor.resolveWith(
                //             (states) => main_color))),
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
                backgroundImage:
                    (selectedImage != null) ? FileImage(selectedImage!) : null,
                radius: 100,
              ),
            ),
            SizedBox(height: 30),
            button(
                function: () async {
                  var uploadtask = await upload(image: selectedImage);
                  var downloadurl =
                      await (await uploadtask).ref.getDownloadURL();
                  User? user = getuser();
                  String? docid = await getDocumentId(id: user!.uid);
                  await updateData(
                      collection: 'userdata',
                      docId: docid,
                      data: {'photourl': downloadurl});
                  Navigator.pushNamed(context, 'donorinfo');
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
