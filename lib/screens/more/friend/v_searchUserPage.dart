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
                                      top: 11, bottom: 11, left: 16, right: 16),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text('검색 결과', style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                          color: Color(0xFF949494)
                      ),),
                    ),
                    SizedBox(height: 20,),
                    (isFound)
                        ? GestureDetector(
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
                                      CustomFullScreenDialog.showDialog();
                                      await _userModelController.updateFriendUid(foundUserModel!.uid);
                                      await _userModelController.updateWhoResistMe(friendUid: foundUserModel!.uid);
                                      Navigator.pop(context);
                                      CustomFullScreenDialog.cancelDialog();
                                    },
                                    child: Text(
                                      '친구 추가',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xff377EEA),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                                : Container()
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            )
                          ],
                        ));
                      },
                          child: Container(
                      child: Row(
                          children: [
                            Text('${foundUserModel!.displayName}'),
                            SizedBox(width: 10,),
                            Text('${foundUserModel!.resortNickname}'),
                            SizedBox(width: 10,),
                            Text('${foundUserModel!.userEmail}'),
                          ],
                      )
                  ),
                        )
                        : Container(

                    )
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
