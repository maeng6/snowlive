import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

class ReplyModel {
  ReplyModel(
      {this.displayName,
        this.uid,
        this.replyLocationUid,
        this.profileImageUrl,
        this.reply,
        this.commentCount,
        this.timeStamp,
        this.replyLocationUidCount,
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

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  ReplyModel.fromJson(dynamic json, this.reference) {
    reply = json['reply'];
    replyLocationUidCount = json['replyLocationUidCount'];
    displayName = json['displayName'];
    profileImageUrl = json['profileImageUrl'];
    timeStamp = json['timeStamp'];
    uid = json['uid'];
    commentCount = json['commentCount'];
    replyLocationUid = json['replyLocationUid'];

  }

  ReplyModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<ReplyModel> getReplyModel(String uid, String replyLocationUid, commentCount, replyLocationUidCount) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('liveTalk')
        .doc('$replyLocationUid$replyLocationUidCount')
        .collection('reply')
        .doc('$uid$commentCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();

    ReplyModel commentModel = await ReplyModel.fromSnapShot(documentSnapshot);
    return commentModel;
  }

  Future<void> uploadReply(
      {displayName, uid, replyLocationUid, profileImageUrl, reply, timeStamp,replyLocationUidCount, commentCount}) async{

    await ref
        .collection('liveTalk')
        .doc('$replyLocationUid$replyLocationUidCount')
        .collection('reply')
        .doc('$uid$commentCount')
        .set({
      'reply': reply,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'timeStamp': timeStamp,
      'uid': uid,
      'commentCount' : commentCount
    });
  }

  String getAgo(Timestamp timestamp) {
    DateTime uploadTime = timestamp.toDate();
    agoTime = Jiffy(uploadTime).fromNow();
    Jiffy.locale('ko');
    return agoTime;
  }

}