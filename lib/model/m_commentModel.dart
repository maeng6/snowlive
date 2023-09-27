import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

class CommentModel {
  CommentModel(
      {this.displayName,
      this.uid,
      this.profileImageUrl,
      this.comment,
      this.timeStamp,
      this.commentCount,
      this.resortNickname,
      this.likeCount,
      this.replyCount,
      this.livetalkImageUrl});

  String? displayName;
  String? uid;
  String? profileImageUrl;
  int? commentCount;
  String? comment;
  DocumentReference? reference;
  Timestamp? timeStamp;
  late String agoTime;
  String? resortNickname;
  int? likeCount;
  int? replyCount;
  String? livetalkImageUrl;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  CommentModel.fromJson(dynamic json, this.reference) {
    comment = json['comment'];
    commentCount = json['commentCount'];
    displayName = json['displayName'];
    profileImageUrl = json['profileImageUrl'];
    timeStamp = json['timeStamp'];
    uid = json['uid'];
    resortNickname = json['resortNickname'];
    likeCount = json['likeCount'];
    replyCount = json['replyCount'];
    livetalkImageUrl = json['livetalkImageUrl'];
  }

  CommentModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<CommentModel> getCommentModel(String uid,commentCount) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('liveTalk')
        .doc('$uid$commentCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

    CommentModel commentModel = await CommentModel.fromSnapShot(documentSnapshot);
    return commentModel;
  }

  Future<void> uploadComment(
      {displayName, uid, profileImageUrl, comment, timeStamp,commentCount, resortNickname, likeCount, replyCount,livetalkImageUrl}) async{

    await ref
        .collection('liveTalk')
        .doc('$uid$commentCount')
        .set({
      'comment': comment,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'timeStamp': timeStamp,
      'uid': uid,
      'commentCount' : commentCount,
    'resortNickname' : resortNickname,
      'likeCount' : likeCount,
      'replyCount' : replyCount,
      'livetalkImageUrl' : livetalkImageUrl,
      'lock' : false,
    });
  }

  String getAgo(Timestamp timestamp) {
    DateTime uploadTime = timestamp.toDate();
    agoTime = Jiffy(uploadTime).fromNow();
    Jiffy.locale('ko');
    return agoTime;
  }

}
