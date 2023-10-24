import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {

  UserModel({
    this.uid,
    this.displayName,
    this.userEmail,
    this.favoriteResort,
    this.instantResort,
    this.profileImageUrl,
    this.exist,
    this.commentCount,
    this.fleaCount,
    this.bulletinRoomCount,
    this.resortNickname,
    this.phoneAuth,
    this.phoneNum,
    this.likeUidList,
    this.myFriendCommentUidList,
    this.friendUidList,
    this.liveFriendUidList,
    this.resistDate,
    this.newChat,
    this.stateMsg,
    this.isOnLive,
    this.commentCheck,
    this.whoResistMe,
    this.whoInviteMe,
    this.whoIinvite,
    this.whoResistMeBF,
    this.whoRepoMe,
    this.withinBoundary,
    this.liveCrew,
    this.applyCrewList,
    this.totalScores,
    this.deviceToken,
    this.liveTalkHideList
  });

  final auth = FirebaseAuth.instance;
  final ref = FirebaseFirestore.instance;
  String? uid;
  String? displayName;
  String? userEmail;
  int? favoriteResort;
  int? instantResort;
  int? commentCount;
  int? fleaCount;
  int? bulletinRoomCount;
  String? profileImageUrl;
  bool? exist;
  DocumentReference? reference;
  String? resortNickname;
  bool? phoneAuth;
  bool? newChat;
  String? phoneNum;
  List? likeUidList;
  List? myFriendCommentUidList;
  List? friendUidList;
  List? liveFriendUidList;
  List? fleaChatUidList;
  Timestamp? resistDate;
  String? stateMsg;
  bool? isOnLive;
  bool? commentCheck;
  List? whoResistMe;
  List? whoInviteMe;
  List? whoIinvite;
  List? whoResistMeBF;
  List? whoRepoMe;
  bool? withinBoundary;
  String? liveCrew;
  List? applyCrewList;
  Map? totalScores;
  String? deviceToken;
  List? liveTalkHideList;

  UserModel.fromJson(dynamic json, this.reference) {
      uid = json['uid'];
      displayName = json['displayName'];
      userEmail = json['userEmail'];
      favoriteResort = json['favoriteResort'];
      instantResort = json['instantResort'];
      profileImageUrl = json['profileImageUrl'];
      commentCount = json['commentCount'];
      fleaCount = json['fleaCount'];
      bulletinRoomCount = json['bulletinRoomCount'];
      exist = json['exist'];
      resortNickname = json['resortNickname'];
      phoneAuth = json['phoneAuth'];
      phoneNum = json['phoneNum'];
      likeUidList = json['likeUidList'];
      myFriendCommentUidList = json['myFriendCommentUidList'];
      friendUidList = json['friendUidList'];
      liveFriendUidList = json['liveFriendUidList'];
      resistDate = json['resistDate'];
      fleaChatUidList = json['fleaChatUidList'];
      newChat = json['newChat'];
      stateMsg = json['stateMsg'];
      isOnLive = json['isOnLive'];
      commentCheck = json['commentCheck'];
      whoResistMe = json['whoResistMe'];
      whoInviteMe = json['whoInviteMe'];
      whoIinvite = json['whoIinvite'];
      whoResistMeBF = json['whoResistMeBF'];
      withinBoundary = json['withinBoundary'];
      whoRepoMe = json['whoRepoMe'];
      liveCrew = json['liveCrew'];
      applyCrewList = json['applyCrewList'];
      totalScores = json['totalScores'];
      deviceToken = json['deviceToken'];
      liveTalkHideList = json['liveTalkHideList'];


  }

  UserModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson(snapshot.data(), snapshot.reference);

  Future<UserModel?> getUserModel(String uid) async {
    if (uid != null) {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      if (documentSnapshot.exists) {
        UserModel userModel = UserModel.fromSnapShot(documentSnapshot);
        return userModel;
      }
    }
    return null;
  }

  UserModel.fromJson_crew(dynamic json, this.reference) {
    liveCrew = json['liveCrew'];
    applyCrewList = json['applyCrewList'];
  }

  UserModel.fromSnapShot_crew(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson_crew(snapshot.data(), snapshot.reference);

  Future<UserModel?> getUserModel_crew(String uid) async {
    if (uid != null) {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      if (documentSnapshot.exists) {
        UserModel userModel = UserModel.fromSnapShot_crew(documentSnapshot);
        return userModel;
      }
    }
    return null;
  }

  UserModel.fromJson_locationInfo(dynamic json, this.reference) {
    uid = json['uid'];
    isOnLive = json['isOnLive'];
    withinBoundary = json['withinBoundary'];
    favoriteResort = json['favoriteResort'];
    instantResort = json['instantResort'];

  }

  UserModel.fromSnapShot_locationInfo(DocumentSnapshot<Map<String, dynamic>> snapshot)
      :this.fromJson_locationInfo(snapshot.data(), snapshot.reference);

  Future<UserModel?> getUserModel_locationInfo(String uid) async {
    if (uid != null) {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();
      if (documentSnapshot.exists) {
        UserModel userModel = UserModel.fromSnapShot_locationInfo(documentSnapshot);
        return userModel;
      }
    }
    return null;
  }


}

