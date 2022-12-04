import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';

class CommentModelController extends GetxController {
  RxString? _uid = ''.obs;
  RxString? _displayName = ''.obs;
  RxInt? _instantResort = 0.obs;
  RxInt? _commentCount = 0.obs;
  RxString? _profileImageUrl = ''.obs;
  RxString? _comment = ''.obs;
  Timestamp? _timeStamp;
  RxString? _agoTime =''.obs;

  String? get uid => _uid!.value;
  String? get displayName => _displayName!.value;
  int? get instantResort => _instantResort!.value;
  int? get commentCount => _commentCount!.value;
  String? get profileImageUrl => _profileImageUrl!.value;
  String? get comment => _comment!.value;
  Timestamp? get timeStamp => _timeStamp;
  String? get agoTime => _agoTime!.value;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> sendMessage(
      {required displayName,
      required uid,
      required profileImageUrl,
      required instantResort,
      required comment,
      required commentCount
      }) async {
   await CommentModel().uploadComment(
        comment: comment,
        displayName: displayName,
        instantResort: instantResort,
        profileImageUrl: profileImageUrl,
      timeStamp: Timestamp.now(),
        commentCount: commentCount,
        uid: uid,
    );
    CommentModel commentModel = await CommentModel().getCommentModel(uid,instantResort,commentCount);
    this._uid!.value = commentModel.uid!;
    this._displayName!.value = commentModel.displayName!;
    this._instantResort!.value = commentModel.instantResort!;
    this._profileImageUrl!.value = commentModel.profileImageUrl!;
    this._comment!.value = commentModel.comment!;
    this._timeStamp = commentModel.timeStamp!;
    this._commentCount!.value = commentModel.commentCount!;
  }

  String getAgoTime(timestamp){
    String time = CommentModel().getAgo(timestamp);
    return time;
}






}
