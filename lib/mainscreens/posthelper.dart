import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/constants.dart';
import 'package:bloodnation/mainscreens/profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'posttracking.dart';
import 'package:bloodnation/mainscreens/donorlist.dart';

Widget BloodPostCard({
  context,
  current,
  user,
  doc,
  controller,
  requestor = "HAdi",
  url,
}) {
  return GestureDetector(
      onTap: () => extendmodal(
            current: current,
            doc: doc,
            user: user,
            controller: controller,
            context: context,
            requestor: requestor,
            url: url,
          ),
      child: PostBody(
          current: current,
          context: context,
          doc: doc,
          url: url,
          extended: false,
          requestor: requestor,
          user: user));
}

void extendmodal({
  context,
  current,
  doc,
  user,
  controller,
  requestor = "HAdi",
  url,
}) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          surfaceTintColor: main_color_light,
          backgroundColor: main_color_light.withOpacity(1),
          insetPadding: EdgeInsets.zero,
          child: PostMain(
            current: current,
            user: user,
            requestor: requestor,
            doc: doc,
            url: url,
          ),
          insetAnimationCurve: Curves.bounceIn,
        );
      });
}

class PostMain extends StatefulWidget {
  String requestor = "HAdi";
  String? user, url;
  User? current;
  dynamic doc;
  PostMain(
      {this.current,
      this.requestor = "HAdi",
      this.url = "google.com",
      this.user,
      this.doc});
  @override
  State<PostMain> createState() => _PostMainState();
}

class _PostMainState extends State<PostMain> with TickerProviderStateMixin {
  late final TabController _tabController;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [
        TabBar.secondary(
          tabs: [
            Tab(
              child: Text("About", style: text_style(size: 15)),
            ),
            Tab(
              child: Text("Details", style: text_style(size: 15)),
            ),
            Tab(
              child: Text("Responses", style: text_style(size: 15)),
            )
          ],
          controller: _tabController,
        ),
        Container(
          height: MediaQuery.of(context).size.height * .9,
          child: TabBarView(controller: _tabController, children: [
            ListView(
              children: [
                PostBody(
                    tabcontroller: _tabController,
                    current: widget.current,
                    context: context,
                    extended: true,
                    doc: widget.doc,
                    requestor: widget.requestor,
                    url: widget.url,
                    user: widget.user)
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Container(
                decoration: BoxDecoration(

                    // border: Border.all(color: main_color),
                    borderRadius: BorderRadius.all(Radius.circular(15))),
                child: ListView(children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(widget.doc['Description'],
                        textAlign: TextAlign.left, style: text_style(size: 16)),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.symmetric(
                            horizontal: BorderSide(color: Colors.black))),
                    child: ClipRRect(
                      child: (widget.doc['image'] != null)
                          ? Image.network(
                              widget.doc['image']!,
                              fit: BoxFit.fitWidth,
                            )
                          : null,
                    ),
                  ),
                ]),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 20, top: 10),
                  child: Text("People who have responded",
                      style: text_style(size: 20, text_color: main_color)),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 5),
                  child: Container(height: 1, color: main_color),
                ),
                FutureBuilder(
                    future:
                        firestore.collection('post').doc(widget.doc.id).get(),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        var responded = snap.data?['responded'];

                        return StreamBuilder(
                            stream:
                                firestore.collection('userdata').snapshots(),
                            builder: (context, snap) {
                              if (snap.hasData) {
                                List<DocumentSnapshot> document =
                                    snap.data!.docs;
                                return Container(
                                  height:
                                      MediaQuery.of(context).size.height * .5,
                                  child: ListView(
                                    children: document.map((doc) {
                                      dynamic data = doc.data();
                                      if (responded.contains(data['id'])) {
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
                                              bloodgroup: data["blood group"]),
                                        );
                                      } else {
                                        return Container();
                                      }
                                    }).toList(),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            });
                      } else
                        return Container();
                    }),
              ],
            )
          ]),
        ),
      ]),
    );
  }
}

Widget PostBody(
    {extended,
    tabcontroller,
    current,
    doc,
    requestor,
    user,
    context,
    url,
    contact}) {
  User? current = getuser();
  var posttime = doc['Post Time'].toDate();
  String time = "";
  if (posttime.difference(DateTime.now()).inHours >= 24) {
    DateFormat format = DateFormat('MMMM d, yyyy');
    time = format.format(posttime);
  } else {
    DateFormat format = DateFormat('hh:mm a');
    time = 'today, ' + format.format(posttime);
  }
  DateFormat format = DateFormat('MMMM d, yyyy, hh:mm a');
  var donationdate = format.format(doc['Donation DateTime'].toDate());
  return UnconstrainedBox(
    child: Container(
      margin: EdgeInsets.fromLTRB(0, 20, 0, 0),
      decoration: BoxDecoration(
          // border: Border.all(color: main_color, width: 0),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.2), //color of shadow
              spreadRadius: 1, //spread radius
              blurRadius: 1, // blur radius
              offset: Offset(0, 2), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.all(Radius.circular(15))),
      width: MediaQuery.of(context).size.width * .9,
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          topPortion(
              bloodgroup: doc['Blood Group'],
              posttime: time,
              requestor: requestor,
              url: url),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  infoTile(
                      visible: extended,
                      icon: Icons.location_on,
                      text: doc['Location'],
                      context: context,
                      textsize: 14.0),
                  SizedBox(height: 10),
                  infoTile(
                      visible: extended,
                      icon: Icons.date_range,
                      text: donationdate,
                      context: context,
                      textsize: 14.0),
                  SizedBox(height: 10),
                  infoTile(
                      visible: extended,
                      icon: Icons.phone,
                      text: doc['contact'],
                      context: context,
                      textsize: 14.0),
                ],
              ),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: main_color,
                        border: Border.all(color: main_color),
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: main_color,
                      child: Text(doc['Blood Group'],
                          style:
                              text_style(text_color: Colors.white, size: 22)),
                    ),
                  ),
                  Icon(Icons.bloodtype, color: Colors.white),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Buttonbar(
            doc: doc,
            user: user,
            current: current,
          ),
        ]),
      ),
    ),
  );
}

Widget topPortion({bloodgroup, requestor, posttime, url}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            foregroundImage: (url == null)
                ? NetworkImage(
                    'https://developers.elementor.com/docs/assets/img/elementor-placeholder-image.png')
                : NetworkImage(url),
            radius: 18,
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(requestor, style: text_style(size: 12)),
              Text(posttime, style: text_style(size: 12))
            ],
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: Container(
          height: 1,
          color: main_color,
        ),
      )
    ],
  );
}
