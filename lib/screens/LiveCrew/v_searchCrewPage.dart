import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_searchCrewController.dart';
import 'package:snowlive3/controller/vm_timeStampController.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_searchUserController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../model/m_userModel.dart';
import '../../controller/vm_liveCrewModelController.dart';
import '../../model/m_liveCrewModel.dart';

class SearchCrewPage extends StatefulWidget {
  const SearchCrewPage({Key? key}) : super(key: key);

  @override
  State<SearchCrewPage> createState() => _SearchCrewPageState();
}

class _SearchCrewPageState extends State<SearchCrewPage> {


  TextEditingController _textEditingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  var _crewName;
  bool? isCheckedCrewName;
  var foundCrewID;
  bool isFound=false;
  LiveCrewModel? foundCrewModel;

  @override
  Widget build(BuildContext context) {

    //TODO: Dependency Injection**************************************************
    Get.put(SearchUserController(), permanent: true );
    Get.put(SearchCrewController(), permanent: true );
    TimeStampController _timeStampController = Get.find<TimeStampController>();
    UserModelController _userModelController = Get.find<UserModelController>();
    SearchCrewController _searchCrewController = Get.find<SearchCrewController>();
    LiveCrewModelController _liveCrewModelController = Get.find<LiveCrewModelController>();
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
                  Get.back();
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
              title: Text('라이브 크루 검색',
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
                              onFieldSubmitted: (val) async{
                                setState(() {
                                  isLoading = true;
                                });
                                if (_formKey.currentState!.validate()) {
                                  _crewName = _textEditingController.text;
                                  print(_crewName);
                                  isCheckedCrewName =  await _searchCrewController.checkDuplicateCrewName(_crewName);
                                  print(isCheckedCrewName);
                                  if (isCheckedCrewName == false) {
                                    foundCrewID = await _liveCrewModelController.searchCrewByCrewName(_crewName);
                                    print(foundCrewID);
                                    foundCrewModel = await _liveCrewModelController.getFoundCrew(foundCrewID!);
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
                                        '존재하지 않는 크루입니다.\n크루 이름 전체를 정확히 입력해주세요.',
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
                                }else {}
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
                                  hintText: '크루 이름 입력',
                                  labelText: '라이브 크루 검색',
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
                                  return '크루 이름을 입력해주세요.';
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
                              _crewName = _textEditingController.text;
                              print(_crewName);
                              isCheckedCrewName =  await _searchCrewController.checkDuplicateCrewName(_crewName);
                              print(isCheckedCrewName);
                              if (isCheckedCrewName == false) {
                              foundCrewID = await _liveCrewModelController.searchCrewByCrewName(_crewName);
                              print(foundCrewID);
                              foundCrewModel = await _liveCrewModelController.getFoundCrew(foundCrewID!);
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
                                    '존재하지 않는 크루입니다.\n크루 이름 전체를 정확히 입력해주세요.',
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
                              }else {}
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
                            '크루 : ${foundCrewModel!.crewName}\n'
                                '베이스 : ${foundCrewModel!.baseResortNickName}',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15),
                          ),
                          actions: [
                            (foundCrewModel!.memberUidList!.contains(_userModelController.uid!))
                            ? Row(
                              children: [
                                TextButton(
                                    onPressed: () async{
                                     Navigator.pop(context);
                                    },
                                    child: Text(
                                      '확인',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xff377EEA),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ))
                              ],
                              mainAxisAlignment: MainAxisAlignment.center,
                            )
                                : Row(
                              children: [
                                TextButton(
                                    onPressed: () async{
                                      if(_userModelController.liveCrew!.isEmpty || _userModelController.liveCrew == ''){
                                        Get.dialog(AlertDialog(
                                          contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                          content: Text(
                                            '가입신청을 하시겠습니까?',
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                                          ),
                                          actions: [
                                            Row(
                                              children: [
                                                TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      '취소',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Color(0xFF949494),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    )),
                                                TextButton(
                                                    onPressed: () async {
                                                      if(_userModelController.applyCrewList!.contains(foundCrewModel!.crewID)){
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
                                                      } else{
                                                        CustomFullScreenDialog.showDialog();
                                                        print(_liveCrewModelController.leaderUid);
                                                        await _liveCrewModelController.updateInvitation_crew(crewID: foundCrewID);
                                                        await _liveCrewModelController.updateInvitationAlarm_crew(leaderUid: foundCrewModel!.leaderUid);
                                                        await _userModelController.getCurrentUser(_userModelController.uid);
                                                        CustomFullScreenDialog.cancelDialog();
                                                        Navigator.pop(context);
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    child: Text(
                                                      '확인',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Color(0xFF3D83ED),
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ))
                                              ],
                                              mainAxisAlignment: MainAxisAlignment.end,
                                            )
                                          ],
                                        ));
                                      }else{
                                        Get.dialog(AlertDialog(
                                          contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                          content: Text('라이브 크루는 1개만 가입할 수 있습니다.',
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

                                      }
                                    },
                                    child: Text(
                                      '가입신청',
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Color(0xff377EEA),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )),
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
                      child: Row(
                          children: [
                            Text('${foundCrewModel!.crewName}'),
                            SizedBox(width: 10,),
                            Text('${foundCrewModel!.baseResortNickName}'),
                            SizedBox(width: 10,),
                            Text('생성일 : ${_timeStampController.yyyymmddFormat(foundCrewModel!.resistDate).toString()}'),
                          ],
                      )
                  ),
                        )
                        : Container()
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
