import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/mainscreens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bloodnation/mainscreens/posts.dart';
import 'package:bloodnation/mainscreens/donorlist.dart';
import 'package:bloodnation/mainscreens/posthelper.dart';
import 'package:rxdart/rxdart.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user;
  @override
  void initState() {
    super.initState();
    setState(() {
      user = getuser();
    });
  }

  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * .9,
      child: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 15, 15, -0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: 20, top: 10),
                  child: Image.asset(
                    'assets/home.png',
                  ),
                ),
                Text(
                  "Blood Needed Today",
                  style: text_style(
                      size: 25, text_color: main_color.withOpacity(.8)),
                ),
                Container(
                  height: 1,
                  color: main_color.withOpacity(.8),
                )
              ],
            ),
          ),
          TopPosts(),
          GestureDetector(
            onTap: () {
              if (user == null) {
                setState(() {
                  user = getuser();
                });
              }
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 15, 15, -0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Local Blood Hero",
                    style: text_style(
                        size: 25, text_color: main_color.withOpacity(.8)),
                  ),
                  Container(
                    height: 1,
                    color: main_color.withOpacity(.8),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(
                              0.7), // Adjust the opacity value as needed
                          BlendMode.dstATop,
                        ),
                        image: AssetImage('assets/OIG.jpg'),
                        fit: BoxFit.cover),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                height: MediaQuery.of(context).size.height * .7,
                child: Column(
                  children: [
                    BloodHero(user: user),
                  ],
                )),
          )
        ],
      ),
    );
  }
}

class TopPosts extends StatefulWidget {
  const TopPosts({super.key});

  @override
  State<TopPosts> createState() => _TopPostsState();
}

class _TopPostsState extends State<TopPosts> {
  PageController? _pagecontroller;

  @override
  void initState() {
    super.initState();
    _pagecontroller = PageController(initialPage: 0, viewportFraction: 0.95);
  }

  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('post')
            .where('Donation DateTime',
                isGreaterThan: DateTime.now(),
                isLessThan: DateTime.now().add(Duration(days: 1)))
            .orderBy('Donation DateTime', descending: true)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            List<DocumentSnapshot> documents = snap.data!.docs;
            return Container(
              height: MediaQuery.of(context).size.height * .325,
              child: PageView(
                padEnds: false,
                controller: _pagecontroller,
                children: documents.map((doc) {
                  return FutureBuilder(
                    future: getDocumentSnapshot(id: doc['user']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        User? current = getuser();

                        var userdata = snapshot.data.data();
                        var posttime = doc['Post Time'].toDate();
                        String time = "";
                        if (posttime.difference(DateTime.now()).inHours >= 24) {
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
                          current: current,
                          user: doc['user'],
                          context: context,
                          requestor: userdata['name'],
                          url: userdata['photourl'],
                        );
                      } else {
                        return Container(
                          height: MediaQuery.of(context).size.height * .325,
                          child: Center(
                            child:
                                CircularProgressIndicator(color: Colors.amber),
                          ),
                        );
                      }
                    },
                  );
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
}

class BloodHero extends StatefulWidget {
  User? user;

  BloodHero({this.user});

  @override
  State<BloodHero> createState() => _BloodHeroState();
}

class _BloodHeroState extends State<BloodHero> {
  User? current;
  void initState() {
    // TODO: implement initState
    setState(() {
      current = auth.currentUser;
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {});
      },
      child: FutureBuilder(
          future: getDocumentSnapshot(id: widget.user!.uid),
          builder: (context, Currentsnapshot) {
            if (Currentsnapshot.hasData) {
              var Currentuserdata = Currentsnapshot.data.data();

              return StreamBuilder(
                stream: firestore
                    .collection('userdata')
                    .where('district', isEqualTo: Currentuserdata['district'])
                    .snapshots(),
                builder: (context, snap) {
                  if (snap.hasData) {
                    List<DocumentSnapshot> documents = snap.data!.docs;
                    documents.sort((a, b) {
                      double avgratingA = a['avgrating'] ?? 0.0;
                      double avgratingB = b['avgrating'] ?? 0.0;
                      return avgratingB
                          .compareTo(avgratingA); // descending order
                    });
                    List<DocumentSnapshot> firstFiveDocuments =
                        documents.take(5).toList();
                    return Column(
                      children: firstFiveDocuments.map((doc) {
                        dynamic data = doc.data();
                        double avgrating = 0;
                        if (data['rating'] != null) {
                          List ratings = data['rating'].values.toList();
                          double sum = 0.0;

                          for (double number in ratings) {
                            sum += number;
                          }
                          double avg =
                              sum.toDouble() / ratings.length.toDouble();

                          avgrating = avg;
                        }
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.all(Radius.zero)),
                                    surfaceTintColor: main_color_light,
                                    backgroundColor:
                                        Colors.white.withOpacity(1),
                                    insetPadding: EdgeInsets.zero,
                                    child: Container(
                                        child: Profile(
                                      id: data['id'],
                                    )),
                                    insetAnimationCurve: Curves.bounceIn,
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
                              rating: data['avgrating'].toStringAsFixed(1)),
                        );
                      }).toList(),
                    );
                  } else {
                    return Container();
                  }
                },
              );
            } else {
              return Container();
            }
          }),
    );
  }
}
