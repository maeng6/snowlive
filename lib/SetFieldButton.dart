import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

Future<void> updateFieldsForAllDocuments() async {
  // Get a reference to the Firestore collection
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference collection = firestore.collection('user');

  // Get all the documents in the collection
  QuerySnapshot querySnapshot = await collection.get();
  List<QueryDocumentSnapshot> documents = querySnapshot.docs;

  // Update the fields for each document
  documents.forEach((document) async {
    List fleaChatUidList = [];
    CustomFullScreenDialog.showDialog();
    await document.reference.set({
      'bulletinRoomCount': 0,
      'fleaCount': 0,
      'phoneAuth' : false,
      'phoneNum' : '',
      'likeUidList' : [],
      'resistDate' : Timestamp.fromDate(DateTime(1990)),
      'fleaChatUidList' : fleaChatUidList,
      'newChat' : false,
      'friendUidList' : [],
      'stateMsg':'',
      'isOnLive': false,
      'whoResistMe':[],
      'whoInviteMe':[],
      'whoIinvite':[],
      'whoResistMeBF':[],
      'withinBoundary': false,
      'whoRepoMe':[],
      'liveFriendUidList':[],
      'myFriendCommentUidList':[],
      'commentCheck':false,
      'whoIinvite':[],
      'whoInviteMe':[],
      'myCrew':'',
      'liveCrew':[],
      'applyCrewList':[],
      'totalScores':<String, dynamic>{},
    }, SetOptions(merge: true));
    CustomFullScreenDialog.cancelDialog();
  });
}

Future<void> transferUIDs() async {
  final users = FirebaseFirestore.instance.collection('users');
  final newCollection = FirebaseFirestore.instance.collection('newAlarm');
  CustomFullScreenDialog.showDialog();

  final snapshot = await users.get();
  for (final doc in snapshot.docs) {
    final uid = doc.id;
    await newCollection.doc(uid).set({
      'newInvited_crew': false,
      'newInvited_friend': false,
      'uid': uid});
  }
  CustomFullScreenDialog.cancelDialog();
}
