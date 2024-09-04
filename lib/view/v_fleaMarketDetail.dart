import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
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
  FleaMarketDetailView({Key? key}) : super(key: key);


  @override
  State<FleaMarketDetailView> createState() => _FleaMarketDetailViewState();
}

class _FleaMarketDetailViewState extends State<FleaMarketDetailView> {

  var f = NumberFormat('###,###,###,###');

  UserViewModel _userViewModel = Get.find<UserViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();
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
                                                              CustomFullScreenDialog.showDialog();
                                                              await _fleamarketDetailViewModel.deleteFleamarket(
                                                                  fleamarketId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                                                  userId: _userViewModel.user.user_id
                                                              );
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(userId: _userViewModel.user.user_id);
                                                              await _fleamarketListViewModel.fetchFleamarketData_ski(userId: _userViewModel.user.user_id);
                                                              await _fleamarketListViewModel.fetchFleamarketData_board(userId: _userViewModel.user.user_id);
                                                              await _fleamarketListViewModel.fetchFleamarketData_my(userId: _userViewModel.user.user_id);
                                                              CustomFullScreenDialog.cancelDialog();
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
          body: Obx((){
            if(_fleamarketDetailViewModel.isLoading.value == true){
              return Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 16),
                        height: 200,
                        color: SDSColor.snowliveWhite,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.only(right: 16),
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: SDSColor.snowliveWhite,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 20,
                                  color: SDSColor.snowliveWhite,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            height: 40,
                            color: SDSColor.snowliveWhite,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 150,
                                  height: 60,
                                  color: SDSColor.snowliveWhite,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Container(
                        height: 100,
                        color: SDSColor.snowliveWhite,
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 40,
                              color: SDSColor.snowliveWhite,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              height: 40,
                              color: SDSColor.snowliveWhite,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                    ],
                  ),
                )
              );

            }else {
              return SingleChildScrollView(
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
                                  //TODO: 프사, 닉네임 (SNS연결버튼은 옮겨야함)
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
                                if(_fleamarketDetailViewModel.fleamarketDetail.userId == _userViewModel.user.user_id)
                                  Row(
                                  mainAxisAlignment: MainAxisAlignment.start, // 좌측 정렬
                                  children: [
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
                                                            '거래완료',
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
                                                            newStatus: '거래완료',
                                                          );
                                                          await _fleamarketDetailViewModel.fetchFleamarketDetailForUpdateStatus(
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
                                                            '예약중',
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
                                                            newStatus: '예약중',
                                                          );
                                                          await _fleamarketDetailViewModel.fetchFleamarketDetailForUpdateStatus(
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
                                                            '거래가능',
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
                                                            newStatus: '거래가능',
                                                          );
                                                          await _fleamarketDetailViewModel.fetchFleamarketDetailForUpdateStatus(
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
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(4),
                                          color:
                                          (_fleamarketDetailViewModel.fleamarketDetail.status == '거래완료')
                                          ? Color(0xFF949494)
                                          : SDSColor.snowliveBlue,
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 5, vertical: 3),
                                        child:
                                        Text(
                                          _fleamarketDetailViewModel.fleamarketDetail.status!,
                                          style: TextStyle(
                                            color: SDSColor.snowliveWhite,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if(_fleamarketDetailViewModel.fleamarketDetail.userId != _userViewModel.user.user_id)
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
                                      '5분전',
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
                              ]),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                      ],
                    ),
                    Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  children: [
                                    (_fleamarketDetailViewModel.commentsList.length >0)
                                        ? Column(
                                      children: [
                                        ListView.builder(
                                          padding: EdgeInsets.only(top: 4),
                                          shrinkWrap: true,
                                          physics: NeverScrollableScrollPhysics(),
                                          itemCount: _fleamarketDetailViewModel.commentsList.length,
                                          itemBuilder: (context, index) {
                                            final document = _fleamarketDetailViewModel.commentsList[index];
                                            String timestamp = _fleamarketDetailViewModel.commentsList[index].uploadTime!;
                                            String formattedDate = GetDatetime().getAgoString(timestamp); // 원하는 형식으로 날짜 변환
                                            return Column(
                                              children: [
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    if (document.userInfo!.profileImageUrlUser != "")
                                                      GestureDetector(
                                                        onTap: () async{
                                                          await _friendDetailViewModel.fetchFriendDetailInfo(userId: _userViewModel.user.user_id, friendUserId: document.userInfo!.userId!, season: _friendDetailViewModel.seasonDate);
                                                          Get.toNamed(AppRoutes.friendDetail);
                                                        },
                                                        child: Container(
                                                          width: 40,
                                                          height: 40,
                                                          decoration: BoxDecoration(
                                                              color: Color(0xFFDFECFF),
                                                              borderRadius: BorderRadius.circular(50)
                                                          ),
                                                          child: ExtendedImage.network(
                                                            document.userInfo!.profileImageUrlUser!,
                                                            cache: true,
                                                            shape: BoxShape.circle,
                                                            borderRadius:
                                                            BorderRadius.circular(20),
                                                            width: 40,
                                                            height: 40,
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
                                                                    width: 40,
                                                                    height: 40,
                                                                    fit: BoxFit.cover,
                                                                  ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                default:
                                                                  return null;
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    if (document.userInfo!.profileImageUrlUser == "")
                                                      GestureDetector(
                                                        onTap: () async{
                                                          await _friendDetailViewModel.fetchFriendDetailInfo(userId: _userViewModel.user.user_id, friendUserId: document.userInfo!.userId!, season: _friendDetailViewModel.seasonDate);
                                                          Get.toNamed(AppRoutes.friendDetail);
                                                        },
                                                        child: ExtendedImage.network(
                                                          '${profileImgUrlList[0].default_round}',
                                                          shape: BoxShape.circle,
                                                          borderRadius:
                                                          BorderRadius.circular(20),
                                                          width: 40,
                                                          height: 40,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                    SizedBox(width: 12),
                                                    Row(
                                                      children: [
                                                        Text(
                                                          document.userInfo!.displayName!,
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Color(0xFF949494)
                                                          ),),
                                                        SizedBox(width: 6,),
                                                        Text(formattedDate,
                                                          style: TextStyle(
                                                              fontSize: 13,
                                                              color: Color(0xFF949494)
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        width: _size.width - 112,
                                                        child: Text(document.content!,
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              color: Color(0xFF111111)
                                                          ),),
                                                      ),
                                                      GestureDetector(
                                                        onTap: () =>
                                                            showModalBottomSheet(
                                                                enableDrag: false,
                                                                context: context,
                                                                builder: (context) {
                                                                  return SafeArea(
                                                                    child: Container(
                                                                      height: (_friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id
                                                                          || document.userInfo!.userId == _userViewModel.user.user_id)
                                                                          ? 200 : 150,
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                                        child: Column(
                                                                          children: [
                                                                            if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id
                                                                                || document.userInfo!.userId == _userViewModel.user.user_id)
                                                                              GestureDetector(
                                                                                child: ListTile(
                                                                                  contentPadding: EdgeInsets.zero,
                                                                                  title: Center(
                                                                                    child: Text(
                                                                                      '삭제',
                                                                                      style: TextStyle(
                                                                                          fontSize: 15,
                                                                                          fontWeight: FontWeight.bold,
                                                                                          color: Color(
                                                                                              0xFFD63636)
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
                                                                                                          onPressed: () {
                                                                                                            Navigator.pop(context);
                                                                                                          },
                                                                                                          child: Text('취소',
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
                                                                                                            await _friendDetailViewModel.deleteFriendsTalk(userId: _userViewModel.user.user_id, friendsTalkId: document.commentId!);
                                                                                                            print('삭제 완료');
                                                                                                            Navigator.pop(context);
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
                                                                            GestureDetector(
                                                                              child: ListTile(
                                                                                contentPadding: EdgeInsets.zero,
                                                                                title: Center(
                                                                                  child: Text('신고하기',
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
                                                                                                  onPressed: () async {

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
                                                                                    borderRadius: BorderRadius.circular(10)),
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
                                                                                        contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                                        elevation: 0,
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: BorderRadius.circular(10.0)),
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
                                                                                                '차단해제는 [친구목록 - 설정 - 차단목록]에서\n하실 수 있습니다.',
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
                                                                                                  onPressed: () {Navigator.pop(context);},
                                                                                                  child: Text('취소',
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 15,
                                                                                                      color: Color(0xFF949494),
                                                                                                      fontWeight: FontWeight.bold,
                                                                                                    ),
                                                                                                  )),
                                                                                              TextButton(
                                                                                                  onPressed: () async{

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
                                                                    ),
                                                                  );
                                                                }),
                                                        child: Icon(
                                                          Icons.more_horiz,
                                                          color: Color(0xFFdedede),
                                                          size: 20,
                                                        ),
                                                      )
                                                    ],
                                                  ),
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
                                            Text('친구톡이 없습니다', style: TextStyle(
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
                                  SizedBox(width: 10), // 아이콘과 텍스트 필드 사이의 여백
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
                                              "secret": "False"
                                            });
                                            await _fleamarketDetailViewModel.fetchFleamarketCommentsInDetailView(
                                              fleaId: _fleamarketDetailViewModel.fleamarketDetail.fleaId!,
                                              userId: _fleamarketDetailViewModel.fleamarketDetail.userId!,
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
                    ),
                  ],
                ),
              );
            }
          })
        ),
      ),
    ));
  }
}
