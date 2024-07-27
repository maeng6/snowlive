import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/controller/public/vm_limitController.dart';
import 'package:com.snowlive/controller/bulletin/vm_streamController_bulletin.dart';
import 'package:com.snowlive/controller/public/vm_timeStampController.dart';
import 'package:com.snowlive/screens/bulletin/Free/v_bulletinFreeImageScreen.dart';
import 'package:com.snowlive/screens/bulletin/Free/v_bulletin_Free_ModifyPage.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/controller/user/vm_userModelController.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../../controller/alarm/vm_alarmCenterController.dart';
import '../../../controller/liveCrew/vm_allCrewDocsController.dart';
import '../../../controller/user/vm_allUserDocsController.dart';
import '../../../controller/bulletin/vm_bulletinFreeController.dart';
import '../../../controller/bulletin/vm_bulletinFreeReplyController.dart';
import '../../../data/imgaUrls/Data_url_image.dart';
import '../../../model/m_alarmCenterModel.dart';
import '../../more/friend/v_friendDetailPage.dart';
import '../../snowliveDesignStyle.dart';

class Bulletin_Free_List_Detail extends StatefulWidget {
  Bulletin_Free_List_Detail({Key? key}) : super(key: key);

  @override
  State<Bulletin_Free_List_Detail> createState() =>
      _Bulletin_Free_List_DetailState();
}

class _Bulletin_Free_List_DetailState extends State<Bulletin_Free_List_Detail> {
  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  BulletinFreeModelController _bulletinFreeModelController = Get.find<BulletinFreeModelController>();
  limitController _seasonController = Get.find<limitController>();
  AlarmCenterController _alarmCenterController = Get.find<AlarmCenterController>();
  TimeStampController _timeStampController = Get.find<TimeStampController>();
  StreamController_Bulletin _streamController_Bulletin = Get.find<StreamController_Bulletin>();
  AllCrewDocsController _allCrewDocsController = Get.find<AllCrewDocsController>();
  //TODO: Dependency Injection**************************************************

  final _controller = TextEditingController();
  var _newReply = '';
  final _formKey = GlobalKey<FormState>();
  bool _replyReverse = true;
  var _firstPress = true;
  int _currentIndex = 0;



  ScrollController _scrollController = ScrollController();

  ScrollController _scrollController2 = ScrollController();



  @override
  void initState() {
    _updateMethod();
    // TODO: implement initState
    super.initState();
    _seasonController.getBulletinFreeReplyLimit();
  }

  _updateMethod() async {
    await _userModelController.updateRepoUidList();
  }


