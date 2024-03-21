import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_core/firebase_core.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;

Future createuser({email, password}) async {
  try {
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email!,
      password: password!,
    );
    return userCredential;
  } catch (e) {
    // Handle user creation errors
    throw e;
  }
}

User? getuser() {
  return auth.currentUser;
}

Future<String?> getDocumentId({id}) async {
  QuerySnapshot snap =
      await firestore.collection('userdata').where('id', isEqualTo: id).get();

  if (snap.docs.isNotEmpty) {
    DocumentSnapshot doc =
        snap.docs.firstWhere((element) => element['id'] == id);
    return doc.id;
  } else
    return null;
}

Future<dynamic> getDocumentSnapshot({id}) async {
  String? docId = await getDocumentId(id: id);
  var snap = await firestore.collection('userdata').doc(docId).get();
  return snap;
}

Future<dynamic> getPostSnapshot({id}) async {
  var snap = await firestore.collection('post').doc(id).get();
  return snap;
}

Future<UserCredential> login({email, password}) async {
  try {
    final userCredential =
        await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email!,
      password: password!,
    );
    return userCredential;
  } catch (e) {
    throw e;
  }
}

Future signUpWithGoogle() async {
  try {
    GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    if (googleUser == null) {
      print('Sign-in cancelled by user');
    } else {
      print('Signed in as ${googleUser.displayName}');
    }
    GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (error) {
    print('Error occurred during sign-in: $error');
  }
}

Future<void> logOut() async {
  await FirebaseAuth.instance.signOut();
  await GoogleSignIn().signOut();
}

Future<void> addData({collectionName, data}) async {
  await firestore.collection(collectionName).add(data);
}

Future<void> updateData({collection, docId, data}) async {
  firestore.collection(collection).doc(docId).update(data);
}

Future<bool> isResponded({docId, userId}) async {
  DocumentSnapshot doc = await firestore.collection('post').doc(docId).get();
  if (doc.exists) {
    var responded = (doc.data?.call() as Map?)?['responded'];

    if (responded != null && responded.contains(userId)) {
      return true;
    }
    return false;
  } else
    return false;
}

Future<void> deleteDocument(String collectionName, String documentId) async {
  try {
    // Reference to the document you want to delete
    DocumentReference documentReference =
        FirebaseFirestore.instance.collection(collectionName).doc(documentId);

    // Delete the document
    await documentReference.delete();
  } catch (e) {}
}
