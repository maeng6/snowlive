import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewMemberList.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewNotice.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewNoticeListView extends StatelessWidget {
  final CrewNoticeViewModel _crewNoticeViewModel = Get.find<CrewNoticeViewModel>();
  final CrewMemberListViewModel _crewMemberListViewModel = Get.find<CrewMemberListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();



  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;

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
            '공지사항',
            style: TextStyle(
                color: SDSColor.snowliveBlack,
                fontSize: 18
            ),
          ),
          elevation: 0,
          toolbarHeight: 44,
        ),
        body: Obx(() {
          if (_crewNoticeViewModel.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (_crewNoticeViewModel.noticeList.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.only(top: _size.height / 4),
                child: Container(
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/imgs/icons/icon_nodata.png',
                        scale: 4,
                        width: 64,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text('공지사항이 없습니다.',
                        style: SDSTextStyle.regular.copyWith(
                            fontSize: 13,
                            color: SDSColor.gray500
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 40),
            itemCount: _crewNoticeViewModel.noticeList.length,
            itemBuilder: (context, index) {
              final notice = _crewNoticeViewModel.noticeList[index];
              bool isLatest = index == 0; // 첫 번째 항목이 최신 공지
              final isCrewLeader = _crewMemberListViewModel.getMemberRole(_userViewModel.user.user_id) == '크루장';
              final isAuthor = notice.authorUserId == _userViewModel.user.user_id;

              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notice.notice ?? '공지 없음',
                            style: SDSTextStyle.regular.copyWith(
                              fontSize: 15,
                              color: SDSColor.gray900,
                            ),
                          ),
                        ),
                        if(isCrewLeader || isAuthor)
                          GestureDetector(
                            onTap: () {
                              // 더보기 아이콘 클릭 시 수행할 작업
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true, // 전체 화면 제어 가능
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  double modalHeight;

                                  if (isAuthor) {
                                    modalHeight = 150; // 수정 및 삭제 모두 가능할 때
                                  } else if (isCrewLeader) {
                                    modalHeight = 100; // 크루장일 때, 삭제만 가능할 때
                                  } else {
                                    modalHeight = 0; // 해당하지 않으면 모달을 띄우지 않음 (이 조건은 필요에 따라 설정)
                                  }

                                  return Padding(
                                    padding: EdgeInsets.only(left: 16, right: 16, bottom: 48), // 양옆과 아래를 띄움
                                    child: Container(
                                      height: modalHeight, // 조건에 따른 모달 높이 설정
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16), // 모서리 둥글게 설정
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          if (isCrewLeader && !isAuthor) ...[
                                            ListTile(
                                              title: Center(child: Text('공지사항 삭제하기',
                                                  style: TextStyle(
                                                      color: SDSColor.snowliveBlack,
                                                      fontWeight: FontWeight.bold
                                                  ))),
                                              onTap: () {
                                                // 삭제 기능 호출
                                                Navigator.pop(context); // 모달 닫기
                                                _crewNoticeViewModel.deleteCrewNotice(notice.authorUserId!, notice.noticeCrewId!); // 삭제 로직 실행
                                              },
                                            ),
                                          ],
                                          if (isAuthor)
                                            Column(
                                              children: [
                                                ListTile(
                                                  title: Center(
                                                    child: Text('공지사항 수정하기',
                                                        style: TextStyle(
                                                            color: SDSColor.snowliveBlack,
                                                            fontWeight: FontWeight.bold
                                                        )),
                                                  ),
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Get.toNamed(
                                                        AppRoutes.crewNoticeModify,
                                                        arguments: {
                                                          'noticeId': notice.noticeCrewId,
                                                          'noticeText': notice.notice,
                                                        });

                                                  },
                                                ),
                                                ListTile(
                                                  title: Center(child: Text('공지사항 삭제하기',
                                                      style: TextStyle(
                                                          color: SDSColor.red,
                                                          fontWeight: FontWeight.bold
                                                      ))),
                                                  onTap: () {
                                                    // 삭제 기능 호출
                                                    Navigator.pop(context); // 모달 닫기
                                                    _crewNoticeViewModel.deleteCrewNotice(notice.authorUserId!, notice.noticeCrewId!); // 삭제 로직 실행
                                                  },
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(
                              Icons.more_horiz,
                              color: SDSColor.gray200,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (isLatest) ...[
                          // 최신 공지 배경 강조 스타일
                          Container(
                            width: 52,  // 원하는 너비 설정
                            height: 22, // 원하는 높이 설정
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            decoration: BoxDecoration(
                              color: SDSColor.snowliveBlue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: Text(
                                '최신 공지',
                                style: SDSTextStyle.bold.copyWith(
                                  color: SDSColor.snowliveWhite,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(width: 8),
                        Text(
                          _crewNoticeViewModel.formatDateTime(notice.uploadTime!),
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 12,
                            color: SDSColor.gray700,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text('·',
                            style: TextStyle(
                                color: SDSColor.gray700
                            ),
                          ),
                        ),
                        Text(
                          _crewNoticeViewModel.getAuthorInfo(notice.authorUserId!), // 작성자 이름
                          style: TextStyle(
                            fontSize: 12,
                            color: SDSColor.gray700,
                          ),
                        ),
                        SizedBox(width: 1),
                        Text(
                          _crewNoticeViewModel.getAuthorRole(notice.authorUserId!), // 작성자 역할
                          style: TextStyle(
                            fontSize: 12,
                            color: SDSColor.gray700,
                          ),
                        ),
                      ],
                    ),
                    
                    Divider(
                        thickness: 1,
                        color: SDSColor.gray100,
                      height: 40,
                    ), // 항목 구분선
                  ],
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
