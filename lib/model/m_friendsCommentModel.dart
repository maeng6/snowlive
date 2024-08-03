import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';
import 'package:intl/intl.dart';

class FriendsCommentModel {
  FriendsCommentModel(
      {this.displayName,
        this.myUid,
      this.friendsUid,
      this.profileImageUrl,
      this.comment,
      this.timeStamp,
      this.commentCount,
      this.resortNickname,});

  String? displayName;
  String? friendsUid;
  String? myUid;
  String? profileImageUrl;
  int? commentCount;
  String? comment;
  DocumentReference? reference;
  Timestamp? timeStamp;
  late String agoTime;
  String? resortNickname;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋


  Future<void> uploadComment(
      {displayName,
        myUid,
        friendsUid,
        profileImageUrl,
        comment,
        timeStamp,
        commentCount,
        resortNickname}) async{

    await ref
        .collection('user')
        .doc('$friendsUid')
        .collection('friendsComment')
        .doc('$myUid')
        .set({
      'comment': comment,
      'displayName': displayName,
      'profileImageUrl': profileImageUrl,
      'timeStamp': timeStamp,
      'friendsUid': friendsUid,
      'myUid': myUid,
      'commentCount' : commentCount,
    'resortNickname' : resortNickname,
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
