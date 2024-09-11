import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_board.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_favorite.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_my.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_ski.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_total.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../viewmodel/vm_fleamarketList.dart';

class FleaMarketMainView extends StatelessWidget {
  FleaMarketMainView({Key? key}) : super(key: key);

  final FleamarketListViewModel _fleamarketViewModel = Get.find<FleamarketListViewModel>();

  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(106),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppBar(
              automaticallyImplyLeading: false,
              iconTheme: IconThemeData(size: 26, color: Colors.black87),
              centerTitle: false,
              titleSpacing: 0,
              title: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  '스노우마켓',
                  style: TextStyle(
                      color: Color(0xFF111111),
                      fontWeight: FontWeight.bold,
                      fontSize: 20),
                ),
              ),
              backgroundColor: Colors.white,
              elevation: 0.0,
            ),
            GestureDetector(
              onTap: () {
                Get.toNamed(AppRoutes.fleamarketSearch);
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Color(0xFFEFEFEF),
                  ),
                  height: 50,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Color(0xFF666666),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 1),
                          child: Text(
                            '상품 검색',
                            style:
                            TextStyle(fontSize: 15, color: Color(0xFF666666)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 44,
              child: Container(
                width: _size.width,
                height: 1,
                color: Color(0xFFECECEC),
              ),
            ),
            Obx(()=>Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    child: Text(
                                      '전체',
                                      style: TextStyle(
                                          color: (_fleamarketViewModel.tapName == '전체')
                                              ? Color(0xFF111111)
                                              : Color(0xFFC8C8C8),
                                          fontWeight: (_fleamarketViewModel.tapName == '전체')
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      print('전체 페이지로 전환');
                                      _fleamarketViewModel.changeTap('전체');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.only(top: 0),
                                      minimumSize: Size(40, 10),
                                      backgroundColor: Color(0xFFFFFFFF),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 68,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '전체')
                                    ? Color(0xFF111111)
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    child: Text(
                                      '스키',
                                      style: TextStyle(
                                          color: (_fleamarketViewModel.tapName == '스키')
                                              ? Color(0xFF111111)
                                              : Color(0xFFC8C8C8),
                                          fontWeight: (_fleamarketViewModel.tapName == '스키')
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      print('스키 페이지로 전환');
                                      _fleamarketViewModel.changeTap('스키');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.only(top: 0),
                                      minimumSize: Size(40, 10),
                                      backgroundColor: Color(0xFFFFFFFF),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 68,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '스키')
                                    ? Color(0xFF111111)
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    child: Text(
                                      '스노보드',
                                      style: TextStyle(
                                          color: (_fleamarketViewModel.tapName == '스노보드')
                                              ? Color(0xFF111111)
                                              : Color(0xFFC8C8C8),
                                          fontWeight: (_fleamarketViewModel.tapName == '스노보드')
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      print('스노보드 페이지로 전환');
                                      _fleamarketViewModel.changeTap('스노보드');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.only(top: 0),
                                      minimumSize: Size(40, 10),
                                      backgroundColor: Color(0xFFFFFFFF),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 68,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '스노보드')
                                    ? Color(0xFF111111)
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    child: Text(
                                      '찜 목록',
                                      style: TextStyle(
                                          color: (_fleamarketViewModel.tapName == '찜 목록')
                                              ? Color(0xFF111111)
                                              : Color(0xFFC8C8C8),
                                          fontWeight: (_fleamarketViewModel.tapName == '찜 목록')
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      print('찜 목록 페이지로 전환');
                                      _fleamarketViewModel.changeTap('찜 목록');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.only(top: 0),
                                      minimumSize: Size(40, 10),
                                      backgroundColor: Color(0xFFFFFFFF),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 68,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '찜 목록')
                                    ? Color(0xFF111111)
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 12),
                          child: Column(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 2),
                                child: Container(
                                  height: 40,
                                  child: ElevatedButton(
                                    child: Text(
                                      '내 게시글',
                                      style: TextStyle(
                                          color: (_fleamarketViewModel.tapName == '내 게시글')
                                              ? Color(0xFF111111)
                                              : Color(0xFFC8C8C8),
                                          fontWeight: (_fleamarketViewModel.tapName == '내 게시글')
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16),
                                    ),
                                    onPressed: () {
                                      HapticFeedback.lightImpact();
                                      print('내 게시글 페이지로 전환');
                                      _fleamarketViewModel.changeTap('내 게시글');
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.only(top: 0),
                                      minimumSize: Size(40, 10),
                                      backgroundColor: Color(0xFFFFFFFF),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 68,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '내 게시글')
                                    ? Color(0xFF111111)
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),

                      ],
                    ),
                  ),
                  if (_fleamarketViewModel.tapName == '전체')
                    Expanded(child: FleaMarketListView_total()),
                  if (_fleamarketViewModel.tapName == '스키')
                    Expanded(child: FleaMarketListView_ski()),
                  if (_fleamarketViewModel.tapName == '스노보드')
                    Expanded(child: FleaMarketListView_board()),
                  if (_fleamarketViewModel.tapName == '찜 목록')
                    Expanded(child: FleaMarketListView_favorite()),
                  if (_fleamarketViewModel.tapName == '내 게시글')
                    Expanded(child: FleaMarketListView_my()),
                ],
              ),
            )),
          ],
        ),
      )
    );
  }
}
