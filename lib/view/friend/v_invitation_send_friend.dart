import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendFriendRequestView extends StatefulWidget {
  const SendFriendRequestView({Key? key}) : super(key: key);

  @override
  State<SendFriendRequestView> createState() => _SendFriendRequestViewState();
}

class _SendFriendRequestViewState extends State<SendFriendRequestView> {

  FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        body: Obx(()=>ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 0),
          itemCount: _friendListViewModel.myRequestList.length,
          itemBuilder: (BuildContext context, int index) {
            var friend = _friendListViewModel.myRequestList[index];
            return Padding(
              padding: EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Container(
                height: 44,
                child: Center(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0),
                    leading:  (friend.friendUserInfo.profileImageUrlUser.isNotEmpty)
                        ? GestureDetector(
                      onTap: () async{
                        Get.toNamed(AppRoutes.friendDetail);
                        await _friendDetailViewModel.fetchFriendDetailInfo(
                          userId: _userViewModel.user.user_id,
                          friendUserId: friend.friendUserId,
                          season: _friendDetailViewModel.seasonDate,
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                            color: SDSColor.gray50,
                            borderRadius: BorderRadius.circular(50)
                        ),
                        alignment: Alignment.centerLeft,
                        child: ExtendedImage.network(
                          '${friend.friendUserInfo.profileImageUrlUser}',
                          enableMemoryCache: true,
                          shape: BoxShape.circle,
                          borderRadius: BorderRadius.circular(8),
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
                                return ExtendedImage.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
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
                    )
                        : GestureDetector(
                      onTap: () async{
                        Get.toNamed(AppRoutes.friendDetail);
                        await _friendDetailViewModel.fetchFriendDetailInfo(
                          userId: _userViewModel.user.user_id,
                          friendUserId: friend.friendUserId,
                          season: _friendDetailViewModel.seasonDate,
                        );
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              child: ExtendedImage.asset('assets/imgs/profile/img_profile_default_circle.png',
                                enableMemoryCache:
                                true,
                                shape: BoxShape.circle,
                                borderRadius:
                                BorderRadius.circular(8),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    title: Text(
                      friend.friendUserInfo.displayName,
                      style: SDSTextStyle.regular.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900,
                      ),
                    ),
                    trailing: Container(
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: (){


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
                                            '보낸 요청을 취소하시겠어요?',
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
                                                      CustomFullScreenDialog.showDialog();
                                                      await _friendListViewModel.deleteFriend(
                                                          {
                                                            "friend_id": friend.friendId    //필수 - 수락할 친구요청id(user_id 아님에 주의)
                                                          }
                                                      );
                                                      await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);

                                                    },
                                                    style: TextButton.styleFrom(
                                                      backgroundColor: Colors.transparent, // 배경색 투명
                                                      splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                    ),
                                                    child: Text('취소하기',
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

                            }, child: Text('취소',
                            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                              minimumSize: Size(36, 32),
                              backgroundColor: SDSColor.snowliveWhite,
                              side: BorderSide(
                                  color: SDSColor.gray200
                              ),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100)),
                            ),),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
                ],
              ),
            );
          },
        ))
    );
  }
}
