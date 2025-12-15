import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_event.dart';
import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:com.snowlive/model/m_event.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

class EventPageView extends StatefulWidget {
  const EventPageView({Key? key}) : super(key: key);

  @override
  State<EventPageView> createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {
  final EventViewModel _eventViewModel = Get.put(EventViewModel());
  final EventAlarmViewModel _eventAlarmViewModel =
  Get.find<EventAlarmViewModel>();

  @override
  void initState() {
    super.initState();
    _eventViewModel.fetchEventList();
    _eventAlarmViewModel.markAsRead();
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        '오류',
        'URL을 열 수 없습니다.',
        snackPosition: SnackPosition.BOTTOM,
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
        return const Color(0xFF4A90E2);
      case '공지':
        return const Color(0xFFE24A4A);
      case '행사':
        return const Color(0xFFE24A4A);
      case '시승회':
        return const Color(0xFF50C878);
      case '기타':
        return const Color(0xFF50C850);
      case '이벤트':
        return const Color(0xFF50C850);
      case '모집':
        return const Color(0xFF50C850);
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
          /// 테이블 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: SDSColor.gray50,
            child: Row(
              children: const [
                SizedBox(width: 60, child: Center(child: Text('분류'))),
                Expanded(child: Center(child: Text('제목'))),
                SizedBox(width: 80, child: Center(child: Text('등록일'))),
              ],
            ),
          ),

          /// 리스트
          Expanded(
            child: RefreshIndicator(
              strokeWidth: 2,
              edgeOffset: -25,
              backgroundColor: SDSColor.snowliveBlue,
              color: SDSColor.snowliveWhite,
              onRefresh: _eventViewModel.refresh,
              child: Obx(() {
                // ✅ 최초 진입 로딩
                if (_eventViewModel.isLoading.value &&
                    _eventViewModel.eventList.isEmpty) {
                  return Center(
                    child: SizedBox(
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

                // ✅ 데이터 없음
                if (_eventViewModel.eventList.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: Text('등록된 이벤트가 없습니다.'),
                      ),
                    ),
                  );
                }

                final int listLen = _eventViewModel.eventList.length;

                /// ⭐ 핵심
                /// - 다음 페이지가 있거나
                /// - 이미 로딩 중이면
                /// → 하단 슬롯을 반드시 만든다
                final bool showBottomSlot =
                    _eventViewModel.hasNextPage ||
                        _eventViewModel.isLoadingMore.value;

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  controller: _eventViewModel.scrollController,
                  itemCount: listLen + (showBottomSlot ? 1 : 0),
                  itemBuilder: (context, index) {
                    // ✅ 하단 페이지네이션 슬롯
                    if (index == listLen) {
                      // ⭐ 다음 페이지 요청 중이면 항상 인디케이터 표시
                      if (_eventViewModel.isLoadingMore.value) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Center(
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 4,
                                backgroundColor: SDSColor.gray100,
                                color: SDSColor.gray300.withOpacity(0.6),
                              ),
                            ),
                          ),
                        );
                      }

                      // 다음 페이지는 있지만 아직 로딩 전이면 빈 공간
                      return const SizedBox.shrink();
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
        if (event.landingUrl?.isNotEmpty == true) {
          _launchURL(event.landingUrl!);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: SDSColor.gray100!, width: 1),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color:
                  _getCategoryColor(event.category ?? '').withOpacity(0.1),
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
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                event.title ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 80,
              child: Text(
                _formatDate(event.uploadTime),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
