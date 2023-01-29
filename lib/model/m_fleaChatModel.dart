import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

class FleaChatModel {
  FleaChatModel(
      {this.displayName,
        this.uid,
        this.profileImageUrl,
        this.comment,
        this.timeStamp,
        this.commentCount,
        this.resortNickname,
        this.fleaChatCount,
        this.otherUid,
        this.otherProfileImageUrl,
        this.otherResortNickname,
        this.otherDisplayName,
        this.myUid,
        this.chatUidSumList,
        this.fixMyUid,
        this.chatRoomName,
      });

  String? displayName;
  String? uid;
  String? profileImageUrl;
  int? commentCount;
  String? comment;
  DocumentReference? reference;
  Timestamp? timeStamp;
  late String agoTime;
  String? resortNickname;
  String? otherUid;
  int? fleaChatCount;
  String? otherProfileImageUrl;
  String? otherResortNickname;
  String? otherDisplayName;
  String? myUid;
  List? chatUidSumList;
  String? fixMyUid;
  String? chatRoomName;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  FleaChatModel.fromJson(dynamic json, this.reference) {
    comment = json['comment'];
    otherUid = json['otherUid'];
    fleaChatCount = json['fleaChatCount'];
    displayName = json['displayName'];
    profileImageUrl = json['profileImageUrl'];
    timeStamp = json['timeStamp'];
    uid = json['uid'];
    resortNickname = json['resortNickname'];
    otherProfileImageUrl = json['otherProfileImageUrl'];
    otherResortNickname = json['otherResortNickname'];
    otherDisplayName = json['otherDisplayName'];
    myUid = json['myUid'];
    chatUidSumList = json['chatUidSumList'];
    fixMyUid = json['fixMyUid'];
    chatRoomName = json['chatRoomName'];

  }

  FleaChatModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<FleaChatModel> getFleaChatModel(String uid,String otherUid) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('fleaChat')
        .doc('$uid#$otherUid');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    FleaChatModel fleaChatModel = FleaChatModel.fromSnapShot(documentSnapshot);
    return fleaChatModel;
  }

  Future<void> uploadComment(
      {displayName, uid, myUid, fixMyUid, commentCount, profileImageUrl, comment, timeStamp,fleaChatCount, resortNickname}) async{

    await ref
        .collection('fleaChat')
        .doc('$myUid#$uid')
        .collection('messege')
        .doc('$fixMyUid$commentCount')
        .set({
      'comment': comment,
      'commentCount' : commentCount,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'timeStamp': timeStamp,
      'myUid': myUid,
      'fleaChatCount' : fleaChatCount,
      'resortNickname' : resortNickname,
      'fixMyUid' : fixMyUid,
    });
  }



  Future<void> uploadCommentBuy(
      {displayName, uid, myUid, commentCount, profileImageUrl, comment, timeStamp,fleaChatCount, resortNickname}) async{

    await ref
        .collection('fleaChat')
        .doc('$myUid#$uid')
        .collection('messege')
        .doc('$myUid$commentCount')
        .set({
      'comment': comment,
      'commentCount' : commentCount,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'timeStamp': timeStamp,
      'myUid': myUid,
      'fleaChatCount' : fleaChatCount,
      'resortNickname' : resortNickname,
    });
  }

  Future<void> uploadCommentSell(
      {displayName, uid, myUid, commentCount, profileImageUrl, comment, timeStamp,fleaChatCount, resortNickname}) async{

    await ref
        .collection('fleaChat')
        .doc('$uid#$myUid')
        .collection('messege')
        .doc('$myUid$commentCount')
        .set({
      'comment': comment,
      'commentCount' : commentCount,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'timeStamp': timeStamp,
      'myUid': myUid,
      'fleaChatCount' : fleaChatCount,
      'resortNickname' : resortNickname,
    });
  }

  Future<void> createChatroom(
      { uid, otherUid, fixMyUid, timeStamp,fleaChatCount, displayName, resortNickname, profileImageUrl,
        otherProfileImageUrl,otherResortNickname,otherDisplayName }) async{

    await ref
        .collection('fleaChat')
        .doc('$uid#$otherUid')
        .set({
      'chatRoomName' : '$uid#$otherUid',
      'timeStamp': Timestamp.now(),
      'uid': uid,
      'otherUid' : otherUid,
      'fleaChatCount' : fleaChatCount,
      'otherProfileImageUrl' : otherProfileImageUrl,
      'otherResortNickname' : otherResortNickname,
      'otherDisplayName' : otherDisplayName,
      'displayName' : displayName,
      'profileImageUrl' : profileImageUrl,
      'resortNickname' : resortNickname,
      'fixMyUid' : fixMyUid
    });
  }


  String getAgo(Timestamp timestamp) {
    DateTime uploadTime = timestamp.toDate();
    agoTime = Jiffy(uploadTime).fromNow();
    Jiffy.locale('ko');
    return agoTime;
  }

}
