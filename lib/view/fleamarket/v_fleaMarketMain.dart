import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_board.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_favorite.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_my.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_ski.dart';
import 'package:com.snowlive/view/fleamarket/v_fleaMarketList_total.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

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
        preferredSize: Size.fromHeight(44),
        child: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: false,
          titleSpacing: 0,
          title: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '스노우마켓',
              style: SDSTextStyle.extraBold.copyWith(
                  color: SDSColor.gray900,
                  fontSize: 18),
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
            Positioned(
              top: 98,
              child: Container(
                width: _size.width,
                height: 1,
                color: SDSColor.gray100,
              ),
            ),
            Obx(()=>Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoutes.fleamarketSearch);
                    },
                    child: Padding(
                      padding: EdgeInsets.only(top: 4, bottom: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: SDSColor.gray50,
                        ),
                        height: 40,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              Image.asset('assets/imgs/icons/icon_search.png',
                              width: 16,),
                              SizedBox(
                                width: 6,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 1),
                                child: Text(
                                  '상품 검색',
                                  style: SDSTextStyle.regular.copyWith(fontSize: 15, color: SDSColor.gray400),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 6),
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
                                              ? SDSColor.gray900
                                              : SDSColor.gray300,
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
                                      backgroundColor: SDSColor.snowliveWhite,
                                      overlayColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '전체')
                                    ? SDSColor.gray900
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6),
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
                                              ? SDSColor.gray900
                                              : SDSColor.gray300,
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
                                      backgroundColor: SDSColor.snowliveWhite,
                                      overlayColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 60,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '스키')
                                    ? SDSColor.gray900
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6),
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
                                              ? SDSColor.gray900
                                              : SDSColor.gray300,
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
                                      backgroundColor: SDSColor.snowliveWhite,
                                      overlayColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 76,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '스노보드')
                                    ? SDSColor.gray900
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6),
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
                                              ? SDSColor.gray900
                                              : SDSColor.gray300,
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
                                      backgroundColor: SDSColor.snowliveWhite,
                                      overlayColor: Colors.transparent,
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
                                    ? SDSColor.gray900
                                    : Colors.transparent,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 6),
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
                                              ? SDSColor.gray900
                                              : SDSColor.gray300,
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
                                      backgroundColor: SDSColor.snowliveWhite,
                                      overlayColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                width: 78,
                                height: 3,
                                color: (_fleamarketViewModel.tapName == '내 게시글')
                                    ? SDSColor.gray900
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
