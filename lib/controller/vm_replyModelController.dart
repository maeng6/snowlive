import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';
import 'package:com.snowlive/model/m_replyModel.dart';

class ReplyModelController extends GetxController {
  RxString? _uid = ''.obs;
  RxString? _replyLocationUid = ''.obs;
  RxString? _displayName = ''.obs;
  RxInt? _replyLocationUidCount = 0.obs;
  RxInt? _commentCount = 0.obs;
  RxString? _profileImageUrl = ''.obs;
  RxString? _reply = ''.obs;
  Timestamp? _timeStamp;
  RxString? _agoTime =''.obs;
  RxString? _replyResortNickname = ''.obs;


  String? get uid => _uid!.value;
  String? get replyLocationUid => _replyLocationUid!.value;
  String? get displayName => _displayName!.value;
  int? get commentCount => _commentCount!.value;
  int? get replyLocationUidCount => _replyLocationUidCount!.value;
  String? get profileImageUrl => _profileImageUrl!.value;
  String? get reply => _reply!.value;
  Timestamp? get timeStamp => _timeStamp;
  String? get agoTime => _agoTime!.value;
  String? get replyResortNickname => _replyResortNickname!.value;

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> sendReply(
      {required displayName,
        required uid,
        required replyLocationUid,
        required replyResortNickname,
        required profileImageUrl,
        required reply,
        required commentCount,
        required replyLocationUidCount,
      }) async {
    await ReplyModel().uploadReply(
      reply: reply,
      replyLocationUid: replyLocationUid,
      displayName: displayName,
      replyResortNickname: replyResortNickname,
      profileImageUrl: profileImageUrl,
      timeStamp: Timestamp.now(),
      replyLocationUidCount: replyLocationUidCount,
      commentCount: commentCount,
      uid: uid,
    );
    ReplyModel replyModel = await ReplyModel().getReplyModel(uid,replyLocationUid,replyLocationUidCount, commentCount, replyResortNickname);
    this._uid!.value = replyModel.uid!;
    this._commentCount!.value = replyModel.commentCount!;
    this._displayName!.value = replyModel.displayName!;
    this._replyResortNickname!.value = replyModel.replyResortNickname!;
    this._profileImageUrl!.value = replyModel.profileImageUrl!;
    this._reply!.value = replyModel.reply!;
    this._timeStamp = replyModel.timeStamp!;
  }

  String getAgoTime(timestamp){
    String time = CommentModel().getAgo(timestamp);
    return time;
  }






}
