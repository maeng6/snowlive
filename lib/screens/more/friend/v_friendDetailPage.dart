import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:snowlive3/controller/vm_DialogController_resortHome.dart';
import 'package:snowlive3/controller/vm_friendsCommentController.dart';
import 'package:snowlive3/controller/vm_liveMapController.dart';
import 'package:snowlive3/controller/vm_resortModelController.dart';
import 'package:snowlive3/controller/vm_seasonController.dart';
import 'package:snowlive3/screens/comments/v_profileImageScreen.dart';
import '../../../controller/vm_liveCrewModelController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../../LiveCrew/v_crewDetailPage_screen.dart';
import '../v_setProfileImage_moreTab.dart';

class FriendDetailPage extends StatefulWidget {
  FriendDetailPage({Key? key, required this.uid,}) : super(key: key);

  String? uid;

  @override
  State<FriendDetailPage> createState() => _FriendDetailPageState();
}

class _FriendDetailPageState extends State<FriendDetailPage> {

  var _stream;
  final _formKeyProfile = GlobalKey<FormState>();
  final _formKeyProfile2 = GlobalKey<FormState>();
  final _formKeyProfile3 = GlobalKey<FormState>();
  final _stateMsgController = TextEditingController();
  final _displayNameController = TextEditingController();
  var _newComment = '';
  bool edit= false;
  String _initStateMsg='';
  String _initialDisplayName='';

  @override
  void initState() {
    _stream = newStream();
    // TODO: implement initState
    super.initState();
    _stateMsgController.text = '';
    _initStateMsg = _userModelController.stateMsg!;
    _initialDisplayName = _userModelController.displayName!;
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('user')
        .doc('${widget.uid}')
        .collection('friendsComment')
        .snapshots();
  }

  //TODO: Dependency Injection**************************************************
  DialogController _dialogController = Get.find<DialogController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  UserModelController _userModelController = Get.find<UserModelController>();
  FriendsCommentModelController _friendsCommentModelController = Get.find<FriendsCommentModelController>();
  LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
  LiveMapController _liveMapController = Get.find<LiveMapController>();

