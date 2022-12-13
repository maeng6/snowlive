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
  RxString? _agoTime = ''.obs;
  RxString? _resortNickname = ''.obs;

  String? get uid => _uid!.value;

  String? get displayName => _displayName!.value;

  int? get instantResort => _instantResort!.value;

  int? get commentCount => _commentCount!.value;

  String? get profileImageUrl => _profileImageUrl!.value;

  String? get comment => _comment!.value;

  Timestamp? get timeStamp => _timeStamp;

  String? get agoTime => _agoTime!.value;

  String? get resortNickname => _resortNickname!.value;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> sendMessage(
      {required displayName,
      required uid,
      required profileImageUrl,
      required comment,
      required commentCount,
      required resortNickname}) async {
    await CommentModel().uploadComment(
      comment: comment,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      timeStamp: Timestamp.now(),
      commentCount: commentCount,
      uid: uid,
      resortNickname: resortNickname,
    );
    CommentModel commentModel =
        await CommentModel().getCommentModel(uid, commentCount);
    this._uid!.value = commentModel.uid!;
    this._displayName!.value = commentModel.displayName!;
    this._profileImageUrl!.value = commentModel.profileImageUrl!;
    this._comment!.value = commentModel.comment!;
    this._timeStamp = commentModel.timeStamp!;
    this._commentCount!.value = commentModel.commentCount!;
    this._resortNickname!.value = commentModel.resortNickname!;
  }

  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }
}
