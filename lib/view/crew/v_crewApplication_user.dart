import 'package:com.snowlive/data/imgaUrls/Data_url_image.dart';
import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewDetail.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/friend/vm_friendDetail.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewApply.dart';
import 'package:extended_image/extended_image.dart';

class CrewApplicationUserView extends StatelessWidget {
  final CrewApplyViewModel _crewApplyViewModel = Get.find<CrewApplyViewModel>();
  final CrewDetailViewModel _crewDetailViewModel = Get.find<CrewDetailViewModel>();
  final FriendDetailViewModel _friendDetailViewModel = Get.find<FriendDetailViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: SDSColor.snowliveWhite,
        child: SafeArea(
          top: false,
          bottom: true,
          child: Scaffold(
            backgroundColor: SDSColor.snowliveWhite,
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
                '가입 신청한 크루',
                style: TextStyle(
                    color: SDSColor.snowliveBlack,
                    fontSize: 18
                ),
              ),
              elevation: 0,
              toolbarHeight: 44,
            ),
            body: Obx(() {
              var crewApplyList = _crewApplyViewModel.crewApplyList;

              return Column(
                children: [
                  Expanded(
                    child: FutureBuilder(
                      future: Future.wait(crewApplyList.map((crew) async {
                        await _crewDetailViewModel.findCrewDetails(crew.crewId!, _friendDetailViewModel.seasonDate);
                        return crew;
                      }).toList()),
                      builder: (context, snapshot) {

                        var loadedCrewList = snapshot.data as List<dynamic>? ?? [];

                        return ListView(
                          children: loadedCrewList.map((crew) {
                            var crewInfo = _crewDetailViewModel.crewDetails[crew.crewId] ?? {
                              'logoUrl': '',
                              'name': '',
                              'description': ''
                            };
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: GestureDetector(
                                onTap: () async {
                                  CustomFullScreenDialog.showDialog();
                                  await _crewDetailViewModel.fetchCrewDetail(
                                    crew.crewId!,
                                    _friendDetailViewModel.seasonDate,
                                  );
                                  CustomFullScreenDialog.cancelDialog();
                                  Get.toNamed(AppRoutes.crewMain);
                                  await _crewMemberListViewModel.fetchCrewMembers(crewId: crew.crewId!);

                                },
                                child: Row(
                                  children: [
                                    // 크루명 및 부가 정보
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            crewInfo['name']!,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: 1),
                                          Text(
                                            crewInfo['description']!,
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
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
                                                      '가입 신청을 취소하시겠어요?',
                                                      textAlign: TextAlign.center,
                                                      style: SDSTextStyle.bold.copyWith(
                                                          color: SDSColor.gray900,
                                                          fontSize: 16
                                                      ),
                                                    ),
                                                    Text(
                                                      '가입 신청을 취소하셔도 다음에 다시\n가입 신청을 하실 수 있어요.',
                                                      style: TextStyle(fontSize: 14, color: SDSColor.gray600),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    Navigator.pop(context);
                                                    CustomFullScreenDialog.showDialog();
                                                    await _crewApplyViewModel.deleteCrewApplication(
                                                      _userViewModel.user.user_id,
                                                      crew.crewId!,
                                                      _userViewModel.user.user_id,
                                                    );
                                                    _crewApplyViewModel.crewApplyList
                                                        .removeWhere((item) => item.crewId == crew.crewId); // 삭제된 항목만 제거
                                                    CustomFullScreenDialog.cancelDialog();
                                                  },
                                                  child: Text(
                                                    '신청 취소하기',
                                                    style: TextStyle(
                                                      color: SDSColor.snowliveWhite,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    backgroundColor: SDSColor.snowliveBlue, // 신청 취소 버튼 색상
                                                    minimumSize: Size(double.infinity, 48), // 버튼 크기
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop(); // 팝업 닫기
                                                  },
                                                  child: Text(
                                                    '돌아가기',
                                                    style: TextStyle(
                                                      color: SDSColor.snowliveBlack,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.transparent,
                                                    elevation: 0,
                                                    minimumSize: Size(double.infinity, 48), // 버튼 크기
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 3),
                                        minimumSize: Size(36, 32),
                                        backgroundColor: SDSColor.snowliveWhite,
                                        side: BorderSide(
                                            color: SDSColor.gray200
                                        ),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(100)),
                                      ),
                                      child: Text(
                                        '신청취소',
                                        style: SDSTextStyle.bold.copyWith(fontSize: 13, color: SDSColor.gray900),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                  // 하단의 다른 크루 찾아보기 버튼
                  Container(
                    color: SDSColor.snowliveWhite,
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          Get.offNamed(AppRoutes.searchCrew);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SDSColor.snowliveBlue, // 버튼 색상
                          padding: EdgeInsets.symmetric(vertical: 16),
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                            elevation: 0
                        ),
                        child: Text(
                          '다른 크루 찾아보기',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
