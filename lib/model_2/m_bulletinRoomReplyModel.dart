import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class BulletinRoomReplyModel {
  BulletinRoomReplyModel(
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

  BulletinRoomReplyModel.fromJson(dynamic json, this.reference) {
    reply = json['reply'];
    displayName = json['displayName'];
    profileImageUrl = json['profileImageUrl'];
    timeStamp = json['timeStamp'];
    uid = json['uid'];
    commentCount = json['commentCount'];
    replyResortNickname = json['replyResortNickname'];
  }

  BulletinRoomReplyModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<BulletinRoomReplyModel> getReplyModel(String uid, String replyLocationUid, commentCount, replyLocationUidCount, replyResortNickname) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('bulletinRoom')
        .doc('$replyLocationUid#$commentCount')
        .collection('reply')
        .doc('$uid$replyLocationUidCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();

    BulletinRoomReplyModel commentModel = await BulletinRoomReplyModel.fromSnapShot(documentSnapshot);
    return commentModel;
  }

  Future<void> uploadReply(
      {displayName, uid, replyLocationUid, profileImageUrl, reply, timeStamp,replyLocationUidCount, commentCount, replyResortNickname}) async{

    await ref
        .collection('bulletinRoom')
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
    DateTime now = DateTime.now();

    Duration difference = now.difference(uploadTime);

    if (difference.inDays > 1) {
      return DateFormat.yMMMd('ko').format(uploadTime); // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }

}