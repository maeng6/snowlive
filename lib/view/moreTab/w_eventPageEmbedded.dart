import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/viewmodel/vm_event.dart';
import 'package:com.snowlive/viewmodel/vm_eventAlarm.dart';
import 'package:com.snowlive/model/m_event.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

/// 커뮤니티 탭 내에서 사용할 수 있는 이벤트 페이지 (AppBar 없음)
class EventPageEmbeddedView extends StatefulWidget {
  const EventPageEmbeddedView({Key? key}) : super(key: key);

  @override
  State<EventPageEmbeddedView> createState() => _EventPageEmbeddedViewState();
}

class _EventPageEmbeddedViewState extends State<EventPageEmbeddedView> {
  final EventViewModel _eventViewModel = Get.put(EventViewModel());
  final EventAlarmViewModel _eventAlarmViewModel = Get.find<EventAlarmViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

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
        return const Color(0xFF34A853);
      case '시승회':
        return const Color(0xFF34A853);
      case '공지':
        return const Color(0xFF0066FF);
      case '모집':
        return const Color(0xFF0066FF);
      case '행사':
        return const Color(0xFF7543CC);
      case '이벤트':
        return const Color(0xFF7543CC);
      case '프로모션':
        return const Color(0xFF7543CC);
      case '기타':
        return const Color(0xFF7543CC);
      default:
        return SDSColor.gray500!;
    }
  }

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Column(
      children: [
        /// 카테고리 필터 버튼
        Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Stack(
                children: [
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          _showCategoryBottomSheet(context);
                        },
                        style: ElevatedButton.styleFrom(
                            shadowColor: Colors.transparent,
                            overlayColor: Colors.transparent,
                            padding: EdgeInsets.only(right: 32, left: 12, top: 3, bottom: 2),
                            side: BorderSide(
                              width: 1,
                              color: (_eventViewModel.selectedCategory != '전체') ? SDSColor.gray900 : SDSColor.gray100,
                            ),
                            backgroundColor: (_eventViewModel.selectedCategory != '전체') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50))),
                        child: Text('${_eventViewModel.selectedCategory}',
                            style: SDSTextStyle.bold.copyWith(fontSize: 13, color: (_eventViewModel.selectedCategory != '전체') ? Color(0xFFFFFFFF) : Color(0xFF111111)))),
                  ),
                  Positioned(
                    right: 10,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.5),
                      child: GestureDetector(
                        onTap: () async {
                          _showCategoryBottomSheet(context);
                        },
                        child: (_eventViewModel.selectedCategory != '전체')
                            ? Image.asset(
                          'assets/imgs/icons/icon_check_round.png',
                          fit: BoxFit.cover,
                          width: 16,
                          height: 16,
                        )
                            : Image.asset(
                          'assets/imgs/icons/icon_check_round_black.png',
                          fit: BoxFit.cover,
                          width: 16,
                          height: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )),

        /// 테이블 헤더
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: SDSColor.snowliveWhite,
          child: Row(
            children: const [
              SizedBox(
                width: 56,
                child: Center(
                  child: Text(
                    '분류',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SDSColor.snowliveBlack),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '제목',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SDSColor.snowliveBlack),
                  ),
                ),
              ),
              SizedBox(
                width: 72,
                child: Center(
                  child: Text(
                    '등록일',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: SDSColor.snowliveBlack),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: _size.width,
          height: 1,
          color: SDSColor.gray50,
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
              // 최초 진입 로딩
              if (_eventViewModel.isLoading.value && _eventViewModel.eventList.isEmpty) {
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

              // 데이터 없음
              if (_eventViewModel.eventList.isEmpty) {
                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const Center(
                      child: Text('등록된 글이 없습니다.'),
                    ),
                  ),
                );
              }

              final int listLen = _eventViewModel.eventList.length;
              final bool showBottomSlot = _eventViewModel.hasNextPage || _eventViewModel.isLoadingMore.value;

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                controller: _eventViewModel.scrollController,
                itemCount: listLen + (showBottomSlot ? 1 : 0),
                itemBuilder: (context, index) {
                  // 하단 페이지네이션 슬롯
                  if (index == listLen) {
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
    );
  }

  void _showCategoryBottomSheet(BuildContext context) {
    showModalBottomSheet(
        enableDrag: false,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        context: context,
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Container(
                margin: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 16,
                ),
                height: MediaQuery.of(context).size.height * 0.6,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Scrollbar(
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: [
                        _buildCategoryTile('전체'),
                        _buildCategoryTile('공지'),
                        _buildCategoryTile('이벤트'),
                        _buildCategoryTile('행사'),
                        _buildCategoryTile('시승회'),
                        _buildCategoryTile('클리닉'),
                        _buildCategoryTile('모집'),
                        _buildCategoryTile('프로모션'),
                        _buildCategoryTile('기타'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Widget _buildCategoryTile(String category) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Center(
        child: Text(
          category,
          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
        ),
      ),
      onTap: () async {
        Navigator.pop(context);
        _eventViewModel.setCategory(category);
        await _eventViewModel.fetchEventList();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildEventRow(EventModel event) {
    return GestureDetector(
      onTap: () {
        if (event.landingUrl?.isNotEmpty == true) {
          _launchURL(event.landingUrl!);
          _eventViewModel.addViewCount(user_id: _userViewModel.user.user_id, event_id: event.eventId!);
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: SDSColor.gray50!, width: 1),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 2, vertical: 3),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(event.category ?? '').withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    event.category ?? '',
                    textAlign: TextAlign.center,
                    style: SDSTextStyle.extraBold.copyWith(
                      fontSize: 12,
                      color: _getCategoryColor(event.category ?? ''),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  event.title ?? '',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: Text(
                  _formatDate(event.uploadTime),
                  style: TextStyle(fontSize: 13, color: Color(0xFF949494)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}