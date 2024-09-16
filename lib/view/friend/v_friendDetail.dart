import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/friend/v_profilePageCalendar.dart';
import 'package:com.snowlive/viewmodel/vm_friendDetail.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../data/imgaUrls/Data_url_image.dart';
import '../../screens/snowliveDesignStyle.dart';
import '../../viewmodel/vm_friendDetailUpdate.dart';
import '../../viewmodel/vm_user.dart';

class FriendDetailView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    final Size _size = MediaQuery.of(context).size;
    FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
    UserViewModel _userViewModel = Get.find<UserViewModel>();
    FriendDetailUpdateViewModel _friendDetailUpdateViewModel = Get.find<FriendDetailUpdateViewModel>();

    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          leading: GestureDetector(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/imgs/icons/icon_snowLive_back.png',
                  scale: 4,
                  width: 26,
                  height: 26,
                ),
              ],
            ),
            onTap: () {
              Get.back();
            },
          ),
          actions: [
            if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id)
            GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/imgs/icons/icon_edit_pencil.png',
                      scale: 1,
                      width: 26,
                      height: 26,
                    )
                  ],
                ),
              ),
              onTap: () {
                //TODO: 수정페이지로 이동
                _friendDetailUpdateViewModel.fetchFriendDetailUpdateData(
                    displayName: _friendDetailViewModel.friendDetailModel.friendUserInfo.displayName,
                    state_msg: _friendDetailViewModel.friendDetailModel.friendUserInfo.stateMsg,
                    profileImageUrl: _friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser,
                    selectedResortName: _friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResort,
                    selectedResortIndex: _friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResortId-1,
                    selectedSkiOrBoard: _friendDetailViewModel.friendDetailModel.friendUserInfo.skiorboard,
                    selectedSex: _friendDetailViewModel.friendDetailModel.friendUserInfo.sex,
                    hideProfile: _friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile
                );
                Get.toNamed(AppRoutes.friendDetailUpdate);
              },
            ),
          ],
          elevation: 0.0,
          titleSpacing: 0,
          centerTitle: true,
          toolbarHeight: 58.0, // 이 부분은 AppBar의 높이를 조절합니다.
        ),
        body: RefreshIndicator(
          strokeWidth: 2,
          edgeOffset: 40,
          onRefresh: ()=> _friendDetailViewModel.fetchFriendDetailInfo(
              userId: _userViewModel.user.user_id,
              friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
              season: _friendDetailViewModel.seasonDate),
          child: Container(
            color: Colors.white,
            child: SafeArea(
              child: Container(
                height: _size.height,
                width: _size.width,
                child: GestureDetector(
                  onTap: (){
                    FocusScope.of(context).unfocus();
                  },
                  child: SingleChildScrollView(
                    child: Obx(()=> Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //TODO: 프사, 닉네임, 상태메세지, 친구등록버튼
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              //TODO: 프사
                              (_friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser.isNotEmpty)
                                  ? GestureDetector(
                                onTap: () {
                                  Get.toNamed(AppRoutes.userProfileIamge,arguments:_friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser);
                                },
                                child: Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFDFECFF),
                                        borderRadius: BorderRadius.circular(80)
                                    ),
                                    child: ExtendedImage.network(
                                      _friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser,
                                      enableMemoryCache: true,
                                      shape: BoxShape.circle,
                                      borderRadius: BorderRadius.circular(8),
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      loadStateChanged: (ExtendedImageState state) {
                                        switch (state.extendedImageLoadState) {
                                          case LoadState.loading:
                                            return SizedBox.shrink();
                                          case LoadState.completed:
                                            return state.completedWidget;
                                          case LoadState.failed:
                                            return ExtendedImage.network(
                                              'https://i.esdrop.com/d/f/yytYSNBROy/NIlGn0N46O.png',
                                              shape: BoxShape.circle,
                                              borderRadius: BorderRadius.circular(8),
                                              width: 110,
                                              height: 110,
                                              fit: BoxFit.cover,
                                            ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                          default:
                                            return null;
                                        }
                                      },
                                    )),
                              )
                                  :  GestureDetector(
                                onTap: () {
                                },
                                child: Container(
                                  width: 110,
                                  height: 110,
                                  child: ExtendedImage.network(
                                    'https://i.esdrop.com/d/f/yytYSNBROy/NIlGn0N46O.png',
                                    enableMemoryCache: true,
                                    shape: BoxShape.circle,
                                    borderRadius: BorderRadius.circular(8),
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Container(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //TODO: 닉네임
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Text('${_friendDetailViewModel.friendDetailModel.friendUserInfo.displayName}',
                                            style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111111)
                                            ),),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text(
                                        '${_friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResort} · ${_friendDetailViewModel.friendDetailModel.friendUserInfo.crewName}',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF949494),
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ),
                                    //TODO: 상태메세지
                                    (_friendDetailViewModel.friendDetailModel.friendUserInfo.stateMsg != null)
                                        ? Container(
                                      child: Text('${_friendDetailViewModel.friendDetailModel.friendUserInfo.stateMsg}', style: TextStyle(
                                          fontSize: 14,
                                          color: SDSColor.gray500),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                        : SizedBox.shrink(),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    //TODO: 친구추가 버튼
                                    if(_userViewModel.user.user_id == _friendDetailViewModel.friendDetailModel.friendUserInfo.userId)
                                      Container(), //프디페 = 내 프디페
                                    if(_userViewModel.user.user_id != _friendDetailViewModel.friendDetailModel.friendUserInfo.userId &&
                                        !_friendDetailViewModel.friendDetailModel.friendUserInfo.areWeFriend)
                                      ElevatedButton(
                                        onPressed: () async{
                                          Get.dialog(
                                              AlertDialog(
                                                contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0)),
                                                buttonPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                                                content: Text(
                                                  '친구등록 요청을 보내시겠습니까?',
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
                                                          child: Text('취소',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(0xFF949494),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )),
                                                      TextButton(
                                                          onPressed: () async {
                                                            Navigator.pop(context);
                                                            await _friendDetailViewModel.sendFriendRequest({
                                                              "user_id": _userViewModel.user.user_id,    //필수 - 신청자 (나)
                                                              "friend_user_id": _friendDetailViewModel.friendDetailModel.friendUserInfo.userId    //필수 - 신청받는사람
                                                            });
                                                          },
                                                          child: Text('보내기',
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                              color: Color(0xFF3D83ED),
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          )),
                                                    ],
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                  )
                                                ],
                                              ));
                                        }, child: Text('친구 추가', style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: SDSColor.snowliveBlack
                                      ),
                                      ),
                                        style: TextButton.styleFrom(
                                            shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(15)),
                                                side: BorderSide(color: Color(0xFFDEDEDE))
                                            ),
                                            padding: EdgeInsets.symmetric(horizontal: 6),
                                            elevation: 0,
                                            splashFactory: InkRipple.splashFactory,
                                            minimumSize: Size(82, 32),
                                            backgroundColor:
                                            Color(0xffffffff)),
                                      ), //내가 아니고, 친구도 아닐 때
                                    if(_userViewModel.user.user_id != _friendDetailViewModel.friendDetailModel.friendUserInfo.userId &&
                                        _friendDetailViewModel.friendDetailModel.friendUserInfo.areWeFriend)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Color(0xFFF0F6FF),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text(
                                                '내 친구',
                                                style: TextStyle(
                                                  fontSize: 13,
                                                  color: SDSColor.snowliveBlue,
                                                  fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          GestureDetector(
                                            onTap:() async{
                                              await _friendDetailViewModel.checkFriendRelationship(
                                                  {
                                                    "my_user_id": _userViewModel.user.user_id.toString(),
                                                    "friend_user_id": _friendDetailViewModel.friendDetailModel.friendUserInfo.userId.toString()
                                                  }
                                              );
                                              await _friendDetailViewModel.toggleBestFriend(
                                                  {
                                                    "friend_id": _friendDetailViewModel.friend_id
                                                  }
                                              );
                                            },
                                            child: Obx(()=>Container(
                                              child: (!_friendDetailViewModel.friendDetailModel.friendUserInfo.bestFriend)
                                                  ? Image.asset(
                                                'assets/imgs/icons/icon_profile_bestfriend_off.png',  // 에셋 이미지 경로
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                              )
                                                  : Image.asset(
                                                'assets/imgs/icons/icon_profile_bestfriend_on.png',  // 에셋 이미지 경로
                                                width: 24,
                                                height: 24,
                                                fit: BoxFit.cover,
                                              ),
                                            )),
                                          ),
                                        ],
                                      ),//내가 아니고, 친구일 때
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20,),
                        if(_friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile == false
                        || _friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id)
                        Column(children: [
                          SafeArea(
                            child: Stack(
                              children: [
                                Positioned(
                                  top: 44,
                                  child: Container(
                                    width: _size.width,
                                    height: 1,
                                    color: Color(0xFFECECEC),
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //TODO: 메인탭
                                    Row(
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 2, left: 20),
                                              child: Container(
                                                height: 40,
                                                child: ElevatedButton(
                                                  child: Text(
                                                    '${FriendDetailViewModel.mainTabNameListConst[0]}',
                                                    style: TextStyle(
                                                        color: (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                                            ? Color(0xFF111111)
                                                            : Color(0xFFc8c8c8),
                                                        fontWeight: (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontSize: 16),
                                                  ),
                                                  onPressed: () async{
                                                    HapticFeedback.lightImpact();
                                                    print('라이딩 통계로 전환');
                                                    _friendDetailViewModel.changeMainTab(0);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.only(top: 0),
                                                    minimumSize: Size(40, 10),
                                                    backgroundColor: Color(0xFFFFFFFF),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8)),
                                                    elevation: 0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 20),
                                              child: Container(
                                                width: _size.width / 2 - 20,
                                                height: 3,
                                                color:
                                                (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                                    ? Color(0xFF111111)
                                                    : Colors.transparent,
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Padding(
                                              padding: EdgeInsets.only(bottom: 2),
                                              child: Container(
                                                height: 40,
                                                child: ElevatedButton(
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(right: 20),
                                                    child: Text(
                                                      '${FriendDetailViewModel.mainTabNameListConst[1]}',
                                                      style: TextStyle(
                                                          color: (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                                              ? Color(0xFF111111)
                                                              : Color(0xFFc8c8c8),
                                                          fontWeight:
                                                          (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                                              ? FontWeight.bold
                                                              : FontWeight.normal,
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    HapticFeedback.lightImpact();
                                                    print('방명록으로 전환');
                                                    _friendDetailViewModel.changeMainTab(1);
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    padding: EdgeInsets.only(top: 0),
                                                    minimumSize: Size(40, 10),
                                                    backgroundColor: Color(0xFFFFFFFF),
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(8)),
                                                    elevation: 0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(right: 20),
                                              child: Container(
                                                width: _size.width / 2 - 20,
                                                height: 3,
                                                color:
                                                (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                                    ? Color(0xFF111111)
                                                    : Colors.transparent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 20,),
                                    //TODO: 라이딩 통계탭
                                    if(_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                      Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 16, left: 16),
                                            child: Text('${_friendDetailViewModel.seasonStartDate.substring(2, 4)}-${_friendDetailViewModel.seasonEndDate.substring(2, 4)} 시즌 정보',
                                              style: SDSTextStyle.extraBold.copyWith(
                                                  fontSize: 15,
                                                  color: SDSColor.gray900
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 16, right: 16),
                                            child: Container(
                                              padding: const EdgeInsets.only(left: 24, right: 20, top: 24, bottom: 24),
                                              decoration: BoxDecoration(
                                                color: SDSColor.snowliveBlue,
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 92,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 6),
                                                              child: Row(
                                                                children: [
                                                                  ExtendedImage.asset(
                                                                    'assets/imgs/icons/icon_circle_black.png',
                                                                    fit: BoxFit.cover,
                                                                    width: 16,
                                                                    height: 16,
                                                                  ),
                                                                  SizedBox(width: 4),
                                                                  Text(
                                                                    '총 점수',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 15,
                                                                      color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text('${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalScore}점',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                color: SDSColor.snowliveWhite,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Container(
                                                        width: 92,
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.only(bottom: 6),
                                                              child: Row(
                                                                children: [
                                                                  ExtendedImage.asset(
                                                                    'assets/imgs/icons/icon_circle_black.png',
                                                                    fit: BoxFit.cover,
                                                                    width: 16,
                                                                    height: 16,
                                                                  ),
                                                                  SizedBox(width: 4),
                                                                  Text(
                                                                    '통합 랭킹',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 15,
                                                                      color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              '${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallRank}등',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                color: SDSColor.snowliveWhite,
                                                                fontSize: 20,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  ExtendedImage.asset(
                                                    '${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTierIconUrl}',
                                                    fit: BoxFit.cover,
                                                    width: 70,
                                                    height: 70,
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 40,),
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 25, left: 0),
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: Row(
                                                        children: [
                                                          //TODO: 누적통계 버튼
                                                          GestureDetector(
                                                            onTap: (){
                                                              HapticFeedback.lightImpact();
                                                              _friendDetailViewModel.changeRidingStaticTab(0);
                                                            },
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(left: 16),
                                                              child: Container(
                                                                  decoration: BoxDecoration(
                                                                    color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[0])
                                                                        ? Color(0xFFD8E7FD)
                                                                        : Color(0xFFFFFFFF),
                                                                    borderRadius: BorderRadius.circular(30.0),
                                                                    border: Border.all(
                                                                        color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[0])
                                                                            ? Color(0xFFD8E7FD)
                                                                            : Color(0xFFDEDEDE)),
                                                                  ),
                                                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                  height: 33,
                                                                  child: Text('${FriendDetailViewModel.ridingStatisticsTabNameListConst[0]}',
                                                                    style: TextStyle(
                                                                        fontSize: 13,
                                                                        fontWeight: FontWeight.bold,
                                                                        color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[0])
                                                                            ? Color(0xFF3D83ED)
                                                                            : Color(0xFF777777)
                                                                    ),)
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 6),
                                                          //TODO: 일간통계 버튼
                                                          GestureDetector(
                                                            onTap: (){
                                                              HapticFeedback.lightImpact();
                                                              _friendDetailViewModel.changeRidingStaticTab(1);
                                                            },
                                                            child: Container(
                                                                decoration: BoxDecoration(
                                                                  color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                                                      ? Color(0xFFD8E7FD)
                                                                      : Color(0xFFFFFFFF),
                                                                  borderRadius: BorderRadius.circular(30.0),
                                                                  border: Border.all(
                                                                      color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                                                          ? Color(0xFFD8E7FD)
                                                                          : Color(0xFFDEDEDE)),
                                                                ),
                                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                height: 33,
                                                                child: Text('${FriendDetailViewModel.ridingStatisticsTabNameListConst[1]}',
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                                                          ? Color(0xFF3D83ED)
                                                                          : Color(0xFF777777)
                                                                  ),)
                                                            ),
                                                          ),
                                                          SizedBox(width: 6),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if(_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[0])
                                            Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 16),
                                                  child: Container(
                                                    padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                                    width: _size.width,
                                                    decoration: BoxDecoration(
                                                      color: SDSColor.blue50,
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text('라이딩 슬로프 종류',
                                                          style: SDSTextStyle.regular.copyWith(
                                                              color: SDSColor.gray900.withOpacity(0.5),
                                                              fontSize: 14
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding: const EdgeInsets.only(top: 4, bottom: 20),
                                                          child: Text('${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.length}',
                                                            style: SDSTextStyle.extraBold.copyWith(
                                                                color: SDSColor.gray900,
                                                                fontSize: 24
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.map<Widget>((data) {
                                                              String slopeName = data.slope;
                                                              int passCount = data.count;
                                                              double barWidthRatio = data.ratio;
                                                              return Padding(
                                                                padding: (data != _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.last)
                                                                    ? EdgeInsets.only(bottom: 8)
                                                                    : EdgeInsets.only(bottom: 0),
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                      width: 40,
                                                                      child: Text(
                                                                        slopeName,
                                                                        style: SDSTextStyle.bold.copyWith(
                                                                          fontSize: 11,
                                                                          color: SDSColor.gray900,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Container(
                                                                      height: 16,
                                                                      width: (_size.width - 148) * barWidthRatio,
                                                                      decoration: BoxDecoration(
                                                                          color: SDSColor.blue200,
                                                                          borderRadius: BorderRadius.only(
                                                                              topRight: Radius.circular(4),
                                                                              bottomRight: Radius.circular(4)
                                                                          )
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: (data == _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.first)
                                                                          ? EdgeInsets.only(left: 6)
                                                                          : EdgeInsets.only(left: 2),
                                                                      child: Container(
                                                                        width: 30,
                                                                        child: Column(
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(20),
                                                                                color: (data == _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.first)
                                                                                    ? SDSColor.gray900
                                                                                    : Colors.transparent,
                                                                              ),
                                                                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                              child: Text('$passCount',
                                                                                style: SDSTextStyle.extraBold.copyWith(
                                                                                  fontSize: 12,
                                                                                  fontWeight: (data == _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.first)
                                                                                      ? FontWeight.w900 : FontWeight.w300,
                                                                                  color: (data == _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.first)
                                                                                      ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList(),
                                                          )
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 16),
                                                  child: Container(
                                                    padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                                    width: _size.width,
                                                    decoration: BoxDecoration(
                                                      color: SDSColor.blue50,
                                                      borderRadius: BorderRadius.circular(16),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text('총 라이딩 횟수',
                                                              style: SDSTextStyle.regular.copyWith(
                                                                  color: SDSColor.gray900.withOpacity(0.5),
                                                                  fontSize: 14
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.only(top: 4, bottom: 20),
                                                              child: Text('${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalCount}회',
                                                                style: SDSTextStyle.extraBold.copyWith(
                                                                    color: SDSColor.gray900,
                                                                    fontSize: 24
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        (_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalCount != 0)
                                                            ? Container(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            crossAxisAlignment: CrossAxisAlignment.end,
                                                            children: _friendDetailViewModel.friendDetailModel.seasonRankingInfo.timeInfo.entries.map<Widget>((entry) {
                                                              String slotName = entry.key;
                                                              int passCount = entry.value;
                                                              int maxCount = _friendDetailViewModel.friendDetailModel.seasonRankingInfo.timeInfo_maxCount;
                                                              double barHeightRatio =  passCount/maxCount;
                                                              return Container(
                                                                width: 30,
                                                                child: Column(
                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                  children: [
                                                                    Container(
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(20),
                                                                        color: passCount == maxCount ? SDSColor.gray900 : Colors.transparent,
                                                                      ),
                                                                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                                      child: AutoSizeText(
                                                                        passCount != 0 ? '$passCount' : '',
                                                                        style: SDSTextStyle.bold.copyWith(
                                                                          fontSize: 12,
                                                                          color: passCount == maxCount ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                                                          fontWeight: passCount == maxCount ? FontWeight.w900 : FontWeight.w300,
                                                                        ),
                                                                        minFontSize: 6,
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.visible,
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.only(top: passCount == maxCount ? 6 : 0),
                                                                      child:
                                                                      Container(
                                                                        width: 16,
                                                                        height: 140 * barHeightRatio,
                                                                        decoration: BoxDecoration(
                                                                            color: SDSColor.snowliveBlue,
                                                                            borderRadius: BorderRadius.only(
                                                                                topRight: Radius.circular(4), topLeft: Radius.circular(4)
                                                                            )
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(top: 8),
                                                                      child: Container(
                                                                        width: 20,
                                                                        child: Text(
                                                                          slotName,
                                                                          style: SDSTextStyle.regular.copyWith(
                                                                            fontSize: 11,
                                                                            color: SDSColor.gray900,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList(),
                                                          ),
                                                        )
                                                            :Container(),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if(_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                            Column(
      children: [
        ProfilePageCalendar(),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                width: _size.width,
                decoration: BoxDecoration(
                  color: SDSColor.blue50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('라이딩 슬로프 종류',
                      style: SDSTextStyle.regular.copyWith(
                          color: SDSColor.gray900.withOpacity(0.5),
                          fontSize: 14
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 20),
                      child: Text(
                        (_friendDetailViewModel.selectedDailyIndex != -1 &&
                            _friendDetailViewModel.friendDetailModel.calendarInfo.length > _friendDetailViewModel.selectedDailyIndex)
                            ? '${_friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.length}'
                            : '0',
                        style: SDSTextStyle.extraBold.copyWith(
                            color: SDSColor.gray900,
                            fontSize: 24
                        ),
                      ),
                    ),
                    (_friendDetailViewModel.selectedDailyIndex != -1 &&
                        _friendDetailViewModel.friendDetailModel.calendarInfo.length > _friendDetailViewModel.selectedDailyIndex)
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.map<Widget>((data) {
                        String slopeName = data.slope;
                        int passCount = data.count;
                        double barWidthRatio = data.ratio;
                        return Padding(
                          padding: (data != _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.last)
                              ? EdgeInsets.only(bottom: 8)
                              : EdgeInsets.only(bottom: 0),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                child: Text(
                                  slopeName,
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 11,
                                    color: SDSColor.gray900,
                                  ),
                                ),
                              ),
                              Container(
                                height: 16,
                                width: (_size.width - 148) * barWidthRatio,
                                decoration: BoxDecoration(
                                    color: SDSColor.blue200,
                                    borderRadius: BorderRadius.only(
                                        topRight: Radius.circular(4),
                                        bottomRight: Radius.circular(4)
                                    )
                                ),
                              ),
                              Padding(
                                padding: (data == _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.first)
                                    ? EdgeInsets.only(left: 6)
                                    : EdgeInsets.only(left: 2),
                                child: Container(
                                  width: 30,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(20),
                                          color: (data == _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.first)
                                              ? SDSColor.gray900
                                              : Colors.transparent,
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                        child: Text('$passCount',
                                          style: SDSTextStyle.extraBold.copyWith(
                                            fontSize: 12,
                                            fontWeight: (data == _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.first)
                                                ? FontWeight.w900 : FontWeight.w300,
                                            color: (data == _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.first)
                                                ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: _size.height / 5,
                        ),
                        Container(
                          width: 48,
                          child: ExtendedImage.asset(
                            'assets/imgs/ranking/icon_ranking_nodata_2.png',
                            enableMemoryCache: true,
                            scale: 4,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text('라이딩 기록이 없어요',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 15,
                                fontWeight: FontWeight.normal
                            ),),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Container(
                padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                width: _size.width,
                decoration: BoxDecoration(
                  color: SDSColor.blue50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('라이딩 횟수',
                          style: SDSTextStyle.regular.copyWith(
                              color: SDSColor.gray900.withOpacity(0.5),
                              fontSize: 14
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 4, bottom: 20),
                          child: Text(
                            (_friendDetailViewModel.selectedDailyIndex != -1 &&
                                _friendDetailViewModel.friendDetailModel.calendarInfo.length > _friendDetailViewModel.selectedDailyIndex)
                                ? '${_friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].daily_total_count}회'
                                : '0회',
                            style: SDSTextStyle.extraBold.copyWith(
                                color: SDSColor.gray900,
                                fontSize: 24
                            ),
                          ),
                        ),
                      ],
                    ),
                    (_friendDetailViewModel.selectedDailyIndex != -1 &&
                        _friendDetailViewModel.friendDetailModel.calendarInfo.length > _friendDetailViewModel.selectedDailyIndex)
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].timeInfo.entries.map<Widget>((entry) {
                        String slotName = entry.key;
                        int passCount = entry.value;
                        int maxCount = _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].timeInfo_maxCount;
                        double barHeightRatio = passCount / maxCount;
                        return Container(
                          width: 30,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: passCount == maxCount ? SDSColor.gray900 : Colors.transparent,
                                ),
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                child: AutoSizeText(
                                  passCount != 0 ? '$passCount' : '',
                                  style: SDSTextStyle.bold.copyWith(
                                    fontSize: 12,
                                    color: passCount == maxCount ? SDSColor.snowliveWhite : SDSColor.gray900.withOpacity(0.4),
                                    fontWeight: passCount == maxCount ? FontWeight.w900 : FontWeight.w300,
                                  ),
                                  minFontSize: 6,
                                  maxLines: 1,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(top: passCount == maxCount ? 6 : 0),
                                child: Container(
                                  width: 16,
                                  height: 140 * barHeightRatio,
                                  decoration: BoxDecoration(
                                      color: SDSColor.snowliveBlue,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(4), topLeft: Radius.circular(4)
                                      )
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  width: 20,
                                  child: Text(
                                    slotName,
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 11,
                                      color: SDSColor.gray900,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    )
                        : Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: _size.height / 5,
                        ),
                        Container(
                          width: 48,
                          child: ExtendedImage.asset(
                            'assets/imgs/ranking/icon_ranking_nodata_2.png',
                            enableMemoryCache: true,
                            scale: 4,
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ),
                        Center(
                          child: Text('라이딩 기록이 없어요',
                            style: TextStyle(
                                color: Color(0xFF666666),
                                fontSize: 15,
                                fontWeight: FontWeight.normal
                            ),),
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
    ),],),
                                    if(_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16),
                                              child: Obx(()=>Column(
                                                children: [
                                                  (_friendDetailViewModel.friendsTalk.length >0)
                                                  ? Column(
                                                    children: [
                                                      ListView.builder(
                                                        padding: EdgeInsets.only(top: 4),
                                                        shrinkWrap: true,
                                                        physics: NeverScrollableScrollPhysics(),
                                                        itemCount: _friendDetailViewModel.friendsTalk.length,
                                                        itemBuilder: (context, index) {
                                                          final document = _friendDetailViewModel.friendsTalk[index];
                                                          DateTime updateTime = _friendDetailViewModel.friendsTalk[index].updateTime;
                                                          String formattedDate = DateFormat('yyyy.MM.dd').format(updateTime); // 원하는 형식으로 날짜 변환
                                                          return Column(
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                children: [
                                                                  if (document.authorInfo.profileImageUrlUser != "")
                                                                    GestureDetector(
                                                                      onTap: () async{
                                                                        await _friendDetailViewModel.fetchFriendDetailInfo(userId: _userViewModel.user.user_id, friendUserId: document.authorInfo.userId, season: _friendDetailViewModel.seasonDate);
                                                                        Get.toNamed(AppRoutes.friendDetail);
                                                                      },
                                                                      child: Container(
                                                                        width: 20,
                                                                        height: 20,
                                                                        decoration: BoxDecoration(
                                                                            color: Color(0xFFDFECFF),
                                                                            borderRadius: BorderRadius.circular(50)
                                                                        ),
                                                                        child: ExtendedImage.network(
                                                                          document.authorInfo.profileImageUrlUser,
                                                                          cache: true,
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
                                                                                  fit: BoxFit.cover,
                                                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                                              default:
                                                                                return null;
                                                                            }
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  if (document.authorInfo.profileImageUrlUser == "")
                                                                    GestureDetector(
                                                                      onTap: () async{
                                                                        await _friendDetailViewModel.fetchFriendDetailInfo(userId: _userViewModel.user.user_id, friendUserId: document.authorInfo.userId, season: _friendDetailViewModel.seasonDate);
                                                                        Get.toNamed(AppRoutes.friendDetail);
                                                                      },
                                                                      child: ExtendedImage.network(
                                                                        '${profileImgUrlList[0].default_round}',
                                                                        shape: BoxShape.circle,
                                                                        borderRadius:
                                                                        BorderRadius.circular(20),
                                                                        width: 20,
                                                                        height: 20,
                                                                        fit: BoxFit.cover,
                                                                      ),
                                                                    ),
                                                                  SizedBox(width: 12),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        document.authorInfo.displayName,
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
                                                                  Spacer(),
                                                                  //TODO: 댓글 더보기 메뉴_내 프로필 페이지인 경우 (삭제, 신고, 차단)
                                                                  if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id)
                                                                    GestureDetector(
                                                                      onTap: () =>
                                                                          showModalBottomSheet(
                                                                              enableDrag: false,
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return SafeArea(
                                                                                  child: Container(
                                                                                    height: 200,
                                                                                    child: Padding(
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
                                                                                                                        Navigator.pop(context);
                                                                                                                        await _friendDetailViewModel.deleteFriendsTalk(userId: _userViewModel.user.user_id, friendsTalkId: document.friendsTalkId);
                                                                                                                        await _friendDetailViewModel.fetchFriendsTalkList(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
                                                                                                                        print('삭제 완료');

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
                                                                                                                  await _friendDetailViewModel.reportFriendsTalk({
                                                                                                                    {
                                                                                                                      "user_id": _userViewModel.user.user_id,    //필수 - 신고자(나)
                                                                                                                      "friends_talk_id": document.friendsTalkId   //필수 - 신고할 친구톡id
                                                                                                                    }
                                                                                                                  });
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
                                                                                                                  Navigator.pop(context);
                                                                                                                  await _friendDetailViewModel.blockUser({
                                                                                                                    "user_id" : _userViewModel.user.user_id,    //필수 - 차단하는 사람(나)
                                                                                                                    "block_user_id" : document.authorInfo.userId   //필수 - 내가 차단할 사람
                                                                                                                  });
                                                                                                                  await _friendDetailViewModel.fetchFriendsTalkList(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
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
                                                                                  ),
                                                                                );
                                                                              }),
                                                                      child: Icon(
                                                                        Icons.more_horiz,
                                                                        color: Color(0xFFdedede),
                                                                        size: 20,
                                                                      ),
                                                                    ),
                                                                  //TODO: 댓글 더보기 메뉴_내 프로필 페이지가 아니고 내가 단 댓글이 아닌 경우 (신고, 차단)
                                                                  if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId != _userViewModel.user.user_id
                                                                  && document.authorInfo.userId != _userViewModel.user.user_id)
                                                                  GestureDetector(
                                                                    onTap: () =>
                                                                        showModalBottomSheet(
                                                                            enableDrag: false,
                                                                            context: context,
                                                                            builder: (context) {
                                                                              return SafeArea(
                                                                                child: Container(
                                                                                  height: 150,
                                                                                  child: Padding(
                                                                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                                                    child: Column(
                                                                                      children: [
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
                                                                                                                await _friendDetailViewModel.reportFriendsTalk({
                                                                                                                  {
                                                                                                                    "user_id": _userViewModel.user.user_id,    //필수 - 신고자(나)
                                                                                                                    "friends_talk_id": document.friendsTalkId   //필수 - 신고할 친구톡id
                                                                                                                  }
                                                                                                                });
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
                                                                                                                Navigator.pop(context);
                                                                                                                await _friendDetailViewModel.blockUser({
                                                                                                                  "user_id" : _userViewModel.user.user_id,    //필수 - 차단하는 사람(나)
                                                                                                                  "block_user_id" : document.authorInfo.userId   //필수 - 내가 차단할 사람
                                                                                                                });
                                                                                                                await _friendDetailViewModel.fetchFriendsTalkList(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
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
                                                                                ),
                                                                              );
                                                                            }),
                                                                    child: Icon(
                                                                      Icons.more_horiz,
                                                                      color: Color(0xFFdedede),
                                                                      size: 20,
                                                                    ),
                                                                  ),
                                                                  //TODO: 댓글 더보기 메뉴_내 프로필 페이지가 아니고 내가 단 댓글인 경우 (삭제)
                                                                  if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId != _userViewModel.user.user_id
                                                                      && document.authorInfo.userId == _userViewModel.user.user_id)
                                                                    GestureDetector(
                                                                      onTap: () =>
                                                                          showModalBottomSheet(
                                                                              enableDrag: false,
                                                                              context: context,
                                                                              builder: (context) {
                                                                                return SafeArea(
                                                                                  child: Container(
                                                                                    height: 100,
                                                                                    child: Padding(
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
                                                                                                                        Navigator.pop(context);
                                                                                                                        await _friendDetailViewModel.deleteFriendsTalk(userId: _userViewModel.user.user_id, friendsTalkId: document.friendsTalkId);
                                                                                                                        await _friendDetailViewModel.fetchFriendsTalkList(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
                                                                                                                        print('삭제 완료');

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
                                                                      child: Icon(
                                                                        Icons.more_horiz,
                                                                        color: Color(0xFFdedede),
                                                                        size: 20,
                                                                      ),
                                                                    ), // 친구 프로필 페이지이고 내가 단 댓글인 경우
                                                                ],
                                                              ),
                                                              Padding(
                                                                padding: const EdgeInsets.only(top: 10),
                                                                child: Row(
                                                                  children: [
                                                                    Expanded(
                                                                      child: Container(
                                                                        decoration: BoxDecoration(
                                                                          color: Color(0xFFF0F5FF),
                                                                          borderRadius: BorderRadius.circular(12),
                                                                        ),
                                                                        padding: EdgeInsets.all(10),
                                                                        constraints: BoxConstraints(
                                                                          maxWidth: _size.width * 0.75,
                                                                        ),
                                                                        width: double.infinity,
                                                                        child: Text(document.content,
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              color: Color(0xFF111111)
                                                                          ),),
                                                                      ),
                                                                    ),
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
                                                            'assets/imgs/icons/icon_friendsTalk_nodata.png',
                                                            width: 74,
                                                          ),
                                                          SizedBox(
                                                            height: 6,
                                                          ),
                                                          Text('아직 방명록이 없어요', style: TextStyle(
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
                                              ))
                                          ),
                                        ],),
                                    if(_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1]
                                        && _userViewModel.user.user_id != _friendDetailViewModel.friendDetailModel.friendUserInfo.userId)
                                      Container(
                                        color: Colors.white,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: TextFormField(
                                            key: _friendDetailViewModel.formKey,
                                            cursorColor: Color(0xff377EEA),
                                            controller: _friendDetailViewModel.textEditingController,
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
                                                    if (_friendDetailViewModel.textEditingController.text.trim().isEmpty) {
                                                      return;
                                                    }
                                                    await _friendDetailViewModel.uploadFriendsTalk(
                                                        {
                                                          "author_user_id": _userViewModel.user.user_id,
                                                          "friend_user_id": _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
                                                          "content": _friendDetailViewModel.textEditingController.text
                                                        }
                                                    );
                                                    await _friendDetailViewModel.fetchFriendsTalkList(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
                                                    FocusScope.of(context).unfocus();
                                                    _friendDetailViewModel.textEditingController.clear();
                                                  },
                                                  icon:  (_friendDetailViewModel.isSendButtonEnabled.value == false)
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
                                                hintText: '새로운 방명록 등록 시, 기존 방명록은 삭제됩니다.',
                                                contentPadding: EdgeInsets.only(
                                                    top: 2, bottom: 2, left: 16, right: 16),
                                                fillColor: Color(0xFFEFEFEF),
                                                hoverColor: Colors.transparent,
                                                filled: true,
                                                focusColor: Colors.transparent,
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Color(0xFFEFEFEF)),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                errorBorder:  OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.transparent),
                                                ),
                                                focusedBorder:  OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.transparent),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: Colors.transparent),
                                                  borderRadius: BorderRadius.circular(6),
                                                )),
                                            onChanged: (value) {
                                              _friendDetailViewModel.changefriendsTalkInputText(value);
                                            },
                                          ),
                                        ),
                                      )
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],),
                        if(_friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile == true &&
                        _friendDetailViewModel.friendDetailModel.friendUserInfo.userId != _userViewModel.user.user_id)
                          Center(
                            child: Column(
                              children: [
                                SizedBox(height: _size.height * 0.15,),
                                Image.asset(
                                  'assets/imgs/icons/icon_profile_lock.png',
                                  width: 74,
                                  height: 74,
                                ),
                                Text('프로필 비공개 유저입니다'),
                              ],
                            ),
                          )
                      ],
                    ))
                  ),
                ),
              ),
            ),
          ),
        )
    );
  }
}


