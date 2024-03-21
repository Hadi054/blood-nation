// ignore_for_file: prefer_const_constructors, sort_child_properties_last, non_constant_identifier_names, prefer_interpolation_to_compose_strings
import 'package:bloodnation/backend/firebase.dart';
import 'package:bloodnation/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:bloodnation/mainscreens/posthelper.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class Post extends StatefulWidget {
  const Post({super.key});

  @override
  State<Post> createState() => _PostsState();
}

class _PostsState extends State<Post> {
  User? current;

  PageController? _pagecontroller;

  @override
  void initState() {
    setState(() {
      current = getuser();
    });
    super.initState();
    _pagecontroller = PageController(initialPage: 0, viewportFraction: 0.95);
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                "In Your District",
                style: text_style(
                    size: 25, text_color: main_color.withOpacity(.8)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(
                height: 1,
                color: main_color.withOpacity(.8),
              ),
            ),
            TopPosts(),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                "Matches Your Blood",
                style: text_style(
                    size: 25, text_color: main_color.withOpacity(.8)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(
                height: 1,
                color: main_color.withOpacity(.8),
              ),
            ),
            BGPost(),
            SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text(
                "All Posts",
                style: text_style(
                    size: 25, text_color: main_color.withOpacity(.8)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Container(
                height: 1,
                color: main_color.withOpacity(.8),
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height * .65,
              child: AllPosts(),
            ),
          ],
        ),
      ),
    );
  }
}

class AllPosts extends StatefulWidget {
  const AllPosts({super.key});

  @override
  State<AllPosts> createState() => _AllPostsState();
}

class _AllPostsState extends State<AllPosts> {
  User? current;

  PageController? _pagecontroller;

  @override
  void initState() {
    setState(() {
      current = getuser();
    });
    super.initState();
    _pagecontroller = PageController(initialPage: 0, viewportFraction: 0.95);
  }

  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestore
            .collection('post')
            .orderBy('Donation DateTime', descending: false)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasData) {
            List<DocumentSnapshot> documents = snap.data!.docs;
            return Container(
              height: MediaQuery.of(context).size.height * .55,
              child: ListView(
                children: documents.map((doc) {
                  return FutureBuilder(
                    future: getDocumentSnapshot(id: doc['user']),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
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
                        return Container();
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

class TopPosts extends StatefulWidget {
  const TopPosts({super.key});

  @override
  State<TopPosts> createState() => _TopPostsState();
}

class _TopPostsState extends State<TopPosts> {
  PageController? _pagecontroller;
  User? current;
  @override
  void initState() {
    super.initState();
    _pagecontroller = PageController(initialPage: 0, viewportFraction: 0.95);
    current = getuser();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDocumentSnapshot(id: current!.uid),
        builder: (context, usersnap) {
          if (usersnap.hasData) {
            var userdata = usersnap.data.data();
            return StreamBuilder(
                stream: firestore
                    .collection('post')
                    .where('district', isEqualTo: userdata['district'])
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
                                if (posttime
                                        .difference(DateTime.now())
                                        .inHours >=
                                    24) {
                                  DateFormat format =
                                      DateFormat('MMMM d, yyyy');
                                  time = format.format(posttime);
                                } else {
                                  DateFormat format = DateFormat('hh:mm a');
                                  time = 'today, ' + format.format(posttime);
                                }
                                DateFormat format =
                                    DateFormat('MMMM d, yyyy , hh:mm a');
                                var donationdate = format
                                    .format(doc['Donation DateTime'].toDate());
                                return BloodPostCard(
                                  doc: doc,
                                  current: current,
                                  user: doc['user'],
                                  context: context,
                                  requestor: userdata['name'],
                                  url: userdata['photourl'],
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.amber),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Container(
                      height: MediaQuery.of(context).size.height * .325,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  }
                });
          } else {
            return Container(
              height: MediaQuery.of(context).size.height * .325,
              child: Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            );
          }
        });
  }
}

class BGPost extends StatefulWidget {
  const BGPost({super.key});

  @override
  State<BGPost> createState() => _BGPostState();
}

class _BGPostState extends State<BGPost> {
  PageController? _pagecontroller;
  User? current;
  @override
  void initState() {
    super.initState();
    _pagecontroller = PageController(initialPage: 0, viewportFraction: 0.95);
    current = getuser();
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getDocumentSnapshot(id: current!.uid),
        builder: (context, usersnap) {
          if (usersnap.hasData) {
            var userdata = usersnap.data.data();
            return StreamBuilder(
                stream: firestore
                    .collection('post')
                    .where('Blood Group', isEqualTo: userdata['blood group'])
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
                                if (posttime
                                        .difference(DateTime.now())
                                        .inHours >=
                                    24) {
                                  DateFormat format =
                                      DateFormat('MMMM d, yyyy');
                                  time = format.format(posttime);
                                } else {
                                  DateFormat format = DateFormat('hh:mm a');
                                  time = 'today, ' + format.format(posttime);
                                }
                                DateFormat format =
                                    DateFormat('MMMM d, yyyy , hh:mm a');
                                var donationdate = format
                                    .format(doc['Donation DateTime'].toDate());
                                return BloodPostCard(
                                  doc: doc,
                                  current: current,
                                  user: doc['user'],
                                  context: context,
                                  requestor: userdata['name'],
                                  url: userdata['photourl'],
                                );
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.amber),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return Container(
                      height: MediaQuery.of(context).size.height * .325,
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  }
                });
          } else {
            return Container(
              height: MediaQuery.of(context).size.height * .325,
              child: Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
            );
          }
        });
  }
}
