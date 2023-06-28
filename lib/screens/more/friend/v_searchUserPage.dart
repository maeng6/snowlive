import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';

import '../../../controller/vm_searchUserController.dart';
import '../../../controller/vm_userModelController.dart';
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
  var foundUserUid;
  bool isFound=false;
  UserModel? foundUserModel;

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    //TODO: Dependency Injection**************************************************
    Get.put(SearchUserController(), permanent: true );
    SearchUserController _searchUserController = Get.find<SearchUserController>();
    UserModelController _userModelController = Get.find<UserModelController>();
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
          child: Scaffold(
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
                  Navigator.pop(context);
                },
              ),
              // actions: [
              //   GestureDetector(
              //     onTap: (){
              //       Get.to(()=>SearchUserPage());
              //     },
              //     child: Icon(Icons.search),
              //   )
              // ],
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
            body: Container(
              color: Colors.white,
              child:  Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                        children: [
                          Form(
                            key: _formKey,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 30, top: 2),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: TextFormField(
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
                                      labelText: '친구 검색',
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
                                  isCheckedDispName =  await _userModelController.checkDuplicateDisplayName(_nickName);
                                  if (isCheckedDispName == false) {
                                    foundUserUid =  await _searchUserController.searchUsersByDisplayName(_nickName);
                                    print(foundUserUid);
                                    foundUserModel = await _userModelController.getFoundUser(foundUserUid!);
                                    isFound = true;
                                  }
                                  else{
                                    isFound = false;
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
                                        '존재하지 않는 활동명입니다.\n활동명 전체를 정확히 입력해주세요.',
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
                                } else {}
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
                        SizedBox(height: 10),
                        (isFound)
                            ? Center(
                              child: GestureDetector(
                          onTap: (){
                              Get.dialog(AlertDialog(
                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0)),
                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                content: Text(
                                  '닉네임 : ${foundUserModel!.displayName}\n'
                                      '베이스 : ${foundUserModel!.resortNickname}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15),
                                ),
                                actions: [
                                  Row(
                                    children: [
                                      (_userModelController.uid != foundUserModel!.uid)
                                      ? TextButton(
                                          onPressed: () async{
                                            await _userModelController.getCurrentUser(_userModelController.uid);
                                            if(_userModelController.whoInviteMe!.contains(foundUserModel!.uid)){
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
                                                  '이미 요청받은 회원입니다.',
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
                                                          child: Text(
                                                            '확인',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xFF949494),
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          )),
                                                    ],
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                  )
                                                ],
                                              ));
                                            }else if(_userModelController.friendUidList!.contains(foundUserModel!.uid)){
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
                                                  '이미 추가된 친구입니다.',
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 15),
                                                ),
                                                actions: [
                                                  Row(
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                            Get.back();
                                                          },
                                                          child: Text(
                                                            '확인',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(
                                                                  0xFF949494),
                                                              fontWeight:
                                                              FontWeight.bold,
                                                            ),
                                                          )),
                                                    ],
                                                    mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                  )
                                                ],
                                              ));
                                            } else{
                                              CustomFullScreenDialog.showDialog();
                                              await _userModelController.updateInvitation(friendUid: foundUserModel!.uid);
                                              await _userModelController.getCurrentUser(_userModelController.uid);

                                              //await _userModelController.updateFriendUid(foundUserModel!.uid);
                                              //await _userModelController.updateWhoResistMe(friendUid: foundUserModel!.uid);
                                              Navigator.pop(context);
                                              CustomFullScreenDialog.cancelDialog();
                                            }

                                          },
                                          child: Text(
                                            '친구 요청',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xff377EEA),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))
                                      : Container(),
                                      SizedBox(width: 10,),
                                      TextButton(
                                          onPressed: () async{
                                           Navigator.pop(context);
                                          },
                                          child: Text(
                                            '취소',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: Color(0xff377EEA),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ))
                                    ],
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  )
                                ],
                              ));
                          },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Color(0xFF3D83ED)
                                  ),
                                    width: 290,
                                    height: 457,
                                    child: Column(
                                      children: [
                                        Text('${foundUserModel!.displayName}'),
                                        SizedBox(width: 10,),
                                        Text('${foundUserModel!.resortNickname}'),
                                        SizedBox(width: 10,),
                                        Text('${foundUserModel!.userEmail}'),
                                      ],
                                    )
                                ),
                              ),
                            )
                            : Container(
                          height: _size.height - 400,
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
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
                          child: Text('활동명 전체를 정확히 입력해야 검색이 완료됩니다.', style: TextStyle(
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
                                  padding: EdgeInsets.only(
                                      top: 16,
                                      bottom:
                                      MediaQuery.of(context).viewInsets.bottom + 16,
                                      right: 5),
                                  child: TextButton(
                                      onPressed: () {

                                      },
                                      style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.all(Radius.circular(6))),
                                        elevation: 0,
                                        splashFactory: InkRipple.splashFactory,
                                        minimumSize: Size(1000, 56),
                                        backgroundColor:
                                        (isFound) ? Color(0xff666666) : Color(0xffDEDEDE),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 4),
                                        child: Text('프로필 보기',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                      )
                                  )),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        16,
                                    left: 5,
                                    top: 16),
                                child: TextButton(
                                    onPressed: () {
                                    },
                                    style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6))),
                                        elevation: 0,
                                        splashFactory: InkRipple.splashFactory,
                                        minimumSize: Size(1000, 56),
                                        backgroundColor: (isFound) ? Color(0xff377EEA) : Color(0xffDEDEDE)),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.only(bottom: 4),
                                      child: Text(
                                        '친구 추가하기',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    )
                                ),
                              ),
                            )

                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
