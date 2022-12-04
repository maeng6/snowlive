import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowlive3/model/m_userModel.dart';

class UserModelController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _uid = ''.obs;
  RxString? _displayName = ''.obs;
  RxString? _userEmail = ''.obs;
  RxInt? _favoriteResort = 0.obs;
  RxInt? _instantResort = 0.obs;
  RxInt? _commentCount = 0.obs;
  int? _favoriteSaved=0;
  RxString? _profileImageUrl=''.obs;
  RxList? _repoUidList=[].obs;


  String? get uid => _uid!.value;
  String? get displayName => _displayName!.value;
  String? get userEmial => _userEmail!.value;
  int? get favoriteResort => _favoriteResort!.value;
  int? get instantResort  => _instantResort!.value;
  int? get commentCount  => _commentCount!.value;
  int? get favoriteSaved => _favoriteSaved;
  String? get profileImageUrl => _profileImageUrl!.value;
  List? get repoUidList => _repoUidList;



  @override
  void onInit()  async{
    // TODO: implement onInit
    String? loginUid = await FlutterSecureStorage().read(key: 'uid');
    getCurrentUser(loginUid);
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
      this._profileImageUrl!.value = userModel.profileImageUrl!;
      await prefs.setInt('favoriteResort', userModel.favoriteResort!);
    } else {}
  }

  Future<void> updateProfileImageUrl(url) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'profileImageUrl': url,
    });
    try{
    try{
    await ref.collection('comment').doc('resort').collection('0').doc(uid).update({
      'profileImageUrl': url
    });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('1').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('2').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('3').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('4').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('5').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('6').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('7').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('8').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('9').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('10').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('11').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}
    try{
      await ref.collection('comment').doc('resort').collection('12').doc(uid).update({
        'profileImageUrl': url
      });} catch(e){print(e);}

    }catch(e){print(e);}
    await getCurrentUser(auth.currentUser!.uid);
  }

  Future<void> deleteProfileImageUrl() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'profileImageUrl': '',
    });
    try{
      try{
        await ref.collection('comment').doc('resort').collection('0').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('1').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('2').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('3').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('4').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('5').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('6').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('7').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('8').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('9').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('10').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('11').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}
      try{
        await ref.collection('comment').doc('resort').collection('12').doc(uid).update({
          'profileImageUrl': ''
        });} catch(e){print(e);}

    }catch(e){print(e);}
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

  Future<void> updateNickname(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'displayName': index,
    });
    await getCurrentUser(auth.currentUser!.uid);
  } //선택한 리조트를 파베유저문서에 업데이트
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
}