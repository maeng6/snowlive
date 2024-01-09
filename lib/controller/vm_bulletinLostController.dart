import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model/m_commentModel.dart';
import '../model/m_bulletinLostModel.dart';

class BulletinLostModelController extends GetxController {
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _displayName = ''.obs;
  RxString? _uid = ''.obs;
  RxString? _profileImageUrl = ''.obs;
  RxList? _itemImagesUrls = [].obs;
  RxString? _title = ''.obs;
  RxString? _category = ''.obs;
  RxString? _description = ''.obs;
  RxInt? _bulletinLostCount = 0.obs;
  RxInt? _bulletinLostReplyCount = 0.obs;
  RxString? _resortNickname = ''.obs;
  RxBool? _soldOut = false.obs;
  Timestamp? _timeStamp;
  RxInt? _likeCount = 0.obs;
  RxDouble? _score = 0.0.obs;
  RxBool? _hot=false.obs;
  RxList? _viewerUid = [].obs;

  String? get displayName => _displayName!.value;

  String? get uid => _uid!.value;

  String? get profileImageUrl => _profileImageUrl!.value;

  List? get itemImagesUrls => _itemImagesUrls!.value;

  String? get title => _title!.value;

  String? get category => _category!.value;

  String? get description => _description!.value;

  int? get bulletinLostCount => _bulletinLostCount!.value;

  int? get bulletinLostReplyCount => _bulletinLostReplyCount!.value;

  String? get resortNickname => _resortNickname!.value;

  bool? get soldOut => _soldOut!.value;

  Timestamp? get timeStamp => _timeStamp;

  int? get likeCount => _likeCount!.value;

  double? get score => _score!.value;

  bool? get hot => _hot!.value;

  List? get viewerUid => _viewerUid!;

  Future<void> getCurrentBulletinLost({required uid, required bulletinLostCount}) async {
    BulletinLostModel bulletinLostModel = await BulletinLostModel().getBulletinLostModel(uid,bulletinLostCount);
    this._displayName!.value = bulletinLostModel.displayName!;
    this._uid!.value = bulletinLostModel.uid!;
    this._profileImageUrl!.value = bulletinLostModel.profileImageUrl!;
    this._itemImagesUrls!.value = bulletinLostModel.itemImagesUrls!;
    this._title!.value = bulletinLostModel.title!;
    this._category!.value = bulletinLostModel.category!;
    this._description!.value = bulletinLostModel.description!;
    this._bulletinLostCount!.value = bulletinLostModel.bulletinLostCount!;
    this._bulletinLostReplyCount!.value = bulletinLostModel.bulletinLostReplyCount!;
    this._resortNickname!.value = bulletinLostModel.resortNickname!;
    this._soldOut!.value = bulletinLostModel.soldOut!;
    this._timeStamp = bulletinLostModel.timeStamp!;
    this._likeCount!.value = bulletinLostModel.likeCount!;
    this._score!.value = bulletinLostModel.score!;
    this._hot!.value = bulletinLostModel.hot!;
    this._viewerUid!.value = bulletinLostModel.viewerUid!;
  }

