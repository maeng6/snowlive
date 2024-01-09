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
  RxInt? _bulletinLostLimit = 0.obs;
  RxInt? _bulletinEventLimit = 0.obs;
  RxBool? _bulletinFreeHot = false.obs;
  RxInt? _bulletinCrewReplyLimit = 0.obs;
  RxInt? _bulletinRoomReplyLimit = 0.obs;
  RxInt? _bulletinFreeReplyLimit = 0.obs;
  RxInt? _bulletinLostReplyLimit = 0.obs;
  RxInt? _bulletinEventReplyLimit = 0.obs;
  RxBool? _open = false.obs;
  RxBool? _dailyOpen = false.obs;
  RxList? _open_uidList = [].obs;

  String? get currentSeason => _currentSeason!.value;
  int? get liveTalkLimit => _liveTalkLimit!.value;
  int? get liveTalkReplyLimit => _liveTalkReplyLimit!.value;
  int? get fleaMarketLimit => _fleaMarketLimit!.value;
  int? get bulletinRoomLimit => _bulletinRoomLimit!.value;
  int? get bulletinCrewLimit => _bulletinCrewLimit!.value;
  int? get bulletinFreeLimit => _bulletinFreeLimit!.value;
  int? get bulletinLostLimit => _bulletinLostLimit!.value;
  int? get bulletinEventLimit => _bulletinEventLimit!.value;
  bool? get bulletinFreeHot => _bulletinFreeHot!.value;
  int? get bulletinCrewReplyLimit => _bulletinCrewReplyLimit!.value;
  int? get bulletinRoomReplyLimit => _bulletinRoomReplyLimit!.value;
  int? get bulletinFreeReplyLimit => _bulletinFreeReplyLimit!.value;
  int? get bulletinLostReplyLimit => _bulletinLostReplyLimit!.value;
  int? get bulletinEventReplyLimit => _bulletinEventReplyLimit!.value;
  bool? get open => _open!.value;
  bool? get dailyOpen => _dailyOpen!.value;
  List? get open_uidList => _open_uidList!;


  @override
  void onInit()  async{
    await getCurrentSeason();
    await getLiveTalkLimit();
    await getLiveTalkReplyLimit();
    await getFleaMarketLimit();
    await getBulletinRoomLimit();
    await getBulletinCrewLimit();
    await getBulletinFreeLimit();
    await getBulletinLostLimit();
    await getBulletinEventLimit();
    await getBulletinCrewReplyLimit();
    await getBulletinRoomReplyLimit();
    await getBulletinLostReplyLimit();
    await getBulletinFreeReplyLimit();
    await getBulletinEventReplyLimit();
    await getBulletinFreeHot();
    kusbfListener();
    freeLimitListener();
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

  Future<void> getBulletinLostLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinLostLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinLostLimit = documentSnapshot.get('limit');
    this._bulletinLostLimit!.value = bulletinLostLimit;
  }

  Future<void> getBulletinEventLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinEventLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinEventLimit = documentSnapshot.get('limit');
    this._bulletinEventLimit!.value = bulletinEventLimit;
  }

  Future<void> getBulletinFreeHot() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinFreeLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool bulletinFreeHot = documentSnapshot.get('hot');
    this._bulletinFreeHot!.value = bulletinFreeHot!;
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

  Future<void> getBulletinLostReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinLostReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinLostReplyLimit = documentSnapshot.get('limit');
    this._bulletinLostReplyLimit!.value = bulletinLostReplyLimit;
  }

  Future<void> getBulletinEventReplyLimit() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinEventReplyLimit').doc('1');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    int bulletinEventReplyLimit = documentSnapshot.get('limit');
    this._bulletinEventReplyLimit!.value = bulletinEventReplyLimit;
  }


  Future<void> getSeasonOpen() async {
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('Ranking_openControl').doc('${_currentSeason}');
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool open = documentSnapshot.get('open');
    bool dailyOpen = documentSnapshot.get('dailyOpen');
    List open_uidList = documentSnapshot.get('open_uidList');
    this._open!.value = open;
    this._dailyOpen!.value = dailyOpen;
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

  void freeLimitListener() {
    final DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('bulletinFreeLimit').doc('1');

    documentReference.snapshots().listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        int limit = data!['limit'];
        bool hot = data['hot'];
        this._bulletinFreeLimit!.value = limit;
        this._bulletinFreeHot!.value = hot;
        print(hot);
      } else {
        print('Document does not exist on the database');
      }
    }, onError: (error) => print('Listen failed: $error'));
  }


}

