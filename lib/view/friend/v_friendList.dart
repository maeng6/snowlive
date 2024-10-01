import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

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
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_friendListViewModel.friendsRequestList.isEmpty)
            IconButton(
              highlightColor: Colors.transparent,
              onPressed: () async {
                Get.toNamed(AppRoutes.invitaionFriend);
                await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
              },
              icon: Image.asset(
                'assets/imgs/icons/icon_alarm_resortHome.png',
                scale: 4,
                width: 26,
                height: 26,
              ),
            ),
          if (_friendListViewModel.friendsRequestList.isNotEmpty)
            Stack(
              children: [
                IconButton(
                  highlightColor: Colors.transparent,
                  onPressed: () async {
                    Get.toNamed(AppRoutes.invitaionFriend);
                    await _friendListViewModel.fetchFriendRequestList(_userViewModel.user.user_id);
                  },
                  icon: Image.asset(
                    'assets/imgs/icons/icon_alarm_resortHome.png',
                    scale: 4,
                    width: 26,
                    height: 26,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: SDSColor.red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        'N',
                        style: SDSTextStyle.bold.copyWith(
                          fontSize: 12,
                          color: SDSColor.snowliveWhite,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: IconButton(
              highlightColor: Colors.transparent,
              onPressed: () async{
                CustomFullScreenDialog.showDialog();
                await _friendListViewModel.fetchBlockUserList();
                CustomFullScreenDialog.cancelDialog();
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
        toolbarHeight: 44,
        title: Text(
          '친구',
          style: SDSTextStyle.extraBold.copyWith(
              color: SDSColor.gray900,
              fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        strokeWidth: 2,
        edgeOffset: 70,
        backgroundColor: SDSColor.snowliveWhite,
        color: SDSColor.snowliveBlue,
        onRefresh: () async{
          await _friendListViewModel.fetchFriendList(
          );
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: _statusBarSize + 44),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () async {
                    await _friendListViewModel.resetSearchFriend();
                    _friendListViewModel.setSearchFriendSuccess(false);
                    Get.toNamed(AppRoutes.searchFriend);
                  },
                  child: Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: SDSColor.gray50,
                      ),
                      height: 40,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Image.asset('assets/imgs/icons/icon_search.png',
                              width: 16,),
                            SizedBox(
                              width: 6,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 1),
                              child: Text(
                                '친구 검색',
                                style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray400),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 14),
              (_friendListViewModel.isLoading == true)
                  ? Container(
                height: 150,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        backgroundColor: SDSColor.snowliveWhite,
                        color: SDSColor.snowliveBlue,
                      ),
                    ),
                  ],
                ),
              )
                  :
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
                              ? Stack(
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: (_userViewModel.user.within_boundary == true &&
                                      _userViewModel.user.reveal_wb == true)
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
                                  _userViewModel.user.profile_image_url_user,
                                  shape: BoxShape.circle,
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (_userViewModel.user.within_boundary == true &&
                                  _userViewModel.user.reveal_wb == true)
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
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: (_userViewModel.user.within_boundary == true &&
                                      _userViewModel.user.reveal_wb == true)
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
                                  width: 56,
                                  height: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              if (_userViewModel.user.within_boundary == true &&
                                  _userViewModel.user.reveal_wb == true)
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
                              width: _size.width - 98,
                              child: Column(
                                mainAxisAlignment:  _userViewModel.user.state_msg != ''
                                    ? MainAxisAlignment.center
                                    : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _userViewModel.user.display_name,
                                    style: SDSTextStyle.regular.copyWith(
                                      color: SDSColor.gray900,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (_userViewModel.user.state_msg != '' && _userViewModel.user.state_msg != null)
                                    Text(
                                      _userViewModel.user.state_msg,
                                      style: SDSTextStyle.regular.copyWith(
                                        color: SDSColor.gray500,
                                        fontSize: 14,
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
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(
                      color: SDSColor.gray50,
                      height: 48,
                      thickness: 1,
                    ),
                  ),
                  (_friendListViewModel.friendList.isEmpty)
                      ? Container(
                    height: _size.height - 320,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            '친구',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray900,
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
                        SizedBox(height: 6),
                        Center(
                          child: Text(
                            '친구를 검색해 추가해 보세요',
                            style: SDSTextStyle.regular.copyWith(fontSize: 14, color: SDSColor.gray500),
                          ),
                        ),
                        SizedBox(height: 12),
                        Center(
                          child: Container(
                            width: 100,
                            height: 36,
                            child: OutlinedButton(
                              onPressed: () async {
                                await _friendListViewModel.resetSearchFriend();
                                Get.toNamed(AppRoutes.searchFriend);
                              },
                              child: Text(
                                '친구 추가하기',
                                style: SDSTextStyle.bold.copyWith(
                                  color: SDSColor.gray900,
                                  fontSize: 14,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                side: BorderSide(width: 1, color: SDSColor.gray200),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
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
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 13,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Column(
                          children: _friendListViewModel.friendList.map((friend) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
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
                                                  style: SDSTextStyle.regular.copyWith(
                                                    color: SDSColor.gray900,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                if (friend.friendInfo.stateMsg.isNotEmpty)
                                                  Text(
                                                    friend.friendInfo.stateMsg,
                                                    style: SDSTextStyle.regular.copyWith(
                                                      color: SDSColor.gray500,
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
                                      width: 64,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              HapticFeedback.lightImpact();
                                              await _friendDetailViewModel.toggleBestFriend(
                                                {"friend_id": friend.friendId},
                                              );
                                              await _friendListViewModel.fetchFriendList_afterBest();
                                            },
                                            child: Image.asset(
                                              'assets/imgs/icons/icon_profile_bestfriend_on.png',
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          GestureDetector(
                                            onTap: () => showModalBottomSheet(
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
                                                            onTap: () {
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
                                                                          '친구 목록에서 삭제하시겠어요?',
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
                                                                        mainAxisAlignment: MainAxisAlignment.end,
                                                                        children: [
                                                                          Expanded(
                                                                            child: Container(
                                                                              child: TextButton(
                                                                                onPressed: () {
                                                                                  Navigator.pop(context);
                                                                                  Get.back();
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
                                                                                ),
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
                                                                                  await _friendListViewModel.deleteFriend(
                                                                                    {"friend_id": friend.friendId},
                                                                                  );
                                                                                  await _friendListViewModel.fetchFriendList();
                                                                                },
                                                                                style: TextButton.styleFrom(
                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                ),
                                                                                child: Text('삭제하기',
                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 17,
                                                                                    color: SDSColor.snowliveBlue,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                            child: ListTile(
                                                              contentPadding: EdgeInsets.zero,
                                                              title: Center(
                                                                child: Text(
                                                                  '친구 삭제하기',
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900,
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
                                              Icons.more_horiz,
                                              color: SDSColor.gray200,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                        : Container(
                                      width: 64,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          GestureDetector(
                                            onTap: () async {
                                              HapticFeedback.lightImpact();
                                              await _friendDetailViewModel.toggleBestFriend(
                                                {"friend_id": friend.friendId},
                                              );
                                              await _friendListViewModel.fetchFriendList_afterBest();
                                            },
                                            child: Image.asset(
                                              'assets/imgs/icons/icon_profile_bestfriend_off.png',
                                              width: 24,
                                              height: 24,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 6,
                                          ),
                                          GestureDetector(
                                            onTap: () => showModalBottomSheet(
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
                                                            onTap: () {
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
                                                                          '친구 목록에서 삭제하시겠어요?',
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
                                                                        mainAxisAlignment: MainAxisAlignment.end,
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
                                                                                ),
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
                                                                                  CustomFullScreenDialog.showDialog();
                                                                                  await _friendListViewModel.deleteFriend(
                                                                                    {"friend_id": friend.friendId},
                                                                                  );
                                                                                  CustomFullScreenDialog.cancelDialog();
                                                                                  Navigator.pop(context);
                                                                                },
                                                                                style: TextButton.styleFrom(
                                                                                  backgroundColor: Colors.transparent, // 배경색 투명
                                                                                  splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                                                ),
                                                                                child: Text('삭제하기',
                                                                                  style: SDSTextStyle.bold.copyWith(
                                                                                    fontSize: 17,
                                                                                    color: SDSColor.snowliveBlue,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              );
                                                            },
                                                            child: ListTile(
                                                              contentPadding: EdgeInsets.zero,
                                                              title: Center(
                                                                child: Text(
                                                                  '친구 삭제하기',
                                                                  style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900,
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
                                              Icons.more_horiz,
                                              color: SDSColor.gray200,
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
      ),
    ));
  }
}
