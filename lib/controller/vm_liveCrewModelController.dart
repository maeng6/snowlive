import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../model/m_liveCrewModel.dart';
import '../model/m_resortModel.dart';

class LiveCrewModelController extends GetxController {

  final ref = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;

  RxString? _crewID=''.obs;
  RxString? _crewName=''.obs;
  RxString? _crewLeader=''.obs;
  RxInt? _crewColor=0.obs;
  RxString? _leaderUid=''.obs;
  RxString? _baseResortNickName=''.obs;
  RxInt? _baseResort=0.obs;
  RxString? _profileImageUrl=''.obs;
  RxList? _memberUidList=[].obs;
  RxList? _applyUidList=[].obs;
  RxList? _galleryUrlList=[].obs;
  RxString? _description=''.obs;
  RxString? _notice=''.obs;
  RxString? _sns=''.obs;
  Timestamp? _resistDate;
  Timestamp? _lastPassTime;
  RxMap? _passCountData={}.obs;
  RxMap? _slopeScores={}.obs;
  RxMap? _passCountTimedata={}.obs;
  RxInt? _totalPassCount=0.obs;


  String? get crewID => _crewID!.value;
  String? get crewName => _crewName!.value;
  String? get crewLeader => _crewLeader!.value;
  int? get crewColor => _crewColor!.value;
  String? get leaderUid => _leaderUid!.value;
  String? get baseResortNickName => _baseResortNickName!.value;
  int? get baseResort => _baseResort!.value;
  String? get profileImageUrl => _profileImageUrl!.value;
  List? get memberUidList => _memberUidList!;
  List? get applyUidList => _applyUidList!;
  List? get galleryUrlList => _galleryUrlList!;
  String? get description => _description!.value;
  String? get notice => _notice!.value;
  String? get sns => _sns!.value;
  Timestamp? get resistDate => _resistDate!;
  Timestamp? get lastPassTime => _lastPassTime!;
  Map? get passCountData => _passCountData!;
  Map? get slopeScores => _slopeScores!;
  Map? get passCountTimeData => _passCountTimedata!;
  int? get totalPassCount => _totalPassCount!.value;


  Future<void> getCurrnetCrew(crewID) async {
    if (crewID != null) {
      LiveCrewModel? crewModel = await LiveCrewModel().getCrewModel(crewID);
      this._crewID!.value = crewModel!.crewID!;
      this._crewName!.value = crewModel.crewName!;
      this._crewLeader!.value = crewModel.crewLeader!;
      this._crewColor!.value = crewModel.crewColor!;
      this._leaderUid!.value = crewModel.leaderUid!;
      this._baseResortNickName!.value = crewModel.baseResortNickName!;
      this._baseResort!.value = crewModel.baseResort!;
      this._profileImageUrl!.value = crewModel.profileImageUrl!;
      this._memberUidList!.value = crewModel.memberUidList!;
      this._applyUidList!.value = crewModel.applyUidList!;
      this._galleryUrlList!.value = crewModel.galleryUrlList!;
      this._description!.value = crewModel.description!;
      this._notice!.value = crewModel.notice!;
      this._sns!.value = crewModel.sns!;
      this._passCountData!.value = crewModel.passCountData!;
      this._slopeScores!.value = crewModel.slopeScores!;
      this._passCountTimedata!.value = crewModel.passCountTimeData!;
      this._totalPassCount!.value = crewModel.totalPassCount!;
      this._lastPassTime = crewModel.lastPassTime!;
      this._resistDate = crewModel.resistDate!;
    }
  }

  Future<bool> checkDuplicateCrewName(String crewName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewName', isEqualTo: crewName)
        .get();
    return querySnapshot.docs.isEmpty;
  }