  //TODO: Dependency Injection**************************************************

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
          backgroundColor: Colors.white,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            leading:
            (edit == false)
                ? GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(top: _statusBarSize - 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/imgs/icons/icon_snowLive_back.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                  ],
                ),
              ),
              onTap: () {
                // Navigator.popUntil(context, (route) => route.isFirst);
                // Navigator.push(context, MaterialPageRoute(builder: (context) => FriendListPage()));
                Get.back();
              },
            )
                : GestureDetector(
              child: Padding(
                padding: EdgeInsets.only(top: _statusBarSize - 30, left: 12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text('취소', style: TextStyle(fontSize: 16, color: Color(0xFF111111), fontWeight: FontWeight.bold),),
                    ),
                  ],
                ),
              ),
              onTap: () {
                setState(() {
                  edit=false;
                });
              },
            ),
            actions: [
              if(edit == true)
                GestureDetector(
                  child: Padding(
                    padding: EdgeInsets.only(top: _statusBarSize - 30, right: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text('완료', style: TextStyle(fontSize: 16, color: Color(0xFF111111), fontWeight: FontWeight.bold),),
                        ),
                      ],
                    ),
                  ),
                  onTap: () async{
                    CustomFullScreenDialog.showDialog();
                    try {
                      if(_displayNameController.text == '' || _displayNameController.text ==null) {
                        await _userModelController.updateNickname(
                            _userModelController.displayName);
                      }else{
                        await _userModelController.updateNickname(
                            _displayNameController.text);
                      }
                      await _userModelController.updateStateMsg(_stateMsgController.text);
                      await _userModelController.getCurrentUser(_userModelController.uid);
                      _stateMsgController.clear();
                      _displayNameController.clear();
                    } catch (e) {
                      CustomFullScreenDialog.cancelDialog();
                    }
                    setState(() {
                      edit=false;
                    });
                    CustomFullScreenDialog.cancelDialog();
                  },
                ),
            ],
            elevation: 0.0,
            titleSpacing: 0,
            centerTitle: true,
            toolbarHeight: 58.0, // 이 부분은 AppBar의 높이를 조절합니다.
          ),
          body: StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('user')
        .where('uid', isEqualTo: widget.uid )
        .snapshots(),
    builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
      
      if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator(),);}

      if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
        return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            children: [
              Center(
                child: Icon(Icons.no_accounts_outlined,
                  size: 80,
                ),
              ),
              Center(
                child: Text('이미 탈퇴한 회원입니다',
                style: TextStyle(
                  fontSize: 16
                ),
                ),
              ),
            ],
          ),
        ],
      );
      }

      final friendDocs = snapshot.data!.docs;
      final List whoInviteMe = friendDocs[0]['whoInviteMe'];

      return Padding(
        padding: EdgeInsets.only(top: _statusBarSize + 58),
        child: Stack(
          children: [
            Container(
              height: _size.height - 160,
              width: _size.width,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Color(0xFFEEEEF5)
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 16),
                          padding: EdgeInsets.only(top: 30, bottom: 16),
                          child: Column(
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    (friendDocs[0]['profileImageUrl'].isNotEmpty)
                                        ? GestureDetector(
                                      onTap: () {
                                        Get.to(() => ProfileImagePage(
                                            CommentProfileUrl: friendDocs[0]['profileImageUrl']));
                                      },
                                      child: Container(
                                          width: 100,
                                          height: 100,
                                          child: ExtendedImage.network(
                                            friendDocs[0]['profileImageUrl'],
                                            enableMemoryCache: true,
                                            shape: BoxShape.circle,
                                            borderRadius: BorderRadius.circular(8),
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                          )),
                                    )
                                        : GestureDetector(
                                      onTap: () {
                                        Get.to(() => ProfileImagePage(
                                            CommentProfileUrl: ''));
                                      },
                                      child: Container(
                                        width: 100,
                                        height: 100,
                                        child: ExtendedImage.asset(
                                          'assets/imgs/profile/img_profile_default_circle.png',
                                          enableMemoryCache: true,
                                          shape: BoxShape.circle,
                                          borderRadius: BorderRadius.circular(8),
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        (edit == true)
                                            ? Text(
                                          _initialDisplayName, style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111111)
                                        ),)
                                            : Text(
                                          '${friendDocs[0]['displayName']}',
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF111111)
                                          ),),
                                        if(edit == true)
                                          GestureDetector(
                                              onTap: () {
                                                _displayNameController.clear();
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (BuildContext context) {
                                                    return SafeArea(
                                                      child: Container(
                                                        height: 240,
                                                        child: Padding(
                                                          padding: EdgeInsets.only(
                                                              left: 20, right: 20),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment
                                                                .start,
                                                            mainAxisAlignment: MainAxisAlignment
                                                                .start,
                                                            children: [
                                                              SizedBox(
                                                                height: 30,
                                                              ),
                                                              Text(
                                                                '변경할 활동명을 입력해주세요.',
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight
                                                                        .bold,
                                                                    color: Color(
                                                                        0xFF111111)),
                                                              ),
                                                              SizedBox(
                                                                height: 20,
                                                              ),
                                                              Container(
                                                                height: 100,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                      .start,
                                                                  mainAxisAlignment: MainAxisAlignment
                                                                      .start,
                                                                  children: [
                                                                    Form(
                                                                      key: _formKeyProfile,
                                                                      child:
                                                                      Container(
                                                                        height: 56,
                                                                        child: TextFormField(
                                                                          cursorColor: Color(
                                                                              0xff377EEA),
                                                                          cursorHeight: 16,
                                                                          cursorWidth: 2,
                                                                          autovalidateMode:
                                                                          AutovalidateMode
                                                                              .onUserInteraction,
                                                                          controller: _displayNameController..text = _initialDisplayName,
                                                                          strutStyle:
                                                                          StrutStyle(
                                                                              leading: 0.3),
                                                                          decoration: InputDecoration(
                                                                              errorStyle: TextStyle(
                                                                                fontSize: 12,
                                                                              ),
                                                                              hintStyle: TextStyle(
                                                                                  color: Color(
                                                                                      0xff949494),
                                                                                  fontSize: 16),
                                                                              hintText: '활동명 입력',
                                                                              labelText: '활동명',
                                                                              contentPadding: EdgeInsets
                                                                                  .only(
                                                                                  top: 20,
                                                                                  bottom: 20,
                                                                                  left: 20,
                                                                                  right: 20),
                                                                              border: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                    color: Color(
                                                                                        0xFFDEDEDE)),
                                                                                borderRadius: BorderRadius
                                                                                    .circular(
                                                                                    6),
                                                                              ),
                                                                              enabledBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                    color: Color(
                                                                                        0xFFDEDEDE)),
                                                                                borderRadius: BorderRadius
                                                                                    .circular(
                                                                                    6),
                                                                              ),
                                                                              errorBorder: OutlineInputBorder(
                                                                                borderSide: BorderSide(
                                                                                    color: Color(
                                                                                        0xFFFF3726)),
                                                                                borderRadius: BorderRadius
                                                                                    .circular(
                                                                                    6),
                                                                              )),
                                                                          validator:
                                                                              (
                                                                              val) {
                                                                            if (val!
                                                                                .length <=
                                                                                20 &&
                                                                                val
                                                                                    .length >=
                                                                                    1) {
                                                                              return null;
                                                                            } else
                                                                            if (val
                                                                                .length ==
                                                                                0) {
                                                                              return '닉네임을 입력해주세요.';
                                                                            } else {
                                                                              return '최대 글자 수를 초과했습니다.';
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    SizedBox(
                                                                      height: 6,
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left: 19),
                                                                      child: Text(
                                                                        '최대 20글자까지 입력 가능합니다.',
                                                                        style: TextStyle(
                                                                            color: Color(
                                                                                0xff949494),
                                                                            fontSize: 12),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Expanded(
                                                                    child: InkWell(
                                                                      child: ElevatedButton(
                                                                        onPressed: () {
                                                                          _displayNameController
                                                                              .text =
                                                                          _userModelController
                                                                              .displayName!;
                                                                          Navigator
                                                                              .pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                          '취소',
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight
                                                                                  .bold),
                                                                        ),
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                            splashFactory:
                                                                            InkRipple
                                                                                .splashFactory,
                                                                            elevation: 0,
                                                                            minimumSize: Size(
                                                                                100,
                                                                                56),
                                                                            backgroundColor: Color(
                                                                                0xff555555),
                                                                            padding: EdgeInsets
                                                                                .symmetric(
                                                                                horizontal: 0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Expanded(
                                                                    child: InkWell(
                                                                      child:
                                                                      ElevatedButton(
                                                                        onPressed: () {
                                                                          if (_formKeyProfile
                                                                              .currentState!
                                                                              .validate()) {
                                                                            setState(() {
                                                                              _initialDisplayName =
                                                                                  _displayNameController
                                                                                      .text;
                                                                            });
                                                                            FocusScope
                                                                                .of(
                                                                                context)
                                                                                .unfocus();
                                                                            Navigator
                                                                                .pop(
                                                                                context);
                                                                          } else {
                                                                            Get
                                                                                .snackbar(
                                                                                '입력 실패',
                                                                                '올바른 활동명을 입력해주세요.',
                                                                                snackPosition: SnackPosition
                                                                                    .BOTTOM,
                                                                                margin: EdgeInsets
                                                                                    .only(
                                                                                    right: 20,
                                                                                    left: 20,
                                                                                    bottom: 12),
                                                                                backgroundColor: Colors
                                                                                    .black87,
                                                                                colorText: Colors
                                                                                    .white,
                                                                                duration:
                                                                                Duration(
                                                                                    milliseconds: 3000));
                                                                          }
                                                                        },
                                                                        child: Text(
                                                                          '변경',
                                                                          style: TextStyle(
                                                                              color: Colors
                                                                                  .white,
                                                                              fontSize: 15,
                                                                              fontWeight: FontWeight
                                                                                  .bold),
                                                                        ),
                                                                        style: TextButton
                                                                            .styleFrom(
                                                                            splashFactory:
                                                                            InkRipple
                                                                                .splashFactory,
                                                                            elevation: 0,
                                                                            minimumSize: Size(
                                                                                100,
                                                                                56),
                                                                            backgroundColor: Color(
                                                                                0xff2C97FB),
                                                                            padding: EdgeInsets
                                                                                .symmetric(
                                                                                horizontal: 0)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 4),
                                                child: Image.asset(
                                                  'assets/imgs/icons/icon_edit_pencil.png',
                                                  height: 20,
                                                  width: 20,
                                                ),
                                              )),
                                      ],
                                    ), //활동명//상태메시지
                                    SizedBox(
                                      height: 4,
                                    ),
                                    (edit == true)
                                        ? Padding(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 2),
                                      child: Container(
                                        width: _size.width - 64,
                                        height: 36,
                                        child: TextFormField(
                                          key: _formKeyProfile2,
                                          cursorColor: Color(0xff949494),
                                          controller: _stateMsgController,
                                          strutStyle: StrutStyle(leading: 0.3),
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          maxLines: 1,
                                          enableSuggestions: false,
                                          autocorrect: false,
                                          textInputAction: TextInputAction.newline,
                                          onTap: () {
                                            // 텍스트 필드 선택 시 커서를 맨 오른쪽으로 이동
                                            _stateMsgController.selection =
                                                TextSelection.fromPosition(
                                                    TextPosition(
                                                        offset: _stateMsgController
                                                            .text.length));
                                          },
                                          decoration: InputDecoration(
                                            suffixIcon: TextButton(
                                              onPressed: () {
                                                FocusScope.of(context).unfocus();
                                              },
                                              child: Text('', style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF377EEA))),
                                            ),
                                            floatingLabelBehavior: FloatingLabelBehavior
                                                .never,
                                            labelText: '상태메시지',
                                            labelStyle: TextStyle(
                                              fontSize: 14, fontWeight: FontWeight
                                                .normal, color: Color(0xFF666666),
                                            ),
                                            hoverColor: Colors.transparent,
                                            filled: true,
                                            focusColor: Colors.transparent,
                                            errorStyle: TextStyle(
                                              fontSize: 12,
                                            ),
                                            hintStyle: TextStyle(color: Color(
                                                0xffb7b7b7), fontSize: 14),
                                            hintText: '상태메시지를 입력해주세요.',
                                            contentPadding: EdgeInsets.only(
                                                left: 12, right: 12),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.transparent),
                                              borderRadius: BorderRadius.circular(
                                                  6),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.transparent),
                                              borderRadius: BorderRadius.circular(
                                                  6),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.transparent),
                                              borderRadius: BorderRadius.circular(
                                                  6),
                                            ),
                                            errorBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFFF3726)),
                                              borderRadius: BorderRadius.circular(
                                                  6),
                                            ),
                                          ),
                                          validator: (val) {
                                            if (val!.length <= 20) {
                                              return null;
                                            } else {
                                              return '20자 미만으로 적어주세요.';
                                            }
                                          },
                                        ),

                                      ),
                                    )
                                        : Padding(
                                      padding: const EdgeInsets.only(bottom: 26),
                                      child: Text('${friendDocs[0]['stateMsg']}',
                                        style: TextStyle(fontSize: 14,
                                            color: Color(0xFF949494)),),
                                    ),
                                  ],
                                ),
                              ),
                              (widget.uid == _userModelController.uid)
                                  ? Padding(
                                padding: const EdgeInsets.only(top: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(onPressed: () {
                                      setState(() {
                                        _initStateMsg =
                                        _userModelController.stateMsg!;
                                        _initialDisplayName =
                                        _userModelController.displayName!;
                                        edit = true;
                                      });
                                      print(_displayNameController.text);
                                      print(_stateMsgController.text);
                                    }, child: Text('프로필 수정', style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF666666)
                                    ),
                                    ),
                                      style: TextButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6))),
                                          elevation: 0,
                                          splashFactory: InkRipple.splashFactory,
                                          minimumSize: Size(
                                              _size.width / 2 - 36, 38),
                                          backgroundColor:
                                          Color(0xffffffff)),

                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(onPressed: () {
                                      Get.to(() => SetProfileImage_moreTab());
                                    }, child: Text('이미지 수정', style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF666666)
                                    ),
                                    ),
                                      style: TextButton.styleFrom(
                                          shape: const RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(6))),
                                          elevation: 0,
                                          splashFactory: InkRipple.splashFactory,
                                          minimumSize: Size(
                                              _size.width / 2 - 36, 38),
                                          backgroundColor:
                                          Color(0xffffffff)),

                                    ),
                                    // SizedBox(
                                    //   width: 40,
                                    // ),
                                    // Column(
                                    //   children: [
                                    //     IconButton(
                                    //         onPressed: (){},
                                    //         iconSize: 32,
                                    //         icon: Image.asset('assets/imgs/icons/icon_edit_livecrew.png')
                                    //     ),
                                    //     Text('라이브 크루', style: TextStyle(fontSize: 13, color: Color(0xFF111111)),)
                                    //   ],
                                    // ),
                                  ],
                                ),
                              ) //프로필수정 + 라이브크루
                                  : StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('user')
                                    .where(
                                    'uid', isEqualTo: _userModelController.uid)
                                    .snapshots(),
                                builder: (context, AsyncSnapshot<
                                    QuerySnapshot<Map<String, dynamic>>> snapshot) {
                                  if (!snapshot.hasData || snapshot.data == null) {}
                                  else if (snapshot.data!.docs.isNotEmpty) {
                                    final userDocs = snapshot.data!.docs;
                                    return
                                      (userDocs[0]['friendUidList'].contains(
                                          widget.uid))
                                          ? Container() //빈칸
                                          : Padding(
                                        padding: const EdgeInsets.only(top: 30),
                                        child:
                                        (whoInviteMe.contains(_userModelController.uid))
                                            ? GestureDetector(
                                          onTap: () {
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0)),
                                              buttonPadding:
                                              EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              content: Text(
                                                '이미 요청중입니다.',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          '확인',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xff377EEA),
                                                            fontWeight: FontWeight
                                                                .bold,
                                                          ),
                                                        )),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                )
                                              ],
                                            ));
                                          },
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Image.asset(
                                                      'assets/imgs/icons/icon_profile_friend_add.png',
                                                      height: _size.width / 10,
                                                      width: _size.width / 10,
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text('친구등록 요청중')
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                            : GestureDetector(
                                          onTap: () {
                                            Get.dialog(AlertDialog(
                                              contentPadding: EdgeInsets.only(
                                                  bottom: 0,
                                                  left: 20,
                                                  right: 20,
                                                  top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(
                                                      10.0)),
                                              buttonPadding:
                                              EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 0),
                                              content: Text(
                                                '친구등록 요청을 보내시겠습니까?',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15),
                                              ),
                                              actions: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: () async {
                                                          await _userModelController
                                                              .getCurrentUser(
                                                              _userModelController
                                                                  .uid);
                                                          if (_userModelController
                                                              .whoInviteMe!
                                                              .contains(
                                                              widget.uid)) {
                                                            Get.dialog(AlertDialog(
                                                              contentPadding: EdgeInsets
                                                                  .only(
                                                                  bottom: 0,
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 30),
                                                              elevation: 0,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                      10.0)),
                                                              buttonPadding:
                                                              EdgeInsets.symmetric(
                                                                  horizontal: 20,
                                                                  vertical: 0),
                                                              content: Text(
                                                                '이미 요청받은 회원입니다.',
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight
                                                                        .w600,
                                                                    fontSize: 15),
                                                              ),
                                                              actions: [
                                                                Row(
                                                                  children: [
                                                                    TextButton(
                                                                        onPressed: () {
                                                                          Navigator
                                                                              .pop(
                                                                              context);
                                                                          Get
                                                                              .back();
                                                                        },
                                                                        child: Text(
                                                                          '확인',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Color(
                                                                                0xFF949494),
                                                                            fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                          ),
                                                                        )),
                                                                  ],
                                                                  mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                                )
                                                              ],
                                                            ));
                                                          } else {
                                                            CustomFullScreenDialog.showDialog();
                                                            await _userModelController.updateInvitation(friendUid: widget.uid);
                                                            await _userModelController.updateInvitationAlarm(friendUid: widget.uid);
                                                            await _userModelController.getCurrentUser(_userModelController.uid);
                                                            //await _userModelController.updateFriendUid(widget.uid);
                                                            //await _userModelController.updateWhoResistMe(friendUid: widget.uid!);
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.cancelDialog();
                                                          }
                                                        },
                                                        child: Text(
                                                          '보내기',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xff377EEA),
                                                            fontWeight: FontWeight
                                                                .bold,
                                                          ),
                                                        )),
                                                    TextButton(
                                                        onPressed: () async {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          '취소',
                                                          style: TextStyle(
                                                            fontSize: 15,
                                                            color: Color(
                                                                0xff377EEA),
                                                            fontWeight: FontWeight
                                                                .bold,
                                                          ),
                                                        )),
                                                  ],
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                )
                                              ],
                                            ));
                                          },
                                          child: Container(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Column(
                                                  children: [
                                                    Image.asset(
                                                      'assets/imgs/icons/icon_profile_friend_add.png',
                                                      height: _size.width / 10,
                                                      width: _size.width / 10,
                                                    ),
                                                    SizedBox(height: 5,),
                                                    Text('친구로 등록하기')
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ); //친구로등록하기
                                  }
                                  else if (snapshot.connectionState ==
                                      ConnectionState.waiting) {}
                                  return Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },),
                            ],
                          ),
                        ),
                        Positioned(
                            top: 15,
                            right: 35,
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 3, bottom: 3, left: 10, right: 10),
                              decoration: BoxDecoration(
                                color: Color(0xFFDEDEEF),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: Text(
                                '${_resortModelController.getResortName(_userModelController.resortNickname!)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF626274),
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                        ),
                      ],
                    ), //프사 + 닉네임 + 상메
                    SizedBox(height: 30,),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('가입한 라이브 크루',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF111111)
                          ),)),
                    SizedBox(height: 10),
                    GestureDetector(
                      onTap: () async {
                        CustomFullScreenDialog.showDialog();
                        await _liveCrewModelController.getCurrnetCrew(friendDocs[0]['liveCrew']);
                        CustomFullScreenDialog.cancelDialog();
                        Get.to(()=>CrewDetailPage_screen());
                      },
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('liveCrew')
                              .where('memberUidList', arrayContains: widget.uid)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<dynamic> snapshot) {
                            if (!snapshot.hasData || snapshot.data == null) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text('소속된 크루가 없습니다.', style: TextStyle(
                                    fontSize: 13, color: Color(0xFF666666)),),
                              );
                            }
                            else if (snapshot.connectionState ==
                                ConnectionState.waiting) {}
                            else if (snapshot.data!.docs.isNotEmpty) {
                              final crewDocs = snapshot.data!.docs[0];
                              return Container(
                                margin: EdgeInsets.only(left: 16, right: 16,),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Color(crewDocs['crewColor'])
                                ),
                                child: Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('${crewDocs['crewName']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                            color: Color(0xFFFFFFFF)
                                          ),
                                          ),
                                          Text('${_userModelController.displayName}',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFFFFFFFF)
                                            ),
                                          )
                                        ],
                                      ),
                                      Expanded(child: SizedBox()),
                                      (crewDocs['profileImageUrl'].isNotEmpty)
                                          ? GestureDetector(
                                        onTap: () {
                                          Get.to(() => ProfileImagePage(
                                              CommentProfileUrl: crewDocs['profileImageUrl']));
                                        },
                                        child: Container(
                                            width: 90,
                                            height: 90,
                                            child: ExtendedImage.network(
                                              crewDocs['profileImageUrl'],
                                              enableMemoryCache: true,
                                              shape: BoxShape.rectangle,
                                              borderRadius: BorderRadius.circular(16),
                                              fit: BoxFit.cover,
                                            )),
                                      )
                                          : GestureDetector(
                                        onTap: () {
                                          Get.to(() => ProfileImagePage(
                                              CommentProfileUrl: ''));
                                        },
                                        child: Container(
                                          width: 90,
                                          height: 90,
                                          child: ExtendedImage.asset(
                                            'assets/imgs/profile/img_profile_default_.png',
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(16),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              );

                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10,left: 16),
                              child: Text('소속된 크루가 없습니다.', style: TextStyle(
                                  fontSize: 13, color: Color(0xFF666666)),),
                            );
                          },
                        ),
                    ), //소속된크루
                    SizedBox(height: 30,),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text('슬로프 라이딩 횟수',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF111111)
                              ),),
                            Expanded(child: SizedBox()),
                            GestureDetector(
                              onTap: (){},
                              child: Text('자세히 보기',
                              style: TextStyle(
                                fontSize: 13
                              ),
                              ),
                            )
                          ],
                        )),
                    SizedBox(height: 10,),
                    Container(
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Ranking')
                              .doc('${_seasonController.currentSeason}')
                              .collection('${friendDocs[0]['favoriteResort']}')
                              .doc("${friendDocs[0]['uid']}")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {

                            if (snapshot.hasError) {
                              return Text("오류가 발생했습니다");
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Lottie.asset('assets/json/loadings_wht_final.json');
                            }

                            Map<String, dynamic>? data =
                            snapshot.data!.data() as Map<String, dynamic>?;

                            Map<String, dynamic>? passCountData =
                            data?['passCountData'] as Map<String, dynamic>?;

                            List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataPassCount(passCountData);


                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  color: Color(0xFFDFECFF),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 2,
                                      offset: Offset(1, 0),
                                    ),
                                  ]
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Container(
                                        child:
                                        passCountData?.entries.isEmpty ?? true ?
                                        Center(child: Text('데이터가 없습니다'))
                                            : ListView(
                                            scrollDirection: Axis.horizontal,
                                            children: barData.map((data) {
                                              String slopeName = data['slopeName'];
                                              int passCount = data['passCount'];
                                              double barHeightRatio = data['barHeightRatio'];
                                              Color barColor = data['barColor'];

                                              return Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              width: 50,
                                              height: 95,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '$passCount',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF111111),
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: 50,
                                                    height: 95 * barHeightRatio,
                                                    child: Container(
                                                      width: 20,
                                                      height: 95 * barHeightRatio,
                                                      decoration: BoxDecoration(
                                                          color: barColor,
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(3),
                                                              topLeft: Radius.circular(3)
                                                          )
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    slopeName,
                                                    style: TextStyle(fontSize: 11, color: Color(0xFF111111)),
                                                  ),
                                                  SizedBox(height: 20,)
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            );
                          }
                      ),
                    ),
                    SizedBox(height: 30,),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text('시간대별 라이딩 횟수',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF111111)
                              ),),
                            Expanded(child: SizedBox()),
                            GestureDetector(
                              onTap: (){},
                              child: Text('자세히 보기',
                                style: TextStyle(
                                    fontSize: 13
                                ),
                              ),
                            )
                          ],
                        )),
                    SizedBox(height: 10,),
                    Container(
                      child: StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Ranking')
                              .doc('${_seasonController.currentSeason}')
                              .collection('${friendDocs[0]['favoriteResort']}')
                              .doc("${friendDocs[0]['uid']}")
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {

                            if (snapshot.hasError) {
                              return Text("오류가 발생했습니다");
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Lottie.asset('assets/json/loadings_wht_final.json');
                            }

                            Map<String, dynamic>? data =
                            snapshot.data!.data() as Map<String, dynamic>?;

                            Map<String, dynamic>? passCountTimeData =
                            data?['passCountTimeData'] as Map<String, dynamic>?;

                            List<Map<String, dynamic>> barData = _liveMapController.calculateBarDataSlot(passCountTimeData);


                            return Container(
                              height: 200,
                              decoration: BoxDecoration(
                                  color: Color(0xFFDFECFF),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.5),
                                      blurRadius: 2,
                                      offset: Offset(1, 0),
                                    ),
                                  ]
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Container(
                                        child:
                                        passCountTimeData?.entries.isEmpty ?? true ?
                                        Center(child: Text('데이터가 없습니다'))
                                            : ListView(
                                          scrollDirection: Axis.horizontal,
                                          physics: NeverScrollableScrollPhysics(),
                                          children: barData.map((data) {
                                            String slotName = data['slotName'];
                                            int passCount = data['passCount'];
                                            double barHeightRatio = data['barHeightRatio'];
                                            Color barColor = data['barColor'];

                                            return Container(
                                              margin: EdgeInsets.symmetric(horizontal: 5),
                                              width: 29,
                                              height: 95,
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    '$passCount',
                                                    style: TextStyle(
                                                        fontSize: 11,
                                                        color: Color(0xFF111111),
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    width: 30,
                                                    height: 95 * barHeightRatio,
                                                    child: Container(
                                                      width: 30,
                                                      height: 95 * barHeightRatio,
                                                      decoration: BoxDecoration(
                                                          color: barColor,
                                                          borderRadius: BorderRadius.only(
                                                              topRight: Radius.circular(3),
                                                              topLeft: Radius.circular(3)
                                                          )
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 10),
                                                  Text(
                                                    _resortModelController.getSlotName(slotName),
                                                    style: TextStyle(fontSize: 11, color: Color(0xFF111111)),
                                                  ),
                                                  SizedBox(height: 20,)
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ),
                                  ),

                                ],
                              ),
                            );
                          }
                      ),
                    ), //시간대별 라이딩 횟수


                    SizedBox(height: 30),
                    Divider(
                      thickness: 8,
                      height: 20,
                      color: Color(0xFFEEEEEE),),
                    SizedBox(height: 20,),
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('친구톡',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF111111)
                          ),)), //친구톡
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            StreamBuilder(
                              stream: _stream,
                              builder: (BuildContext context,
                                  AsyncSnapshot<dynamic> snapshot) {
                                if (!snapshot.hasData ||
                                    snapshot.data == null) {
                                  return Center(child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 24),
                                    child: Text('친구톡이 없습니다', style: TextStyle(
                                        fontSize: 13, color: Color(
                                        0xFF666666)),),
                                  ));
                                } else if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }
                                else if (snapshot.data!.docs.isNotEmpty) {
                                  List commentDocs = snapshot.data!.docs;
                                  return ListView.builder(
                                    padding: EdgeInsets.only(top: 4),
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: commentDocs.length,
                                    itemBuilder: (context, index) {
                                      Timestamp timestamp = commentDocs[index]
                                          .get('timeStamp');
                                      String formattedDate = DateFormat(
                                          'yyyy.MM.dd').format(
                                          timestamp.toDate()); // 원하는 형식으로 날짜 변환
                                      return
                                        (_userModelController.repoUidList!
                                            .contains(commentDocs[index].get(
                                            'myUid')))
                                            ? Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 14),
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius
                                                  .circular(8)
                                          ),
                                          child: Center(
                                            child: Padding(
                                              padding: const EdgeInsets
                                                  .symmetric(vertical: 12),
                                              child: Text(
                                                '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                                style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .normal,
                                                    fontSize: 12,
                                                    color: Color(0xffc8c8c8)),
                                              ),
                                            ),
                                          ),
                                        )
                                            : Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8),
                                              child: Row(
                                                children: [
                                                  Column(
                                                    crossAxisAlignment: CrossAxisAlignment
                                                        .start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment
                                                            .start,
                                                        children: [
                                                          Container(
                                                            child: Text(
                                                              commentDocs[index]['comment'],
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Color(
                                                                      0xFF111111)
                                                              ),),
                                                            width: _size.width -
                                                                52,
                                                          ),
                                                          (commentDocs[index]['myUid'] !=
                                                              _userModelController
                                                                  .uid)
                                                              ? GestureDetector(
                                                            onTap: () =>
                                                                showModalBottomSheet(
                                                                    enableDrag: false,
                                                                    context: context,
                                                                    builder: (
                                                                        context) {
                                                                      return SafeArea(
                                                                        child: Container(
                                                                          height: 200,
                                                                          child: Padding(
                                                                            padding: const EdgeInsets
                                                                                .symmetric(
                                                                                horizontal: 20.0,
                                                                                vertical: 14),
                                                                            child: Column(
                                                                              children: [
                                                                                GestureDetector(
                                                                                  child: ListTile(
                                                                                    contentPadding: EdgeInsets
                                                                                        .zero,
                                                                                    title: Center(
                                                                                      child: Text(
                                                                                        '삭제',
                                                                                        style: TextStyle(
                                                                                            fontSize: 15,
                                                                                            fontWeight: FontWeight
                                                                                                .bold,
                                                                                            color: Color(
                                                                                                0xFFD63636)
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    //selected: _isSelected[index]!,
                                                                                    onTap: () async {
                                                                                      Navigator
                                                                                          .pop(
                                                                                          context);
                                                                                      showModalBottomSheet(
                                                                                          context: context,
                                                                                          builder: (
                                                                                              context) {
                                                                                            return Container(
                                                                                              color: Colors
                                                                                                  .white,
                                                                                              height: 180,
                                                                                              child: Padding(
                                                                                                padding: const EdgeInsets
                                                                                                    .symmetric(
                                                                                                    horizontal: 20.0),
                                                                                                child: Column(
                                                                                                  crossAxisAlignment: CrossAxisAlignment
                                                                                                      .start,
                                                                                                  mainAxisAlignment: MainAxisAlignment
                                                                                                      .start,
                                                                                                  children: [
                                                                                                    SizedBox(
                                                                                                      height: 30,
                                                                                                    ),
                                                                                                    Text(
                                                                                                      '삭제하시겠습니까?',
                                                                                                      style: TextStyle(
                                                                                                          fontSize: 20,
                                                                                                          fontWeight: FontWeight
                                                                                                              .bold,
                                                                                                          color: Color(
                                                                                                              0xFF111111)),
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      height: 30,
                                                                                                    ),
                                                                                                    Row(
                                                                                                      mainAxisAlignment: MainAxisAlignment
                                                                                                          .spaceEvenly,
                                                                                                      children: [
                                                                                                        Expanded(
                                                                                                          child: ElevatedButton(
                                                                                                            onPressed: () {
                                                                                                              Navigator
                                                                                                                  .pop(
                                                                                                                  context);
                                                                                                            },
                                                                                                            child: Text(
                                                                                                              '취소',
                                                                                                              style: TextStyle(
                                                                                                                  color: Colors
                                                                                                                      .white,
                                                                                                                  fontSize: 15,
                                                                                                                  fontWeight: FontWeight
                                                                                                                      .bold),
                                                                                                            ),
                                                                                                            style: TextButton
                                                                                                                .styleFrom(
                                                                                                                splashFactory: InkRipple
                                                                                                                    .splashFactory,
                                                                                                                elevation: 0,
                                                                                                                minimumSize: Size(
                                                                                                                    100,
                                                                                                                    56),
                                                                                                                backgroundColor: Color(
                                                                                                                    0xff555555),
                                                                                                                padding: EdgeInsets
                                                                                                                    .symmetric(
                                                                                                                    horizontal: 0)),
                                                                                                          ),
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          width: 10,
                                                                                                        ),
                                                                                                        Expanded(
                                                                                                          child: ElevatedButton(
                                                                                                            onPressed: () async {
                                                                                                              CustomFullScreenDialog
                                                                                                                  .showDialog();
                                                                                                              try {
                                                                                                                await FirebaseFirestore
                                                                                                                    .instance
                                                                                                                    .collection(
                                                                                                                    'user')
                                                                                                                    .doc(
                                                                                                                    '${widget
                                                                                                                        .uid}')
                                                                                                                    .collection(
                                                                                                                    'friendsComment')
                                                                                                                    .doc(
                                                                                                                    commentDocs[index]['myUid'])
                                                                                                                    .delete();
                                                                                                              } catch (e) {}
                                                                                                              print(
                                                                                                                  ' 삭제 완료');
                                                                                                              Navigator
                                                                                                                  .pop(
                                                                                                                  context);
                                                                                                              CustomFullScreenDialog
                                                                                                                  .cancelDialog();
                                                                                                            },
                                                                                                            child: Text(
                                                                                                              '확인',
                                                                                                              style: TextStyle(
                                                                                                                  color: Colors
                                                                                                                      .white,
                                                                                                                  fontSize: 15,
                                                                                                                  fontWeight: FontWeight
                                                                                                                      .bold),
                                                                                                            ),
                                                                                                            style: TextButton
                                                                                                                .styleFrom(
                                                                                                                splashFactory: InkRipple
                                                                                                                    .splashFactory,
                                                                                                                elevation: 0,
                                                                                                                minimumSize: Size(
                                                                                                                    100,
                                                                                                                    56),
                                                                                                                backgroundColor: Color(
                                                                                                                    0xff2C97FB),
                                                                                                                padding: EdgeInsets
                                                                                                                    .symmetric(
                                                                                                                    horizontal: 0)),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ],
                                                                                                    )
                                                                                                  ],
                                                                                                ),
                                                                                              ),
                                                                                            );
                                                                                          });
                                                                                    },
                                                                                    shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                            10)),
                                                                                  ),
                                                                                ),
                                                                                GestureDetector(
                                                                                  child: ListTile(
                                                                                    contentPadding: EdgeInsets
                                                                                        .zero,
                                                                                    title: Center(
                                                                                      child: Text(
                                                                                        '신고하기',
                                                                                        style: TextStyle(
                                                                                          fontSize: 15,
                                                                                          fontWeight: FontWeight
                                                                                              .bold,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    //selected: _isSelected[index]!,
                                                                                    onTap: () async {
                                                                                      Get
                                                                                          .dialog(
                                                                                          AlertDialog(
                                                                                            contentPadding: EdgeInsets
                                                                                                .only(
                                                                                                bottom: 0,
                                                                                                left: 20,
                                                                                                right: 20,
                                                                                                top: 30),
                                                                                            elevation: 0,
                                                                                            shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius
                                                                                                    .circular(
                                                                                                    10.0)),
                                                                                            buttonPadding: EdgeInsets
                                                                                                .symmetric(
                                                                                                horizontal: 20,
                                                                                                vertical: 0),
                                                                                            content: Text(
                                                                                              '이 회원을 신고하시겠습니까?',
                                                                                              style: TextStyle(
                                                                                                  fontWeight: FontWeight
                                                                                                      .w600,
                                                                                                  fontSize: 15),
                                                                                            ),
                                                                                            actions: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  TextButton(
                                                                                                      onPressed: () {
                                                                                                        Navigator
                                                                                                            .pop(
                                                                                                            context);
                                                                                                      },
                                                                                                      child: Text(
                                                                                                        '취소',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 15,
                                                                                                          color: Color(
                                                                                                              0xFF949494),
                                                                                                          fontWeight: FontWeight
                                                                                                              .bold,
                                                                                                        ),
                                                                                                      )),
                                                                                                  TextButton(
                                                                                                      onPressed: () async {
                                                                                                        var repoUid = commentDocs[index]
                                                                                                            .get(
                                                                                                            'myUid');
                                                                                                        await _userModelController
                                                                                                            .repoUpdate(
                                                                                                            repoUid);
                                                                                                        Navigator
                                                                                                            .pop(
                                                                                                            context);
                                                                                                        Navigator
                                                                                                            .pop(
                                                                                                            context);
                                                                                                      },
                                                                                                      child: Text(
                                                                                                        '신고',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 15,
                                                                                                          color: Color(
                                                                                                              0xFF3D83ED),
                                                                                                          fontWeight: FontWeight
                                                                                                              .bold,
                                                                                                        ),
                                                                                                      ))
                                                                                                ],
                                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                                    .end,
                                                                                              )
                                                                                            ],
                                                                                          ));
                                                                                    },
                                                                                    shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                            10)),
                                                                                  ),
                                                                                ),
                                                                                GestureDetector(
                                                                                  child: ListTile(
                                                                                    contentPadding: EdgeInsets
                                                                                        .zero,
                                                                                    title: Center(
                                                                                      child: Text(
                                                                                        '이 회원의 글 모두 숨기기',
                                                                                        style: TextStyle(
                                                                                          fontSize: 15,
                                                                                          fontWeight: FontWeight
                                                                                              .bold,
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    //selected: _isSelected[index]!,
                                                                                    onTap: () async {
                                                                                      Get
                                                                                          .dialog(
                                                                                          AlertDialog(
                                                                                            contentPadding: EdgeInsets
                                                                                                .only(
                                                                                                bottom: 0,
                                                                                                left: 20,
                                                                                                right: 20,
                                                                                                top: 30),
                                                                                            elevation: 0,
                                                                                            shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius
                                                                                                    .circular(
                                                                                                    10.0)),
                                                                                            buttonPadding: EdgeInsets
                                                                                                .symmetric(
                                                                                                horizontal: 20,
                                                                                                vertical: 0),
                                                                                            content: Text(
                                                                                              '이 회원의 게시물을 모두 숨길까요?\n이 동작은 취소할 수 없습니다.',
                                                                                              style: TextStyle(
                                                                                                  fontWeight: FontWeight
                                                                                                      .w600,
                                                                                                  fontSize: 15),
                                                                                            ),
                                                                                            actions: [
                                                                                              Row(
                                                                                                children: [
                                                                                                  TextButton(
                                                                                                      onPressed: () {
                                                                                                        Navigator
                                                                                                            .pop(
                                                                                                            context);
                                                                                                      },
                                                                                                      child: Text(
                                                                                                        '취소',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 15,
                                                                                                          color: Color(
                                                                                                              0xFF949494),
                                                                                                          fontWeight: FontWeight
                                                                                                              .bold,
                                                                                                        ),
                                                                                                      )),
                                                                                                  TextButton(
                                                                                                      onPressed: () {
                                                                                                        var repoUid = commentDocs[index]
                                                                                                            .get(
                                                                                                            'myUid');
                                                                                                        _userModelController
                                                                                                            .updateRepoUid(
                                                                                                            repoUid);
                                                                                                        Navigator
                                                                                                            .pop(
                                                                                                            context);
                                                                                                        Navigator
                                                                                                            .pop(
                                                                                                            context);
                                                                                                      },
                                                                                                      child: Text(
                                                                                                        '확인',
                                                                                                        style: TextStyle(
                                                                                                          fontSize: 15,
                                                                                                          color: Color(
                                                                                                              0xFF3D83ED),
                                                                                                          fontWeight: FontWeight
                                                                                                              .bold,
                                                                                                        ),
                                                                                                      ))
                                                                                                ],
                                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                                    .end,
                                                                                              )
                                                                                            ],
                                                                                          ));
                                                                                    },
                                                                                    shape: RoundedRectangleBorder(
                                                                                        borderRadius: BorderRadius
                                                                                            .circular(
                                                                                            10)),
                                                                                  ),
                                                                                )
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                            child: Icon(
                                                              Icons.more_horiz,
                                                              color: Color(
                                                                  0xFFdedede),
                                                              size: 20,
                                                            ),
                                                          )
                                                              : GestureDetector(
                                                            onTap: () =>
                                                                showModalBottomSheet(
                                                                    enableDrag:
                                                                    false,
                                                                    context: context,
                                                                    builder: (
                                                                        context) {
                                                                      return Container(
                                                                        height: 100,
                                                                        child:
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .symmetric(
                                                                              horizontal: 20.0,
                                                                              vertical: 14),
                                                                          child: Column(
                                                                            children: [
                                                                              GestureDetector(
                                                                                child: ListTile(
                                                                                  contentPadding: EdgeInsets
                                                                                      .zero,
                                                                                  title: Center(
                                                                                    child: Text(
                                                                                      '삭제',
                                                                                      style: TextStyle(
                                                                                          fontSize: 15,
                                                                                          fontWeight: FontWeight
                                                                                              .bold,
                                                                                          color: Color(
                                                                                              0xFFD63636)
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  //selected: _isSelected[index]!,
                                                                                  onTap: () async {
                                                                                    Navigator
                                                                                        .pop(
                                                                                        context);
                                                                                    showModalBottomSheet(
                                                                                        context: context,
                                                                                        builder: (
                                                                                            context) {
                                                                                          return Container(
                                                                                            color: Colors
                                                                                                .white,
                                                                                            height: 180,
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets
                                                                                                  .symmetric(
                                                                                                  horizontal: 20.0),
                                                                                              child: Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment
                                                                                                    .start,
                                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                                    .start,
                                                                                                children: [
                                                                                                  SizedBox(
                                                                                                    height: 30,
                                                                                                  ),
                                                                                                  Text(
                                                                                                    '삭제하시겠습니까?',
                                                                                                    style: TextStyle(
                                                                                                        fontSize: 20,
                                                                                                        fontWeight: FontWeight
                                                                                                            .bold,
                                                                                                        color: Color(
                                                                                                            0xFF111111)),
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 30,
                                                                                                  ),
                                                                                                  Row(
                                                                                                    mainAxisAlignment: MainAxisAlignment
                                                                                                        .spaceEvenly,
                                                                                                    children: [
                                                                                                      Expanded(
                                                                                                        child: ElevatedButton(
                                                                                                          onPressed: () {
                                                                                                            Navigator
                                                                                                                .pop(
                                                                                                                context);
                                                                                                          },
                                                                                                          child: Text(
                                                                                                            '취소',
                                                                                                            style: TextStyle(
                                                                                                                color: Colors
                                                                                                                    .white,
                                                                                                                fontSize: 15,
                                                                                                                fontWeight: FontWeight
                                                                                                                    .bold),
                                                                                                          ),
                                                                                                          style: TextButton
                                                                                                              .styleFrom(
                                                                                                              splashFactory: InkRipple
                                                                                                                  .splashFactory,
                                                                                                              elevation: 0,
                                                                                                              minimumSize: Size(
                                                                                                                  100,
                                                                                                                  56),
                                                                                                              backgroundColor: Color(
                                                                                                                  0xff555555),
                                                                                                              padding: EdgeInsets
                                                                                                                  .symmetric(
                                                                                                                  horizontal: 0)),
                                                                                                        ),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        width: 10,
                                                                                                      ),
                                                                                                      Expanded(
                                                                                                        child: ElevatedButton(
                                                                                                          onPressed: () async {
                                                                                                            CustomFullScreenDialog
                                                                                                                .showDialog();
                                                                                                            try {
                                                                                                              await FirebaseFirestore
                                                                                                                  .instance
                                                                                                                  .collection(
                                                                                                                  'user')
                                                                                                                  .doc(
                                                                                                                  '${widget
                                                                                                                      .uid}')
                                                                                                                  .collection(
                                                                                                                  'friendsComment')
                                                                                                                  .doc(
                                                                                                                  '${_userModelController
                                                                                                                      .uid}')
                                                                                                                  .delete();
                                                                                                            } catch (e) {}
                                                                                                            print(
                                                                                                                '친구톡 삭제 완료');
                                                                                                            Navigator
                                                                                                                .pop(
                                                                                                                context);
                                                                                                            CustomFullScreenDialog
                                                                                                                .cancelDialog();
                                                                                                          },
                                                                                                          child: Text(
                                                                                                            '확인',
                                                                                                            style: TextStyle(
                                                                                                                color: Colors
                                                                                                                    .white,
                                                                                                                fontSize: 15,
                                                                                                                fontWeight: FontWeight
                                                                                                                    .bold),
                                                                                                          ),
                                                                                                          style: TextButton
                                                                                                              .styleFrom(
                                                                                                              splashFactory: InkRipple
                                                                                                                  .splashFactory,
                                                                                                              elevation: 0,
                                                                                                              minimumSize: Size(
                                                                                                                  100,
                                                                                                                  56),
                                                                                                              backgroundColor: Color(
                                                                                                                  0xff2C97FB),
                                                                                                              padding: EdgeInsets
                                                                                                                  .symmetric(
                                                                                                                  horizontal: 0)),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          );
                                                                                        });
                                                                                  },
                                                                                  shape: RoundedRectangleBorder(
                                                                                      borderRadius: BorderRadius
                                                                                          .circular(
                                                                                          10)),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    }),
                                                            child: Icon(
                                                              Icons.more_horiz,
                                                              color: Color(
                                                                  0xFFdedede),
                                                              size: 20,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 6,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text(
                                                            commentDocs[index]['displayName'],
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(
                                                                    0xFF949494)
                                                            ),),
                                                          SizedBox(width: 6,),
                                                          Text(formattedDate,
                                                            style: TextStyle(
                                                                fontSize: 13,
                                                                color: Color(
                                                                    0xFF949494)
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),

                                                ],
                                              ),
                                            ),
                                            SizedBox(height: 8),
                                            if (index != commentDocs.length - 1)
                                              Container(
                                                color: Color(0xFFF5F5F5),
                                                height: 1,
                                                width: _size.width - 32,
                                              )
                                          ],
                                        );
                                    },
                                  );
                                }
                                return Center(child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 24),
                                  child: Text('친구톡이 없습니다.', style: TextStyle(
                                      fontSize: 13, color: Color(0xFF666666)),),
                                ));
                              },
                            )
                          ],
                        )
                    ),
                    (widget.uid != _userModelController.uid)
                        ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextFormField(
                        key: _formKeyProfile3,
                        cursorColor: Color(0xff377EEA),
                        controller: _stateMsgController,
                        strutStyle: StrutStyle(leading: 0.3),
                        maxLines: 1,
                        enableSuggestions: false,
                        autocorrect: false,
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              splashColor: Colors.transparent,
                              onPressed: () async {
                                if (_stateMsgController.text
                                    .trim()
                                    .isEmpty) {
                                  return;
                                }
                                try {
                                  if (_userModelController
                                      .myFriendCommentUidList!.contains(
                                      widget.uid)
                                      && _userModelController.commentCheck! ==
                                          false) {
                                    Get.dialog(
                                        AlertDialog(
                                          title: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween,
                                            children: [
                                              Text("친구톡 새로 등록하기"),
                                              IconButton(
                                                icon: Icon(
                                                    Icons.cancel_outlined),
                                                onPressed: () {
                                                  _dialogController.isChecked
                                                      .value =
                                                  false; // Reset checkbox when dialog is closed
                                                  Navigator.pop(context);
                                                },
                                              ),
                                            ],
                                          ),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text("기존 친구톡은 삭제됩니다.",
                                                style: TextStyle(
                                                    fontSize: 13
                                                ),
                                              ),
                                              Text("계속하시겠습니까?",
                                                style: TextStyle(
                                                    fontSize: 13
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 10, bottom: 10),
                                                child: Divider(
                                                  height: 1,
                                                  color: Color(0xFFFDEDEDE),
                                                ),
                                              ),
                                              Obx(() =>
                                                  Row(
                                                    children: [
                                                      Checkbox(
                                                        value: _dialogController
                                                            .isChecked.value,
                                                        onChanged: (newValue) {
                                                          _dialogController
                                                              .isChecked.value =
                                                          newValue!;
                                                        },
                                                      ),
                                                      Text('다시 보지 않기.',
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ),
                                            ],
                                          ),
                                          actions: [
                                            ButtonBar(
                                              alignment: MainAxisAlignment
                                                  .center,
                                              children: [
                                                Obx(
                                                      () =>
                                                      TextButton(
                                                        style: TextButton
                                                            .styleFrom(
                                                          backgroundColor: Colors
                                                              .blue,
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              vertical: 10,
                                                              horizontal: 20),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius
                                                                .circular(10),
                                                          ),
                                                        ),
                                                        child: Text("친구톡 등록",
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white
                                                          ),
                                                        ),
                                                        onPressed: _dialogController
                                                            .isChecked.value
                                                            ? () async {
                                                          CustomFullScreenDialog
                                                              .showDialog();
                                                          await _userModelController
                                                              .updateCommentCheck();
                                                          await _friendsCommentModelController
                                                              .sendMessage(
                                                            displayName: _userModelController
                                                                .displayName,
                                                            profileImageUrl: _userModelController
                                                                .profileImageUrl,
                                                            comment: _newComment,
                                                            commentCount: _userModelController
                                                                .commentCount,
                                                            resortNickname: _userModelController
                                                                .resortNickname,
                                                            myUid: _userModelController
                                                                .uid,
                                                            friendsUid: widget
                                                                .uid,
                                                          );
                                                          await _userModelController
                                                              .getCurrentUser(
                                                              _userModelController
                                                                  .uid);
                                                          _stateMsgController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          CustomFullScreenDialog
                                                              .cancelDialog();
                                                        }
                                                            : () async {
                                                          CustomFullScreenDialog
                                                              .showDialog();
                                                          await _friendsCommentModelController
                                                              .sendMessage(
                                                            displayName: _userModelController
                                                                .displayName,
                                                            profileImageUrl: _userModelController
                                                                .profileImageUrl,
                                                            comment: _newComment,
                                                            commentCount: _userModelController
                                                                .commentCount,
                                                            resortNickname: _userModelController
                                                                .resortNickname,
                                                            myUid: _userModelController
                                                                .uid,
                                                            friendsUid: widget
                                                                .uid,
                                                          );
                                                          _stateMsgController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                          CustomFullScreenDialog
                                                              .cancelDialog();
                                                        },
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                    );
                                    Get.dialog(
                                        AlertDialog()
                                    ); //빈 다이얼로그. 이거없으면 위 다이얼로그가 안나옴..

                                  } else {
                                    CustomFullScreenDialog.showDialog();
                                    await _friendsCommentModelController
                                        .sendMessage(
                                      displayName: _userModelController
                                          .displayName,
                                      profileImageUrl: _userModelController
                                          .profileImageUrl,
                                      comment: _newComment,
                                      commentCount: _userModelController
                                          .commentCount,
                                      resortNickname: _userModelController
                                          .resortNickname,
                                      myUid: _userModelController.uid,
                                      friendsUid: widget.uid,
                                    );
                                    await _userModelController
                                        .updateMyFriendCommentUidList(
                                        friendUid: widget.uid);
                                    FocusScope.of(context).unfocus();
                                    _stateMsgController.clear();
                                  }
                                } catch (e) {
                                  CustomFullScreenDialog.cancelDialog();
                                }
                                CustomFullScreenDialog.cancelDialog();
                              },
                              icon: (_stateMsgController.text
                                  .trim()
                                  .isEmpty)
                                  ? Image.asset(
                                'assets/imgs/icons/icon_livetalk_send_g.png',
                                width: 27,
                                height: 27,
                              )
                                  : Image.asset(
                                'assets/imgs/icons/icon_livetalk_send.png',
                                width: 27,
                                height: 27,
                              ),
                            ),
                            errorStyle: TextStyle(
                              fontSize: 12,
                            ),
                            hintStyle: TextStyle(
                                color: Color(0xff949494), fontSize: 14),
                            hintText: '친구톡 남기기',
                            contentPadding: EdgeInsets.only(
                                top: 2, bottom: 2, left: 16, right: 16),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFDEDEDE)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFDEDEDE)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(0xFFFF3726)),
                              borderRadius: BorderRadius.circular(6),
                            )),
                        onChanged: (value) {
                          setState(() {
                            _newComment = value;
                          });
                        },
                      ),
                    )
                        : Container()
                  ],
                ),
              ),
            ),
          ],
        ),
      );

    }
    ),
        )
      );
  }
}

// if (!snapshot.hasData || snapshot.data == null) {}
// else if (snapshot.data!.docs.isNotEmpty) {
// Column(
// children: [
//
// ],
// );
// }
// else if (snapshot.connectionState == ConnectionState.waiting) {}
// return Center(
// child: CircularProgressIndicator(),
// );

