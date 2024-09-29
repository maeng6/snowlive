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
              backgroundColor: SDSColor.snowliveWhite,
              foregroundColor: SDSColor.snowliveWhite,
              surfaceTintColor: SDSColor.snowliveWhite,
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
                                  Get.toNamed(AppRoutes.crewMain);
                                  await _crewDetailViewModel.fetchCrewDetail(
                                    crew.crewId!,
                                    _friendDetailViewModel.seasonDate,
                                  );
                                  await _crewMemberListViewModel.fetchCrewMembers(crewId: crew.crewId!);

                                },
                                child: Row(
                                  children: [
                                    if (crewInfo['logoUrl'] != '')
                                      GestureDetector(
                                        onTap: () async{
                                          Get.toNamed(AppRoutes.crewMain);
                                          await _crewDetailViewModel.fetchCrewDetail(
                                            crew.crewId!,
                                            _friendDetailViewModel.seasonDate,
                                          );
                                          await _crewMemberListViewModel.fetchCrewMembers(crewId: crew.crewId!);

                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: SDSColor.gray100
                                              )
                                          ),
                                          width: 44,
                                          height: 44,
                                          child: ExtendedImage.network(
                                            '${crewInfo['logoUrl']}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    if (crewInfo['logoUrl'] == '')
                                      GestureDetector(
                                        onTap: () async{
                                          Get.toNamed(AppRoutes.crewMain);
                                          await _crewDetailViewModel.fetchCrewDetail(
                                            crew.crewId!,
                                            _friendDetailViewModel.seasonDate,
                                          );
                                          await _crewMemberListViewModel.fetchCrewMembers(crewId: crew.crewId!);

                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: SDSColor.gray100
                                              )
                                          ),
                                          width: 44,
                                          height: 44,
                                          child: ExtendedImage.network(
                                            '${crewDefaultLogoUrl['${_crewDetailViewModel.color}']}',
                                            enableMemoryCache: true,
                                            shape: BoxShape.rectangle,
                                            borderRadius: BorderRadius.circular(10),
                                            width: 44,
                                            height: 44,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    SizedBox(width: 12),
                                    // 크루명 및 부가 정보
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            crewInfo['name']!,
                                            style: SDSTextStyle.regular.copyWith(
                                              fontSize: 15,
                                              color: SDSColor.gray900,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          SizedBox(height: 1),
                                          Text(
                                            crewInfo['description']!,
                                            style: SDSTextStyle.regular.copyWith(
                                              fontSize: 13,
                                              color: SDSColor.gray500,
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
                                                height: 80,
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
                                                    SizedBox(
                                                      height: 6,
                                                    ),
                                                    Text(
                                                      '가입 신청을 취소하셔도 다음에 다시 가입 신청을 하실 수 있어요.',
                                                      textAlign: TextAlign.center,
                                                      style: SDSTextStyle.regular.copyWith(
                                                        color: SDSColor.gray500,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              actions: [
                                                Padding(
                                                  padding: EdgeInsets.only(top: 10, left: 16, right: 16),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          child: TextButton(
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
                                                            style: TextButton.styleFrom(
                                                              backgroundColor: Colors.transparent, // 배경색 투명
                                                              splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
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
                                                              CustomFullScreenDialog.showDialog();
                                                              await _crewApplyViewModel.deleteCrewApplication(
                                                                _userViewModel.user.user_id,
                                                                crew.crewId!,
                                                                _userViewModel.user.user_id,
                                                              );
                                                              _crewApplyViewModel.crewApplyList.removeWhere((item) => item.crewId == crew.crewId); // 삭제된 항목만 제거
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            child: Text(
                                                              '신청 취소',
                                                              style: TextStyle(
                                                                color: SDSColor.gray500,
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                            style: TextButton.styleFrom(
                                                              backgroundColor: Colors.transparent, // 배경색 투명
                                                              splashFactory: NoSplash.splashFactory, // 터치 시 효과 제거
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
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
                          Get.toNamed(AppRoutes.searchCrew);
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
