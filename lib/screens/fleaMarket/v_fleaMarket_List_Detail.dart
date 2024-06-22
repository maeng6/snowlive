import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/controller/vm_fleaMarketController.dart';
import 'package:com.snowlive/controller/vm_userModelController.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarketImageScreen.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarket_ModifyPage.dart';
import 'package:com.snowlive/screens/fleaMarket/v_phone_Auth_Screen.dart';
import 'package:com.snowlive/screens/more/friend/v_friendDetailPage.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import '../../controller/vm_streamController_fleaMarket.dart';
import '../../controller/vm_urlLauncherController.dart';

class FleaMarket_List_Detail extends StatefulWidget {
  FleaMarket_List_Detail({Key? key}) : super(key: key);

  @override
  State<FleaMarket_List_Detail> createState() => _FleaMarket_List_DetailState();
}

class _FleaMarket_List_DetailState extends State<FleaMarket_List_Detail> {

  //TODO: Dependency Injection**************************************************
  UserModelController _userModelController = Get.find<UserModelController>();
  FleaModelController _fleaModelController = Get.find<FleaModelController>();
  UrlLauncherController _urlLauncherController = Get.find<UrlLauncherController>();
  StreamController_fleaMarket _streamController_fleaMarket = Get.find<StreamController_fleaMarket>();
//TODO: Dependency Injection**************************************************

  Stream<QuerySnapshot<Map<String, dynamic>>>? _fleaStream;
  var f = NumberFormat('###,###,###,###');
  int _currentIndex = 0;


  @override
  void initState() {
    _fleaStream = _streamController_fleaMarket.fleaStream_fleaMarket_List_Detail.value;
  }


