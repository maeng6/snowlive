import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/screens/bulletin/Lost/v_bulletin_Lost_List_Detail.dart';
import 'package:com.snowlive/screens/bulletin/Lost/v_bulletin_Lost_Upload.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controller/vm_allUserDocsController.dart';
import '../../../controller/vm_bulletinLostController.dart';
import '../../../controller/vm_timeStampController.dart';
import '../../../controller/vm_userModelController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model/m_bulletinLostModel.dart';
import '../../../widget/w_fullScreenDialog.dart';

class Bulletin_Lost_List_Screen extends StatefulWidget {
  const Bulletin_Lost_List_Screen({Key? key}) : super(key: key);

  @override
  State<Bulletin_Lost_List_Screen> createState() => _Bulletin_Lost_List_ScreenState();

}

class _Bulletin_Lost_List_ScreenState extends State<Bulletin_Lost_List_Screen> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinLostModelController _bulletinLostModelController = Get.find<BulletinLostModelController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  //TODO: Dependency Injection**************************************************

  var _stream;
  var _stream_hot;
  var _selectedValue = '카테고리';
  var _allCategories;
  bool _isVisible = false;
  bool _orderbyLike = false;
  bool _orderbyView = false;
  var _alluser;


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
    _seasonController.getBulletinLostLimit();
    _stream = newStream();
    _stream_hot = hotStream();

    try{
      FirebaseAnalytics.instance.logEvent(
        name: 'visit_bulletinLost',
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

  Stream<QuerySnapshot> newStream(){
    return FirebaseFirestore.instance
        .collection('bulletinLost')
        .where('category',
        isEqualTo:
        (_selectedValue == '카테고리') ? _allCategories : '$_selectedValue')
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.bulletinLostLimit!)
        .snapshots();
  }

  Stream<QuerySnapshot> hotStream() {

    return FirebaseFirestore.instance
        .collection('bulletinLost')
        .where('likeCount', isGreaterThan: 9)
        .limit(_seasonController.bulletinLostLimit!)
        .snapshots();
  }

  _showCupertinoPicker() async {
    await showCupertinoModalPopup(
        context: context,
        builder: (_) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Transform.translate(
              offset: Offset(0, 50),
              child: Container(
                  height: 400,
                  padding: EdgeInsets.only(left: 20, right: 20),
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
                          child: Text(
                            '선택',
                          )),
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
                  )
              ),
            ),
          );
        });
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
    Size _size = MediaQuery.of(context).size;

    _seasonController.getBulletinLostLimit();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: _size.height - 308),
                  child: Visibility(
                    visible: _isVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Container(
                        width: 106,
                        child: FloatingActionButton(
                          heroTag: 'bulletin_Lost',
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
                  ),
                ),
              ),
              Positioned(
                bottom: 0, // Adjust the position as needed
                right: 16, // Adjust the position as needed
                child: Transform.translate(
                  offset:  Offset(18, 0),
                  child: AnimatedContainer(
                    width: _showAddButton ? 104 : 52,
                    height: 52,
                    duration: Duration(milliseconds: 200),
                    child: FloatingActionButton.extended(
                      heroTag: 'bulletin_lost',
                      elevation: 4,
                      onPressed: () async {
                        await _userModelController.getCurrentUser(_userModelController.uid);
                        Get.to(() => Bulletin_Lost_Upload());
                      },
                      icon: Transform.translate(
                        offset: Offset(6, 0),
                        child: Center(child: Icon(Icons.add)),
                      ),
                      label: _showAddButton
                          ? Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '글쓰기',
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                          : SizedBox.shrink(),
                      backgroundColor: Color(0xFF3D6FED),
                    ),
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
                                        _selectedValue = '카테고리';
                                        _isVisible = false;
                                        _stream = newStream();
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: (isTap[0] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                            borderRadius: BorderRadius.circular(30.0),
                                            border: Border.all(
                                                color: (isTap[0] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                          height: 33,
                                          child: Text('전체',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: (isTap[0] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
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
                                        _selectedValue = '${bulletinLostCategoryList[0]}';
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
                                        height: 33,
                                        child: Text('분실물',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: (isTap[1] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
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
                                        _selectedValue = '${bulletinLostCategoryList[1]}';
                                        _isVisible = false;
                                        _stream = newStream();
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[2] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        height: 33,
                                        child: Text('습득물',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: (isTap[2] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
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
                                        _selectedValue = '${bulletinLostCategoryList[2]}';
                                        _isVisible = false;
                                        _stream = newStream();
                                      });
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (isTap[3] == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (isTap[3] == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                        height: 33,
                                        child: Text('기타',
                                          style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: (isTap[3] == true) ? Color(0xFF3D83ED) : Color(0xFF777777)
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
                                      color: (_filerTab == true) ? Color(0xFFD8E7FD) : Color(0xFFFFFFFF),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: (_filerTab == true) ? Color(0xFFD8E7FD) : Color(0xFFDEDEDE)),
                                    ),
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    height: 32,
                                    child: (_filerTab == true)
                                        ? Text(_filterValue,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: (_filerTab == true) ? Color(0xFF3D83ED) : Color(0xFF777777)))
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
                  Column(
                    children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: _stream,
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
                              ? Padding(
                            padding: const EdgeInsets.only(top: 120),
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
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.normal,
                                        color: Color(0xFF949494)
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
                                    var docName = '${_bulletinLostModelController.uid}#${_bulletinLostModelController.bulletinLostCount}';
                                    if(isLocked == false) {
                                      if (_userModelController.repoUidList!
                                          .contains(chatDocs[index].get('uid'))) {
                                        return;
                                      }
                                      CustomFullScreenDialog.showDialog();
                                      await _bulletinLostModelController
                                          .getCurrentBulletinLost(
                                          uid: chatDocs[index].get('uid'),
                                          bulletinLostCount:
                                          chatDocs[index].get('bulletinLostCount'));
                                      if (data?.containsKey('lock') == false) {
                                        await chatDocs[index].reference.update({'viewerUid': []});
                                      }
                                      await _bulletinLostModelController.scoreUpdate_read(bullUid: _bulletinLostModelController.uid, docName: docName, timeStamp: _bulletinLostModelController.timeStamp, score: _bulletinLostModelController.score, viewerUid: _bulletinLostModelController.viewerUid);
                                      await _bulletinLostModelController.updateViewerUid();
                                      CustomFullScreenDialog.cancelDialog();
                                      Get.to(() => Bulletin_Lost_List_Detail());
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
                                                                                                          await _bulletinLostModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['bulletinLostCount']}');
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
                                                  :(_userModelController.repoUidList!.contains(chatDocs[index].get('uid')))
                                                  ? Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                                  child: Text(
                                                    '이 게시글은 회원님의 요청에 의해 숨김 처리되었습니다.',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 12,
                                                        color: Color(0xffc8c8c8)),
                                                  ),
                                                ),
                                              )
                                                  : Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.symmetric(vertical: 6),
                                                    child: Container(
                                                      width: _size.width - 32,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: Color(0xFFECECEC),
                                                              borderRadius: BorderRadius.circular(4),
                                                            ),
                                                            child: Text(
                                                              chatDocs[index].get('category'),
                                                              style: TextStyle(
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 12,
                                                                  color: Color(0xFF666666)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Expanded(
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Container(
                                                                        constraints: BoxConstraints(
                                                                            maxWidth: _size.width - 179),
                                                                        child: Row(
                                                                          children: [
                                                                            Container(
                                                                              width: _size.width - 91,
                                                                              child: Text(
                                                                                chatDocs[index].get('title'),
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                                style: TextStyle(
                                                                                    fontWeight: FontWeight.bold,
                                                                                    fontSize: 15,
                                                                                    color: Color(0xFF111111)),
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
                                                                                                                                await _bulletinLostModelController.lock('${chatDocs[index]['uid']}#${chatDocs[index]['bulletinLostCount']}');
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
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(left: 16),
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(50),
                                                                          color: Color(0xFFE1EDFF),
                                                                        ),
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(top: 2, bottom: 4, left: 8, right: 8),
                                                                          child: Text(
                                                                            chatDocs[index].get('bulletinLostReplyCount').toString(),
                                                                            maxLines: 1,
                                                                            overflow:  TextOverflow.ellipsis,
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.normal,
                                                                                fontSize: 11,
                                                                                color: Color(0xFF3D83ED)),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(
                                                            height: 7,
                                                          ),
                                                          Row(
                                                            children: [
                                                              Container(
                                                                width: 16,
                                                                height: 16,
                                                                decoration: BoxDecoration(
                                                                    color: Color(0xFFDFECFF),
                                                                    borderRadius: BorderRadius.circular(50)
                                                                ),
                                                                child: ExtendedImage.network(
                                                                  profileUrl,
                                                                  cache: true,
                                                                  shape: BoxShape.circle,
                                                                  borderRadius:
                                                                  BorderRadius.circular(20),
                                                                  width: 16,
                                                                  height: 16,
                                                                  fit: BoxFit.cover,
                                                                  loadStateChanged: (ExtendedImageState state) {
                                                                    switch (state.extendedImageLoadState) {
                                                                      case LoadState.loading:
                                                                        return ExtendedImage.network(
                                                                          '${profileImgUrlList[0].default_round}',
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          cacheHeight: 100,
                                                                          width: 16,
                                                                          height: 16,
                                                                          fit: BoxFit.cover,
                                                                        );
                                                                      case LoadState.completed:
                                                                        return state.completedWidget;
                                                                      case LoadState.failed:
                                                                        return ExtendedImage.network(
                                                                          '${profileImgUrlList[0].default_round}',
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          cacheHeight: 100,
                                                                          width: 16,
                                                                          height: 16,
                                                                          fit: BoxFit.cover,
                                                                        ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                      default:
                                                                        return null;
                                                                    }
                                                                  },
                                                                ),
                                                              ),
                                                              SizedBox(width: 4),
                                                              Text('$displayName',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF111111),
                                                                    fontWeight: FontWeight.normal),
                                                              ),
                                                              SizedBox(width: 8,),
                                                              Text('|   $_time',
                                                                style: TextStyle(
                                                                    fontSize: 13,
                                                                    color: Color(0xFF949494),
                                                                    fontWeight: FontWeight.normal),
                                                              ),
                                                              SizedBox(width: 10,),
                                                              Row(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                children: [
                                                                  Icon(
                                                                    Icons.remove_red_eye_rounded,
                                                                    color: Color(0xFFc8c8c8),
                                                                    size: 15,
                                                                  ),
                                                                  SizedBox(width: 4,),
                                                                  Text(
                                                                      '${viewerUid.length.toString()}',
                                                                      style: TextStyle(
                                                                          fontSize: 13,
                                                                          color: Color(0xFF949494),
                                                                          fontWeight: FontWeight.normal)
                                                                  ),
                                                                  SizedBox(width: 10),
                                                                  Icon(
                                                                    Icons.thumb_up_alt,
                                                                    color: Color(0xFFc8c8c8),
                                                                    size: 15,
                                                                  ),
                                                                  SizedBox(width: 4,),
                                                                  Text(
                                                                      '${chatDocs[index]['likeCount']}',
                                                                      style: TextStyle(
                                                                          fontSize: 13,
                                                                          color: Color(0xFF949494),
                                                                          fontWeight: FontWeight.normal)
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
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
                                        color: Color(0xFFDEDEDE),
                                        height: 15,
                                        thickness: 0.5,
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
