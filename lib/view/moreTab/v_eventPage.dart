import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class EventPageView extends StatelessWidget {
  EventPageView({Key? key}) : super(key: key);

  // 더미 데이터
  final List<EventItem> _dummyEvents = [
    EventItem(
      category: '이벤트',
      date: '2024.12.01 ~ 2024.12.31',
      title: '겨울 시즌 오픈 기념 이벤트',
      url: 'https://example.com/event1',
    ),
    EventItem(
      category: '공지',
      date: '2024.11.15',
      title: '스노우라이브 서비스 업데이트 안내',
      url: 'https://example.com/notice1',
    ),
    EventItem(
      category: '이벤트',
      date: '2024.11.01 ~ 2024.11.30',
      title: '크루 랭킹 이벤트',
      url: 'https://example.com/event2',
    ),
    EventItem(
      category: '혜택',
      date: '2024.10.20 ~ 2024.12.20',
      title: '리프트권 할인 프로모션',
      url: 'https://example.com/benefit1',
    ),
    EventItem(
      category: '이벤트',
      date: '2024.10.01 ~ 2024.10.31',
      title: '친구 초대 이벤트',
      url: 'https://example.com/event3',
    ),
  ];

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

  Color _getCategoryColor(String category) {
    switch (category) {
      case '이벤트':
        return Color(0xFF4A90E2);
      case '공지':
        return Color(0xFFE24A4A);
      case '혜택':
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
      body: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _dummyEvents.length,
        separatorBuilder: (context, index) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = _dummyEvents[index];
          return _buildEventCard(event);
        },
      ),
    );
  }

  Widget _buildEventCard(EventItem event) {
    return GestureDetector(
      onTap: () => _launchURL(event.url),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: SDSColor.gray200!,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(event.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      event.category,
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 12,
                        color: _getCategoryColor(event.category),
                      ),
                    ),
                  ),
                  Spacer(),
                  Text(
                    event.date,
                    style: SDSTextStyle.regular.copyWith(
                      fontSize: 12,
                      color: SDSColor.gray500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.title,
                      style: SDSTextStyle.bold.copyWith(
                        fontSize: 15,
                        color: SDSColor.gray900,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: SDSColor.gray400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EventItem {
  final String category;
  final String date;
  final String title;
  final String url;

  EventItem({
    required this.category,
    required this.date,
    required this.title,
    required this.url,
  });
}