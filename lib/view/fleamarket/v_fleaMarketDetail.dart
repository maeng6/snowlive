import 'package:carousel_slider/carousel_slider.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/vm_fleamarketUpdate.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:com.snowlive/screens/fleaMarket/v_fleaMarketImageScreen.dart';
import 'package:shimmer/shimmer.dart';
import '../../data/imgaUrls/Data_url_image.dart';
import '../../routes/routes.dart';
import '../../util/util_1.dart';
import '../../viewmodel/vm_friendDetail.dart';
import '../../viewmodel/vm_user.dart';

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
  final FleamarketUpdateViewModel _fleamarketUpdateViewModel = Get.find<FleamarketUpdateViewModel>();
  final ScrollController _scrollController = ScrollController();
  bool isAppBarCollapsed = false;


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300 && !isAppBarCollapsed) {
        setState(() {
          isAppBarCollapsed = true;
        });
      } else if (_scrollController.offset <= 300 && isAppBarCollapsed) {
        setState(() {
          isAppBarCollapsed = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }


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
            preferredSize: Size.fromHeight(44),
            child:
            (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                ? AppBar(
              backgroundColor: isAppBarCollapsed ? SDSColor.snowliveWhite : Colors.transparent,
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors:
                    isAppBarCollapsed ?
                    [Colors.transparent, Colors.transparent,]
                    : [Colors.black.withOpacity(0.4), Colors.transparent,],
                  ),
                ),
              ),
              elevation: 0.0,
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                  color: isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              actions: [
                if((_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id )
                    && _fleamarketDetailViewModel.fleamarketDetail.isFavorite == false)
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: GestureDetector(
                    onTap: () async{
                      await _fleamarketDetailViewModel.addFavoriteFleamarket(
                          fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                          body: {
                            "user_id": _userViewModel.user.user_id
                          }
                      );
                    },
                    child:Image.asset(
                      'assets/imgs/icons/icon_flea_appbar_scrap.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                      color: isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite,
                    ),
                                    ),
                  ),
                if((_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id )
                    && _fleamarketDetailViewModel.fleamarketDetail.isFavorite == true)
                 Padding(
                   padding: EdgeInsets.only(right: 20),
                   child: GestureDetector(
                    onTap: () async{
                      await _fleamarketDetailViewModel.deleteFavoriteFleamarket(
                          fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                          body: {
                            "user_id": _userViewModel.user.user_id
                          }
                      );
                    },
                    child: Image.asset(
                      'assets/imgs/icons/icon_flea_appbar_scrap_on.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                      color: isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite,
                    ),
                                   ),
                 ),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Image.asset(
                    'assets/imgs/icons/icon_flea_appbar_share.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                    color: isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite,
                  ),
                ),
                (_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)
                    ? Padding(
                  padding: EdgeInsets.only(right: 16),
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
                            }
                            ),
                        child: Image.asset(
                          'assets/imgs/icons/icon_flea_appbar_more.png',
                          scale: 4,
                          width: 26,
                          height: 26,
                          color: isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite,
                        ),
                      ),
                    )
                    : Padding(
                      padding: EdgeInsets.only(right: 16),
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
                                        await _fleamarketUpdateViewModel.fetchFleamarketUpdateData(
                                            textEditingController_title: _fleamarketDetailViewModel.fleamarketDetail.title,
                                            selectedCategorySub: _fleamarketDetailViewModel.fleamarketDetail.categorySub,
                                            selectedCategoryMain: _fleamarketDetailViewModel.fleamarketDetail.categoryMain,
                                            textEditingController_productName: _fleamarketDetailViewModel.fleamarketDetail.productName,
                                            itemPriceTextEditingController: _fleamarketDetailViewModel.fleamarketDetail.price,
                                            selectedTradeMethod: _fleamarketDetailViewModel.fleamarketDetail.method,
                                            selectedTradeSpot: _fleamarketDetailViewModel.fleamarketDetail.spot,
                                            textEditingController_desc: _fleamarketDetailViewModel.fleamarketDetail.description,
                                            photos: _fleamarketDetailViewModel.fleamarketDetail.photos
                                        );
                                        Get.toNamed(AppRoutes.fleamarketUpdate);
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
                          child: Image.asset(
                            'assets/imgs/icons/icon_flea_appbar_more.png',
                            scale: 4,
                            width: 26,
                            height: 26,
                            color: isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite,
                          ),
                        ),
                      ),
                    )
              ],
            )
                : AppBar(
              backgroundColor: SDSColor.snowliveWhite,
              foregroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0.0,
              leading: GestureDetector(
                child: Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                  color: SDSColor.gray900,
                ),
                onTap: () {
                  Get.back();
                },
              ),
              actions: [
                if((_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id )
                    && _fleamarketDetailViewModel.fleamarketDetail.isFavorite == false)
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () async{
                        await _fleamarketDetailViewModel.addFavoriteFleamarket(
                            fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                            body: {
                              "user_id": _userViewModel.user.user_id
                            }
                        );
                      },
                      child:Image.asset(
                        'assets/imgs/icons/icon_flea_appbar_scrap.png',
                        scale: 4,
                        width: 26,
                        height: 26,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                if((_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id )
                    && _fleamarketDetailViewModel.fleamarketDetail.isFavorite == true)
                  Padding(
                    padding: EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () async{
                        await _fleamarketDetailViewModel.deleteFavoriteFleamarket(
                            fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                            body: {
                              "user_id": _userViewModel.user.user_id
                            }
                        );
                      },
                      child: Image.asset(
                        'assets/imgs/icons/icon_flea_appbar_scrap_on.png',
                        scale: 4,
                        width: 26,
                        height: 26,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Image.asset(
                    'assets/imgs/icons/icon_flea_appbar_share.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                    color: SDSColor.gray900,
                  ),
                ),
                (_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)
                    ? Padding(
                  padding: EdgeInsets.only(right: 16),
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
                        }
                    ),
                    child: Image.asset(
                      'assets/imgs/icons/icon_flea_appbar_more.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                      color: SDSColor.gray900,
                    ),
                  ),
                )
                    : Padding(
                  padding: EdgeInsets.only(right: 16),
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
                                        await _fleamarketUpdateViewModel.fetchFleamarketUpdateData(
                                            textEditingController_title: _fleamarketDetailViewModel.fleamarketDetail.title,
                                            selectedCategorySub: _fleamarketDetailViewModel.fleamarketDetail.categorySub,
                                            selectedCategoryMain: _fleamarketDetailViewModel.fleamarketDetail.categoryMain,
                                            textEditingController_productName: _fleamarketDetailViewModel.fleamarketDetail.productName,
                                            itemPriceTextEditingController: _fleamarketDetailViewModel.fleamarketDetail.price,
                                            selectedTradeMethod: _fleamarketDetailViewModel.fleamarketDetail.method,
                                            selectedTradeSpot: _fleamarketDetailViewModel.fleamarketDetail.spot,
                                            textEditingController_desc: _fleamarketDetailViewModel.fleamarketDetail.description,
                                            photos: _fleamarketDetailViewModel.fleamarketDetail.photos
                                        );
                                        Get.toNamed(AppRoutes.fleamarketUpdate);
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
                    child: Image.asset(
                      'assets/imgs/icons/icon_flea_appbar_more.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                      color: SDSColor.gray900,
                    ),
                  ),
                )
              ],
            )
          ),
          body: Obx((){
              return Stack(
                children: [
                  SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        Column(
                          children: [
                            if (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                              Stack(
                                children: [
                                  CarouselSlider.builder(
                                    options: CarouselOptions(
                                      height: _size.width,
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
                                                height: _size.width,
                                                cacheHeight: 1080,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    bottom: 12,
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(
                                        _fleamarketDetailViewModel.fleamarketDetail.photos!.length,
                                            (index) {
                                          return Container(
                                            width: 6,
                                            height: 6,
                                            margin: EdgeInsets.symmetric(horizontal: 4),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _fleamarketDetailViewModel.currentIndex == index ? SDSColor.snowliveBlue : SDSColor.snowliveBlack.withOpacity(0.2),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            if (_fleamarketDetailViewModel.fleamarketDetail.photos!.isEmpty)
                              SizedBox(height: 44),
                            SizedBox(
                              height: 16,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16,),
                              child: Padding(
                                padding: EdgeInsets.only(top: (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty) ? 0 : 10),
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
                                                      borderRadius: BorderRadius.circular(50),
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
                                                        borderRadius: BorderRadius.circular(50),
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
                                                                borderRadius: BorderRadius.circular(50),
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
                                                SizedBox(width: 10),
                                                //TODO: 닉네임
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text(
                                                          '${_fleamarketDetailViewModel.fleamarketDetail.userInfo!.displayName}',
                                                          style: SDSTextStyle.bold.copyWith(
                                                              fontSize: 14,
                                                              color: SDSColor.gray900
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Divider(
                                          height: 32,
                                          thickness: 1,
                                          color: SDSColor.gray100,
                                        )
                                      ],
                                    )),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.start, // 좌측 정렬
                                      children: [
                                        if(_fleamarketDetailViewModel.fleamarketDetail.status == '거래완료')
                                          Padding(
                                          padding: EdgeInsets.only(bottom: 8),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(4),
                                              color: SDSColor.gray900,
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                            child: Text(_fleamarketDetailViewModel.fleamarketDetail.status!,
                                              style: SDSTextStyle.bold.copyWith(
                                                color: SDSColor.snowliveWhite,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ),
                                        if(_fleamarketDetailViewModel.fleamarketDetail.status == '예약중')
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(4),
                                                color: SDSColor.snowliveBlue,
                                              ),
                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                              child: Text(_fleamarketDetailViewModel.fleamarketDetail.status!,
                                                style: SDSTextStyle.bold.copyWith(
                                                  color: SDSColor.snowliveWhite,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ),
                                        if(_fleamarketDetailViewModel.fleamarketDetail.status == '거래가능')
                                          Container(),
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
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: SDSTextStyle.bold.copyWith(
                                                fontSize: 18,
                                                color: SDSColor.gray900
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    //TODO: 장소, 서브카테고리, 시간
                                    Padding(
                                      padding: EdgeInsets.only(top: 4),
                                      child: Row(
                                        children: [
                                          Text(
                                            '${_fleamarketDetailViewModel.fleamarketDetail.spot} · ',
                                            style: SDSTextStyle.regular.copyWith(
                                                fontSize: 14,
                                                color: SDSColor.gray500,
                                            ),
                                          ),
                                          Text(
                                            '${_fleamarketDetailViewModel.fleamarketDetail.categorySub}',
                                            style: SDSTextStyle.regular.copyWith(
                                              fontSize: 14,
                                              color: SDSColor.gray500,
                                            ),
                                          ),
                                          Expanded(child: SizedBox()),
                                          Text(
                                            '${_fleamarketDetailViewModel.time}',
                                            style: SDSTextStyle.regular.copyWith(
                                              fontSize: 14,
                                              color: SDSColor.gray500,
                                            ),
                                          ),
                                        ],),
                                    ),
                                    //TODO: 금액
                                    Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Container(
                                        width: _size.width / 2 - 32,
                                        child: Text(
                                          '${f.format(_fleamarketDetailViewModel.fleamarketDetail.price)}원',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: SDSTextStyle.extraBold.copyWith(
                                              fontSize: 20,
                                              color: SDSColor.gray900),
                                        ),
                                      ),
                                    ),
                                    //TODO: 설명
                                    Padding(
                                      padding: EdgeInsets.only(top: 24),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          (_fleamarketDetailViewModel.fleamarketDetail.status != FleamarketStatus.soldOut.korean)
                                              ? Container(
                                            width: _size.width,
                                            child: SelectableText(
                                              '${_fleamarketDetailViewModel.fleamarketDetail.description}',
                                              style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 15,
                                                  color: SDSColor.gray900),
                                            ),
                                          )
                                              : Container(
                                            width: _size.width,
                                            child: SelectableText(
                                              '거래가 완료된 물품입니다.',
                                              style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 15,
                                                  color: SDSColor.gray900),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Divider(
                                      height: 48,
                                      thickness: 1,
                                      color: SDSColor.gray100,
                                    ),
                                    //TODO: 물품명, 거래방식
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: _size.width / 2 - 31,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('물품명',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray500),
                                              ),
                                              Text('${_fleamarketDetailViewModel.fleamarketDetail.productName}',
                                                maxLines: 2,
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 15,
                                                    color: SDSColor.gray900
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: _size.width / 2 - 31,
                                          child: Column(
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '거래방식',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray500),
                                              ),
                                              Text(
                                                '${_fleamarketDetailViewModel.fleamarketDetail.method}',
                                                maxLines: 2,
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 15,
                                                    color: SDSColor.gray900
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    if(_fleamarketDetailViewModel.fleamarketDetail.userId == _userViewModel.user.user_id)
                                      Padding(
                                        padding: EdgeInsets.only(top: 30),
                                        child: GestureDetector(
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
                                                color: SDSColor.gray200,
                                                width: 1,
                                              ),
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                                            child: Center( // 텍스트 중앙 정렬
                                              child: Text(
                                                '거래 상태 설정하기',
                                                style: SDSTextStyle.bold.copyWith(
                                                  color: SDSColor.gray900,
                                                  fontSize: 15,
                                                ),
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
                                height: 10,
                                color: SDSColor.gray50,
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 10),
                          child: Row(
                            children: [
                            Text('댓글',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray900
                            ),
                            )
                          ],),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
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
                                    : Column(
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
                                                    padding: EdgeInsets.only(bottom: 32),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Container(
                                                          width: 32,
                                                          height: 32,
                                                          decoration: BoxDecoration(
                                                            color: SDSColor.gray100,
                                                            borderRadius: BorderRadius.circular(50),
                                                          ),
                                                          child: Icon(Icons.lock,
                                                            size: 16,
                                                            color: SDSColor.gray400,
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: EdgeInsets.only(left: 12),
                                                          child: Container(
                                                            width: _size.width - 76,
                                                            child: Text('이 글은 비밀글입니다.',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                  fontSize: 14,
                                                                  color: SDSColor.gray500
                                                              ),),
                                                          ),
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
                                                                width: 32,
                                                                height: 32,
                                                                decoration: BoxDecoration(
                                                                  color: Color(0xFFDFECFF),
                                                                  borderRadius: BorderRadius.circular(50),
                                                                ),
                                                                child: ExtendedImage.network(
                                                                  document.userInfo!.profileImageUrlUser!,
                                                                  cache: true,
                                                                  shape: BoxShape.circle,
                                                                  borderRadius: BorderRadius.circular(20),
                                                                  width: 32,
                                                                  height: 32,
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
                                                                width: 32,
                                                                height: 32,
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
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        fontSize: 13,
                                                                        color: SDSColor.gray900,
                                                                      ),
                                                                    ),
                                                                    SizedBox(width: 6),
                                                                    Text(
                                                                      time,
                                                                      style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 13,
                                                                        color: SDSColor.gray500,
                                                                      ),
                                                                    ),
                                                                    if (document.secret!)
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(left: 6),
                                                                        child: Icon(Icons.lock,
                                                                        size: 14,
                                                                        color: SDSColor.gray300,
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
                                                                                                                    await _fleamarketDetailViewModel.deleteFleamarket(
                                                                                                                        fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                                                                        userId: _userViewModel.user.user_id);
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
                                                                    padding: const EdgeInsets.only(top: 6),
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Container(
                                                                          width: _size.width - 72,
                                                                          child: Text(
                                                                            document.content!,
                                                                            style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: SDSColor.gray900,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        SizedBox(height: 8),
                                                                        Text(
                                                                          (document.replies!.length == 0)
                                                                              ? '답글 달기'
                                                                              : '답글 ${document.replies!.length}개 보기',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 13,
                                                                            color: SDSColor.gray900,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(height: 30),
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
                                          height: 80,
                                        )
                                      ],
                                    )
                                        : Center(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Column(
                                          children: [
                                            Image.asset(
                                              'assets/imgs/icons/icon_nodata.png',
                                              scale: 4,
                                              width: 64,
                                            ),
                                            SizedBox(
                                              height: 6,
                                            ),
                                            Text('댓글이 없어요',
                                              style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 13,
                                                  color: SDSColor.gray500
                                              ),
                                            ),
                                            SizedBox(
                                              height: 140,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 72,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            if(_fleamarketDetailViewModel.fleamarketDetail.snsUrl != null && _fleamarketDetailViewModel.fleamarketDetail.snsUrl != '' && (_fleamarketDetailViewModel.fleamarketDetail.status != FleamarketStatus.soldOut.korean))
                              GestureDetector(
                                onTap: () {
                                  otherShare(contents: '${_fleamarketDetailViewModel.fleamarketDetail.snsUrl}');
                                },
                                child: Padding(
                                  padding: EdgeInsets.only(right: 8),
                                  child: Container(
                                    width: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFEE500),
                                    ),
                                    padding: EdgeInsets.all(8),
                                    child: ExtendedImage.asset(
                                      'assets/imgs/logos/kakao_logo.png',
                                      enableMemoryCache: true,
                                      shape: BoxShape.rectangle,
                                      width: 20,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onTap: (){
                                _fleamarketDetailViewModel.changeSecret();
                              },
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color:
                                  (_fleamarketDetailViewModel.isSecret == true)
                                      ? Color(0xFFCBE0FF)
                                      : Color(0xFFECECEC),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(bottom: 1),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      (_fleamarketDetailViewModel.isSecret == true)
                                          ? Icon(Icons.lock,
                                        size: 17,
                                        color: SDSColor.snowliveBlue,
                                      )
                                          :  Icon(Icons.lock,
                                        size: 17,
                                        color: SDSColor.gray400,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: TextFormField(
                                key: _fleamarketDetailViewModel.formKey,
                                controller: _fleamarketDetailViewModel.textEditingController,
                                textAlignVertical: TextAlignVertical.center,
                                cursorColor: SDSColor.snowliveBlue,
                                cursorHeight: 16,
                                cursorWidth: 2,
                                autovalidateMode: AutovalidateMode.onUserInteraction,
                                style: SDSTextStyle.regular.copyWith(fontSize: 15),
                                strutStyle: StrutStyle(fontSize: 14, leading: 0),
                                enableSuggestions: false,
                                autocorrect: false,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  errorMaxLines: 2,
                                  errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                  labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                  hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
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
                                  hintText: '댓글을 입력하세요',
                                  contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
                                  fillColor: SDSColor.gray50,
                                  hoverColor: SDSColor.snowliveBlue,
                                  filled: true,
                                  focusColor: SDSColor.snowliveBlue,
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide(color: SDSColor.gray50),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: SDSColor.red, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(color: SDSColor.snowliveBlue, strokeAlign: BorderSide.strokeAlignInside, width: 1.5),
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
                  Positioned(
                    right: 0,
                    left: 0,
                    bottom: 72,
                    child: Container(
                      height: 1,
                      color: SDSColor.gray50,
                    ),
                  )
                ],
              );
          })
        ),
      ),
    ));
  }
}
