import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

class BulletinCrewReplyModel {
  BulletinCrewReplyModel(
      {this.displayName,
        this.uid,
        this.replyLocationUid,
        this.profileImageUrl,
        this.reply,
        this.commentCount,
        this.timeStamp,
        this.replyLocationUidCount,
        this.replyResortNickname
      });

  String? displayName;
  String? uid;
  String? replyLocationUid;
  String? profileImageUrl;
  int? replyLocationUidCount;
  int? commentCount;
  String? reply;
  DocumentReference? reference;
  Timestamp? timeStamp;
  late String agoTime;
  String? replyResortNickname;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  BulletinCrewReplyModel.fromJson(dynamic json, this.reference) {
    reply = json['reply'];
    replyLocationUidCount = json['replyLocationUidCount'];
    displayName = json['displayName'];
    profileImageUrl = json['profileImageUrl'];
    timeStamp = json['timeStamp'];
    uid = json['uid'];
    commentCount = json['commentCount'];
    replyLocationUid = json['replyLocationUid'];
    replyResortNickname = json['replyResortNickname'];
  }

  BulletinCrewReplyModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<BulletinCrewReplyModel> getReplyModel(String uid, String replyLocationUid, commentCount, replyLocationUidCount, replyResortNickname) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('bulletinCrew')
        .doc('$replyLocationUid#$replyLocationUidCount')
        .collection('reply')
        .doc('$uid$commentCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();

    BulletinCrewReplyModel commentModel = await BulletinCrewReplyModel.fromSnapShot(documentSnapshot);
    return commentModel;
  }

  Future<void> uploadReply(
      {displayName, uid, replyLocationUid, profileImageUrl, reply, timeStamp,replyLocationUidCount, commentCount, replyResortNickname}) async{

    await ref
        .collection('bulletinCrew')
        .doc('$replyLocationUid#$replyLocationUidCount')
        .collection('reply')
        .doc('$uid$commentCount')
        .set({
      'reply': reply,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'timeStamp': timeStamp,
      'uid': uid,
      'commentCount' : commentCount,
      'replyResortNickname' : replyResortNickname,
    });
  }

  String getAgo(Timestamp timestamp) {
    DateTime uploadTime = timestamp.toDate();
    agoTime = Jiffy(uploadTime).fromNow();
    Jiffy.locale('ko');
    return agoTime;
  }

}