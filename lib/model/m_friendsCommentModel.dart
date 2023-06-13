import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

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
    agoTime = Jiffy(uploadTime).fromNow();
    Jiffy.locale('ko');
    return agoTime;
  }

}
