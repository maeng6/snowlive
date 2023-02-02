import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowlive3/model/m_userModel.dart';

import '../model/m_resortModel.dart';

class UserModelController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _uid = ''.obs;
  RxString? _displayName = ''.obs;
  RxString? _userEmail = ''.obs;
  RxInt? _favoriteResort = 0.obs;
  RxInt? _instantResort = 0.obs;
  RxInt? _commentCount = 0.obs;
  RxInt? _fleaCount = 0.obs;
  int? _favoriteSaved=0;
  RxString? _profileImageUrl=''.obs;
  RxList? _repoUidList=[].obs;
  RxList? _likeUidList=[].obs;
  RxList? _fleaChatUidList=[].obs;
  RxString? _resortNickname =''.obs;
  RxInt? _fleaChatCount = 0.obs;
  RxString? _phoneNum=''.obs;
  RxBool? _phoneAuth=false.obs;
  Timestamp? _resistDate;


  String? get uid => _uid!.value;
  String? get displayName => _displayName!.value;
  String? get userEmail => _userEmail!.value;
  int? get favoriteResort => _favoriteResort!.value;
  int? get instantResort  => _instantResort!.value;
  int? get commentCount  => _commentCount!.value;
  int? get fleaCount  => _fleaCount!.value;
  int? get favoriteSaved => _favoriteSaved;
  String? get profileImageUrl => _profileImageUrl!.value;
  List? get repoUidList => _repoUidList;
  List? get likeUidList => _likeUidList;
  List? get fleaChatUidList => _fleaChatUidList;
  String? get resortNickname => _resortNickname!.value;
  int? get fleaChatCount => _fleaChatCount!.value;
  String? get phoneNum => _phoneNum!.value;
  bool? get phoneAuth => _phoneAuth!.value;
  Timestamp? get resistDate => _resistDate;


  @override
  void onInit()  async{
    // TODO: implement onInit
    String? loginUid = await FlutterSecureStorage().read(key: 'uid');
      getCurrentUser(loginUid).catchError((e){
        setNewField();
      }).catchError((){
        print('로그인 전');
      });
    super.onInit();
  }

  Future<void> getLocalSave() async {
    final prefs = await SharedPreferences.getInstance();
    int? localFavorite = prefs.getInt('favoriteResort');
    this._favoriteSaved = localFavorite;
  }

  Future<void> getCurrentUser(uid) async{
    if(FirebaseAuth.instance.currentUser != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      //String uid = FirebaseAuth.instance.currentUser!.uid;
      UserModel userModel = await UserModel().getUserModel(uid);
      this._uid!.value = userModel.uid!;
      this._displayName!.value = userModel.displayName!;
      this._userEmail!.value = userModel.userEmail!;
      this._favoriteResort!.value = userModel.favoriteResort!;
      this._instantResort!.value = userModel.instantResort!;
      this._commentCount!.value = userModel.commentCount!;
      this._fleaCount!.value = userModel.fleaCount!;
      this._profileImageUrl!.value = userModel.profileImageUrl!;
      this._resortNickname!.value = userModel.resortNickname!;
      this._phoneNum!.value = userModel.phoneNum!;
      this._phoneAuth!.value = userModel.phoneAuth!;
      this._likeUidList!.value = userModel.likeUidList!;
      this._resistDate = userModel.resistDate!;
      this._fleaChatUidList!.value = userModel.fleaChatUidList!;
      await prefs.setInt('favoriteResort', userModel.favoriteResort!);
    } else {}
  }


  Future<void> addChatUidList({required otherAddUid, required myAddUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'fleaChatUidList':  FieldValue.arrayUnion([otherAddUid])
    });
    await ref.collection('user').doc(otherAddUid).update({
      'fleaChatUidList':  FieldValue.arrayUnion([myAddUid])
    });
    await getCurrentUser(auth.currentUser!.uid);
  }

  Future<void> setNewField() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    List fleaChatUidList = [];
    await ref.collection('user').doc(uid).update({
      'fleaCount': 0,
      'phoneAuth' : false,
      'phoneNum' : '',
      'likeUidList' : [],
      'resistDate' : Timestamp.fromDate(DateTime(1990)),
      'fleaChatUidList' : fleaChatUidList
    });
    await getCurrentUser(auth.currentUser!.uid);
  }



  Future<void> updateProfileImageUrl(url) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'profileImageUrl': url,
    });
    await getCurrentUser(auth.currentUser!.uid);
  }

  Future<void> deleteProfileImageUrl() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'profileImageUrl': '',
    });
    await getCurrentUser(auth.currentUser!.uid);
  }

  Future<void> repoUpdate(uid) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int repoCount = documentSnapshot.get('repoCount');
      int repoCountPlus = repoCount + 1;

      await ref.collection('user').doc(uid).update({
        'repoCount': repoCountPlus,
      });
    }catch(e){
      print('탈퇴한 회원');
    }
  }

  Future<void> fleaCountUpdate(uid) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int fleaCount = documentSnapshot.get('fleaCount');
      int fleaCountPlus = fleaCount + 1;

      await ref.collection('user').doc(uid).update({
        'fleaCount': fleaCountPlus,
      });
      this._fleaCount!.value = fleaCountPlus;
    }catch(e){
      await ref.collection('user').doc(uid).update({
        'fleaCount': 1,
      });
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int fleaCount = documentSnapshot.get('fleaCount');

      this._fleaCount!.value = fleaCount;

    }

  }




  Future<void> updateRepoUid(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(userMe).update({
      'repoUidList': FieldValue.arrayUnion([uid])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List repoUidList = documentSnapshot.get('repoUidList');
    this._repoUidList!.value = repoUidList;
  }

  Future<void> updateRepoUidList() async {
    final  userMe = auth.currentUser!.uid;
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List repoUidList = documentSnapshot.get('repoUidList');
    this._repoUidList!.value = repoUidList;
  }

  Future<void> updatefleaChatUidList() async {
    final  userMe = auth.currentUser!.uid;
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List fleaChatUidList = documentSnapshot.get('fleaChatUidList');
    this._fleaChatUidList!.value = fleaChatUidList;
  }


  Future<void> updateLikeUid(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(userMe).update({
      'likeUidList': FieldValue.arrayUnion([uid])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List likeUidList = documentSnapshot.get('likeUidList');
    this._likeUidList!.value = likeUidList;
  }

  Future<void> deleteLikeUid(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(userMe).update({
      'likeUidList': FieldValue.arrayRemove([uid])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List likeUidList = documentSnapshot.get('likeUidList');
    this._likeUidList!.value = likeUidList;
  }


  Future<void> updateLikeUidList() async {
    final  userMe = auth.currentUser!.uid;
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List likeUidList = documentSnapshot.get('likeUidList');
    this._likeUidList!.value = likeUidList;
  }

  Future<void> updateNickname(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'displayName': index,
    });
    await getCurrentUser(auth.currentUser!.uid);
  }
  //선택한 리조트를 파베유저문서에 업데이트
  Future<void> updateFavoriteResort(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'favoriteResort': index,
    });
    await getCurrentUser(auth.currentUser!.uid);
    await getLocalSave();
  } //선택한 리조트를 파베유저문서에 업데이트
  Future<void> updateInstantResort(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'instantResort': index,
    });
    await getCurrentUser(auth.currentUser!.uid);
  } //선택한 리조트를 파베유저문서에 업데이트

  Future<void> updateCommentCount(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'commentCount': index+1,
    });
    await getCurrentUser(auth.currentUser!.uid);
  }

  Future<void> updateChatCount({required myUid,required otherUid,required chatRoomName,required chatCount,required chatCheckCount}) async {
    await ref.collection('user').doc(otherUid).collection('$chatRoomName').doc(myUid).update({
      'chatCount': chatCount+1,
      'chatCheckCount' : chatCheckCount+1
    });
  }


  Future<void> updateResortNickname(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'resortNickname': nicknameList[index],
    });
    await getCurrentUser(auth.currentUser!.uid);
  } //선택한 리조트를 파베유저문서에 업데이트
}

