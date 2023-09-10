import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';
import 'package:com.snowlive/model/m_friendsCommentModel.dart';

class FriendsCommentModelController extends GetxController {
  RxString? _uid = ''.obs;
  RxString? _displayName = ''.obs;
  RxInt? _commentCount = 0.obs;
  RxString? _profileImageUrl = ''.obs;
  RxString? _comment = ''.obs;
  Timestamp? _timeStamp;
  RxString? _agoTime = ''.obs;
  RxString? _resortNickname = ''.obs;

  String? get uid => _uid!.value;

  String? get displayName => _displayName!.value;

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
      required myUid,
      required friendsUid,
      required profileImageUrl,
      required comment,
      required commentCount,
      required resortNickname,
      }) async {
    await FriendsCommentModel().uploadComment(
      comment: comment,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      timeStamp: Timestamp.now(),
      commentCount: commentCount,
      myUid: myUid,
      friendsUid: friendsUid,
      resortNickname: resortNickname,
    );
  }


  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }
}
