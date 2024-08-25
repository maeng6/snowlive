import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/model_2/m_commentModel.dart';
import '../../model_2/m_bulletinFreeModel.dart';

class BulletinFreeModelController extends GetxController {
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _displayName = ''.obs;
  RxString? _uid = ''.obs;
  RxString? _profileImageUrl = ''.obs;
  RxList? _itemImagesUrls = [].obs;
  RxString? _title = ''.obs;
  RxString? _category = ''.obs;
  RxString? _description = ''.obs;
  RxInt? _bulletinFreeCount = 0.obs;
  RxInt? _bulletinFreeReplyCount = 0.obs;
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

  int? get bulletinFreeCount => _bulletinFreeCount!.value;

  int? get bulletinFreeReplyCount => _bulletinFreeReplyCount!.value;

  String? get resortNickname => _resortNickname!.value;

  bool? get soldOut => _soldOut!.value;

  Timestamp? get timeStamp => _timeStamp;

  int? get likeCount => _likeCount!.value;

  double? get score => _score!.value;

  bool? get hot => _hot!.value;

  List? get viewerUid => _viewerUid!;

  Future<void> getCurrentBulletinFree({required uid, required bulletinFreeCount}) async {
    BulletinFreeModel bulletinFreeModel = await BulletinFreeModel().getBulletinFreeModel(uid,bulletinFreeCount);
    this._displayName!.value = bulletinFreeModel.displayName!;
    this._uid!.value = bulletinFreeModel.uid!;
    this._profileImageUrl!.value = bulletinFreeModel.profileImageUrl!;
    this._itemImagesUrls!.value = bulletinFreeModel.itemImagesUrls!;
    this._title!.value = bulletinFreeModel.title!;
    this._category!.value = bulletinFreeModel.category!;
    this._description!.value = bulletinFreeModel.description!;
    this._bulletinFreeCount!.value = bulletinFreeModel.bulletinFreeCount!;
    this._bulletinFreeReplyCount!.value = bulletinFreeModel.bulletinFreeReplyCount!;
    this._resortNickname!.value = bulletinFreeModel.resortNickname!;
    this._soldOut!.value = bulletinFreeModel.soldOut!;
    this._timeStamp = bulletinFreeModel.timeStamp!;
    this._likeCount!.value = bulletinFreeModel.likeCount!;
    this._score!.value = bulletinFreeModel.score!;
    this._hot!.value = bulletinFreeModel.hot!;
    this._viewerUid!.value = bulletinFreeModel.viewerUid!;
  }

  Future<void> updateItemImageUrls(imageUrls) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('bulletinFree').doc('$uid#$bulletinFreeCount').update({
      'itemImagesUrls': imageUrls,
    });
    await getCurrentBulletinFree(uid: uid, bulletinFreeCount: bulletinFreeCount);
  }

  Future<void> deleteBulletinFreeImage({required uid, required bulletinFreeCount, required imageCount}) async{
    print('$uid#$bulletinFreeCount');
    for (int i = imageCount-1; i > -1; i--) {
      print('#$i.jpg');
    await FirebaseStorage.instance.ref().child('images/bulletinFree/$uid#$bulletinFreeCount/#$i.jpg').delete();
    }
  }

  // Future<void> updateState(isSoldOut) async {
  //   final User? user = auth.currentUser;
  //   final uid = user!.uid;
  //   if(isSoldOut == false) {
  //     await ref.collection('bulletinFree').doc('$uid#$bulletinFreeCount').update({
  //       'soldOut': true,
  //     });
  //   }else{
  //     await ref.collection('bulletinFree').doc('$uid#$bulletinFreeCount').update({
  //       'soldOut': false,
  //     });
  //   }
  //   await getCurrentBulletinFree(uid: uid, bulletinFreeCount: bulletinFreeCount);
  // }

  Future<void> updateViewerUid() async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('bulletinFree').doc('$uid#$bulletinFreeCount').update({
      'viewerUid': FieldValue.arrayUnion([userMe])
    });
  }

  Future<void> lock(uid) async {
    try {

      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinFree').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      bool isLock = documentSnapshot.get('lock');

      if(isLock == false) {
        await ref.collection('bulletinFree').doc(uid).update({
          'lock': true,
        });
      }else {
        await ref.collection('bulletinFree').doc(uid).update({
          'lock': false,
        });
      }
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> uploadBulletinFree(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required description,
        required bulletinFreeCount,
        required resortNickname,
      }) async {
    await BulletinFreeModel().uploadBulletinFree(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        description: description,
        bulletinFreeCount: bulletinFreeCount,
        resortNickname: resortNickname,
    );
  }

  Future<void> updateBulletinFree(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required location,
        required description,
        required bulletinFreeCount,
        required resortNickname,
        required likeCount,
        required hot,
        required score,
        required viewerUid,
        required timeStamp

      }) async {
    await BulletinFreeModel().updateBulletinFree(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        description: description,
        bulletinFreeCount: bulletinFreeCount,
        resortNickname: resortNickname,
        likeCount:likeCount,
        hot: hot,
        score: score,
        viewerUid: viewerUid,
        timeStamp: timeStamp,
    );
  }

  Future<void> updateBulletinFreeReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinFree').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinFreeReplyCount = documentSnapshot.get('bulletinFreeReplyCount');
      int bulletinFreeReplyCountPlus = bulletinFreeReplyCount + 1;

      await ref.collection('bulletinFree').doc('$bullUid#$bullCount').update({
        'bulletinFreeReplyCount': bulletinFreeReplyCountPlus,
      });
    }catch(e){
      await ref.collection('bulletinFree').doc('$bullUid#$bullCount').update({
        'bulletinFreeReplyCount': 1,
      });
    }
  }

  Future<void> reduceBulletinFreeReplyCount({required bullUid, required bullCount}) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinFree').doc('$bullUid#$bullCount');

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinFreeReplyCount = documentSnapshot.get('bulletinFreeReplyCount');
      int bulletinFreeReplyCountPlus = bulletinFreeReplyCount - 1;

      await ref.collection('bulletinFree').doc('$bullUid#$bullCount').update({
        'bulletinFreeReplyCount': bulletinFreeReplyCountPlus,
      });
    }catch(e){}
  }

  Future<void> likeDelete(docName) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinFree').doc(docName);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int likeCount = documentSnapshot.get('likeCount');
      int likeCountMinus = likeCount - 1;

      await ref.collection('bulletinFree').doc(docName).update({
        'likeCount': likeCountMinus,
      });
    } catch (e) {
      print('탈퇴한 회원');
    }
  }

  Future<void> likeUpdate(docName) async {
    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('bulletinFree').doc(docName);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int likeCount = documentSnapshot.get('likeCount');
      int likeCountPlus = likeCount + 1;

      await ref.collection('bulletinFree').doc(docName).update({
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
        ref.collection('bulletinFree').doc(docName);

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

        await ref.collection('bulletinFree').doc(docName).update({
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
        ref.collection('bulletinFree').doc(docName);

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

        await ref.collection('bulletinFree').doc(docName).update({
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
        ref.collection('bulletinFree').doc(docName);

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

        await ref.collection('bulletinFree').doc(docName).update({
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
        ref.collection('bulletinFree').doc(docName);

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

        await ref.collection('bulletinFree').doc(docName).update({
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
        ref.collection('bulletinFree').doc(docName);

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

        await ref.collection('bulletinFree').doc(docName).update({
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

