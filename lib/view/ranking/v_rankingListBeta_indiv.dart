

import 'package:auto_size_text/auto_size_text.dart';
import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/ranking/vm_rankingList_beta.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RankingListBetaIndiv extends StatelessWidget {

  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final RankingListBetaViewModel _rankingListBetaViewModel = Get.find<RankingListBetaViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return RefreshIndicator(
      onRefresh: () async{
        //당겨서 새로고침
      },
      child: Scrollbar(
        controller: _rankingListBetaViewModel.scrollControllerIndivBeta,
        child: ListView.builder(
          shrinkWrap: true,
          controller: _rankingListBetaViewModel.scrollControllerIndivBeta,
          itemCount: _rankingListBetaViewModel.rankingListIndivBetaList.length,
          itemBuilder: (context, index) {
            final document = _rankingListBetaViewModel.rankingListIndivBetaList[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 2, right: 2),
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
                            Image.asset('assets/imgs/icons/icon_medal_1.png', width: 24),
                          ] else if (index == 1) ...[
                            Image.asset('assets/imgs/icons/icon_medal_2.png', width: 24),
                          ] else if (index == 2) ...[
                            Image.asset('assets/imgs/icons/icon_medal_3.png', width: 24),
                          ] else ...[
                            Expanded(
                              child: Center(
                                child: AutoSizeText(
                                  index.toString(),
                                  style: SDSTextStyle.bold.copyWith(
                                      fontSize: 14,
                                      color: Color(0xFF111111)
                                  ),
                                  maxLines: 1,
                                  minFontSize: 6,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    // 개인랭킹 정보
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
                      child: document.userInfo!.profileImageUrlUser!.isNotEmpty
                          ? ExtendedImage.network(
                        document.userInfo!.profileImageUrlUser!,
                        enableMemoryCache: true,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        cacheHeight: 100,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      )
                          : ExtendedImage.network(
                        '${profileImgUrlList[0].default_round}',
                        enableMemoryCache: true,
                        cacheHeight: 100,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(10),
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(document.userInfo!.displayName!,
                                style: SDSTextStyle.regular.copyWith(
                                    fontSize: 14,
                                    color: SDSColor.gray900
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: _size.width - 200,
                            child: Row(
                              children: [
                                Text(
                                  document.userInfo!.resortNickname!,
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray500
                                  ),
                                ),
                                Text('·',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray500
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    child: Text(
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      document.userInfo!.crewName??'',
                                      style: SDSTextStyle.regular.copyWith(
                                          fontSize: 12,
                                          color: SDSColor.gray500
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Row(
                      children: [
                          Text('${document.resortTotalScore!.toInt()}점',
                            style: SDSTextStyle.regular.copyWith(
                              color: SDSColor.gray900,
                              fontSize: 16,
                            ),
                          )
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          padding: EdgeInsets.only(bottom: 80),
        ),
      ),
    );
  }
}
