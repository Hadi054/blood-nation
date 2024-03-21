// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'package:bloodnation/authenticationscreens/edit.dart';
import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/backend/location.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/mainscreens/posthelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:bloodnation/backend/upload.dart';
import 'package:flutter/material.dart';
import 'package:bloodnation/constants.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bloodnation/mainscreens/chatscreen.dart';
import 'package:translator/translator.dart';

class Profile extends StatefulWidget {
  String? id;
  Profile({this.id});
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  late final TabController _tabController;
  User? user = getuser();

  void initState() {
    super.initState();
    _tabController =
        TabController(length: (widget.id == null) ? 4 : 2, vsync: this);
  }

  List<Tab> everyone = [
    Tab(
        child: Text(
      'General profile',
      style: text_style(),
    )),
    Tab(
      child: Text('Donation Profie', style: text_style()),
    ),
  ];
  List<Tab> me = [
    Tab(
        child: Text(
      'General profile',
      style: text_style(),
    )),
    Tab(
      child: Text('Donation Profie', style: text_style()),
    ),
    Tab(
      child: Text('Your Posts', style: text_style()),
    ),
    Tab(
      child: Text('Chats', style: text_style()),
    )
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder(
          future: getDocumentSnapshot(
              id: (widget.id == null) ? user!.uid : widget.id),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data.data();
              if (data != null) {
                var birthdate = data['birthdate'].toDate();
                DateFormat format = DateFormat('MMMM d, yyyy');
                var age =
                    (birthdate.difference(DateTime.now()).inDays ~/ 365) * -1;
                birthdate = format.format(birthdate);
                List keys = snapshot.data.data().keys.toList();
                var last_donation = data['last donation'].toDate();
                var last_don_dif =
                    (last_donation.difference(DateTime.now()).inDays ~/ 30) *
                        -1;
                String a = last_don_dif.toString() + ' since last donation';
                double avgrating = 0;
                List<Widget> chats = [];

                if (data['chats'] != null) {
                  for (var i in data['chats']) {
                    Widget chat = FutureBuilder(
                      future: getDocumentSnapshot(id: i),
                      builder: (context, chatSnapshot) {
                        if (chatSnapshot.hasData) {
                          var chatData = chatSnapshot.data.data();
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: GestureDetector(
                              onTap: () {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return ChatScreen(
                                        receiver: chatData['id'],
                                      );
                                    });
                              },
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .07,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(.2),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15))),
                                child: Row(children: [
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(chatData['photourl']),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 15.0),
                                    child: Text(
                                      chatData['name'],
                                      style: text_style(),
                                    ),
                                  )
                                ]),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                    chats.add(chat);
                  }
                }
                bool alreadyRated = false;
                if (data['rating'] != null) {
                  List ratings = data['rating'].values.toList();
                  double sum = 0.0;

                  for (double number in ratings) {
                    sum += number;
                  }
                  double avg = sum.toDouble() / ratings.length.toDouble();

                  avgrating = avg;
                }
                //   // double sum =
                //   //     ratings.reduce((value, element) => value + element);
                //   // print(sum);
                //   // avgrating = sum / data['rating'].length;
                //   // print(avgrating);
                // }
                var math;
                return Column(
                  children: <Widget>[
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Stack(
                            children: [
                              profilePic(size: 70.0, url: data['photourl']),
                              (widget.id == null)
                                  ? Positioned(
                                      top: 12,
                                      right: 12,
                                      child: GestureDetector(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return EditPhoto(
                                                  profileimage:
                                                      data['photourl'],
                                                );
                                              },
                                            ).then((value) {
                                              setState(() {});
                                            });
                                          },
                                          child: Icon(
                                            Icons.edit,
                                            color: main_color,
                                            size: 15,
                                          )),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .5,
                                child: Row(
                                  children: [
                                    Text(data['name'],
                                        style: text_style(
                                          size: 18,
                                        ),
                                        maxLines: null,
                                        overflow: TextOverflow.fade),
                                    SizedBox(width: 5),
                                    (widget.id == null)
                                        ? GestureDetector(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return EditName(
                                                    username: data['name'],
                                                  );
                                                },
                                              ).then((value) {
                                                setState(() {});
                                              });
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: main_color,
                                              size: 12,
                                            ),
                                          )
                                        : Container()
                                  ],
                                ),
                              ),
                              infoTile(
                                  edit: (widget.id == null) ? true : false,
                                  editfunction: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditNumber(
                                          number: data['contact'],
                                        );
                                      },
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  },
                                  icon: Icons.phone,
                                  context: context,
                                  text: data['contact'],
                                  visible: true,
                                  textsize: 12.0),
                              infoTile(
                                  edit: (widget.id == null) ? true : false,
                                  editfunction: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditEmail(
                                          email: data['email'],
                                        );
                                      },
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  },
                                  icon: Icons.email,
                                  context: context,
                                  text: data['email'],
                                  visible: true,
                                  textsize: 12.0),
                              infoTile(
                                  icon: Icons.star,
                                  context: context,
                                  text: avgrating.toStringAsFixed(1),
                                  visible: true,
                                  textsize: 12.0),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: (widget.id == user!.uid || widget.id == null)
                            ? []
                            : [
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                main_color)),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          double? rate = 3.0;

                                          return Dialog(
                                            backgroundColor: Colors.white,
                                            child: Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .3,
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text("Rate Donor",
                                                        style: text_style(
                                                            size: 30)),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: RatingBar.builder(
                                                      initialRating: 3,
                                                      minRating: 1,
                                                      direction:
                                                          Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemCount: 5,
                                                      itemPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 4.0),
                                                      itemBuilder:
                                                          (context, _) => Icon(
                                                        Icons.star,
                                                        color: Colors.amber,
                                                      ),
                                                      updateOnDrag: true,
                                                      onRatingUpdate: (rating) {
                                                        rate = rating;
                                                      },
                                                    ),
                                                  ),
                                                  button(
                                                      function: () async {
                                                        String? docid =
                                                            await getDocumentId(
                                                                id: widget.id);
                                                        data['rating']
                                                            [user!.uid] = rate;
                                                        if (data['rating'] !=
                                                            null) {
                                                          List ratings =
                                                              data['rating']
                                                                  .values
                                                                  .toList();
                                                          double sum = 0.0;

                                                          for (double number
                                                              in ratings) {
                                                            sum += number;
                                                          }
                                                          double avg = sum
                                                                  .toDouble() /
                                                              ratings.length
                                                                  .toDouble();

                                                          avgrating = avg;
                                                        }
                                                        data['avgrating'] =
                                                            avgrating;
                                                        await updateData(
                                                            collection:
                                                                'userdata',
                                                            data: data,
                                                            docId: docid);
                                                        setState(() {});

                                                        Navigator.pop(context);
                                                      },
                                                      context: context,
                                                      text: 'Submit',
                                                      background_color:
                                                          main_color,
                                                      text_color: Colors.white),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.star,
                                            color: Colors.white, size: 25),
                                        Text('Rate',
                                            style: text_style(
                                                size: 15,
                                                text_color: Colors.white)),
                                      ],
                                    )),
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                main_color)),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return ChatScreen(
                                              receiver: widget.id,
                                            );
                                          });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.chat,
                                            color: Colors.white, size: 25),
                                        Text('Chat',
                                            style: text_style(
                                                size: 15,
                                                text_color: Colors.white)),
                                      ],
                                    ))
                              ],
                      ),
                    ),
                    TabBar.secondary(
                        tabs: (widget.id == null) ? me : everyone,
                        controller: _tabController),
                    Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: TabBarView(controller: _tabController, children: [
                        ListView(children: [
                          Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey
                                            .withOpacity(0.1), //color of shadow
                                        spreadRadius: 2, //spread radius
                                        blurRadius: 2, // blur radius
                                        offset: Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                    color: main_color_light,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: (widget.id == null)
                                    ? ListTile(
                                        trailing: GestureDetector(
                                            onTap: () async {
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return EditAddress(
                                                      Address: data['address'],
                                                    );
                                                  });
                                            },
                                            child: Icon(
                                              Icons.edit,
                                              color: main_color,
                                              size: 18,
                                            )),
                                        subtitle: Text(data['address'],
                                            style: text_style()),
                                        title: Text(
                                          "Address",
                                          style: text_style(),
                                        ))
                                    : ListTile(
                                        subtitle: Text(data['address'],
                                            style: text_style()),
                                        title: Text(
                                          "Address",
                                          style: text_style(),
                                        )),
                              )),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                function: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditBirth(
                                          bday: data['birthdate'],
                                        );
                                      }).then((value) {
                                    setState(() {});
                                  });
                                },
                                title: 'Birth Date',
                                subtitle: birthdate),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                title: 'Age', subtitle: age.toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                function: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return EditGender(
                                          gen: data['gender'],
                                        );
                                      }).then((value) {
                                    setState(() {});
                                  });
                                },
                                title: 'Gender',
                                subtitle: data['gender']),
                          ),
                        ]),
                        ListView(children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                function: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return EditBG(
                                        bg: data['blood group'],
                                      );
                                    },
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                                title: 'Blood Group',
                                subtitle: data['blood group'].toString()),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                function: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return EditDonDate(
                                        bday: data['last donation'],
                                      );
                                    },
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                                color: (last_don_dif >= 3)
                                    ? Color.fromARGB(255, 35, 218, 63)
                                    : Colors.redAccent,
                                subtitle: last_don_dif.toString() +
                                    ' months since last donation',
                                title: ((last_don_dif >= 3) ? '' : 'Not ') +
                                    'Safe to donate'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                function: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return EditWeight(
                                        w: data['weight'],
                                      );
                                    },
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                                color: (int.parse(data['weight']) >= 50)
                                    ? Color.fromARGB(255, 35, 218, 63)
                                    : Colors.redAccent,
                                subtitle: data['weight'] + ' Kg',
                                title: ((int.parse(data['weight']) >= 50)
                                        ? ''
                                        : 'Not ') +
                                    'Safe to donate'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                function: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return EditCondition(
                                        condition: data['health conditions'],
                                      );
                                    },
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                                color: (data['health conditions'] == 'None')
                                    ? Color.fromARGB(255, 35, 218, 63)
                                    : Colors.redAccent,
                                subtitle:
                                    ((data['health conditions'] == 'None'))
                                        ? 'No Serious Health Conditions'
                                        : data['health conditions'],
                                title: ((data['health conditions'] == 'None')
                                        ? ''
                                        : 'Not ') +
                                    'Safe to donate'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: profileCard(
                                function: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return EditEmergencyNumber(
                                        number: data['emergency contact'],
                                      );
                                    },
                                  ).then((value) {
                                    setState(() {});
                                  });
                                },
                                title: 'Emergency Contact',
                                subtitle: data['emergency contact'].toString()),
                          ),
                        ]),
                        (widget.id == null) ? YourPosts() : Container(),
                        (widget.id == null)
                            ? ListView(
                                children: chats,
                              )
                            : Container()
                      ]),
                    ),
                  ],
                );
              } else {
                return Container(
                  height: MediaQuery.of(context).size.height * .325,
                  child: Center(
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
                );
              }
            } else
              return Container(
                height: MediaQuery.of(context).size.height * .325,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.amber),
                ),
              );
          }),
    );
  }

  Widget YourPosts() {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('post')
            .orderBy('Donation DateTime', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            List<DocumentSnapshot> documents = snap.data!.docs;
            return Container(
              height: MediaQuery.of(context).size.height * .325,
              child: ListView(
                children: documents.map((doc) {
                  if (doc['user'] == user!.uid) {
                    return FutureBuilder(
                      future: getDocumentSnapshot(id: doc['user']),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          var userdata = snapshot.data.data();
                          var posttime = doc['Post Time'].toDate();
                          String time = "";
                          if (posttime.difference(DateTime.now()).inHours >=
                              24) {
                            DateFormat format = DateFormat('MMMM d, yyyy');
                            time = format.format(posttime);
                          } else {
                            DateFormat format = DateFormat('hh:mm a');
                            time = 'today, ' + format.format(posttime);
                          }
                          DateFormat format =
                              DateFormat('MMMM d, yyyy , hh:mm a');
                          var donationdate =
                              format.format(doc['Donation DateTime'].toDate());
                          return BloodPostCard(
                            doc: doc,
                            current: user,
                            user: doc['user'],
                            context: context,
                            requestor: userdata['name'],
                            url: userdata['photourl'],
                          );
                        } else {
                          return Container();
                        }
                      },
                    );
                  } else
                    return Container();
                }).toList(),
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(color: Colors.amber),
            );
          }
        });
  }

  Widget profileCard({color, title, subtitle, function}) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: (color == null)
                  ? Colors.grey.withOpacity(0.1)
                  : color, //color of shadow
              spreadRadius: 2, //spread radius
              blurRadius: 2, // blur radius
              offset: Offset(0, 3), // changes position of shadow
            ),
          ],
          color: main_color_light,
          borderRadius: BorderRadius.all(Radius.circular(10))),
      child: (widget.id == null)
          ? ListTile(
              trailing: GestureDetector(
                  child: Icon(
                    Icons.edit,
                    size: 18,
                    color: main_color,
                  ),
                  onTap: function),
              subtitle: Text(subtitle, style: text_style()),
              title: Text(
                title,
                style: text_style(),
              ))
          : ListTile(
              subtitle: Text(subtitle, style: text_style()),
              title: Text(
                title,
                style: text_style(),
              )),
    );
  }
}
