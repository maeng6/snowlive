import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewMemberSettingsView extends StatelessWidget {

  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  void _showRoleChangeBottomSheet(BuildContext context, int index) {
    String memberRole = _crewMemberListViewModel.getMemberRole(_crewMemberListViewModel.crewMembersList[index].userInfo!.userId!);
    String roleChangeOption = memberRole == '운영진' ? '크루원으로 변경' : '운영진으로 변경';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 전체 화면 제어 가능
      backgroundColor: Colors.transparent, // 배경을 투명하게 만들어서 모서리 둥근 디자인 보이게 설정
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(left: 16, right: 16, bottom: 48), // 양옆과 아래를 띄움
          child: Container(
            height: 180, // 적절한 높이 설정
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16), // 모서리 둥글게 설정
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      '크루장 위임',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                  ),
                  onTap: () {
                    // 권한 변경 로직 확인 팝업
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text('크루장을 위임하시겠습니까?',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back(); // 팝업 닫기
                              },
                              child: Text(
                                '아니오',
                                style: TextStyle(
                                    color: SDSColor.snowliveBlack,
                                    fontSize: 15
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                CustomFullScreenDialog.showDialog();
                                // 권한 변경 로직 실행
                                await _crewMemberListViewModel.updateCrewMemberStatus(
                                    crewMemberUserId: _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!,
                                    newStatus: '크루장');
                                await _crewMemberListViewModel.updateCrewMemberStatus(
                                    crewMemberUserId: _userViewModel.user.user_id,
                                    newStatus: '운영진');
                                await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);
                                Navigator.pop(context);
                                Navigator.pop(context);
                                CustomFullScreenDialog.cancelDialog();
                                Get.back();
                                print('크루장 위임에 성공하였습니다');
                              },
                              child: Text(
                                '예',
                                style: TextStyle(
                                    color: SDSColor.snowliveBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Center(
                    child: Text(
                      roleChangeOption,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                  ),
                  onTap: () {
                    // 권한 변경 로직 확인 팝업
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(roleChangeOption + '하시겠습니까?',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back(); // 팝업 닫기
                              },
                              child: Text(
                                '아니오',
                                style: TextStyle(
                                    color: SDSColor.snowliveBlack,
                                    fontSize: 15
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                CustomFullScreenDialog.showDialog();
                                // 권한 변경 로직 실행
                                String newRole = _crewMemberListViewModel.getMemberRole(_crewMemberListViewModel.crewMembersList[index].userInfo!.userId!) == '운영진'
                                    ? '크루원'
                                    : '운영진';
                                await _crewMemberListViewModel.updateCrewMemberStatus(
                                    crewMemberUserId: _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!,
                                    newStatus: newRole);
                                await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);
                                CustomFullScreenDialog.cancelDialog();
                                print('권한이 $newRole 으로 변경되었습니다.');
                                Get.back(); // 팝업 닫기
                                Get.back(); // bottom sheet 닫기
                              },
                              child: Text(
                                '예',
                                style: TextStyle(
                                    color: SDSColor.snowliveBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
                ListTile(
                  title: Center(
                    child: Text(
                      '강퇴하기',
                      style: TextStyle(
                        fontSize: 15,
                        color: SDSColor.snowliveBlack,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text('정말 강퇴하시겠습니까?',
                            style: TextStyle(
                                color: SDSColor.snowliveBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 15
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Get.back(); // 팝업 닫기
                              },
                              child: Text(
                                '아니오',
                                style: TextStyle(
                                    color: SDSColor.snowliveBlack,
                                    fontSize: 15
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () async{
                                Navigator.pop(context);
                                CustomFullScreenDialog.showDialog();
                                await _crewMemberListViewModel.expelCrewMember(
                                    crewMemberUserId: _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!
                                );
                                await _crewMemberListViewModel.fetchCrewMembers(crewId: _userViewModel.user.crew_id);
                                CustomFullScreenDialog.cancelDialog();
                              },
                              child: Text(
                                '예',
                                style: TextStyle(
                                    color: SDSColor.snowliveBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 닫기
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
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
          title: Text(
            '크루원 관리',
            style: SDSTextStyle.bold.copyWith(color: SDSColor.snowliveBlack, fontSize: 18),
          ),
          elevation: 0,
          toolbarHeight: 44,
        ),
        body: SingleChildScrollView(
          child: Obx(
                () => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '멤버 ${_crewMemberListViewModel.totalMemberCount}명',
                        style: SDSTextStyle.bold.copyWith(fontSize: 14, color: SDSColor.gray900),
                      ),
                      SizedBox(height: 20),
                      Container(
                        width: _size.width,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: _crewMemberListViewModel.crewMembersList.length,
                          itemBuilder: (BuildContext context, int index) {
                            if (_crewMemberListViewModel.crewMembersList.isNotEmpty || _crewMemberListViewModel.crewMembersList != null) {
                              return Column(
                                children: [
                                  InkWell(
                                    highlightColor: Colors.transparent,
                                    splashColor: Colors.transparent,
                                    onTap: () async {
                                      Get.toNamed(AppRoutes.friendDetail);
                                      await _friendDetailViewModel.fetchFriendDetailInfo(
                                        userId: _userViewModel.user.user_id,
                                        friendUserId: _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!,
                                        season: _friendDetailViewModel.seasonDate,
                                      );
                                    },
                                    child: Container(
                                      width: _size.width,
                                      child: Row(
                                        children: [
                                          (_crewMemberListViewModel.crewMembersList[index].userInfo!.profileImageUrlUser!.isNotEmpty)
                                              ? Stack(
                                            children: [
                                              Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(100),
                                                    border: (_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true &&
                                                        _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true)
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
                                                    _crewMemberListViewModel.crewMembersList[index].userInfo!.profileImageUrlUser!,
                                                    enableMemoryCache: true,
                                                    shape: BoxShape.circle,
                                                    cacheHeight: 150,
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
                                                            borderRadius: BorderRadius.circular(8),
                                                            width: 50,
                                                            height: 50,
                                                            fit: BoxFit.cover,
                                                          ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                        default:
                                                          return null;
                                                      }
                                                    },
                                                  )),
                                              if (_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true &&
                                                  _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true)
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
                                                width: 40,
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  border: (_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true &&
                                                      _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true)
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
                                                  enableMemoryCache: true,
                                                  shape: BoxShape.circle,
                                                  borderRadius: BorderRadius.circular(8),
                                                  width: 40,
                                                  height: 40,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              if (_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true &&
                                                  _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true)
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
                                          SizedBox(width: 8),
                                          Container(
                                            width: _size.width - 140,
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Text(
                                                  _crewMemberListViewModel.crewMembersList[index].userInfo!.displayName!,
                                                  style: SDSTextStyle.regular.copyWith(
                                                    color: SDSColor.gray900,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 8),
                                                  child: Container(
                                                    width: 40, // 원하는 너비 설정
                                                    height: 20, // 원하는 높이 설정
                                                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: _crewMemberListViewModel.getRoleColorBox(
                                                          _crewMemberListViewModel.getMemberRole(
                                                              _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!)),
                                                      borderRadius: BorderRadius.circular(4),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _crewMemberListViewModel.getMemberRole(
                                                            _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!),
                                                        style: SDSTextStyle.bold.copyWith(
                                                          color: _crewMemberListViewModel.getRoleColorText(
                                                              _crewMemberListViewModel.getMemberRole(
                                                                  _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!)),
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          Expanded(child: SizedBox()),
                                          if(_crewMemberListViewModel.getMemberRole(
                                              _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!) != '크루장')
                                            GestureDetector(
                                              onTap: (){
                                                _showRoleChangeBottomSheet(context, index);
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 10),
                                                child: Container(
                                                  width: 40, // 원하는 너비 설정
                                                  height: 40, // 원하는 높이 설정
                                                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.more_horiz,
                                                      color: SDSColor.gray200,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (index != _crewMemberListViewModel.crewMembersList.length - 1) SizedBox(height: 15)
                                ],
                              );
                            } else {
                              return Container(
                                height: _size.height - 400,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Center(
                                      child: Image.asset(
                                        'assets/imgs/icons/icon_no_member.png',
                                        width: 100,
                                      ),
                                    ),
                                    SizedBox(height: 12),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.only(bottom: 50),
                                        child: Text(
                                          '가입된 멤버가 없습니다',
                                          style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

}
