import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snowlive3/controller/vm_searchCrewController.dart';
import 'package:snowlive3/controller/vm_timeStampController.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_home.dart';
import 'package:snowlive3/screens/LiveCrew/v_crewDetailPage_screen.dart';
import 'package:snowlive3/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_searchUserController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../model/m_userModel.dart';
import '../../controller/vm_liveCrewModelController.dart';
import '../../model/m_crewLogoModel.dart';
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
  var assetFoundCrew;

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

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
                                  onFieldSubmitted: (val) async{
                                    CustomFullScreenDialog.showDialog();
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
                                        for (var crewLogo in crewLogoList) {
                                          if (crewLogo.crewColor == foundCrewModel!.crewColor) {
                                            assetFoundCrew = crewLogo.crewLogoAsset;
                                            break;
                                          }
                                        }
                                        isFound = true;
                                        CustomFullScreenDialog.cancelDialog();
                                      }
                                      else{
                                        CustomFullScreenDialog.cancelDialog();
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
                                CustomFullScreenDialog.showDialog();
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
                                  for (var crewLogo in crewLogoList) {
                                    if (crewLogo.crewColor == foundCrewModel!.crewColor) {
                                      assetFoundCrew = crewLogo.crewLogoAsset;
                                      break;
                                    }
                                  }
                                  isFound = true;
                                  CustomFullScreenDialog.cancelDialog();
                                }
                                  else{
                                    CustomFullScreenDialog.cancelDialog();
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
                        SizedBox(height: 6),
                        (isFound)
                            ? GestureDetector(
                          onTap: () async{
                            CustomFullScreenDialog.showDialog();
                            await _liveCrewModelController.getCurrnetCrew(foundCrewID);
                            CustomFullScreenDialog.cancelDialog();
                            Get.to(()=> CrewDetailPage_screen());
                          },
                              child: Center(
                                child: Container(
                          child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Color(foundCrewModel!.crewColor!)
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
                                      child: (foundCrewModel!.profileImageUrl!.isNotEmpty)
                                          ? ExtendedImage.network(
                                        '${foundCrewModel!.profileImageUrl}',
                                        enableMemoryCache: true,
                                        borderRadius: BorderRadius.circular(8),
                                        fit: BoxFit.cover,
                                      )
                                          : ExtendedImage.asset(
                                        assetFoundCrew,
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
                                          child: Row(
                                            children: [
                                              Text('${foundCrewModel!.crewName}',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 2,),
                                        Row(
                                          children: [
                                            Text('${foundCrewModel!.baseResortNickName}',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: Colors.white
                                              ),),
                                          ],
                                        ),
                                        SizedBox(height: 14,),
                                        Container(
                                          height: 1,
                                          width: _size.width- 136,
                                          color: Colors.black12,
                                        ),
                                        SizedBox(height: 14,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('생성일', style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.white60,
                                            ),),
                                            Text('${_timeStampController.yyyymmddFormat(foundCrewModel!.resistDate).toString()}', style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white
                                            ),),
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
                                ),
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
                          child: Text('크루명 전체를 정확히 입력해야 검색이 완료됩니다.', style: TextStyle(
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
                                  padding: EdgeInsets.only(top: 16, bottom: MediaQuery.of(context).viewInsets.bottom + 16, right: 5),
                                  child: TextButton(
                                      onPressed: () async{
                                        CustomFullScreenDialog.showDialog();
                                        await _liveCrewModelController.getCurrnetCrew(foundCrewID);
                                        CustomFullScreenDialog.cancelDialog();
                                        Get.to(()=> CrewDetailPage_screen());
                                      },
                                      style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(6))),
                                        elevation: 0,
                                        splashFactory: InkRipple.splashFactory,
                                        minimumSize: Size(1000, 56),
                                        backgroundColor:
                                        (isFound) ? Color(foundCrewModel!.crewColor!).withOpacity(0.2) : Color(0xffDEDEDE),
                                      ),
                                      child: Text('크루 보기',
                                        style: TextStyle(
                                            color: (isFound) ? Color(foundCrewModel!.crewColor!) : Color(0xffFFFFFF),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      )
                                  )),
                            ),
                            if(foundCrewID != _userModelController.liveCrew)
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 16, left: 5, top: 16),
                                child: TextButton(
                                    onPressed: () async {
                                      Get.dialog(AlertDialog(
                                        contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0)),
                                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                        content: Text(
                                          '${foundCrewModel!.crewName}에 가입하시겠습니까?',
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
                                              : Column(
                                            children: [
                                              ElevatedButton(
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
                                                                      Get.snackbar(
                                                                        '가입신청 완료',
                                                                        '신청 목록은 라이브크루 페이지에서 확인하실 수 있습니다.',
                                                                        margin: EdgeInsets.only(right: 20, left: 20, bottom: 12),
                                                                        snackPosition: SnackPosition.BOTTOM,
                                                                        backgroundColor: Colors.black87,
                                                                        colorText: Colors.white,
                                                                        duration: Duration(milliseconds: 3000),
                                                                      );
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
                                                  style: TextButton.styleFrom(
                                                      shape: const RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.all(Radius.circular(6))),
                                                      elevation: 0,
                                                      splashFactory: InkRipple.splashFactory,
                                                      minimumSize: Size(1000, 48),
                                                      backgroundColor: Color(0xff377EEA)

                                                  ),
                                                  child: Text(
                                                    '가입신청',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0xffffffff),
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
                                                      color: Color(0xff949494),
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ))
                                            ],
                                            mainAxisAlignment: MainAxisAlignment.center,
                                          )
                                        ],
                                      ));
                                    },
                                    style: TextButton.styleFrom(
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(6))),
                                        elevation: 0,
                                        splashFactory: InkRipple.splashFactory,
                                        minimumSize: Size(1000, 56),
                                        backgroundColor: (isFound) ? Color(foundCrewModel!.crewColor!) : Color(0xffDEDEDE)),
                                    child: Text(
                                      '크루 가입하기',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
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
