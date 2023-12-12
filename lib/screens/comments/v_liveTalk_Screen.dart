import 'dart:io';
import 'package:com.snowlive/controller/vm_resortModelController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/model/m_resortModel.dart';
import 'package:com.snowlive/screens/comments/v_modify_liveTalk.dart';
import 'package:com.snowlive/screens/more/friend/v_snowliveDetailPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:com.snowlive/screens/comments/v_noUserScreen.dart';
import 'package:com.snowlive/screens/comments/v_profileImageScreen.dart';
import 'package:com.snowlive/screens/comments/v_reply_Screen.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import '../../controller/vm_alarmCenterController.dart';
import '../../controller/vm_allUserDocsController.dart';
import '../../controller/vm_commentController.dart';
import '../../controller/vm_userModelController.dart';
import '../../model/m_alarmCenterModel.dart';
import '../../widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/controller/vm_imageController.dart';


class LiveTalkScreen extends StatefulWidget {
  const LiveTalkScreen({Key? key}) : super(key: key);

  @override
  State<LiveTalkScreen> createState() =>
      _LiveTalkScreenState();
}


class _LiveTalkScreenState extends State<LiveTalkScreen> {
  final _controller = TextEditingController();
  var _newComment = '';
  final _formKey = GlobalKey<FormState>();
  var _firstPress = true;
  bool livetalkImage = false;
  XFile? _imageFile;
  bool anony = false;

  var _selectedValue = '필터';
  var _selectedValue2 = '전체';
  var _selectedValue3 = '전체';
  var _allCategories;
  var _alluser;
  var _selectedKusbfName = '필터';

  int counter = 0;
  List<bool> isTap = [
    true,
    false,
    false,
    false,
    false
  ];
  List checkUidList = [];


  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  CommentModelController _commentModelController = Get.find<CommentModelController>();
  ResortModelController _resortModelController = Get.find<ResortModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
  //TODO: Dependency Injection**************************************************

