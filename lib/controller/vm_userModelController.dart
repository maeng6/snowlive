import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowlive3/model/m_userModel.dart';

class UserModelController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _uid = ''.obs;
  RxString? _userEmail = ''.obs;
  RxInt? _favoriteResort = 0.obs;
  RxInt? _instantResort = 0.obs;
  int? _favoriteSaved=0;

  String? get uid => _uid!.value;
  String? get userEmial => _userEmail!.value;
  int? get favoriteResort => _favoriteResort!.value;
  int? get instantResort  => _instantResort!.value;
  int? get favoriteSaved => _favoriteSaved;

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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    UserModel userModel = await UserModel().getUserModel(uid);
    this._uid!.value = userModel.uid!;
    this._userEmail!.value = userModel.userEmail!;
    this._favoriteResort!.value = userModel.favoriteResort!;
    this._instantResort!.value = userModel.instantResort!;
    await prefs.setInt('favoriteResort', userModel.favoriteResort!);
    print('${prefs.getInt('favoriteResort')}');
  }

  Future<void> updateFavoriteResort(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'favoriteResort': index,
    });
    await getCurrentUser();
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