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
            ),
            body: Obx(() {
              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: _crewApplyViewModel.crewApplyList.length,
                      itemBuilder: (context, index) {
                        var crew = _crewApplyViewModel.crewApplyList[index];

                        // 로고와 크루 정보를 가져오기
                        if (!_crewDetailViewModel.crewDetails.containsKey(crew.crewId)) {
                          _crewDetailViewModel.findCrewDetails(crew.crewId!, _friendDetailViewModel.seasonDate);
                        }

                        var crewInfo = _crewDetailViewModel.crewDetails[crew.crewId] ?? {
                          'logoUrl': '',
                          'name': '',
                          'description': ''
                        };

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: GestureDetector(
                            onTap: () async{
                              CustomFullScreenDialog.showDialog();
                              await _crewDetailViewModel.fetchCrewDetail(
                                  crew.crewId!,
                                  _friendDetailViewModel.seasonDate
                              );
                              await _crewMemberListViewModel.fetchCrewMembers(crewId: crew.crewId!);
                              CustomFullScreenDialog.cancelDialog();
                              Get.toNamed(AppRoutes.crewMain);
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
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          title: Text('가입 신청을 취소하시겠어요?',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16
                                          ),
                                            textAlign: TextAlign.center
                                          ),
                                          content: Text('가입 신청을 취소하셔도 다음에 다시\n가입 신청을 하실 수 있어요.',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: SDSColor.gray600
                                          ),
                                          textAlign: TextAlign.center
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
                                                CustomFullScreenDialog.cancelDialog();
                                                Get.back();
                                              },
                                              child: Text('신청 취소하기',
                                              style: TextStyle(
                                                color: SDSColor.snowliveWhite,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16
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
                                              child: Text('돌아가기',
                                                style: TextStyle(
                                                    color: SDSColor.snowliveBlack,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16
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
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                      side: BorderSide(
                                        color: SDSColor.gray300, // 테두리 색상 설정
                                        width: 1.0, // 테두리 두께 설정
                                      ),
                                    ),
                                    minimumSize: Size(41, 28),
                                  ),
                                  child: Text('신청취소',
                                      style: TextStyle(
                                        color: SDSColor.snowliveBlack,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // 하단의 다른 크루 찾아보기 버튼
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Get.offNamed(AppRoutes.searchCrew);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // 버튼 색상
                        padding: EdgeInsets.symmetric(vertical: 16),
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        '다른 크루 찾아보기',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold
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