  Future<void> updateItemImageUrls(imageUrls) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('bulletinLost').doc('$uid#$bulletinLostCount').update({
      'itemImagesUrls': imageUrls,
    });
    await getCurrentBulletinLost(uid: uid, bulletinLostCount: bulletinLostCount);
  }

  Future<void> deleteBulletinLostImage({required uid, required bulletinLostCount, required imageCount}) async{
    print('$uid#$bulletinLostCount');
    for (int i = imageCount-1; i > -1; i--) {
      print('#$i.jpg');
      await FirebaseStorage.instance.ref().child('images/bulletinLost/$uid#$bulletinLostCount/#$i.jpg').delete();
    }
  }

  Future<void> updateViewerUid() async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('bulletinLost').doc('$uid#$bulletinLostCount').update({
      'viewerUid': FieldValue.arrayUnion([userMe])
    });
  }

  Future<void> lock(uid) async {
    try {

      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinLost').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      bool isLock = documentSnapshot.get('lock');

      if(isLock == false) {
        await ref.collection('bulletinLost').doc(uid).update({
          'lock': true,
        });
      }else {
        await ref.collection('bulletinLost').doc(uid).update({
          'lock': false,
        });
      }
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> uploadBulletinLost(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required description,
        required bulletinLostCount,
        required resortNickname,
      }) async {
    await BulletinLostModel().uploadBulletinLost(
      displayName: displayName,
      uid: uid,
      profileImageUrl: profileImageUrl,
      itemImagesUrls: itemImagesUrls,
      title: title,
      category: category,
      description: description,
      bulletinLostCount: bulletinLostCount,
      resortNickname: resortNickname,
    );
  }

  Future<void> updateBulletinLost(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required location,
        required description,
        required bulletinLostCount,
        required resortNickname,
        required likeCount,
        required hot,
        required score,
        required viewerUid,
        required timeStamp

      }) async {
    await BulletinLostModel().updateBulletinLost(
      displayName: displayName,
      uid: uid,
      profileImageUrl: profileImageUrl,
      itemImagesUrls: itemImagesUrls,
      title: title,
      category: category,
      description: description,
      bulletinLostCount: bulletinLostCount,
      resortNickname: resortNickname,
      likeCount:likeCount,
      hot: hot,
      score: score,
      viewerUid: viewerUid,
      timeStamp: timeStamp,
    );
  }

  Future<void> updateBulletinLostReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinLost').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinLostReplyCount = documentSnapshot.get('bulletinLostReplyCount');
      int bulletinLostReplyCountPlus = bulletinLostReplyCount + 1;

      await ref.collection('bulletinLost').doc('$bullUid#$bullCount').update({
        'bulletinLostReplyCount': bulletinLostReplyCountPlus,
      });
    }catch(e){
      await ref.collection('bulletinLost').doc('$bullUid#$bullCount').update({
        'bulletinLostReplyCount': 1,
      });
    }
  }

  Future<void> reduceBulletinLostReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinLost').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinLostReplyCount = documentSnapshot.get('bulletinLostReplyCount');
      int bulletinLostReplyCountPlus = bulletinLostReplyCount - 1;

      await ref.collection('bulletinLost').doc('$bullUid#$bullCount').update({
        'bulletinLostReplyCount': bulletinLostReplyCountPlus,
      });
    }catch(e){}
  }

  Future<void> likeDelete(docName) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinLost').doc(docName);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int likeCount = documentSnapshot.get('likeCount');
      int likeCountMinus = likeCount - 1;

      await ref.collection('bulletinLost').doc(docName).update({
        'likeCount': likeCountMinus,
      });
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> likeUpdate(docName) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinLost').doc(docName);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int likeCount = documentSnapshot.get('likeCount');
      int likeCountPlus = likeCount + 1;

      await ref.collection('bulletinLost').doc(docName).update({
        'likeCount': likeCountPlus,
      });
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> scoreUpdate_like({required bullUid, required docName, required timeStamp, required score}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    print('111');
    if(uid != bullUid) {
      try {
        DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('bulletinLost').doc(docName);

        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

        Timestamp timeStamp_now = Timestamp.now();

        // Timestamp를 DateTime으로 변환
        DateTime dateTime_doc = timeStamp.toDate();
        DateTime dateTime_now = timeStamp_now.toDate();

        // 날짜 차이 계산
        Duration difference = dateTime_now.difference(dateTime_doc);
        int daysDifference = difference.inDays;

        // 차이를 일 단위로 올림 처리
        if (difference - Duration(days: daysDifference) > Duration.zero) {
          daysDifference++;
        }

        double plusScore = 0;

        if (daysDifference >= 5) {
          plusScore = likeScoring[5]!;
        }
        else if (daysDifference == 4) {
          plusScore = likeScoring[4]!;
        }
        else if (daysDifference == 3) {
          plusScore = likeScoring[3]!;
        }
        else if (daysDifference == 2) {
          plusScore = likeScoring[2]!;
        }
        else if (daysDifference == 1) {
          plusScore = likeScoring[1]!;
        }

        double score_updated = score + plusScore;

        await ref.collection('bulletinLost').doc(docName).update({
          'score': score_updated,
        });
      } catch (e) {
        print('탈퇴한 회원');
      }
    }else{}
  }

  Future<void> scoreDelete_like({required bullUid, required docName, required timeStamp, required score}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    print('111');
    if(uid != bullUid) {
      try {
        DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('bulletinLost').doc(docName);

        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

        Timestamp timeStamp_now = Timestamp.now();

        // Timestamp를 DateTime으로 변환
        DateTime dateTime_doc = timeStamp.toDate();
        DateTime dateTime_now = timeStamp_now.toDate();

        // 날짜 차이 계산
        Duration difference = dateTime_now.difference(dateTime_doc);
        int daysDifference = difference.inDays;

        // 차이를 일 단위로 올림 처리
        if (difference - Duration(days: daysDifference) > Duration.zero) {
          daysDifference++;
        }

        double plusScore = 0;

        if (daysDifference >= 5) {
          plusScore = likeScoring[5]!;
        }
        else if (daysDifference == 4) {
          plusScore = likeScoring[4]!;
        }
        else if (daysDifference == 3) {
          plusScore = likeScoring[3]!;
        }
        else if (daysDifference == 2) {
          plusScore = likeScoring[2]!;
        }
        else if (daysDifference == 1) {
          plusScore = likeScoring[1]!;
        }

        double score_updated = score - plusScore;

        await ref.collection('bulletinLost').doc(docName).update({
          'score': score_updated,
        });
      } catch (e) {
        print('탈퇴한 회원');
      }
    }else{}
  }

  Future<void> scoreUpdate_reply({required bullUid, required docName, required timeStamp, required score}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    print('111');
    if(uid != bullUid) {
      try {
        DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('bulletinLost').doc(docName);

        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();
        print('1111');

        Timestamp timeStamp_now = Timestamp.now();

        // Timestamp를 DateTime으로 변환
        DateTime dateTime_doc = timeStamp.toDate();
        DateTime dateTime_now = timeStamp_now.toDate();

        // 날짜 차이 계산
        Duration difference = dateTime_now.difference(dateTime_doc);
        int daysDifference = difference.inDays;

        // 차이를 일 단위로 올림 처리
        if (difference - Duration(days: daysDifference) > Duration.zero) {
          daysDifference++;
        }

        double plusScore = 0;

        if (daysDifference >= 5) {
          plusScore = replyScoring[5]!;
        }
        else if (daysDifference == 4) {
          plusScore = replyScoring[4]!;
        }
        else if (daysDifference == 3) {
          plusScore = replyScoring[3]!;
        }
        else if (daysDifference == 2) {
          plusScore = replyScoring[2]!;
        }
        else if (daysDifference == 1) {
          plusScore = replyScoring[1]!;
        }

        double score_updated = score + plusScore;

        await ref.collection('bulletinLost').doc(docName).update({
          'score': score_updated,
        });
      } catch (e) {
        print('탈퇴한 회원');
      }
    }else {}
  }

  Future<void> scoreDelete_reply({required bullUid, required docName, required timeStamp, required score}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    print('111');
    if(uid != bullUid) {
      try {
        DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('bulletinLost').doc(docName);

        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

        Timestamp timeStamp_now = Timestamp.now();

        // Timestamp를 DateTime으로 변환
        DateTime dateTime_doc = timeStamp.toDate();
        DateTime dateTime_now = timeStamp_now.toDate();

        // 날짜 차이 계산
        Duration difference = dateTime_now.difference(dateTime_doc);
        int daysDifference = difference.inDays;

        // 차이를 일 단위로 올림 처리
        if (difference - Duration(days: daysDifference) > Duration.zero) {
          daysDifference++;
        }

        double plusScore = 0;

        if (daysDifference >= 5) {
          plusScore = replyScoring[5]!;
        }
        else if (daysDifference == 4) {
          plusScore = replyScoring[4]!;
        }
        else if (daysDifference == 3) {
          plusScore = replyScoring[3]!;
        }
        else if (daysDifference == 2) {
          plusScore = replyScoring[2]!;
        }
        else if (daysDifference == 1) {
          plusScore = replyScoring[1]!;
        }

        double score_updated = score - plusScore;

        await ref.collection('bulletinLost').doc(docName).update({
          'score': score_updated,
        });
      } catch (e) {
        print('탈퇴한 회원');
      }
    }else {}
  }

  Future<void> scoreUpdate_read({required bullUid, required docName, required timeStamp, required score,required viewerUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    List viewerUidList = viewerUid;
    print('111');

    if(!viewerUidList.contains(uid)) {
      try {
        DocumentReference<Map<String, dynamic>> documentReference =
        ref.collection('bulletinLost').doc(docName);

        final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
        await documentReference.get();

        Timestamp timeStamp_now = Timestamp.now();

        // Timestamp를 DateTime으로 변환
        DateTime dateTime_doc = timeStamp.toDate();
        DateTime dateTime_now = timeStamp_now.toDate();

        // 날짜 차이 계산
        Duration difference = dateTime_now.difference(dateTime_doc);
        int daysDifference = difference.inDays;

        // 차이를 일 단위로 올림 처리
        if (difference - Duration(days: daysDifference) > Duration.zero) {
          daysDifference++;
        }

        double plusScore = 0;

        if (daysDifference >= 5) {
          plusScore = readScoring[5]!;
        }
        else if (daysDifference == 4) {
          plusScore = readScoring[4]!;
        }
        else if (daysDifference == 3) {
          plusScore = readScoring[3]!;
        }
        else if (daysDifference == 2) {
          plusScore = readScoring[2]!;
        }
        else if (daysDifference == 1) {
          plusScore = readScoring[1]!;
        }

        double score_updated = score + plusScore;

        await ref.collection('bulletinLost').doc(docName).update({
          'score': score_updated,
        });
      } catch (e) {
        print('탈퇴한 회원');
      }
    }else{}
  }

  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }



}

Map<int, double> likeScoring = {
  5: 1,
  4: 2,
  3: 3,
  2: 4,
  1: 5
};

Map<int, double> replyScoring = {
  5: 1,
  4: 1,
  3: 1,
  2: 1,
  1: 1
};

Map<int, double> readScoring = {
  5: 0.001,
  4: 0.001,
  3: 0.001,
  2: 0.001,
  1: 0.002
};

