import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  CommentModel(
      {this.displayName,
      this.uid,
      this.profileImageUrl,
      this.instantResort,
      this.comment,
      this.timeStamp});

  String? displayName;
  String? uid;
  String? profileImageUrl;
  int? instantResort;
  String? comment;
  DocumentReference? reference;
  DateTime? timeStamp;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseFirestore.instance;

  //TODO : 날짜다르면 댓글 리셋

  CommentModel.fromJson(dynamic json, this.reference) {
    uid = json['uid'];
    displayName = json['displayName'];
    instantResort = json['instantResort'];
    profileImageUrl = json['profileImageUrl'];
    comment = json['comment'];
    timeStamp = json['timeStamp'];
  }

  CommentModel.fromSnapShot(DocumentSnapshot<Map<String, dynamic>> snapshot)
      : this.fromJson(snapshot.data(), snapshot.reference);

  Future<CommentModel> getCommentModel(String uid) async {
    DocumentReference<Map<String, dynamic>> documentReference = ref
        .collection('comment')
        .doc('${instantResort.toString()}')
        .collection(uid)
        .doc('comment');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
    CommentModel commentModel = CommentModel.fromSnapShot(documentSnapshot);
    return commentModel;
  }

  void uploadComment(
      {displayName, uid, profileImageUrl, instantResort, comment, timeStamp}) {
    ref
        .collection('comment')
        .doc('resort')
        .collection('${instantResort.toString()}')
        .doc(uid)
        .set({
      'displayName': displayName,
      'uid': uid,
      'profileImageUrl': profileImageUrl,
      'instantResort': instantResort,
      'comment': comment,
      'timeStamp': timeStamp
    });
  }
}
