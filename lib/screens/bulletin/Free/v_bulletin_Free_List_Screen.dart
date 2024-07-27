import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:com.snowlive/controller/bulletin/vm_streamController_bulletin.dart';
import 'package:com.snowlive/screens/bulletin/Free/v_bulletin_Free_List_Detail.dart';
import 'package:com.snowlive/screens/bulletin/Free/v_bulletin_Free_Upload.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/user/vm_allUserDocsController.dart';
import '../../../controller/bulletin/vm_bulletinFreeController.dart';
import '../../../controller/public/vm_timeStampController.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model/m_bulletinFreeModel.dart';
import '../../../widget/w_fullScreenDialog.dart';
import '../../snowliveDesignStyle.dart';

class Bulletin_Free_List_Screen extends StatefulWidget {
  const Bulletin_Free_List_Screen({Key? key}) : super(key: key);

  @override
  State<Bulletin_Free_List_Screen> createState() => _Bulletin_Free_List_ScreenState();

}

class _Bulletin_Free_List_ScreenState extends State<Bulletin_Free_List_Screen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  limitController _seasonController = Get.find<limitController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  StreamController_Bulletin _streamController_Bulletin = Get.find<StreamController_Bulletin>();
  //TODO: Dependency Injection**************************************************

  var _selectedValue = '카테고리';
  bool _isVisible = false;
  bool _orderbyLike = false;
  bool _orderbyView = false;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _bulletinFreeStream;


  var f = NumberFormat('###,###,###,###');

  ScrollController _scrollController = ScrollController();
  bool _showAddButton = true;

  List<bool> isTap = [
    true,
    false,
    false,
    false,
    false
  ];

  bool _filerTab = false;
  var _filterValue = '필터';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _seasonController.getBulletinFreeLimit();

    setState(() {
      _streamController_Bulletin.setSelectedValues_bulletinFree(_selectedValue);
      _bulletinFreeStream = _streamController_Bulletin.bulletinStream_bulletinFree_List_Screen.value;
    });

    try{
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_bulletinFree',
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

    // Add a listener to the ScrollController
    _scrollController.addListener(() {
      setState(() {
        // Check if the user has scrolled down by a certain offset (e.g., 100 pixels)
        _showAddButton = _scrollController.offset <= 0;
      });
    });
  }

  @override
  void dispose() {
    _allUserDocsController.stopListening();
    super.dispose();
  }


  _showCupertinoPicker() async {
    await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: CupertinoActionSheet(
              actions: [
                CupertinoActionSheetAction(
                    onPressed: () {
                      setState(() {
                        _orderbyLike = false;
                        _orderbyView = false;
                        _isVisible = false;
                        _filerTab = false;

                      });
                      Navigator.pop(context);
                    },
                    child: Text('전체',)),
                CupertinoActionSheetAction(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _orderbyLike = false;
                        _orderbyView = true;
                        _isVisible = false;
                        _filerTab = true;
                        _filterValue = '조회순';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('조회순')),
                CupertinoActionSheetAction(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        _orderbyLike = true;
                        _orderbyView = false;
                        _isVisible = false;
                        _filerTab = true;
                        _filterValue = '추천순';
                      });
                      Navigator.pop(context);
                    },
                    child: Text('추천순')),

              ],
              cancelButton: CupertinoActionSheetAction(
                child: Text('닫기'),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                },
              ),
            ),
          );
        });
    setState(() {
      _bulletinFreeStream = _streamController_Bulletin.bulletinStream_bulletinFree_List_Screen.value;
    });
  }

  Future<void> _refreshData() async {
    await _allUserDocsController.getAllUserDocs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    _seasonController.getBulletinFreeLimit();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          floatingActionButton: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: _size.height - 292),
                  child: Visibility(
                    visible: _isVisible,
                    child: Container(
                      width: 106,
                      child: FloatingActionButton(
                        heroTag: 'bulletin_free',
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
                                size: 18),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 3),
                              child: Text('최신글 보기',
                                style: SDSTextStyle.bold.copyWith(
                                    fontSize: 13,
                                    color: SDSColor.snowliveWhite.withOpacity(0.8),
                                    letterSpacing: 0
                                ),),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0, // Adjust the position as needed
                right: 16, // Adjust the position as needed
                child: AnimatedContainer(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                      boxShadow: [
                        BoxShadow(
                          color: SDSColor.snowliveBlack.withOpacity(0.2),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        )
                      ]
                  ),
                  width: _showAddButton ? 104 : 52,
                  height: 52,
                  duration: Duration(milliseconds: 200),
                  child: FloatingActionButton.extended(
                    heroTag: 'bulletin_free',
                    elevation: 0,
                    onPressed: () async {
                      await _userModelController.getCurrentUser(_userModelController.uid);
                      Get.to(() => Bulletin_Free_Upload());
                    },
                    icon: Transform.translate(
                      offset: Offset(6, 0),
                      child: Center(child: Icon(Icons.add,
                      size: 24,)),
                    ),
                    label: _showAddButton
                        ? Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Text(
                        '글쓰기',
                        style: SDSTextStyle.bold.copyWith(
                          letterSpacing: 0.5,
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                    )
                        : SizedBox.shrink(),
                    backgroundColor: SDSColor.snowliveBlue,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16, left: 0),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
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
                                        _selectedValue = '카테고리';
                                        _isVisible = false;
                                      });
                                      _streamController_Bulletin.setSelectedValues_bulletinFree('카테고리');
                                      setState(() {
                                        _bulletinFreeStream = _streamController_Bulletin.bulletinStream_bulletinFree_List_Screen.value;
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: (isTap[0] == true) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                            borderRadius: BorderRadius.circular(30.0),
                                            border: Border.all(
                                                color: (isTap[0] == true) ? SDSColor.gray900 : SDSColor.gray200),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          height: 32,
                                          child: Text('전체',
                                            style: SDSTextStyle.bold.copyWith(
                                                fontSize: 13,
                                                fontWeight: (isTap[0] == true) ? FontWeight.bold : FontWeight.w300,
                                                color: (isTap[0] == true) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                            ),)
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        isTap[0] = false;
                                        isTap[1] = true;
                                        isTap[2] = false;
                                        isTap[3] = false;
                                        isTap[4] = false;
                                        _selectedValue = '${bulletinFreeCategoryList[0]}';
                                        _isVisible = false;
                                      });
                                      _streamController_Bulletin.setSelectedValues_bulletinFree('${bulletinFreeCategoryList[0]}');
                                      setState(() {
                                        _bulletinFreeStream = _streamController_Bulletin.bulletinStream_bulletinFree_List_Screen.value;
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[1] == true) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[1] == true) ? SDSColor.gray900 : SDSColor.gray200),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        height: 32,
                                        child: Text('잡담',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 13,
                                              fontWeight: (isTap[1] == true) ? FontWeight.bold : FontWeight.w300,
                                              color: (isTap[1] == true) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                          ),)
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      setState(() {
                                        isTap[0] = false;
                                        isTap[1] = false;
                                        isTap[2] = true;
                                        isTap[3] = false;
                                        isTap[4] = false;
                                        _selectedValue = '${bulletinFreeCategoryList[1]}';
                                        _isVisible = false;
                                      });
                                      _streamController_Bulletin.setSelectedValues_bulletinFree('${bulletinFreeCategoryList[1]}');
                                      setState(() {
                                        _bulletinFreeStream = _streamController_Bulletin.bulletinStream_bulletinFree_List_Screen.value;
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[2] == true) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[2] == true) ? SDSColor.gray900 : SDSColor.gray200),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        height: 32,
                                        child: Text('분실물',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 13,
                                              fontWeight: (isTap[2] == true) ? FontWeight.bold : FontWeight.w300,
                                              color: (isTap[2] == true) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                          ),)
                                    ),
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
                                        _selectedValue = '${bulletinFreeCategoryList[2]}';
                                        _isVisible = false;
                                      });
                                      _streamController_Bulletin.setSelectedValues_bulletinFree('${bulletinFreeCategoryList[2]}');
                                      setState(() {
                                        _bulletinFreeStream = _streamController_Bulletin.bulletinStream_bulletinFree_List_Screen.value;
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[3] == true) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[3] == true) ? SDSColor.gray900 : SDSColor.gray200),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        height: 32,
                                        child: Text('단톡방·동호회',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 13,
                                              fontWeight: (isTap[3] == true) ? FontWeight.bold : FontWeight.w300,
                                              color: (isTap[3] == true) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                          ),)
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: (){
                                      setState(() {
                                        HapticFeedback.lightImpact();
                                        isTap[0] = false;
                                        isTap[1] = false;
                                        isTap[2] = false;
                                        isTap[3] = false;
                                        isTap[4] = true;
                                        _selectedValue = '${bulletinFreeCategoryList[3]}';
                                        _isVisible = false;
                                      });
                                      _streamController_Bulletin.setSelectedValues_bulletinFree('${bulletinFreeCategoryList[3]}');
                                      setState(() {
                                        _bulletinFreeStream = _streamController_Bulletin.bulletinStream_bulletinFree_List_Screen.value;
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[4] == true) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[4] == true) ? SDSColor.gray900 : SDSColor.gray200),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        height: 32,
                                        child: Text('시즌방',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 13,
                                              fontWeight: (isTap[4] == true) ? FontWeight.bold : FontWeight.w300,
                                              color: (isTap[4] == true) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                          ),)
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async{
                              await _showCupertinoPicker();
                            },
                            child: Container(
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 12, right: 16),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: (_filerTab == true) ? SDSColor.snowliveWhite : SDSColor.snowliveWhite,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: (_filerTab == true) ? SDSColor.gray200 : SDSColor.gray200),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                    height: 32,
                                    child: (_filerTab == true)
                                        ? Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(right: 3),
                                              child:  ExtendedImage.network(
                                                '${IconAssetUrlList[0].filter}',
                                                enableMemoryCache: true,
                                                shape: BoxShape.rectangle,
                                                cacheHeight: 50,
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
                                            Text(_filterValue,
                                            style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: (_filerTab == true) ? SDSColor.gray900 : SDSColor.gray900)
                                    ),
                                          ],
                                        )
                                        : Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(right: 3),
                                          child:  ExtendedImage.network(
                                            '${IconAssetUrlList[0].filter}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            cacheHeight: 50,
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
                                            style: SDSTextStyle.regular.copyWith(
                                                fontSize: 13,
                                                color: SDSColor.gray900)
                                        )
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
                  Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _bulletinFreeStream,
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(
                              color: Colors.white,
                            );
                          } else if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          List<DocumentSnapshot> sortChatDocs(List<DocumentSnapshot> chatDocs) {
                            if (_orderbyLike) {
                              chatDocs.sort((a, b) {
                                int likeCountA = a['likeCount'];
                                int likeCountB = b['likeCount'];
                                return likeCountB.compareTo(likeCountA);
                              });
                            } else if (_orderbyView) {
                              chatDocs.sort((a, b) {
                                int viewerCountA = (a['viewerUid'] as List).length;
                                int viewerCountB = (b['viewerUid'] as List).length;
                                return viewerCountB.compareTo(viewerCountA);
                              });
                            }

                            return chatDocs;
                          }

                          final chatDocsOrigin = snapshot.data!.docs;
                          final chatDocs = sortChatDocs(chatDocsOrigin);

                          return (chatDocs.length == 0)
                              ? Container(
                            height: _size.height-380,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/imgs/icons/icon_nodata.png',
                                        scale: 4,
                                        width: 73,
                                        height: 73,
                                      ),
                                      SizedBox(
                                        height: 6,
                                      ),
                                      Text('게시판에 글이 없습니다.',
                                        style: SDSTextStyle.regular.copyWith(
                                            fontSize: 14,
                                            color: SDSColor.gray700
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: chatDocs.length,
                              itemBuilder: (context, index) {
                                Map<String, dynamic>? data = chatDocs[index].data() as Map<String, dynamic>?;
                                // 필드가 없을 경우 기본값 설정
                                bool isLocked = data?.containsKey('lock') == true ? data!['lock'] : false;
                                List viewerUid = data?.containsKey('viewerUid') == true ? data!['viewerUid'] : [];
                                String _time = _timeStampController.yyyymmddFormat(chatDocs[index].get('timeStamp'));
                                String? profileUrl = _allUserDocsController.findProfileUrl(chatDocs[index]['uid'], _allUserDocsController.allUserDocs);
                                String? displayName = _allUserDocsController.findDisplayName(chatDocs[index]['uid'], _allUserDocsController.allUserDocs);
                                return GestureDetector(
                                  onTap: () async {
                                    var docName = '${_bulletinFreeModelController.uid}#${_bulletinFreeModelController.bulletinFreeCount}';
                                    if(isLocked == false) {
                                      if (_userModelController.repoUidList!
                                          .contains(chatDocs[index].get('uid'))) {
                                        return;
                                      }
                                      CustomFullScreenDialog.showDialog();
                                      await _bulletinFreeModelController
                                          .getCurrentBulletinFree(
                                          uid: chatDocs[index].get('uid'),
                                          bulletinFreeCount:
                                          chatDocs[index].get('bulletinFreeCount'));
                                      if (data?.containsKey('lock') == false) {
                                        await chatDocs[index].reference.update({'viewerUid': []});
                                      }
                                      await _bulletinFreeModelController.scoreUpdate_read(bullUid: _bulletinFreeModelController.uid, docName: docName, timeStamp: _bulletinFreeModelController.timeStamp, score: _bulletinFreeModelController.score, viewerUid: _bulletinFreeModelController.viewerUid);
                                      await _bulletinFreeModelController.updateViewerUid();
                                      CustomFullScreenDialog.cancelDialog();
                                      Get.to(() => Bulletin_Free_List_Detail());
                                    }else{}
                                  },
                                  child: Obx(() => Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 2),
                                        child: Container(
                                          color: Colors.white,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              (isLocked==true)
                                                  ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                                                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
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
                                                                                                  (isLocked == false)
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
                                                                                                          await _bulletinFreeModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['bulletinFreeCount']}');
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
                                                            color: Color(0xFFEF0069),
                                                            size: 20,
                                                          ),
                                                        )
                                                    ],
                                                  ),
                                                ),
                                              )
                                                  : (_userModelController.repoUidList!.contains(chatDocs[index].get('uid')))
                                                  ? Container()
                                              // Center(
                                              //   child: Padding(
                                              //     padding: const EdgeInsets.symmetric(vertical: 24),
                                              //     child: Text(
                                              //       '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                              //       style: TextStyle(
                                              //           fontWeight: FontWeight.normal,
                                              //           fontSize: 12,
                                              //           color: Color(0xffc8c8c8)),
                                              //     ),
                                              //   ),
                                              // )
                                                  : Row(
                                                children: [
                                                  Container(
                                                    width: _size.width - 32,
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Expanded(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(top: 6, bottom: 8),
                                                            child: Column(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Padding(
                                                                  padding: const EdgeInsets.only(bottom: 6),
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                    children: [
                                                                      Expanded(
                                                                        child: Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Row(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  //자유게시판 카테고리 뱃지 디자인
                                                                                  Padding(
                                                                                    padding: const EdgeInsets.only(right: 6),
                                                                                    child: Container(
                                                                                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                                                                      decoration: BoxDecoration(
                                                                                        color: SDSColor.blue50,
                                                                                        borderRadius: BorderRadius.circular(4),
                                                                                      ),
                                                                                      child: Text(
                                                                                        chatDocs[index].get('category'),
                                                                                        style: SDSTextStyle.regular.copyWith(
                                                                                            fontSize: 11,
                                                                                            color: SDSColor.snowliveBlue),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  if (chatDocs[index].get('category') == '단톡·동호회')
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(right: 6),
                                                                                      child: Container(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                                                                        decoration: BoxDecoration(
                                                                                          color: SDSColor.gray50,
                                                                                          borderRadius: BorderRadius.circular(4),
                                                                                        ),
                                                                                        child: Text('주주모집',
                                                                                          style: SDSTextStyle.regular.copyWith(
                                                                                              fontSize: 11,
                                                                                              color: SDSColor.gray700),
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  // 게시글 타이틀
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      child: Text(
                                                                                        chatDocs[index].get('title'),
                                                                                        maxLines: 1,
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                            fontSize: 15,
                                                                                            color: SDSColor.gray900
                                                                                        ),
                                                                                      ),
                                                                                    ),
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
                                                                                                    padding: const EdgeInsets.symmetric(
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
                                                                                                                              (isLocked == false)
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
                                                                                                                                      await _bulletinFreeModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['bulletinFreeCount']}');
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
                                                                                        color: Color(0xFFEF0069),
                                                                                        size: 20,
                                                                                      ),
                                                                                    ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Row(
                                                                  children: [
                                                                    Text('$displayName',
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 12,
                                                                          color: SDSColor.gray700,
                                                                      ),
                                                                    ),
                                                                    Text(' · $_time',
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 12,
                                                                        color: SDSColor.gray700,
                                                                      ),
                                                                    ),
                                                                    Text('  |  ',
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 12,
                                                                        color: SDSColor.gray300,
                                                                      ),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                      children: [
                                                                        Image.asset('assets/imgs/icons/icon_eye_rounded.png',
                                                                        width: 14,
                                                                        height: 14,),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(left: 2),
                                                                          child: Text(
                                                                              '${viewerUid.length.toString()}',
                                                                            style: SDSTextStyle.regular.copyWith(
                                                                              fontSize: 12,
                                                                              color: SDSColor.gray700,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(width: 6),
                                                                        Image.asset('assets/imgs/icons/icon_reply_rounded.png',
                                                                          width: 14,
                                                                          height: 14,),
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(left: 2),
                                                                          child: Text(chatDocs[index].get('bulletinFreeReplyCount').toString(),
                                                                            style: SDSTextStyle.regular.copyWith(
                                                                              fontSize: 12,
                                                                              color: SDSColor.gray700,
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
                                                        (index == 5 || index == 2 || index == 6)
                                                            ? Padding(
                                                              padding: const EdgeInsets.only(left: 16),
                                                              child: Image.asset('assets/imgs/imgs/img_bulletin_thumbnail.png',
                                                          width: 50,
                                                          height: 50,),
                                                            )
                                                            : Container()
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if(chatDocs.length != index + 1)
                                        Divider(
                                          color: SDSColor.gray50,
                                          height: 16,
                                          thickness: 1,
                                        ),
                                    ],
                                  )),
                                );
                              },
                              padding: EdgeInsets.only(bottom: 90),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}