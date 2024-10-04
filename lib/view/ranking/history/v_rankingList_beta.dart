import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewRecordRoom.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_beta.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:com.snowlive/widget/w_verticalDivider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class RankingBetaView extends StatelessWidget {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final RankingListBetaViewModel _rankingListBetaViewModel = Get.find<RankingListBetaViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final CrewRecordRoomViewModel _crewRecordRoomViewModel = Get.find<CrewRecordRoomViewModel>();


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    double _statusBarSize = MediaQuery.of(context).padding.top;

    return Obx(() => Container(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            (_rankingListBetaViewModel.isLoadingBeta_crew == true ||
                _rankingListBetaViewModel.isLoadingBeta_indiv == true)
                ? Center(
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
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 필터
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Text('23/24 시즌',
                            style: SDSTextStyle.bold.copyWith(
                                fontSize: 15, color: Color(0xFF111111))),
                      ),
                      Container(
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: Stack(
                                          children: [
                                            ElevatedButton(
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                _rankingListBetaViewModel.changeCrewOrIndiv('크루');
                                              },
                                              style: ElevatedButton.styleFrom(
                                                shadowColor: Colors.transparent,
                                                overlayColor: Colors.transparent,
                                                padding: EdgeInsets.only(
                                                    right: 12, left: 12, top: 2, bottom: 2),
                                                side: BorderSide(
                                                  width: 1,
                                                  color: (_rankingListBetaViewModel.crewOrIndiv == '크루')
                                                      ? SDSColor.gray900
                                                      : SDSColor.gray100,
                                                ),
                                                backgroundColor: (_rankingListBetaViewModel.crewOrIndiv == '크루')
                                                    ? SDSColor.gray900
                                                    : SDSColor.snowliveWhite,
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(50)),
                                              ),
                                              child: Text('크루랭킹',
                                                  style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 13,
                                                      color: (_rankingListBetaViewModel.crewOrIndiv == '크루')
                                                          ? Color(0xFFFFFFFF)
                                                          : Color(0xFF111111))),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 8, bottom: 8),
                                  child: Row(
                                    children: [
                                      Stack(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              _rankingListBetaViewModel.changeCrewOrIndiv('개인');
                                            },
                                            style: ElevatedButton.styleFrom(
                                              shadowColor: Colors.transparent,
                                              overlayColor: Colors.transparent,
                                              padding: EdgeInsets.only(
                                                  right: 12, left: 12, top: 2, bottom: 2),
                                              side: BorderSide(
                                                width: 1,
                                                color: (_rankingListBetaViewModel.crewOrIndiv == '개인')
                                                    ? SDSColor.gray900
                                                    : SDSColor.gray100,
                                              ),
                                              backgroundColor: (_rankingListBetaViewModel.crewOrIndiv == '개인')
                                                  ? SDSColor.gray900
                                                  : SDSColor.snowliveWhite,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(50)),
                                            ),
                                            child: Text('개인랭킹',
                                                style: SDSTextStyle.bold.copyWith(
                                                    fontSize: 13,
                                                    color: (_rankingListBetaViewModel.crewOrIndiv == '개인')
                                                        ? Color(0xFFFFFFFF)
                                                        : Color(0xFF111111))),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // 크루 또는 개인 랭킹 리스트 표시
                  Expanded( // Expanded로 감싸서 남은 공간을 사용하도록 함
                    child: (_rankingListBetaViewModel.crewOrIndiv == '크루')
                        ? Scrollbar(
                      controller: _rankingListBetaViewModel.scrollControllerCrewBeta,
                      child: ListView.builder(
                        controller: _rankingListBetaViewModel.scrollControllerCrewBeta,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _rankingListBetaViewModel.rankingListCrewBetaList.length + 1,
                        itemBuilder: (context, index) {

                          if(index ==  _rankingListBetaViewModel.rankingListCrewBetaList.length){
                            return Obx(() => _rankingListBetaViewModel.isLoadingNextList_crew == true // 여기서 Obx 사용
                                ? Container(
                              height: 100,
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
                            )
                                : SizedBox.shrink());
                          }else{
                            final document = _rankingListBetaViewModel.rankingListCrewBetaList[index];
                            return Padding(
                              padding:
                              const EdgeInsets.only(bottom: 8, left: 2, right: 2),
                              child: GestureDetector(
                                onTap: () async {
                                  Get.toNamed(AppRoutes.crewMain);
                                  await _crewMemberListViewModel.fetchCrewMembers(
                                    crewId: document.crewInfo!.crewId!,
                                  );
                                  await _crewDetailViewModel.fetchCrewDetail(
                                    document.crewInfo!.crewId!,
                                    _friendDetailViewModel.seasonDate,
                                  );

                                  if(_userViewModel.user.crew_id == document.crewInfo!.crewId!)
                                    await _crewRecordRoomViewModel.fetchCrewRidingRecords(
                                        document.crewInfo!.crewId!,
                                        '${DateTime.now().year}'
                                    );
                                },
                                child: Row(
                                  children: [
                                    // 크루 랭킹 정보 표시
                                    Container(
                                      width: 24,
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (index == 0) ...[
                                            Image.asset(
                                                'assets/imgs/icons/icon_medal_1.png',
                                                width: 24),
                                          ] else if (index == 1) ...[
                                            Image.asset(
                                                'assets/imgs/icons/icon_medal_2.png',
                                                width: 24),
                                          ] else if (index == 2) ...[
                                            Image.asset(
                                                'assets/imgs/icons/icon_medal_3.png',
                                                width: 24),
                                          ] else ...[
                                            Expanded(
                                              child: Center(
                                                child: AutoSizeText(
                                                  (index + 1).toString(), // 순위를 1부터 시작
                                                  style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 14,
                                                      color: Color(0xFF111111)),
                                                  maxLines: 1,
                                                  minFontSize: 6,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: SDSColor.gray100,
                                          width: 1,
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: document.crewInfo!.crewLogoUrl!.isNotEmpty
                                          ? ExtendedImage.network(
                                        document.crewInfo!.crewLogoUrl!,
                                        enableMemoryCache: true,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        cacheHeight: 100,
                                        width: 32,
                                        height: 32,
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
                                                '${crewDefaultLogoUrl['${document.crewInfo!.color}']}', // 대체 이미지 경로
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                          }
                                        },
                                      )
                                          : ExtendedImage.network(
                                        '${crewDefaultLogoUrl['${document.crewInfo!.color}']}',
                                        enableMemoryCache: true,
                                        cacheHeight: 100,
                                        shape: BoxShape.rectangle,
                                        borderRadius: BorderRadius.circular(10),
                                        width: 32,
                                        height: 32,
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
                                                '${crewDefaultLogoUrl['${document.crewInfo!.color}']}', // 대체 이미지 경로
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                document.crewInfo!.crewName!,
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 14,
                                                    color: SDSColor.gray900),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                document.crewInfo!.baseResortNickname!,
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 12,
                                                    color: SDSColor.gray500),
                                              ),
                                              if(document.crewInfo!.description != '')
                                                Text(
                                                  ' · ',
                                                  style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 12,
                                                      color: SDSColor.gray500),
                                                ),
                                              Expanded(
                                                child: Text(
                                                  document.crewInfo!.description ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 12,
                                                      color: SDSColor.gray500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${document.overallTotalScore!.toInt()}점',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: SDSColor.gray900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }


                        },
                        padding: EdgeInsets.only(bottom: 80),
                      ),
                    )
                        : Scrollbar(
                      controller: _rankingListBetaViewModel.scrollControllerIndivBeta,
                      child: ListView.builder(
                        controller: _rankingListBetaViewModel.scrollControllerIndivBeta,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemCount: _rankingListBetaViewModel.rankingListIndivBetaList.length + 1,
                        itemBuilder: (context, index) {

                          if(index == _rankingListBetaViewModel.rankingListIndivBetaList.length){
                            return Obx(() => _rankingListBetaViewModel.isLoadingNextList_indi == true // 여기서 Obx 사용
                                ? Container(
                              height: 100,
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
                            )
                                : SizedBox.shrink());
                          }else{
                            final document = _rankingListBetaViewModel.rankingListIndivBetaList[index];
                            return Padding(
                              padding:
                              const EdgeInsets.only(bottom: 8, left: 2, right: 2),
                              child: GestureDetector(
                                onTap: () async {
                                  Get.toNamed(AppRoutes.friendDetail);
                                  await _friendDetailViewModel.fetchFriendDetailInfo(
                                      userId: _userViewModel.user.user_id,
                                      friendUserId: document.userInfo!.userId!,
                                      season: _friendDetailViewModel.seasonDate);
                                },
                                child: Row(
                                  children: [
                                    // 개인 랭킹 정보 표시
                                    Container(
                                      width: 24,
                                      height: 40,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          if (index == 0) ...[
                                            Image.asset(
                                                'assets/imgs/icons/icon_medal_1.png',
                                                width: 24),
                                          ] else if (index == 1) ...[
                                            Image.asset(
                                                'assets/imgs/icons/icon_medal_2.png',
                                                width: 24),
                                          ] else if (index == 2) ...[
                                            Image.asset(
                                                'assets/imgs/icons/icon_medal_3.png',
                                                width: 24),
                                          ] else ...[
                                            Expanded(
                                              child: Center(
                                                child: AutoSizeText(
                                                  (index + 1).toString(), // 순위를 1부터 시작
                                                  style: SDSTextStyle.bold.copyWith(
                                                      fontSize: 14,
                                                      color: Color(0xFF111111)),
                                                  maxLines: 1,
                                                  minFontSize: 6,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                            color: SDSColor.gray100,
                                            width: 1,
                                          ),
                                          borderRadius: BorderRadius.circular(50)
                                      ),
                                      child: document.userInfo!.profileImageUrlUser!
                                          .isNotEmpty
                                          ? ExtendedImage.network(
                                        document.userInfo!.profileImageUrlUser!,
                                        enableMemoryCache: true,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        cacheHeight: 100,
                                        width: 32,
                                        height: 32,
                                        cacheWidth: 100,
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
                                                '${profileImgUrlList[0].default_round}', // 대체 이미지 경로
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                          }
                                        },
                                      )
                                          : ExtendedImage.network(
                                        '${profileImgUrlList[0].default_round}',
                                        enableMemoryCache: true,
                                        shape: BoxShape.circle,
                                        borderRadius: BorderRadius.circular(8),
                                        cacheHeight: 100,
                                        width: 32,
                                        height: 32,
                                        cacheWidth: 100,
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
                                                '${profileImgUrlList[0].default_round}', // 대체 이미지 경로
                                                width: 32,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              );
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                document.userInfo?.displayName?? '',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 14,
                                                    color: SDSColor.gray900),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                document.userInfo?.resortNickname??'',
                                                style: SDSTextStyle.regular.copyWith(
                                                    fontSize: 12,
                                                    color: SDSColor.gray500),
                                              ),
                                              if(document.userInfo?.crewName != null)
                                                Text(
                                                  ' · ',
                                                  style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 12,
                                                      color: SDSColor.gray500),
                                                ),
                                              Expanded(
                                                child: Text(
                                                  document.userInfo?.crewName ?? '',
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: SDSTextStyle.regular.copyWith(
                                                      fontSize: 12,
                                                      color: SDSColor.gray500),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          '${document.resortTotalScore!.toInt()}점',
                                          style: SDSTextStyle.regular.copyWith(
                                            color: SDSColor.gray900,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }


                        },
                        padding: EdgeInsets.only(bottom: 80),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }
}

