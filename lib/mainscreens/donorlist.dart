// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last, avoid_print

import 'package:bloodnation/constants.dart';
import 'package:bloodnation/mainscreens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bloodnation/districs.dart';
import 'package:bloodnation/backend/firebase.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class DonorList extends StatefulWidget {
  const DonorList({super.key});

  @override
  State<DonorList> createState() => _DonorListState();
}

class _DonorListState extends State<DonorList> with TickerProviderStateMixin {
  late final TabController _tabController;
  String district = '';
  String bloodgroup = '';
  String regdistrict = '';
  String regbloodgroup = '';
  List<DocumentSnapshot> mergeDocuments(
    List<DocumentSnapshot> documents1,
    List<DocumentSnapshot> documents2,
  ) {
    Set<DocumentSnapshot> mergedSet = {...documents1, ...documents2};
    return mergedSet.toList();
  }

  User? user = getuser();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar.secondary(tabs: [
          Tab(
            child: Text("Registered Donors", style: text_style()),
          ),
          Tab(
            child: Text("Unregistered Donors", style: text_style()),
          )
        ], controller: _tabController),
        Container(
          height: MediaQuery.of(context).size.height * .725,
          child: TabBarView(
            controller: _tabController,
            children: [
              FutureBuilder(
                future: getDocumentSnapshot(id: user!.uid),
                builder: (context, usersnapshot) {
                  if (usersnapshot.hasData) {
                    var userdata = usersnapshot.data.data();

                    return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * .07,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 12.0, right: 12.0),
                            child: Row(children: [
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  child: dropDown(
                                      labelIcon: Icons.bloodtype,
                                      labelText: 'Districts',
                                      list: bangladeshDistricts,
                                      onValueChanged: (v) {
                                        if (v == 'All') v = '';
                                        if (v == 'Current')
                                          v = userdata['district'];
                                        setState(() {
                                          regdistrict = v;
                                        });
                                      })),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  child: dropDown(
                                      labelIcon: Icons.bloodtype,
                                      labelText: "Blood Group",
                                      list: bloodGroups,
                                      onValueChanged: (v) {
                                        if (v == 'All') v = '';
                                        if (v == 'Your Group')
                                          v = userdata['blood group'];

                                        setState(() {
                                          regbloodgroup = v;
                                        });
                                      })),
                            ]),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .655,
                          child: StreamBuilder<QuerySnapshot>(
                              stream:
                                  firestore.collection('userdata').snapshots(),
                              builder: (context, snap) {
                                if (snap.hasData) {
                                  List<DocumentSnapshot> document =
                                      snap.data!.docs;

                                  return ListView(
                                    children: document.map((doc) {
                                      dynamic data = doc.data();
                                      var addresslow =
                                          data['address'].toLowerCase();
                                      double avgrating = 0;

                                      if (data['rating'] != null) {
                                        List ratings =
                                            data['rating'].values.toList();
                                        double sum = 0.0;

                                        for (double number in ratings) {
                                          sum += number;
                                        }
                                        double avg = sum.toDouble() /
                                            ratings.length.toDouble();

                                        avgrating = avg;
                                      }
                                      if (addresslow.contains(
                                              regdistrict.toLowerCase()) &&
                                          data['blood group']
                                              .contains(regbloodgroup)) {
                                        return GestureDetector(
                                          onTap: () {
                                            showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .zero)),
                                                    surfaceTintColor:
                                                        main_color_light,
                                                    backgroundColor: Colors
                                                        .white
                                                        .withOpacity(1),
                                                    insetPadding:
                                                        EdgeInsets.zero,
                                                    child: Container(
                                                        child: Profile(
                                                      id: data['id'],
                                                    )),
                                                    insetAnimationCurve:
                                                        Curves.bounceIn,
                                                  );
                                                });
                                          },
                                          child: donorCard(
                                              context: context,
                                              url: data['photourl'],
                                              name: data['name'],
                                              address: data["address"],
                                              contact: data["contact"],
                                              bloodgroup: data["blood group"],
                                              rating: avgrating),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }).toList(),
                                  );
                                } else {
                                  return Container();
                                }
                              }),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
              FutureBuilder(
                future: getDocumentSnapshot(id: user!.uid),
                builder: (context, usersnapshot) {
                  if (usersnapshot.hasData) {
                    var userdata = usersnapshot.data.data();

                    return Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * .072,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 12.0, right: 12.0),
                            child: Row(children: [
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  child: dropDown(
                                      labelIcon: Icons.bloodtype,
                                      labelText: 'Districts',
                                      list: bangladeshDistricts,
                                      onValueChanged: (v) {
                                        if (v == 'All') v = '';
                                        if (v == 'Current')
                                          v = userdata['district'];
                                        setState(() {
                                          district = v;
                                        });
                                      })),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * .45,
                                  child: dropDown(
                                      labelIcon: Icons.bloodtype,
                                      labelText: "Blood Group",
                                      list: bloodGroups,
                                      onValueChanged: (v) {
                                        if (v == 'All') v = '';
                                        if (v == 'Your Group')
                                          v = userdata['blood group'];
                                        setState(() {
                                          bloodgroup = v;
                                        });
                                      })),
                            ]),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * .653,
                          child: StreamBuilder<QuerySnapshot>(
                              stream: firestore
                                  .collection('unreg_donors')
                                  .where('Blood Group',
                                      isGreaterThanOrEqualTo: bloodgroup)
                                  .snapshots(),
                              builder: (context, snap) {
                                if (snap.hasData) {
                                  List<DocumentSnapshot> document =
                                      snap.data!.docs;
                                  return StreamBuilder<Object>(
                                      stream: firestore
                                          .collection('unreg_donors')
                                          .where('addresslow',
                                              isGreaterThanOrEqualTo:
                                                  district.toLowerCase())
                                          .snapshots(),
                                      builder: (context, snapDistrict) {
                                        if (snapDistrict.hasData) {
                                          List<DocumentSnapshot>
                                              documentsDistrict = (snapDistrict
                                                      .data as QuerySnapshot)
                                                  .docs;
                                          List<DocumentSnapshot>
                                              commonDocuments = document
                                                  .where((doc1) =>
                                                      documentsDistrict.any(
                                                          (doc2) =>
                                                              doc1.id ==
                                                              doc2.id))
                                                  .toList();
                                          return ListView(
                                            children:
                                                commonDocuments.map((doc) {
                                              dynamic data = doc.data();
                                              if (data['addresslow'].contains(
                                                      district.toLowerCase()) &&
                                                  data['Blood Group']
                                                      .contains(bloodgroup)) {
                                                return donorCard(
                                                    context: context,
                                                    url: null,
                                                    name: data[
                                                        'Name (Full Name)'],
                                                    address: data[
                                                        "Address (your university hall address is not acceptable)"],
                                                    contact: data["Phone no."],
                                                    bloodgroup:
                                                        data["Blood Group"]);
                                              } else {
                                                return Container();
                                              }
                                            }).toList(),
                                          );
                                        } else {
                                          return Center(
                                            child: CircularProgressIndicator(
                                                color: Colors.amber),
                                          );
                                        }
                                      });
                                } else {
                                  return Container();
                                }
                              }),
                        ),
                      ],
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget donorCard({context, bloodgroup, url, name, address, contact, rating}) {
  return UnconstrainedBox(
    child: Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      decoration: BoxDecoration(
          color: main_color_light,
          borderRadius: BorderRadius.all(Radius.circular(12))),
      width: MediaQuery.of(context).size.width * .9,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  profilePic(size: 25.0, url: url),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.45),
                        child: Text(name,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            maxLines: null,
                            style: text_style(
                              weight: FontWeight.bold,
                              size: 20,
                            )),
                      ),
                      infoTile(
                          visible: false,
                          context: context,
                          icon: Icons.location_on,
                          text: address,
                          iconsize: 12.0,
                          textsize: 12.0),
                      infoTile(
                          visible: false,
                          context: context,
                          icon: Icons.phone,
                          text: contact,
                          iconsize: 12.0,
                          textsize: 12.0),
                      (rating != null)
                          ? infoTile(
                              visible: false,
                              context: context,
                              icon: Icons.star,
                              text: rating.toString(),
                              iconsize: 12.0,
                              textsize: 12.0)
                          : Container(),
                      SizedBox(
                        height: 5,
                      )
                    ],
                  ),
                ],
              ),
              Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(bloodgroup,
                            style:
                                text_style(text_color: main_color, size: 16)),
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                    ),
                  ),
                  Icon(
                    Icons.bloodtype,
                    color: main_color,
                    size: 25,
                  )
                ],
              )
            ],
          ),
        ],
      ),
    ),
  );
}
