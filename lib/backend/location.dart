import 'package:bloodnation/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

Future<dynamic> reverseGeocode({lat, lon}) async {
  var url = Uri.parse(
      "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon");
  var response = await http.get(url);
  var jsonResponse = jsonDecode(response.body);

  return jsonResponse;
}

Future<Position> determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }
  return await Geolocator.getCurrentPosition();
}

Widget getLocation({textState, textEditingController, context}) {
  return GestureDetector(
    onTap: () async {
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
        Position pos = await determinePosition();
        GoogleTranslator translator = GoogleTranslator();

        dynamic jsonResponse =
            await reverseGeocode(lat: pos.latitude, lon: pos.longitude);
        Translation district = await translator.translate(
            jsonResponse['address']['state_district'],
            from: 'bn',
            to: 'en');
        String address = jsonResponse['address']['road'].toString() +
            ', ' +
            district.toString();

        textState(
            textEditingController, address, district.toString().split(' ')[0]);
      } finally {
        // Close the loading dialog when the data is loaded or an error occurs
        Navigator.of(context).pop();
      }
    },
    child: Column(
      children: [
        Icon(
          Icons.location_searching,
          color: Colors.blueAccent,
        ),
        Text(
          'Detect',
          style: text_style(size: 10),
        )
      ],
    ),
  );
}

Widget getDistrict({textState, textEditingController, context}) {
  return GestureDetector(
    onTap: () async {
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
        Position pos = await determinePosition();
        GoogleTranslator translator = GoogleTranslator();

        dynamic jsonResponse =
            await reverseGeocode(lat: pos.latitude, lon: pos.longitude);

        Translation district = await translator.translate(
            jsonResponse['address']['state_district'],
            from: 'bn',
            to: 'en');
        String address = district.toString();

        textState(textEditingController, district.toString().split(' ')[0],
            district.toString().split(' ')[0]);
      } on Exception catch (e) {
        // TODO
      } finally {
        // Close the loading dialog when the data is loaded or an error occurs
        Navigator.of(context).pop();
      }
    },
    child: Column(
      children: [
        Icon(
          Icons.location_searching,
          color: Colors.blueAccent,
        ),
        Text(
          'Detect',
          style: text_style(size: 10),
        )
      ],
    ),
  );
}