  @override
  Widget build(BuildContext context) {

    //TODO : ****************************************************************
    Get.put(BulletinFreeReplyModelController(), permanent: true);
    BulletinFreeReplyModelController _bulletinFreeReplyModelController = Get.find<BulletinFreeReplyModelController>();
    //TODO : ****************************************************************

    _seasonController.getBulletinFreeReplyLimit();

    String _time =
    _timeStampController.yyyymmddFormat(_bulletinFreeModelController.timeStamp);
    Size _size = MediaQuery.of(context).size;
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(44),
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
                GestureDetector(
                  onTap: (){},
                  child: Padding(
                    padding: const EdgeInsets.only(right: 14),
                    child: Image.asset(
                      'assets/imgs/icons/icon_header_scrap.png',
                      width: 26,
                      height: 26,
                    ),
                  ),
                ),
                (_bulletinFreeModelController.uid != _userModelController.uid)
                    ? GestureDetector(
                  onTap: () => showModalBottomSheet(
                      enableDrag: false,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return SafeArea(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                              ),
                              height: 144,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  GestureDetector(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Text(
                                          '신고하기',
                                          style: SDSTextStyle.bold.copyWith(
                                            fontSize: 15,
                                            color: SDSColor.gray900
                                          ),
                                        ),
                                      ),
                                      //selected: _isSelected[index]!,
                                      onTap: () async {
                                        Get.dialog(
                                            AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16)),
                                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                              content: Container(
                                                height: 32,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Text('이 회원을 신고하시겠습니까?',
                                                      style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 16,
                                                          color: SDSColor.gray900),
                                            ),
                                                  ],
                                                ),
                                              ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    child: TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: Text(
                                                          '취소',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 16,
                                                            color: SDSColor.gray500,
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: TextButton(
                                                        onPressed: () async {
                                                          var repoUid = _bulletinFreeModelController.uid;
                                                          await _userModelController.repoUpdate(
                                                              repoUid);
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          '신고하기',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 16,
                                                            color: SDSColor.gray900,
                                                          ),
                                                        )),
                                                  ),
                                                )
                                              ],

                                            )
                                          ],
                                        ));
                                      },
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(16)),
                                    ),
                                  ),
                                  GestureDetector(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Text(
                                          '이 회원의 글 모두 숨기기',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 15,
                                              color: SDSColor.gray900
                                          ),
                                        ),
                                      ),
                                      //selected: _isSelected[index]!,
                                      onTap: () async {
                                        Get.dialog(
                                            AlertDialog(
                                              contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(16)),
                                              buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                          content:  Container(
                                            height: 70,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '이 회원의 게시물을 모두 숨길까요?',
                                                  style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 16,
                                                      color: SDSColor.gray900),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 8),
                                                  child: Text(
                                                    '차단해제는 [더보기 - 친구 - 설정 - 차단목록]에서하실 수 있습니다.',
                                                    style: SDSTextStyle.regular.copyWith(
                                                        fontSize: 14,
                                                        color: SDSColor.gray600,
                                                        height: 1.4),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    child: TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          '취소',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 16,
                                                            color: SDSColor.gray500,
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    child: TextButton(
                                                        onPressed: () {
                                                          var repoUid = _bulletinFreeModelController.uid;
                                                          _userModelController.updateRepoUid(repoUid);
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                          Navigator.pop(context);
                                                        },
                                                        child: Text(
                                                          '확인',
                                                          style: SDSTextStyle.bold.copyWith(
                                                            fontSize: 16,
                                                            color: SDSColor.gray900,
                                                          ),
                                                        )),
                                                  ),
                                                )
                                              ],

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
                    padding: const EdgeInsets.only(right: 14),
                    child: Image.asset(
                      'assets/imgs/icons/icon_header_more.png',
                      width: 26,
                      height: 26,
                    ),
                  ),
                )
                    : GestureDetector(
                  onTap: () => showModalBottomSheet(
                      enableDrag: false,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: SafeArea(
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 16,
                                right: 16,
                                top: 16,
                              ),
                              height: 144,
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  (_bulletinFreeModelController.uid == _userModelController.uid)?
                                  GestureDetector(
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Text(
                                          '수정하기',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 15,
                                              color: SDSColor.gray900
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
                                                () => Bulletin_Free_ModifyPage());
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
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 15,
                                              color: SDSColor.red
                                          ),
                                        ),
                                      ),
                                      //selected: _isSelected[index]!,
                                      onTap: () async {
                                        Navigator.pop(context);
                                        showModalBottomSheet(
                                            context: context,
                                            builder: (context) {
                                              return SafeArea(
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                                    color: SDSColor.snowliveWhite,
                                                  ),
                                                  padding: EdgeInsets.only(bottom: 20, right: 20, left: 20, top: 12),
                                                  height: 160,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Padding(
                                                        padding: const EdgeInsets.only(bottom: 20),
                                                        child: Container(
                                                          height: 4,
                                                          width: 36,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(10),
                                                            color: SDSColor.gray200,
                                                          ),
                                                        ),
                                                      ),
                                                      Text(
                                                        '삭제하시겠습니까?',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 16, color: SDSColor.gray900),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      Expanded(child: Container()),
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
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: SDSColor.snowliveWhite,
                                                                    fontSize: 16),
                                                              ),
                                                              style: TextButton.styleFrom(
                                                                  splashFactory: InkRipple.splashFactory,
                                                                  elevation: 0,
                                                                  minimumSize: Size(100, 48),
                                                                  backgroundColor: SDSColor.sBlue500
                                                              ),
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
                                                                      .collection('bulletinFree')
                                                                      .doc('${_userModelController.uid}#${_bulletinFreeModelController.bulletinFreeCount}')
                                                                      .delete();
                                                                  try {
                                                                    await _bulletinFreeModelController.deleteBulletinFreeImage(
                                                                        uid:
                                                                        _userModelController.uid,
                                                                        bulletinFreeCount: _bulletinFreeModelController.bulletinFreeCount,
                                                                        imageCount: _bulletinFreeModelController.itemImagesUrls!.length);
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
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: SDSColor.snowliveWhite,
                                                                    fontSize: 16),
                                                              ),
                                                              style: TextButton.styleFrom(
                                                                splashFactory: InkRipple.splashFactory,
                                                                elevation: 0,
                                                                minimumSize: Size(100, 48),
                                                                backgroundColor: SDSColor.snowliveBlue,
                                                              ),
                                                          ),
                                                          )
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
                    padding: const EdgeInsets.only(right: 14),
                    child: Image.asset(
                      'assets/imgs/icons/icon_header_more.png',
                      width: 26,
                      height: 26,
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
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: SDSColor.blue50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${_bulletinFreeModelController.category}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: SDSTextStyle.regular.copyWith(
                                            fontSize: 12,
                                            color: SDSColor.snowliveBlue),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Container(
                                    width: _size.width - 32,
                                    child: Text(
                                      (_bulletinFreeModelController.soldOut == true)
                                          ? '거래완료'
                                          : '${_bulletinFreeModelController.title}',
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: SDSTextStyle.bold.copyWith(
                                          fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      StreamBuilder(
                                          stream: _streamController_Bulletin.setupStreams_bulletinFree_detail_user(),
                                          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                                            if (!snapshot.hasData || snapshot.data == null) {
                                              return  SizedBox();
                                            }
                                            final userDoc = snapshot.data!.docs;
                                            final userData = userDoc.isNotEmpty ? userDoc[0] : null;

                                            String? crewName = _allCrewDocsController.findCrewName(userData['liveCrew'], _allCrewDocsController.allCrewDocs);

                                            if (userData == null) {
                                              return SizedBox();
                                            }
                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Text('$_time',
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
                                                          child: Text('48',
                                                            // '${viewerUid.length.toString()}',
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
                                                          child: Text('492',
                                                            // chatDocs[index].get('bulletinFreeReplyCount').toString(),
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
                                                GestureDetector(
                                                  onTap: (){
                                                    Get.to(() => FriendDetailPage(uid: userData['uid'], favoriteResort: userData['favoriteResort'],));
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(top: 16),
                                                    child: Row(
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        if (userData['profileImageUrl'] != "")
                                                          Container(
                                                            width: 32,
                                                            height: 32,
                                                            decoration: BoxDecoration(
                                                                color: SDSColor.blue50,
                                                                borderRadius: BorderRadius.circular(50),
                                                              border: Border.all(
                                                                color: SDSColor.gray100,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: ExtendedImage.network(
                                                              userData['profileImageUrl'],
                                                              cache: true,
                                                              cacheHeight: 100,
                                                              shape: BoxShape.circle,
                                                              borderRadius:
                                                              BorderRadius.circular(20),
                                                              width: 32,
                                                              height: 32,
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
                                                                      width: 32,
                                                                      height: 32,
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
                                                            width: 32,
                                                            height: 32,
                                                            cacheHeight: 100,
                                                            cache: true,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(left: 10),
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text('${userData['displayName']}',
                                                                //chatDocs[index].get('displayName'),
                                                                style: SDSTextStyle.regular.copyWith(
                                                                    fontSize: 12,
                                                                    color: SDSColor.gray900),
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 2),
                                                                child: Row(
                                                                  children: [
                                                                    Text('${userData['resortNickname']}',
                                                                      //chatDocs[index].get('displayName'),
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 12,
                                                                          color: SDSColor.gray500),
                                                                    ),
                                                                    Text(' · ${crewName}',
                                                                      //chatDocs[index].get('displayName'),
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 12,
                                                                          color: SDSColor.gray500),
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
                                                ),
                                              ],
                                            );
                                          }),
                                    ],
                                  ),
                                  Divider(
                                    color: SDSColor.gray50,
                                    height: 32,
                                    thickness: 1,
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
                                            if (_bulletinFreeModelController.itemImagesUrls!.isEmpty)
                                              Container(),
                                            if (_bulletinFreeModelController.itemImagesUrls!.isNotEmpty)
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
                                                    _bulletinFreeModelController.itemImagesUrls!.length,
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
                                                                      Get.to(() => BulletinFreeImageScreen());
                                                                    },
                                                                    child: ExtendedImage.network(
                                                                      _bulletinFreeModelController.itemImagesUrls![index],
                                                                      fit: BoxFit.fitWidth,
                                                                      width: _size.width - 32,
                                                                      cacheHeight: 500,
                                                                        borderRadius: BorderRadius.circular(8)
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
                                                          _bulletinFreeModelController.itemImagesUrls!.length,
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
                                            Container(
                                              width: _size.width,
                                              child: SelectableText(
                                                '${_bulletinFreeModelController.description}',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 15,
                                                    height: 1.4
                                                ),
                                              ),
                                            ),
                                            Container(
                                              height: 20,
                                            )
                                          ],
                                        ),
                                      ]),
                                ),
                                Divider(
                                  color: SDSColor.gray50,
                                  height: 60,
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
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 20),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      '답글',
                                                      style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 14,
                                                          color: SDSColor.gray900),
                                                    ),
                                                    Text(
                                                      ' 24',
                                                      style: SDSTextStyle.bold.copyWith(
                                                          fontSize: 14,
                                                          color: SDSColor.gray900),
                                                    ),
                                                  ],
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
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      (_replyReverse == true)
                                                      ? Padding(
                                                        padding: const EdgeInsets.only(bottom: 1),
                                                        child: Image.asset('assets/imgs/icons/icon_filter_latest.png',
                                                          fit: BoxFit.cover,
                                                          width: 14,
                                                          height: 14,
                                                          color: SDSColor.gray300,
                                                        ),
                                                      )
                                                      : Padding(
                                                        padding: const EdgeInsets.only(bottom: 1),
                                                        child: Image.asset('assets/imgs/icons/icon_filter_latest.png',
                                                          fit: BoxFit.cover,
                                                          width: 14,
                                                          height: 14,
                                                          color: SDSColor.gray900,
                                                        ),
                                                      ),
                                                      Text(
                                                        '최신순',
                                                        style: SDSTextStyle.regular.copyWith(
                                                            fontSize: 13,
                                                            color:
                                                            (_replyReverse == true)
                                                                ? SDSColor.gray500 : SDSColor.gray900),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            child: StreamBuilder<QuerySnapshot>(
                                                stream: _streamController_Bulletin.setupStreams_bulletinFree_detail_reply(),
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
                                                                ? Center(
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.symmetric(vertical: 80),
                                                                    child: Text('첫 답글을 남겨주세요!',
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 14,
                                                                          color: SDSColor.gray500
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                                : ListView.builder(
                                                              controller: _scrollController2,
                                                              shrinkWrap: true,
                                                              reverse: _replyReverse,
                                                              itemCount: replyDocs.length,
                                                              itemBuilder: (context, index) {
                                                                String _time = _bulletinFreeReplyModelController.getAgoTime(replyDocs[index].get('timeStamp'));
                                                                return Padding(
                                                                  padding: const EdgeInsets.only(bottom: 30),
                                                                  child: Obx(() => Container(
                                                                    color: Colors.white,
                                                                    child: Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment.start,
                                                                      children: [
                                                                        (_userModelController.repoUidList!.contains(
                                                                            replyDocs[index].get('uid')))
                                                                            ? Container()
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
                                                                                        stream: _streamController_Bulletin.setupStreams_bulletinFree_detail_user_reply('${replyDocs[index]['uid']}'),
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
                                                                                                      width: 32,
                                                                                                      height: 32,
                                                                                                      decoration: BoxDecoration(
                                                                                                          color: SDSColor.blue50,
                                                                                                          borderRadius: BorderRadius.circular(50),
                                                                                                        border: Border.all(
                                                                                                          color: SDSColor.gray100,
                                                                                                          width: 1,
                                                                                                        ),

                                                                                                      ),
                                                                                                      child: ExtendedImage.network(
                                                                                                        userData['profileImageUrl'],
                                                                                                        cache: true,
                                                                                                        cacheHeight: 100,
                                                                                                        shape: BoxShape.circle,
                                                                                                        borderRadius:
                                                                                                        BorderRadius.circular(20),
                                                                                                        width: 32,
                                                                                                        height: 32,
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
                                                                                                                width: 32,
                                                                                                                height: 32,
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
                                                                                                      width: 32,
                                                                                                      height: 32,
                                                                                                      cacheHeight: 100,
                                                                                                      cache: true,
                                                                                                      fit: BoxFit.cover,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              SizedBox(width: 10),
                                                                                              Column(
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                                    children: [
                                                                                                      Text(
                                                                                                        userData['displayName'],
                                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                                            fontSize: 13,
                                                                                                            color: SDSColor.gray900),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                          width: 6),
                                                                                                      Text(
                                                                                                        userData['resortNickname'],
                                                                                                        style: SDSTextStyle.regular.copyWith(
                                                                                                            fontSize: 12,
                                                                                                            color: SDSColor.gray500,
                                                                                                        ),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                          width: 1),
                                                                                                      Text(
                                                                                                        '· $_time',
                                                                                                        style: SDSTextStyle.regular.copyWith(
                                                                                                          fontSize: 12,
                                                                                                          color: SDSColor.gray500,
                                                                                                        ),
                                                                                                      ),
                                                                                                      SizedBox(width: 6),
                                                                                                      Container(
                                                                                                        decoration: BoxDecoration(
                                                                                                          borderRadius: BorderRadius.circular(30),
                                                                                                          color:
                                                                                                          (replyDocs[index].get('uid')==_bulletinFreeModelController.uid)
                                                                                                              ? SDSColor.blue100
                                                                                                              : Colors.transparent,
                                                                                                        ),
                                                                                                        child: Padding(
                                                                                                          padding: const EdgeInsets.only(top: 3, bottom: 3, left: 6, right: 6),
                                                                                                          child: Text(
                                                                                                            '글쓴이',
                                                                                                            style: SDSTextStyle.bold.copyWith(fontSize: 11,
                                                                                                                color:
                                                                                                                (replyDocs[index].get('uid')==_bulletinFreeModelController.uid)
                                                                                                                    ? SDSColor.snowliveBlue
                                                                                                                    : Colors.transparent),
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 4,
                                                                                                  ),
                                                                                                  Container(
                                                                                                    constraints:
                                                                                                    BoxConstraints(maxWidth: _size.width - 110),
                                                                                                    child:
                                                                                                    SelectableText(
                                                                                                      replyDocs[index].get('reply'),
                                                                                                      style: SDSTextStyle.regular.copyWith(
                                                                                                          color: SDSColor.gray900,
                                                                                                          fontSize: 14,
                                                                                                      height: 1.4),
                                                                                                    ),
                                                                                                  ),
                                                                                                  Padding(
                                                                                                    padding: const EdgeInsets.only(top: 10),
                                                                                                    child: Text(
                                                                                                      '답글 4개 보기',
                                                                                                      style: SDSTextStyle.bold.copyWith(
                                                                                                          color: SDSColor.gray900,
                                                                                                          fontSize: 14,
                                                                                                          height: 1.4),
                                                                                                    ),
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
                                                                                  isScrollControlled: true,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return SafeArea(
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(vertical: 20),
                                                                                        child: Container(
                                                                                          margin: EdgeInsets.only(
                                                                                            left: 16,
                                                                                            right: 16,
                                                                                            top: 16,
                                                                                          ),
                                                                                          height: 144,
                                                                                          padding: EdgeInsets.all(16),
                                                                                          decoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.circular(16),
                                                                                          ),
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
                                                                                                          contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                                                                                                          elevation: 0,
                                                                                                          shape: RoundedRectangleBorder(
                                                                                                              borderRadius: BorderRadius.circular(16)),
                                                                                                          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                          content: Container(
                                                                                                            height: 32,
                                                                                                            child: Column(
                                                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                              children: [
                                                                                                                Text('이 회원을 신고하시겠습니까?',
                                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                                      fontSize: 16,
                                                                                                                      color: SDSColor.gray900),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                      actions: [
                                                                                                        Row(
                                                                                                          children: [
                                                                                                            Expanded(
                                                                                                              child: Container(
                                                                                                                child: TextButton(
                                                                                                                    onPressed: () {
                                                                                                                      Navigator.pop(context);
                                                                                                                    },
                                                                                                                    child: Text(
                                                                                                                      '취소',
                                                                                                                      style: SDSTextStyle.bold.copyWith(
                                                                                                                        fontSize: 16,
                                                                                                                        color: SDSColor.gray500,
                                                                                                                      ),
                                                                                                                    )),
                                                                                                              ),
                                                                                                            ),
                                                                                                            Expanded(
                                                                                                              child: Container(
                                                                                                                child: TextButton(
                                                                                                                    onPressed: () async {
                                                                                                                      var repoUid = replyDocs[index].get('uid');
                                                                                                                      await _userModelController.repoUpdate(repoUid);
                                                                                                                      Navigator.pop(context);
                                                                                                                      Navigator.pop(context);
                                                                                                                    },
                                                                                                                    child: Text(
                                                                                                                      '신고',
                                                                                                                      style: SDSTextStyle.bold.copyWith(
                                                                                                                        fontSize: 16,
                                                                                                                        color: SDSColor.gray900,
                                                                                                                      ),
                                                                                                                    )),
                                                                                                              ),
                                                                                                            )
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
                                                                                                    Get.dialog(
                                                                                                        AlertDialog(
                                                                                                          contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 30),
                                                                                                          elevation: 0,
                                                                                                          shape: RoundedRectangleBorder(
                                                                                                              borderRadius: BorderRadius.circular(16)),
                                                                                                          buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                          content:  Container(
                                                                                                            height: 70,
                                                                                                            child: Column(
                                                                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                              children: [
                                                                                                                Text(
                                                                                                                  '이 회원의 게시물을 모두 숨길까요?',
                                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                                      fontSize: 16,
                                                                                                                      color: SDSColor.gray900),
                                                                                                                ),
                                                                                                                Padding(
                                                                                                                  padding: const EdgeInsets.only(top: 8),
                                                                                                                  child: Text(
                                                                                                                    '차단해제는 [더보기 - 친구 - 설정 - 차단목록]에서하실 수 있습니다.',
                                                                                                                    style: SDSTextStyle.regular.copyWith(
                                                                                                                        fontSize: 14,
                                                                                                                        color: SDSColor.gray600,
                                                                                                                        height: 1.4),
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                  ),
                                                                                                                ),
                                                                                                              ],
                                                                                                            ),
                                                                                                          ),
                                                                                                      actions: [
                                                                                                        Row(
                                                                                                          children: [
                                                                                                            Expanded(
                                                                                                              child: Container(
                                                                                                                child: TextButton(
                                                                                                                    onPressed: () {
                                                                                                                      Navigator.pop(context);
                                                                                                                    },
                                                                                                                    child: Text(
                                                                                                                        '취소',
                                                                                                                      style: SDSTextStyle.bold.copyWith(
                                                                                                                        fontSize: 16,
                                                                                                                        color: SDSColor.gray500,
                                                                                                                      ),
                                                                                                                    )),
                                                                                                              ),
                                                                                                            ),
                                                                                                            Expanded(
                                                                                                              child: Container(
                                                                                                                child: TextButton(
                                                                                                                    onPressed: () {
                                                                                                                      var repoUid = replyDocs[index].get('uid');
                                                                                                                      _userModelController.updateRepoUid(repoUid);
                                                                                                                      Navigator.pop(context);
                                                                                                                      Navigator.pop(context);
                                                                                                                    },
                                                                                                                    child: Text(
                                                                                                                      '확인',
                                                                                                                      style: SDSTextStyle.bold.copyWith(
                                                                                                                        fontSize: 16,
                                                                                                                        color: SDSColor.gray900,
                                                                                                                      ),
                                                                                                                    )),
                                                                                                              ),
                                                                                                            )
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
                                                                                padding: const EdgeInsets.only(bottom: 22),
                                                                                child:
                                                                                Icon(
                                                                                  Icons.more_vert,
                                                                                  color: SDSColor.gray200,
                                                                                  size: 20,
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
                                                                                                                            var docName = '${_bulletinFreeModelController.uid}#${_bulletinFreeModelController.bulletinFreeCount}';
                                                                                                                            try {
                                                                                                                              await FirebaseFirestore.instance
                                                                                                                                  .collection('bulletinFree')
                                                                                                                                  .doc('${_bulletinFreeModelController.uid}#${_bulletinFreeModelController.bulletinFreeCount}')
                                                                                                                                  .collection('reply')
                                                                                                                                  .doc('${_userModelController.uid}${replyDocs[index]['commentCount']}')
                                                                                                                                  .delete();
                                                                                                                              String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.communityReplyKey_free];
                                                                                                                              await _alarmCenterController.deleteAlarm(
                                                                                                                                  receiverUid: _bulletinFreeModelController.uid,
                                                                                                                                  senderUid: _userModelController.uid ,
                                                                                                                                  category: alarmCategory,
                                                                                                                                  alarmCount: _bulletinFreeModelController.bulletinFreeCount
                                                                                                                              );
                                                                                                                              await _bulletinFreeModelController.reduceBulletinFreeReplyCount(
                                                                                                                                  bullUid: _bulletinFreeModelController.uid,
                                                                                                                                  bullCount: _bulletinFreeModelController.bulletinFreeCount);
                                                                                                                              await _bulletinFreeModelController.scoreDelete_reply(bullUid: _bulletinFreeModelController.uid, docName: docName, timeStamp: _bulletinFreeModelController.timeStamp, score: _bulletinFreeModelController.score);
                                                                                                                              await _bulletinFreeModelController.getCurrentBulletinFree(uid: _bulletinFreeModelController.uid, bulletinFreeCount: _bulletinFreeModelController.bulletinFreeCount);
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
                  Column(
                    children: [
                      Container(
                        width: _size.width,
                        color: SDSColor.gray50,
                        height: 1,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        padding: EdgeInsets.only(top: 12, left: 12, right: 12, bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                key: _formKey,
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor: SDSColor.snowliveBlue,
                                cursorHeight: 16,
                                cursorWidth: 2,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                controller: _controller,
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 15
                                ),
                                strutStyle: StrutStyle(fontSize: 14, leading: 0),
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
                                        var docName = '${_bulletinFreeModelController.uid}#${_bulletinFreeModelController.bulletinFreeCount}';
                                        await _userModelController.updateCommentCount(_userModelController.commentCount);
                                        await _bulletinFreeModelController.updateBulletinFreeReplyCount(
                                            bullUid: _bulletinFreeModelController.uid,
                                            bullCount: _bulletinFreeModelController.bulletinFreeCount);
                                        await _bulletinFreeReplyModelController.sendReply(
                                            replyResortNickname: _userModelController.resortNickname,
                                            displayName: _userModelController.displayName,
                                            uid: _userModelController.uid,
                                            replyLocationUid: _bulletinFreeModelController.uid,
                                            profileImageUrl: _userModelController.profileImageUrl,
                                            reply: _newReply,
                                            replyLocationUidCount: _bulletinFreeModelController.bulletinFreeCount,
                                            commentCount: _userModelController.commentCount);
                                        String? alarmCategory = AlarmCenterModel().alarmCategory[AlarmCenterModel.communityReplyKey_free];
                                        await _alarmCenterController.sendAlarm(
                                            alarmCount: _bulletinFreeModelController.bulletinFreeCount,
                                            receiverUid: _bulletinFreeModelController.uid,
                                            senderUid: _userModelController.uid,
                                            senderDisplayName: _userModelController.displayName,
                                            timeStamp: Timestamp.now(),
                                            category: alarmCategory,
                                            msg: '${_userModelController.displayName}님이 $alarmCategory에 댓글을 남겼습니다.',
                                            content: _newReply,
                                            docName: '${_bulletinFreeModelController.uid}#${_bulletinFreeModelController.bulletinFreeCount}',
                                            liveTalk_uid : '',
                                            liveTalk_commentCount : '',
                                            bulletinRoomUid :'',
                                            bulletinRoomCount :'',
                                            bulletinCrewUid : '',
                                            bulletinCrewCount : '',
                                            bulletinEventUid : '',
                                            bulletinEventCount : '',
                                            bulletinFreeUid : _bulletinFreeModelController.uid,
                                            bulletinFreeCount : _bulletinFreeModelController.bulletinFreeCount,
                                            originContent: _bulletinFreeModelController.title,
                                            bulletinLostUid: '',
                                            bulletinLostCount: ''
                                        );
                                        await _bulletinFreeModelController.scoreUpdate_reply(bullUid: _bulletinFreeModelController.uid, docName: docName, timeStamp: _bulletinFreeModelController.timeStamp, score: _bulletinFreeModelController.score);
                                        await _bulletinFreeModelController.getCurrentBulletinFree(uid: _bulletinFreeModelController.uid, bulletinFreeCount: _bulletinFreeModelController.bulletinFreeCount);
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
                                        width: 24,
                                        height: 24,
                                      )
                                          : Image.asset(
                                        'assets/imgs/icons/icon_livetalk_send.png',
                                        width: 24,
                                        height: 24,
                                      ),
                                    ),
                                    errorStyle: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.red,
                                    ),
                                    labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                    hintText: '답글을 남겨 주세요.',
                                    contentPadding: EdgeInsets.only(
                                        top: 14, bottom: 14, left: 12, right: 12),
                                    fillColor: SDSColor.gray50,
                                    hoverColor: SDSColor.snowliveBlue,
                                    filled: true,
                                    focusColor: SDSColor.snowliveBlue,
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: SDSColor.gray50),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    errorBorder:  OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: SDSColor.red,
                                          strokeAlign: BorderSide.strokeAlignInside,
                                          width: 1.5),
                                    ),
                                    focusedBorder:  OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: SDSColor.snowliveBlue,
                                          strokeAlign: BorderSide.strokeAlignInside,
                                          width: 1.5),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.transparent),
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