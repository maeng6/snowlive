import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/vm_bulletinLostController.dart';
import 'package:com.snowlive/controller/vm_bulletinLostReplyController.dart';
import 'package:com.snowlive/controller/vm_seasonController.dart';
import 'package:com.snowlive/controller/vm_timeStampController.dart';
import 'package:com.snowlive/screens/bulletin/Lost/v_bulletinLostImageScreen.dart';
import 'package:com.snowlive/screens/bulletin/Lost/v_bulletin_Lost_ModifyPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../../controller/vm_alarmCenterController.dart';
import '../../../controller/vm_allUserDocsController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model/m_alarmCenterModel.dart';
import '../../more/friend/v_friendDetailPage.dart';

class Bulletin_Lost_List_Detail extends StatefulWidget {
  Bulletin_Lost_List_Detail({Key? key}) : super(key: key);

  @override
  State<Bulletin_Lost_List_Detail> createState() =>
      _Bulletin_Lost_List_DetailState();
}

class _Bulletin_Lost_List_DetailState extends State<Bulletin_Lost_List_Detail> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinLostModelController _bulletinLostModelController = Get.find<BulletinLostModelController>();
  SeasonController _seasonController = Get.find<SeasonController>();
  AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  AllUserDocsController _allUserDocsController = Get.find<AllUserDocsController>();
  //TODO: Dependency Injection**************************************************

  final _controller = TextEditingController();
  var _newReply = '';
  final _formKey = GlobalKey<FormState>();
  bool _replyReverse = true;
  var _firstPress = true;
  var _replyStream;
  int _currentIndex = 0;
  var _alluser;


  ScrollController _scrollController = ScrollController();

  ScrollController _scrollController2 = ScrollController();



  @override
  void initState() {
    _updateMethod();
    // TODO: implement initState
    super.initState();
    _seasonController.getBulletinLostReplyLimit();
    _replyStream = replyNewStream();
  }

  _updateMethod() async {
    await _userModelController.updateRepoUidList();
  }

  Stream<QuerySnapshot> replyNewStream() {
    return FirebaseFirestore.instance
        .collection('bulletinLost')
        .doc('${_bulletinLostModelController.uid}#${_bulletinLostModelController.bulletinLostCount}')
        .collection('reply')
        .orderBy('timeStamp', descending: true)
        .limit(_seasonController.bulletinLostReplyLimit!)
        .snapshots();
  }

  Future<void> _refreshData() async {
    await _allUserDocsController.getAllUserDocs();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    //TODO : ****************************************************************
    Get.put(BulletinLostReplyModelController(), permanent: true);
    BulletinLostReplyModelController _bulletinLostReplyModelController = Get.find<BulletinLostReplyModelController>();
    //TODO : ****************************************************************

    _seasonController.getBulletinLostReplyLimit();

    String _time =
    _timeStampController.yyyymmddFormat(_bulletinLostModelController.timeStamp);
    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(58),
            child: AppBar(
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
              actions: [
                (_bulletinLostModelController.uid != _userModelController.uid)
                    ? GestureDetector(
                  onTap: () => showModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Container(
                            height: 140,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 14),
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
                                        Get.dialog(AlertDialog(
                                          contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0)),
                                          buttonPadding:
                                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
                                                      Navigator.pop(
                                                          context);
                                                    },
                                                    child: Text(
                                                      '취소',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Color(
                                                            0xFF949494),
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    )),
                                                TextButton(
                                                    onPressed: () async {
                                                      var repoUid =
                                                          _bulletinLostModelController
                                                              .uid;
                                                      await _userModelController
                                                          .repoUpdate(
                                                          repoUid);
                                                      Navigator.pop(
                                                          context);
                                                      Navigator.pop(
                                                          context);
                                                    },
                                                    child: Text(
                                                      '신고',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Color(
                                                            0xFF3D83ED),
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ))
                                              ],
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                            )
                                          ],
                                        ));
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Text(
                                          '이 회원의 글 모두 숨기기',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      //selected: _isSelected[index]!,
                                      onTap: () async {
                                        Get.dialog(AlertDialog(
                                          contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10.0)),
                                          buttonPadding:
                                          EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                          content:  Container(
                                            height: _size.width * 0.17,
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
                                                        color: Color(
                                                            0xFF949494),
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    )),
                                                TextButton(
                                                    onPressed: () {
                                                      var repoUid = _bulletinLostModelController.uid;
                                                      _userModelController.updateRepoUid(repoUid);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text(
                                                      '확인',
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Color(
                                                            0xFF3D83ED),
                                                        fontWeight:
                                                        FontWeight.bold,
                                                      ),
                                                    ))
                                              ],
                                              mainAxisAlignment:
                                              MainAxisAlignment.end,
                                            )
                                          ],
                                        ));
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 1, right: 10),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 28,
                      color: Color(0xFF111111),
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: () => showModalBottomSheet(
                      enableDrag: false,
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Container(
                            height: 140,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 14),
                              child: Column(
                                children: [
                                  (_bulletinLostModelController.uid == _userModelController.uid)?
                                  GestureDetector(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Text(
                                          '수정하기',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      //selected: _isSelected[index]!,
                                      onTap: () async {
                                        CustomFullScreenDialog.showDialog();
                                        Navigator.pop(context);
                                        await _userModelController
                                            .getCurrentUser(_userModelController.uid);
                                        CustomFullScreenDialog.cancelDialog();
                                        Get.to(
                                                () => Bulletin_Lost_ModifyPage());
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(10)),
                                    ),
                                  )
                                      : SizedBox(),
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
                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                                                              onPressed:
                                                                  () {
                                                                Navigator.pop(context);
                                                              },
                                                              child: Text(
                                                                '취소',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                    15,
                                                                    fontWeight:
                                                                    FontWeight.bold),
                                                              ),
                                                              style: TextButton.styleFrom(
                                                                  splashFactory: InkRipple.splashFactory,
                                                                  elevation: 0,
                                                                  minimumSize: Size(100, 56),
                                                                  backgroundColor:
                                                                  Color(0xff555555),
                                                                  padding: EdgeInsets.symmetric(horizontal: 0)),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                          Expanded(
                                                            child:
                                                            ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                CustomFullScreenDialog.showDialog();
                                                                try {
                                                                  await FirebaseFirestore.instance
                                                                      .collection('bulletinLost')
                                                                      .doc('${_userModelController.uid}#${_bulletinLostModelController.bulletinLostCount}')
                                                                      .delete();
                                                                  try {
                                                                    await _bulletinLostModelController.deleteBulletinLostImage(
                                                                        uid:
                                                                        _userModelController.uid,
                                                                        bulletinLostCount: _bulletinLostModelController.bulletinLostCount,
                                                                        imageCount: _bulletinLostModelController.itemImagesUrls!.length);
                                                                  } catch (e) {
                                                                    print('이미지 삭제 에러');
                                                                  };
                                                                  Navigator.pop(context);
                                                                } catch (e) {}
                                                                print('시즌방게시글 삭제 완료');
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
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 1, right: 10),
                    child: Icon(
                      Icons.more_horiz_rounded,
                      size: 28,
                      color: Color(0xFF111111),
                    ),
                  ),
                )
              ],
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
          ),
          body: GestureDetector(
            onTap: (){
              FocusScope.of(context).unfocus();
            },
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Container(
                      height: _size.height - MediaQuery.of(context).viewPadding.top - 58 - MediaQuery.of(context).viewPadding.bottom - 88,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          children: [
                            if (_bulletinLostModelController.itemImagesUrls!.isEmpty)
                              SizedBox(
                                height: 6,
                              ),
                            if (_bulletinLostModelController.itemImagesUrls!.isNotEmpty)
                              Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      height: 280,
                                      viewportFraction: 1,
                                      enableInfiniteScroll: false,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentIndex = index;
                                        });
                                      },
                                    ),
                                    itemCount:
                                    _bulletinLostModelController.itemImagesUrls!.length,
                                    itemBuilder: (context, index, pageViewIndex) {
                                      return Container(
                                        padding: EdgeInsets.only(bottom: 16),
                                        child: StreamBuilder<Object>(
                                            stream: null,
                                            builder: (context, snapshot) {
                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to(() => BulletinLostImageScreen());
                                                    },
                                                    child: ExtendedImage.network(
                                                      _bulletinLostModelController
                                                          .itemImagesUrls![index],
                                                      fit: BoxFit.cover,
                                                      width: _size.width,
                                                      height: 280,
                                                      cacheHeight: 300,
                                                      cache: true,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }),
                                      );
                                    },
                                  ),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 245),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          _bulletinLostModelController.itemImagesUrls!.length,
                                              (index) {
                                            return Container(
                                              width: 8,
                                              height: 8,
                                              margin: EdgeInsets.symmetric(horizontal: 4),
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: _currentIndex == index ? Color(0xFFFFFFFF) : Color(0xFF111111).withOpacity(0.5),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFECECEC),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${_bulletinLostModelController.category}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF666666)),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 12,
                                  ),
                                  Container(
                                    width: _size.width - 32,
                                    child: Text(
                                      (_bulletinLostModelController.soldOut == true)
                                          ? '거래완료'
                                          : '${_bulletinLostModelController.title}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              StreamBuilder(
                                                  stream:  FirebaseFirestore.instance
                                                      .collection('user')
                                                      .where('uid', isEqualTo: _bulletinLostModelController.uid)
                                                      .snapshots(),
                                                  builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                    if (!snapshot.hasData || snapshot.data == null) {
                                                      return  SizedBox();
                                                    }
                                                    final userDoc = snapshot.data!.docs;
                                                    final userData = userDoc.isNotEmpty ? userDoc[0] : null;
                                                    if (userData == null) {
                                                      return SizedBox();
                                                    }
                                                    return GestureDetector(
                                                      onTap: (){
                                                        Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                                      },
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          if (userData['profileImageUrl'] != "")
                                                            Container(
                                                              width: 20,
                                                              height: 20,
                                                              decoration: BoxDecoration(
                                                                  color: Color(0xFFDFECFF),
                                                                  borderRadius: BorderRadius.circular(50)
                                                              ),
                                                              child: ExtendedImage.network(
                                                                userData['profileImageUrl'],
                                                                cache: true,
                                                                cacheHeight: 100,
                                                                shape: BoxShape.circle,
                                                                borderRadius:
                                                                BorderRadius.circular(20),
                                                                width: 20,
                                                                height: 20,
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
                                                                        width: 20,
                                                                        height: 20,
                                                                        cacheHeight: 100,
                                                                        cache: true,
                                                                        fit: BoxFit.cover,
                                                                      ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                    default:
                                                                      return null;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          if (userData['profileImageUrl'] == "")
                                                            ExtendedImage.network(
                                                              '${profileImgUrlList[0].default_round}',
                                                              shape: BoxShape.circle,
                                                              borderRadius:
                                                              BorderRadius.circular(20),
                                                              width: 20,
                                                              height: 20,
                                                              cacheHeight: 100,
                                                              cache: true,
                                                              fit: BoxFit.cover,
                                                            ),
                                                          SizedBox(width: 5,),
                                                          Text('${userData['displayName']}',
                                                            //chatDocs[index].get('displayName'),
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.normal,
                                                                fontSize: 14,
                                                                color: Color(0xFF949494)),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  }),

                                            ],

                                          ),
                                          Text('$_time',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Color(0xFF949494),
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    color: Color(0xFFdedede),
                                    height: 32,
                                    thickness: 0.5,
                                  )
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '내용',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.normal,
                                                  color: Color(0xFFB7B7B7)),
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Container(
                                              width: _size.width,
                                              child: SelectableText(
                                                '${_bulletinLostModelController.description}',
                                                style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.normal),
                                              ),
                                            ),

                                          ],
                                        ),
                                      ]),
                                ),
                                Divider(
                                  color: Color(0xFFf5f5f5),
                                  height: 50,
                                  thickness: 8,
                                ),
                                Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '답글',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.normal,
                                                    color: Color(0xFFB7B7B7)),
                                              ),
                                              GestureDetector(
                                                onTap: (){
                                                  if(_replyReverse == true){
                                                    setState(() {
                                                      _replyReverse = false;
                                                    });
                                                  }else{
                                                    setState(() {
                                                      _replyReverse = true;
                                                    });
                                                  }
                                                },
                                                child: Text(
                                                  '최신순⇅',
                                                  style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.normal,
                                                      color:
                                                      (_replyReverse == true)
                                                          ? Color(0xFFB7B7B7) : Colors.blue),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(
                                            height: 4,
                                          ),
                                          Container(
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: _replyStream,
                                                builder: (context, snapshot2) {
                                                  if (!snapshot2.hasData) {
                                                    return Container(
                                                      color: Colors.white,
                                                    );
                                                  }
                                                  else if (snapshot2.connectionState == ConnectionState.waiting) {
                                                    return Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                                  }
                                                  final replyDocs = snapshot2.data!.docs;
                                                  return Column(
                                                    children: [
                                                      Container(
                                                        color: Colors.white,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            (replyDocs.length == 0)
                                                                ? Column(
                                                              children: [
                                                                Text('첫 답글을 남겨주세요!', style: TextStyle(
                                                                    fontSize: 15,
                                                                    fontWeight: FontWeight.normal,
                                                                    color: Color(0xFF111111)
                                                                ),),
                                                                SizedBox(
                                                                  height: 20,
                                                                )
                                                              ],
                                                            )
                                                                : ListView.builder(
                                                              controller: _scrollController2,
                                                              shrinkWrap: true,
                                                              reverse: _replyReverse,
                                                              itemCount: replyDocs.length,
                                                              itemBuilder: (context, index) {
                                                                String _time = _bulletinLostReplyModelController.getAgoTime(replyDocs[index].get('timeStamp'));
                                                                return Padding(
                                                                  padding: const EdgeInsets.only(top: 16),
                                                                  child: Obx(() => Container(
                                                                    color: Colors.white,
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                      children: [
                                                                        (_userModelController.repoUidList!.contains(
                                                                            replyDocs[index].get('uid')))
                                                                            ? Center(
                                                                          child: Padding(
                                                                            padding:
                                                                            const EdgeInsets.symmetric(vertical: 16),
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
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                                  children: [
                                                                                    StreamBuilder(
                                                                                        stream:  FirebaseFirestore.instance
                                                                                            .collection('user')
                                                                                            .where('uid', isEqualTo: replyDocs[index]['uid'])
                                                                                            .snapshots(),
                                                                                        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                                                                                          if (!snapshot.hasData || snapshot.data == null) {
                                                                                            return SizedBox();
                                                                                          }
                                                                                          final userDoc = snapshot.data!.docs;
                                                                                          final userData = userDoc.isNotEmpty ? userDoc[0] : null;
                                                                                          if (userData == null) {
                                                                                            return SizedBox();
                                                                                          }
                                                                                          return Row(
                                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                                            children: [
                                                                                              if (userData['profileImageUrl'] != "")
                                                                                                GestureDetector(
                                                                                                  onTap: (){
                                                                                                    Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                                                                                  },
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.only(bottom: 8),
                                                                                                    child: Container(
                                                                                                      width: 26,
                                                                                                      height: 26,
                                                                                                      decoration: BoxDecoration(
                                                                                                          color: Color(0xFFDFECFF),
                                                                                                          borderRadius: BorderRadius.circular(50)
                                                                                                      ),
                                                                                                      child: ExtendedImage.network(
                                                                                                        userData['profileImageUrl'],
                                                                                                        cache: true,
                                                                                                        cacheHeight: 100,
                                                                                                        shape: BoxShape.circle,
                                                                                                        borderRadius:
                                                                                                        BorderRadius.circular(20),
                                                                                                        width: 26,
                                                                                                        height: 26,
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
                                                                                                                width: 26,
                                                                                                                height: 26,
                                                                                                                cacheHeight: 100,
                                                                                                                cache: true,
                                                                                                                fit: BoxFit.cover,
                                                                                                              ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                                                            default:
                                                                                                              return null;
                                                                                                          }
                                                                                                        },
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              if (userData['profileImageUrl'] == "")
                                                                                                GestureDetector(
                                                                                                  onTap: (){
                                                                                                    Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                                                                                  },
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.only(bottom: 8),
                                                                                                    child: ExtendedImage.network(
                                                                                                      '${profileImgUrlList[0].default_round}',
                                                                                                      shape: BoxShape.circle,
                                                                                                      borderRadius:
                                                                                                      BorderRadius.circular(20),
                                                                                                      width: 26,
                                                                                                      height: 26,
                                                                                                      cacheHeight: 100,
                                                                                                      cache: true,
                                                                                                      fit: BoxFit.cover,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              SizedBox(width: 12,),
                                                                                              Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        userData['displayName'],
                                                                                                        style: TextStyle(
                                                                                                            fontWeight: FontWeight.bold,
                                                                                                            fontSize: 14,
                                                                                                            color: Color(0xFF111111)),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                          width: 6),
                                                                                                      Text(
                                                                                                        userData['resortNickname'],
                                                                                                        style: TextStyle(
                                                                                                            fontSize: 13,
                                                                                                            color: Color(0xFF949494),
                                                                                                            fontWeight: FontWeight.w300),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                          width: 1),
                                                                                                      Text(
                                                                                                        '· $_time',
                                                                                                        style: TextStyle(
                                                                                                            fontSize: 13,
                                                                                                            color: Color(0xFF949494),
                                                                                                            fontWeight: FontWeight.w300),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                          width: 6),
                                                                                                      Padding(
                                                                                                        padding: EdgeInsets.only(top: 1),
                                                                                                        child: Container(
                                                                                                          decoration: BoxDecoration(
                                                                                                            borderRadius: BorderRadius.circular(30),
                                                                                                            color:
                                                                                                            (replyDocs[index].get('uid')==_bulletinLostModelController.uid)
                                                                                                                ? Color(0xFFE1EDFF)
                                                                                                                : Colors.white,
                                                                                                          ),
                                                                                                          child: Padding(
                                                                                                            padding: const EdgeInsets.only(top: 1, bottom: 3, left: 6, right: 6),
                                                                                                            child: Text(
                                                                                                              '글쓴이',
                                                                                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal,
                                                                                                                  color:
                                                                                                                  (replyDocs[index].get('uid')==_bulletinLostModelController.uid)
                                                                                                                      ? Color(0xFF3D83ED)
                                                                                                                      : Colors.white),
                                                                                                            ),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 2,
                                                                                                  ),
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        constraints:
                                                                                                        BoxConstraints(maxWidth: _size.width - 100),
                                                                                                        child:
                                                                                                        SelectableText(
                                                                                                          replyDocs[index].get('reply'),
                                                                                                          style: TextStyle(
                                                                                                              color: Color(0xFF111111),
                                                                                                              fontWeight: FontWeight.normal,
                                                                                                              fontSize: 13),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 8,
                                                                                                  ),
                                                                                                ],
                                                                                              )
                                                                                            ],
                                                                                          );
                                                                                        }),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            (replyDocs[index]['uid'] != _userModelController.uid)
                                                                                ? GestureDetector(
                                                                              onTap: () => showModalBottomSheet(
                                                                                  enableDrag: false,
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return SafeArea(
                                                                                      child: Container(
                                                                                        height:
                                                                                        140,
                                                                                        child:
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                                                                                                    Get.dialog(AlertDialog(
                                                                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                      elevation: 0,
                                                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                      content: Text(
                                                                                                        '이 회원을 신고하시겠습니까?',
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
                                                                                                                  var repoUid = replyDocs[index].get('uid');
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
                                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                ),
                                                                                              ),
                                                                                              GestureDetector(
                                                                                                child: ListTile(
                                                                                                  contentPadding: EdgeInsets.zero,
                                                                                                  title: Center(
                                                                                                    child: Text(
                                                                                                      '이 회원의 글 모두 숨기기',
                                                                                                      style: TextStyle(
                                                                                                        fontSize: 15,
                                                                                                        fontWeight: FontWeight.bold,
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                  //selected: _isSelected[index]!,
                                                                                                  onTap: () async {
                                                                                                    Get.dialog(AlertDialog(
                                                                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                                      elevation: 0,
                                                                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                                                                                      buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                      content:  Container(
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
                                                                                                                  var repoUid = replyDocs[index].get('uid');
                                                                                                                  _userModelController.updateRepoUid(repoUid);
                                                                                                                  Navigator.pop(context);
                                                                                                                  Navigator.pop(context);
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
                                                                                                  },
                                                                                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                                                                                ),
                                                                                              )
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  }),
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(
                                                                                    bottom: 22),
                                                                                child:
                                                                                Icon(
                                                                                  Icons.more_vert,
                                                                                  color: Color(0xFFdedede),
                                                                                  size: 22,
                                                                                ),
                                                                              ),
                                                                            )
                                                                                : GestureDetector(
                                                                              onTap: () => showModalBottomSheet(
                                                                                  enableDrag: false,
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return SafeArea(
                                                                                      child: Container(
                                                                                        height: 90,
                                                                                        child:
                                                                                        Padding(
                                                                                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                                                          child: Column(
                                                                                            children: [
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
                                                                                                              padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                                                                                              child: Column(
                                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                                children: [
                                                                                                                  SizedBox(
                                                                                                                    height: 30,
                                                                                                                  ),
                                                                                                                  Text(
                                                                                                                    '삭제하시겠습니까?',
                                                                                                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111111)),
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
                                                                                                                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                                                          ),
                                                                                                                          style: TextButton.styleFrom(splashFactory: InkRipple.splashFactory, elevation: 0, minimumSize: Size(100, 56), backgroundColor: Color(0xff555555), padding: EdgeInsets.symmetric(horizontal: 0)),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      SizedBox(
                                                                                                                        width: 10,
                                                                                                                      ),
                                                                                                                      Expanded(
                                                                                                                        child: ElevatedButton(
                                                                                                                          onPressed: () async {
                                                                                                                            CustomFullScreenDialog.showDialog();
                                                                                                                            var docName = '${_bulletinLostModelController.uid}#${_bulletinLostModelController.bulletinLostCount}';
                                                                                                                            try {
                                                                                                                              await FirebaseFirestore.instance
                                                                                                                                  .collection('bulletinLost')
                                                                                                                                  .doc('${_bulletinLostModelController.uid}#${_bulletinLostModelController.bulletinLostCount}')
                                                                                                                                  .collection('reply')
                                                                                                                                  .doc('${_userModelController.uid}${replyDocs[index]['commentCount']}')
                                                                                                                                  .delete();
                                                                                                                              String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.communityReplyKey_lost];
                                                                                                                              await _alarmCenterController.deleteAlarm(
                                                                                                                                  receiverUid: _bulletinLostModelController.uid,
                                                                                                                                  senderUid: _userModelController.uid ,
                                                                                                                                  category: alarmCategory,
                                                                                                                                  alarmCount: _bulletinLostModelController.bulletinLostCount
                                                                                                                              );
                                                                                                                              await _bulletinLostModelController.reduceBulletinLostReplyCount(
                                                                                                                                  bullUid: _bulletinLostModelController.uid,
                                                                                                                                  bullCount: _bulletinLostModelController.bulletinLostCount);
                                                                                                                              await _bulletinLostModelController.scoreDelete_reply(bullUid: _bulletinLostModelController.uid, docName: docName, timeStamp: _bulletinLostModelController.timeStamp, score: _bulletinLostModelController.score);
                                                                                                                              await _bulletinLostModelController.getCurrentBulletinLost(uid: _bulletinLostModelController.uid, bulletinLostCount: _bulletinLostModelController.bulletinLostCount);
                                                                                                                              print('댓글 삭제 완료');
                                                                                                                            } catch (e) {}
                                                                                                                            Navigator.pop(context);
                                                                                                                            CustomFullScreenDialog.cancelDialog();
                                                                                                                          },
                                                                                                                          child: Text(
                                                                                                                            '확인',
                                                                                                                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                                                                                                                          ),
                                                                                                                          style: TextButton.styleFrom(splashFactory: InkRipple.splashFactory, elevation: 0, minimumSize: Size(100, 56), backgroundColor: Color(0xff2C97FB), padding: EdgeInsets.symmetric(horizontal: 0)),
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
                                                                                      ),
                                                                                    );
                                                                                  }),
                                                                              child:
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(bottom: 22),
                                                                                child: Icon(Icons.more_vert,
                                                                                  color: Color(0xFFdedede),
                                                                                ),
                                                                              ),
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  )),
                                                                );
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                }
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                    ),
                    padding:
                    EdgeInsets.only(top: 16, left: 16, right: 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
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
                                        if(_controller.text.trim().isEmpty)
                                        {return ;}
                                        FocusScope.of(context).unfocus();
                                        _controller.clear();
                                        CustomFullScreenDialog.showDialog();
                                        // try{
                                        var docName = '${_bulletinLostModelController.uid}#${_bulletinLostModelController.bulletinLostCount}';
                                        await _userModelController.updateCommentCount(_userModelController.commentCount);
                                        await _bulletinLostModelController.updateBulletinLostReplyCount(
                                            bullUid: _bulletinLostModelController.uid,
                                            bullCount: _bulletinLostModelController.bulletinLostCount);
                                        await _bulletinLostReplyModelController.sendReply(
                                            replyResortNickname: _userModelController.resortNickname,
                                            displayName: _userModelController.displayName,
                                            uid: _userModelController.uid,
                                            replyLocationUid: _bulletinLostModelController.uid,
                                            profileImageUrl: _userModelController.profileImageUrl,
                                            reply: _newReply,
                                            replyLocationUidCount: _bulletinLostModelController.bulletinLostCount,
                                            commentCount: _userModelController.commentCount);
                                        String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.communityReplyKey_lost];
                                        await _alarmCenterController.sendAlarm(
                                            alarmCount: _bulletinLostModelController.bulletinLostCount,
                                            receiverUid: _bulletinLostModelController.uid,
                                            senderUid: _userModelController.uid,
                                            senderDisplayName: _userModelController.displayName,
                                            timeStamp: Timestamp.now(),
                                            category: alarmCategory,
                                            msg: '${_userModelController.displayName}님이 $alarmCategory에 댓글을 남겼습니다.',
                                            content: _newReply,
                                            docName: '${_bulletinLostModelController.uid}#${_bulletinLostModelController.bulletinLostCount}',
                                            liveTalk_uid : '',
                                            liveTalk_commentCount : '',
                                            bulletinRoomUid :'',
                                            bulletinRoomCount :'',
                                            bulletinCrewUid : '',
                                            bulletinCrewCount : '',
                                            bulletinEventUid : '',
                                            bulletinEventCount : '',
                                            bulletinLostUid : _bulletinLostModelController.uid,
                                            bulletinLostCount : _bulletinLostModelController.bulletinLostCount,
                                            originContent: _bulletinLostModelController.title,
                                            bulletinFreeUid: '',
                                            bulletinFreeCount: ''
                                        );
                                        await _bulletinLostModelController.getCurrentBulletinLost(uid: _bulletinLostModelController.uid, bulletinLostCount: _bulletinLostModelController.bulletinLostCount);
                                        CustomFullScreenDialog.cancelDialog();
                                        setState(() {});
                                        //   }catch(e){}
                                        _scrollController
                                            .jumpTo(
                                            (_replyReverse == true) ? _scrollController.position.maxScrollExtent
                                                : 0);
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
                                    hintStyle: TextStyle(color: Color(0xff949494), fontSize: 14),
                                    hintText: '답글 남기기',
                                    contentPadding:
                                    EdgeInsets.only(top: 10, bottom: 10, left: 16, right: 16),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFDEDEDE)),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Color(0xFFFF3726)),
                                      borderRadius: BorderRadius.circular(6),
                                    )),
                                onChanged: (value) {
                                  setState(() {
                                    _newReply = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
