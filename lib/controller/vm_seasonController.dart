import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SeasonController extends GetxController{

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _currentSeason = ''.obs;
  RxInt? _liveTalkLimit = 0.obs;
  RxInt? _liveTalkReplyLimit = 0.obs;
  RxInt? _fleaMarketLimit = 0.obs;
  RxInt? _bulletinRoomLimit = 0.obs;
  RxInt? _bulletinCrewLimit = 0.obs;
  RxInt? _bulletinFreeLimit = 0.obs;
  RxInt? _bulletinCrewReplyLimit = 0.obs;
  RxInt? _bulletinRoomReplyLimit = 0.obs;
  RxInt? _bulletinFreeReplyLimit = 0.obs;
  RxBool? _open = false.obs;
  RxList? _open_uidList = [].obs;

  String? get currentSeason => _currentSeason!.value;
  int? get liveTalkLimit => _liveTalkLimit!.value;
  int? get liveTalkReplyLimit => _liveTalkReplyLimit!.value;
  int? get fleaMarketLimit => _fleaMarketLimit!.value;
  int? get bulletinRoomLimit => _bulletinRoomLimit!.value;
  int? get bulletinCrewLimit => _bulletinCrewLimit!.value;
  int? get bulletinFreeLimit => _bulletinFreeLimit!.value;
  int? get bulletinCrewReplyLimit => _bulletinCrewReplyLimit!.value;
  int? get bulletinRoomReplyLimit => _bulletinRoomReplyLimit!.value;
  int? get bulletinFreeReplyLimit => _bulletinFreeReplyLimit!.value;
  bool? get open => _open!.value;
  List? get open_uidList => _open_uidList!.value;


  @override
  void onInit()  async{
    await getCurrentSeason();
    await getLiveTalkLimit();
    await getLiveTalkReplyLimit();
    await getFleaMarketLimit();
    await getBulletinRoomLimit();
    await getBulletinCrewLimit();
    await getBulletinFreeLimit();
    await getBulletinCrewReplyLimit();
    await getBulletinRoomReplyLimit();
    await getBulletinFreeReplyLimit();
    kusbfListener();
    // TODO: implement onInit
    super.onInit();
  }


  Future<void> getCurrentSeason() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('season').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    String currentSeason = documentSnapshot.get('season');
    this._currentSeason!.value = currentSeason;
  }

  Future<void> getLiveTalkLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('liveTalkLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int liveTalkLimit = documentSnapshot.get('limit');
    this._liveTalkLimit!.value = liveTalkLimit;
  }

  Future<void> getLiveTalkReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('liveTalkReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int liveTalkReplyLimit = documentSnapshot.get('limit');
    this._liveTalkReplyLimit!.value = liveTalkReplyLimit;
  }

  Future<void> getFleaMarketLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('fleaMarketLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int fleaMarketLimit = documentSnapshot.get('limit');
    this._fleaMarketLimit!.value = fleaMarketLimit;
  }

  Future<void> getBulletinRoomLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinRoomLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinRoomLimit = documentSnapshot.get('limit');
    this._bulletinRoomLimit!.value = bulletinRoomLimit;
  }

  Future<void> getBulletinCrewLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinCrewLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinCrewLimit = documentSnapshot.get('limit');
    this._bulletinCrewLimit!.value = bulletinCrewLimit;
  }

  Future<void> getBulletinFreeLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinFreeLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinFreeLimit = documentSnapshot.get('limit');
    this._bulletinFreeLimit!.value = bulletinFreeLimit;
  }

  Future<void> getBulletinCrewReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinCrewReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinCrewReplyLimit = documentSnapshot.get('limit');
    this._bulletinCrewReplyLimit!.value = bulletinCrewReplyLimit;
  }

  Future<void> getBulletinRoomReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinRoomReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinRoomReplyLimit = documentSnapshot.get('limit');
    this._bulletinRoomReplyLimit!.value = bulletinRoomReplyLimit;
  }

  Future<void> getBulletinFreeReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinFreeReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinFreeReplyLimit = documentSnapshot.get('limit');
    this._bulletinFreeReplyLimit!.value = bulletinFreeReplyLimit;
  }

  Future<void> getSeasonOpen() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('Ranking_openControl').doc('${_currentSeason}');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool open = documentSnapshot.get('open');
    List open_uidList = documentSnapshot.get('open_uidList');
    this._open!.value = open;
    this._open_uidList!.value = open_uidList;
  }

  void kusbfListener() {
    final DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('Ranking_openControl').doc('${_currentSeason}');

    documentReference.snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        bool open = data!['open'];
        List open_uidList = data['open_uidList'];
        this._open!.value = open;
        this._open_uidList!.value = open_uidList;
      } else {
        print('Document does not exist on the database');
      }
    }, onError: (error) => print('Listen failed: $error'));
  }


}