  @override
  Widget build(BuildContext context) {
    String _time =
    _fleaModelController.getAgoTime(_fleaModelController.timeStamp);
    Size _size = MediaQuery.of(context).size;
    bool isSoldOut = _fleaModelController.soldOut!;

    return StreamBuilder(
          stream: _fleaStream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {}
            else if (snapshot.data!.docs.isNotEmpty) {
              final userDocs = snapshot.data!.docs;
              return  Container(
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
                          (_fleaModelController.uid != _userModelController.uid)
                              ? GestureDetector(
                            onTap: () => showModalBottomSheet(
                                enableDrag: false,
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: 180,
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
                                                            onPressed: () async {
                                                              var repoUid = _fleaModelController.uid;
                                                              await _userModelController.repoUpdate(repoUid);
                                                              Navigator.pop(context);
                                                              Navigator.pop(context);
                                                            },
                                                            child: Text('신고',
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
                                                  EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 0),
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
                                                              Navigator.pop(
                                                                  context);
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
                                                              var repoUid = _fleaModelController
                                                                  .uid;
                                                              _userModelController.updateRepoUid(repoUid);
                                                              Navigator.pop(context);
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
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 1, right: 16),
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
                                  return Container(
                                    height: 130,
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
                                                                    child:
                                                                    ElevatedButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(context);
                                                                      },
                                                                      child: Text(
                                                                        '취소',
                                                                        style: TextStyle(
                                                                            color: Colors
                                                                                .white,
                                                                            fontSize: 15,
                                                                            fontWeight: FontWeight.bold),
                                                                      ),
                                                                      style: TextButton.styleFrom(
                                                                          splashFactory:
                                                                          InkRipple.splashFactory,
                                                                          elevation: 0,
                                                                          minimumSize:
                                                                          Size(100, 56),
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
                                                                        CustomFullScreenDialog
                                                                            .showDialog();
                                                                        try {
                                                                          await FirebaseFirestore.instance.collection('fleaMarket').doc('${_userModelController.uid}#${_fleaModelController.fleaCount}').delete();
                                                                          try {
                                                                            await _fleaModelController.deleteFleaImage(
                                                                                uid: _userModelController.uid,
                                                                                fleaCount: _fleaModelController.fleaCount,
                                                                                imageCount: _fleaModelController.itemImagesUrls!.length);
                                                                          }catch(e){
                                                                            print('이미지 삭제 에러');
                                                                          };
                                                                          Navigator.pop(context);
                                                                        } catch (e) {}
                                                                        print('게시글 삭제 완료');
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
                                                                          minimumSize:
                                                                          Size(100, 56),
                                                                          backgroundColor:
                                                                          Color(0xff2C97FB),
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
                                                  borderRadius:
                                                  BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 1, right: 16),
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
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Column(
                            children: [
                              if (_fleaModelController.itemImagesUrls!.isEmpty)
                                Container(
                                  color: Color(0xFFB9D5FF),
                                  child: ExtendedImage.asset(
                                    'assets/imgs/profile/img_profile_default_.png',
                                    fit: BoxFit.fitHeight,
                                    width: _size.width,
                                    height: 280,
                                  ),
                                ),
                              if (_fleaModelController.itemImagesUrls!.isNotEmpty)
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
                                      itemCount: _fleaModelController.itemImagesUrls!.length,
                                      itemBuilder: (context, index, pageViewIndex) {
                                        return Container(
                                          child: StreamBuilder<Object>(
                                            stream: null,
                                            builder: (context, snapshot) {
                                              return Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  GestureDetector(
                                                    onTap: () {
                                                      Get.to(() => FleaMarketImageScreen());
                                                    },
                                                    child: ExtendedImage.network(
                                                      _fleaModelController.itemImagesUrls![index],
                                                      fit: BoxFit.cover,
                                                      width: _size.width,
                                                      height: 280,
                                                      cacheHeight: 1080,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(top: 260),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: List.generate(
                                            _fleaModelController.itemImagesUrls!.length,
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
                              SizedBox(
                                height: 16,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                if (_fleaModelController.profileImageUrl!.isEmpty)
                                                  GestureDetector(
                                                    onTap: (){
                                                      Get.to(()=>FriendDetailPage(uid: _fleaModelController.uid, favoriteResort: userDocs[0]['favoriteResort'],));
                                                    },
                                                    child: ExtendedImage.asset(
                                                      'assets/imgs/profile/img_profile_default_circle.png',
                                                      shape: BoxShape.circle,
                                                      borderRadius: BorderRadius.circular(20),
                                                      width: 32,
                                                      height: 32,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                if (_fleaModelController.profileImageUrl!.isNotEmpty)
                                                  GestureDetector(
                                                    onTap: (){
                                                      Get.to(()=>FriendDetailPage(uid: _fleaModelController.uid, favoriteResort: userDocs[0]['favoriteResort']));
                                                    },
                                                    child: Container(
                                                      width: 32,
                                                      height: 32,
                                                      decoration: BoxDecoration(
                                                          color: Color(0xFFDFECFF),
                                                          borderRadius: BorderRadius.circular(50)
                                                      ),
                                                      child: ExtendedImage.network(
                                                        '${_fleaModelController.profileImageUrl}',
                                                        shape: BoxShape.circle,
                                                        borderRadius: BorderRadius.circular(20),
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
                                                              return ExtendedImage.asset(
                                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                                shape: BoxShape.circle,
                                                                borderRadius: BorderRadius.circular(8),
                                                                width: 32,
                                                                height: 32,
                                                                fit: BoxFit.cover,
                                                              ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                            default:
                                                              return null;
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                SizedBox(width: 12),
                                                Padding(
                                                  padding: const EdgeInsets.only(bottom: 2),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Text(
                                                                '${_fleaModelController.displayName}',
                                                                //chatDocs[index].get('displayName'),
                                                                style: TextStyle(
                                                                    fontWeight: FontWeight.bold,
                                                                    fontSize: 14,
                                                                    color: Color(0xFF111111)),
                                                              ),
                                                              SizedBox(width: 6),
                                                              Text(
                                                                '$_time',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: Color(0xFF949494),
                                                                    fontWeight:
                                                                    FontWeight.w300),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if(_fleaModelController.kakaoUrl != null && _fleaModelController.kakaoUrl != '' && (_fleaModelController.soldOut == false))
                                              GestureDetector(
                                                onTap: (){
                                                  if(_fleaModelController.kakaoUrl!.isNotEmpty && _fleaModelController.kakaoUrl != '' ) {
                                                    _urlLauncherController.otherShare(contents: '${_fleaModelController.kakaoUrl}');
                                                  }else{
                                                    Get.dialog(AlertDialog(
                                                      contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                      elevation: 0,
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(10.0)),
                                                      buttonPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 20,
                                                          vertical: 0),
                                                      content: Text(
                                                        '연결된 카카오 오픈채팅이 없습니다.',
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
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(5),
                                                    color: Color(0xFFFEE500),
                                                  ),
                                                  padding: EdgeInsets.only(right: 8, left: 6, top: 5, bottom: 5),
                                                  child: Row(
                                                    children: [
                                                      ExtendedImage.asset(
                                                        'assets/imgs/logos/kakao_logo.png',
                                                        enableMemoryCache: true,
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(7),
                                                        width: 18,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      SizedBox(
                                                        width: 2,
                                                      ),
                                                      Text(
                                                        '카카오 오픈채팅',
                                                        style: TextStyle(
                                                            fontWeight: FontWeight.bold,
                                                            fontSize: 12,
                                                            color: Colors.black),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        Divider(
                                          height: 32,
                                          thickness: 0.5,
                                        )
                                      ],
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            width: _size.width - 32,
                                            child: Text(
                                              (_fleaModelController.soldOut == true)
                                                  ? '거래완료'
                                                  : '${_fleaModelController.title}',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 8,
                                      ),
                                      Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              color: Color(0xFFD7F4FF),
                                            ),
                                            padding: EdgeInsets.only(
                                                right: 6, left: 6, top: 2, bottom: 3),
                                            child: Text(
                                              '${_fleaModelController.category}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Color(0xFF458BF5)),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(3),
                                              color: Color(0xFFD5F7E0),
                                            ),
                                            padding: EdgeInsets.only(
                                                right: 6, left: 6, top: 2, bottom: 3),
                                            child: Text(
                                              '${_fleaModelController.location}',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                  color: Color(0xFF17AD4A)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 24),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '물품명',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xFFB7B7B7)),
                                          ),
                                          Text(
                                            '${_fleaModelController.itemName}',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.normal),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '금액',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.normal,
                                                    color: Color(0xFFB7B7B7)),
                                              ),
                                              Container(
                                                width: _size.width / 2 - 32,
                                                child: Text(
                                                  '${f.format(_fleaModelController.price)} 원',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '거래방식',
                                                style: TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.normal,
                                                    color: Color(0xFFB7B7B7)),
                                              ),
                                              Container(
                                                width: _size.width / 2 - 32,
                                                child: Text(
                                                  '${_fleaModelController.method}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.normal),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Divider(
                                        height: 50,
                                        thickness: 0.5,
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '상세설명',
                                            style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.normal,
                                                color: Color(0xFFB7B7B7)),
                                          ),
                                          (_fleaModelController.soldOut == false)
                                          ? Container(
                                            width: _size.width,
                                            child: SelectableText(
                                              '${_fleaModelController.description}',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                          )
                                          : Container(
                                            width: _size.width,
                                            child: SelectableText(
                                              '거래가 완료된 물품입니다.',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.normal),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ]),
                              ),
                              SizedBox(
                                height: 40,
                              ),
                            ],
                          ),
                          Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child:
                              (_fleaModelController.uid == _userModelController.uid)
                                  ?Row(
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
                                          onPressed: () async {
                                            CustomFullScreenDialog.showDialog();
                                            await _userModelController.getCurrentUser(_userModelController.uid);
                                            if (_userModelController.phoneAuth == true) {
                                              CustomFullScreenDialog.cancelDialog();
                                              return Get.to(() => FleaMarket_ModifyPage());
                                            } else if (_userModelController.phoneAuth == false) {
                                              CustomFullScreenDialog.cancelDialog();
                                              Get.to(() => PhoneAuthScreen());
                                            } else {}
                                          },
                                          style: TextButton.styleFrom(
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.all(Radius.circular(6))),
                                              elevation: 0,
                                              splashFactory: InkRipple.splashFactory,
                                              minimumSize: Size(1000, 56),
                                              backgroundColor: Color(0xff3D83ED)),
                                          child: Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              '수정하기',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                    ),
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
                                          onPressed: () async {
                                            CustomFullScreenDialog.showDialog();
                                            await _fleaModelController.updateState(isSoldOut);
                                            await _fleaModelController.getCurrentFleaItem(uid: _fleaModelController.uid, fleaCount: _fleaModelController.fleaCount);
                                            setState(() {});
                                            CustomFullScreenDialog.cancelDialog();
                                          },
                                          style: TextButton.styleFrom(
                                              shape: const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(6))),
                                              elevation: 0,
                                              splashFactory: InkRipple.splashFactory,
                                              minimumSize: Size(1000, 56),
                                              backgroundColor: Color(0xff377EEA)),
                                          child: (_fleaModelController.soldOut == true)
                                              ? Padding(
                                            padding:
                                            const EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              '거래가능으로 변경',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )
                                              : Padding(
                                            padding:
                                            const EdgeInsets.only(bottom: 4),
                                            child: Text(
                                              '거래완료로 변경',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                    ),
                                  )
                                ],
                              )
                                  :SizedBox.shrink()
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            else if (snapshot.connectionState == ConnectionState.waiting) {}
            return Center(
              child: CircularProgressIndicator(),
            );
          });
  }
}
