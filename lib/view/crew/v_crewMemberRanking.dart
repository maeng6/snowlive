import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberRankingList.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewMemberRankingListView extends StatelessWidget {
  final CrewRankingListViewModel _crewRankingListViewModel = Get.find<CrewRankingListViewModel>();

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Obx(() {
        // 로딩 중일 때 표시할 위젯
        if (_crewRankingListViewModel.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // 랭킹 리스트가 비어있을 경우
        if (_crewRankingListViewModel.crewRankings.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 50),
              child: Column(
                children: [
                  Image.asset(
                    'assets/imgs/icons/icon_nodata.png',
                    width: 100,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '크루 랭킹 정보가 없습니다.',
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 14,
                      color: SDSColor.gray600,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // 랭킹 리스트 렌더링
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Text(
                '크루원 랭킹 (${_crewRankingListViewModel.crewRankings.length}명)',
                style: SDSTextStyle.bold.copyWith(
                  fontSize: 16,
                  color: SDSColor.snowliveBlack,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _crewRankingListViewModel.crewRankings.length,
              itemBuilder: (context, index) {
                final ranking = _crewRankingListViewModel.crewRankings[index];

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          // 순위 표시
                          Text(
                            '${index + 1}',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 14,
                              color: SDSColor.snowliveBlue,
                            ),
                          ),
                          SizedBox(width: 16),
                          // 프로필 이미지
                          ranking.profileImageUrlUser?.isNotEmpty == true
                              ? ClipOval(
                            child: Image.network(
                              ranking.profileImageUrlUser!,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/imgs/profile/img_profile_default_circle.png',
                                  width: 40,
                                  height: 40,
                                );
                              },
                            ),
                          )
                              : Image.asset(
                            'assets/imgs/profile/img_profile_default_circle.png',
                            width: 40,
                            height: 40,
                          ),
                          SizedBox(width: 16),
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
                                    style: SDSTextStyle.regular.copyWith(
                                      fontSize: 12,
                                      color: SDSColor.gray700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          // 점수
                          Text(
                            '${ranking.totalScore?.toStringAsFixed(1) ?? '0.0'}',
                            style: SDSTextStyle.bold.copyWith(
                              fontSize: 14,
                              color: SDSColor.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (index != _crewRankingListViewModel.crewRankings.length - 1)
                      Divider(
                        color: SDSColor.gray200,
                        thickness: 1,
                        height: 1,
                      ),
                  ],
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
