import 'package:com.snowlive/routes/routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controller/friends/vm_streamController_friend.dart';
import '../../../controller/user/vm_userModelController.dart';
import '../viewmodel/vm_friendDetail.dart';
import '../viewmodel/vm_friendList.dart';
import '../viewmodel/vm_user.dart';

class FriendListView extends StatefulWidget {
  const FriendListView({Key? key}) : super(key: key);

  @override
  State<FriendListView> createState() => _FriendListViewState();
}

class _FriendListViewState extends State<FriendListView> {

  FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          if(_friendListViewModel.friendsRequestList.length == 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed(AppRoutes.invitaionFriend);
                    },
                    icon: Image.asset(
                      'assets/imgs/icons/icon_noti_off.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                  ),
                ],
              ),
            ),
          if(_friendListViewModel.friendsRequestList.length > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () async{
                      Get.toNamed(AppRoutes.invitaionFriend);
                    },
                    icon: Image.asset(
                      'assets/imgs/icons/icon_noti_off.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                  ),
                  //TODO:알림센터DB구현하기
                  Positioned(  // draw a red marble
                      top: 6,
                      right: 0,
                      child:
                      (true)
                          ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                        decoration: BoxDecoration(
                          color: Color(0xFFD6382B),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('NEW',
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFFFFFF)
                          ),

                        ),
                      )
                          :
                      Container()
                    // new Icon(Icons.brightness_1, size: 6.0,
                    //     color:
                    //     (alarmDocs[0]['newInvited_friend'] == true)
                    //         ?Color(0xFFD32F2F):Colors.white),
                  )
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: (){
                Get.toNamed(AppRoutes.settingFriend);
              },
              icon: Image.asset(
                'assets/imgs/icons/icon_settings.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
            ),
          )
        ],
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
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text(
          '친구',
          style: TextStyle(
              color: Color(0xFF111111),
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: _statusBarSize + 58,
            ),
            //TODO:친구 검색
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.searchFriend);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xFFEFEFEF),
                  ),
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Color(0xFF666666),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '친구 검색',
                            style:
                            TextStyle(fontSize: 15, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            //TODO:친구 리스트
            Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (_friendListViewModel.friendList.length == 0)
                        ? Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '친구',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: Color(0xFF949494)),
                            ),
                          ),
                          SizedBox(height: 100,),
                          Center(
                            child: Image.asset('assets/imgs/icons/icon_friend_add.png',
                              width: 72,
                            ),
                          ),
                          SizedBox(height: 10),
                          Center(
                            child: Text(
                              '등록된 친구가 없습니다',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666)),
                            ),
                          ),
                          Center(
                            child: Text(
                              '친구를 검색해 추가해 보세요',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF666666)),
                            ),
                          ),
                          SizedBox(height: 10,),
                          Center(
                            child: OutlinedButton(
                              onPressed: () {
                                //Get.to(()=>SearchUserPage());
                              },
                              child: Text('친구 추가하기',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF666666),
                                    fontSize: 14
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      width: 1,
                                      color: Color(0xFFDEDEDE)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)
                                  )// 버튼 윤곽선의 색과 두께를 설정
                              ),
                            )
                            ,
                          )
                        ],
                      ),
                    )
                        : Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '친구 ${_friendListViewModel.friendList.length}',
                              style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                  color: Color(0xFF949494)),
                            ),
                          ),
                          SizedBox(height: 10),
                          Column(
                            children: _friendListViewModel.friendList.map((friend) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                                child: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () async{
                                    await _friendDetailViewModel.fetchFriendDetailInfo(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId: friend.friendInfo.userId,
                                      season: _friendDetailViewModel.seasonDate,
                                    );
                                    Get.toNamed(AppRoutes.friendDetail);
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          (friend.friendInfo.profileImageUrlUser.isNotEmpty)
                                          //TODO: 라이브온 뱃지처리하기
                                              ? Container(
                                            width: 56,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Stack(
                                                    fit: StackFit.loose,
                                                    children: [
                                                      Container(
                                                        width: 48,
                                                        height: 48,
                                                        decoration: BoxDecoration(
                                                            color: Color(0xFFDFECFF),
                                                            borderRadius: BorderRadius.circular(50)
                                                        ),
                                                        alignment: Alignment.center,
                                                        child: ExtendedImage.network(
                                                          '${friend.friendInfo.profileImageUrlUser}',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 48,
                                                          height: 48,
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
                                                                  width: 48,
                                                                  height: 48,
                                                                  fit: BoxFit.cover,
                                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                              default:
                                                                return null;
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ]),
                                              ],
                                            ),
                                          )
                                              : Container(
                                            width: 56,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Stack(
                                                  fit: StackFit.loose,
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.center,
                                                      child: ExtendedImage.asset('assets/imgs/profile/img_profile_default_circle.png',
                                                        enableMemoryCache:
                                                        true,
                                                        shape: BoxShape.circle,
                                                        borderRadius:
                                                        BorderRadius.circular(8),
                                                        width: 48,
                                                        height: 48,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Container(
                                              width: _size.width - 160,
                                              child: Column(
                                                mainAxisAlignment: friend.friendInfo.stateMsg == ''
                                                    ? MainAxisAlignment.center
                                                    : MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text('${friend.friendInfo.stateMsg}',
                                                    style: TextStyle(
                                                        color: Color(0xFF111111),
                                                        fontWeight: FontWeight.normal,
                                                        fontSize: 15),
                                                  ),
                                                  if (friend.friendInfo.stateMsg == '')
                                                    SizedBox(height: 0)
                                                  else
                                                    Text(
                                                      '${friend.friendInfo.stateMsg}',
                                                      style: TextStyle(
                                                          color: Color(0xFF949494),
                                                          fontWeight: FontWeight.normal,
                                                          fontSize: 13),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      (friend.bestFriend)
                                          ? Container(
                                        width: 56,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            //TODO:친친버튼 메서드처리하기
                                            GestureDetector(
                                                onTap: () async {
                                                },
                                                child: Icon(
                                                  Icons.star_rounded,
                                                  color: Color(0xFFFDAF04),
                                                )),
                                            //TODO:삭제버튼 메서드처리하기
                                            GestureDetector(
                                              onTap: () => showModalBottomSheet(
                                                  enableDrag: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return SafeArea(
                                                      child: Container(
                                                          height: 120,
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14),
                                                            child: Column(
                                                              children: [
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      Get.dialog(
                                                                          AlertDialog(
                                                                            contentPadding: EdgeInsets.only(bottom: 0, left: 20, right: 20, top: 30),
                                                                            elevation: 0,
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(10.0)),
                                                                            buttonPadding: EdgeInsets.symmetric(
                                                                                horizontal: 20,
                                                                                vertical: 0),
                                                                            content:
                                                                            Text(
                                                                              '친구목록에서 삭제하시겠습니까?',
                                                                              style: TextStyle(
                                                                                  fontWeight:
                                                                                  FontWeight.w600,
                                                                                  fontSize: 15),
                                                                            ),
                                                                            actions: [
                                                                              Row(
                                                                                children: [
                                                                                  TextButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                        Get.back();
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
                                                                                mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                              )
                                                                            ],
                                                                          ));
                                                                    },
                                                                    child: Center(
                                                                      child:
                                                                      Padding(
                                                                        padding: const EdgeInsets
                                                                            .only(
                                                                            top:
                                                                            24),
                                                                        child:
                                                                        Text(
                                                                          '친구 삭제',
                                                                          style:
                                                                          TextStyle(
                                                                              fontSize:
                                                                              15,
                                                                              fontWeight:
                                                                              FontWeight.bold,
                                                                              color: Color(0xFFD63636)
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                          )),
                                                    );
                                                  }),
                                              child: Icon(
                                                Icons.more_vert,
                                                color: Color(0xFFdedede),
                                                size: 24,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                          : Container(
                                        width: 56,
                                        child: Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            //TODO:친친버튼 메서드처리하기
                                            GestureDetector(
                                                onTap: () async {
                                                },
                                                child: Icon(
                                                  Icons.star_rounded,
                                                  color: Color(0xFFdedede),
                                                )),
                                            //TODO:삭제버튼 메서드처리하기
                                            GestureDetector(
                                              onTap: () => showModalBottomSheet(
                                                  enableDrag: false,
                                                  context: context,
                                                  builder: (context) {
                                                    return SafeArea(
                                                      child: Container(
                                                          height: 120,
                                                          child: Padding(
                                                            padding:
                                                            const EdgeInsets.symmetric(
                                                                horizontal: 20.0,
                                                                vertical: 14),
                                                            child: Column(
                                                              children: [
                                                                GestureDetector(
                                                                    onTap: () {
                                                                      Get.dialog(
                                                                          AlertDialog(
                                                                            contentPadding: EdgeInsets.only(
                                                                                bottom: 0,
                                                                                left: 20,
                                                                                right: 20,
                                                                                top: 30),
                                                                            elevation: 0,
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius:
                                                                                BorderRadius.circular(10.0)),
                                                                            buttonPadding: EdgeInsets.symmetric(
                                                                                horizontal: 20,
                                                                                vertical: 0),
                                                                            content:
                                                                            Text(
                                                                              '친구목록에서 삭제하시겠습니까?',
                                                                              style: TextStyle(
                                                                                  fontWeight:
                                                                                  FontWeight.w600,
                                                                                  fontSize: 15),
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
                                                                                mainAxisAlignment:
                                                                                MainAxisAlignment.end,
                                                                              )
                                                                            ],
                                                                          ));
                                                                    },
                                                                    child: Center(
                                                                      child:
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top: 24),
                                                                        child: Text(
                                                                          '친구 삭제',
                                                                          style: TextStyle(
                                                                              fontSize: 15,
                                                                              fontWeight:
                                                                              FontWeight.bold,
                                                                              color: Color(0xFFD63636)
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                          )),
                                                    );
                                                  }),
                                              child: Icon(
                                                Icons.more_vert,
                                                color: Color(0xFFdedede),
                                                size: 24,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ), //친구목록
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    )
                  ],
                )
          ],
        ),
      ),
    );
  }
}
