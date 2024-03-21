import 'dart:io';

import 'package:bloodnation/backend/location.dart';
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

Future<File> pickImage() async {
  ImagePicker picker = ImagePicker();
  XFile? image = await picker.pickImage(source: ImageSource.gallery);
  if (image == null) {
    throw Exception('Image picking canceled');
  }
  final originalFile = File(image.path);
  const int targetWidth = 256 * 2;
  const int targetQuality = 256;
  final originalImage = img.decodeImage(originalFile.readAsBytesSync())!;
  final resizedImage = img.copyResize(originalImage, width: targetWidth);
  final compressedBytes = img.encodeJpg(resizedImage, quality: targetQuality);
  final compressedFile = await originalFile.writeAsBytes(compressedBytes);

  return compressedFile;
}

Future<dynamic> upload({image}) async {
  var uploadtask = await firebase_storage.FirebaseStorage.instance
      .ref('uploads/${image.path}')
      .putFile(image);
  return uploadtask;
}

Future<void> uploadXLSX() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String csvAssetPath = 'assets/data.csv';

  String csvContent = await rootBundle.loadString(csvAssetPath);

  List<List<dynamic>> csvList =
      CsvToListConverter(eol: '\n', fieldDelimiter: ',').convert(csvContent);
  List<String> headers = csvList[0].map((cell) => cell.toString()).toList();
  headers.add('addresslow');
  String collectionName = 'unreg_donors';

  for (int rowIdx = 1; rowIdx < csvList.length; rowIdx++) {
    Map<String, dynamic> data = {};
    for (int colIdx = 0; colIdx < headers.length - 1; colIdx++) {
      data[headers[colIdx]] = csvList[rowIdx][colIdx].toString();
    }
    data[headers[headers.length - 1]] =
        csvList[rowIdx][1].toString().toLowerCase();
    await firestore.collection(collectionName).add(data);
  }
}
