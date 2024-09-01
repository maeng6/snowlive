import 'package:carousel_slider/carousel_slider.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketList.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarketImageScreen.dart';
import '../routes/routes.dart';
import '../util/util_1.dart';
import '../viewmodel/vm_friendDetail.dart';
import '../viewmodel/vm_user.dart';

class FleaMarketDetailView extends StatefulWidget {
  FleaMarketDetailView({Key? key}) : super(key: key);


  @override
  State<FleaMarketDetailView> createState() => _FleaMarketDetailViewState();
}

class _FleaMarketDetailViewState extends State<FleaMarketDetailView> {

  var f = NumberFormat('###,###,###,###');

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();
  final FleamarketListViewModel _fleamarketViewModel = Get.find<FleamarketListViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Obx(()=>Container(
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
                (_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)
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
                                //TODO: 신고하기
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
                                                    await _fleamarketDetailViewModel.reportFleamarket(
                                                        {
                                                          "user_id": _userViewModel.user.user_id,
                                                          "flea_id": _fleamarketDetailViewModel.fleamarketDetail.fleaId
                                                        }
                                                    );
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
                                //TODO: 숨기기
                                GestureDetector(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Text(
                                        '이 회원의 모든 글 숨기기',
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
                                                '이 회원의 모든 글을 숨기시겠습니까?',
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
                                                  onPressed: () async{
                                                    await _userViewModel.block_user({
                                                      "user_id": _userViewModel.user.user_id,
                                                      "block_user_id": _fleamarketDetailViewModel.fleamarketDetail.userId
                                                    });
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
                                //TODO: 수정하기
                                GestureDetector(
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Text(
                                        '수정',
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
                                      // Get.toNamed(page);
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(10)),
                                  ),
                                ),
                                //TODO: 삭제하기
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
                                                            onPressed: () async {
                                                              Navigator.pop(context);
                                                              await _fleamarketDetailViewModel.deleteFleamarket(
                                                                  fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                  userId: _userViewModel.user.user_id
                                                              );
                                                              await _fleamarketViewModel.fetchFleamarketData_total(userId: _userViewModel.user.user_id);
                                                              Get.back();
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
                    if (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                      Stack(
                        children: [
                          CarouselSlider.builder(
                            options: CarouselOptions(
                              height: 280,
                              viewportFraction: 1,
                              enableInfiniteScroll: false,
                              onPageChanged: (index, reason) {
                                _fleamarketDetailViewModel.updateCurrentIndex(index);
                              },
                            ),
                            itemCount: _fleamarketDetailViewModel.fleamarketDetail.photos!.length,
                            itemBuilder: (context, index, pageViewIndex) {
                              return Container(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => FleaMarketImageScreen());
                                      },
                                      child: ExtendedImage.network(
                                        _fleamarketDetailViewModel.fleamarketDetail.photos![index].urlFleaPhoto!,
                                        fit: BoxFit.cover,
                                        width: _size.width,
                                        height: 280,
                                        cacheHeight: 1080,
                                      ),
                                    ),
                                  ],
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
                                  _fleamarketDetailViewModel.fleamarketDetail.photos!.length,
                                      (index) {
                                    return Container(
                                      width: 8,
                                      height: 8,
                                      margin: EdgeInsets.symmetric(horizontal: 4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _fleamarketDetailViewModel.currentIndex == index ? Color(0xFFFFFFFF) : Color(0xFF111111).withOpacity(0.5),
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
                                  //TODO: 인적사항
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      //TODO: 프사
                                      if (_fleamarketDetailViewModel.fleamarketDetail.userInfo!.profileImageUrlUser!.isEmpty)
                                        GestureDetector(
                                          onTap: () async{
                                            await _friendDetailViewModel.fetchFriendDetailInfo(
                                                userId: _userViewModel.user.user_id,
                                                friendUserId:_fleamarketDetailViewModel.fleamarketDetail.userInfo!.userId!,
                                                season: _friendDetailViewModel.seasonDate);
                                            Get.toNamed(AppRoutes.friendDetail);
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
                                      if (_fleamarketDetailViewModel.fleamarketDetail.userInfo!.profileImageUrlUser!.isNotEmpty)
                                        GestureDetector(
                                          onTap: () async{
                                            await _friendDetailViewModel.fetchFriendDetailInfo(
                                                userId: _userViewModel.user.user_id,
                                                friendUserId:_fleamarketDetailViewModel.fleamarketDetail.userInfo!.userId!,
                                                season: _friendDetailViewModel.seasonDate);
                                            Get.toNamed(AppRoutes.friendDetail);
                                          },
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                                color: Color(0xFFDFECFF),
                                                borderRadius: BorderRadius.circular(50)
                                            ),
                                            child: ExtendedImage.network(
                                              '${_fleamarketDetailViewModel.fleamarketDetail.userInfo!.profileImageUrlUser!}',
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
                                      //TODO: 닉네임, 업로드시간
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
                                                      '${_fleamarketDetailViewModel.fleamarketDetail.userInfo!.displayName}',
                                                      //chatDocs[index].get('displayName'),
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 14,
                                                          color: Color(0xFF111111)),
                                                    ),
                                                    SizedBox(width: 6),
                                                    Text(
                                                      '${_fleamarketDetailViewModel.time}',
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
                                  //TODO: SNS연결 버튼
                                  if(_fleamarketDetailViewModel.fleamarketDetail.snsUrl != null && _fleamarketDetailViewModel.fleamarketDetail.snsUrl != '' && (_fleamarketDetailViewModel.fleamarketDetail.status != FleamarketStatus.soldOut.korean))
                                    GestureDetector(
                                      onTap: (){
                                        otherShare(contents: '${_fleamarketDetailViewModel.fleamarketDetail.snsUrl}');
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
                                    '${_fleamarketDetailViewModel.fleamarketDetail.title}',
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
                                    '${_fleamarketDetailViewModel.fleamarketDetail.categorySub}',
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
                                    '${_fleamarketDetailViewModel.fleamarketDetail.spot}',
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
                                  '${_fleamarketDetailViewModel.fleamarketDetail.productName}',
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
                                        '${f.format(_fleamarketDetailViewModel.fleamarketDetail.price)} 원',
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
                                        '${_fleamarketDetailViewModel.fleamarketDetail.method}',
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
                                (_fleamarketDetailViewModel.fleamarketDetail.status != FleamarketStatus.soldOut.korean)
                                    ? Container(
                                  width: _size.width,
                                  child: SelectableText(
                                    '${_fleamarketDetailViewModel.fleamarketDetail.description}',
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
                    (_fleamarketDetailViewModel.fleamarketDetail.userId == _userViewModel.user.user_id)
                        ?Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                  showModalBottomSheet(
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
                                                //TODO: 거래완료
                                                GestureDetector(
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '거래완료',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    //selected: _isSelected[index]!,
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      await _fleamarketDetailViewModel.updateStatus(
                                                        fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                        body:
                                                        {
                                                          "user_id": _userViewModel.user.user_id,
                                                          "product_name": _fleamarketDetailViewModel.fleamarketDetail.productName,
                                                          "category_main": _fleamarketDetailViewModel.fleamarketDetail.categoryMain,
                                                          "category_sub": _fleamarketDetailViewModel.fleamarketDetail.categorySub,
                                                          "price": _fleamarketDetailViewModel.fleamarketDetail.price,
                                                          "negotiable": _fleamarketDetailViewModel.fleamarketDetail.negotiable,
                                                          "method": _fleamarketDetailViewModel.fleamarketDetail.method,
                                                          "spot": _fleamarketDetailViewModel.fleamarketDetail.spot,
                                                          "status": "거래완료",
                                                          "sns_url": _fleamarketDetailViewModel.fleamarketDetail.snsUrl,
                                                          "title": _fleamarketDetailViewModel.fleamarketDetail.title,
                                                          "description": _fleamarketDetailViewModel.fleamarketDetail.description}
                                                      );
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(10)),
                                                  ),
                                                ),
                                                //TODO: 예약중
                                                GestureDetector(
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '예약중',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    //selected: _isSelected[index]!,
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      await _fleamarketDetailViewModel.updateStatus(
                                                        fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                        body:
                                                        {
                                                          "user_id": _userViewModel.user.user_id,
                                                          "product_name": _fleamarketDetailViewModel.fleamarketDetail.productName,
                                                          "category_main": _fleamarketDetailViewModel.fleamarketDetail.categoryMain,
                                                          "category_sub": _fleamarketDetailViewModel.fleamarketDetail.categorySub,
                                                          "price": _fleamarketDetailViewModel.fleamarketDetail.price,
                                                          "negotiable": _fleamarketDetailViewModel.fleamarketDetail.negotiable,
                                                          "method": _fleamarketDetailViewModel.fleamarketDetail.method,
                                                          "spot": _fleamarketDetailViewModel.fleamarketDetail.spot,
                                                          "status": "예약중",
                                                          "sns_url": _fleamarketDetailViewModel.fleamarketDetail.snsUrl,
                                                          "title": _fleamarketDetailViewModel.fleamarketDetail.title,
                                                          "description": _fleamarketDetailViewModel.fleamarketDetail.description}
                                                      );
                                                    },
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(10)),
                                                  ),
                                                ),
                                                //TODO: 거래가능
                                                GestureDetector(
                                                  child: ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '거래가능',
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    //selected: _isSelected[index]!,
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      await _fleamarketDetailViewModel.updateStatus(
                                                        fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                        body:
                                                        {
                                                          "user_id": _userViewModel.user.user_id,
                                                          "product_name": _fleamarketDetailViewModel.fleamarketDetail.productName,
                                                          "category_main": _fleamarketDetailViewModel.fleamarketDetail.categoryMain,
                                                          "category_sub": _fleamarketDetailViewModel.fleamarketDetail.categorySub,
                                                          "price": _fleamarketDetailViewModel.fleamarketDetail.price,
                                                          "negotiable": _fleamarketDetailViewModel.fleamarketDetail.negotiable,
                                                          "method": _fleamarketDetailViewModel.fleamarketDetail.method,
                                                          "spot": _fleamarketDetailViewModel.fleamarketDetail.spot,
                                                          "status": "거래가능",
                                                          "sns_url": _fleamarketDetailViewModel.fleamarketDetail.snsUrl,
                                                          "title": _fleamarketDetailViewModel.fleamarketDetail.title,
                                                          "description": _fleamarketDetailViewModel.fleamarketDetail.description}
                                                      );
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
                                      });
                                },
                                style: TextButton.styleFrom(
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6))),
                                    elevation: 0,
                                    splashFactory: InkRipple.splashFactory,
                                    minimumSize: Size(1000, 56),
                                    backgroundColor: Color(0xff377EEA)),
                                child: Padding(
                                  padding:
                                  const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '거래상태 설정하기',
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
    ));
  }
}
