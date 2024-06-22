import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_alarmCenterController.dart';
import 'package:com.snowlive/screens/more/friend/v_snowliveDetailPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';

import '../../../controller/vm_searchUserController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../model/m_alarmCenterModel.dart';
import '../../../model/m_rankingTierModel.dart';
import '../../../model/m_userModel.dart';

class SearchUserPage extends StatefulWidget {
  const SearchUserPage({Key? key}) : super(key: key);

  @override
  State<SearchUserPage> createState() => _SearchUserPageState();
}

class _SearchUserPageState extends State<SearchUserPage> {


  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var _nickName;
  bool? isCheckedDispName;
  String? foundUserUid;
  String? foundUserTier;
  String? foundUserCrewName;
  bool isFound=false;
  UserModel? foundUserModel;

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    //TODO: Dependency Injection**************************************************
    Get.put(SearchUserController(), permanent: true );
    SearchUserController _searchUserController = Get.find<SearchUserController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
    //TODO: Dependency Injection**************************************************
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Stack(
            children: [
              Scaffold(
                backgroundColor: Colors.white,
                appBar:AppBar(
                  backgroundColor: Colors.white,
                  leading: GestureDetector(
                    child: Image.asset(
                      'assets/imgs/icons/icon_snowLive_back.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                    onTap: () {
                      Get.back();
                    },
                  ),
                  elevation: 0.0,
                  titleSpacing: 0,
                  centerTitle: true,
                  title: Text('친구 검색',
                    style: TextStyle(
                        color: Color(0xFF111111),
                        fontWeight: FontWeight.bold,
                        fontSize: 20),
                  ),
                ),
                body: SingleChildScrollView(
                  child: Container(
                        color: Colors.white,
                        child:  Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Stack(
                              children: [
                                Form(
                                  key: _formKey,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: TextFormField(
                                      onFieldSubmitted: (val) async{
                                        setState(() {
                                          isLoading = true;
                                        });
                                        if (_formKey.currentState!.validate()) {
                                          _nickName = _textEditingController.text;
                                          CustomFullScreenDialog.showDialog();
                                          isCheckedDispName =  await _userModelController.checkDuplicateDisplayName(_nickName);
                                          if (isCheckedDispName == false) {

                                            try{
                                              foundUserUid =  await _searchUserController.searchUsersByDisplayName(_nickName);
                                              foundUserModel = await _userModelController.getFoundUser(foundUserUid!);
                                              foundUserTier = await _searchUserController.searchUsersTier(uid: foundUserUid);
                                              foundUserCrewName = await _searchUserController.searchUsersCrewName(uid: foundUserUid);
                                              isFound = true;
                                              CustomFullScreenDialog.cancelDialog();
                                            }catch(e){
                                              CustomFullScreenDialog.cancelDialog();
                                              Get.dialog(AlertDialog(
                                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                buttonPadding:
                                                EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                content: Text('존재하지 않는 활동명입니다.\n활동명 전체를 정확히 입력해주세요.',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 15),
                                                ),
                                                actions: [
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          child: Text(
                                                            '확인',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(0xff377EEA),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )),
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                  )
                                                ],
                                              ));
                                            }

                                          }
                                          else{
                                            CustomFullScreenDialog.cancelDialog();
                                            isFound = false;
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                              buttonPadding:
                                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              content: Text('존재하지 않는 활동명입니다.\n활동명 전체를 정확히 입력해주세요.',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          CustomFullScreenDialog.cancelDialog();
                                                        },
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(0xff377EEA),
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                )
                                              ],
                                            ));
                                          }
                                        }
                                        else {}
                                        setState(() {
                                          isLoading = false;
                                        });
                                      },
                                      autofocus: true,
                                      textAlignVertical: TextAlignVertical.center,
                                      cursorColor: Color(0xff949494),
                                      cursorHeight: 16,
                                      cursorWidth: 2,
                                      autovalidateMode: AutovalidateMode.onUserInteraction,
                                      controller: _textEditingController,
                                      strutStyle: StrutStyle(leading: 0.3),
                                      decoration: InputDecoration(
                                          floatingLabelBehavior: FloatingLabelBehavior.never,
                                          errorStyle: TextStyle(
                                            fontSize: 12,
                                          ),
                                          labelStyle: TextStyle(color: Color(0xff666666), fontSize: 15),
                                          hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                          hintText: '활동명 입력',
                                          labelText: '활동명 입력',
                                          contentPadding: EdgeInsets.only(
                                              top: 14, bottom: 8, left: 16, right: 16),
                                          fillColor: Color(0xFFEFEFEF),
                                          hoverColor: Colors.transparent,
                                          filled: true,
                                          focusColor: Colors.transparent,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          errorBorder:  OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.transparent),
                                          ),
                                          focusedBorder:  OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.transparent),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.transparent),
                                            borderRadius: BorderRadius.circular(6),
                                          )),
                                      validator: (val) {
                                        if (val!.length <= 20 && val.length >= 1) {
                                          return null;
                                        } else if (val.length == 0) {
                                          return '활동명을 입력해주세요.';
                                        } else {
                                          return '최대 입력 가능한 글자 수를 초과했습니다.';
                                        }
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: -4,
                                  top: 15,
                                  child: GestureDetector(
                                    onTap: () async{
                                      setState(() {
                                        isLoading = true;
                                      });
                                      if (_formKey.currentState!.validate()) {
                                        _nickName = _textEditingController.text;
                                        CustomFullScreenDialog.showDialog();
                                        isCheckedDispName =  await _userModelController.checkDuplicateDisplayName(_nickName);
                                        if (isCheckedDispName == false) {

                                          try{
                                            foundUserUid =  await _searchUserController.searchUsersByDisplayName(_nickName);
                                            foundUserModel = await _userModelController.getFoundUser(foundUserUid!);
                                            foundUserTier = await _searchUserController.searchUsersTier(uid: foundUserUid);
                                            foundUserCrewName = await _searchUserController.searchUsersCrewName(uid: foundUserUid);
                                            isFound = true;
                                            CustomFullScreenDialog.cancelDialog();
                                          }catch(e){
                                            CustomFullScreenDialog.cancelDialog();
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                              buttonPadding:
                                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              content: Text('존재하지 않는 활동명입니다.\n활동명 전체를 정확히 입력해주세요.',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: () {
                                                          CustomFullScreenDialog.cancelDialog();
                                                        },
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(0xff377EEA),
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                )
                                              ],
                                            ));
                                          }

                                        }
                                        else{
                                          CustomFullScreenDialog.cancelDialog();
                                          isFound = false;
                                          Get.dialog(AlertDialog(
                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                            buttonPadding:
                                            EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                            content: Text('존재하지 않는 활동명입니다.\n활동명 전체를 정확히 입력해주세요.',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                            actions: [
                                              Row(
                                                children: [
                                                  TextButton(
                                                      onPressed: () {
                                                        CustomFullScreenDialog.cancelDialog();
                                                      },
                                                      child: Text(
                                                        '확인',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xff377EEA),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      )),
                                                ],
                                                mainAxisAlignment: MainAxisAlignment.center,
                                              )
                                            ],
                                          ));
                                        }
                                      }
                                      else {}
                                      setState(() {
                                        isLoading = false;
                                      });
                                    },
                                    child: Padding(
                                        padding: const EdgeInsets.only(right: 20),
                                        child: Icon(Icons.search, color: Color(0xFF666666),),)
                                  ),
                                )
                              ],
                            ),
                              SizedBox(height: 20),
                              (isFound)
                                  ? GestureDetector(
                                onTap: (){
                                  if(isFound && foundUserModel!.displayName != 'SNOWLIVE') {
                                    Get.to(() => FriendDetailPage(
                                      uid: foundUserModel!.uid,
                                      favoriteResort: foundUserModel!.favoriteResort,));
                                  }else if(isFound && foundUserModel!.displayName == 'SNOWLIVE'){
                                    Get.to(()=>SnowliveDetailPage());
                                  }
                                },
                                    child: Center(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Color(0xFF3D83ED)
                                        ),
                                          width: 290,
                                          height: 457,
                                          child: Column(
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Container(
                                                    width: 270,
                                                    height: 270,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(8),
                                                    color: Colors.black12
                                                  ),
                                                  child:
                                                  (foundUserModel!.profileImageUrl!.isNotEmpty)
                                                      ? ExtendedImage.network(
                                                        '${foundUserModel!.profileImageUrl}',
                                                        enableMemoryCache: true,
                                                        borderRadius: BorderRadius.circular(8),
                                                        fit: BoxFit.cover,
                                                    loadStateChanged: (ExtendedImageState state) {
                                                      switch (state.extendedImageLoadState) {
                                                        case LoadState.loading:
                                                          return SizedBox.shrink();
                                                        case LoadState.completed:
                                                          return state.completedWidget;
                                                        case LoadState.failed:
                                                          return ExtendedImage.asset(
                                                            'assets/imgs/profile/img_profile_default_.png',
                                                            enableMemoryCache: true,
                                                            borderRadius: BorderRadius.circular(8),
                                                            fit: BoxFit.cover,
                                                          ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                        default:
                                                          return null;
                                                      }
                                                    },
                                                      )
                                                      : ExtendedImage.network(
                                                        'https://i.esdrop.com/d/f/yytYSNBROy/6rPYflzCCZ.png',
                                                        enableMemoryCache: true,
                                                        borderRadius: BorderRadius.circular(8),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 6),
                                                      child:
                                                      Row(
                                                        children: [
                                                          Text('${foundUserModel!.displayName}', style: TextStyle(
                                                              fontSize: 20,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.white
                                                          ),),
                                                          for(var rankingTier in rankingTierList)
                                                            if(foundUserTier == rankingTier.tierName)
                                                              ExtendedImage.asset(
                                                                enableMemoryCache:true,
                                                                rankingTier.badgeAsset,
                                                                scale: 8,
                                                              ),
                                                          if(foundUserTier == '')
                                                            Container()
                                                        ],
                                                      )

                                                    ),
                                                    SizedBox(height: 2,),
                                                    Text('${foundUserModel!.resortNickname}', style: TextStyle(
                                                        fontSize: 13,
                                                        fontWeight: FontWeight.normal,
                                                        color: Colors.white
                                                    ),),
                                                    SizedBox(height: 14,),
                                                    Container(
                                                      height: 1,
                                                      width: _size.width- 136,
                                                      color: Colors.black12,
                                                    ),
                                                    SizedBox(height: 14,),
                                                    Row(
                                                      children: [
                                                        Container(
                                                          width: 200,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('라이브 크루', style: TextStyle(
                                                                fontSize: 13,
                                                                fontWeight: FontWeight.normal,
                                                                color: Colors.white60,
                                                              ),),
                                                              (foundUserCrewName != '' && foundUserCrewName != null)
                                                              ? Text('$foundUserCrewName', style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white
                                                              ),)
                                                                  :Text('활동중인 크루가 없습니다.', style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Colors.white
                                                              ),)
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 14,),
                                                    Container(
                                                      height: 1,
                                                      width: _size.width- 136,
                                                      color: Colors.black12,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                      ),
                                    ),
                                  )
                                  : Container(
                                height: _size.height - 360,
                                    child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                    Center(child: Image.asset('assets/imgs/icons/icon_friend_search_illust.png', scale: 4, width: 180, height: 100,))
                                ],
                              ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                ),
              ),
              Positioned(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                right: 0,
                left: 0,
                child: SafeArea(
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                            child: Text('활동명 전체를 정확히 입력해야 검색이 완료됩니다.',
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                fontSize: 13,
                                color: Color(0xFF949494)
                            ),),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                    padding: EdgeInsets.only(top: 16, bottom: 16, right: 5),
                                    child: TextButton(
                                        onPressed: () {
                                          if(isFound && foundUserModel!.displayName != 'SNOWLIVE') {
                                            Get.to(() => FriendDetailPage(
                                              uid: foundUserModel!.uid,
                                              favoriteResort: foundUserModel!.favoriteResort,));
                                          }else if(isFound && foundUserModel!.displayName == 'SNOWLIVE'){
                                            Get.to(()=>SnowliveDetailPage());
                                          }
                                        },
                                        style: TextButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(6))),
                                          elevation: 0,
                                          splashFactory: InkRipple.splashFactory,
                                          minimumSize: Size(1000, 56),
                                          backgroundColor:
                                          (isFound) ? Color(0xff3D83ED).withOpacity(0.2) : Color(0xffDEDEDE),
                                        ),
                                        child: Text('프로필 보기',
                                          style: TextStyle(
                                              color: (isFound) ? Color(0xff3D83ED) : Color(0xffFFFFFF),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        )
                                    )),
                              ),
                              if(isFound && foundUserModel!.displayName != 'SNOWLIVE')
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 16, left: 5, top: 16),
                                  child: TextButton(
                                      onPressed: () async {
                                        if(isFound){
                                          Get.dialog(AlertDialog(
                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10.0)),
                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                            content: Text(
                                              '${foundUserModel!.displayName}님을 친구로 추가하시겠습니까?',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15),
                                            ),
                                            actions: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  (_userModelController.uid != foundUserModel!.uid)
                                                      ? ElevatedButton(
                                                      onPressed: () async{
                                                        await _userModelController.getCurrentUser(_userModelController.uid);
                                                        if(_userModelController.whoInviteMe!.contains(foundUserModel!.uid)){
                                                          Get.dialog(AlertDialog(
                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                            elevation: 0,
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                            content: Text('이미 요청받은 회원입니다.',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 15),
                                                            ),
                                                            actions: [
                                                              Row(
                                                                children: [
                                                                  TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        Get.back();
                                                                      },
                                                                      child: Text('확인',
                                                                        style: TextStyle(
                                                                          fontSize: 15,
                                                                          color: Color(0xFF949494),
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      )),
                                                                ],
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                              )
                                                            ],
                                                          ));
                                                        }else if(_userModelController.friendUidList!.contains(foundUserModel!.uid)){
                                                          Get.dialog(AlertDialog(
                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                            elevation: 0,
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(10.0)),
                                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                            content: Text('이미 추가된 친구입니다.',
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 15),
                                                            ),
                                                            actions: [
                                                              Row(
                                                                children: [
                                                                  TextButton(
                                                                      onPressed: () {
                                                                        Navigator.pop(context);
                                                                        Get.back();
                                                                      },
                                                                      child: Text('확인',
                                                                        style: TextStyle(fontSize: 15,
                                                                          color: Color(0xFF949494),
                                                                          fontWeight: FontWeight.bold,
                                                                        ),
                                                                      )),
                                                                ],
                                                                mainAxisAlignment: MainAxisAlignment.end,
                                                              )
                                                            ],
                                                          ));
                                                        } else{
                                                          CustomFullScreenDialog.showDialog();
                                                          await _userModelController.updateInvitation(friendUid: foundUserModel!.uid);
                                                          await _userModelController.updateInvitationAlarm(friendUid: foundUserModel!.uid);
                                                          String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendRequestKey];
                                                          await _alarmCenterController.sendAlarm(
                                                              alarmCount: 'friend',
                                                              receiverUid: foundUserModel!.uid,
                                                              senderUid: _userModelController.uid,
                                                              senderDisplayName: _userModelController.displayName,
                                                              timeStamp: Timestamp.now(),
                                                              category: alarmCategory,
                                                              msg: '${_userModelController.displayName}님으로부터 $alarmCategory이 도착했습니다.',
                                                              content: '',
                                                              docName: '',
                                                              liveTalk_uid : '',
                                                              liveTalk_commentCount : '',
                                                              bulletinRoomUid :'',
                                                              bulletinRoomCount :'',
                                                              bulletinCrewUid : '',
                                                              bulletinCrewCount : '',
                                                              bulletinFreeUid : '',
                                                              bulletinFreeCount : '',
                                                              bulletinEventUid : '',
                                                              bulletinEventCount : '',
                                                              originContent: 'friend',
                                                              bulletinLostUid: '',
                                                              bulletinLostCount: ''
                                                          );
                                                          await _userModelController.getCurrentUser(_userModelController.uid);
                                                          Navigator.pop(context);
                                                          CustomFullScreenDialog.cancelDialog();
                                                          Get.snackbar(
                                                            '친구요청 완료',
                                                            '요청중인 목록은 친구목록 페이지에서 확인하실 수 있습니다.',
                                                            margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                                            snackPosition: SnackPosition.BOTTOM,
                                                            backgroundColor: Colors.black87,
                                                            colorText: Colors.white,
                                                            duration: Duration(milliseconds: 3000),
                                                          );
                                                        }

                                                      },
                                                      style: TextButton.styleFrom(
                                                          shape: const RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(6))),
                                                          elevation: 0,
                                                          splashFactory: InkRipple.splashFactory,
                                                          minimumSize: Size(1000, 48),
                                                          backgroundColor: Color(0xff377EEA)

                                                      ),
                                                      child: Text(
                                                        '친구 요청',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          color: Color(0xffFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ))
                                                      : Container(),
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4),
                                                    child: ElevatedButton(
                                                        onPressed: () async{
                                                          Navigator.pop(context);
                                                        },
                                                        style: TextButton.styleFrom(
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6))),
                                                            elevation: 0,
                                                            splashFactory: InkRipple.splashFactory,
                                                            minimumSize: Size(1000, 48),
                                                            backgroundColor: Color(0xffFFFFFF)

                                                        ),
                                                        child: Text('취소',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(0xff949494),
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        )),
                                                  )
                                                ],
                                              )
                                            ],
                                          ));
                                        }

                                      },
                                      style: TextButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6))),
                                          elevation: 0,
                                          splashFactory: InkRipple.splashFactory,
                                          minimumSize: Size(1000, 56),
                                          backgroundColor: (isFound) ? Color(0xff3D83ED) : Color(0xffDEDEDE)),
                                      child: Text(
                                        '친구 추가하기',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                  ),
                                ),
                              ),
                              if(!isFound)
                              Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 16, left: 5, top: 16),
                                    child: TextButton(
                                        onPressed: () async {
                                          if(isFound){
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0)),
                                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              content: Text(
                                                '${foundUserModel!.displayName}님을 친구로 추가하시겠습니까?',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    (_userModelController.uid != foundUserModel!.uid)
                                                        ? ElevatedButton(
                                                        onPressed: () async{
                                                          await _userModelController.getCurrentUser(_userModelController.uid);
                                                          if(_userModelController.whoInviteMe!.contains(foundUserModel!.uid)){
                                                            Get.dialog(AlertDialog(
                                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                              content: Text('이미 요청받은 회원입니다.',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 15),
                                                              ),
                                                              actions: [
                                                                Row(
                                                                  children: [
                                                                    TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                          Get.back();
                                                                        },
                                                                        child: Text('확인',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Color(0xFF949494),
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        )),
                                                                  ],
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                )
                                                              ],
                                                            ));
                                                          }else if(_userModelController.friendUidList!.contains(foundUserModel!.uid)){
                                                            Get.dialog(AlertDialog(
                                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10.0)),
                                                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                              content: Text('이미 추가된 친구입니다.',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 15),
                                                              ),
                                                              actions: [
                                                                Row(
                                                                  children: [
                                                                    TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                          Get.back();
                                                                        },
                                                                        child: Text('확인',
                                                                          style: TextStyle(fontSize: 15,
                                                                            color: Color(0xFF949494),
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        )),
                                                                  ],
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                )
                                                              ],
                                                            ));
                                                          } else{
                                                            CustomFullScreenDialog.showDialog();
                                                            await _userModelController.updateInvitation(friendUid: foundUserModel!.uid);
                                                            await _userModelController.updateInvitationAlarm(friendUid: foundUserModel!.uid);
                                                            String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.friendRequestKey];
                                                            await _alarmCenterController.sendAlarm(
                                                                alarmCount: 'friend',
                                                                receiverUid: foundUserModel!.uid,
                                                                senderUid: _userModelController.uid,
                                                                senderDisplayName: _userModelController.displayName,
                                                                timeStamp: Timestamp.now(),
                                                                category: alarmCategory,
                                                                msg: '${_userModelController.displayName}님으로부터 $alarmCategory이 도착했습니다.',
                                                                content: '',
                                                                docName: '',
                                                                liveTalk_uid : '',
                                                                liveTalk_commentCount : '',
                                                                bulletinRoomUid :'',
                                                                bulletinRoomCount :'',
                                                                bulletinCrewUid : '',
                                                                bulletinCrewCount : '',
                                                                bulletinFreeUid : '',
                                                                bulletinFreeCount : '',
                                                                bulletinEventUid : '',
                                                                bulletinEventCount : '',
                                                                originContent: 'friend',
                                                                bulletinLostUid: '',
                                                                bulletinLostCount: ''
                                                            );
                                                            await _userModelController.getCurrentUser(_userModelController.uid);
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.cancelDialog();
                                                            Get.snackbar(
                                                              '친구요청 완료',
                                                              '요청중인 목록은 친구목록 페이지에서 확인하실 수 있습니다.',
                                                              margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                                              snackPosition: SnackPosition.BOTTOM,
                                                              backgroundColor: Colors.black87,
                                                              colorText: Colors.white,
                                                              duration: Duration(milliseconds: 3000),
                                                            );
                                                          }

                                                        },
                                                        style: TextButton.styleFrom(
                                                            shape: const RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.all(Radius.circular(6))),
                                                            elevation: 0,
                                                            splashFactory: InkRipple.splashFactory,
                                                            minimumSize: Size(1000, 48),
                                                            backgroundColor: Color(0xff377EEA)

                                                        ),
                                                        child: Text(
                                                          '친구 요청',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(0xffFFFFFF),
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ))
                                                        : Container(),
                                                    Padding(
                                                      padding: const EdgeInsets.only(top: 4),
                                                      child: ElevatedButton(
                                                          onPressed: () async{
                                                            Navigator.pop(context);
                                                          },
                                                          style: TextButton.styleFrom(
                                                              shape: const RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.all(Radius.circular(6))),
                                                              elevation: 0,
                                                              splashFactory: InkRipple.splashFactory,
                                                              minimumSize: Size(1000, 48),
                                                              backgroundColor: Color(0xffFFFFFF)

                                                          ),
                                                          child: Text('취소',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(0xff949494),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ));
                                          }

                                        },
                                        style: TextButton.styleFrom(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(6))),
                                            elevation: 0,
                                            splashFactory: InkRipple.splashFactory,
                                            minimumSize: Size(1000, 56),
                                            backgroundColor: (isFound) ? Color(0xff3D83ED) : Color(0xffDEDEDE)),
                                        child: Text(
                                          '친구 추가하기',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        )
                                    ),
                                  ),
                                ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