  Future<void> createCrewDoc({
    required crewLeader,
    required crewName,
    required resortNum,
    required crewImageUrl,
    required crewColor,
    required crewID,
    required sns,
    required totalScore,
} ) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    int colorValue = crewColor.value;
    await ref.collection('liveCrew').doc(crewID).set({
      'crewID' : crewID,
      'crewName' : crewName,
      'crewLeader': crewLeader,
      'crewColor': colorValue,
      'leaderUid': uid,
      'baseResortNickName' : nicknameList[resortNum],
      'baseResort': resortNum,
      'profileImageUrl' : crewImageUrl,
      'memberUidList' : FieldValue.arrayUnion([uid]),
      'applyUidList' : [],
      'galleryUrlList' : [],
      'description':'',
      'notice':'',
      'resistDate' : Timestamp.now(),
      'lastPassTime' : Timestamp.now(),
      'sns' : '',
      'totalScore': 0,
      'passCountData': {},
      'slopeScores': {},
      'passCountTimeData': {
        '1': 0,
        '2': 0,
        '3': 0,
        '4': 0,
        '5': 0,
        '6': 0,
        '7': 0,
        '8': 0,
        '9': 0,
        '10': 0,
        '11': 0,
        '12': 0,
      },
      'totalPassCount':0
    });
  }

  Future<void> deleteCrew({required crewID}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;

    try {
      CollectionReference crews = FirebaseFirestore.instance.collection('liveCrew');
      await crews.doc(crewID).delete();

      await ref.collection('user').doc(uid).update({
        'liveCrew': ''
      });

    }catch(e){
      print('삭제 에러');
    }
  }

  Future<void> deleteCrewMember({required crewID, required memberUid}) async {
    try {
      await ref.collection('user').doc(memberUid).update({
        'liveCrew': ''
      });

      await ref.collection('liveCrew').doc(crewID).update({
        'memberUidList': FieldValue.arrayRemove([memberUid])
      });

    }catch(e){
      print('삭제 에러');
    }
    getCurrnetCrew(crewID);
  }

  Future<dynamic> searchCrewByCrewName(String crewName) async {
    var foundCrewID ;
    final querySnapshot = await FirebaseFirestore.instance
        .collection('liveCrew')
        .where('crewName', isEqualTo: crewName)
        .get();

    final List<LiveCrewModel> users = [];
    for (final doc in querySnapshot.docs) {
      final crew = await LiveCrewModel.fromJson(doc.data(),doc.reference);
      users.add(crew);

      foundCrewID = crew.crewID;
    }
    return foundCrewID;

  }

  Future<LiveCrewModel?> getFoundCrew(crewID) async{
    LiveCrewModel? foundCrewModel= LiveCrewModel();
    if(crewID != null) {
      foundCrewModel = await LiveCrewModel().getCrewModel(crewID);
      if (foundCrewModel != null) {
        foundCrewModel.baseResort = foundCrewModel.baseResort!;
        foundCrewModel.baseResortNickName = foundCrewModel.baseResortNickName;
        foundCrewModel.crewColor = foundCrewModel.crewColor!;
        foundCrewModel.crewName = foundCrewModel.crewName!;
        foundCrewModel.crewLeader = foundCrewModel.crewLeader!;
        foundCrewModel.description = foundCrewModel.description;
        foundCrewModel.leaderUid = foundCrewModel.leaderUid!;
        foundCrewModel.memberUidList = foundCrewModel.memberUidList!;
        foundCrewModel.profileImageUrl = foundCrewModel.profileImageUrl!;
        foundCrewModel.resistDate = foundCrewModel.resistDate!;
      } else {
        // handle the case where the userModel is null
      }
    } else{
    }
    return foundCrewModel;
  }

  Future<void> updateInvitation_crew({required crewID}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'applyCrewList': FieldValue.arrayUnion([crewID])
    });
    await ref.collection('liveCrew').doc(crewID).update({
      'applyUidList': FieldValue.arrayUnion([uid])
    });

  }

  Future<void> updateInvitationAlarm_crew({required leaderUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('newAlarm')
        .doc(leaderUid)
        .update({
      'newInvited_crew': true
    });
  }
  Future<void> deleteInvitationAlarm_crew({required leaderUid}) async {
    await ref.collection('newAlarm')
        .doc(leaderUid)
        .update({
      'newInvited_crew': false
    });
  }

  Future<void> deleteInvitation_crew({required crewID,required applyUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(applyUid).update({
      'applyCrewList': FieldValue.arrayRemove([crewID])
    });

    await ref.collection('liveCrew').doc(crewID).update({
      'applyUidList': FieldValue.arrayRemove([applyUid])
    });
  }

  Future<void> updateCrewMember({required applyUid,required crewID}) async {

    await ref.collection('user').doc(applyUid).update({
      'liveCrew': crewID
    });
    await ref.collection('liveCrew').doc(crewID).update({
      'memberUidList': FieldValue.arrayUnion([applyUid])
    });

    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('liveCrew').doc(crewID);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List memberUidList = documentSnapshot.get('memberUidList');
    this._memberUidList!.value = memberUidList;
  }

  Future<void> crewLeaderDelegation_crewDoc({required memberUid,required memberDisplayName, required crewID}) async {

    await ref.collection('liveCrew').doc(crewID).update({
      'leaderUid': memberUid,
    });
    await ref.collection('liveCrew').doc(crewID).update({
      'crewLeader': memberDisplayName,
    });

    await getCurrnetCrew(crewID);

  }

  Future<void> updateProfileImageUrl({required url, required crewID}) async {
    await ref.collection('liveCrew').doc(crewID).update({
      'profileImageUrl': url,
    });
    await getCurrnetCrew(crewID);
  }


  Future<void> deleteProfileImageUrl({required crewID}) async {
    await ref.collection('liveCrew').doc(crewID).update({
      'profileImageUrl': '',
    });
    await getCurrnetCrew(crewID);
  }

  Future<void> updateDescription({required desc, required crewID}) async {
    await ref.collection('liveCrew').doc(crewID).update({
      'description': desc,
    });
    await getCurrnetCrew(crewID);
  }

  Future<void> updateNotice({required notice, required crewID}) async {
    await ref.collection('liveCrew').doc(crewID).update({
      'notice': notice,
    });
    await getCurrnetCrew(crewID);
  }

  Future<void> updateSNS({required snsLink, required crewID}) async {
    await ref.collection('liveCrew').doc(crewID).update({
      'sns': snsLink,
    });
    await getCurrnetCrew(crewID);
  }

  Future<void> updateCrewColor({required crewColor, required crewID}) async {
    int colorValue = crewColor.value;
    await ref.collection('liveCrew').doc(crewID).update({
      'crewColor': colorValue,
    });
    await getCurrnetCrew(crewID);
  }

  void otherShare({required String contents}) async{
    if(await canLaunchUrlString(contents) )
      await launchUrlString(contents);
    else throw "Not!";
}


}