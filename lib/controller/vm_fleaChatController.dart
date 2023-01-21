import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';
import 'package:snowlive3/model/m_fleaChatModel.dart';

class FleaChatModelController extends GetxController {
  RxString? _uid = ''.obs;
  RxString? _displayName = ''.obs;
  RxString? _profileImageUrl = ''.obs;
  RxString? _comment = ''.obs;
  Timestamp? _timeStamp;
  RxString? _agoTime = ''.obs;
  RxString? _resortNickname = ''.obs;
  RxString? _otherUid = ''.obs;
  RxInt? _fleaChatCount = 0.obs;
  RxString? _otherProfileImageUrl = ''.obs;
  RxString? _otherResortNickname = ''.obs;
  RxString? _otherDisplayName = ''.obs;
  RxString _myUid = ''.obs;


  String? get uid => _uid!.value;
  String? get displayName => _displayName!.value;
  String? get profileImageUrl => _profileImageUrl!.value;
  String? get comment => _comment!.value;
  Timestamp? get timeStamp => _timeStamp;
  String? get agoTime => _agoTime!.value;
  String? get resortNickname => _resortNickname!.value;
  String? get otherUid => _otherUid!.value;
  int? get fleaChatCount => _fleaChatCount!.value;
  String? get otherProfileImageUrl => _otherProfileImageUrl!.value;
  String? get otherResortNickname => _otherResortNickname!.value;
  String? get otherDisplayName => _otherDisplayName!.value;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> getCurrentFleaChat({required uid, required fleaChatCount}) async {
    FleaChatModel fleaChatModel = await FleaChatModel().getFleaChatModel(uid,fleaChatCount);
    this._otherDisplayName!.value = fleaChatModel.otherDisplayName!;
    this._uid!.value = fleaChatModel.uid!;
    this._otherUid!.value = fleaChatModel.otherUid!;
    this._otherProfileImageUrl!.value = fleaChatModel.otherProfileImageUrl!;
    this._fleaChatCount!.value = fleaChatModel.fleaChatCount!;
    this._otherResortNickname!.value = fleaChatModel.otherResortNickname!;
    this._timeStamp = fleaChatModel.timeStamp!;
  }


  Future<void> sendMessage(
      {required displayName,
        required uid,
        required profileImageUrl,
        required comment,
        required fleaChatCount,
        required resortNickname,
        required commentCount,
        required myUid,}) async {
    await FleaChatModel().uploadComment(
        comment: comment,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
        timeStamp: Timestamp.now(),
        fleaChatCount: fleaChatCount,
        uid: uid,
        resortNickname: resortNickname,
        commentCount: commentCount,
        myUid: myUid,
    );
    FleaChatModel fleaChatModel =
    await FleaChatModel().getFleaChatModel(uid, fleaChatCount);
    this._uid!.value = fleaChatModel.uid!;
    this._displayName!.value = fleaChatModel.displayName!;
    this._profileImageUrl!.value = fleaChatModel.profileImageUrl!;
    this._comment!.value = fleaChatModel.comment!;
    this._timeStamp = fleaChatModel.timeStamp!;
    this._resortNickname!.value = fleaChatModel.resortNickname!;
    this._myUid!.value = fleaChatModel.myUid!;
  }

  Future<void> createChatroom(
      {required uid,
        required otherUid,
        required timeStamp,
        required fleaChatCount,
        required otherProfileImageUrl,
        required otherResortNickname,
        required otherDisplayName,
        required displayName,
        required profileImageUrl,
        required resortNickname
      }) async {
    await FleaChatModel().createChatroom(
        fleaChatCount: fleaChatCount,
        otherUid: otherUid,
        timeStamp: timeStamp,
        uid: uid,
        otherProfileImageUrl: otherProfileImageUrl,
        otherResortNickname: otherResortNickname,
        otherDisplayName: otherDisplayName,
        displayName: displayName,
        profileImageUrl: profileImageUrl,
        resortNickname: resortNickname,
    );
    FleaChatModel fleaChatModel =
    await FleaChatModel().getFleaChatModel(uid, fleaChatCount);
    this._uid!.value = fleaChatModel.uid!;
    this._timeStamp = fleaChatModel.timeStamp!;
    this._fleaChatCount!.value = fleaChatModel.fleaChatCount!;
    this._otherUid!.value = fleaChatModel.otherUid!;
    this._otherProfileImageUrl!.value = fleaChatModel.otherProfileImageUrl!;
    this._otherResortNickname!.value = fleaChatModel.otherResortNickname!;
    this._otherDisplayName!.value = fleaChatModel.otherDisplayName!;
    this._displayName!.value = fleaChatModel.displayName!;
    this._profileImageUrl!.value = fleaChatModel.profileImageUrl!;
    this._resortNickname!.value = fleaChatModel.resortNickname!;

  }





  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }
}