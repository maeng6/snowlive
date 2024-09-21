import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/crew/vm_crewNotice.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CrewNoticeListView extends StatelessWidget {

  final CrewNoticeViewModel _crewNoticeViewModel = Get.find<CrewNoticeViewModel>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 키보드 닫기
      },
      child: Scaffold(
        backgroundColor: Colors.white,
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
            '공지사항',
            style: TextStyle(
                color: SDSColor.snowliveBlack,
                fontSize: 18
            ),
          ),
          elevation: 0,
        ),
        body: Obx(() {
          if (_crewNoticeViewModel.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }

          if (_crewNoticeViewModel.noticeList.isEmpty) {
            return Center(
              child: Text('공지사항이 없습니다.'),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: _crewNoticeViewModel.noticeList.length,
            itemBuilder: (context, index) {
              final notice = _crewNoticeViewModel.noticeList[index];
              bool isLatest = index == 0; // 첫 번째 항목이 최신 공지

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notice.notice ?? '공지 없음',
                      style: TextStyle(
                        fontSize: 15,
                        color: SDSColor.snowliveBlack,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        if (isLatest) ...[
                          // 최신 공지 배경 강조 스타일
                          Container(
                            width: 50,  // 원하는 너비 설정
                            height: 20, // 원하는 높이 설정
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            decoration: BoxDecoration(
                              color: SDSColor.snowliveBlue,
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Center(
                              child: Text(
                                '최신 공지',
                                style: TextStyle(
                                  color: SDSColor.snowliveWhite,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 4),
                        ],
                        SizedBox(width: 8),
                        Text(
                          _crewNoticeViewModel.formatDateTime(notice.uploadTime!),
                          style: TextStyle(
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
                        SizedBox(width: 4),
                        Text(
                          _crewNoticeViewModel.getAuthorRole(notice.authorUserId!), // 작성자 역할
                          style: TextStyle(
                            fontSize: 12,
                            color: SDSColor.gray700,
                          ),
                        ),
                      ],
                    ),
                    Divider(thickness: 1, color: SDSColor.gray100), // 항목 구분선
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
