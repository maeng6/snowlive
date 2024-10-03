import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/view/friend/v_profilePageCalendar.dart';
import 'package:com.snowlive/view/v_profileImageScreen.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetailUpdate.dart';
import 'package:com.snowlive/viewmodel/resortHome/vm_alarmCenter.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class FriendDetailView extends StatefulWidget {
  @override
  _FriendDetailViewState createState() => _FriendDetailViewState();
}

class _FriendDetailViewState extends State<FriendDetailView> {
  FocusNode _textFocus = FocusNode();
  late GlobalKey<FormState> _formKey;


  @override
  void initState() {
    super.initState();
    // initState에서 GlobalKey 초기화
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _textFocus.dispose(); // FocusNode를 적절히 해제
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
    UserViewModel _userViewModel = Get.find<UserViewModel>();
    FriendDetailUpdateViewModel _friendDetailUpdateViewModel = Get.find<FriendDetailUpdateViewModel>();
    final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
    final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
    final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();
    final AlarmCenterViewModel _alarmCenterViewModel = Get.find<AlarmCenterViewModel>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 텍스트 필드 외부 클릭 시 포커스를 해제
        _textFocus.unfocus();
      },
      child: Obx(() => Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: SDSColor.snowliveWhite,
          foregroundColor: SDSColor.snowliveWhite,
          surfaceTintColor: SDSColor.snowliveWhite,
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
          // actions: [
          //   if (_friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id)
          //     GestureDetector(
          //       child: Padding(
          //         padding: const EdgeInsets.only(right: 16),
          //         child: Column(
          //           mainAxisAlignment: MainAxisAlignment.center,
          //           children: [
          //             (_friendDetailViewModel.isLoading == true)
          //                 ? SizedBox.shrink()
          //                 : Image.asset(
          //               'assets/imgs/icons/icon_edit_pencil.png',
          //               scale: 1,
          //               width: 26,
          //               height: 26,
          //             )
          //           ],
          //         ),
          //       ),
          //       onTap: () {
          //         _friendDetailUpdateViewModel.fetchFriendDetailUpdateData(
          //           displayName: _friendDetailViewModel.friendDetailModel.friendUserInfo.displayName,
          //           state_msg: _friendDetailViewModel.friendDetailModel.friendUserInfo.stateMsg,
          //           profileImageUrl: _friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser,
          //           selectedResortName: _friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResort,
          //           selectedResortIndex: _friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResortId - 1,
          //           selectedSkiOrBoard: _friendDetailViewModel.friendDetailModel.friendUserInfo.skiorboard,
          //           selectedSex: _friendDetailViewModel.friendDetailModel.friendUserInfo.sex,
          //           hideProfile: _friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile,
          //         );
          //         Get.toNamed(AppRoutes.friendDetailUpdate);
          //       },
          //     ),
          // ],
          elevation: 0.0,
          titleSpacing: 0,
          centerTitle: true,
          toolbarHeight: 44.0,
        ),
        body: RefreshIndicator(
          strokeWidth: 2,
          edgeOffset: 80,
          backgroundColor: SDSColor.snowliveBlue,
          color: SDSColor.snowliveWhite,
          onRefresh: () => _friendDetailViewModel.fetchFriendDetailInfo(
            userId: _userViewModel.user.user_id,
            friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
            season: _friendDetailViewModel.seasonDate,
          ),
          child: (_friendDetailViewModel.isLoading == true)
              ? Center(
            child: Container(
              height: 150,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Container(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              backgroundColor: SDSColor.gray100,
                              color: SDSColor.gray300.withOpacity(0.6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
              :Container(
            color: Colors.white,
            child: SafeArea(
              child: Obx(() => Stack(
                children: [
                  Container(
                    height: _size.height,
                    width: _size.width,
                    child: GestureDetector(
                      onTap: (){
                        FocusScope.of(context).unfocus();
                        _textFocus.unfocus();
                      },
                      child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //프사, 닉네임, 상태메세지, 친구등록버튼
                              Container(
                                height: 250,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      //프사
                                      (_friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser != '')
                                          ? GestureDetector(
                                        onTap: () {
                                          _textFocus.unfocus();
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Dialog(
                                                backgroundColor: Colors.transparent, // 다이얼로그 배경을 투명하게 설정
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Navigator.of(context).pop(); // 클릭 시 다이얼로그 닫기
                                                  },
                                                  child: Center(
                                                    child: PhotoView(
                                                      imageProvider: ExtendedNetworkImageProvider(
                                                        _friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser, // 이미지 URL 설정
                                                        cache: true, // 캐싱 옵션
                                                      ),
                                                      backgroundDecoration: const BoxDecoration(
                                                        color: Colors.transparent, // 배경을 투명으로 설정
                                                      ),
                                                      minScale: PhotoViewComputedScale.contained, // 최소 확대 비율
                                                      maxScale: PhotoViewComputedScale.covered * 7, // 최대 확대 비율
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Container(
                                            width: 82,
                                            height: 82,
                                            decoration: BoxDecoration(
                                                color: SDSColor.gray50,
                                                borderRadius: BorderRadius.circular(80),
                                                border: Border.all(
                                                    color: SDSColor.gray100
                                                )
                                            ),
                                            child: ExtendedImage.network(
                                              _friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser,
                                              enableMemoryCache: true,
                                              shape: BoxShape.circle,
                                              borderRadius: BorderRadius.circular(8),
                                              width: 82,
                                              height: 82,
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
                                                      width: 82,
                                                      height: 82,
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
                                          width: 82,
                                          height: 82,
                                          child: ClipOval(
                                            child: Image.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              width: 82,
                                              height: 82,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            //닉네임
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Text('${_friendDetailViewModel.friendDetailModel.friendUserInfo.displayName}',
                                                    style: SDSTextStyle.bold.copyWith(
                                                        fontSize: 20,
                                                        color: SDSColor.gray900
                                                    ),),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(top: 2),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    '${_friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResort}',
                                                    style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 13,
                                                      color: SDSColor.gray900,
                                                    ),
                                                  ),
                                                  if(_friendDetailViewModel.friendDetailModel.friendUserInfo.crewName != null)
                                                    GestureDetector(
                                                      onTap: () async{
                                                        _textFocus.unfocus();
                                                        Get.toNamed(AppRoutes.crewMain);
                                                        await _crewDetailViewModel.fetchCrewDetail(
                                                            _friendDetailViewModel.friendDetailModel.friendUserInfo.crewId,
                                                            _friendDetailViewModel.seasonDate
                                                        );
                                                        await _crewMemberListViewModel.fetchCrewMembers(crewId: _friendDetailViewModel.friendDetailModel.friendUserInfo.crewId);
                                                        if(_userViewModel.user.crew_id == _friendDetailViewModel.friendDetailModel.friendUserInfo.crewId)
                                                          await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                                                              _friendDetailViewModel.friendDetailModel.friendUserInfo.crewId,
                                                              '${DateTime.now().year}'
                                                          );

                                                      },//
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            ' · ${_friendDetailViewModel.friendDetailModel.friendUserInfo.crewName}',
                                                            style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 13,
                                                              color: SDSColor.gray900,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          Image.asset(
                                                            'assets/imgs/icons/icon_arrow_round_black.png',
                                                            fit: BoxFit.cover,
                                                            width: 15,
                                                            height: 15,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],),
                                            ),
                                            //상태메세지
                                            (_friendDetailViewModel.friendDetailModel.friendUserInfo.stateMsg != null)
                                                ? Padding(
                                              padding: EdgeInsets.only(top: 10),
                                              child: Container(
                                                child: Text('${_friendDetailViewModel.friendDetailModel.friendUserInfo.stateMsg}',
                                                  style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray500,
                                                  ),
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            )
                                                : SizedBox.shrink(),
                                            SizedBox(
                                              height: 16,
                                            ),
                                            //친구추가 버튼
                                            if(_userViewModel.user.user_id == _friendDetailViewModel.friendDetailModel.friendUserInfo.userId)
                                              ElevatedButton(
                                                onPressed: () async{

                                                  _friendDetailUpdateViewModel.fetchFriendDetailUpdateData(
                                                    displayName: _friendDetailViewModel.friendDetailModel.friendUserInfo.displayName,
                                                    state_msg: _friendDetailViewModel.friendDetailModel.friendUserInfo.stateMsg,
                                                    profileImageUrl: _friendDetailViewModel.friendDetailModel.friendUserInfo.profileImageUrlUser,
                                                    selectedResortName: _friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResort,
                                                    selectedResortIndex: _friendDetailViewModel.friendDetailModel.friendUserInfo.favoriteResortId - 1,
                                                    selectedSkiOrBoard: _friendDetailViewModel.friendDetailModel.friendUserInfo.skiorboard,
                                                    selectedSex: _friendDetailViewModel.friendDetailModel.friendUserInfo.sex,
                                                    hideProfile: _friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile,
                                                  );
                                                  Get.toNamed(AppRoutes.friendDetailUpdate);

                                                }, child: Text('프로필 수정',
                                                style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray900
                                                ),
                                              ),
                                                style: TextButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                                        side: BorderSide(color: SDSColor.gray100)
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 0),
                                                    elevation: 0,
                                                    splashFactory: InkRipple.splashFactory,
                                                    overlayColor: Colors.transparent,
                                                    minimumSize: Size(84, 34),
                                                    backgroundColor: Color(0xffffffff)),
                                              ), //프디페 = 내 프디페
                                            if(_userViewModel.user.user_id != _friendDetailViewModel.friendDetailModel.friendUserInfo.userId &&
                                                !_friendDetailViewModel.friendDetailModel.friendUserInfo.areWeFriend)
                                              ElevatedButton(
                                                onPressed: () async{
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
                                                                '친구등록 요청을 보내시겠습니까?',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900),
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
                                                                          CustomFullScreenDialog.showDialog();
                                                                          await _friendDetailViewModel.sendFriendRequest({
                                                                            "user_id": _userViewModel.user.user_id,    //필수 - 신청자 (나)
                                                                            "friend_user_id": _friendDetailViewModel.friendDetailModel.friendUserInfo.userId    //필수 - 신청받는사람
                                                                          });
                                                                          await _alarmCenterViewModel.updateNotification(
                                                                              _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
                                                                              total: true,
                                                                              friend: true
                                                                          );
                                                                        },
                                                                        child: Text('보내기',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Color(0xFF3D83ED),
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        )),
                                                                  ),
                                                                ),
                                                              ],
                                                              mainAxisAlignment: MainAxisAlignment.end,
                                                            ),
                                                          )
                                                        ],
                                                      ));
                                                }, child: Text('친구 추가',
                                                style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 13,
                                                    color: SDSColor.gray900
                                                ),
                                              ),
                                                style: TextButton.styleFrom(
                                                    shape: const RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(20)),
                                                        side: BorderSide(color: SDSColor.gray100)
                                                    ),
                                                    padding: EdgeInsets.symmetric(horizontal: 0),
                                                    elevation: 0,
                                                    splashFactory: InkRipple.splashFactory,
                                                    overlayColor: Colors.transparent,
                                                    minimumSize: Size(76, 34),
                                                    backgroundColor: Color(0xffffffff)),
                                              ), //내가 아니고, 친구도 아닐 때
                                            if(_userViewModel.user.user_id != _friendDetailViewModel.friendDetailModel.friendUserInfo.userId &&
                                                _friendDetailViewModel.friendDetailModel.friendUserInfo.areWeFriend)
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    child: Container(
                                                      height: 34,
                                                      width: 68,
                                                      decoration: BoxDecoration(
                                                        color: SDSColor.blue50,
                                                        borderRadius: BorderRadius.circular(20),
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          '내 친구',
                                                          style: SDSTextStyle.bold.copyWith(
                                                              fontSize: 13,
                                                              color: SDSColor.snowliveBlue
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap:() async{
                                                      _textFocus.unfocus();
                                                      CustomFullScreenDialog.showDialog();
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
                                                        width: 34,
                                                        height: 34,
                                                        fit: BoxFit.cover,
                                                      )
                                                          : Image.asset(
                                                        'assets/imgs/icons/icon_profile_bestfriend_on.png',  // 에셋 이미지 경로
                                                        width: 34,
                                                        height: 34,
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
                              ),
                              SizedBox(height: 20),

                              //통계, 방명록
                              if(_friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile == false
                                  || _friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id)
                                Column(children: [
                                  SafeArea(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          top: 43,
                                          child: Container(
                                            width: _size.width,
                                            height: 1,
                                            color: SDSColor.gray100,
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // 메인탭
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: 2, left: 20),
                                                      child: Container(
                                                        width: _size.width / 2 - 20,
                                                        height: 40,
                                                        child: ElevatedButton(
                                                          child: Text(
                                                            '${FriendDetailViewModel.mainTabNameListConst[0]}',
                                                            style: SDSTextStyle.extraBold.copyWith(
                                                                color: (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                                                    ? SDSColor.gray900
                                                                    : SDSColor.gray500,
                                                                fontWeight: (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                                                    ? FontWeight.w900
                                                                    : FontWeight.normal,
                                                                fontSize: 15),
                                                          ),
                                                          onPressed: () async{
                                                            HapticFeedback.lightImpact();
                                                            print('라이딩 통계로 전환');
                                                            _friendDetailViewModel.changeMainTab(0);
                                                          },
                                                          style: ElevatedButton.styleFrom(
                                                            padding: EdgeInsets.only(top: 0),
                                                            minimumSize: Size(40, 10),
                                                            backgroundColor: Colors.transparent,
                                                            overlayColor: Colors.transparent,
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
                                                        width: _size.width / 2 - 100,
                                                        height: 2,
                                                        color:
                                                        (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                                            ? SDSColor.gray900
                                                            : Colors.transparent,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  children: [
                                                    Padding(
                                                      padding: EdgeInsets.only(bottom: 2),
                                                      child: Container(
                                                        width: _size.width / 2 - 20,
                                                        height: 40,
                                                        child: ElevatedButton(
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(right: 20),
                                                            child: Text(
                                                              '${FriendDetailViewModel.mainTabNameListConst[1]}',
                                                              style: SDSTextStyle.extraBold.copyWith(
                                                                  color: (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                                                      ? SDSColor.gray900
                                                                      : SDSColor.gray500,
                                                                  fontWeight: (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                                                      ? FontWeight.w900
                                                                      : FontWeight.normal,
                                                                  fontSize: 15),
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
                                                            overlayColor: Colors.transparent,
                                                            backgroundColor: Colors.transparent,
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
                                                        width: _size.width / 2 - 100,
                                                        height: 2,
                                                        color:
                                                        (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                                            ? SDSColor.gray900
                                                            : Colors.transparent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            //라이딩 통계탭
                                            if(_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[0])
                                              (_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalCount != 0)
                                                  ?Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 30,),
                                                  //타이틀
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 12, left: 20),
                                                    child: Text('${_friendDetailViewModel.seasonStartDate.substring(2, 4)}-${_friendDetailViewModel.seasonEndDate.substring(2, 4)} 시즌 정보',
                                                      style: SDSTextStyle.extraBold.copyWith(
                                                          fontSize: 14,
                                                          color: SDSColor.gray900
                                                      ),
                                                    ),
                                                  ),
                                                  // 시즌 정보 상단박스 디자인
                                                  Padding(
                                                    padding: const EdgeInsets.only(left: 16, right: 16),
                                                    child: Container(
                                                      height: 92,
                                                      padding: const EdgeInsets.only(left: 24, right: 20, top: 18, bottom: 18),
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
                                                                width: _size.width / 3 - 24,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom: 2),
                                                                      child: Text(
                                                                        '총 점수',
                                                                        style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 13,
                                                                          color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text('${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalScore.toInt()}점',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        color: SDSColor.snowliveWhite,
                                                                        fontSize: 18,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                width: 16,
                                                              ),
                                                              Container(
                                                                width: _size.width / 3 - 24,
                                                                child: Column(
                                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(bottom: 2),
                                                                      child: Text(
                                                                        '통합 랭킹',
                                                                        style: SDSTextStyle.regular.copyWith(
                                                                          fontSize: 13,
                                                                          color: SDSColor.snowliveWhite.withOpacity(0.7),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Text(
                                                                      '${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallRank}등',
                                                                      style: SDSTextStyle.bold.copyWith(
                                                                        color: SDSColor.snowliveWhite,
                                                                        fontSize: 18,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          ExtendedImage.network(
                                                            '${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTierIconUrl}',
                                                            fit: BoxFit.cover,
                                                            enableMemoryCache: true,
                                                            width: 66,
                                                            height: 66,
                                                            loadStateChanged: (ExtendedImageState state) {
                                                              switch (state.extendedImageLoadState) {
                                                                case LoadState.loading:
                                                                // 로딩 중일 때 로딩 인디케이터를 표시
                                                                  return Center(child: Container(
                                                                    width: 24,
                                                                    height: 24,
                                                                    child: CircularProgressIndicator(
                                                                      strokeWidth: 4,
                                                                      backgroundColor: SDSColor.blue600,
                                                                      color: SDSColor.blue800.withOpacity(0.6),
                                                                    ),
                                                                  ),);
                                                                case LoadState.completed:
                                                                // 로딩이 완료되었을 때 이미지 반환
                                                                  return state.completedWidget;
                                                                case LoadState.failed:
                                                                // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                                  return Container();
                                                              }
                                                            },
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(height: 40,),
                                                  // 누적통계, 일간통계 칩 버튼
                                                  Padding(
                                                    padding: const EdgeInsets.only(bottom: 10, left: 4),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  // 누적통계 버튼
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
                                                                                ? SDSColor.gray900
                                                                                : SDSColor.snowliveWhite,
                                                                            borderRadius: BorderRadius.circular(30.0),
                                                                            border: Border.all(
                                                                                color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[0])
                                                                                    ? SDSColor.gray900
                                                                                    : SDSColor.gray200),
                                                                          ),
                                                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                          height: 36,
                                                                          child: Text('${FriendDetailViewModel.ridingStatisticsTabNameListConst[0]}',
                                                                            style: SDSTextStyle.bold.copyWith(
                                                                                fontSize: 13,
                                                                                color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[0])
                                                                                    ? SDSColor.snowliveWhite
                                                                                    : SDSColor.gray900
                                                                            ),)
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(width: 8),
                                                                  //TODO: 일간통계 버튼
                                                                  GestureDetector(
                                                                    onTap: (){
                                                                      HapticFeedback.lightImpact();
                                                                      _friendDetailViewModel.changeRidingStaticTab(1);
                                                                    },
                                                                    child: Container(
                                                                        decoration: BoxDecoration(
                                                                          color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                                                              ? SDSColor.gray900
                                                                              : SDSColor.snowliveWhite,
                                                                          borderRadius: BorderRadius.circular(30.0),
                                                                          border: Border.all(
                                                                              color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                                                                  ? SDSColor.gray900
                                                                                  : SDSColor.gray200),
                                                                        ),
                                                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                                        height: 36,
                                                                        child: Text('${FriendDetailViewModel.ridingStatisticsTabNameListConst[1]}',
                                                                          style: SDSTextStyle.bold.copyWith(
                                                                              fontSize: 13,
                                                                              color: (_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                                                                  ? SDSColor.snowliveWhite
                                                                                  : SDSColor.gray900
                                                                          ),)
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId
                                                                  == _userViewModel.user.user_id)
                                                                Padding(
                                                                  padding: EdgeInsets.only(right: 14),
                                                                  child:
                                                                  GestureDetector(
                                                                    onTap: (){
                                                                      Get.toNamed(AppRoutes.rankingIndivHistoryHome);
                                                                    } ,
                                                                    child: Row(
                                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                                      children: [
                                                                        IconButton(
                                                                          highlightColor: Colors.transparent,
                                                                          onPressed: () async{
                                                                            Get.toNamed(AppRoutes.rankingIndivHistoryHome);
                                                                          },
                                                                          icon: Image.asset(
                                                                            'assets/imgs/icons/icon_data_history.png',
                                                                            width: 26,
                                                                            height: 26,
                                                                          ),
                                                                        ),
                                                                        Transform.translate(
                                                                          offset: Offset(-6, 0),
                                                                          child: Text('라이딩 기록실',
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                  fontSize: 14,
                                                                                  color: SDSColor.gray900
                                                                              )),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  // 누적통계
                                                  if(_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[0])
                                                    Padding(
                                                      padding: EdgeInsets.only(left: 16, right: 16, top: 2),
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.only(top: 24, right: 20, left: 20, bottom: 30),
                                                            width: _size.width,
                                                            decoration: BoxDecoration(
                                                              color: SDSColor.blue50,
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text('이번 시즌 탄 슬로프',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      color: SDSColor.gray900.withOpacity(0.5),
                                                                      fontSize: 14
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets.only(top: 4),
                                                                  child: Text('${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.length}',
                                                                    style: SDSTextStyle.extraBold.copyWith(
                                                                        color: SDSColor.gray900,
                                                                        fontSize: 30
                                                                    ),
                                                                  ),
                                                                ),
                                                                if(_friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.length != 0)
                                                                  Container(
                                                                      child: Column(
                                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                                        children: _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.map<Widget>((data) {
                                                                          String slopeName = data.slope;
                                                                          int passCount = data.count;
                                                                          double barWidthRatio = data.ratio;
                                                                          return Padding(
                                                                            padding: (data != _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.last)
                                                                                ? EdgeInsets.only(bottom: 8, top: 4)
                                                                                : EdgeInsets.only(bottom: 0, top: 4),
                                                                            child: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Container(
                                                                                  width: 44,
                                                                                  child: Text(
                                                                                    slopeName,
                                                                                    style: SDSTextStyle.regular.copyWith(
                                                                                      fontSize: 11,
                                                                                      color: SDSColor.sBlue600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 14,
                                                                                  width: (_size.width - 166) * barWidthRatio,
                                                                                  decoration: BoxDecoration(
                                                                                      color:
                                                                                      (data == _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.first)
                                                                                          ? SDSColor.snowliveBlue
                                                                                          : SDSColor.blue200,
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
                                                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                                                                                          child: Text('$passCount',
                                                                                            style: SDSTextStyle.extraBold.copyWith(
                                                                                              fontSize: 12,
                                                                                              fontWeight: (data == _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.first)
                                                                                                  ? FontWeight.w900 : FontWeight.w300,
                                                                                              color: (data == _friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.first)
                                                                                                  ? SDSColor.snowliveWhite : SDSColor.gray900,
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
                                                                if(_friendDetailViewModel.friendDetailModel.seasonRankingInfo.countInfo.length == 0)
                                                                  Center(
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.only(bottom: 30),
                                                                      child: Column(
                                                                        children: [
                                                                          Image.asset(
                                                                            'assets/imgs/imgs/img_resoreHome_nodata.png',
                                                                            fit: BoxFit.cover,
                                                                            width: 72,
                                                                            height: 72,
                                                                          ),
                                                                          Text('라이딩 기록이 없어요',
                                                                            style: SDSTextStyle.regular.copyWith(
                                                                                fontSize: 14,
                                                                                color: SDSColor.gray600
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  )
                                                              ],
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
                                                                        padding: const EdgeInsets.only(top: 4, bottom: 10),
                                                                        child: Text('${_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalCount}',
                                                                          style: SDSTextStyle.extraBold.copyWith(
                                                                              color: SDSColor.gray900,
                                                                              fontSize: 30
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  if (_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalCount != 0)
                                                                    Container(
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
                                                                                AutoSizeText(
                                                                                  passCount != 0 ? '$passCount' : '',
                                                                                  style: SDSTextStyle.regular.copyWith(
                                                                                    fontSize: 12,
                                                                                    color: SDSColor.gray900,
                                                                                  ),
                                                                                  minFontSize: 6,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.visible,
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(top: 4),
                                                                                  child:
                                                                                  Container(
                                                                                    width: 16,
                                                                                    height: 140 * barHeightRatio,
                                                                                    decoration: BoxDecoration(
                                                                                        color: SDSColor.blue200,
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
                                                                                          color: SDSColor.sBlue600,
                                                                                          height: 1.2
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                      ),
                                                                    ),
                                                                  if (_friendDetailViewModel.friendDetailModel.seasonRankingInfo.overallTotalCount == 0)
                                                                    Center(
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.only(bottom: 30),
                                                                        child: Column(
                                                                          children: [
                                                                            Image.asset(
                                                                              'assets/imgs/imgs/img_resoreHome_nodata.png',
                                                                              fit: BoxFit.cover,
                                                                              width: 72,
                                                                              height: 72,
                                                                            ),
                                                                            Text('라이딩 기록이 없어요',
                                                                              style: SDSTextStyle.regular.copyWith(
                                                                                  fontSize: 14,
                                                                                  color: SDSColor.gray600
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  //일간통계
                                                  if(_friendDetailViewModel.ridingStatisticsTabName == FriendDetailViewModel.ridingStatisticsTabNameListConst[1])
                                                    Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 16),
                                                      child: Column(
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
                                                                      Text('이용 슬로프',
                                                                        style: SDSTextStyle.regular.copyWith(
                                                                            color: SDSColor.gray900.withOpacity(0.5),
                                                                            fontSize: 14
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 4),
                                                                        child: Text(
                                                                          (_friendDetailViewModel.selectedDailyIndex != -1 &&
                                                                              _friendDetailViewModel.friendDetailModel.calendarInfo.length > _friendDetailViewModel.selectedDailyIndex)
                                                                              ? '${_friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.length}'
                                                                              : '0',
                                                                          style: SDSTextStyle.extraBold.copyWith(
                                                                              color: SDSColor.gray900,
                                                                              fontSize: 30
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
                                                                                ? EdgeInsets.only(bottom: 8, top: 4)
                                                                                : EdgeInsets.only(bottom: 0, top: 4),
                                                                            child: Row(
                                                                              children: [
                                                                                Container(
                                                                                  width: 44,
                                                                                  child: Text(
                                                                                    slopeName,
                                                                                    style: SDSTextStyle.regular.copyWith(
                                                                                      fontSize: 11,
                                                                                      color: SDSColor.sBlue600,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                Container(
                                                                                  height: 14,
                                                                                  width: (_size.width - 166) * barWidthRatio,
                                                                                  decoration: BoxDecoration(
                                                                                      color:
                                                                                      (data == _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.first)
                                                                                          ? SDSColor.snowliveBlue : SDSColor.blue200,
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
                                                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                                                          child: Text('$passCount',
                                                                                            style: SDSTextStyle.extraBold.copyWith(
                                                                                              fontSize: 12,
                                                                                              fontWeight: (data == _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.first)
                                                                                                  ? FontWeight.w900 : FontWeight.w300,
                                                                                              color: (data == _friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].dailyInfo.first)
                                                                                                  ? SDSColor.snowliveWhite : SDSColor.gray900,
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
                                                                          : Center(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(bottom: 30),
                                                                          child: Column(
                                                                            children: [
                                                                              Image.asset(
                                                                                'assets/imgs/imgs/img_resoreHome_nodata.png',
                                                                                fit: BoxFit.cover,
                                                                                width: 72,
                                                                                height: 72,
                                                                              ),
                                                                              Text('라이딩 기록이 없어요',
                                                                                style: SDSTextStyle.regular.copyWith(
                                                                                    fontSize: 14,
                                                                                    color: SDSColor.gray600
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
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
                                                                            padding: const EdgeInsets.only(top: 4, bottom: 10),
                                                                            child: Text(
                                                                              (_friendDetailViewModel.selectedDailyIndex != -1 &&
                                                                                  _friendDetailViewModel.friendDetailModel.calendarInfo.length > _friendDetailViewModel.selectedDailyIndex)
                                                                                  ? '${_friendDetailViewModel.friendDetailModel.calendarInfo[_friendDetailViewModel.selectedDailyIndex].daily_total_count}'
                                                                                  : '0',
                                                                              style: SDSTextStyle.extraBold.copyWith(
                                                                                  color: SDSColor.gray900,
                                                                                  fontSize: 30
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
                                                                                AutoSizeText(
                                                                                  passCount != 0 ? '$passCount' : '',
                                                                                  style: SDSTextStyle.regular.copyWith(
                                                                                    fontSize: 12,
                                                                                    color: SDSColor.gray900,
                                                                                  ),
                                                                                  minFontSize: 6,
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.visible,
                                                                                ),
                                                                                Padding(
                                                                                  padding: EdgeInsets.only(top: 4),
                                                                                  child: Container(
                                                                                    width: 16,
                                                                                    height: 140 * barHeightRatio,
                                                                                    decoration: BoxDecoration(
                                                                                        color: SDSColor.blue200,
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
                                                                                          color: SDSColor.sBlue600,
                                                                                          height: 1.2
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          );
                                                                        }).toList(),
                                                                      )
                                                                          : Center(
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.only(bottom: 30),
                                                                          child: Column(
                                                                            children: [
                                                                              Image.asset(
                                                                                'assets/imgs/imgs/img_resoreHome_nodata.png',
                                                                                fit: BoxFit.cover,
                                                                                width: 72,
                                                                                height: 72,
                                                                              ),
                                                                              Text('라이딩 기록이 없어요',
                                                                                style: SDSTextStyle.regular.copyWith(
                                                                                    fontSize: 14,
                                                                                    color: SDSColor.gray600
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  SizedBox(
                                                    height: 40,
                                                  )
                                                ],)
                                                  :Padding(
                                                padding: const EdgeInsets.all(20),
                                                child: Container(
                                                  height: _size.height - 570,
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Image.asset(
                                                          'assets/imgs/icons/icon_nodata.png',
                                                          width: 74,
                                                        ),
                                                        SizedBox(
                                                          height: 4,
                                                        ),
                                                        Text('라이딩 기록이 없어요.',
                                                          style: SDSTextStyle.regular.copyWith(
                                                              fontSize: 14,
                                                              color: SDSColor.gray500),),

                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            // 방명록
                                            if(_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1])
                                              Container(
                                                child: Padding(
                                                    padding: EdgeInsets.symmetric(horizontal: 16),
                                                    child: Obx(()=>Column(
                                                      children: [
                                                        (_friendDetailViewModel.friendsTalk.length >0)
                                                            ? Column(
                                                          children: [
                                                            RefreshIndicator(
                                                              strokeWidth: 2,
                                                              edgeOffset: -50,
                                                              backgroundColor: SDSColor.snowliveBlue,
                                                              color: SDSColor.snowliveWhite,
                                                              onRefresh: () => _friendDetailViewModel.fetchFriendsTalkList_refresh(
                                                                userId: _userViewModel.user.user_id,
                                                                friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
                                                              ),
                                                              child:
                                                              (_friendDetailViewModel.isLoadingFriendsTalk == true)
                                                                  ? Center(
                                                                child: Container(
                                                                  height: 150,
                                                                  child: Column(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Center(
                                                                        child: Container(
                                                                          width: 24,
                                                                          height: 24,
                                                                          child: CircularProgressIndicator(
                                                                            strokeWidth: 4,
                                                                            backgroundColor: SDSColor.gray100,
                                                                            color: SDSColor.gray300.withOpacity(0.6),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                                  : ListView.builder(
                                                                padding: EdgeInsets.only(top: 30),
                                                                shrinkWrap: true,
                                                                physics: NeverScrollableScrollPhysics(),
                                                                itemCount: _friendDetailViewModel.friendsTalk.length,
                                                                itemBuilder: (context, index) {
                                                                  final document = _friendDetailViewModel.friendsTalk[index];
                                                                  DateTime updateTime = _friendDetailViewModel.friendsTalk[index].updateTime;
                                                                  String formattedDate = GetDatetime().getAgoString(updateTime.toString());

                                                                  return Column(
                                                                    children: [
                                                                      Row(
                                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                                        children: [
                                                                          if (document.authorInfo.profileImageUrlUser != "")
                                                                            GestureDetector(
                                                                              onTap: () async{
                                                                                _textFocus.unfocus();
                                                                                Get.toNamed(AppRoutes.friendDetail);
                                                                                await _friendDetailViewModel.fetchFriendDetailInfo(userId: _userViewModel.user.user_id, friendUserId: document.authorInfo.userId, season: _friendDetailViewModel.seasonDate);
                                                                              },
                                                                              child: Container(
                                                                                width: 24,
                                                                                height: 24,
                                                                                decoration: BoxDecoration(
                                                                                    color: Color(0xFFDFECFF),
                                                                                    borderRadius: BorderRadius.circular(50),
                                                                                    border: Border.all(
                                                                                        color: SDSColor.gray100,
                                                                                        width: 1
                                                                                    )
                                                                                ),
                                                                                child: ExtendedImage.network(
                                                                                  document.authorInfo.profileImageUrlUser,
                                                                                  cache: true,
                                                                                  shape: BoxShape.circle,
                                                                                  borderRadius:
                                                                                  BorderRadius.circular(20),
                                                                                  width: 24,
                                                                                  height: 24,
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
                                                                                          width: 24,
                                                                                          height: 24,
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
                                                                                _textFocus.unfocus();
                                                                                Get.toNamed(AppRoutes.friendDetail);
                                                                                await _friendDetailViewModel.fetchFriendDetailInfo(userId: _userViewModel.user.user_id, friendUserId: document.authorInfo.userId, season: _friendDetailViewModel.seasonDate);
                                                                              },
                                                                              child: ExtendedImage.network(
                                                                                '${profileImgUrlList[0].default_round}',
                                                                                shape: BoxShape.circle,
                                                                                borderRadius:
                                                                                BorderRadius.circular(20),
                                                                                width: 24,
                                                                                height: 24,
                                                                                fit: BoxFit.cover,
                                                                              ),
                                                                            ),
                                                                          SizedBox(width: 8),
                                                                          Row(
                                                                            children: [
                                                                              Text(
                                                                                document.authorInfo.displayName,
                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 13,
                                                                                    color: SDSColor.gray900
                                                                                ),),
                                                                              SizedBox(width: 4),
                                                                              Text(formattedDate,
                                                                                style: SDSTextStyle.regular.copyWith(
                                                                                    fontSize: 13,
                                                                                    color: SDSColor.gray500
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Spacer(),
                                                                          // 댓글 더보기 메뉴_내 프로필 페이지인 경우 (삭제, 신고, 차단)
                                                                          if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId == _userViewModel.user.user_id)
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                _textFocus.unfocus();
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
                                                                                                      child: Text('신고하기',
                                                                                                        style: SDSTextStyle.bold.copyWith(
                                                                                                          fontSize: 15,
                                                                                                          color: SDSColor.gray900,
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
                                                                                                                    style: SDSTextStyle.bold.copyWith(
                                                                                                                        fontSize: 15,
                                                                                                                        color: SDSColor.gray900),
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
                                                                                                                            )),
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
                                                                                                                              await _friendDetailViewModel.reportFriendsTalk(
                                                                                                                                  {
                                                                                                                                    "user_id": _userViewModel.user.user_id.toString(),    //필수 - 신고자(나)
                                                                                                                                    "friends_talk_id": document.friendsTalkId   //필수 - 신고할 친구톡id
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
                                                                                                            content:  Container(
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
                                                                                                                            onPressed: () async{
                                                                                                                              Navigator.pop(context);
                                                                                                                              Navigator.pop(context);
                                                                                                                              CustomFullScreenDialog.showDialog();
                                                                                                                              await _userViewModel.block_user({
                                                                                                                                "user_id" : _userViewModel.user.user_id,    //필수 - 차단하는 사람(나)
                                                                                                                                "block_user_id" : document.authorInfo.userId   //필수 - 내가 차단할 사람
                                                                                                                              });
                                                                                                                              await _friendDetailViewModel.fetchFriendsTalkList_refresh(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
                                                                                                                            },
                                                                                                                            child: Text('숨기기',
                                                                                                                              style: SDSTextStyle.bold.copyWith(
                                                                                                                                fontSize: 17,
                                                                                                                                color: SDSColor.snowliveBlue,
                                                                                                                              ),
                                                                                                                            )),
                                                                                                                      ),
                                                                                                                    )
                                                                                                                  ],
                                                                                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                ),
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
                                                                                                        '방명록 삭제하기',
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
                                                                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                                            elevation: 0,
                                                                                                            backgroundColor: SDSColor.snowliveWhite,
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
                                                                                                                              await _friendDetailViewModel.deleteFriendsTalk(userId: _userViewModel.user.user_id, friendsTalkId: document.friendsTalkId);
                                                                                                                              print('삭제 완료');
                                                                                                                              await _friendDetailViewModel.fetchFriendsTalkList_afterFriendTalk(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
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
                                                                                                        borderRadius: BorderRadius.circular(10)),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      );
                                                                                    });
                                                                              },
                                                                              child: Icon(
                                                                                Icons.more_horiz,
                                                                                color: SDSColor.gray300,
                                                                                size: 20,
                                                                              ),
                                                                            ),
                                                                          // 댓글 더보기 메뉴_내 프로필 페이지가 아니고 내가 단 댓글이 아닌 경우 (신고, 차단)
                                                                          if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId != _userViewModel.user.user_id
                                                                              && document.authorInfo.userId != _userViewModel.user.user_id)
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                _textFocus.unfocus();
                                                                                showModalBottomSheet(
                                                                                    enableDrag: false,
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return SafeArea(
                                                                                        child: Container(
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
                                                                                                        child: Text('신고하기',
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
                                                                                                                      style: TextStyle(
                                                                                                                          fontWeight: FontWeight.w600,
                                                                                                                          fontSize: 15),
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
                                                                                                                              )),
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
                                                                                                                                CustomFullScreenDialog.showDialog();
                                                                                                                                await _friendDetailViewModel.reportFriendsTalk(
                                                                                                                                    {
                                                                                                                                      "user_id": _userViewModel.user.user_id.toString(),    //필수 - 신고자(나)
                                                                                                                                      "friends_talk_id": document.friendsTalkId   //필수 - 신고할 친구톡id
                                                                                                                                    }
                                                                                                                                );
                                                                                                                                Navigator.pop(context);
                                                                                                                              },
                                                                                                                              style: TextButton.styleFrom(
                                                                                                                                backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                                splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                              ),
                                                                                                                              child: Text(
                                                                                                                                '신고하기',
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
                                                                                                              content:  Container(
                                                                                                                height: 80,
                                                                                                                child: Column(
                                                                                                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                                                                                                              onPressed: () {Navigator.pop(context);},
                                                                                                                              style: TextButton.styleFrom(
                                                                                                                                backgroundColor: Colors.transparent, // 배경색 투명
                                                                                                                                splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                                                              ),
                                                                                                                              child: Text('취소',
                                                                                                                                style: SDSTextStyle.bold.copyWith(
                                                                                                                                  fontSize: 17,
                                                                                                                                  color: SDSColor.gray500,
                                                                                                                                ),
                                                                                                                              )),
                                                                                                                        ),
                                                                                                                      ),
                                                                                                                      SizedBox(
                                                                                                                        width: 10,
                                                                                                                      ),
                                                                                                                      Expanded(
                                                                                                                        child: Container(
                                                                                                                          child: TextButton(
                                                                                                                              onPressed: () async{
                                                                                                                                Navigator.pop(context);
                                                                                                                                Navigator.pop(context);
                                                                                                                                CustomFullScreenDialog.showDialog();
                                                                                                                                await _userViewModel.block_user({
                                                                                                                                  "user_id" : _userViewModel.user.user_id,    //필수 - 차단하는 사람(나)
                                                                                                                                  "block_user_id" : document.authorInfo.userId   //필수 - 내가 차단할 사람
                                                                                                                                });
                                                                                                                                await _friendDetailViewModel.fetchFriendsTalkList_afterFriendTalk(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
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
                                                                                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                                                                                  ),
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
                                                                                        ),
                                                                                      );
                                                                                    });
                                                                              },
                                                                              child: Icon(
                                                                                Icons.more_horiz,
                                                                                color: SDSColor.gray300,
                                                                                size: 20,
                                                                              ),
                                                                            ),
                                                                          // 댓글 더보기 메뉴_내 프로필 페이지가 아니고 내가 단 댓글인 경우 (삭제)
                                                                          if(_friendDetailViewModel.friendDetailModel.friendUserInfo.userId != _userViewModel.user.user_id
                                                                              && document.authorInfo.userId == _userViewModel.user.user_id)
                                                                            GestureDetector(
                                                                              onTap: () {
                                                                                _textFocus.unfocus();
                                                                                showModalBottomSheet(
                                                                                    enableDrag: false,
                                                                                    isScrollControlled: true,
                                                                                    backgroundColor: Colors.transparent,
                                                                                    context: context,
                                                                                    builder: (context) {
                                                                                      return SafeArea(
                                                                                        child: Container(
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
                                                                                                          '방명록 삭제하기',
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
                                                                                                              contentPadding: EdgeInsets.only(bottom: 0, left: 28, right: 28, top: 36),
                                                                                                              elevation: 0,
                                                                                                              backgroundColor: SDSColor.snowliveWhite,
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
                                                                                                                                await _friendDetailViewModel.deleteFriendsTalk(userId: _userViewModel.user.user_id, friendsTalkId: document.friendsTalkId);
                                                                                                                                await _friendDetailViewModel.fetchFriendsTalkList_afterFriendTalk(userId: _userViewModel.user.user_id, friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId);
                                                                                                                                print('삭제 완료');
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
                                                                                                          borderRadius: BorderRadius.circular(10)),
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
                                                                              child: Icon(
                                                                                Icons.more_horiz,
                                                                                color: SDSColor.gray300,
                                                                                size: 20,
                                                                              ),
                                                                            ), // 친구 프로필 페이지이고 내가 단 댓글인 경우
                                                                        ],
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(top: 6, bottom: 20),
                                                                        child: Row(
                                                                          children: [
                                                                            Expanded(
                                                                              child: Container(
                                                                                decoration: BoxDecoration(
                                                                                  color: SDSColor.blue50,
                                                                                  borderRadius: BorderRadius.circular(12),
                                                                                ),
                                                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                                                width: double.infinity,
                                                                                child: Text(document.content,
                                                                                  style: SDSTextStyle.regular.copyWith(
                                                                                      fontSize: 14,
                                                                                      color: SDSColor.gray900
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
                                                            ),
                                                            SizedBox(
                                                              height: 90,
                                                            )
                                                          ],
                                                        )
                                                            : Padding(
                                                          padding: const EdgeInsets.all(20),
                                                          child: Container(
                                                            height: _size.height - 570,
                                                            child: Center(
                                                              child: Column(
                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                children: [
                                                                  Image.asset(
                                                                    'assets/imgs/icons/icon_friendsTalk_nodata.png',
                                                                    width: 74,
                                                                  ),
                                                                  SizedBox(
                                                                    height: 4,
                                                                  ),
                                                                  Text('방명록에 안부 인사를 남겨보세요!',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                        fontSize: 14,
                                                                        color: SDSColor.gray500),),

                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    )
                                                    )
                                                ),
                                              ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],),

                              // 프로필 비공개
                              if(_friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile == true &&
                                  _friendDetailViewModel.friendDetailModel.friendUserInfo.userId != _userViewModel.user.user_id)
                                Container(
                                  width: _size.width,
                                  height: _size.height - _statusBarSize - 44 - 250 - 20,
                                  color: SDSColor.gray50,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        'assets/imgs/icons/icon_profile_lock.png',
                                        width: 64,
                                        height: 64,
                                      ),
                                      Text('프로필 비공개 유저입니다'),
                                    ],
                                  ),
                                )
                            ],
                          )
                      ),
                    ),
                  ),
                  // 텍폼필
                  (_friendDetailViewModel.mainTabName == FriendDetailViewModel.mainTabNameListConst[1] &&
                      _userViewModel.user.user_id != _friendDetailViewModel.friendDetailModel.friendUserInfo.userId &&
                      _friendDetailViewModel.friendDetailModel.friendUserInfo.hideProfile == false)
                      ? Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Stack(
                      children: [
                        Container(
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: TextFormField(
                              key: _formKey,
                              controller: _friendDetailViewModel.textEditingController,
                              focusNode: _textFocus, // FocusNode 추가
                              cursorColor: SDSColor.snowliveBlue,
                              cursorHeight: 16,
                              cursorWidth: 2,
                              style: SDSTextStyle.regular.copyWith(fontSize: 15),
                              enableSuggestions: false,
                              autocorrect: false,
                              textInputAction: TextInputAction.newline,
                              decoration: InputDecoration(
                                errorMaxLines: 2,
                                errorStyle: SDSTextStyle.regular.copyWith(fontSize: 12, color: SDSColor.red),
                                labelStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                hintStyle: SDSTextStyle.regular.copyWith(color: SDSColor.gray400, fontSize: 14),
                                hintText: '방명록을 남겨주세요.',
                                contentPadding: EdgeInsets.only(top: 10, bottom: 10, left: 12, right: 50),
                                fillColor: SDSColor.gray50,
                                hoverColor: SDSColor.snowliveBlue,
                                focusColor: SDSColor.snowliveBlue,
                                filled: true,
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                suffixIcon: IconButton(
                                  splashColor: Colors.transparent,
                                  onPressed: () async {
                                    if (_friendDetailViewModel.textEditingController.text.trim().isEmpty) {
                                      return;
                                    }
                                    CustomFullScreenDialog.showDialog();
                                    await _friendDetailViewModel.uploadFriendsTalk({
                                      "author_user_id": _userViewModel.user.user_id,
                                      "friend_user_id": _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
                                      "content": _friendDetailViewModel.textEditingController.text,
                                    });
                                    CustomFullScreenDialog.cancelDialog();
                                    await _friendDetailViewModel.fetchFriendsTalkList_afterFriendTalk(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId: _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
                                    );
                                    _textFocus.unfocus(); // 메시지 전송 후 포커스 해제
                                    _friendDetailViewModel.textEditingController.clear();
                                    await _alarmCenterViewModel.updateNotification(
                                        _friendDetailViewModel.friendDetailModel.friendUserInfo.userId,
                                        total: true
                                    );
                                  },
                                  icon: (_friendDetailViewModel.isSendButtonEnabled.value == false)
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
                                _friendDetailViewModel.changefriendsTalkInputText(value);
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          left: 0,
                          child: Container(
                            height: 1,
                            width: _size.width,
                            color: SDSColor.gray100,
                          ),
                        ),
                      ],
                    ),
                  )
                      : Container(),
                ],
              )),
            ),
          ),
        ),
      )),
    );
  }
}




