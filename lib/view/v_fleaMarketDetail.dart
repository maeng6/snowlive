import 'package:carousel_slider/carousel_slider.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketList.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarketImageScreen.dart';
import 'package:shimmer/shimmer.dart';
import '../data/imgaUrls/Data_url_image.dart';
import '../routes/routes.dart';
import '../util/util_1.dart';
import '../viewmodel/vm_friendDetail.dart';
import '../viewmodel/vm_user.dart';

class FleaMarketDetailView extends StatefulWidget {

  @override
  State<FleaMarketDetailView> createState() => _FleaMarketDetailViewState();
}

class _FleaMarketDetailViewState extends State<FleaMarketDetailView> {
  final f = NumberFormat('###,###,###,###');

  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  final FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();

  final FleamarketCommentDetailViewModel _fleamarketCommentDetailViewModel = Get.find<FleamarketCommentDetailViewModel>();

  final FleamarketListViewModel _fleamarketListViewModel = Get.find<FleamarketListViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

    return Obx(()=>Container(
      color: Colors.white,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(88),
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
                if((_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id )
                    && _fleamarketDetailViewModel.fleamarketDetail.isFavorite == false)
                  GestureDetector(
                  onTap: () async{
                    await _fleamarketDetailViewModel.addFavoriteFleamarket(
                        fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                        body: {
                          "user_id": _userViewModel.user.user_id
                        }
                    );
                  },
                  child: Icon(Icons.bookmark_border,
                  size: 22,
                  ),
                ),
                if((_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id )
                    && _fleamarketDetailViewModel.fleamarketDetail.isFavorite == true)
                 GestureDetector(
                  onTap: () async{
                    await _fleamarketDetailViewModel.deleteFavoriteFleamarket(
                        fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                        body: {
                          "user_id": _userViewModel.user.user_id
                        }
                    );
                  },
                  child: Icon(Icons.bookmark,
                    size: 22,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(Icons.ios_share,
                  size: 22,
                  ),
                ),
                (_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)
                    ? Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: GestureDetector(
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
                        Icons.more_vert,
                        size: 22,
                        color: Color(0xFF111111),
                      ),
                                        ),
                                      ),
                    )
                    : Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: GestureDetector(
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
                                                                await _fleamarketListViewModel.fetchFleamarketData_total(userId: _userViewModel.user.user_id);
                                                                await _fleamarketListViewModel.fetchFleamarketData_ski(userId: _userViewModel.user.user_id);
                                                                await _fleamarketListViewModel.fetchFleamarketData_board(userId: _userViewModel.user.user_id);
                                                                await _fleamarketListViewModel.fetchFleamarketData_my(userId: _userViewModel.user.user_id);
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
                        Icons.more_vert,
                        size: 22,
                        color: Color(0xFF111111),
                      ),
                                        ),
                                      ),
                    )
              ],
              backgroundColor: Colors.transparent,
              elevation: 0.0,
            ),
          ),
          body: Obx((){
              return Stack(
                children: [
                  SingleChildScrollView(
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
                            if (_fleamarketDetailViewModel.fleamarketDetail.photos!.isEmpty)
                              SizedBox(height: 100,),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                  child: Column(
                                    children: [
                                      //TODO: 프사, 닉네임
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
                                              //TODO: 닉네임
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 2),
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${_fleamarketDetailViewModel.fleamarketDetail.userInfo!.displayName}',
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 14,
                                                              color: Color(0xFF111111)),
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
                                      mainAxisAlignment: MainAxisAlignment.start, // 좌측 정렬
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color:
                                            (_fleamarketDetailViewModel.fleamarketDetail.status == '거래완료')
                                                ? Color(0xFF949494)
                                                : SDSColor.snowliveBlue,
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                          child: Text(
                                            _fleamarketDetailViewModel.fleamarketDetail.status!,
                                            style: TextStyle(
                                              color: SDSColor.snowliveWhite,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //TODO: 타이틀
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
                                    //TODO: 장소, 서브카테고리, 시간
                                    Row(
                                      children: [
                                        Text(
                                          '${_fleamarketDetailViewModel.fleamarketDetail.spot} · ',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: SDSColor.snowliveBlack,
                                              fontWeight:
                                              FontWeight.w300),
                                        ),
                                        Text(
                                          '${_fleamarketDetailViewModel.fleamarketDetail.categorySub}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: SDSColor.snowliveBlack,
                                              fontWeight:
                                              FontWeight.w300),
                                        ),
                                        Expanded(child: SizedBox()),
                                        Text(
                                          '${_fleamarketDetailViewModel.time}',
                                          style: TextStyle(
                                              fontSize: 14,
                                              color: SDSColor.snowliveBlack,
                                              fontWeight:
                                              FontWeight.w300),
                                        ),
                                      ],),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    //TODO: 금액
                                    Container(
                                      width: _size.width / 2 - 32,
                                      child: Text(
                                        '${f.format(_fleamarketDetailViewModel.fleamarketDetail.price)} 원',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    //TODO: 설명
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
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
                                    Divider(
                                      height: 50,
                                      thickness: 0.5,
                                    ),
                                    //TODO: 물품명, 거래방식
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
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
                                    SizedBox(
                                      height: 16,
                                    ),
                                    if(_fleamarketDetailViewModel.fleamarketDetail.userId == _userViewModel.user.user_id)
                                      GestureDetector(
                                        onTap: () async {
                                          showModalBottomSheet(
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return Container(
                                                height: 230,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                  child: Column(
                                                    children: [
                                                      GestureDetector(
                                                        child: ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketStatus.soldOut.korean}',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            await _fleamarketDetailViewModel.updateStatus(
                                                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                              body: {
                                                                "user_id": _userViewModel.user.user_id,
                                                                "status": '${FleamarketStatus.soldOut.korean}',
                                                              },
                                                            );
                                                            await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(
                                                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                              userId: _userViewModel.user.user_id,
                                                            );
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        child: ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketStatus.onBooking.korean}',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            await _fleamarketDetailViewModel.updateStatus(
                                                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                              body: {
                                                                "user_id": _userViewModel.user.user_id,
                                                                "status": '${FleamarketStatus.onBooking.korean}',
                                                              },
                                                            );
                                                            await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(
                                                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                              userId: _userViewModel.user.user_id,
                                                            );
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                      GestureDetector(
                                                        child: ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketStatus.forSale.korean}',
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                          ),
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            await _fleamarketDetailViewModel.updateStatus(
                                                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                              body: {
                                                                "user_id": _userViewModel.user.user_id,
                                                                "status": '${FleamarketStatus.forSale.korean}',
                                                              },
                                                            );
                                                            await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(
                                                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                              userId: _userViewModel.user.user_id,
                                                            );
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(4),
                                            color: SDSColor.snowliveWhite,
                                            border: Border.all(
                                              color: Color(0xFF949494),
                                              width: 1.0,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                          child: Center( // 텍스트 중앙 정렬
                                            child: Text(
                                              '거래 상태 설정하기기',
                                              style: TextStyle(
                                                color: Color(0xFF444444), // 텍스트 색상 회색
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                  ]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 15),
                              child: Container(
                                width: double.infinity,
                                height: 10.0,
                                color: Color(0xFFF5F5F5),
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                          child: Row(
                            children: [
                            Text('댓글',
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                            )
                          ],),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child:
                                (_fleamarketDetailViewModel.isLoading_indicator==true)
                                    ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,  // Column을 가운데로 정렬
                                      children: [
                                        CircularProgressIndicator(
                                          strokeWidth: 4.0, // 인디케이터의 두께를 조절
                                        ),
                                        SizedBox(
                                          height: 20, // 인디케이터와 텍스트 사이의 간격
                                        ),
                                        Text(
                                          '로딩 중...', // 텍스트 내용 변경
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                    :  Column(
                                  children: [
                                    (_fleamarketDetailViewModel.commentsList.length >0)
                                        ? Column(
                                      children: [
                                        ListView.builder(
                                          padding: EdgeInsets.only(top: 4),
                                          shrinkWrap: true,
                                          controller: _fleamarketDetailViewModel.scrollController,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: _fleamarketDetailViewModel.commentsList.length,
                                          itemBuilder: (context, index) {
                                            final document = _fleamarketDetailViewModel.commentsList[index];
                                            String timestamp = _fleamarketDetailViewModel.commentsList[index].uploadTime!;
                                            String time = GetDatetime().getAgoString(timestamp); // 원하는 형식으로 날짜 변환
                                            return Column(
                                              children: [
                                                if(document.secret! &&
                                                    (document.userId != _userViewModel.user.user_id
                                                        && _fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id))
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 10),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Container(
                                                          width: _size.width - 112,
                                                          child: Text('비밀글입니다.',
                                                            style: TextStyle(
                                                                fontSize: 14,
                                                                color: Color(0xFF111111)
                                                            ),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if(!document.secret! ||
                                                    (document.secret! && (document.userId == _userViewModel.user.user_id
                                                    || _fleamarketDetailViewModel.fleamarketDetail.userId == _userViewModel.user.user_id)))
                                                  Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          if (document.userInfo!.profileImageUrlUser != "")
                                                            GestureDetector(
                                                              onTap: () async {
                                                                await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                    userId: _userViewModel.user.user_id,
                                                                    friendUserId: document.userInfo!.userId!,
                                                                    season: _friendDetailViewModel.seasonDate);
                                                                Get.toNamed(AppRoutes.friendDetail);
                                                              },
                                                              child: Container(
                                                                width: 40,
                                                                height: 40,
                                                                decoration: BoxDecoration(
                                                                  color: Color(0xFFDFECFF),
                                                                  borderRadius: BorderRadius.circular(50),
                                                                ),
                                                                child: ExtendedImage.network(
                                                                  document.userInfo!.profileImageUrlUser!,
                                                                  cache: true,
                                                                  shape: BoxShape.circle,
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  width: 40,
                                                                  height: 40,
                                                                  fit: BoxFit.cover,
                                                                ),
                                                              ),
                                                            ),
                                                          if (document.userInfo!.profileImageUrlUser == "")
                                                            GestureDetector(
                                                              onTap: () async {
                                                                await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                    userId: _userViewModel.user.user_id,
                                                                    friendUserId: document.userInfo!.userId!,
                                                                    season: _friendDetailViewModel.seasonDate);
                                                                Get.toNamed(AppRoutes.friendDetail);
                                                              },
                                                              child: ExtendedImage.network(
                                                                '${profileImgUrlList[0].default_round}',
                                                                shape: BoxShape.circle,
                                                                borderRadius: BorderRadius.circular(20),
                                                                width: 40,
                                                                height: 40,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            ),
                                                          SizedBox(width: 12),
                                                          Expanded(
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Text(
                                                                      document.userInfo!.displayName!,
                                                                      style: TextStyle(
                                                                        fontSize: 13,
                                                                        color: SDSColor.snowliveBlack,
                                                                        fontWeight: FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 6),
                                                                    Text(
                                                                      time,
                                                                      style: TextStyle(
                                                                        fontSize: 13,
                                                                        color: Color(0xFF949494),
                                                                      ),
                                                                    ),
                                                                    if (document.secret!)
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 7),
                                                                        child: Icon(Icons.lock,
                                                                        size: 15,
                                                                        color: Color(0xFF949494),
                                                                        ),
                                                                      ),
                                                                    Spacer(), // Adds space between the text and the icons
                                                                    GestureDetector(
                                                                      onTap: () => showModalBottomSheet(
                                                                        enableDrag: false,
                                                                        context: context,
                                                                        builder: (context) {
                                                                          return SafeArea(
                                                                            child: Container(
                                                                              height: (_friendDetailViewModel.friendDetailModel.friendUserInfo.userId ==
                                                                                  _userViewModel.user.user_id ||
                                                                                  document.userInfo!.userId == _userViewModel.user.user_id)
                                                                                  ? 200
                                                                                  : 150,
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.symmetric(
                                                                                    horizontal: 20.0, vertical: 14),
                                                                                child: Column(
                                                                                  children: [
                                                                                    if (_friendDetailViewModel.friendDetailModel
                                                                                        .friendUserInfo.userId ==
                                                                                        _userViewModel.user.user_id ||
                                                                                        document.userInfo!.userId ==
                                                                                            _userViewModel.user.user_id)
                                                                                      GestureDetector(
                                                                                        child: ListTile(
                                                                                          contentPadding: EdgeInsets.zero,
                                                                                          title: Center(
                                                                                            child: Text(
                                                                                              '삭제',
                                                                                              style: TextStyle(
                                                                                                fontSize: 15,
                                                                                                fontWeight: FontWeight.bold,
                                                                                                color: Color(0xFFD63636),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          onTap: () async {
                                                                                            Navigator.pop(context);
                                                                                            showModalBottomSheet(
                                                                                                context: context,
                                                                                                builder: (context) {
                                                                                                  return Container(
                                                                                                    color: Colors.white,
                                                                                                    height: 180,
                                                                                                    child: Padding(
                                                                                                      padding:
                                                                                                      const EdgeInsets.symmetric(
                                                                                                          horizontal: 20.0),
                                                                                                      child: Column(
                                                                                                        crossAxisAlignment:
                                                                                                        CrossAxisAlignment.start,
                                                                                                        mainAxisAlignment:
                                                                                                        MainAxisAlignment.start,
                                                                                                        children: [
                                                                                                          SizedBox(height: 30),
                                                                                                          Text(
                                                                                                            '삭제하시겠습니까?',
                                                                                                            style: TextStyle(
                                                                                                                fontSize: 20,
                                                                                                                fontWeight:
                                                                                                                FontWeight.bold,
                                                                                                                color:
                                                                                                                Color(0xFF111111)),
                                                                                                          ),
                                                                                                          SizedBox(height: 30),
                                                                                                          Row(
                                                                                                            mainAxisAlignment:
                                                                                                            MainAxisAlignment
                                                                                                                .spaceEvenly,
                                                                                                            children: [
                                                                                                              Expanded(
                                                                                                                child:
                                                                                                                ElevatedButton(
                                                                                                                  onPressed: () {
                                                                                                                    Navigator.pop(
                                                                                                                        context);
                                                                                                                  },
                                                                                                                  child: Text(
                                                                                                                    '취소',
                                                                                                                    style: TextStyle(
                                                                                                                        color: Colors
                                                                                                                            .white,
                                                                                                                        fontSize: 15,
                                                                                                                        fontWeight:
                                                                                                                        FontWeight
                                                                                                                            .bold),
                                                                                                                  ),
                                                                                                                  style: TextButton.styleFrom(
                                                                                                                      splashFactory:
                                                                                                                      InkRipple
                                                                                                                          .splashFactory,
                                                                                                                      elevation: 0,
                                                                                                                      minimumSize:
                                                                                                                      Size(100,
                                                                                                                          56),
                                                                                                                      backgroundColor:
                                                                                                                      Color(
                                                                                                                          0xff555555),
                                                                                                                      padding: EdgeInsets
                                                                                                                          .symmetric(
                                                                                                                          horizontal:
                                                                                                                          0)),
                                                                                                                ),
                                                                                                              ),
                                                                                                              SizedBox(width: 10),
                                                                                                              Expanded(
                                                                                                                child:
                                                                                                                ElevatedButton(
                                                                                                                  onPressed:
                                                                                                                      () async {
                                                                                                                    await _friendDetailViewModel
                                                                                                                        .deleteFriendsTalk(
                                                                                                                        userId: _userViewModel
                                                                                                                            .user
                                                                                                                            .user_id,
                                                                                                                        friendsTalkId:
                                                                                                                        document
                                                                                                                            .commentId!);
                                                                                                                    Navigator.pop(
                                                                                                                        context);
                                                                                                                  },
                                                                                                                  child: Text(
                                                                                                                    '확인',
                                                                                                                    style: TextStyle(
                                                                                                                        color: Colors
                                                                                                                            .white,
                                                                                                                        fontSize: 15,
                                                                                                                        fontWeight:
                                                                                                                        FontWeight
                                                                                                                            .bold),
                                                                                                                  ),
                                                                                                                  style: TextButton.styleFrom(
                                                                                                                      splashFactory:
                                                                                                                      InkRipple
                                                                                                                          .splashFactory,
                                                                                                                      elevation: 0,
                                                                                                                      minimumSize:
                                                                                                                      Size(100,
                                                                                                                          56),
                                                                                                                      backgroundColor:
                                                                                                                      Color(
                                                                                                                          0xff2C97FB),
                                                                                                                      padding: EdgeInsets
                                                                                                                          .symmetric(
                                                                                                                          horizontal:
                                                                                                                          0)),
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
                                                                                        ),
                                                                                      ),
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
                                                                                        onTap: () async {
                                                                                          // 신고 기능 처리
                                                                                        },
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          );
                                                                        },
                                                                      ),
                                                                      child: Icon(
                                                                        Icons.more_horiz,
                                                                        color: Color(0xFFdedede),
                                                                        size: 20,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () async{
                                                                    if(document.secret! &&
                                                                        (document.userId != _userViewModel.user.user_id
                                                                            && _fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)){

                                                                    }else {
                                                                      await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetail(commentId: document.commentId!);
                                                                      Get.toNamed(AppRoutes.fleamarketCommentDetail);
                                                                    }
                                                                  },
                                                                  child: Padding(
                                                                    padding: const EdgeInsets.only(top: 10),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          width: _size.width - 112,
                                                                          child: Text(
                                                                            document.content!,
                                                                            style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: SDSColor.snowliveBlack,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 10),
                                                                        Text(
                                                                          (document.replies!.length == 0)
                                                                              ? '답글 달기'
                                                                              : '답글 ${document.replies!.length}개 보기',
                                                                          style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: SDSColor.snowliveBlack,
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 25),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                        SizedBox(
                                          height: 90,
                                        )
                                      ],
                                    )
                                        : Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(20),
                                        child: Column(
                                          children: [
                                            SizedBox(
                                              height: _size.height / 18,
                                            ),
                                            Image.asset(
                                              'assets/imgs/icons/icon_nodata.png',
                                              scale: 4,
                                              width: 64,
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text('댓글이 없습니다', style: TextStyle(
                                                fontSize: 13, color: Color(
                                                0xFF666666)),),
                                            SizedBox(
                                              height: 30,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ],),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            if(_fleamarketDetailViewModel.fleamarketDetail.snsUrl != null && _fleamarketDetailViewModel.fleamarketDetail.snsUrl != '' && (_fleamarketDetailViewModel.fleamarketDetail.status != FleamarketStatus.soldOut.korean))
                              GestureDetector(
                                onTap: () {
                                  otherShare(contents: '${_fleamarketDetailViewModel.fleamarketDetail.snsUrl}');
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFFEE500),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: ExtendedImage.asset(
                                    'assets/imgs/logos/kakao_logo.png',
                                    enableMemoryCache: true,
                                    shape: BoxShape.rectangle,
                                    width: 18,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            SizedBox(width: 5),
                            GestureDetector(
                              onTap: (){
                                _fleamarketDetailViewModel.changeSecret();
                              },
                              child:Container(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                  (_fleamarketDetailViewModel.isSecret == true)
                                      ? Color(0xFFCBE0FF)
                                      : Color(0xFFECECEC),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  children: [
                                    (_fleamarketDetailViewModel.isSecret == true)
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
                                    Text('비밀',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color:
                                          (_fleamarketDetailViewModel.isSecret == true)
                                              ? Color(0xFF3D83ED)
                                              :Color(0xFF949494)
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                key: _fleamarketDetailViewModel.formKey,
                                cursorColor: Color(0xff377EEA),
                                controller: _fleamarketDetailViewModel.textEditingController,
                                strutStyle: StrutStyle(leading: 0.3),
                                maxLines: 1,
                                enableSuggestions: false,
                                autocorrect: false,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  suffixIcon: IconButton(
                                    splashColor: Colors.transparent,
                                    onPressed: () async {
                                      if (_fleamarketDetailViewModel.textEditingController.text.trim().isEmpty) {
                                        return;
                                      }
                                      await _fleamarketDetailViewModel.uploadFleamarketComments({
                                        "flea_id": _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                                        "content": _fleamarketDetailViewModel.textEditingController.text,
                                        "user_id": _userViewModel.user.user_id,
                                        "secret": "${_fleamarketDetailViewModel.isSecret}"
                                      });
                                      await _fleamarketDetailViewModel.fetchFleamarketComments(
                                          fleaId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                          userId: _fleamarketDetailViewModel.fleamarketDetail.userId!,
                                          isLoading_indi: true
                                      );
                                      FocusScope.of(context).unfocus();
                                      _fleamarketDetailViewModel.textEditingController.clear();
                                    },
                                    icon: (_fleamarketDetailViewModel.isCommentButtonEnabled.value == false)
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
                                  labelStyle: TextStyle(color: Color(0xff949494), fontSize: 15),
                                  hintStyle: TextStyle(color: Color(0xffb7b7b7), fontSize: 15),
                                  errorStyle: TextStyle(
                                    fontSize: 12,
                                  ),
                                  hintText: '댓글을 입력하세요',
                                  contentPadding: EdgeInsets.symmetric(vertical: 2, horizontal: 16),
                                  fillColor: Color(0xFFEFEFEF),
                                  filled: true,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.transparent),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                onChanged: (value) {
                                  _fleamarketDetailViewModel.changeFleamarketCommentsInputText(value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
          })
        ),
      ),
    ));
  }
}
