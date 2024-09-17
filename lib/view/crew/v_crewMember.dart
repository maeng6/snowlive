import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/screens/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class CrewMemberListView extends StatelessWidget {

  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Obx(()=>Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Text('멤버 ${_crewMemberListViewModel.totalMemberCount}명',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: SDSColor.snowliveBlack
                  ),
                ),
                SizedBox(height: 15,),
                Container(
                  width : _size.width,
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _crewMemberListViewModel.crewMembersList.length,
                    itemBuilder: (BuildContext context, int index) {
                      if(_crewMemberListViewModel.crewMembersList.isNotEmpty || _crewMemberListViewModel.crewMembersList != null)
                      {
                        return Column(
                          children: [
                            InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: (){
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20), // 다이얼로그 모서리를 둥글게 설정
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                      content: Stack(
                                        children: [
                                          Container(
                                            width: 300,
                                            height: 500,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: AssetImage('assets/imgs/liveCrew/img_liveCrew_profileCard.png'), // 이미지 경로
                                                fit: BoxFit.fill,
                                              ),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Column(
                                              children: [
                                                SizedBox(height: 40),
                                                Center(
                                                  child: (_crewMemberListViewModel.crewMembersList[index].userInfo!.profileImageUrlUser!.isNotEmpty)
                                                      ? Container(
                                                        width: 80,
                                                        height: 80,
                                                        decoration: BoxDecoration(
                                                          color: Color(0xFFDFECFF),
                                                          borderRadius: BorderRadius.circular(50),
                                                        ),
                                                        child: ExtendedImage.network(
                                                          _crewMemberListViewModel.crewMembersList[index].userInfo!.profileImageUrlUser!,
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          cacheHeight: 150,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 80,
                                                          height: 80,
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
                                                                  width: 80,
                                                                  height: 80,
                                                                  fit: BoxFit.cover,
                                                                ); // 예시로 에러 아이콘을 반환하고 있습니다.
                                                              default:
                                                                return null;
                                                            }
                                                          },
                                                        ),
                                                      )
                                                      : Container(
                                                        width: 80,
                                                        height: 80,
                                                        child: ExtendedImage.asset(
                                                          'assets/imgs/profile/img_profile_default_circle.png',
                                                          enableMemoryCache: true,
                                                          shape: BoxShape.circle,
                                                          borderRadius: BorderRadius.circular(8),
                                                          width: 80,
                                                          height: 80,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ),
                                                ),
                                                SizedBox(height: 10),
                                                Container(
                                                  width: MediaQuery.of(context).size.width - 260,
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        _crewMemberListViewModel.crewMembersList[index].userInfo!.displayName!,
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20,
                                                          color: SDSColor.snowliveWhite,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Container(
                                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: SDSColor.snowliveWhite,
                                                    borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(
                                                    '${_crewMemberListViewModel.crewMembersList[index].status} | ${_crewDetailViewModel.crewName}',
                                                    style: TextStyle(
                                                      color: SDSColor.snowliveBlack,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 50),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '크루 랭킹',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          '11등',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                        ExtendedImage.asset(
                                                          'assets/imgs/ranking/icon_ranking_tier_S.png',
                                                          width: 37,
                                                          height: 37,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '참여도 랭킹',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          '6등',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(height: 5),
                                                        ExtendedImage.asset(
                                                          'assets/imgs/ranking/icon_ranking_tier_S.png',
                                                          width: 37,
                                                          height: 37,
                                                          fit: BoxFit.cover,
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                  children: [
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '주종목',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          '해머라이딩',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Column(
                                                      children: [
                                                        Text(
                                                          '가입일',
                                                          style: TextStyle(color: Colors.white),
                                                        ),
                                                        SizedBox(height: 5),
                                                        Text(
                                                          '24.12.02',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                Spacer(),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 16, right: 16),
                                                  child: ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: SDSColor.snowliveWhite,
                                                      textStyle: SDSTextStyle.bold.copyWith(
                                                          fontSize: 15,
                                                          color: SDSColor.gray900
                                                      ),
                                                      minimumSize: Size(double.infinity, 50),
                                                    ),
                                                    onPressed: () async{
                                                      Get.toNamed(AppRoutes.friendDetail);
                                                      await _friendDetailViewModel.fetchFriendDetailInfo(
                                                        userId: _userViewModel.user.user_id,
                                                        friendUserId: _crewMemberListViewModel.crewMembersList[index].userInfo!.userId!,
                                                        season: _friendDetailViewModel.seasonDate,
                                                      );
                                                    },
                                                    child: Text(
                                                      '프로필 보기',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            top: 10,
                                            right: 10,
                                            child: IconButton(
                                              icon: ExtendedImage.asset(
                                                'assets/imgs/icons/icon_liveCrew_save.png',
                                                shape: BoxShape.circle,
                                                borderRadius: BorderRadius.circular(8),
                                                width: 25,
                                                height: 25,
                                                fit: BoxFit.cover,
                                              ),
                                              onPressed: () {

                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    );


                                  },
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
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(100),
                                              border: (_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true
                                                  && _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true)
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
                                              width: 50,
                                              height: 50,
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
                                        if(_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true
                                            && _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true
                                        )
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
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100),
                                            border: (_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true
                                                && _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true)
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
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        if(_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true
                                        && _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true
                                        )
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
                                    SizedBox(width: 15,),
                                    Container(
                                      width: _size.width - 260,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(_crewMemberListViewModel.crewMembersList[index].userInfo!.displayName!,
                                            style: TextStyle(
                                                fontSize: 15,
                                                color: Color(0xFF111111)
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(child: SizedBox()),
                                    Text('5회',
                                      style: TextStyle(
                                          fontSize: 19
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    ExtendedImage.asset(
                                      'assets/imgs/ranking/icon_ranking_tier_S.png',
                                      width: 37,
                                      height: 37,
                                      fit: BoxFit.cover,
                                    ),

                                  ],
                                ),
                              ),
                            ),
                            if (index != _crewMemberListViewModel.crewMembersList.length - 1)
                              SizedBox(height: 15,)
                          ],
                        );
                      }
                      else{
                        return Container(
                          height: _size.height - 400,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Center(
                                child: Image.asset('assets/imgs/icons/icon_no_member.png',
                                  width: 100,
                                ),
                              ),
                              SizedBox(height: 12),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 50),
                                  child: Text(
                                    '가입된 멤버가 없습니다',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Color(0xFF666666)),
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
      ),)
    );
  }
}
