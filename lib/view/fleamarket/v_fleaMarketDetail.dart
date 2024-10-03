import 'package:carousel_slider/carousel_slider.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketImageScreen.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketCommentDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketUpdate.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

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
  final AlarmCenterViewModel _alarmCenterViewModel = Get.find<AlarmCenterViewModel>();

  final ScrollController _scrollController = ScrollController();
  bool isAppBarCollapsed = false;
  FocusNode textFocus = FocusNode();



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
    double statusBarHeight = MediaQuery.of(context).padding.top;
    double appBarHeight = kToolbarHeight;
    double totalAppBarHeight = statusBarHeight + appBarHeight;

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
                AppBar(
                  backgroundColor:
                  (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                      ? isAppBarCollapsed ? SDSColor.snowliveWhite : Colors.transparent
                      : SDSColor.snowliveWhite,
                  foregroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  flexibleSpace: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors:
                        (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                            ? isAppBarCollapsed ? [Colors.transparent, Colors.transparent,] : [Colors.black.withOpacity(0.4), Colors.transparent,]
                            : [Colors.transparent, Colors.transparent,],
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
                      color:
                      (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                          ? isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite
                          : SDSColor.gray900,
                    ),
                    onTap: () async{
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
                            HapticFeedback.lightImpact();
                            setState(() {_fleamarketDetailViewModel.changeIsFavorite(true);});
                            await _fleamarketDetailViewModel.addFavoriteFleamarket(
                                fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                                body: {
                                  "user_id": _userViewModel.user.user_id
                                }
                            );
                            await _fleamarketListViewModel.fetchAllFleamarket_afterFavorite();
                          },
                          child:Image.asset(
                            'assets/imgs/icons/icon_flea_appbar_scrap.png',
                            scale: 4,
                            width: 26,
                            height: 26,
                            color: (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                                ? isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite
                                : SDSColor.gray900,
                          ),
                        ),
                      ),
                    if((_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id )
                        && _fleamarketDetailViewModel.fleamarketDetail.isFavorite == true)
                      Padding(
                        padding: EdgeInsets.only(right: 20),
                        child: GestureDetector(
                          onTap: () async{
                            HapticFeedback.lightImpact();
                            setState(() {_fleamarketDetailViewModel.changeIsFavorite(false);});
                            await _fleamarketDetailViewModel.deleteFavoriteFleamarket(
                                fleamarketID: _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                                body: {
                                  "user_id": _userViewModel.user.user_id
                                }
                            );
                            await _fleamarketListViewModel.fetchAllFleamarket_afterFavorite();
                          },
                          child: Image.asset(
                            'assets/imgs/icons/icon_flea_appbar_scrap_on.png',
                            scale: 4,
                            width: 26,
                            height: 26,
                            color: (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                                ? isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite
                                : SDSColor.gray900,
                          ),
                        ),
                      ),
                    //공유하기 버튼
                    // Padding(
                    //   padding: EdgeInsets.only(right: 20),
                    //   child: Image.asset(
                    //     'assets/imgs/icons/icon_flea_appbar_share.png',
                    //     scale: 4,
                    //     width: 26,
                    //     height: 26,
                    //     color: (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                    //         ? isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite
                    //         : SDSColor.gray900,
                    //   ),
                    // ),
                    (_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)
                        ? Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          textFocus.unfocus();
                          showModalBottomSheet(
                              enableDrag: false,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 20),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 16,
                                      ),
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          children: [
                                            //TODO: 신고하기
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
                                                        backgroundColor: SDSColor.snowliveWhite,
                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16)),
                                                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                        content: Container(
                                                          height: 80,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                '이 회원을 신고하시겠습니까?',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: SDSColor.gray900,
                                                                    fontSize: 16
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 6,
                                                              ),
                                                              Text(
                                                                '신고가 일정 횟수 이상 누적되면 해당 게시물이 삭제 처리됩니다',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  color: SDSColor.gray500,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor: Colors.transparent, // 배경색 투명
                                                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                        ),
                                                                        child: Text('취소',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 17,
                                                                            color: SDSColor.gray500,
                                                                          ),
                                                                        )
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    child: TextButton(
                                                                        onPressed: () async {
                                                                          Navigator.pop(context);
                                                                          Navigator.pop(context);
                                                                          CustomFullScreenDialog.showDialog();
                                                                          await _fleamarketDetailViewModel.reportFleamarket(
                                                                              {
                                                                                "user_id": _userViewModel.user.user_id,
                                                                                "flea_id": _fleamarketDetailViewModel.fleamarketDetail.fleaId
                                                                              }
                                                                          );
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor: Colors.transparent, // 배경색 투명
                                                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                        ),
                                                                        child: Text('신고하기',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 17,
                                                                            color: SDSColor.snowliveBlue,
                                                                          ),
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                  );
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
                                                        backgroundColor: SDSColor.snowliveWhite,
                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16)),
                                                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                        content: Container(
                                                          height: 80,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                '이 회원의 모든 글을 숨기시겠습니까?',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: SDSColor.gray900,
                                                                    fontSize: 16
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: 6,
                                                              ),
                                                              Text(
                                                                '숨김해제는 [더보기 - 친구 - 설정 - 차단목록]에서 하실 수 있습니다.',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.regular.copyWith(
                                                                  color: SDSColor.gray500,
                                                                  fontSize: 14,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor: Colors.transparent, // 배경색 투명
                                                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                        ),
                                                                        child: Text('취소',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 17,
                                                                            color: SDSColor.gray500,
                                                                          ),
                                                                        )
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    child: TextButton(
                                                                        onPressed: () async {
                                                                          Navigator.pop(context);
                                                                          Navigator.pop(context);
                                                                          CustomFullScreenDialog.showDialog();
                                                                          await _userViewModel.block_user({
                                                                            "user_id": _userViewModel.user.user_id,
                                                                            "block_user_id": _fleamarketDetailViewModel.fleamarketDetail.userId
                                                                          });
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor: Colors.transparent, // 배경색 투명
                                                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                        ),
                                                                        child: Text('숨기기',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 17,
                                                                            color: SDSColor.snowliveBlue,
                                                                          ),
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                  );
                                                },
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10)),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                          );
                        },
                        child: Image.asset(
                          'assets/imgs/icons/icon_flea_appbar_more.png',
                          scale: 4,
                          width: 26,
                          height: 26,
                          color: (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                              ? isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite
                              : SDSColor.gray900,
                        ),
                      ),
                    )
                        : Padding(
                      padding: EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: () {
                          textFocus.unfocus();
                          showModalBottomSheet(
                              enableDrag: false,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              context: context,
                              builder: (context) {
                                return SafeArea(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 20),
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        left: 16,
                                        right: 16,
                                        top: 16,
                                      ),
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: SingleChildScrollView(
                                        child: Wrap(
                                          children: [
                                            //TODO: 수정하기
                                            GestureDetector(
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Center(
                                                  child: Text(
                                                    '글 수정하기',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        fontSize: 15,
                                                        color: SDSColor.gray900
                                                    ),
                                                  ),
                                                ),
                                                //selected: _isSelected[index]!,
                                                onTap: () async {
                                                  Navigator.pop(context);
                                                  CustomFullScreenDialog.showDialog();
                                                  _fleamarketUpdateViewModel.toggleUpdateCacheHeight();
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
                                                  CustomFullScreenDialog.cancelDialog();
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
                                                    '글 삭제하기',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        fontSize: 15,
                                                        color: SDSColor.red
                                                    ),
                                                  ),
                                                ),
                                                //selected: _isSelected[index]!,
                                                onTap: () async {
                                                  Get.dialog(
                                                      AlertDialog(
                                                        backgroundColor: SDSColor.snowliveWhite,
                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(16)),
                                                        buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                        content: Container(
                                                          height: 40,
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                            children: [
                                                              Text(
                                                                '이 글을 삭제하시겠어요?',
                                                                textAlign: TextAlign.center,
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    color: SDSColor.gray900,
                                                                    fontSize: 16
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        actions: [
                                                          Padding(
                                                            padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                            child: Row(
                                                              children: [
                                                                Expanded(
                                                                  child: Container(
                                                                    child: TextButton(
                                                                        onPressed: () {
                                                                          Navigator.pop(context);
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor: Colors.transparent, // 배경색 투명
                                                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                        ),
                                                                        child: Text('취소',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 17,
                                                                            color: SDSColor.gray500,
                                                                          ),
                                                                        )
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                                Expanded(
                                                                  child: Container(
                                                                    child: TextButton(
                                                                        onPressed: () async {
                                                                          Navigator.pop(context);
                                                                          Navigator.pop(context);
                                                                          CustomFullScreenDialog.showDialog();
                                                                          await _fleamarketDetailViewModel.deleteFleamarket(
                                                                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                              userId: _userViewModel.user.user_id
                                                                          );
                                                                          Get.back();
                                                                          CustomFullScreenDialog.cancelDialog();
                                                                          await _fleamarketListViewModel.fetchAllFleamarket();
                                                                        },
                                                                        style: TextButton.styleFrom(
                                                                          backgroundColor: Colors.transparent, // 배경색 투명
                                                                          splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                        ),
                                                                        child: Text('삭제하기',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                            fontSize: 17,
                                                                            color: SDSColor.red,
                                                                          ),
                                                                        )),
                                                                  ),
                                                                )
                                                              ],
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                            ),
                                                          )
                                                        ],
                                                      )
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
                                    ),
                                  ),
                                );
                              });
                        },
                        child: Image.asset(
                          'assets/imgs/icons/icon_flea_appbar_more.png',
                          scale: 4,
                          width: 26,
                          height: 26,
                          color: (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty)
                              ? isAppBarCollapsed ? SDSColor.gray900 : SDSColor.snowliveWhite
                              : SDSColor.gray900,
                        ),
                      ),
                    )
                  ],
                )
            ),
            body: Obx((){
              return GestureDetector(
                onTap: (){
                  textFocus.unfocus();
                  FocusScope.of(context).unfocus();
                },
                child: Container(
                  child: Stack(
                    children: [
                      RefreshIndicator(
                        strokeWidth: 2,
                        edgeOffset: 60,
                        backgroundColor: SDSColor.snowliveBlue,
                        color: SDSColor.snowliveWhite,
                        onRefresh: () async{
                          await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(
                              fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                              userId: _userViewModel.user.user_id
                          );
                        },
                        child: SingleChildScrollView(
                          controller: _scrollController,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height
                            ),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    if (_fleamarketDetailViewModel.fleamarketDetail.photos!.length == 0)
                                      SizedBox(height: totalAppBarHeight),
                                    if (_fleamarketDetailViewModel.fleamarketDetail.photos!.length != 0)
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
                                                        textFocus.unfocus();
                                                        Get.to(() => FleaMarketImageScreen(
                                                          itemImagesUrls: _fleamarketDetailViewModel.fleamarketDetail.photos!.map((photo) => photo.urlFleaPhoto!).toList(),
                                                          initialIndex: index,
                                                        ));
                                                      },
                                                      child: ExtendedImage.network(
                                                        _fleamarketDetailViewModel.fleamarketDetail.photos![index].urlFleaPhoto!,
                                                        fit: BoxFit.cover,
                                                        width: _size.width,
                                                        height: _size.width,
                                                        cacheHeight: 1080,
                                                        loadStateChanged: (ExtendedImageState state) {
                                                          switch (state.extendedImageLoadState) {
                                                            case LoadState.loading:
                                                            // 로딩 중일 때 로딩 인디케이터를 표시
                                                              return Shimmer.fromColors(
                                                                baseColor: SDSColor.gray50!,
                                                                highlightColor: SDSColor.gray200!,
                                                                direction: ShimmerDirection.ltr,
                                                                child: Container(
                                                                  width: _size.width,
                                                                  height: _size.width,
                                                                  decoration: BoxDecoration(
                                                                    color: Colors.white,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                  ),
                                                                ),
                                                              );
                                                            case LoadState.completed:
                                                            // 로딩이 완료되었을 때 이미지 반환
                                                              return state.completedWidget;
                                                            case LoadState.failed:
                                                              print('Image load failed: ${state.lastException}');
                                                              // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                              return Image.asset(
                                                                'assets/imgs/imgs/img_flea_default.png', // 대체 이미지 경로
                                                                width: 110,
                                                                height: 110,
                                                                fit: BoxFit.cover,
                                                              );
                                                          }
                                                        },
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
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 16,),
                                      child: Padding(
                                        padding: EdgeInsets.only(top: (_fleamarketDetailViewModel.fleamarketDetail.photos!.isNotEmpty) ? 16 : 0),
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
                                                              textFocus.unfocus();
                                                              Get.toNamed(AppRoutes.friendDetail);
                                                              await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                  userId: _userViewModel.user.user_id,
                                                                  friendUserId:_fleamarketDetailViewModel.fleamarketDetail.userInfo!.userId!,
                                                                  season: _friendDetailViewModel.seasonDate);
                                                            },
                                                            child: ClipOval(
                                                              child: Image.asset(
                                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                                width: 32,
                                                                height: 32,
                                                                fit: BoxFit.cover,
                                                              ),
                                                            )
                                                            ,
                                                          ),
                                                        if (_fleamarketDetailViewModel.fleamarketDetail.userInfo!.profileImageUrlUser!.isNotEmpty)
                                                          GestureDetector(
                                                            onTap: () async{
                                                              textFocus.unfocus();
                                                              Get.toNamed(AppRoutes.friendDetail);
                                                              await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                  userId: _userViewModel.user.user_id,
                                                                  friendUserId:_fleamarketDetailViewModel.fleamarketDetail.userInfo!.userId!,
                                                                  season: _friendDetailViewModel.seasonDate);
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
                                                                      return ClipOval(
                                                                        child: Image.asset(
                                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                                          width: 32,
                                                                          height: 32,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      )
                                                                      ; // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                    default:
                                                                      return null;
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        SizedBox(width: 8),
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
                                                  height: 30,
                                                  thickness: 1,
                                                  color: SDSColor.gray50,
                                                ),
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
                                              height: 4,
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
                                              padding: EdgeInsets.only(top: 16),
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
                                              color: SDSColor.gray50,
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
                                                    textFocus.unfocus();
                                                    showModalBottomSheet(
                                                      enableDrag: false,
                                                      isScrollControlled: true,
                                                      backgroundColor: Colors.transparent,
                                                      context: context,
                                                      builder: (context) {
                                                        return SafeArea(
                                                          child: Padding(
                                                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                                                            child: Container(
                                                              margin: EdgeInsets.only(
                                                                left: 16,
                                                                right: 16,
                                                                top: 16,
                                                              ),
                                                              padding: EdgeInsets.all(16),
                                                              decoration: BoxDecoration(
                                                                color: Colors.white,
                                                                borderRadius: BorderRadius.circular(16),
                                                              ),
                                                              child: Wrap(
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
                                                                        CustomFullScreenDialog.showDialog();
                                                                        await _fleamarketDetailViewModel.updateStatus(
                                                                          fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                          body: {
                                                                            "user_id": _userViewModel.user.user_id,
                                                                            "status": '${FleamarketStatus.soldOut.korean}',
                                                                          },
                                                                        );
                                                                        CustomFullScreenDialog.cancelDialog();
                                                                        await _fleamarketListViewModel.fetchAllFleamarket();
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
                                                                        CustomFullScreenDialog.showDialog();
                                                                        await _fleamarketDetailViewModel.updateStatus(
                                                                          fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                          body: {
                                                                            "user_id": _userViewModel.user.user_id,
                                                                            "status": '${FleamarketStatus.onBooking.korean}',
                                                                          },
                                                                        );
                                                                        CustomFullScreenDialog.cancelDialog();
                                                                        await _fleamarketListViewModel.fetchAllFleamarket();
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
                                                                        CustomFullScreenDialog.showDialog();
                                                                        await _fleamarketDetailViewModel.updateStatus(
                                                                          fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                          body: {
                                                                            "user_id": _userViewModel.user.user_id,
                                                                            "status": '${FleamarketStatus.forSale.korean}',
                                                                          },
                                                                        );
                                                                        CustomFullScreenDialog.cancelDialog();
                                                                        await _fleamarketListViewModel.fetchAllFleamarket();
                                                                      },
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(10),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
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
                                        child: Column(
                                          children: [
                                            (_fleamarketDetailViewModel.fleamarketDetail.commentList!.length >0)
                                                ? Column(
                                              children: [
                                                ListView.builder(
                                                  padding: EdgeInsets.only(top: 4),
                                                  shrinkWrap: true,
                                                  controller: _fleamarketDetailViewModel.scrollController,
                                                  physics: NeverScrollableScrollPhysics(),
                                                  itemCount: _fleamarketDetailViewModel.fleamarketDetail.commentList!.length,
                                                  itemBuilder: (context, index) {
                                                    final document_comment = _fleamarketDetailViewModel.fleamarketDetail.commentList![index];
                                                    String timestamp = _fleamarketDetailViewModel.fleamarketDetail.commentList![index].uploadTime!;
                                                    String time = GetDatetime().getAgoString(timestamp); // 원하는 형식으로 날짜 변환
                                                    return Column(
                                                      children: [
                                                        if(document_comment.secret! &&
                                                            (document_comment.userId != _userViewModel.user.user_id
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
                                                        if(!document_comment.secret! ||
                                                            (document_comment.secret! && (document_comment.userId == _userViewModel.user.user_id
                                                                || _fleamarketDetailViewModel.fleamarketDetail.userId == _userViewModel.user.user_id)))
                                                          Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  if (document_comment.userInfo!.profileImageUrlUser != "")
                                                                    GestureDetector(
                                                                      onTap: () async {
                                                                        textFocus.unfocus();
                                                                        Get.toNamed(AppRoutes.friendDetail);
                                                                        await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                            userId: _userViewModel.user.user_id,
                                                                            friendUserId: document_comment.userInfo!.userId!,
                                                                            season: _friendDetailViewModel.seasonDate);
                                                                      },
                                                                      child: Container(
                                                                        width: 32,
                                                                        height: 32,
                                                                        decoration: BoxDecoration(
                                                                          color: Color(0xFFDFECFF),
                                                                          borderRadius: BorderRadius.circular(50),
                                                                        ),
                                                                        child: ExtendedImage.network(
                                                                          document_comment.userInfo!.profileImageUrlUser!,
                                                                          cache: true,
                                                                          shape: BoxShape.circle,
                                                                          borderRadius: BorderRadius.circular(20),
                                                                          width: 32,
                                                                          height: 32,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (document_comment.userInfo!.profileImageUrlUser == "")
                                                                    GestureDetector(
                                                                      onTap: () async {
                                                                        textFocus.unfocus();
                                                                        Get.toNamed(AppRoutes.friendDetail);
                                                                        await _friendDetailViewModel.fetchFriendDetailInfo(
                                                                            userId: _userViewModel.user.user_id,
                                                                            friendUserId: document_comment.userInfo!.userId!,
                                                                            season: _friendDetailViewModel.seasonDate);
                                                                      },
                                                                      child: ClipOval(
                                                                        child: Image.asset(
                                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                                          width: 32,
                                                                          height: 32,
                                                                          fit: BoxFit.cover,
                                                                        ),
                                                                      )
                                                                      ,
                                                                    ),
                                                                  SizedBox(width: 12),
                                                                  Expanded(
                                                                    child: Column(
                                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              document_comment.userInfo!.displayName!,
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

                                                                            if(document_comment.userInfo!.userId == _fleamarketDetailViewModel.fleamarketDetail.userId)
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 6),
                                                                                child: Container(
                                                                                  decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius.circular(30),
                                                                                      color: SDSColor.blue100

                                                                                  ),
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.only(top: 3, bottom: 3, left: 6, right: 6),
                                                                                    child: Text(
                                                                                      '글쓴이',
                                                                                      style: SDSTextStyle.bold.copyWith(fontSize: 11,
                                                                                          color: SDSColor.snowliveBlue),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            if (document_comment.secret!)
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: 6),
                                                                                child: Icon(Icons.lock,
                                                                                  size: 14,
                                                                                  color: SDSColor.gray300,
                                                                                ),
                                                                              ),
                                                                            Spacer(), // Adds space between the text and the icons
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                textFocus.unfocus();
                                                                                showModalBottomSheet(
                                                                                  enableDrag: false,
                                                                                  isScrollControlled: true,
                                                                                  backgroundColor: Colors.transparent,
                                                                                  context: context,
                                                                                  builder: (context) {
                                                                                    return SafeArea(
                                                                                      child: Padding(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
                                                                                        child: Container(
                                                                                          margin: EdgeInsets.only(
                                                                                            left: 16,
                                                                                            right: 16,
                                                                                            top: 16,
                                                                                          ),
                                                                                          padding: EdgeInsets.all(16),
                                                                                          decoration: BoxDecoration(
                                                                                            color: Colors.white,
                                                                                            borderRadius: BorderRadius.circular(16),
                                                                                          ),
                                                                                          child: Wrap(
                                                                                            children: [
                                                                                              if (_friendDetailViewModel.friendDetailModel.friendUserInfo.userId != _userViewModel.user.user_id && document_comment.userInfo!.userId != _userViewModel.user.user_id)
                                                                                                Column(
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
                                                                                                        onTap: () async {
                                                                                                          Get.dialog(
                                                                                                              AlertDialog(
                                                                                                                backgroundColor: SDSColor.snowliveWhite,
                                                                                                                contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                                                elevation: 0,
                                                                                                                shape: RoundedRectangleBorder(
                                                                                                                    borderRadius: BorderRadius.circular(16)),
                                                                                                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                                content: Container(
                                                                                                                  height: 80,
                                                                                                                  child: Column(
                                                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                                    children: [
                                                                                                                      Text(
                                                                                                                        '이 회원을 신고하시겠습니까?',
                                                                                                                        textAlign: TextAlign.center,
                                                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                                                            color: SDSColor.gray900,
                                                                                                                            fontSize: 16
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      SizedBox(
                                                                                                                        height: 6,
                                                                                                                      ),
                                                                                                                      Text(
                                                                                                                        '신고가 일정 횟수 이상 누적되면 해당 게시물이 삭제 처리됩니다',
                                                                                                                        textAlign: TextAlign.center,
                                                                                                                        style: SDSTextStyle.regular.copyWith(
                                                                                                                          color: SDSColor.gray500,
                                                                                                                          fontSize: 14,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                ),
                                                                                                                actions: [
                                                                                                                  Padding(
                                                                                                                    padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                                                                                    child: Row(
                                                                                                                      children: [
                                                                                                                        Expanded(
                                                                                                                          child: Container(
                                                                                                                            child: TextButton(
                                                                                                                                onPressed: () {
                                                                                                                                  Navigator.pop(context);
                                                                                                                                },
                                                                                                                                style: TextButton.styleFrom(
                                                                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                                ),
                                                                                                                                child: Text('취소',
                                                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                                                    fontSize: 17,
                                                                                                                                    color: SDSColor.gray500,
                                                                                                                                  ),
                                                                                                                                )
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        SizedBox(
                                                                                                                          width: 10,
                                                                                                                        ),
                                                                                                                        Expanded(
                                                                                                                          child: Container(
                                                                                                                            child: TextButton(
                                                                                                                                onPressed: () async {
                                                                                                                                  Navigator.pop(context);
                                                                                                                                  Navigator.pop(context);
                                                                                                                                  CustomFullScreenDialog.showDialog();
                                                                                                                                  await _fleamarketDetailViewModel.reportComment({
                                                                                                                                    "user_id": _userViewModel.user.user_id.toString(),
                                                                                                                                    "comment_id": document_comment.commentId
                                                                                                                                  });
                                                                                                                                },
                                                                                                                                style: TextButton.styleFrom(
                                                                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                                ),
                                                                                                                                child: Text('신고하기',
                                                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                                                    fontSize: 17,
                                                                                                                                    color: SDSColor.snowliveBlue,
                                                                                                                                  ),
                                                                                                                                )),
                                                                                                                          ),
                                                                                                                        )
                                                                                                                      ],
                                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                    ),
                                                                                                                  )
                                                                                                                ],
                                                                                                              )
                                                                                                          );
                                                                                                        },
                                                                                                      ),
                                                                                                    ),
                                                                                                    GestureDetector(
                                                                                                      child: ListTile(
                                                                                                        contentPadding: EdgeInsets.zero,
                                                                                                        title: Center(
                                                                                                          child: Text(
                                                                                                            '이 회원의 모든 글 숨기기',
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
                                                                                                                backgroundColor: SDSColor.snowliveWhite,
                                                                                                                contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                                                elevation: 0,
                                                                                                                shape: RoundedRectangleBorder(
                                                                                                                    borderRadius: BorderRadius.circular(16)),
                                                                                                                buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                                content: Container(
                                                                                                                  height: 80,
                                                                                                                  child: Column(
                                                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                                    children: [
                                                                                                                      Text(
                                                                                                                        '이 회원의 모든 글을 숨기시겠습니까?',
                                                                                                                        textAlign: TextAlign.center,
                                                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                                                            color: SDSColor.gray900,
                                                                                                                            fontSize: 16
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      SizedBox(
                                                                                                                        height: 6,
                                                                                                                      ),
                                                                                                                      Text(
                                                                                                                        '숨김해제는 [더보기 - 친구 - 설정 - 차단목록]에서 하실 수 있습니다.',
                                                                                                                        textAlign: TextAlign.center,
                                                                                                                        style: SDSTextStyle.regular.copyWith(
                                                                                                                          color: SDSColor.gray500,
                                                                                                                          fontSize: 14,
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ],
                                                                                                                  ),
                                                                                                                ),
                                                                                                                actions: [
                                                                                                                  Padding(
                                                                                                                    padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                                                                                    child: Row(
                                                                                                                      children: [
                                                                                                                        Expanded(
                                                                                                                          child: Container(
                                                                                                                            child: TextButton(
                                                                                                                                onPressed: () async{
                                                                                                                                  Navigator.pop(context);
                                                                                                                                },
                                                                                                                                style: TextButton.styleFrom(
                                                                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                                ),
                                                                                                                                child: Text('취소',
                                                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                                                    fontSize: 17,
                                                                                                                                    color: SDSColor.gray500,
                                                                                                                                  ),
                                                                                                                                )
                                                                                                                            ),
                                                                                                                          ),
                                                                                                                        ),
                                                                                                                        SizedBox(
                                                                                                                          width: 10,
                                                                                                                        ),
                                                                                                                        Expanded(
                                                                                                                          child: Container(
                                                                                                                            child: TextButton(
                                                                                                                                onPressed: () async {
                                                                                                                                  Navigator.pop(context);
                                                                                                                                  Navigator.pop(context);
                                                                                                                                  CustomFullScreenDialog.showDialog();
                                                                                                                                  await _userViewModel.block_user({
                                                                                                                                    "user_id" : _userViewModel.user.user_id,    //필수 - 차단하는 사람(나)
                                                                                                                                    "block_user_id" : document_comment.userId      //필수 - 내가 차단할 사람
                                                                                                                                  });
                                                                                                                                  await _fleamarketDetailViewModel.fetchFleamarketComments(
                                                                                                                                    fleaId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                                                                                    userId: _userViewModel.user.user_id,
                                                                                                                                    isLoading_indi: true,
                                                                                                                                  );
                                                                                                                                },
                                                                                                                                style: TextButton.styleFrom(
                                                                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                                ),
                                                                                                                                child: Text('숨기기',
                                                                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                                                                    fontSize: 17,
                                                                                                                                    color: SDSColor.snowliveBlue,
                                                                                                                                  ),
                                                                                                                                )),
                                                                                                                          ),
                                                                                                                        )
                                                                                                                      ],
                                                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                    ),
                                                                                                                  )
                                                                                                                ],
                                                                                                              )
                                                                                                          );
                                                                                                        },
                                                                                                        shape: RoundedRectangleBorder(
                                                                                                            borderRadius: BorderRadius.circular(10)),
                                                                                                      ),
                                                                                                    )
                                                                                                  ],
                                                                                                ),
                                                                                              if (_friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id || document_comment.userInfo!.userId == _userViewModel.user.user_id)
                                                                                                GestureDetector(
                                                                                                  child: ListTile(
                                                                                                    contentPadding: EdgeInsets.zero,
                                                                                                    title: Center(
                                                                                                      child: Text(
                                                                                                        '삭제하기',
                                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                                          fontSize: 15,
                                                                                                          color: SDSColor.red,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ),
                                                                                                    onTap: () async {
                                                                                                      Get.dialog(
                                                                                                          AlertDialog(
                                                                                                            backgroundColor: SDSColor.snowliveWhite,
                                                                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                                            elevation: 0,
                                                                                                            shape: RoundedRectangleBorder(
                                                                                                                borderRadius: BorderRadius.circular(16)),
                                                                                                            buttonPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 0),
                                                                                                            content: Container(
                                                                                                              height: 40,
                                                                                                              child: Column(
                                                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                                                children: [
                                                                                                                  Text(
                                                                                                                    '이 글을 삭제하시겠어요?',
                                                                                                                    textAlign: TextAlign.center,
                                                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                                                        color: SDSColor.gray900,
                                                                                                                        fontSize: 16
                                                                                                                    ),
                                                                                                                  ),
                                                                                                                ],
                                                                                                              ),
                                                                                                            ),
                                                                                                            actions: [
                                                                                                              Padding(
                                                                                                                padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                                                                                child: Row(
                                                                                                                  children: [
                                                                                                                    Expanded(
                                                                                                                      child: Container(
                                                                                                                        child: TextButton(
                                                                                                                            onPressed: () {
                                                                                                                              Navigator.pop(context);
                                                                                                                              Navigator.pop(context);
                                                                                                                            },
                                                                                                                            style: TextButton.styleFrom(
                                                                                                                              backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                              splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                            ),
                                                                                                                            child: Text('취소',
                                                                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                                                                fontSize: 17,
                                                                                                                                color: SDSColor.gray500,
                                                                                                                              ),
                                                                                                                            )
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                    ),
                                                                                                                    SizedBox(
                                                                                                                      width: 10,
                                                                                                                    ),
                                                                                                                    Expanded(
                                                                                                                      child: Container(
                                                                                                                        child: TextButton(
                                                                                                                            onPressed: () async {
                                                                                                                              Navigator.pop(context);
                                                                                                                              Navigator.pop(context);
                                                                                                                              CustomFullScreenDialog.showDialog();
                                                                                                                              await _fleamarketDetailViewModel.deleteFleamarketComments(
                                                                                                                                  user_id: _userViewModel.user.user_id,
                                                                                                                                  comment_id: document_comment.commentId
                                                                                                                              );
                                                                                                                              await _fleamarketDetailViewModel.fetchFleamarketComments(
                                                                                                                                fleaId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                                                                                userId: _userViewModel.user.user_id,
                                                                                                                                isLoading_indi: true,
                                                                                                                              );
                                                                                                                              CustomFullScreenDialog.cancelDialog();
                                                                                                                              await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!, userId: _userViewModel.user.user_id);
                                                                                                                              await _fleamarketListViewModel.fetchAllFleamarket();
                                                                                                                            },
                                                                                                                            style: TextButton.styleFrom(
                                                                                                                              backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                              splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                            ),
                                                                                                                            child: Text('삭제하기',
                                                                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                                                                fontSize: 17,
                                                                                                                                color: SDSColor.red,
                                                                                                                              ),
                                                                                                                            )),
                                                                                                                      ),
                                                                                                                    )
                                                                                                                  ],
                                                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                                                ),
                                                                                                              )
                                                                                                            ],
                                                                                                          )
                                                                                                      );
                                                                                                    },
                                                                                                  ),
                                                                                                ),

                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                );
                                                                              },
                                                                              child: Icon(
                                                                                Icons.more_horiz,
                                                                                color: SDSColor.gray200,
                                                                                size: 20,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        GestureDetector(
                                                                          onTap: () async{
                                                                            textFocus.unfocus();
                                                                            if(document_comment.secret! &&
                                                                                (document_comment.userId != _userViewModel.user.user_id
                                                                                    && _fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)){
                                                                            }else {
                                                                              await _fleamarketCommentDetailViewModel.fetchFleamarketCommentDetailFromModel(commentModel_flea: document_comment);
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
                                                                                    document_comment.content!,
                                                                                    style: SDSTextStyle.regular.copyWith(
                                                                                      fontSize: 14,
                                                                                      color: SDSColor.gray900,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: 8),
                                                                                Text(
                                                                                  (document_comment.replies!.length == 0)
                                                                                      ? '답글 달기'
                                                                                      : '답글 ${document_comment.replies!.length}개 보기',
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
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
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
                                      textFocus.unfocus();
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
                                        child: Image.asset(
                                          'assets/imgs/logos/kakao_logo.png',
                                          width: 20,
                                          fit: BoxFit.cover,
                                        )
                                        ,
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
                                          ? SDSColor.blue100
                                          : SDSColor.gray50,
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
                                    focusNode: textFocus,
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
                                          textFocus.unfocus();
                                          CustomFullScreenDialog.showDialog();
                                          if (_fleamarketDetailViewModel.textEditingController.text.trim().isEmpty) {
                                            return;
                                          }
                                          await _fleamarketDetailViewModel.uploadFleamarketComments({
                                            "flea_id": _fleamarketDetailViewModel.fleamarketDetail.fleaId,
                                            "content": _fleamarketDetailViewModel.textEditingController.text,
                                            "user_id": _userViewModel.user.user_id,
                                            "secret": "${_fleamarketDetailViewModel.isSecret}"
                                          });
                                          _fleamarketDetailViewModel.textEditingController.clear();
                                          FocusScope.of(context).unfocus();
                                          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                                          await _alarmCenterViewModel.updateNotification(
                                              _fleamarketDetailViewModel.fleamarketDetail.userId!,
                                              total: true
                                          );
                                          CustomFullScreenDialog.cancelDialog();
                                          await _fleamarketDetailViewModel.fetchFleamarketDetailFromAPI(fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!, userId: _userViewModel.user.user_id);
                                          await _fleamarketListViewModel.fetchAllFleamarket();
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
                  ),
                ),
              );
            })
        ),
      ),
    ));
  }
}