// Future<void> updatefleaChatUid(uid) async {
//   final  userMe = auth.currentUser!.uid;
//   await ref.collection('user').doc(userMe).update({
//     'fleaChatUidList': FieldValue.arrayUnion([uid])
//   });
//   DocumentReference<Map<String, dynamic>> documentReference =
//   ref.collection('user').doc(userMe);
//   final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//   await documentReference.get();
//   List fleaChatUidList = documentSnapshot.get('fleaChatUidList');
//   this._fleaChatUidList!.value = fleaChatUidList;
// }

// Future<void> fleaChatCountUpdate(uid) async {
//
//   try {
//     DocumentReference<Map<String, dynamic>> documentReference =
//     ref.collection('user').doc(uid);
//
//     final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//     await documentReference.get();
//
//     int fleaChatCount = documentSnapshot.get('fleaChatCount');
//     int fleaChatCountPlus = fleaChatCount + 1;
//
//     await ref.collection('user').doc(uid).update({
//       'fleaChatCount': fleaChatCountPlus,
//     });
//     this._fleaChatCount!.value = fleaChatCountPlus;
//   }catch(e){
//     await ref.collection('user').doc(uid).update({
//       'fleaChatCount': 1,
//     });
//     DocumentReference<Map<String, dynamic>> documentReference =
//     ref.collection('user').doc(uid);
//
//     final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
//     await documentReference.get();
//
//     int fleaChatCount = documentSnapshot.get('fleaChatCount');
//
//     this._fleaChatCount!.value = fleaChatCount;
//
//   }
//
// }