import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

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
        this.livetalkImageUrl,
        this.kusbf,
        this.liveCrew,
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
  int? likeCount;
  int? replyCount;
  String? livetalkImageUrl;
  bool? kusbf;
  String? liveCrew;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  CommentModel.fromJson(dynamic json, this.reference) {
    comment = json['comment'];
    commentCount = json['commentCount'];
    displayName = json['displayName'];
    profileImageUrl = json['profileImageUrl'];
    timeStamp = json['timeStamp'];
    agoTime = getAgo(timeStamp!);
    uid = json['uid'];
    resortNickname = json['resortNickname'];
    likeCount = json['likeCount'];
    replyCount = json['replyCount'];
    livetalkImageUrl = json['livetalkImageUrl'];
    kusbf = json['kusbf'];
    liveCrew = json['liveCrew'];
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
      {displayName, uid, profileImageUrl, comment, timeStamp,commentCount, resortNickname, likeCount, replyCount,livetalkImageUrl, kusbf, liveCrew}) async{

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
      'kusbf' : kusbf,
      'liveCrew' : liveCrew
    });
  }

  String getAgo(Timestamp timestamp) {
    DateTime uploadTime = timestamp.toDate();
    DateTime now = DateTime.now();

    Duration difference = now.difference(uploadTime);

    if (difference.inDays >= 30) {
      int months = difference.inDays ~/ 30;
      return '$months개월 전';
    } else if (difference.inDays > 1) {
      return '${difference.inDays}일 전'; // 1일 이상이면 날짜 형식으로 반환
    } else if (difference.inHours > 1) {
      return '${difference.inHours}시간 전'; // 1시간 이상이면 시간 형식으로 반환
    } else if (difference.inMinutes > 1) {
      return '${difference.inMinutes}분 전'; // 1분 이상이면 분 형식으로 반환
    } else {
      return '방금 전'; // 그 외의 경우 방금 전으로 반환
    }
  }

}
