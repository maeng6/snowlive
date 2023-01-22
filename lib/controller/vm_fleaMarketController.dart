import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:snowlive3/model/m_commentModel.dart';
import 'package:snowlive3/model/m_fleaMarketModel.dart';

class FleaModelController extends GetxController {
  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _displayName = ''.obs;
  RxString? _uid = ''.obs;
  RxString? _profileImageUrl = ''.obs;
  RxList? _itemImagesUrls = [].obs;
  RxString? _title = ''.obs;
  RxString? _category = ''.obs;
  RxString? _itemName = ''.obs;
  RxInt? _price = 0.obs;
  RxString? _location = ''.obs;
  RxString? _method = ''.obs;
  RxString? _description = ''.obs;
  RxInt? _fleaCount = 0.obs;
  RxString? _resortNickname = ''.obs;
  RxBool? _soldOut = false.obs;
  Timestamp? _timeStamp;

  String? get displayName => _displayName!.value;

  String? get uid => _uid!.value;

  String? get profileImageUrl => _profileImageUrl!.value;

  List? get itemImagesUrls => _itemImagesUrls!.value;

  String? get title => _title!.value;

  String? get category => _category!.value;

  String? get itemName => _itemName!.value;

  int? get price => _price!.value;

  String? get location => _location!.value;

  String? get method => _method!.value;

  String? get description => _description!.value;

  int? get fleaCount => _fleaCount!.value;

  String? get resortNickname => _resortNickname!.value;

  bool? get soldOut => _soldOut!.value;

  Timestamp? get timeStamp => _timeStamp;

  Future<void> getCurrentFleaItem({required uid, required fleaCount}) async {
    FleaModel fleaModel = await FleaModel().getFleaModel(uid,fleaCount);
    this._displayName!.value = fleaModel.displayName!;
    this._uid!.value = fleaModel.uid!;
    this._profileImageUrl!.value = fleaModel.profileImageUrl!;
    this._itemImagesUrls!.value = fleaModel.itemImagesUrls!;
    this._title!.value = fleaModel.title!;
    this._category!.value = fleaModel.category!;
    this._itemName!.value = fleaModel.itemName!;
    this._price!.value = fleaModel.price!;
    this._location!.value = fleaModel.location!;
    this._method!.value = fleaModel.method!;
    this._description!.value = fleaModel.description!;
    this._fleaCount!.value = fleaModel.fleaCount!;
    this._resortNickname!.value = fleaModel.resortNickname!;
    this._soldOut!.value = fleaModel.soldOut!;
    this._timeStamp = fleaModel.timeStamp!;
  }

  Future<void> updateItemImageUrls(imageUrls) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('fleaMarket').doc('$uid#$fleaCount').update({
      'itemImagesUrls': imageUrls,
    });
    await getCurrentFleaItem(uid: _uid, fleaCount: _fleaCount);
  }

  Future<void> uploadFleaItem(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required itemName,
        required price,
        required location,
        required method,
        required description,
        required fleaCount,
        required resortNickname}) async {
    await FleaModel().uploadFleaItem(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        itemName: itemName,
        price: price,
        location: location,
        method: method,
        description: description,
        fleaCount: fleaCount,
        resortNickname: resortNickname);
  }

  Future<void> updateFleaItem(
      {required displayName,
        required uid,
        required profileImageUrl,
        required itemImagesUrls,
        required title,
        required category,
        required itemName,
        required price,
        required location,
        required method,
        required description,
        required fleaCount,
        required resortNickname}) async {
    await FleaModel().updateFleaItem(
        displayName: displayName,
        uid: uid,
        profileImageUrl: profileImageUrl,
        itemImagesUrls: itemImagesUrls,
        title: title,
        category: category,
        itemName: itemName,
        price: price,
        location: location,
        method: method,
        description: description,
        fleaCount: fleaCount,
        resortNickname: resortNickname);
  }

  String getAgoTime(timestamp) {
    String time = CommentModel().getAgo(timestamp);
    return time;
  }
}
