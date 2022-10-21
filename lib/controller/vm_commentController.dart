import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';

class CommentModelController extends GetxController {
  RxString? _uid = ''.obs;
  RxString? _displayName = ''.obs;
  RxInt? _instantResort = 0.obs;
  RxString? _profileImageUrl = ''.obs;
  RxString? _comment = ''.obs;
  DateTime? _timeStamp;

  String? get uid => _uid!.value;

  String? get displayName => _displayName!.value;

  int? get instantResort => _instantResort!.value;

  String? get profileImageUrl => _profileImageUrl!.value;

  String? get comment => _comment!.value;
  DateTime? get timeStamp => _timeStamp;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> sendMessage(
      {required displayName,
      required uid,
      required profileImageUrl,
      required instantResort,
      required comment}) async {
    CommentModel().uploadComment(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        instantResort: instantResort,
        comment: comment,
      timeStamp: DateTime.now()
    );
    CommentModel commentModel = await CommentModel().getCommentModel(uid);

    this._uid!.value = commentModel.uid!;
    this._displayName!.value = commentModel.displayName!;
    this._instantResort!.value = commentModel.instantResort!;
    this._profileImageUrl!.value = commentModel.profileImageUrl!;
    this._comment!.value = commentModel.comment!;
    this._timeStamp = commentModel.timeStamp!;
  }
}