  var _stream;
  var _noticeAlarmStream;
  bool _isVisible = false;
  bool _isTabKusbf = false;


  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _imageFile = null;
    _updateMethod();
    _updateMethodComment();
    // TODO: implement initState
    super.initState();
    _seasonController.getLiveTalkLimit();
    _stream = newStream();
    _noticeAlarmStream = newAlarm_liveTalk_notice_stream();
    _scrollController.addListener(() {
      setState(() {
        if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
          _isVisible = true;
        } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward ||
            _scrollController.position.pixels <=
                _scrollController.position.maxScrollExtent) {
          _isVisible = false;
        }
      });
    });

    try{
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_liveTalk',
        parameters: <String, dynamic>{
          'user_id': _userModelController.uid,
          'user_name': _userModelController.displayName,
          'user_resort': _userModelController.favoriteResort
        },
      );
    }catch(e, stackTrace){
      print('GA 업데이트 오류: $e');
      print('Stack trace: $stackTrace');
    }

  }

  @override
  void dispose() {
    _allUserDocsController.stopListening();
    super.dispose();
  }


  _updateMethod() async {
    await _userModelController.updateRepoUidList();
  }

  _updateMethodComment() async {
    await _userModelController.updateLikeUidList();
  }

  Stream<QuerySnapshot> newStream() {
    return FirebaseFirestore.instance
        .collection('liveTalk')
        .where('uid', isEqualTo: (_selectedValue3 == '전체') ? _alluser : _userModelController.uid)
        .where('displayName', isEqualTo: (_selectedValue2 == '전체') ? _alluser : 'SNOWLIVE')
        .where(_isTabKusbf == false ? 'resortNickname' : 'liveCrew', isEqualTo: (_selectedValue == '필터') ? _allCategories : '$_selectedValue')
        .where('kusbf', isEqualTo: (_isTabKusbf == true) ? true : false)
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.liveTalkLimit!)
        .snapshots();
  }

  Stream<QuerySnapshot> newAlarm_liveTalk_notice_stream() {
    return FirebaseFirestore.instance
        .collection('newAlarm_liveTalk_notice')
        .snapshots();
  }

  _showCupertinoPicker() async {
    List resortList = nicknameList; // 리조트 리스트 가져오기

    await showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 520,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      for (int i = 0; i < isTap.length; i++) {
                        isTap[i] = false;
                      }
                      isTap[0] = true;
                      _selectedValue = '필터';
                      _selectedValue2 = '전체';
                      _selectedValue3 = '전체';
                      _isVisible = false;
                    });
                    Navigator.pop(context);
                  },
                  child: Text('전체'),
                ),
                for (String resortName in resortList)
                  CupertinoActionSheetAction(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        for (int i = 0; i < isTap.length; i++) {
                          isTap[i] = false;
                        }
                        isTap[4] = true; // 또는 다른 인덱스로 선택
                        _selectedValue = resortName;
                        _selectedValue2 = '전체';
                        _selectedValue3 = '전체';
                        _isVisible = false;
                      });
                      Navigator.pop(context);
                    },
                    child: Text(resortName),
                  ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text('닫기'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      _stream = newStream();
    });
  }

  _showCupertinoPickerKusbf() async {
    List kusbfList = _userModelController.kusbfArray;
    Map<String, dynamic> kusbfName = _userModelController.kusbfNameMap;

    await showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            height: 520,
            padding: EdgeInsets.only(left: 16, right: 16),
            child: CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      for (int i = 0; i < isTap.length; i++) {
                        isTap[i] = false;
                      }
                      isTap[0] = true;
                      _selectedValue = '필터';
                      _selectedValue2 = '전체';
                      _selectedValue3 = '전체';
                      _isVisible = false;
                      _selectedKusbfName = '필터';
                    });
                    Navigator.pop(context);
                  },
                  child: Text('전체'),
                ),
                for (String kusbfID in kusbfList)
                  CupertinoActionSheetAction(
                    onPressed: () async{
                      HapticFeedback.lightImpact();
                      setState(() {
                        for (int i = 0; i < isTap.length; i++) {
                          isTap[i] = false;
                        }
                        isTap[4] = true; // 또는 다른 인덱스로 선택
                        _selectedValue = kusbfID;
                        _selectedValue2 = '전체';
                        _selectedValue3 = '전체';
                        _isVisible = false;
                        _selectedKusbfName = kusbfName[kusbfID];
                      });
                      Navigator.pop(context);
                    },
                    child: Text(kusbfName[kusbfID] ?? ''),
                  ),
              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text('닫기'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        );
      },
    );

    setState(() {
      _stream = newStream();
    });
  }


  Future<void> _refreshData() async {
    await _allUserDocsController.getAllUserDocs();
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {
    Get.put(ImageController(), permanent: true);
    ImageController _imageController = Get.find<ImageController>();

    _seasonController.getLiveTalkLimit();

    Size _size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(58),
              child: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: false,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: (){
                          print('전체톡으로 전환');
                          setState(() {
                            _isTabKusbf = false;
                            isTap[0] = true;
                            isTap[1] = false;
                            isTap[2] = false;
                            isTap[3] = false;
                            isTap[4] = false;
                            _selectedValue = '필터';
                            _selectedValue2 = '전체';
                            _selectedValue3 = '전체';
                            _isVisible = false;
                          });
                          _stream = newStream();
                        },
                        child: Text(
                          '라이브톡',
                          style: TextStyle(
                              fontFamily: 'Spoqa Han Sans Neo',
                              color: (_isTabKusbf == false)
                                  ? Color(0xFF111111)
                                  : Color(0xFFC8C8C8),
                              fontWeight: (_isTabKusbf == false)
                                  ? FontWeight.bold
                                  : FontWeight.bold,
                              fontSize: 20),
                        ),
                      ),
                      SizedBox(width: 15,),
                      if(_userModelController.kusbf == true)
                        GestureDetector(
                          onTap: (){
                            print('KUSBF톡으로 전환');
                            setState(() {
                              _isTabKusbf = true;
                              isTap[0] = true;
                              isTap[1] = false;
                              isTap[2] = false;
                              isTap[3] = false;
                              isTap[4] = false;
                              _selectedValue = '필터';
                              _selectedValue2 = '전체';
                              _selectedValue3 = '전체';
                              _isVisible = false;
                            });
                            _stream = newStream();
                          },
                          child: Opacity(
                            opacity: (_isTabKusbf ==true)?1.0:0.2,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: ExtendedImage.network(
                                '${KusbfAssetUrlList[0].mainLogo}',
                                enableMemoryCache: true,
                                shape: BoxShape.rectangle,
                                width: 66,
                                fit: BoxFit.cover,
                                loadStateChanged: (ExtendedImageState state) {
                                  switch (state.extendedImageLoadState) {
                                    case LoadState.loading:
                                      return SizedBox.shrink();
                                    default:
                                      return null;
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                backgroundColor: Colors.white,
                elevation: 0.0,
              ),
            ),
            body: RefreshIndicator(
              onRefresh: _refreshData,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 16.0, left: 16, right: 16),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              physics: AlwaysScrollableScrollPhysics(),
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        isTap[0] = true;
                                        isTap[1] = false;
                                        isTap[2] = false;
                                        isTap[3] = false;
                                        isTap[4] = false;
                                        _selectedValue = '필터';
                                        _selectedValue2 = '전체';
                                        _selectedValue3 = '전체';
                                        _isVisible = false;
                                        _stream = newStream();
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[0] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[0] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        height: 32,
                                        child: Text('# 전체',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: (isTap[0] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                          ),)
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  (_isTabKusbf == false)
                                      ? GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        isTap[0] = false;
                                        isTap[1] = true;
                                        isTap[2] = false;
                                        isTap[3] = false;
                                        isTap[4] = false;
                                        _selectedValue = '${_userModelController.resortNickname}';
                                        _selectedValue2 = '전체';
                                        _selectedValue3 = '전체';
                                        _isVisible = false;
                                        _stream = newStream();
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[1] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[1] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        height: 32,
                                        child: Text('# 자주가는',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: (isTap[1] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                          ),)
                                    ),
                                  )
                                      : GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        isTap[0] = false;
                                        isTap[1] = true;
                                        isTap[2] = false;
                                        isTap[3] = false;
                                        isTap[4] = false;
                                        _selectedValue = '${_userModelController.liveCrew}';
                                        _selectedValue2 = '전체';
                                        _selectedValue3 = '전체';
                                        _isVisible = false;
                                        _stream = newStream();
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[1] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[1] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        height: 32,
                                        child: Text('# 내크루',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: (isTap[1] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                          ),)
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                      onTap: () async{

                                        setState(() {
                                          HapticFeedback.lightImpact();
                                          isTap[0] = false;
                                          isTap[1] = false;
                                          isTap[2] = true;
                                          isTap[3] = false;
                                          isTap[4] = false;
                                          _selectedValue = '필터';
                                          _selectedValue2 = 'SNOWLIVE';
                                          _selectedValue3 = '전체';
                                          _isVisible = false;
                                          _stream = newStream();
                                        });
                                        await _commentModelController.addCheckUid(_userModelController.uid);
                                        print(_selectedValue2);
                                      },
                                      child:
                                      StreamBuilder<QuerySnapshot>(
                                          stream: _noticeAlarmStream,
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Container(
                                                  decoration: BoxDecoration(
                                                    color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    border: Border.all(
                                                        color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  height: 32,
                                                  child: Text('# 소식',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: (isTap[2] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                                    ),)
                                              );
                                            }
                                            else if (snapshot.connectionState == ConnectionState.waiting) {
                                              return Container(
                                                  decoration: BoxDecoration(
                                                    color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    border: Border.all(
                                                        color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  height: 32,
                                                  child: Text('# 소식',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: (isTap[2] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                                    ),)
                                              );
                                            }
                                            else if (snapshot.data!.docs.isEmpty){
                                              return Container(
                                                  decoration: BoxDecoration(
                                                    color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                                    borderRadius: BorderRadius.circular(30.0),
                                                    border: Border.all(
                                                        color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  height: 32,
                                                  child: Text('# 소식',
                                                    style: TextStyle(
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                        color: (isTap[2] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                                    ),)
                                              );
                                            }
                                            checkUidList = snapshot.data!.docs[0]['checkUidList'];
                                            return Stack(
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                                      borderRadius: BorderRadius.circular(30.0),
                                                      border: Border.all(
                                                          color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    height: 32,
                                                    child: Text('# 소식',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.bold,
                                                          color: (isTap[2] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                                      ),)
                                                ),
                                                if(checkUidList.contains(_userModelController.uid)==false)
                                                  Positioned(
                                                    top: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFFD6382B),
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Text('N',
                                                        style: TextStyle(
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                            color: Color(0xFFFFFFFF)
                                                        ),

                                                      ),
                                                    ),
                                                  )
                                              ],
                                            );
                                          })
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        HapticFeedback.lightImpact();
                                        isTap[0] = false;
                                        isTap[1] = false;
                                        isTap[2] = false;
                                        isTap[3] = true;
                                        isTap[4] = false;
                                        _selectedValue = '필터';
                                        _selectedValue2 = '전체';
                                        _selectedValue3 = '${_userModelController.uid}';
                                        _isVisible = false;
                                        _stream = newStream();
                                      });
                                      print(_selectedValue3);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[3] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[3] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        height: 32,
                                        child: Text('# 내글',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: (isTap[3] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
                                          ),)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          (_isTabKusbf == false)
                              ?GestureDetector(
                            onTap: () async{
                              await _showCupertinoPicker();
                            },
                            child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: (isTap[4] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: (isTap[4] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    height: 32,
                                    child:(isTap[4] == true)
                                        ? Text(_selectedValue,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: (isTap[4] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)))
                                        : Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child:  ExtendedImage.network(
                                            '${IconAssetUrlList[0].filter}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            width: 12,
                                            loadStateChanged: (ExtendedImageState state) {
                                              switch (state.extendedImageLoadState) {
                                                case LoadState.loading:
                                                  return SizedBox.shrink();
                                                default:
                                                  return null;
                                              }
                                            },
                                          ),
                                        ),
                                        Text('필터',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF777777)))
                                      ],
                                    )

                                ),
                              ),
                            ),

                          )
                              :GestureDetector(
                            onTap: () async{
                              await _showCupertinoPickerKusbf();
                            },
                            child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: (isTap[4] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: (isTap[4] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    height: 32,
                                    child:(isTap[4] == true)
                                        ? Text(_selectedKusbfName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: (isTap[4] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)))
                                        : Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 4),
                                          child:  ExtendedImage.network(
                                            '${IconAssetUrlList[0].filter}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            width: 12,
                                            loadStateChanged: (ExtendedImageState state) {
                                              switch (state.extendedImageLoadState) {
                                                case LoadState.loading:
                                                  return SizedBox.shrink();
                                                default:
                                                  return null;
                                              }
                                            },
                                          ),
                                        ),
                                        Text('필터',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF777777)))
                                      ],
                                    )

                                ),
                              ),
                            ),

                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Color(0xFFF1F1F3),
                      child: Stack(
                        children: [
                          StreamBuilder<QuerySnapshot>(
                            stream: _stream,
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  color: Colors.white,
                                );
                              }
                              else if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              else if (snapshot.data!.docs.isEmpty){
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/imgs/icons/icon_nodata_white.png',
                                      scale: 4,
                                      width: 73,
                                      height: 73,
                                    ),
                                    SizedBox(height: 6,),
                                    Text('라이브톡이 없습니다.',
                                      style: TextStyle(
                                          color: Color(0xFF666666)
                                      ),
                                    ),
                                  ],
                                );
                              }
                              final chatDocs = snapshot.data!.docs;
                              return ListView.builder(
                                controller: _scrollController,
                                reverse: false,
                                itemCount: chatDocs.length,
                                itemBuilder: (context, index) {

                                  Map<String, dynamic>? data = chatDocs[index].data() as Map<String, dynamic>?;

                                  // 필드가 없을 경우 기본값 설정
                                  bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;


                                  String _time = _commentModelController
                                      .getAgoTime(chatDocs[index].get('timeStamp'));

                                  String? profileUrl = _allUserDocsController.findProfileUrl(chatDocs[index]['uid'], _allUserDocsController.allUserDocs);
                                  String? displayName = _allUserDocsController.findDisplayName(chatDocs[index]['uid'], _allUserDocsController.allUserDocs);
                                  return Padding(
                                    padding:
                                    const EdgeInsets.only(
                                        top:12, left: 12, right: 12),
                                    child: Obx(() =>
                                        Container(
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              (isLocked ==true)
                                                  ? Center(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius: BorderRadius
                                                          .circular(8)
                                                  ),
                                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text(
                                                        '운영자에 의해 차단된 게시글입니다.',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.normal,
                                                            fontSize: 13,
                                                            color: Color(0xff949494)),
                                                      ),
                                                      if(_userModelController.displayName == 'SNOWLIVE')
                                                        GestureDetector(
                                                          onTap: () =>
                                                              showModalBottomSheet(
                                                                  enableDrag: false,
                                                                  context: context,
                                                                  builder: (context) {
                                                                    return Container(
                                                                      height: 100,
                                                                      child:Padding(
                                                                        padding: const EdgeInsets
                                                                            .symmetric(
                                                                            horizontal: 20.0,
                                                                            vertical: 14),
                                                                        child: Column(
                                                                          children: [
                                                                            GestureDetector(
                                                                              child: ListTile(
                                                                                contentPadding: EdgeInsets.zero,
                                                                                title: Center(
                                                                                  child: Text(
                                                                                    (isLocked == false)
                                                                                        ? '게시글 잠금' : '게시글 잠금 해제',
                                                                                    style: TextStyle(
                                                                                        fontSize: 15,
                                                                                        fontWeight: FontWeight.bold,
                                                                                        color: Color(0xFFD63636)
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                //selected: _isSelected[index]!,
                                                                                onTap: () async {
                                                                                  Navigator.pop(context);
                                                                                  showModalBottomSheet(
                                                                                      context: context,
                                                                                      builder: (context) {
                                                                                        return Container(
                                                                                          color: Colors.white,
                                                                                          height: 180,
                                                                                          child: Padding(
                                                                                            padding: const EdgeInsets.symmetric(
                                                                                                horizontal: 20.0),
                                                                                            child: Column(
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                                              children: [
                                                                                                SizedBox(
                                                                                                  height: 30,
                                                                                                ),
                                                                                                Text(
                                                                                                  (isLocked==false)
                                                                                                      ? '이 게시글을 잠그시겠습니까?' : '이 게시글의 잠금을 해제하시겠습니까?',
                                                                                                  style: TextStyle(
                                                                                                      fontSize: 20,
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                      color: Color(0xFF111111)),
                                                                                                ),
                                                                                                SizedBox(
                                                                                                  height: 30,
                                                                                                ),
                                                                                                Row(
                                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                  children: [
                                                                                                    Expanded(
                                                                                                      child: ElevatedButton(
                                                                                                        onPressed: () {
                                                                                                          Navigator.pop(context);
                                                                                                        },
                                                                                                        child: Text(
                                                                                                          '취소',
                                                                                                          style: TextStyle(
                                                                                                              color: Colors.white,
                                                                                                              fontSize: 15,
                                                                                                              fontWeight: FontWeight.bold),
                                                                                                        ),
                                                                                                        style: TextButton.styleFrom(
                                                                                                            splashFactory: InkRipple.splashFactory,
                                                                                                            elevation: 0,
                                                                                                            minimumSize: Size(100, 56),
                                                                                                            backgroundColor: Color(0xff555555),
                                                                                                            padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                      ),
                                                                                                    ),
                                                                                                    SizedBox(
                                                                                                      width: 10,
                                                                                                    ),
                                                                                                    Expanded(
                                                                                                      child: ElevatedButton(
                                                                                                        onPressed: () async {
                                                                                                          if (data?.containsKey('lock') == false) {
                                                                                                            await chatDocs[index].reference.update({'lock': false});
                                                                                                          }
                                                                                                          CustomFullScreenDialog.showDialog();
                                                                                                          await _commentModelController.lock('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}');
                                                                                                          Navigator.pop(context);
                                                                                                          CustomFullScreenDialog.cancelDialog();
                                                                                                        },
                                                                                                        child: Text('확인',
                                                                                                          style: TextStyle(
                                                                                                              color: Colors.white,
                                                                                                              fontSize: 15,
                                                                                                              fontWeight: FontWeight.bold),
                                                                                                        ),
                                                                                                        style: TextButton.styleFrom(
                                                                                                            splashFactory: InkRipple.splashFactory,
                                                                                                            elevation: 0,
                                                                                                            minimumSize: Size(100, 56),
                                                                                                            backgroundColor: Color(0xff2C97FB),
                                                                                                            padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                          child: Icon(Icons.more_horiz,
                                                            color: Color(0xFFdedede),
                                                            size: 20,
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              )
                                                  : ( (_userModelController.repoUidList!.contains(chatDocs[index].get('uid')) && chatDocs[index].get('displayName') !='익명' )
                                                  || _userModelController.liveTalkHideList!.contains('${chatDocs[index].get('uid')}${chatDocs[index].get('commentCount')}'))
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
                                                        .symmetric(
                                                        vertical: 12),
                                                    child: Text(
                                                      '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                                      style: TextStyle(
                                                          fontWeight:
                                                          FontWeight.normal,
                                                          fontSize: 12,
                                                          color:
                                                          Color(0xffc8c8c8)),
                                                    ),
                                                  ),
                                                ),
                                              )
                                                  : Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 14),
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius
                                                        .circular(8)
                                                ),
                                                width: _size.width - 24,
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(horizontal: 16),
                                                          child: Container(
                                                            width: _size.width - 56,
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Row(
                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                                  children: [
                                                                    if (profileUrl != "" && chatDocs[index]['profileImageUrl']  != "anony" && chatDocs[index]['displayName'] != 'SNOWLIVE')
                                                                      GestureDetector(
                                                                        onTap: () async {
                                                                          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                                                                              .collection('user')
                                                                              .where('uid', isEqualTo: chatDocs[index]['uid'])
                                                                              .get();

                                                                          if (userQuerySnapshot.docs.isNotEmpty) {
                                                                            DocumentSnapshot userDoc = userQuerySnapshot.docs.first;
                                                                            int favoriteResort = userDoc['favoriteResort'];
                                                                            print(favoriteResort);
                                                                            print(chatDocs[index]['uid']);

                                                                            Get.to(() => FriendDetailPage(uid: chatDocs[index]['uid'], favoriteResort: favoriteResort,));
                                                                          } else {
                                                                            Get.to(()=>NoUserScreen());
                                                                          }
                                                                        },
                                                                        child: Container(
                                                                          width: 24,
                                                                          height: 24,
                                                                          decoration: BoxDecoration(
                                                                              color: Color(0xFFDFECFF),
                                                                              borderRadius: BorderRadius.circular(50)
                                                                          ),
                                                                          child: ExtendedImage.network(
                                                                            profileUrl,
                                                                            cache: true,
                                                                            shape: BoxShape.circle,
                                                                            borderRadius: BorderRadius.circular(20),
                                                                            width: 24,
                                                                            height: 24,
                                                                            fit: BoxFit.cover,
                                                                            loadStateChanged: (ExtendedImageState state) {
                                                                              switch (state.extendedImageLoadState) {
                                                                                case LoadState.loading:
                                                                                  return SizedBox.shrink();
                                                                                case LoadState.completed:
                                                                                  return state.completedWidget;
                                                                                case LoadState.failed:
                                                                                  return ExtendedImage.network(
                                                                                    '${profileImgUrlList[0].default_round}',
                                                                                    shape: BoxShape.circle,
                                                                                    borderRadius: BorderRadius.circular(20),
                                                                                    width: 24,
                                                                                    height: 24,
                                                                                    fit: BoxFit.cover,
                                                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                                default:
                                                                                  return null;
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),

                                                                      ),
                                                                    if (profileUrl == "" && chatDocs[index]['profileImageUrl'] != "anony" && chatDocs[index]['displayName'] != 'SNOWLIVE')
                                                                      GestureDetector(
                                                                        onTap: () async {
                                                                          QuerySnapshot userQuerySnapshot = await FirebaseFirestore.instance
                                                                              .collection('user')
                                                                              .where('uid', isEqualTo: chatDocs[index]['uid'])
                                                                              .get();

                                                                          if (userQuerySnapshot.docs.isNotEmpty) {
                                                                            DocumentSnapshot userDoc = userQuerySnapshot.docs.first;
                                                                            int favoriteResort = userDoc['favoriteResort'];
                                                                            print(favoriteResort);
                                                                            print(chatDocs[index]['uid']);

                                                                            Get.to(() => FriendDetailPage(uid: chatDocs[index]['uid'], favoriteResort: favoriteResort,));
                                                                          } else {
                                                                            Get.to(()=>NoUserScreen());
                                                                          }
                                                                        },
                                                                        child: ExtendedImage.network(
                                                                          '${profileImgUrlList[0].default_round}',
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          width: 24,
                                                                          height: 24,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    if (chatDocs[index]['profileImageUrl'] == "anony" && chatDocs[index]['displayName'] != 'SNOWLIVE')
                                                                      GestureDetector(
                                                                        onTap: () async {},
                                                                        child: ExtendedImage.network(
                                                                          '${profileImgUrlList[0].anony_round}',
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          width: 24,
                                                                          height: 24,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    if (chatDocs[index]['profileImageUrl']!= '' && chatDocs[index]['profileImageUrl']  != "anony" && chatDocs[index]['displayName'] == 'SNOWLIVE')
                                                                      GestureDetector(
                                                                        onTap: () async {
                                                                          Get.to(()=>SnowliveDetailPage());
                                                                        },
                                                                        child: ExtendedImage.network(
                                                                          profileUrl,
                                                                          cache: true,
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          width: 24,
                                                                          height: 24,
                                                                          fit: BoxFit.cover,
                                                                          loadStateChanged: (ExtendedImageState state) {
                                                                            switch (state.extendedImageLoadState) {
                                                                              case LoadState.loading:
                                                                                return SizedBox.shrink();
                                                                              case LoadState.completed:
                                                                                return state.completedWidget;
                                                                              case LoadState.failed:
                                                                                return ExtendedImage.network(
                                                                                  '${profileImgUrlList[0].default_round}',
                                                                                  shape: BoxShape.circle,
                                                                                  borderRadius: BorderRadius.circular(20),
                                                                                  width: 24,
                                                                                  height: 24,
                                                                                  fit: BoxFit.cover,
                                                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                              default:
                                                                                return null;
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    SizedBox(width: 8),
                                                                    Padding(
                                                                        padding: EdgeInsets.only(bottom: 1),
                                                                        child:
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              (chatDocs[index]['displayName'] != "익명")
                                                                                  ? displayName
                                                                                  : chatDocs[index]['displayName'],
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight.bold,
                                                                                  fontSize: 12,
                                                                                  color:
                                                                                  (displayName == '회원정보 없음')? Color(0xFFb7b7b7): Color(0xFF111111)),
                                                                            ),
                                                                            if(chatDocs[index]['displayName'] == 'SNOWLIVE')
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left : 2.0, bottom: 1),
                                                                                child: Image.asset(
                                                                                  'assets/imgs/icons/icon_snowlive_operator.png',
                                                                                  scale: 5.5,
                                                                                ),
                                                                              ),
                                                                            SizedBox(
                                                                                width: 8),
                                                                            if(chatDocs[index]['displayName'] != 'SNOWLIVE')
                                                                              Text(_isTabKusbf == true
                                                                                  ? '${_userModelController.kusbfNameMap[chatDocs[index].get('liveCrew')]}'
                                                                                  : chatDocs[index].get('resortNickname'),
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.w300,
                                                                                    fontSize: 12,
                                                                                    color: Color(0xFF949494)),
                                                                              ),

                                                                          ],
                                                                        )
                                                                    ),
                                                                  ],
                                                                ),
                                                                (chatDocs[index]['uid'] != _userModelController.uid)
                                                                    ? GestureDetector(
                                                                  onTap: () =>
                                                                      showModalBottomSheet(
                                                                          enableDrag: false,
                                                                          context: context,
                                                                          builder: (context) {
                                                                            return SafeArea(
                                                                              child: Container(
                                                                                height:
                                                                                (_userModelController.displayName == 'SNOWLIVE')
                                                                                    ? 260
                                                                                    : 140,
                                                                                child: Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                                                  child: Column(
                                                                                    children: [
                                                                                      GestureDetector(
                                                                                        child: ListTile(
                                                                                          contentPadding: EdgeInsets.zero,
                                                                                          title: Center(
                                                                                            child: Text(
                                                                                              '신고하기',
                                                                                              style: TextStyle(
                                                                                                fontSize: 15,
                                                                                                fontWeight: FontWeight.bold,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          //selected: _isSelected[index]!,
                                                                                          onTap: () async {
                                                                                            Get.dialog(
                                                                                                AlertDialog(
                                                                                                  contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                  elevation: 0,
                                                                                                  shape: RoundedRectangleBorder(
                                                                                                      borderRadius: BorderRadius.circular(10.0)),
                                                                                                  buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                  content: Text(
                                                                                                    '이 회원을 신고하시겠습니까?',
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
                                                                                                            child: Text('취소',
                                                                                                              style: TextStyle(
                                                                                                                fontSize: 15,
                                                                                                                color: Color(0xFF949494),
                                                                                                                fontWeight: FontWeight.bold,
                                                                                                              ),
                                                                                                            )),
                                                                                                        TextButton(
                                                                                                            onPressed: () async {var repoUid = chatDocs[index].get('uid');
                                                                                                            await _userModelController.repoUpdate(repoUid);
                                                                                                            Navigator.pop(context);
                                                                                                            Navigator.pop(context);
                                                                                                            },
                                                                                                            child: Text(
                                                                                                              '신고',
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
                                                                                          },
                                                                                          shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius.circular(
                                                                                                  10)),
                                                                                        ),
                                                                                      ),
                                                                                      if(chatDocs[index]['displayName'] != '익명')
                                                                                        GestureDetector(
                                                                                          child: ListTile(
                                                                                            contentPadding: EdgeInsets.zero,
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
                                                                                              Get.dialog(
                                                                                                  AlertDialog(
                                                                                                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                    elevation: 0,
                                                                                                    shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(10.0)),
                                                                                                    buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                    content: Container(
                                                                                                      height: _size.width*0.17,
                                                                                                      child: Column(
                                                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                        children: [
                                                                                                          Text(
                                                                                                            '이 회원의 게시물을 모두 숨길까요?',
                                                                                                            style: TextStyle(
                                                                                                                fontWeight: FontWeight.w600,
                                                                                                                fontSize: 15),
                                                                                                          ),
                                                                                                          SizedBox(
                                                                                                            height: 10,
                                                                                                          ),
                                                                                                          Text(
                                                                                                            '차단해제는 [더보기 - 친구 - 설정 - 차단목록]에서\n하실 수 있습니다.',
                                                                                                            style: TextStyle(
                                                                                                                fontWeight: FontWeight.w600,
                                                                                                                fontSize: 12,
                                                                                                                color: Color(0xFF555555)),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
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
                                                                                                              onPressed: () {
                                                                                                                var repoUid = chatDocs[index].get('uid');
                                                                                                                _userModelController.updateRepoUid(repoUid);
                                                                                                                Navigator.pop(context);
                                                                                                                Navigator.pop(context);
                                                                                                              },
                                                                                                              child: Text('확인',
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
                                                                                            },
                                                                                            shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.circular(10)),
                                                                                          ),
                                                                                        ),
                                                                                      if(chatDocs[index]['displayName'] == '익명')
                                                                                        GestureDetector(
                                                                                          child: ListTile(
                                                                                            contentPadding: EdgeInsets.zero,
                                                                                            title: Center(
                                                                                              child: Text(
                                                                                                '이 글 숨기기',
                                                                                                style: TextStyle(
                                                                                                  fontSize: 15,
                                                                                                  fontWeight: FontWeight
                                                                                                      .bold,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                            //selected: _isSelected[index]!,
                                                                                            onTap: () async {
                                                                                              Get.dialog(
                                                                                                  AlertDialog(
                                                                                                    contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                    elevation: 0,
                                                                                                    shape: RoundedRectangleBorder(
                                                                                                        borderRadius: BorderRadius.circular(10.0)),
                                                                                                    buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                    content: Text(
                                                                                                      '이 글을 숨기시겠습니까?\n이 동작은 취소할 수 없습니다.',
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
                                                                                                                '취소',
                                                                                                                style: TextStyle(
                                                                                                                  fontSize: 15,
                                                                                                                  color: Color(0xFF949494),
                                                                                                                  fontWeight: FontWeight.bold,
                                                                                                                ),
                                                                                                              )),
                                                                                                          TextButton(
                                                                                                              onPressed: () async{
                                                                                                                var repoUid = chatDocs[index].get('uid');
                                                                                                                var commentCount = chatDocs[index].get('commentCount');
                                                                                                                await _userModelController.updateHideList('${repoUid}${commentCount}');
                                                                                                                await _userModelController.getCurrentUser(_userModelController.uid);
                                                                                                                Navigator.pop(context);
                                                                                                                Navigator.pop(context);
                                                                                                              },
                                                                                                              child: Text('확인',
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
                                                                                            },
                                                                                            shape: RoundedRectangleBorder(
                                                                                                borderRadius: BorderRadius.circular(10)),
                                                                                          ),
                                                                                        ),
                                                                                      if(_userModelController.displayName == 'SNOWLIVE')
                                                                                        Column(
                                                                                          children: [
                                                                                            GestureDetector(
                                                                                              child: ListTile(
                                                                                                contentPadding: EdgeInsets.zero,
                                                                                                title: Center(
                                                                                                  child: Text(
                                                                                                    (isLocked ==false)
                                                                                                        ? '게시글 잠금' : '게시글 잠금 해제',
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
                                                                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                        elevation: 0,
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(10.0)),
                                                                                                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                        content: Text(
                                                                                                          (isLocked ==false)
                                                                                                              ? '이 게시글을 잠그시겠습니까?' : '게시글 잠금을 해제하시겠습니까?',
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
                                                                                                                    '취소',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 15,
                                                                                                                      color: Color(0xFF949494),
                                                                                                                      fontWeight: FontWeight.bold,
                                                                                                                    ),
                                                                                                                  )),
                                                                                                              TextButton(
                                                                                                                  onPressed: () async{
                                                                                                                    if (data?.containsKey('lock') == false) {
                                                                                                                      await chatDocs[index].reference.update({'lock': false});
                                                                                                                    }
                                                                                                                    await _commentModelController.lock('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}');
                                                                                                                    Navigator.pop(context);
                                                                                                                    Navigator.pop(context);
                                                                                                                  },
                                                                                                                  child: Text('확인',
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
                                                                                                },
                                                                                                shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(10)),
                                                                                              ),
                                                                                            ),
                                                                                            GestureDetector(
                                                                                              child: ListTile(
                                                                                                contentPadding: EdgeInsets.zero,
                                                                                                title: Center(
                                                                                                  child: Text(
                                                                                                    '게시글 수정',
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 15,
                                                                                                      fontWeight: FontWeight
                                                                                                          .bold,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                //selected: _isSelected[index]!,
                                                                                                onTap: () async {
                                                                                                  Get.dialog(
                                                                                                      AlertDialog(
                                                                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                        elevation: 0,
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(10.0)),
                                                                                                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                        content: Text(
                                                                                                          '이 게시글을 수정하시겠습니까?',
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
                                                                                                                    '취소',
                                                                                                                    style: TextStyle(
                                                                                                                      fontSize: 15,
                                                                                                                      color: Color(0xFF949494),
                                                                                                                      fontWeight: FontWeight.bold,
                                                                                                                    ),
                                                                                                                  )),
                                                                                                              TextButton(
                                                                                                                  onPressed: () async{
                                                                                                                    await _commentModelController.getCurrentLiveTalk(uid: chatDocs[index]['uid'],commentCount: chatDocs[index]['commentCount'],);
                                                                                                                    Navigator.pop(context);
                                                                                                                    Navigator.pop(context);
                                                                                                                    Get.to(()=>Modify_liveTalk());
                                                                                                                  },
                                                                                                                  child: Text('확인',
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
                                                                                                },
                                                                                                shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(10)),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                  child: Icon(
                                                                    Icons.more_horiz,
                                                                    color: Color(0xFFdedede),
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
                                                                              height: (_userModelController.displayName == 'SNOWLIVE')
                                                                                  ? 260
                                                                                  : 160,
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                    horizontal: 20.0, vertical: 14),
                                                                                child: Column(
                                                                                  children: [
                                                                                    if(_userModelController.displayName == 'SNOWLIVE')
                                                                                      Column(
                                                                                        children: [
                                                                                          GestureDetector(
                                                                                            child: ListTile(
                                                                                              contentPadding: EdgeInsets.zero,
                                                                                              title: Center(
                                                                                                child: Text(
                                                                                                  (isLocked ==false)
                                                                                                      ? '게시글 잠금' : '게시글 잠금 해제',
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 15,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              //selected: _isSelected[index]!,
                                                                                              onTap: () async {
                                                                                                Get.dialog(
                                                                                                    AlertDialog(
                                                                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                      elevation: 0,
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                          borderRadius: BorderRadius.circular(10.0)),
                                                                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                      content: Text(
                                                                                                        (isLocked ==false)
                                                                                                            ? '이 게시글을 잠그시겠습니까?' : '게시글 잠금을 해제하시겠습니까?',
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
                                                                                                                  '취소',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 15,
                                                                                                                    color: Color(0xFF949494),
                                                                                                                    fontWeight: FontWeight.bold,
                                                                                                                  ),
                                                                                                                )),
                                                                                                            TextButton(
                                                                                                                onPressed: () async{
                                                                                                                  if (data?.containsKey('lock') == false) {
                                                                                                                    await chatDocs[index].reference.update({'lock': false});
                                                                                                                  }
                                                                                                                  await _commentModelController.lock('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}');
                                                                                                                  Navigator.pop(context);
                                                                                                                  Navigator.pop(context);
                                                                                                                },
                                                                                                                child: Text('확인',
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
                                                                                              },
                                                                                              shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(10)),
                                                                                            ),
                                                                                          ),
                                                                                          GestureDetector(
                                                                                            child: ListTile(
                                                                                              contentPadding: EdgeInsets.zero,
                                                                                              title: Center(
                                                                                                child: Text(
                                                                                                  '게시글 수정',
                                                                                                  style: TextStyle(
                                                                                                    fontSize: 15,
                                                                                                    fontWeight: FontWeight
                                                                                                        .bold,
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              //selected: _isSelected[index]!,
                                                                                              onTap: () async {
                                                                                                Get.dialog(
                                                                                                    AlertDialog(
                                                                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                      elevation: 0,
                                                                                                      shape: RoundedRectangleBorder(
                                                                                                          borderRadius: BorderRadius.circular(10.0)),
                                                                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                      content: Text(
                                                                                                        '이 게시글을 수정하시겠습니까?',
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
                                                                                                                  '취소',
                                                                                                                  style: TextStyle(
                                                                                                                    fontSize: 15,
                                                                                                                    color: Color(0xFF949494),
                                                                                                                    fontWeight: FontWeight.bold,
                                                                                                                  ),
                                                                                                                )),
                                                                                                            TextButton(
                                                                                                                onPressed: () async{
                                                                                                                  await _commentModelController.getCurrentLiveTalk(uid: chatDocs[index]['uid'],commentCount: chatDocs[index]['commentCount'],);
                                                                                                                  Get.to(()=>Modify_liveTalk());
                                                                                                                },
                                                                                                                child: Text('확인',
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
                                                                                              },
                                                                                              shape: RoundedRectangleBorder(
                                                                                                  borderRadius: BorderRadius.circular(10)),
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    GestureDetector(
                                                                                      child: ListTile(
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Center(
                                                                                          child: Text(
                                                                                            '게시글 수정',
                                                                                            style: TextStyle(
                                                                                              fontSize: 15,
                                                                                              fontWeight: FontWeight
                                                                                                  .bold,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        //selected: _isSelected[index]!,
                                                                                        onTap: () async {
                                                                                          Get.dialog(
                                                                                              AlertDialog(
                                                                                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                elevation: 0,
                                                                                                shape: RoundedRectangleBorder(
                                                                                                    borderRadius: BorderRadius.circular(10.0)),
                                                                                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                content: Text(
                                                                                                  '이 게시글을 수정하시겠습니까?',
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
                                                                                                            '취소',
                                                                                                            style: TextStyle(
                                                                                                              fontSize: 15,
                                                                                                              color: Color(0xFF949494),
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                            ),
                                                                                                          )),
                                                                                                      TextButton(
                                                                                                          onPressed: () async{
                                                                                                            Navigator.pop(context);
                                                                                                            Navigator.pop(context);
                                                                                                            await _commentModelController.getCurrentLiveTalk(uid: chatDocs[index]['uid'],commentCount: chatDocs[index]['commentCount'],);
                                                                                                            Get.to(()=>Modify_liveTalk());
                                                                                                          },
                                                                                                          child: Text('확인',
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
                                                                                        },
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(10)),
                                                                                      ),
                                                                                    ),
                                                                                    GestureDetector(
                                                                                      child: ListTile(
                                                                                        contentPadding: EdgeInsets.zero,
                                                                                        title: Center(
                                                                                          child: Text(
                                                                                            '삭제',
                                                                                            style: TextStyle(
                                                                                                fontSize: 15,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                color: Color(0xFFD63636)
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        //selected: _isSelected[index]!,
                                                                                        onTap: () async {
                                                                                          Navigator.pop(context);
                                                                                          showModalBottomSheet(
                                                                                              context: context,
                                                                                              builder: (context) {
                                                                                                return Container(
                                                                                                  color: Colors.white,
                                                                                                  height: 180,
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.symmetric(
                                                                                                        horizontal: 20.0),
                                                                                                    child: Column(
                                                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                                                                      children: [
                                                                                                        SizedBox(
                                                                                                          height: 30,
                                                                                                        ),
                                                                                                        Text(
                                                                                                          '삭제하시겠습니까?',
                                                                                                          style: TextStyle(
                                                                                                              fontSize: 20,
                                                                                                              fontWeight: FontWeight.bold,
                                                                                                              color: Color(0xFF111111)),
                                                                                                        ),
                                                                                                        SizedBox(
                                                                                                          height: 30,
                                                                                                        ),
                                                                                                        Row(
                                                                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                                          children: [
                                                                                                            Expanded(
                                                                                                              child: ElevatedButton(
                                                                                                                onPressed: () {
                                                                                                                  Navigator.pop(context);
                                                                                                                },
                                                                                                                child: Text(
                                                                                                                  '취소',
                                                                                                                  style: TextStyle(
                                                                                                                      color: Colors.white,
                                                                                                                      fontSize: 15,
                                                                                                                      fontWeight: FontWeight.bold),
                                                                                                                ),
                                                                                                                style: TextButton.styleFrom(
                                                                                                                    splashFactory: InkRipple.splashFactory,
                                                                                                                    elevation: 0,
                                                                                                                    minimumSize: Size(100, 56),
                                                                                                                    backgroundColor: Color(0xff555555),
                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                              ),
                                                                                                            ),
                                                                                                            SizedBox(
                                                                                                              width: 10,
                                                                                                            ),
                                                                                                            Expanded(
                                                                                                              child: ElevatedButton(
                                                                                                                onPressed: () async {
                                                                                                                  CustomFullScreenDialog.showDialog();
                                                                                                                  try {
                                                                                                                    await FirebaseFirestore.instance.collection('liveTalk').doc('${_userModelController.uid}${chatDocs[index]['commentCount']}').delete();
                                                                                                                    await _imageController.deleteLiveTalkImage(uid: _userModelController.uid!, count: chatDocs[index]['commentCount']);

                                                                                                                  } catch (e) {}
                                                                                                                  print('라이브톡 삭제 완료');
                                                                                                                  Navigator.pop(context);
                                                                                                                  CustomFullScreenDialog.cancelDialog();
                                                                                                                },
                                                                                                                child: Text('확인',
                                                                                                                  style: TextStyle(
                                                                                                                      color: Colors.white,
                                                                                                                      fontSize: 15,
                                                                                                                      fontWeight: FontWeight.bold),
                                                                                                                ),
                                                                                                                style: TextButton.styleFrom(
                                                                                                                    splashFactory: InkRipple.splashFactory,
                                                                                                                    elevation: 0,
                                                                                                                    minimumSize: Size(100, 56),
                                                                                                                    backgroundColor: Color(0xff2C97FB),
                                                                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                  child: Icon(Icons.more_horiz,
                                                                    color: Color(0xFFdedede),
                                                                    size: 20,
                                                                  ),
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        Column(
                                                          children: [
                                                            if (chatDocs[index]['livetalkImageUrl'] != "")
                                                              Padding(
                                                                padding: EdgeInsets.only(top: 14, bottom: 6),
                                                                child: GestureDetector(
                                                                  onTap: () {Get.to(() =>
                                                                      ProfileImagePage(
                                                                        CommentProfileUrl: chatDocs[index]['livetalkImageUrl'],
                                                                      ));
                                                                  },
                                                                  child: ExtendedImage.network(
                                                                    chatDocs[index]['livetalkImageUrl'],
                                                                    cache: true,
                                                                    //cacheHeight: 1600,
                                                                    width: _size.width - 24,
                                                                    height: _size.width - 24,
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                            if (chatDocs[index]['livetalkImageUrl'] == "")
                                                              Container(
                                                                height: 0,
                                                              )
                                                          ],
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              horizontal: 16),
                                                          child: Column(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Container(
                                                                    constraints: BoxConstraints(
                                                                        maxWidth: _size.width - 56),
                                                                    child: SelectableText(
                                                                      chatDocs[index].get('comment'),
                                                                      style: TextStyle(
                                                                          color: Color(0xFF111111),
                                                                          fontWeight: FontWeight.normal,
                                                                          fontSize: 14),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text('$_time',
                                                                style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: Color(0xFF949494),
                                                                    fontWeight: FontWeight.w300),
                                                              ),
                                                              SizedBox(
                                                                height: 16,
                                                              ),
                                                              Row(
                                                                children: [
                                                                  GestureDetector(
                                                                    child: Container(
                                                                      height: 24,
                                                                      decoration: BoxDecoration(
                                                                          color: (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}'))
                                                                              ? Color(0xFFFFCDCD)
                                                                              : Color(0xFFECECEC),
                                                                          borderRadius: BorderRadius.circular(4)
                                                                      ),
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(right: 8),
                                                                        child: Row(
                                                                          children: [
                                                                            (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}'))
                                                                                ? Padding(
                                                                              padding: const EdgeInsets.only(top: 2),
                                                                              child:
                                                                              IconButton(
                                                                                onPressed: () async {
                                                                                  var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                                  print(likeUid);
                                                                                  HapticFeedback.lightImpact();
                                                                                  if (_firstPress) {
                                                                                    _firstPress = false;
                                                                                    await _userModelController.deleteLikeUid(likeUid);
                                                                                    await _commentModelController.likeDelete(likeUid);
                                                                                    _firstPress =
                                                                                    true;
                                                                                  }
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.favorite,
                                                                                  size: 14,
                                                                                  color: Color(0xFFD63636),
                                                                                ),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints: BoxConstraints(),
                                                                              ),
                                                                            )
                                                                                : Padding(
                                                                              padding: const EdgeInsets.only(top: 2),
                                                                              child:
                                                                              IconButton(
                                                                                onPressed: () async {
                                                                                  var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                                  print(likeUid);
                                                                                  HapticFeedback.lightImpact();
                                                                                  if (_firstPress) {
                                                                                    _firstPress = false;
                                                                                    await _userModelController.updateLikeUid(likeUid);
                                                                                    await _commentModelController.likeUpdate(likeUid);
                                                                                    _firstPress = true;
                                                                                  }
                                                                                },
                                                                                icon: Icon(Icons.favorite,
                                                                                  size: 14,
                                                                                  color: Color(0xFFC8C8C8),
                                                                                ),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints: BoxConstraints(),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(bottom: 1),
                                                                              child: Text(
                                                                                '${chatDocs[index]['likeCount']}',
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 11,
                                                                                    color:
                                                                                    (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}'))
                                                                                        ? Color(0xFF111111)
                                                                                        : Color(0xFF666666)),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    onTap: () async{
                                                                      if (_userModelController.likeUidList!.contains('${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}')){
                                                                        var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                        print(likeUid);
                                                                        HapticFeedback.lightImpact();
                                                                        if (_firstPress) {
                                                                          _firstPress = false;
                                                                          await _userModelController.deleteLikeUid(likeUid);
                                                                          await _commentModelController.likeDelete(likeUid);
                                                                          _firstPress = true;
                                                                        }
                                                                      } else{
                                                                        var likeUid = '${chatDocs[index]['uid']}${chatDocs[index]['commentCount']}';
                                                                        print(likeUid);
                                                                        HapticFeedback.lightImpact();
                                                                        if (_firstPress) {
                                                                          _firstPress = false;
                                                                          await _userModelController.updateLikeUid(likeUid);
                                                                          await _commentModelController.likeUpdate(likeUid);
                                                                          _firstPress = true;
                                                                        }
                                                                      }

                                                                    },
                                                                  ),
                                                                  SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  GestureDetector(
                                                                    onTap: (){
                                                                      Get.to(() =>
                                                                          ReplyScreen(
                                                                            replyUid: chatDocs[index]['uid'],
                                                                            replyCount: chatDocs[index]['commentCount'],
                                                                            replyImage:
                                                                            (chatDocs[index]['profileImageUrl'] != 'anony')
                                                                                ? profileUrl
                                                                                : chatDocs[index]['profileImageUrl'],
                                                                            replyDisplayName:
                                                                            (chatDocs[index]['displayName'] != '익명')
                                                                                ? displayName
                                                                                : chatDocs[index]['displayName'],
                                                                            replyResortNickname: chatDocs[index]['resortNickname'],
                                                                            comment: chatDocs[index]['comment'],
                                                                            commentTime: chatDocs[index]['timeStamp'],
                                                                            kusbf: _isTabKusbf == true ? true : false,
                                                                            replyLiveTalkImageUrl: chatDocs[index]['livetalkImageUrl'],
                                                                          ));
                                                                    },
                                                                    child: Container(
                                                                      height: 24,
                                                                      decoration: BoxDecoration(
                                                                          color:
                                                                          (chatDocs[index]['replyCount'] != 0)
                                                                              ? Color(0xFFCBE0FF)
                                                                              : Color(0xFFECECEC),
                                                                          borderRadius: BorderRadius.circular(4)
                                                                      ),
                                                                      child: Padding(
                                                                        padding: EdgeInsets.only(right: 6),
                                                                        child: Row(
                                                                          children: [
                                                                            Padding(
                                                                              padding:
                                                                              const EdgeInsets.only(top: 2),
                                                                              child:
                                                                              IconButton(
                                                                                onPressed: () {
                                                                                  Get.to(() =>
                                                                                      ReplyScreen(
                                                                                        replyUid: chatDocs[index]['uid'],
                                                                                        replyCount: chatDocs[index]['commentCount'],
                                                                                        replyImage:
                                                                                        (chatDocs[index]['profileImageUrl'] != 'anony')
                                                                                            ? profileUrl
                                                                                            : chatDocs[index]['profileImageUrl'],
                                                                                        replyDisplayName:
                                                                                        (chatDocs[index]['displayName'] != '익명')
                                                                                            ? displayName
                                                                                            : chatDocs[index]['displayName'],
                                                                                        replyResortNickname: chatDocs[index]['resortNickname'],
                                                                                        comment: chatDocs[index]['comment'],
                                                                                        commentTime: chatDocs[index]['timeStamp'],
                                                                                        kusbf: _isTabKusbf == true ? true : false,
                                                                                        replyLiveTalkImageUrl: chatDocs[index]['livetalkImageUrl'],
                                                                                      ));
                                                                                },
                                                                                icon: Icon(
                                                                                  Icons.insert_comment,
                                                                                  size: 14,
                                                                                  color:
                                                                                  (chatDocs[index]['replyCount'] != 0)
                                                                                      ? Color(0xFF3D83ED)
                                                                                      : Color(0xFFC8C8C8),
                                                                                ),
                                                                                padding: EdgeInsets.zero,
                                                                                constraints: BoxConstraints(),
                                                                              ),
                                                                            ),
                                                                            Padding(
                                                                              padding: EdgeInsets.only(bottom: 1),
                                                                              child: Text(
                                                                                '${chatDocs[index]['replyCount']}',
                                                                                style: TextStyle(
                                                                                    color:
                                                                                    (chatDocs[index]['replyCount'] != 0)
                                                                                        ? Color(0xFF111111)
                                                                                        : Color(0xFF666666),
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 11),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                  );
                                },
                              );
                            },
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              (_imageFile != null)
                                  ? Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: _size.width,
                                    height: 112,
                                    color: Colors.black.withOpacity(0.8),
                                  ),
                                  Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.transparent,
                                    child: (_imageFile == null)
                                        ? null
                                        : Image.file(File(_imageFile!.path),
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        child: ExtendedImage.asset(
                                            'assets/imgs/icons/icon_profile_delete.png',
                                            scale: 4),
                                        onTap: () {
                                          livetalkImage = false;
                                          _imageFile = null;
                                          setState(() {});
                                        },
                                      )),
                                ],
                              )
                                  : Container(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                ),
                                padding:
                                EdgeInsets.only(top: 12, left: 10, right: 16, bottom: 12),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.zero,
                                      width: 40,
                                      child:
                                      (livetalkImage) //이 값이 true이면 이미지업로드가 된 상태이므로, 미리보기 띄움
                                          ? IconButton(
                                        icon: Icon(Icons.photo_camera,
                                          size: 28,
                                          color: Color(0xFF444444),),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) =>
                                                Container(
                                                  height: 179,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 24.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              height: 30,
                                                            ),
                                                            Text(
                                                              '업로드 방법을 선택해주세요.',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFF111111)),
                                                            ),
                                                            SizedBox(
                                                              height: 30,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async {
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.showDialog();
                                                                  try {
                                                                    _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    livetalkImage = true;
                                                                    setState(() {});
                                                                  } catch (e) {
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    print('사진촬영 오류');
                                                                  }
                                                                },
                                                                child: Text(
                                                                  '사진 촬영',
                                                                  style: TextStyle(
                                                                      color: Color(0xFF3D83ED),
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(
                                                                    splashFactory:
                                                                    InkRipple.splashFactory,
                                                                    elevation: 0,
                                                                    minimumSize: Size(100, 56),
                                                                    backgroundColor:
                                                                    Color(0xffCBE0FF),
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
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.showDialog();
                                                                  try {
                                                                    _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    livetalkImage = true;
                                                                    setState(() {});
                                                                  } catch (e) {
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    print('앨범 오류');
                                                                  }
                                                                },
                                                                child: Text(
                                                                  '앨범에서 선택',
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(
                                                                    splashFactory:
                                                                    InkRipple.splashFactory,
                                                                    elevation: 0,
                                                                    minimumSize: Size(100, 56),
                                                                    backgroundColor:
                                                                    Color(0xff3D83ED),
                                                                    padding: EdgeInsets
                                                                        .symmetric(
                                                                        horizontal: 0)),
                                                              ),
                                                            ),

                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 40,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                          );
                                        },
                                      )
                                          : IconButton(
                                        icon: Icon(Icons.photo_camera,
                                          size: 28,
                                          color: Color(0xFF444444),
                                        ),
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (context) =>
                                                Container(
                                                  height: 179,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 24.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                          CrossAxisAlignment.start,
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            SizedBox(
                                                              height: 30,
                                                            ),
                                                            Text(
                                                              '업로드 방법을 선택해주세요.',
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFF111111)),
                                                            ),
                                                            SizedBox(
                                                              height: 30,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.symmetric(
                                                            horizontal: 20),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                          MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async {
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.showDialog();
                                                                  try {
                                                                    _imageFile = await _imageController.getSingleImage(ImageSource.camera);
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    livetalkImage = true;
                                                                    setState(() {});
                                                                  } catch (e) {
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                  }
                                                                },
                                                                child: Text(
                                                                  '사진 촬영',
                                                                  style: TextStyle(
                                                                      color: Color(0xFF3D83ED),
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(
                                                                    splashFactory:
                                                                    InkRipple.splashFactory,
                                                                    elevation: 0,
                                                                    minimumSize: Size(100, 56),
                                                                    backgroundColor:
                                                                    Color(0xffCBE0FF),
                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Expanded(
                                                              child: ElevatedButton(
                                                                onPressed: () async {
                                                                  Navigator.pop(context);
                                                                  CustomFullScreenDialog.showDialog();
                                                                  try {
                                                                    _imageFile = await _imageController.getSingleImage(ImageSource.gallery);
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                    livetalkImage = true;
                                                                    setState(() {});
                                                                  } catch (e) {
                                                                    CustomFullScreenDialog.cancelDialog();
                                                                  }
                                                                },
                                                                child: Text(
                                                                  '앨범에서 선택',
                                                                  style: TextStyle(
                                                                      color: Colors.white,
                                                                      fontSize: 15,
                                                                      fontWeight: FontWeight.bold),
                                                                ),
                                                                style: TextButton.styleFrom(
                                                                    splashFactory:
                                                                    InkRipple.splashFactory,
                                                                    elevation: 0,
                                                                    minimumSize: Size(100, 56),
                                                                    backgroundColor:
                                                                    Color(0xff3D83ED),
                                                                    padding: EdgeInsets.symmetric(horizontal: 0)),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: 40,
                                                      )
                                                    ],
                                                  ),
                                                ),
                                          );
                                        },
                                      ),),
                                    SizedBox(
                                      width: 8,
                                    ),
                                    if(_isTabKusbf == false)
                                      GestureDetector(
                                        onTap: (){
                                          setState(() {
                                            if(anony == true){
                                              setState(() {
                                                anony = false;
                                              });
                                            }else{
                                              setState(() {
                                                anony = true;
                                              });
                                            }
                                          });
                                        },
                                        child:Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                          decoration: BoxDecoration(
                                            color:
                                            (anony == true)
                                                ? Color(0xFFCBE0FF)
                                                : Color(0xFFECECEC),
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                          child: Row(
                                            children: [
                                              (anony == true)
                                                  ? Image.asset(
                                                'assets/imgs/icons/icon_livetalk_check.png',
                                                scale: 4,
                                                width: 10,
                                                height: 10,
                                              )
                                                  :  Image.asset(
                                                'assets/imgs/icons/icon_livetalk_check_off.png',
                                                scale: 4,
                                                width: 10,
                                                height: 10,
                                              ),
                                              SizedBox(width: 2,),
                                              Text('익명',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                    color:
                                                    (anony == true)
                                                        ? Color(0xFF3D83ED)
                                                        :Color(0xFF949494)
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    SizedBox(
                                      width: 14,
                                    ),
                                    Expanded(
                                      child: TextFormField(
                                        key: _formKey,
                                        cursorColor: Color(0xff377EEA),
                                        controller: _controller,
                                        strutStyle: StrutStyle(leading: 0.3),
                                        maxLines: null,
                                        keyboardType: TextInputType.multiline,
                                        enableSuggestions: false,
                                        autocorrect: false,
                                        textInputAction: TextInputAction.newline,
                                        decoration: InputDecoration(
                                            suffixIcon: IconButton(
                                              splashColor: Colors.transparent,
                                              onPressed: () async {
                                                if (_controller.text.trim().isEmpty) {
                                                  return;
                                                }
                                                try{
                                                  CustomFullScreenDialog.showDialog();
                                                  await _userModelController.getCurrentUser(_userModelController.uid);
                                                  await _userModelController.updateCommentCount(_userModelController.commentCount);
                                                  await _userModelController.getCurrentUser(_userModelController.uid);

                                                  String? livetalkImageUrl = "";
                                                  if (_imageFile != null) {
                                                    livetalkImageUrl = await _imageController.setNewImage_livetalk(_imageFile!, _userModelController.commentCount);
                                                    await _commentModelController.updateLivetalkImageUrl(livetalkImageUrl);

                                                    setState(() {
                                                      _imageFile = null;
                                                      livetalkImage = false;
                                                    });
                                                  }
                                                  _controller.clear();
                                                  _scrollController.jumpTo(0);
                                                  try {
                                                    await _commentModelController.sendMessage(
                                                      displayName:
                                                      (anony == false)
                                                          ? _userModelController.displayName
                                                          : "익명",
                                                      uid: _userModelController.uid,
                                                      profileImageUrl:
                                                      (anony == false)
                                                          ? _userModelController.profileImageUrl
                                                          : 'anony',
                                                      comment: _newComment,
                                                      commentCount: _userModelController.commentCount,
                                                      resortNickname: _userModelController.resortNickname,
                                                      likeCount: 0,
                                                      replyCount: 0,
                                                      livetalkImageUrl: livetalkImageUrl,
                                                      kusbf: _userModelController.kusbf == true && _isTabKusbf == true ? true : false,
                                                      liveCrew: _userModelController.liveCrew,
                                                    );
                                                    FocusScope.of(context).unfocus();
                                                    _controller.clear();
                                                    setState(() {});
                                                  } catch (e) {
                                                    CustomFullScreenDialog.cancelDialog();
                                                  }
                                                  CustomFullScreenDialog.cancelDialog();
                                                } catch(e){
                                                  CustomFullScreenDialog.cancelDialog();
                                                }
                                              },
                                              icon: (_controller.text.trim().isEmpty)
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
                                            labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                            hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                            hintText: '라이브톡 남기기',
                                            contentPadding: EdgeInsets.only(
                                                top: 2, bottom: 2, left: 12, right: 16),
                                            border: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Color(0xFFDEDEDE)),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            focusedBorder:  OutlineInputBorder(
                                              borderSide: BorderSide(color: Color(0xFFDEDEDE)),
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
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            floatingActionButton: Visibility(
              visible: _isVisible,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 64, left: 32),
                    child: Container(
                      width: 106,
                      child: FloatingActionButton(
                        heroTag: 'liveTalkScreen',
                        mini: true,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40)
                        ),
                        backgroundColor: Color(0xFF000000).withOpacity(0.8),
                        foregroundColor: Colors.white,
                        onPressed: () {
                          _scrollController.jumpTo(0);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: Color(0xFFffffff),
                                size: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 3),
                              child: Text('최신글 보기',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFffffff).withOpacity(0.8),
                                    letterSpacing: 0
                                ),),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),)
        ,
      )
      ,
    );
  }
}