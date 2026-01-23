import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_board.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_favorite.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_my.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_ski.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_total.dart';
import 'package:com.snowlive/view/banner/v_banner_fleaMarket.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FleaMarketMainView extends StatefulWidget {
  const FleaMarketMainView({Key? key}) : super(key: key);

  @override
  State<FleaMarketMainView> createState() => _FleaMarketMainViewState();
}

// AnimatedSize를 쓰려면 TickerProvider가 필요해서 mixin 추가
class _FleaMarketMainViewState extends State<FleaMarketMainView>
    with SingleTickerProviderStateMixin {
  final FleamarketListViewModel _fleamarketViewModel =
  Get.find<FleamarketListViewModel>();

  /// 헤더(검색 + 탭 + 배너) 보임 여부
  bool _isHeaderVisible = true;

  /// 키워드 알림 툴팁 표시 여부
  bool _showAlertTooltip = false;

  static const String _tooltipKey = 'hasSeenFleamarketAlertTooltip';

  @override
  void initState() {
    super.initState();
    _checkTooltipStatus();
  }

  Future<void> _checkTooltipStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeen = prefs.getBool(_tooltipKey) ?? false;
    if (!hasSeen && mounted) {
      setState(() {
        _showAlertTooltip = true;
      });
    }
  }

  Future<void> _dismissTooltip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tooltipKey, true);
    if (mounted) {
      setState(() {
        _showAlertTooltip = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size _size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '중고거래',
              style: SDSTextStyle.extraBold.copyWith(
                color: SDSColor.gray900,
                fontSize: 18,
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                if (_showAlertTooltip) {
                  _dismissTooltip();
                }
                Get.toNamed(AppRoutes.fleamarketAlertSettings);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Image.asset(
                  'assets/imgs/icons/icon_header_setting.png',
                  width: 26,
                  height: 26,
                  color: SDSColor.gray900,
                ),
              ),
            ),
          ],
          backgroundColor: SDSColor.snowliveWhite,
          surfaceTintColor: SDSColor.snowliveWhite,
          elevation: 0.0,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // 1) 헤더 영역 (검색 + 탭 + 배너)
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 1.0, end: _isHeaderVisible ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  builder: (context, factor, child) {
                    return ClipRect(
                      child: Align(
                        alignment: Alignment.topCenter,
                        heightFactor: factor,   // ✅ 세로만 줄임
                        child: child,
                      ),
                    );
                  },
                  child: _buildHeader(_size),  // ✅ child는 항상 유지(레이아웃 안정)
                ),

                /// 2) 리스트 영역 – 항상 남은 영역을 꽉 채움
                Expanded(
                  child: NotificationListener<UserScrollNotification>(
                    onNotification: (notification) {
                      // 스크롤 방향에 따라 헤더 숨기기/보이기
                      if (notification.direction == ScrollDirection.reverse) {
                        // 아래로 스크롤 → 헤더 숨김
                        if (_isHeaderVisible) {
                          setState(() {
                            _isHeaderVisible = false;
                          });
                        }
                      } else if (notification.direction ==
                          ScrollDirection.forward) {
                        // 위로 스크롤 → 헤더 보이기
                        if (!_isHeaderVisible) {
                          setState(() {
                            _isHeaderVisible = true;
                          });
                        }
                      }

                      // 최상단에 도달하면 무조건 헤더 다시 보이게 하고 싶으면:
                      // if (notification.metrics.pixels <= 0 && !_isHeaderVisible) {
                      //   setState(() => _isHeaderVisible = true);
                      // }

                      return false;
                    },
                    child: Obx(() {
                      final tapName = _fleamarketViewModel.tapName;

                      if (tapName == '전체') {
                        return FleaMarketListView_total();
                      } else if (tapName == '스키') {
                        return FleaMarketListView_ski();
                      } else if (tapName == '스노보드') {
                        return FleaMarketListView_board();
                      } else if (tapName == '찜 목록') {
                        return FleaMarketListView_favorite();
                      } else if (tapName == '내 게시글') {
                        return FleaMarketListView_my();
                      } else {
                        return const SizedBox.shrink();
                      }
                    }),
                  ),
                ),
              ],
            ),
          ),
          // 키워드 알림 툴팁 (오버레이)
          if (_showAlertTooltip)
            Positioned(
              top: MediaQuery.of(context).padding.top + 44,
              right: 8,
              child: _buildAlertTooltip(),
            ),
        ],
      ),
    );
  }

  /// 상단 헤더: 검색 / 탭 메뉴 / 배너
  Widget _buildHeader(Size size) {
    return Container(
      width: size.width,
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 검색 영역
          GestureDetector(
            onTap: () {
              Get.toNamed(AppRoutes.fleamarketSearch);
            },
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 4, bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: SDSColor.gray50,
                ),
                height: 40,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/imgs/icons/icon_search.png',
                        width: 16,
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 1),
                        child: Text(
                          '상품 검색',
                          style: SDSTextStyle.regular.copyWith(
                            fontSize: 14,
                            color: SDSColor.gray400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 탭 메뉴 + 아래 구분선
          Stack(
            children: [
              Positioned(
                bottom: 1,
                child: Container(
                  width: size.width,
                  height: 1,
                  color: SDSColor.gray100,
                ),
              ),
              Obx(
                    () => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      _buildTapButton('전체', 60),
                      _buildTapButton('스키', 60),
                      _buildTapButton('스노보드', 76),
                      _buildTapButton('찜 목록', 68),
                      _buildTapButton('내 게시글', 78),
                      const SizedBox(width: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 배너 (보이든/안 보이든 자연스럽게 포함됨)
          Banner_fleaMarket(),
        ],
      ),
    );
  }

  /// 탭 버튼 공통 위젯
  Widget _buildTapButton(String label, double underlineWidth) {
    final bool isSelected = _fleamarketViewModel.tapName == label;

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: SizedBox(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  _fleamarketViewModel.changeTap(label);
                },
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                  overlayColor: Colors.transparent,
                  padding: const EdgeInsets.only(top: 0),
                  minimumSize: const Size(40, 10),
                  backgroundColor: SDSColor.snowliveWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? SDSColor.gray900 : SDSColor.gray300,
                    fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: underlineWidth,
            height: 3,
            color: isSelected ? SDSColor.gray900 : Colors.transparent,
          ),
        ],
      ),
    );
  }

  /// 키워드 알림 툴팁 위젯
  Widget _buildAlertTooltip() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        _dismissTooltip();
        Get.toNamed(AppRoutes.fleamarketAlertSettings);
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 말풍선 꼬리 (삼각형)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: CustomPaint(
              size: const Size(10, 6),
              painter: _TooltipArrowPainter(),
            ),
          ),
          // 말풍선 본체
          Container(
            padding: const EdgeInsets.only(left: 12, right: 6, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: SDSColor.gray900,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '키워드 알림을 설정해 보세요!',
                  style: SDSTextStyle.regular.copyWith(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _dismissTooltip();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: SDSColor.gray300,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 툴팁 화살표 페인터
class _TooltipArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SDSColor.gray900
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
