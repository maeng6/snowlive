import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';


class CrewMemberListView extends StatelessWidget {

  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();

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
                    style: SDSTextStyle.bold.copyWith(
                        fontSize: 14,
                        color: SDSColor.snowliveBlack
                    ),
                  ),
                  SizedBox(height: 20,),
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
                                onTap: () async{
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
                                                border: (_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true
                                                    && _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true
                                                &&  _crewDetailViewModel.crewDetailInfo.crewId == _userViewModel.user.crew_id)
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
                                                    // 로딩 중일 때 로딩 인디케이터를 표시
                                                      return Shimmer.fromColors(
                                                        baseColor: SDSColor.gray200!,
                                                        highlightColor: SDSColor.gray50!,
                                                        child: Container(
                                                          width: 32,
                                                          height: 32,
                                                          decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                        ),
                                                      );
                                                    case LoadState.completed:
                                                    // 로딩이 완료되었을 때 이미지 반환
                                                      return state.completedWidget;
                                                    case LoadState.failed:
                                                    // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                      return Image.asset(
                                                        'assets/imgs/profile/img_profile_default_circle.png',
                                                        width: 32,
                                                        height: 32,
                                                        fit: BoxFit.cover,
                                                      );
                                                  }
                                                },
                                              )),
                                          if(_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true
                                              && _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true
                                          && _crewDetailViewModel.crewDetailInfo.crewId == _userViewModel.user.crew_id
                                          )
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/imgs/icons/icon_badge_live.png',
                                                  width: 30,
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
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.asset(
                                                'assets/imgs/profile/img_profile_default_circle.png',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                            ,
                                          ),
                                          if(_crewMemberListViewModel.crewMembersList[index].userInfo!.withinBoundary == true
                                              && _crewMemberListViewModel.crewMembersList[index].userInfo!.revealWb == true
                                          )
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Center(
                                                child: Image.asset(
                                                  'assets/imgs/icons/icon_badge_live.png',
                                                  width: 30,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(width: 10,),
                                      Container(
                                        width: _size.width - 260,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(_crewMemberListViewModel.crewMembersList[index].userInfo!.displayName!,
                                              style: SDSTextStyle.regular.copyWith(
                                                  fontSize: 15,
                                                  color: SDSColor.gray900
                                              ),
                                            ),
                                          ],
                                        ),
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
