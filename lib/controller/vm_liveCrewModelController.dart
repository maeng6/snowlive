import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
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
  RxString? _description=''.obs;
  RxString? _notice=''.obs;
  Timestamp? _resistDate;

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
  String? get description => _description!.value;
  String? get notice => _notice!.value;
  Timestamp? get resistDate => _resistDate!;

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
      this._description!.value = crewModel.description!;
      this._notice!.value = crewModel.notice!;
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
    required crewID
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
      'description':'',
      'notice':'',
      'resistDate' : Timestamp.now(),
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




}