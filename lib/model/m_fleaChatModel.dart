import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

class FleaChatModel {
  FleaChatModel(
      {this.myDisplayName,
        this.myProfileImageUrl,
        this.comment,
        this.timeStamp,
        this.commentCount,
        this.myResortNickname,
        this.fleaChatCount,
        this.otherUid,
        this.otherProfileImageUrl,
        this.otherResortNickname,
        this.otherDisplayName,
        this.myUid,
        this.chatUidSumList,
        this.fixMyUid,
        this.chatRoomName,
        this.myChatCount,
        this.otherChatCount,
        this.myChatCheckCount,
        this.otherChatCheckCount,
      });

  String? myDisplayName;
  String? myProfileImageUrl;
  int? commentCount;
  String? comment;
  DocumentReference? reference;
  Timestamp? timeStamp;
  late String agoTime;
  String? myResortNickname;
  String? otherUid;
  int? fleaChatCount;
  String? otherProfileImageUrl;
  String? otherResortNickname;
  String? otherDisplayName;
  String? myUid;
  List? chatUidSumList;
  String? fixMyUid;
  String? chatRoomName;
  int? myChatCount;
  int? otherChatCount;
  int? myChatCheckCount;
  int? otherChatCheckCount;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  FleaChatModel.fromJson(dynamic json, this.reference) {
    this.chatRoomName = json['chatRoomName'];
   this.timeStamp = json['timeStamp'];
   this.otherUid = json['otherUid'];
   this.otherProfileImageUrl = json['otherProfileImageUrl'];
   this.otherResortNickname = json['otherResortNickname'];
   this.otherDisplayName = json['otherDisplayName'];
   this.myDisplayName = json['myDisplayName'];
   this.myProfileImageUrl = json['myProfileImageUrl'];
   this.myResortNickname = json['resortNickname'];
   this.myUid = json['myUid'];
   this.myChatCount = json['myChatCount'];
   this.otherChatCount = json['otherChatCount'];
   this.myChatCheckCount = json['myChatCheckCount'];
   this.otherChatCheckCount = json['otherChatCheckCount'];
   this.comment = json['comment'];
  }

  FleaChatModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<FleaChatModel> getCuyrrentFleaChatInfo(chatRoomName) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('fleaChat')
        .doc(chatRoomName);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    FleaChatModel fleaChatModel = FleaChatModel.fromSnapShot(documentSnapshot);
    return fleaChatModel;
  }


  Future<void> createChatroom(
      {required myUid,required otherUid,required myDisplayName,required myResortNickname,required myProfileImageUrl,
        required otherProfileImageUrl,required otherResortNickname,required otherDisplayName }) async{

    List chatUidSumList =  [];

    await ref
        .collection('fleaChat')
        .doc('$myUid#$otherUid')
        .set({
      'chatRoomName' : '$myUid#$otherUid',
      'timeStamp': Timestamp.now(),
      'myUid': myUid,
      'otherUid' : otherUid,
      'otherProfileImageUrl' : otherProfileImageUrl,
      'otherResortNickname' : otherResortNickname,
      'otherDisplayName' : otherDisplayName,
      'myDisplayName' : myDisplayName,
      'myProfileImageUrl' : myProfileImageUrl,
      'resortNickname' : myResortNickname,
      'chatUidSumList' : chatUidSumList,
      'myChatCount': 0,
      'otherChatCount': 0,
      'myChatCheckCount' : 0,
      'otherChatCheckCount' : 0,
      'comment' : '',
    });
    await getCuyrrentFleaChatInfo('$myUid#$otherUid');

  }

  Future<void> uploadChat(
      {required myDisplayName,
      required myUid,
      required otherUid,
      required myProfileImageUrl,
      required comment,
      required myResortNickname,
      required chatCount,
      required chatRoomName,
        required timeStamp,
       required myChatCount,
       required otherChatCount,
       required myChatCheckCount,
       required otherChatCheckCount,
      }) async{
    await ref
        .collection('fleaChat')
        .doc(chatRoomName)
        .collection(myUid)
        .doc('$myUid$chatCount')
        .set({
      'myDisplayName' : myDisplayName,
      'senderUid' : myUid,
      'receiverUid' : otherUid,
      'myProfileImageUrl' : myProfileImageUrl,
      'comment' : comment,
      'myResortNickname' : myResortNickname,
      'chatCount' : chatCount,
      'chatRoomName' : chatRoomName,
      'timeStamp' : timeStamp,
      'myChatCount' : myChatCount+1,
      'otherChatCount' : otherChatCount+1,
      'myChatCheckCount' : myChatCheckCount+1,
      'otherChatCheckCount' : otherChatCheckCount+1
    });
    await ref
        .collection('fleaChat')
        .doc(chatRoomName)
        .collection(otherUid)
        .doc('$myUid$chatCount')
        .set({
      'myDisplayName' : myDisplayName,
      'senderUid' : myUid,
      'receiverUid' : otherUid,
      'myProfileImageUrl' : myProfileImageUrl,
      'comment' : comment,
      'myResortNickname' : myResortNickname,
      'chatCount' : chatCount,
      'chatRoomName' : chatRoomName,
      'timeStamp' : timeStamp
    });
    await ref
        .collection('fleaChat')
        .doc(chatRoomName)
        .update({
      'comment' : comment,
    });
  }



  String getAgo(Timestamp timestamp) {
    DateTime uploadTime = timestamp.toDate();
    agoTime = Jiffy(uploadTime).fromNow();
    Jiffy.locale('ko');
    return agoTime;
  }

  // Future<void> uploadCommentBuy(
  //     {displayName, uid, myUid, commentCount, profileImageUrl, comment, timeStamp,fleaChatCount, resortNickname}) async{
  //
  //   await ref
  //       .collection('fleaChat')
  //       .doc('$myUid#$uid')
  //       .collection('messege')
  //       .doc('$myUid$commentCount')
  //       .set({
  //     'comment': comment,
  //     'commentCount' : commentCount,
  //     'displayName': displayName,
  //     'profileImageUrl': profileImageUrl,
  //     'timeStamp': timeStamp,
  //     'myUid': myUid,
  //     'fleaChatCount' : fleaChatCount,
  //     'resortNickname' : resortNickname,
  //   });
  // }
  //
  // Future<void> uploadCommentSell(
  //     {displayName, uid, myUid, commentCount, profileImageUrl, comment, timeStamp,fleaChatCount, resortNickname}) async{
  //
  //   await ref
  //       .collection('fleaChat')
  //       .doc('$uid#$myUid')
  //       .collection('$uid')
  //       .doc('$myUid$commentCount')
  //       .set({
  //     'comment': comment,
  //     'commentCount' : commentCount,
  //     'displayName': displayName,
  //     'profileImageUrl': profileImageUrl,
  //     'timeStamp': timeStamp,
  //     'myUid': myUid,
  //     'fleaChatCount' : fleaChatCount,
  //     'resortNickname' : resortNickname,
  //   });
  // }

}
