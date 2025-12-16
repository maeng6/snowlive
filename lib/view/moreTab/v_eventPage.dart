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

class EventPageView extends StatefulWidget {
  const EventPageView({Key? key}) : super(key: key);

  @override
  State<EventPageView> createState() => _EventPageViewState();
}

class _EventPageViewState extends State<EventPageView> {
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
        return const Color(0xFF3D83ED);
      case '모집':
        return const Color(0xFF3D83ED);
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
    return Scaffold(
      backgroundColor: SDSColor.snowliveWhite,
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
        title: Text(
          '이벤트·소식',
          style: SDSTextStyle.extraBold.copyWith(color: SDSColor.gray900, fontSize: 18),
        ),
        actions: [
          Obx(() => Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 12),
                    child: Stack(
                      children: [
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                              onPressed: () async {
                                HapticFeedback.lightImpact();
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
                                                    //전체
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '전체',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('전체');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //공지
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '공지',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('공지');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //이벤트
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '이벤트',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('이벤트');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //행사
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '행사',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('행사');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //시승회
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '시승회',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('시승회');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //클리닉
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '클리닉',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('클리닉');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //모집
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '모집',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('모집');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //프로모션
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '프로모션',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('프로모션');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                    //기타
                                                    ListTile(
                                                      contentPadding: EdgeInsets.zero,
                                                      title: Center(
                                                        child: Text(
                                                          '기타',
                                                          style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        Navigator.pop(context);
                                                        _eventViewModel.setCategory('기타');
                                                        await _eventViewModel.fetchEventList();
                                                      },
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    });
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
                                            height: MediaQuery.of(context).size.height * 0.5,
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: SingleChildScrollView(
                                              child: Wrap(
                                                children: [
                                                  //전체
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '전체',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('전체');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //공지
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '공지',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('공지');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //이벤트
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '이벤트',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('이벤트');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //행사
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '행사',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('행사');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //시승회
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '시승회',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('시승회');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //클리닉
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '클리닉',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('클리닉');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //모집
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '모집',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('모집');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //프로모션
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '프로모션',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('프로모션');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                  //기타
                                                  ListTile(
                                                    contentPadding: EdgeInsets.zero,
                                                    title: Center(
                                                      child: Text(
                                                        '기타',
                                                        style: SDSTextStyle.bold.copyWith(fontSize: 15, color: SDSColor.gray900),
                                                      ),
                                                    ),
                                                    onTap: () async {
                                                      Navigator.pop(context);
                                                      _eventViewModel.setCategory('기타');
                                                      await _eventViewModel.fetchEventList();
                                                    },
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    });
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
                  ),
                ],
              )),
        ],
      ),
      body: Column(
        children: [
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
                // ✅ 최초 진입 로딩
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

                // ✅ 데이터 없음
                if (_eventViewModel.eventList.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: const Center(
                        child: Text('등록된 글이 없습니다.'),
                      ),
                    ),
                  );
                }

                final int listLen = _eventViewModel.eventList.length;

                /// ⭐ 핵심
                /// - 다음 페이지가 있거나
                /// - 이미 로딩 중이면
                /// → 하단 슬롯을 반드시 만든다
                final bool showBottomSlot = _eventViewModel.hasNextPage || _eventViewModel.isLoadingMore.value;

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
