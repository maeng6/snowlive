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

class FleaMarketMainView extends StatefulWidget {
  const FleaMarketMainView({Key? key}) : super(key: key);

  @override
  State<FleaMarketMainView> createState() => _FleaMarketMainViewState();
}

class _FleaMarketMainViewState extends State<FleaMarketMainView> {
  final FleamarketListViewModel _fleamarketViewModel =
  Get.find<FleamarketListViewModel>();

  /// 헤더(검색 + 탭 + 배너) 보임 여부
  bool _isHeaderVisible = true;

  /// 헤더 실제 높이 (초기값은 대충 넣어두고, 빌드 후 정확히 측정해서 갱신)
  double _headerHeight = 220;

  /// 헤더 높이 측정을 위한 GlobalKey
  final GlobalKey _headerKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;

    // 빌드 완료 후 헤더 실제 높이 측정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHeaderHeight();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(44),
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
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
          backgroundColor: SDSColor.snowliveWhite,
          surfaceTintColor: SDSColor.snowliveWhite,
          elevation: 0.0,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            /// 1) 리스트 영역
            ///
            /// top 패딩 = 헤더 실제 높이
            /// 헤더가 숨을 때는 0으로 줄어들어서, 바로 윗부분까지 꽉 채움
            AnimatedPadding(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              padding: EdgeInsets.only(
                top: _isHeaderVisible ? _headerHeight : 0,
              ),
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
                  } else if (notification.direction == ScrollDirection.forward) {
                    // 위로 스크롤 → 헤더 보이기
                    if (!_isHeaderVisible) {
                      setState(() {
                        _isHeaderVisible = true;
                      });
                    }
                  }
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

            /// 2) 헤더(검색 + 탭 + 배너) 슬라이드 인/아웃
            Align(
              alignment: Alignment.topCenter,
              child: AnimatedSlide(
                offset: _isHeaderVisible
                    ? const Offset(0, 0)
                    : const Offset(0, -1), // 위로 스윽 올라가게
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeInOut,
                child: _buildHeader(_size),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단 헤더: 검색 / 탭 메뉴 / 배너
  Widget _buildHeader(Size size) {
    return Container(
      key: _headerKey, // ← 여기에 key 부착해서 높이 측정
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
              padding:
              const EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 10),
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

          // 탭 메뉴
          Stack(
            children: [
              // 헤더 하단 구분선
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
          // 배너
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

  /// 헤더 실제 높이 측정해서 _headerHeight 갱신
  void _updateHeaderHeight() {
    final ctx = _headerKey.currentContext;
    if (ctx == null) return;

    final box = ctx.findRenderObject();
    if (box is RenderBox) {
      final newHeight = box.size.height;
      if (newHeight != _headerHeight && newHeight > 0 && mounted) {
        setState(() {
          _headerHeight = newHeight;
        });
      }
    }
  }
}
