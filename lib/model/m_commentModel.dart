import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jiffy/jiffy.dart';

class CommentModel {
  CommentModel(
      {this.displayName,
      this.uid,
      this.profileImageUrl,
      this.instantResort,
      this.comment,
      this.timeStamp,
      this.commentCount});

  String? displayName;
  String? uid;
  String? profileImageUrl;
  int? instantResort;
  int? commentCount;
  String? comment;
  DocumentReference? reference;
  Timestamp? timeStamp;
  late String agoTime;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  CommentModel.fromJson(dynamic json, this.reference) {
    comment = json['comment'];
    commentCount = json['commentCount'];
    displayName = json['displayName'];
    instantResort = json['instantResort'];
    profileImageUrl = json['profileImageUrl'];
    timeStamp = json['timeStamp'];
    uid = json['uid'];

  }

  CommentModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<CommentModel> getCommentModel(String uid,int instantResort,commentCount) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('comment')
        .doc('resort')
        .collection('${instantResort.toString()}')
        .doc('$uid$commentCount');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

    CommentModel commentModel = await CommentModel.fromSnapShot(documentSnapshot);
    return commentModel;
  }

  Future<void> uploadComment(
      {displayName, uid, profileImageUrl, instantResort, comment, timeStamp,commentCount}) async{

    await ref
        .collection('comment')
        .doc('resort')
        .collection('${instantResort.toString()}')
        .doc('$uid$commentCount')
        .set({
      'comment': comment,
      'displayName': displayName,
      'instantResort': instantResort,
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
