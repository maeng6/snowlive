import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  int? _favoriteSaved=0;
  RxString? _profileImageUrl=''.obs;
  RxBool? _exist = false.obs;

  String? get uid => _uid!.value;
  String? get displayName => _displayName!.value;
  String? get userEmial => _userEmail!.value;
  int? get favoriteResort => _favoriteResort!.value;
  int? get instantResort  => _instantResort!.value;
  int? get favoriteSaved => _favoriteSaved;
  String? get profileImageUrl => _profileImageUrl!.value;
  bool? get exist => _exist!.value;

  @override
  void onInit()  {
    // TODO: implement onInit
     getCurrentUser();
    super.onInit();
  }

  Future<void> getLocalSave() async {
    final prefs = await SharedPreferences.getInstance();
    int? localFavorite = prefs.getInt('favoriteResort');
    this._favoriteSaved = localFavorite;
  }

  Future<void> getCurrentUser() async{
    if(FirebaseAuth.instance.currentUser != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String uid = FirebaseAuth.instance.currentUser!.uid;
      UserModel userModel = await UserModel().getUserModel(uid);
      this._uid!.value = userModel.uid!;
      this._displayName!.value = userModel.displayName!;
      this._userEmail!.value = userModel.userEmail!;
      this._favoriteResort!.value = userModel.favoriteResort!;
      this._instantResort!.value = userModel.instantResort!;
      this._profileImageUrl!.value = userModel.profileImageUrl!;
      this._exist!.value = userModel.exist!;
      await prefs.setInt('favoriteResort', userModel.favoriteResort!);
    } else {}
  }

  Future<void> updateProfileImageUrl(url) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'profileImageUrl': url,
    });
    await getCurrentUser();
  } //선택한 리조트를 파베유저문서에 업데이트
  Future<void> updateNickname(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'displayName': index,
    });
    await getCurrentUser();
  } //선택한 리조트를 파베유저문서에 업데이트
  Future<void> updateFavoriteResort(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'favoriteResort': index,
    });
    await getCurrentUser();
    await getLocalSave();
  } //선택한 리조트를 파베유저문서에 업데이트
  Future<void> updateInstantResort(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'instantResort': index,
    });
    await getCurrentUser();
  } //선택한 리조트를 파베유저문서에 업데이트
}