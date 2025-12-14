import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_event.dart';
import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:com.snowlive/model/m_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class EventPageView extends StatefulWidget {
  EventPageView({Key? key}) : super(key: key);

  @override
  State<EventPageView> createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {
  final EventViewModel _eventViewModel = Get.put(EventViewModel());
  final EventAlarmViewModel _eventAlarmViewModel = Get.find<EventAlarmViewModel>();

  @override
  void initState() {
    super.initState();
    _eventViewModel.fetchEventList();
    // 이벤트 페이지 진입 시 읽음 처리
    _eventAlarmViewModel.markAsRead();
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        '오류',
        'URL을 열 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    return DateFormat('yyyy.MM.dd').format(dateTime);
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '클리닉':
        return Color(0xFF4A90E2);
      case '공지':
        return Color(0xFFE24A4A);
      case '행사':
        return Color(0xFF50C878);
      case '시승회':
        return Color(0xFF50C878);
      default:
        return SDSColor.gray500!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 44,
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
            Navigator.pop(context);
          },
        ),
        elevation: 0.0,
        titleSpacing: 0,
        centerTitle: true,
        title: Text('이벤트 모음',
          style: SDSTextStyle.extraBold.copyWith(
              color: SDSColor.gray900,
              fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // 테이블 헤더 (고정)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SDSColor.gray50,
              border: Border(
                bottom: BorderSide(color: SDSColor.gray200!, width: 1),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 60,
                  child: Text(
                    '분류',
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 13,
                      color: SDSColor.gray600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '제목',
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 13,
                      color: SDSColor.gray600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '등록일',
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.bold.copyWith(
                      fontSize: 13,
                      color: SDSColor.gray600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 게시판 목록 (당겨서 새로고침 가능)
          Expanded(
            child: RefreshIndicator(
              strokeWidth: 2,
              edgeOffset: -40,
              displacement: 40,
              backgroundColor: SDSColor.snowliveBlue,
              color: SDSColor.snowliveWhite,
              onRefresh: _eventViewModel.fetchEventList,
              child: Obx(() {
                // 로딩 중일 때 인디케이터 표시
                if (_eventViewModel.isLoading.value && _eventViewModel.eventList.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: SDSColor.snowliveBlue,
                    ),
                  );
                }

                // 데이터가 없을 때
                if (_eventViewModel.eventList.isEmpty) {
                  return SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: SDSColor.gray400,
                            ),
                            SizedBox(height: 16),
                            Text(
                              '등록된 이벤트가 없습니다.',
                              style: SDSTextStyle.regular.copyWith(
                                fontSize: 14,
                                color: SDSColor.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(),
                  controller: _eventViewModel.scrollController,
                  itemCount: _eventViewModel.eventList.length + (_eventViewModel.hasNextPage ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _eventViewModel.eventList.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: SDSColor.snowliveBlue,
                          ),
                        ),
                      );
                    }
                    final event = _eventViewModel.eventList[index];
                    return _buildEventRow(event);
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventRow(EventModel event) {
    return GestureDetector(
      onTap: () {
        print(1);
        if (event.landingUrl != null && event.landingUrl!.isNotEmpty) {
          _launchURL(event.landingUrl!);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: SDSColor.gray100!, width: 1),
          ),
        ),
        child: Row(
          children: [
            // 분류
            SizedBox(
              width: 60,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getCategoryColor(event.category ?? '').withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  event.category ?? '',
                  textAlign: TextAlign.center,
                  style: SDSTextStyle.bold.copyWith(
                    fontSize: 11,
                    color: _getCategoryColor(event.category ?? ''),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(width: 12),
            // 제목
            Expanded(
              child: Text(
                event.title ?? '',
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 14,
                  color: SDSColor.gray900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 12),
            // 등록일
            SizedBox(
              width: 80,
              child: Text(
                _formatDate(event.uploadTime),
                textAlign: TextAlign.center,
                style: SDSTextStyle.regular.copyWith(
                  fontSize: 12,
                  color: SDSColor.gray500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}