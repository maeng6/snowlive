import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowlive3/model/m_userModel.dart';
import 'package:snowlive3/screens/login/v_loginpage.dart';
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
  RxInt? _bulletinRoomCount = 0.obs;
  RxInt? _bulletinCrewCount = 0.obs;
  int? _favoriteSaved=0;
  RxString? _profileImageUrl=''.obs;
  RxList? _repoUidList=[].obs;
  RxList? _friendUidList=[].obs;
  RxList? _liveFriendUidList=[].obs;
  RxList? _likeUidList=[].obs;
  RxList? _fleaChatUidList=[].obs;
  RxList? _myFriendCommentUidList=[].obs;
  RxString? _resortNickname =''.obs;
  RxString? _myCrew =''.obs;
  RxList? _liveCrew =[].obs;
  RxInt? _fleaChatCount = 0.obs;
  RxString? _phoneNum=''.obs;
  RxBool? _phoneAuth=false.obs;
  RxBool? _newChat=false.obs;
  Timestamp? _resistDate;
  RxString? _stateMsg = ''.obs;
  RxBool? _isOnLive = false.obs;
  RxBool? _commentCheck = false.obs;
  RxList? _whoResistMe = [].obs;
  RxList? _whoInviteMe = [].obs;
  RxList? _whoIinvite = [].obs;
  RxList? _whoResistMeBF = [].obs;
  RxList? _whoRepoMe = [].obs;
  RxBool? _withinBoundary = false.obs;
  RxList? _applyCrewList = [].obs;


  String? get uid => _uid!.value;
  String? get displayName => _displayName!.value;
  String? get userEmail => _userEmail!.value;
  int? get favoriteResort => _favoriteResort!.value;
  int? get instantResort  => _instantResort!.value;
  int? get commentCount  => _commentCount!.value;
  int? get fleaCount  => _fleaCount!.value;
  int? get bulletinRoomCount  => _bulletinRoomCount!.value;
  int? get bulletinCrewCount  => _bulletinCrewCount!.value;
  int? get favoriteSaved => _favoriteSaved;
  String? get profileImageUrl => _profileImageUrl!.value;
  List? get repoUidList => _repoUidList;
  List? get friendUidList => _friendUidList;
  List? get liveFriendUidList => _liveFriendUidList;
  List? get likeUidList => _likeUidList;
  List? get fleaChatUidList => _fleaChatUidList;
  List? get myFriendCommentUidList => _myFriendCommentUidList;
  String? get resortNickname => _resortNickname!.value;
  String? get myCrew => _myCrew!.value;
  List? get liveCrew => _liveCrew!;
  int? get fleaChatCount => _fleaChatCount!.value;
  String? get phoneNum => _phoneNum!.value;
  bool? get phoneAuth => _phoneAuth!.value;
  bool? get newChat => _newChat!.value;
  Timestamp? get resistDate => _resistDate;
  String? get stateMsg =>_stateMsg!.value;
  bool? get isOnLive =>_isOnLive!.value;
  bool? get commentCheck =>_commentCheck!.value;
  List? get whoResistMe =>_whoResistMe;
  List? get whoInviteMe =>_whoInviteMe;
  List? get whoIinvite =>_whoIinvite;
  List? get whoResistMeBF =>_whoResistMeBF;
  List? get whoRepoMe =>_whoRepoMe;
  bool? get withinBoundary => _withinBoundary!.value;
  List? get applyCrewList => _applyCrewList;

  @override
  void onInit()  async{
    // TODO: implement onInit
    String? loginUid = await FlutterSecureStorage().read(key: 'uid');
    if(loginUid != null) {
      getCurrentUser(loginUid).catchError((e) {
        setNewField2();
        getCurrentUser(loginUid).catchError((e){
          setNewField();
          getCurrentUser(loginUid);
        });
      }).catchError(() {
        print('로그인 전');
      });
    }else{
      Get.to(()=>LoginPage());
    }
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
      if(uid!=null) {
        UserModel? userModel = await UserModel().getUserModel(uid);
        if (userModel != null) {
          this._uid!.value = userModel.uid!;
          this._displayName!.value = userModel.displayName!;
          this._userEmail!.value = userModel.userEmail!;
          this._favoriteResort!.value = userModel.favoriteResort!;
          this._instantResort!.value = userModel.instantResort!;
          this._commentCount!.value = userModel.commentCount!;
          this._fleaCount!.value = userModel.fleaCount!;
          this._bulletinRoomCount!.value = userModel.bulletinRoomCount!;
          this._profileImageUrl!.value = userModel.profileImageUrl!;
          this._resortNickname!.value = userModel.resortNickname!;
          this._phoneNum!.value = userModel.phoneNum!;
          this._phoneAuth!.value = userModel.phoneAuth!;
          this._likeUidList!.value = userModel.likeUidList!;
          this._friendUidList!.value = userModel.friendUidList!;
          this._myFriendCommentUidList!.value = userModel.myFriendCommentUidList!;
          this._liveFriendUidList!.value = userModel.liveFriendUidList!;
          this._resistDate = userModel.resistDate!;
          this._myCrew!.value = userModel.myCrew!;
          this._newChat!.value = userModel.newChat!;
          this._stateMsg!.value = userModel.stateMsg!;
          this._isOnLive!.value = userModel.isOnLive!;
          this._commentCheck!.value = userModel.commentCheck!;
          this._whoResistMe!.value = userModel.whoResistMe!;
          this._whoInviteMe!.value = userModel.whoInviteMe!;
          this._whoIinvite!.value = userModel.whoIinvite!;
          this._whoResistMeBF!.value = userModel.whoResistMeBF!;
          this._whoRepoMe!.value = userModel.whoRepoMe!;
          this._withinBoundary!.value = userModel.withinBoundary!;
          this._applyCrewList!.value = userModel.applyCrewList!;
          try {
            this._fleaChatUidList!.value = userModel.fleaChatUidList!;
          }catch(e){};
          await prefs.setInt('favoriteResort', userModel.favoriteResort!);
          //
        }else {
          Get.to(()=>LoginPage());
          // handle the case where the userModel is null
        }} else {
        Get.to(()=>LoginPage());
        // handle the case where the userModel is null
      }

    } else {
      Get.to(()=>LoginPage());
    }
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
      'bulletinRoomCount': 0,
      'fleaCount': 0,
      'phoneAuth' : false,
      'phoneNum' : '',
      'likeUidList' : [],
      'resistDate' : Timestamp.fromDate(DateTime(1990)),
      'fleaChatUidList' : fleaChatUidList,
      'newChat' : false,
      'friendUidList' : [],
    });
    await getCurrentUser(auth.currentUser!.uid);
  }
  Future<void> setNewField2() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'stateMsg':'',
      'isOnLive': false,
      'whoResistMe':[],
      'whoInviteMe':[],
      'whoIinvite':[],
      'whoResistMeBF':[],
      'withinBoundary': false,
      'whoRepoMe':[],
      'liveFriendUidList':[],
      'myFriendCommentUidList':[],
      'commentCheck':false,
      'whoIinvite':[],
      'whoInviteMe':[],
      'myCrew':'',
      'liveCrew':[],
      'applyCrewList':[]
    });
    await getCurrentUser(auth.currentUser!.uid);
  }

  Future<void> updateNewChatRead() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'newChat': false,
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


  Future<void> deleteMyCrew() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'myCrew': '',
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

  Future<void> bulletinRoomCountUpdate(uid) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinRoomCount = documentSnapshot.get('bulletinRoomCount');
      int bulletinRoomCountPlus = bulletinRoomCount + 1;

      await ref.collection('user').doc(uid).update({
        'bulletinRoomCount': bulletinRoomCountPlus,
      });
      this._bulletinRoomCount!.value = bulletinRoomCountPlus;
    }catch(e){
      await ref.collection('user').doc(uid).update({
        'bulletinRoomCount': 1,
      });
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinRoomCount = documentSnapshot.get('bulletinRoomCount');

      this._bulletinRoomCount!.value = bulletinRoomCount;
    }
  }

  Future<void> bulletinCrewCountUpdate(uid) async {

    try {
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinCrewCount = documentSnapshot.get('bulletinCrewCount');
      int bulletinCrewCountPlus = bulletinCrewCount + 1;

      await ref.collection('user').doc(uid).update({
        'bulletinCrewCount': bulletinCrewCountPlus,
      });
      this._bulletinCrewCount!.value = bulletinCrewCountPlus;
    }catch(e){
      await ref.collection('user').doc(uid).update({
        'bulletinCrewCount': 1,
      });
      DocumentReference<Map<String, dynamic>> documentReference =
      ref.collection('user').doc(uid);

      final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
      await documentReference.get();

      int bulletinCrewCount = documentSnapshot.get('bulletinCrewCount');

      this._bulletinCrewCount!.value = bulletinCrewCount;
    }
  }



  Future<void> updateRepoUid(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(userMe).update({
      'repoUidList': FieldValue.arrayUnion([uid])
    });
    await ref.collection('user').doc(uid).update({
      'whoRepoMe': FieldValue.arrayUnion([userMe])
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
  Future<void> deleteRepoUid(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(userMe).update({
      'repoUidList': FieldValue.arrayRemove([uid])
    });
    await ref.collection('user').doc(uid).update({
      'whoRepoMe': FieldValue.arrayRemove([userMe])
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



  Future<void> updateResortNickname(index) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'resortNickname': nicknameList[index],
    });
    await getCurrentUser(auth.currentUser!.uid);
  } //선택한 리조트를 파베유저문서에 업데이트

  Future<void> updateMyCrew(crewID) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'myCrew': crewID,
    });
    await getCurrentUser(auth.currentUser!.uid);
  }

  Future<bool> checkDuplicateDisplayName(String displayName) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('user')
        .where('displayName', isEqualTo: displayName)
        .get();
    return querySnapshot.docs.isEmpty;
  }//회원 닉네임 중복방지

  Future<UserModel?> getFoundUser(uid) async{
    UserModel? foundUserModel= UserModel();
      if(uid!=null) {
         foundUserModel = await UserModel().getUserModel(uid);
        if (foundUserModel != null) {
          foundUserModel.uid = foundUserModel.uid!;
          foundUserModel.displayName = foundUserModel.displayName!;
          foundUserModel.userEmail = foundUserModel.userEmail!;
          foundUserModel.favoriteResort = foundUserModel.favoriteResort!;
          foundUserModel.instantResort = foundUserModel.instantResort!;
          foundUserModel.commentCount = foundUserModel.commentCount!;
          foundUserModel.fleaCount = foundUserModel.fleaCount!;
          foundUserModel.bulletinRoomCount = foundUserModel.bulletinRoomCount!;
          foundUserModel.profileImageUrl = foundUserModel.profileImageUrl!;
          foundUserModel.resortNickname = foundUserModel.resortNickname!;
          foundUserModel.phoneNum = foundUserModel.phoneNum!;
          foundUserModel.phoneAuth = foundUserModel.phoneAuth!;
          foundUserModel.likeUidList = foundUserModel.likeUidList!;
          foundUserModel.resistDate = foundUserModel.resistDate!;
          foundUserModel.newChat = foundUserModel.newChat!;
        } else {
          // handle the case where the userModel is null
        }
      } else{
      }
    return foundUserModel;
      }

  Future<void> updateFriendUid(uid) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(userMe).update({
      'friendUidList': FieldValue.arrayUnion([uid])
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List friendUidList = documentSnapshot.get('friendUidList');
    this._friendUidList!.value = friendUidList;
  }

  Future<void> createFriendDoc({
    required foundUid,
    required userEmail,
    required displayName,
    required favoriteResort,
    required profileImageUrl,
    required friendUidList,
    required resortNickname,
    required phoneNum,
    required resistDate,

  }) async {
    final User? user = auth.currentUser;

    await ref.collection('user').doc(uid).collection('friendList').doc(foundUid)
        .set({
      'uid': foundUid,
      'userEmail': userEmail,
      'displayName': displayName,
      'favoriteResort': favoriteResort,
      'profileImageUrl' : profileImageUrl,
      'friendUidList' : friendUidList,
      'resortNickname' : resortNickname,
      'phoneNum' : phoneNum,
      'resistDate' : resistDate,
    });

  }

  Future<void> updateFriendUidList() async {
    final  userMe = auth.currentUser!.uid;
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List friendUidList = documentSnapshot.get('friendUidList');
    this._friendUidList!.value = friendUidList;
  }

  Future<void> updateWhoResistMe({required friendUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(friendUid).update({
      'whoResistMe': FieldValue.arrayUnion([uid])
    });
  }

  Future<void> updateWhoResistMeBF({required friendUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(friendUid).update({
      'whoResistMeBF': FieldValue.arrayUnion([uid])
    });
  }
  Future<void> deleteWhoResistMeBF({required friendUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(friendUid).update({
      'whoResistMeBF': FieldValue.arrayRemove([uid])
    });
  }
  Future<void> deleteWhoResistMe({required friendUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(friendUid).update({
      'whoResistMe': FieldValue.arrayRemove([uid])
    });
    await ref.collection('user').doc(friendUid).update({
      'whoResistMeBF': FieldValue.arrayRemove([uid])
    });
  }

  Future<void> updateIsOnLiveOn() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'isOnLive': true,
    });
  }

  Future<void> updateIsOnLiveOff() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'isOnLive': false,
    });
  }

  Future<void> updateStateMsg(msg) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'stateMsg': msg,
    });
  }

  Future<void> updateInvitation({required friendUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(friendUid).update({
      'whoInviteMe': FieldValue.arrayUnion([uid])
    });
    await ref.collection('user').doc(uid).update({
      'whoIinvite': FieldValue.arrayUnion([friendUid])
    });

  }
  Future<void> updateInvitationAlarm({required friendUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('newAlarm')
        .doc(friendUid)
        .set({
      'uid': friendUid,
      'newInvited': true
    });
  }
  Future<void> deleteInvitation({required friendUid}) async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(friendUid).update({
      'whoInviteMe': FieldValue.arrayRemove([uid])
    });
    await ref.collection('user').doc(uid).update({
      'whoIinvite': FieldValue.arrayRemove([friendUid])
    });
    await ref.collection('user').doc(uid).update({
      'whoInviteMe': FieldValue.arrayRemove([friendUid])
    });
    await ref.collection('user').doc(friendUid).update({
      'whoIinvite': FieldValue.arrayRemove([uid])
    });
  }
  Future<void> deleteInvitationAlarm({required uid}) async {
    await ref.collection('newAlarm')
        .doc(uid)
        .update({
      'newInvited': false
    });
  }
  Future<void> updateFriend({required friendUid}) async {
    final  userMe = auth.currentUser!.uid;

    await ref.collection('user').doc(userMe).update({
      'friendUidList': FieldValue.arrayUnion([friendUid])
    });
    await ref.collection('user').doc(friendUid).update({
      'friendUidList': FieldValue.arrayUnion([userMe])
    });
    await ref.collection('user').doc(userMe).update({
      'whoResistMe': FieldValue.arrayUnion([friendUid])
    });
    await ref.collection('user').doc(friendUid).update({
      'whoResistMe': FieldValue.arrayUnion([userMe])
    });

    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List friendUidList = documentSnapshot.get('friendUidList');
    this._friendUidList!.value = friendUidList;
  }
  Future<void> deleteFriend({required friendUid}) async {
    final  userMe = auth.currentUser!.uid;

    await ref.collection('user').doc(userMe).update({
      'friendUidList': FieldValue.arrayRemove([friendUid])
    });
    await ref.collection('user').doc(friendUid).update({
      'friendUidList': FieldValue.arrayRemove([userMe])
    });
    await ref.collection('user').doc(userMe).update({
      'whoResistMe': FieldValue.arrayRemove([friendUid])
    });
    await ref.collection('user').doc(friendUid).update({
      'whoResistMe': FieldValue.arrayRemove([userMe])
    });
    await ref.collection('user').doc(userMe).update({
      'whoResistMeBF': FieldValue.arrayRemove([friendUid])
    });
    await ref.collection('user').doc(friendUid).update({
      'whoResistMeBF': FieldValue.arrayRemove([userMe])
    });

    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List friendUidList = documentSnapshot.get('friendUidList');
    this._friendUidList!.value = friendUidList;
  }

  Future<void> updateMyFriendCommentUidList({required friendUid}) async {
    final  userMe = auth.currentUser!.uid;
    await ref.collection('user').doc(userMe).update({
      'myFriendCommentUidList': FieldValue.arrayUnion([friendUid])
    });

    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(userMe);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    List myFriendCommentUidList = documentSnapshot.get('myFriendCommentUidList');
    this._myFriendCommentUidList!.value = myFriendCommentUidList;
  }

  Future<void> updateCommentCheck() async {
    final User? user = auth.currentUser;
    final uid = user!.uid;
    await ref.collection('user').doc(uid).update({
      'commentCheck': true,
    });
    DocumentReference<Map<String, dynamic>> documentReference =
    ref.collection('user').doc(uid);
    final DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
    await documentReference.get();
    bool commentCheck = documentSnapshot.get('commentCheck');
    this._commentCheck!.value = commentCheck;
  }









}

