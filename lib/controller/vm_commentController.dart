import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';

class CommentModelController extends GetxController {
  RxString? _uid = ''.obs;
  RxString? _displayName = ''.obs;
  RxInt? _commentCount = 0.obs;
  RxString? _profileImageUrl = ''.obs;
  RxString? _comment = ''.obs;
  Timestamp? _timeStamp;
  RxString? _agoTime = ''.obs;
  RxString? _resortNickname = ''.obs;
  RxInt? _likeCount = 0.obs;
  RxInt? _replyCount = 0.obs;
  RxString? _livetalkImageUrl = ''.obs;

  String? get uid => _uid!.value;

  String? get displayName => _displayName!.value;

  int? get commentCount => _commentCount!.value;

  String? get profileImageUrl => _profileImageUrl!.value;

  String? get comment => _comment!.value;

  Timestamp? get timeStamp => _timeStamp;

  String? get agoTime => _agoTime!.value;

  String? get resortNickname => _resortNickname!.value;

  int? get likeCount => _likeCount!.value;

  int? get replyCount => _replyCount!.value;

  String? get livetalkImageUrl => _livetalkImageUrl!.value;


  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  Future<void> sendMessage(
      {required displayName,
      required uid,
      required profileImageUrl,
      required comment,
      required commentCount,
      required resortNickname,
      required likeCount,
      required replyCount,
        required livetalkImageUrl,
      }) async {
    await CommentModel().uploadComment(
      comment: comment,
      displayName: displayName,
      profileImageUrl: profileImageUrl,
      timeStamp: Timestamp.now(),
      commentCount: commentCount,
      uid: uid,
      resortNickname: resortNickname,
      likeCount: likeCount,
      replyCount: replyCount,
      livetalkImageUrl: livetalkImageUrl,
    );

    if(displayName =='SNOWLIVE'){
      await ref
          .collection('newAlarm_liveTalk_Notice')
          .doc('$uid$commentCount')
          .set({
        'comment': [],
        'displayName': displayName,
        'profileImageUrl': profileImageUrl,
        'timeStamp': timeStamp,
        'uid': uid,
        'commentCount' : commentCount,
        'resortNickname' : resortNickname,
        'likeCount' : likeCount,
        'replyCount' : replyCount,
        'livetalkImageUrl' : livetalkImageUrl,
        'lock' : false,
      });
    }else{}

    print("sendMessage 함수에서의 livetalkImageUrl 값: $livetalkImageUrl"); // 로그 추가
    CommentModel commentModel =
        await CommentModel().getCommentModel(uid, commentCount);
    this._uid!.value = commentModel.uid!;
    this._displayName!.value = commentModel.displayName!;
    this._profileImageUrl!.value = commentModel.profileImageUrl!;
    this._comment!.value = commentModel.comment!;
    this._timeStamp = commentModel.timeStamp!;
    this._commentCount!.value = commentModel.commentCount!;
    this._resortNickname!.value = commentModel.resortNickname!;
    this._likeCount!.value = commentModel.likeCount!;
    this._replyCount!.value = commentModel.replyCount!;
    this._livetalkImageUrl!.value = commentModel.livetalkImageUrl!;
  }



  Future<void> likeUpdate(uid) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          ref.collection('liveTalk').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await documentReference.get();

      int likeCount = documentSnapshot.get('likeCount');
      int likeCountPlus = likeCount + 1;

      await ref.collection('liveTalk').doc(uid).update({
        'likeCount': likeCountPlus,
      });
    } catch (e) {
      print('탈퇴한 회원');
    }
  }


  Future<void> lock(uid) async {
    try {

      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('liveTalk').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      bool isLock = documentSnapshot.get('lock');

      if(isLock == false) {
        await ref.collection('liveTalk').doc(uid).update({
          'lock': true,
        });
      }else {
        await ref.collection('liveTalk').doc(uid).update({
          'lock': false,
        });
      }
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> likeDelete(uid) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          ref.collection('liveTalk').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await documentReference.get();

      int likeCount = documentSnapshot.get('likeCount');
      int likeCountMinus = likeCount - 1;

      await ref.collection('liveTalk').doc(uid).update({
        'likeCount': likeCountMinus,
      });
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> replyCountUpdate(uid) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          ref.collection('liveTalk').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await documentReference.get();

      int replyCount = documentSnapshot.get('replyCount');
      int replyCountPlus = replyCount + 1;

      await ref.collection('liveTalk').doc(uid).update({
        'replyCount': replyCountPlus,
      });
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> replyCountDelete(uid) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
          ref.collection('liveTalk').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await documentReference.get();

      int replyCount = documentSnapshot.get('replyCount');
      int replyCountMinus = replyCount - 1;

      await ref.collection('liveTalk').doc(uid).update({
        'replyCount': replyCountMinus,
      });
    } catch (e) {
      print('탈퇴한 회원');
    }
  }


  Future<void> updateLivetalkImageUrl(imageUrls) async {
    try {
      final User? user = auth.currentUser;
      final uid = user!.uid;
      DocumentReference<Map<String, dynamic>> documentReference = ref.collection('liveTalk').doc(uid);
      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot = await documentReference.get();

      if (documentSnapshot.exists) {
        await documentReference.update({
          'livetalkImageUrl': imageUrls,
        });
      } else {
        await documentReference.set({
          'livetalkImageUrl': imageUrls,
          // 필요한 다른 필드를 여기에 추가하세요.
        });
      }
    } catch (e) {
      print('라이브톡 이미지 업데이트 오류: $e');
    }
  }


  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }
}
