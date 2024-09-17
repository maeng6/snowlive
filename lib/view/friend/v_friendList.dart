import 'package:com.snowlive/routes/routes.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../screens/snowliveDesignStyle.dart';
import '../../viewmodel/vm_friendDetail.dart';
import '../../viewmodel/vm_friendList.dart';
import '../../viewmodel/vm_user.dart';

class FriendListView extends StatelessWidget {
  FriendListView({Key? key}) : super(key: key);

  final FriendListViewModel _friendListViewModel = Get.find<FriendListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    final double _statusBarSize = MediaQuery.of(context).padding.top;

    return Obx(() => Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        actions: [
          if (_friendListViewModel.friendsRequestList.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      Get.toNamed(AppRoutes.invitaionFriend);
                      await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
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
          if (_friendListViewModel.friendsRequestList.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      Get.toNamed(AppRoutes.invitaionFriend);
                      await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                    },
                    icon: Image.asset(
                      'assets/imgs/icons/icon_noti_off.png',
                      scale: 4,
                      width: 26,
                      height: 26,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFD6382B),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: IconButton(
              onPressed: () {
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
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: _statusBarSize + 58),
            GestureDetector(
              onTap: () async {
                await _friendListViewModel.resetSearchFriend();
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
                        Icon(Icons.search, color: Color(0xFF666666)),
                        SizedBox(width: 5),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '친구 검색',
                            style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 25),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () async{
                    Get.toNamed(AppRoutes.friendDetail);
                    await _friendDetailViewModel.fetchFriendDetailInfo(
                      userId: _userViewModel.user.user_id,
                      friendUserId: _userViewModel.user.user_id,
                      season: _friendDetailViewModel.seasonDate,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        (_userViewModel.user.profile_image_url_user != '')
                            ? Container(
                              width: 56,
                              child: ExtendedImage.network(
                            _userViewModel.user.profile_image_url_user,
                            shape: BoxShape.circle,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                              ),
                            )
                            : Container(
                              width: 56,
                              child: ExtendedImage.asset(
                            'assets/imgs/profile/img_profile_default_circle.png',
                            shape: BoxShape.circle,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                              ),
                            ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Container(
                            width: _size.width - 160,
                            child: Column(
                              mainAxisAlignment:  _userViewModel.user.state_msg != ''
                                  ? MainAxisAlignment.center
                                  : MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userViewModel.user.display_name,
                                  style: TextStyle(
                                    color: Color(0xFF111111),
                                    fontSize: 15,
                                  ),
                                ),
                                if (_userViewModel.user.state_msg != '')
                                  Text(
                                    _userViewModel.user.state_msg,
                                    style: TextStyle(
                                      color: Color(0xFF949494),
                                      fontSize: 13,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Divider(
                    color: SDSColor.gray50,
                    height: 32,
                    thickness: 1,
                  ),
                ),
                (_friendListViewModel.friendList.isEmpty)
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
                            color: Color(0xFF949494),
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                      Center(
                        child: Image.asset(
                          'assets/imgs/icons/icon_friend_add.png',
                          width: 72,
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: Text(
                          '등록된 친구가 없습니다',
                          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                        ),
                      ),
                      Center(
                        child: Text(
                          '친구를 검색해 추가해 보세요',
                          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                        ),
                      ),
                      SizedBox(height: 10),
                      Center(
                        child: OutlinedButton(
                          onPressed: () async {
                            await _friendListViewModel.resetSearchFriend();
                            Get.toNamed(AppRoutes.searchFriend);
                          },
                          child: Text(
                            '친구 추가하기',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF666666),
                              fontSize: 14,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 1, color: Color(0xFFDEDEDE)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
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
                            color: Color(0xFF949494),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Column(
                        children: _friendListViewModel.friendList.map((friend) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            child: GestureDetector(
                              onTap: () async {
                                Get.toNamed(AppRoutes.friendDetail);
                                await _friendDetailViewModel.fetchFriendDetailInfo(
                                  userId: _userViewModel.user.user_id,
                                  friendUserId: friend.friendInfo.userId,
                                  season: _friendDetailViewModel.seasonDate,
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      (friend.friendInfo.profileImageUrlUser.isNotEmpty)
                                          ? Stack(
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: (friend.friendInfo.withinBoundary == true &&
                                                      friend.friendInfo.revealWb == true)
                                                      ? Border.all(
                                                    color: SDSColor.snowliveBlue,
                                                    width: 2,
                                                  )
                                                      : Border.all(
                                                    color: SDSColor.gray100,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: ExtendedImage.network(
                                              friend.friendInfo.profileImageUrlUser,
                                              shape: BoxShape.circle,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                                ),
                                              ),
                                              if (friend.friendInfo.withinBoundary == true &&
                                                  friend.friendInfo.revealWb == true)
                                                Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  left: 0,
                                                  child: Center(
                                                    child: Image.asset(
                                                      'assets/imgs/icons/icon_badge_live.png',
                                                      width: 34,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          )
                                          : Stack(
                                            children: [
                                              Container(
                                                width: 48,
                                                height: 48,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: (friend.friendInfo.withinBoundary == true &&
                                                      friend.friendInfo.revealWb == true)
                                                      ? Border.all(
                                                    color: SDSColor.snowliveBlue,
                                                    width: 2,
                                                  )
                                                      : Border.all(
                                                    color: SDSColor.gray100,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: ExtendedImage.asset(
                                              'assets/imgs/profile/img_profile_default_circle.png',
                                              shape: BoxShape.circle,
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                                ),
                                              ),
                                              if (friend.friendInfo.withinBoundary == true &&
                                                  friend.friendInfo.revealWb == true)
                                                Positioned(
                                                  right: 0,
                                                  bottom: 0,
                                                  left: 0,
                                                  child: Center(
                                                    child: Image.asset(
                                                      'assets/imgs/icons/icon_badge_live.png',
                                                      width: 34,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10),
                                        child: Container(
                                          width: _size.width - 160,
                                          child: Column(
                                            mainAxisAlignment: friend.friendInfo.stateMsg.isEmpty
                                                ? MainAxisAlignment.center
                                                : MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                friend.friendInfo.displayName,
                                                style: TextStyle(
                                                  color: Color(0xFF111111),
                                                  fontSize: 15,
                                                ),
                                              ),
                                              if (friend.friendInfo.stateMsg.isNotEmpty)
                                                Text(
                                                  friend.friendInfo.stateMsg,
                                                  style: TextStyle(
                                                    color: Color(0xFF949494),
                                                    fontSize: 13,
                                                  ),
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
                                        GestureDetector(
                                          onTap: () async {
                                            await _friendDetailViewModel.toggleBestFriend(
                                              {"friend_id": friend.friendId},
                                            );
                                            await _friendListViewModel.fetchFriendList();
                                          },
                                          child: Icon(
                                            Icons.star_rounded,
                                            color: Color(0xFFFDAF04),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => showModalBottomSheet(
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return SafeArea(
                                                child: Container(
                                                  height: 120,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 14,
                                                    ),
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
                                                                  top: 30,
                                                                ),
                                                                elevation: 0,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                ),
                                                                buttonPadding: EdgeInsets.symmetric(
                                                                  horizontal: 20,
                                                                  vertical: 0,
                                                                ),
                                                                content: Text(
                                                                  '친구목록에서 삭제하시겠습니까?',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () async {
                                                                          Navigator.pop(context);
                                                                          await _friendListViewModel.deleteFriend(
                                                                            {"friend_id": friend.friendId},
                                                                          );
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Text(
                                                                          '확인',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Color(0xFF3D83ED),
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          child: Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 24),
                                                              child: Text(
                                                                '친구 삭제',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFFD63636),
                                                                ),
                                                              ),
                                                            ),
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
                                            Icons.more_vert,
                                            color: Color(0xFFdedede),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                      : Container(
                                    width: 56,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            await _friendDetailViewModel.toggleBestFriend(
                                              {"friend_id": friend.friendId},
                                            );
                                            await _friendListViewModel.fetchFriendList();
                                          },
                                          child: Icon(
                                            Icons.star_rounded,
                                            color: Color(0xFFdedede),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => showModalBottomSheet(
                                            enableDrag: false,
                                            context: context,
                                            builder: (context) {
                                              return SafeArea(
                                                child: Container(
                                                  height: 120,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 20.0,
                                                      vertical: 14,
                                                    ),
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
                                                                  top: 30,
                                                                ),
                                                                elevation: 0,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(10.0),
                                                                ),
                                                                buttonPadding: EdgeInsets.symmetric(
                                                                  horizontal: 20,
                                                                  vertical: 0,
                                                                ),
                                                                content: Text(
                                                                  '친구목록에서 삭제하시겠습니까?',
                                                                  style: TextStyle(
                                                                    fontWeight: FontWeight.w600,
                                                                    fontSize: 15,
                                                                  ),
                                                                ),
                                                                actions: [
                                                                  Row(
                                                                    mainAxisAlignment: MainAxisAlignment.end,
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
                                                                        ),
                                                                      ),
                                                                      TextButton(
                                                                        onPressed: () async {
                                                                          Navigator.pop(context);
                                                                          await _friendListViewModel.deleteFriend(
                                                                            {"friend_id": friend.friendId},
                                                                          );
                                                                          Navigator.pop(context);
                                                                        },
                                                                        child: Text(
                                                                          '확인',
                                                                          style: TextStyle(
                                                                            fontSize: 15,
                                                                            color: Color(0xFF3D83ED),
                                                                            fontWeight: FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          },
                                                          child: Center(
                                                            child: Padding(
                                                              padding: const EdgeInsets.only(top: 24),
                                                              child: Text(
                                                                '친구 삭제',
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  fontWeight: FontWeight.bold,
                                                                  color: Color(0xFFD63636),
                                                                ),
                                                              ),
                                                            ),
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
                                            Icons.more_vert,
                                            color: Color(0xFFdedede),
                                            size: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    ));
  }
}
