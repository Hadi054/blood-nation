// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:bloodnation/backend/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder_buddy/geocoder_buddy.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

GeocoderBuddy geocoderBuddy = GeocoderBuddy();

Color main_color = Color.fromARGB(255, 220, 26, 71);
Color main_color_light = Color.fromARGB(200, 242, 230, 225);

Color text_color = Color.fromARGB(255, 135, 126, 127);
Color title_color = Color.fromARGB(255, 73, 0, 8);
TextStyle text_style(
    {Color? text_color, double? size, FontWeight? weight = FontWeight.normal}) {
  return TextStyle(
      color: text_color,
      fontSize: size,
      fontWeight: weight,
      fontFamily: 'Lexend');
}

TextButton button(
    {text,
    context,
    background_color,
    text_color,
    function,
    double? text_size}) {
  return TextButton(
      onPressed: function,
      child: Container(
        height: MediaQuery.of(context).size.height * .08,
        width: MediaQuery.of(context).size.width * .8,
        decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color.fromARGB(200, 135, 126, 127),
                offset: const Offset(
                  0.0,
                  3.0,
                ),
                blurRadius: 5.0,
                //spreadRadius: 2.0,
              )
            ],
            borderRadius: BorderRadius.all(Radius.circular(50)),
            border: Border.all(color: main_color),
            color: background_color),
        child: Center(
            child: Text(text,
                style: text_style(text_color: text_color, size: text_size))),
      ));
}

Widget label(IconData? icon, String text) {
  return Row(
    children: [
      Icon(icon),
      Text(
        text,
        style: text_style(
            size: 12, text_color: Color.fromARGB(255, 135, 126, 127)),
      ),
    ],
  );
}

Widget textField(
    {textEditingController, icon, text, suffixicon, keyboardtype}) {
  return TextFormField(
    keyboardType: keyboardtype,
    controller: textEditingController,
    style: text_style(size: 16, text_color: Color.fromARGB(255, 25, 24, 24)),
    decoration:
        InputDecoration(label: label(icon, text), suffixIcon: suffixicon),
  );
}

Widget passwordField(
    {textVisible, textVisibleState, labelText, paswordcontroller}) {
  return TextFormField(
    controller: paswordcontroller,
    obscureText: textVisible,
    style: text_style(size: 16, text_color: Color.fromARGB(255, 25, 24, 24)),
    decoration: InputDecoration(
        suffixIcon: GestureDetector(
          onTap: () => textVisibleState(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
            child: Icon(
              Icons.visibility,
              size: 20,
            ),
          ),
        ),
        label: label(Icons.lock, labelText)),
  );
}

Widget calender({dateController, calenderState, calenderText}) {
  return TextFormField(
    readOnly: true,
    controller: dateController,
    keyboardType: TextInputType.datetime,
    onTap: () async {
      calenderState(dateController);
    },
    style: text_style(size: 16, text_color: Color.fromARGB(255, 25, 24, 24)),
    decoration:
        InputDecoration(label: label(Icons.calendar_month, calenderText)),
  );
}

Widget time({timeController, timeState, timeText}) {
  return TextFormField(
    readOnly: true,
    controller: timeController,
    keyboardType: TextInputType.datetime,
    onTap: () async {
      timeState(timeController);
    },
    style: text_style(size: 16, text_color: Color.fromARGB(255, 25, 24, 24)),
    decoration: InputDecoration(label: label(Icons.alarm_on, timeText)),
  );
}

List<DropdownMenuItem> dropDownItemBuilder(List<String> list) {
  List<DropdownMenuItem> menuItems = [];
  for (int i = 0; i < list.length; i++) {
    menuItems.add(DropdownMenuItem(value: list[i], child: Text(list[i])));
  }
  return menuItems;
}

Widget dropDown({list, labelText, labelIcon, onValueChanged, value}) {
  return DropdownButtonFormField(
      value: value,
      decoration: InputDecoration(label: label(labelIcon, labelText)),
      items: dropDownItemBuilder(list),
      onChanged: onValueChanged,
      style: text_style(size: 16, text_color: Color.fromARGB(255, 25, 24, 24)),
      icon: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
        child: Container(
          margin: EdgeInsets.only(bottom: 15),
          child: Icon(
            Icons.arrow_drop_down,
            size: 25,
          ),
        ),
      ));
}

Widget infoTile(
    {context,
    icon,
    text,
    textsize,
    iconsize,
    visible,
    edit = false,
    editfunction}) {
  return Row(
    children: [
      Icon(
        icon,
        color: main_color,
        size: iconsize,
      ),
      SizedBox(width: 5),
      Container(
        constraints: BoxConstraints(
            maxWidth:
                MediaQuery.of(context).size.width * 0.45), // Adjust as needed
        child: Text(
          text,
          overflow: (visible) ? TextOverflow.visible : TextOverflow.ellipsis,
          style: text_style(size: textsize, text_color: title_color),
        ),
      ),
      SizedBox(width: 5),
      (edit)
          ? GestureDetector(
              child: Icon(Icons.edit, size: 12, color: main_color),
              onTap: editfunction,
            )
          : Container()
    ],
  );
}

Widget profilePic({url, size}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 5, 10),
    child: CircleAvatar(
      radius: size,
      backgroundImage: (url == null)
          ? NetworkImage(
              'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png')
          : NetworkImage(url),
    ),
  );
}
