import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/routes.dart';
import '../../viewmodel/vm_friendDetail.dart';
import '../../viewmodel/vm_friendList.dart';
import '../../viewmodel/vm_user.dart';

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
            return Column(
              children: [
                Container(
              height: 80,
              child: Center(
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                  leading:  (friend.friendUserInfo.profileImageUrlUser.isNotEmpty)
                      ? GestureDetector(
                    onTap: () async{
                      await _friendDetailViewModel.fetchFriendDetailInfo(
                        userId: _userViewModel.user.user_id,
                        friendUserId: friend.friendUserId,
                        season: _friendDetailViewModel.seasonDate,
                      );
                      Get.toNamed(AppRoutes.friendDetail);
                    },
                    child: Container(
                      width: 56,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                              fit: StackFit.loose,
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                      color: Color(0xFFDFECFF),
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
                              ]),
                        ],
                      ),
                    ),
                  )
                      : GestureDetector(
                    onTap: () async{
                      await _friendDetailViewModel.fetchFriendDetailInfo(
                        userId: _userViewModel.user.user_id,
                        friendUserId: friend.friendUserId,
                        season: _friendDetailViewModel.seasonDate,
                      );
                      Get.toNamed(AppRoutes.friendDetail);
                    },
                    child: Container(
                      width: 56,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Stack(
                            fit: StackFit.loose,
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
                        ],
                      ),
                    ),
                  ),
                  title: Transform.translate(
                    offset: Offset(-20, 0),
                    child: Text(
                      friend.friendUserInfo.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  trailing: Container(
                    width: 134,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: (){
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    color: Colors.white,
                                    height: 180,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20.0),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Text(
                                            '요청을 취소하시겠습니까?',
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF111111)),
                                          ),
                                          SizedBox(
                                            height: 30,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text(
                                                    '취소',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                      splashFactory: InkRipple
                                                          .splashFactory,
                                                      elevation: 0,
                                                      minimumSize:
                                                      Size(100, 56),
                                                      backgroundColor:
                                                      Color(0xff555555),
                                                      padding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 0)),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    await _friendDetailViewModel.deleteFriend(
                                                        {
                                                          "friend_id": friend.friendId    //필수 - 수락할 친구요청id(user_id 아님에 주의)
                                                        }
                                                    );
                                                    await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                                                  },
                                                  child: Text(
                                                    '확인',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 15,
                                                        fontWeight:
                                                        FontWeight.bold),
                                                  ),
                                                  style: TextButton.styleFrom(
                                                      splashFactory: InkRipple
                                                          .splashFactory,
                                                      elevation: 0,
                                                      minimumSize:
                                                      Size(100, 56),
                                                      backgroundColor:
                                                      Color(0xff2C97FB),
                                                      padding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 0)),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                });
                          }, child: Text('취소', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF949494)),),
                          style: ElevatedButton.styleFrom(
                              minimumSize: Size(58, 32),
                              backgroundColor: Color(0xFFFFFFFF),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              side: BorderSide(
                                  color: Color(0xFFDEDEDE)
                              )
                          ),),
                      ],
                    ),
                  ),
                ),
              ),
            ),
                if (index != _friendListViewModel.friendsRequestList.length - 1)
                  Container(
                    color: Color(0xFFF5F5F5),
                    height: 1,
                    width: _size.width -32,
                  )
              ],
            );
          },
        ))
    );
  }
}
