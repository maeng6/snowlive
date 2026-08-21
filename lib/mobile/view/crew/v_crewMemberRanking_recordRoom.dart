import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/core/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_crewMemberRankingList.dart';
import 'package:com.snowlive/core/viewmodel/ranking/vm_crewMemberRankingList_recordRoom.dart';
import 'package:com.snowlive/core/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/core/viewmodel/vm_user.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CrewMemberRankingListView_recordRoom extends StatelessWidget {
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewRankingListViewModel_recordRoom _crewRankingListViewModel_recordRoom = Get.find<CrewRankingListViewModel_recordRoom>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
      appBar: AppBar(
        backgroundColor: SDSColor.snowliveWhite,
        surfaceTintColor: Colors.transparent,
        toolbarHeight: 44,
        elevation: 0.0,
        leading: Padding(
          padding: EdgeInsets.only(left: 8),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: SvgPicture.asset('assets/imgs/icons/icon_snowLive_back.svg', width: 26, height: 26),
            highlightColor: Colors.transparent,
          ),
        ),
        centerTitle: true,
        title: Text(
          '크루원 랭킹',
          style: SDSTextStyle.extraBold.copyWith(
            color: SDSColor.gray900,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        // 로딩 중일 때 표시할 위젯
        if (_crewRankingListViewModel_recordRoom.isLoading.value) {
          return Center(
            child: Container(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 4,
                backgroundColor: SDSColor.gray100,
                color: SDSColor.gray300.withOpacity(0.6),
              ),
            ),
          );
        }

        // 랭킹 리스트가 비어있을 경우
        if (_crewRankingListViewModel_recordRoom.crewRankings.isEmpty) {
          return SizedBox(
            height: _size.height,
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
                      '랭킹전에 참여한 크루원이 없습니다',
                      style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // 랭킹 리스트 렌더링
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _crewRankingListViewModel_recordRoom.crewRankings.length,
                itemBuilder: (context, index) {
                  final ranking = _crewRankingListViewModel_recordRoom.crewRankings[index];

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            // 순위 표시
                            Container(
                              width: 24,
                              height: 40,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Center(
                                      child: AutoSizeText(
                                        '${index + 1}',
                                        style: SDSTextStyle.bold.copyWith(
                                          fontSize: 14,
                                          color: Color(0xFF111111),
                                        ),
                                        maxLines: 1,
                                        minFontSize: 6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10),
                            // 프로필 이미지
                            GestureDetector(
                              onTap: () async {
                                Get.toNamed(AppRoutes.friendDetail);
                                await _friendDetailViewModel.fetchFriendDetailInfo(
                                  userId: _userViewModel.user.user_id,
                                  friendUserId: ranking.userId!,
                                  season: _friendDetailViewModel.seasonDate,
                                );
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: SDSColor.gray100,
                                    width: 1,
                                  ),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: ranking.profileImageUrlUser?.isNotEmpty == true
                                    ? ExtendedImage.network(
                                  ranking.profileImageUrlUser!,
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
                                        return state.completedWidget;
                                      case LoadState.failed:
                                        return Image.asset(
                                          'assets/imgs/profile/img_profile_default_circle.png',
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.cover,
                                        );
                                    }
                                  },
                                )
                                    : Image.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  width: 32,
                                  height: 32,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            // 사용자 정보
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ranking.displayName ?? 'Unknown',
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray900,
                                    ),
                                  ),
                                  if (ranking.stateMsg != null && ranking.stateMsg!.isNotEmpty)
                                    Text(
                                      ranking.stateMsg!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: SDSTextStyle.regular.copyWith(
                                        fontSize: 12,
                                        color: SDSColor.gray500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // 점수
                            Text(
                              '${ranking.totalScore?.round() ?? '0'}점',
                              style: SDSTextStyle.regular.copyWith(
                                color: Color(0xFF111111),
                                fontSize: 16,
                              ),
                            ),
                            SizedBox(width: 2),
                            Transform.translate(
                              offset: Offset(4, 1),
                              child: ExtendedImage.network(
                                '${ranking.tierIconUrl}',
                                enableMemoryCache: true,
                                cacheHeight: 108,
                                fit: BoxFit.cover,
                                width: 36,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              Container(
                height: 24,
              )
            ],
          ),
        );
      }),
    );
  }
}
