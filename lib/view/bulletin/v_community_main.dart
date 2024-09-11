import 'package:com.snowlive/view/bulletin/free/v_community_Bulletin_Total_List.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../screens/snowliveDesignStyle.dart';
import '../../viewmodel/vm_communityFreeList.dart';

class CommunityMainView extends StatelessWidget {

  final CommunityBulletinListViewModel _communityBulletinListViewModel = Get.find<CommunityBulletinListViewModel>();

  @override
  Widget build(BuildContext context) {

    Size _size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.white,
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(44),
          child: AppBar(
            elevation: 0.0,
            titleSpacing: 16,
            centerTitle: false,
            title: Text(
              '커뮤니티',
              style: SDSTextStyle.extraBold.copyWith(
                  color: SDSColor.gray900,
                  fontSize: 18),
            ),
            backgroundColor: Colors.white,
          ),
        ),
        body:
        SafeArea(
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                width: (_size.width - 40) / 2 ,
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '게시판',
                                    style: SDSTextStyle.extraBold.copyWith(
                                        color: (_communityBulletinListViewModel.tapName=='게시판')
                                            ? SDSColor.gray900
                                            : SDSColor.gray900.withOpacity(0.2),
                                        fontWeight: (_communityBulletinListViewModel.tapName=='게시판')
                                            ? FontWeight.w900
                                            : FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _communityBulletinListViewModel.changeTap('게시판');
                                  },
                                  style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.only(top: 0),
                                      minimumSize: Size(40, 10),
                                      backgroundColor: SDSColor.snowliveWhite,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                      shadowColor: Colors.transparent
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 78,
                              height: 3,
                              color:
                              (_communityBulletinListViewModel.tapName=='게시판') ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),//자게
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(bottom: 2),
                              child: Container(
                                width: (_size.width - 40) / 2 ,
                                height: 40,
                                child: ElevatedButton(
                                  child: Text(
                                    '행사·클리닉',
                                    style: SDSTextStyle.extraBold.copyWith(
                                        color: (_communityBulletinListViewModel.tapName=='행사·클리닉')
                                            ? SDSColor.gray900
                                            : SDSColor.gray900.withOpacity(0.2),
                                        fontWeight: (_communityBulletinListViewModel.tapName=='행사·클리닉')
                                            ? FontWeight.w900
                                            : FontWeight.w300,
                                        fontSize: 16),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    _communityBulletinListViewModel.changeTap('행사·클리닉');
                                  },
                                  style: ElevatedButton.styleFrom(
                                      splashFactory: NoSplash.splashFactory,
                                      padding: EdgeInsets.only(top: 0),
                                      minimumSize: Size(40, 10),
                                      backgroundColor: SDSColor.snowliveWhite,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                      shadowColor: Colors.transparent
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 86,
                              height: 3,
                              color:
                              (_communityBulletinListViewModel.tapName=='행사·클리닉') ? Color(0xFF111111) : Colors.transparent,
                            )
                          ],
                        ),//클리닉
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16, left: 0),
                    child: Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.total.korean);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Container(
                                          decoration: BoxDecoration(
                                            color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean)
                                                ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                            borderRadius: BorderRadius.circular(30.0),
                                            border: Border.all(
                                                color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean)
                                                    ? SDSColor.gray900 : SDSColor.gray200),
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                          height: 32,
                                          child: Text('${Community_Category_sub_bulletin.total.korean}',
                                            style: SDSTextStyle.bold.copyWith(
                                                fontSize: 13,
                                                fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean) ? FontWeight.bold : FontWeight.w300,
                                                color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.total.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                            ),)
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.free.korean);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.free.korean) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.free.korean) ? SDSColor.gray900 : SDSColor.gray200),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        height: 32,
                                        child: Text('${Community_Category_sub_bulletin.free.korean}',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 13,
                                              fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.free.korean) ? FontWeight.bold : FontWeight.w300,
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.free.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                          ),)
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.room.korean);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? SDSColor.gray900 : SDSColor.gray200),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        height: 32,
                                        child: Text('${Community_Category_sub_bulletin.room.korean}',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 13,
                                              fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? FontWeight.bold : FontWeight.w300,
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.room.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                          ),)
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: (){
                                      HapticFeedback.lightImpact();
                                      _communityBulletinListViewModel.changeChip(Community_Category_sub_bulletin.crew.korean);
                                    },
                                    child: Container(
                                        decoration: BoxDecoration(
                                          color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                          borderRadius: BorderRadius.circular(30.0),
                                          border: Border.all(
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? SDSColor.gray900 : SDSColor.gray200),
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                        height: 32,
                                        child: Text('${Community_Category_sub_bulletin.crew.korean}',
                                          style: SDSTextStyle.bold.copyWith(
                                              fontSize: 13,
                                              fontWeight: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? FontWeight.bold : FontWeight.w300,
                                              color: (_communityBulletinListViewModel.chipName==Community_Category_sub_bulletin.crew.korean) ? SDSColor.snowliveWhite : SDSColor.snowliveBlack
                                          ),)
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if(_communityBulletinListViewModel.tapName=='게시판'
                  && _communityBulletinListViewModel.chipName == Community_Category_sub_bulletin.total.korean)
                    Expanded(child: CommunityBulletinTotalListView()),
                  // if(_communityListViewModel.tapName=='행사·클리닉')
                    // Expanded(child: BulletinEventListView()),
                ],
              ),
            ],
          ),
        )


    );
  }
}


