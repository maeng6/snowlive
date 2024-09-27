import 'package:com.snowlive/data/snowliveDesignStyle.dart';
import 'package:com.snowlive/model/m_fleamarket.dart';
import 'package:com.snowlive/routes/routes.dart';
import 'package:com.snowlive/util/util_1.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketDetail.dart';
import 'package:com.snowlive/viewmodel/fleamarket/vm_fleamarketList.dart';
import 'package:com.snowlive/viewmodel/vm_user.dart';
import 'package:com.snowlive/widget/w_fullScreenDialog.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class FleaMarketListView_total extends StatelessWidget {

  final f = NumberFormat('###,###,###,###');

  final FleamarketListViewModel _fleamarketListViewModel = Get.find<FleamarketListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();
  final FleamarketDetailViewModel _fleamarketDetailViewModel = Get.find<FleamarketDetailViewModel>();


  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        color: Colors.white,
        child: Scaffold(
          floatingActionButton: Obx(()=>Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Obx(()=> Visibility(
                  visible: _fleamarketListViewModel.isVisible_total,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Container(
                      width: 106,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(50),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: FloatingActionButton(
                        heroTag: 'fleamarketList',
                        mini: true,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          side: BorderSide(color: SDSColor.gray200),
                        ),
                        backgroundColor: SDSColor.snowliveWhite,
                        foregroundColor: SDSColor.snowliveWhite,
                        onPressed: () {
                          _fleamarketListViewModel.scrollController_total.jumpTo(0);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(Icons.arrow_upward_rounded,
                                color: SDSColor.gray900,
                                size: 16),
                            Padding(
                              padding: const EdgeInsets.only(left: 2, right: 3),
                              child: Text('최신글 보기',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: SDSColor.gray900,
                                    letterSpacing: 0
                                ),),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
              ),
              Positioned(
                child: Transform.translate(
                  offset: Offset(18, 0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedContainer(
                      width: _fleamarketListViewModel.showAddButton_total ? 104 : 52,
                      height: 52,
                      duration: Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        elevation: 4,
                        heroTag: 'fleaListScreen',
                        onPressed: () {
                          Get.toNamed(AppRoutes.fleamarketUpload);
                        },
                        icon: Transform.translate(
                            offset: Offset(6,0),
                            child: Center(child: Icon(Icons.add,
                              color: SDSColor.snowliveWhite,
                            ))),
                        label: _fleamarketListViewModel.showAddButton_total
                            ? Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('글쓰기',
                            style: SDSTextStyle.bold.copyWith(
                                letterSpacing: 0.5,
                                fontSize: 15,
                                color: SDSColor.snowliveWhite,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                            : SizedBox.shrink(), // Hide the text when _showAddButton is false
                        backgroundColor: SDSColor.snowliveBlue,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: Colors.white,
          body: Obx(()=>RefreshIndicator(
              strokeWidth: 2,
              edgeOffset: 20,
              backgroundColor: SDSColor.snowliveWhite,
              color: SDSColor.snowliveBlue,
              onRefresh: _fleamarketListViewModel.onRefresh_flea_total,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  children: [
                    //필터
                    Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
                                      showModalBottomSheet(
                                          enableDrag: false,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (context) {
                                            return SafeArea(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 4),
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                    left: 16,
                                                    right: 16,
                                                    top: 16,
                                                  ),
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Wrap(
                                                      children: [
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.total.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.total.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.deck.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.deck.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.binding.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.binding.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categoryMain: _fleamarketListViewModel.selectedCategory_sub_total,
                                                                categorySub: _fleamarketListViewModel.selectedCategory_spot_total
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.boots.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.boots.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.cloth.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.cloth.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.plate.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.plate.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.etc.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.etc.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    style: ElevatedButton.styleFrom(
                                        padding: EdgeInsets.only(
                                            right: 32, left: 12, top: 3, bottom: 2),
                                        side: BorderSide(
                                          width: 1,
                                          color: (_fleamarketListViewModel.selectedCategory_sub_total != '전체 카테고리') ? SDSColor.gray900 : SDSColor.gray100,
                                        ),
                                        backgroundColor: (_fleamarketListViewModel.selectedCategory_sub_total != '전체 카테고리') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50))),
                                    child: Text('${_fleamarketListViewModel.selectedCategory_sub_total}',
                                        style: SDSTextStyle.bold.copyWith(
                                            fontSize: 13,
                                            color: (_fleamarketListViewModel.selectedCategory_sub_total != '전체 카테고리') ? Color(0xFFFFFFFF) : Color(0xFF111111) ))
                                ),
                                Positioned(
                                  top: 16,
                                  right: 10,
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
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Wrap(
                                                      children: [
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.total.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.total.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.deck.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.deck.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.binding.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.binding.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.boots.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.boots.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.cloth.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.cloth.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.plate.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.plate.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_sub.etc.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_sub_total('${FleamarketCategory_sub.etc.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub:_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot:
                                                              (_fleamarketListViewModel.selectedCategory_spot_total == '전체 거래장소')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: (_fleamarketListViewModel.selectedCategory_sub_total != '전체 카테고리') ? Image.asset(
                                      'assets/imgs/icons/icon_check_round.png',
                                      fit: BoxFit.cover,
                                      width: 16,
                                      height: 16,
                                    ) : Image.asset(
                                      'assets/imgs/icons/icon_check_round_black.png',
                                      fit: BoxFit.cover,
                                      width: 16,
                                      height: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Stack(
                              children: [
                                ElevatedButton(
                                    onPressed: () async {
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
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.total.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.total.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.konjiam.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.konjiam.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.muju.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.muju.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.vivaldi.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.vivaldi.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.alphen.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.alphen.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.gangchon.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.gangchon.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.oak.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.oak.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.o2.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.o2.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.yongpyong.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.yongpyong.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.welli.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.welli.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.jisan.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.jisan.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.high1.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.high1.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.phoenix.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.phoenix.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
                                                          ),
                                                          ListTile(
                                                            contentPadding: EdgeInsets.zero,
                                                            title: Center(
                                                              child: Text(
                                                                '${FleamarketCategory_spot.etc.korean}',
                                                                style: SDSTextStyle.bold.copyWith(
                                                                    fontSize: 15,
                                                                    color: SDSColor.gray900
                                                                ),
                                                              ),
                                                            ),
                                                            //selected: _isSelected[index]!,
                                                            onTap: () async {
                                                              Navigator.pop(context);
                                                              CustomFullScreenDialog.showDialog();
                                                              _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.etc.korean}');
                                                              await _fleamarketListViewModel.fetchFleamarketData_total(
                                                                userId: _userViewModel.user.user_id,
                                                                categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                    ? null
                                                                    :_fleamarketListViewModel.selectedCategory_sub_total,
                                                                spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                              );
                                                              CustomFullScreenDialog.cancelDialog();
                                                            },
                                                            shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                BorderRadius.circular(16)),
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
                                        padding: EdgeInsets.only(
                                            right: 32, left: 12, top: 3, bottom: 2),
                                        side: BorderSide(
                                          width: 1,
                                          color: (_fleamarketListViewModel.selectedCategory_spot_total != '전체 거래장소') ? SDSColor.gray900 : SDSColor.gray100,
                                        ),
                                        backgroundColor: (_fleamarketListViewModel.selectedCategory_spot_total != '전체 거래장소') ? SDSColor.gray900 : SDSColor.snowliveWhite,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(50))),
                                    child:
                                    Text('${_fleamarketListViewModel.selectedCategory_spot_total}',
                                        style: SDSTextStyle.bold.copyWith(
                                            fontSize: 13,
                                            color: (_fleamarketListViewModel.selectedCategory_spot_total != '전체 거래장소') ? Color(0xFFFFFFFF) : Color(0xFF111111)))
                                ),
                                Positioned(
                                  top: 16,
                                  right: 10,
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
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.total.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.total.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.konjiam.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.konjiam.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.muju.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.muju.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.vivaldi.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.vivaldi.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.alphen.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.alphen.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.gangchon.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.gangchon.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.oak.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.oak.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.o2.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.o2.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.yongpyong.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.yongpyong.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.welli.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.welli.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.jisan.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.jisan.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.high1.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.high1.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.phoenix.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.phoenix.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                        ListTile(
                                                          contentPadding: EdgeInsets.zero,
                                                          title: Center(
                                                            child: Text(
                                                              '${FleamarketCategory_spot.etc.korean}',
                                                              style: SDSTextStyle.bold.copyWith(
                                                                  fontSize: 15,
                                                                  color: SDSColor.gray900
                                                              ),
                                                            ),
                                                          ),
                                                          //selected: _isSelected[index]!,
                                                          onTap: () async {
                                                            Navigator.pop(context);
                                                            CustomFullScreenDialog.showDialog();
                                                            _fleamarketListViewModel.changeCategory_spot_total('${FleamarketCategory_spot.etc.korean}');
                                                            await _fleamarketListViewModel.fetchFleamarketData_total(
                                                              userId: _userViewModel.user.user_id,
                                                              categorySub: (_fleamarketListViewModel.selectedCategory_sub_total == '전체 카테고리')
                                                                  ? null
                                                                  :_fleamarketListViewModel.selectedCategory_sub_total,
                                                              spot: _fleamarketListViewModel.selectedCategory_spot_total,
                                                            );
                                                            CustomFullScreenDialog.cancelDialog();
                                                          },
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(16)),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    child: (_fleamarketListViewModel.selectedCategory_spot_total != '전체 거래장소') ? Image.asset(
                                      'assets/imgs/icons/icon_check_round.png',
                                      fit: BoxFit.cover,
                                      width: 16,
                                      height: 16,
                                    ) : Image.asset(
                                      'assets/imgs/icons/icon_check_round_black.png',
                                      fit: BoxFit.cover,
                                      width: 16,
                                      height: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //리스트
                    (_fleamarketListViewModel.isLoadingList_total==true)
                        ? Container(
                      height: 150,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: SDSColor.snowliveWhite,
                              color: SDSColor.snowliveBlue,
                            ),
                          ),
                        ],
                      ),
                    )
                    :Expanded(
                        child: (_fleamarketListViewModel.fleamarketListTotal.length == 0)
                            ? Transform.translate(
                          offset: Offset(0, -40),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/imgs/icons/icon_nodata.png',
                                  scale: 4,
                                  width: 73,
                                  height: 73,
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text('게시판에 글이 없습니다.',
                                  style: SDSTextStyle.regular.copyWith(
                                      fontSize: 14,
                                      color: SDSColor.gray600
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                            : Scrollbar(
                          controller: _fleamarketListViewModel.scrollController_total,
                          child: ListView.builder(
                            controller: _fleamarketListViewModel.scrollController_total, // ScrollController 연결
                            itemCount: _fleamarketListViewModel.fleamarketListTotal.length,
                            itemBuilder: (context, index) {
                              Fleamarket data = _fleamarketListViewModel.fleamarketListTotal[index] ;
                              String _time = GetDatetime().getAgoString(data.uploadTime!);

                              return GestureDetector(
                                  onTap: () async {
                                    _fleamarketDetailViewModel.fetchFleamarketDetailFromList(fleamarketResponse: _fleamarketListViewModel.fleamarketListTotal[index]);
                                    Get.toNamed(AppRoutes.fleamarketDetail);
                                    await _fleamarketDetailViewModel.addViewerFleamarket(fleamarketId: data.fleaId!, userId: _userViewModel.user.user_id);
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        color: Colors.white,
                                        height: 110,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Stack(
                                                  children: [
                                                    if (data.photos!.length != 0)
                                                      ExtendedImage.network(
                                                        data.photos!.first.urlFleaPhoto!,
                                                        cache: true,
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(width: 0.5, color: SDSColor.gray100),
                                                        width: 110,
                                                        height: 110,
                                                        cacheHeight: 250,
                                                        fit: BoxFit.cover,
                                                        handleLoadingProgress: true,
                                                        loadStateChanged: (ExtendedImageState state) {
                                                          switch (state.extendedImageLoadState) {
                                                            case LoadState.loading:
                                                            // 로딩 중일 때 로딩 인디케이터를 표시
                                                              return Center(child: CircularProgressIndicator());
                                                            case LoadState.completed:
                                                            // 로딩이 완료되었을 때 이미지 반환
                                                              return state.completedWidget;
                                                            case LoadState.failed:
                                                            // 로딩이 실패했을 때 대체 이미지 또는 다른 처리
                                                              return Image.asset(
                                                                'assets/imgs/imgs/img_flea_default.png', // 대체 이미지 경로
                                                                width: 110,
                                                                height: 110,
                                                                fit: BoxFit.cover,
                                                              );
                                                          }
                                                        },
                                                      ),
                                                    if (data.photos!.length == 0)
                                                      ExtendedImage.asset(
                                                        'assets/imgs/imgs/img_flea_default.png',
                                                        shape: BoxShape.rectangle,
                                                        borderRadius: BorderRadius.circular(8),
                                                        width: 110,
                                                        height: 110,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    if (data.status == FleamarketStatus.soldOut.korean)
                                                      Container(
                                                        width: 110, // 이미지와 동일한 너비
                                                        height: 110, // 이미지와 동일한 높이
                                                        decoration: BoxDecoration(
                                                          color: Colors.black.withOpacity(0.6),  // 반투명한 검정색 오버레이
                                                          borderRadius: BorderRadius.circular(8),  // 이미지와 동일한 둥근 모서리
                                                        ),
                                                      ),
                                                    if (data.status == FleamarketStatus.soldOut.korean)
                                                      Positioned(
                                                        top: 8,
                                                        left: 8,  // 좌측 상단에 위치하도록 설정
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),  // 패딩을 추가하여 뱃지 모양을 만듦
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(4),  // 모서리를 둥글게 처리
                                                            color: SDSColor.snowliveWhite,  // 배경색과 투명도 설정
                                                          ),
                                                          child: Text(
                                                            '${FleamarketStatus.soldOut.korean}',
                                                            style: SDSTextStyle.bold.copyWith(
                                                              color: SDSColor.snowliveBlack,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    if (data.status == FleamarketStatus.onBooking.korean)
                                                      Positioned(
                                                        top: 8,
                                                        left: 8,  // 좌측 상단에 위치하도록 설정
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),  // 패딩을 추가하여 뱃지 모양을 만듦
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(4),  // 모서리를 둥글게 처리
                                                            color: SDSColor.snowliveBlue,  // 배경색과 투명도 설정
                                                          ),
                                                          child: Text(
                                                            '${FleamarketStatus.onBooking.korean}',
                                                            style: SDSTextStyle.bold.copyWith(
                                                              color: SDSColor.snowliveWhite,
                                                              fontWeight: FontWeight.bold,
                                                              fontSize: 11,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                ),
                                                SizedBox(width: 16),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      width: _size.width - 158,
                                                      height: 91,
                                                      child: Column(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          //TODO: 타이틀
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Container(
                                                                constraints: BoxConstraints(maxWidth: _size.width - 158),
                                                                child: Text(
                                                                  data.title!,
                                                                  maxLines: 2,
                                                                  overflow: TextOverflow.ellipsis,
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 15,
                                                                      color: SDSColor.gray900),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          //TODO: 장소, 시간
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 2),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  '${data.spot!} · ',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 13,
                                                                      color: SDSColor.gray500
                                                                  ),
                                                                ),
                                                                Text(
                                                                  '$_time',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 13,
                                                                      color: SDSColor.gray500
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 2,
                                                          ),
                                                          //TODO: 가격
                                                          Row(
                                                            children: [
                                                              Container(
                                                                  constraints: BoxConstraints(maxWidth: _size.width - 106),
                                                                  child: Text(
                                                                    f.format(data.price) + '원',
                                                                    maxLines: 1,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    style: SDSTextStyle.bold.copyWith(
                                                                        color: SDSColor.gray900,
                                                                        fontSize: 17),
                                                                  )
                                                              ),
                                                            ],
                                                          ),

                                                        ],
                                                      ),
                                                    ),
                                                    //TODO: 조회수, 찜수, 댓글수
                                                    Row(
                                                      children: [
                                                        //TODO: 조회수
                                                        if(data.viewsCount!.toInt() != 0)
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Container(
                                                                width: 16,
                                                                height: 16,
                                                                decoration: BoxDecoration(
                                                                  shape: BoxShape.rectangle,
                                                                  borderRadius: BorderRadius.circular(8),
                                                                  image: DecorationImage(
                                                                    image: AssetImage('assets/imgs/icons/icon_list_view.png'),
                                                                    fit: BoxFit.cover,
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(width: 2,),
                                                              Text(
                                                                  '${data.viewsCount}',
                                                                  style: SDSTextStyle.regular.copyWith(
                                                                    fontSize: 13,
                                                                    color: SDSColor.gray500,
                                                                  )
                                                              )
                                                            ],
                                                          ),
                                                        //TODO: 찜수
                                                        if(data.favoriteCount!.toInt() != 0)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 6),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                (data.isFavorite == false)
                                                                    ? Container(
                                                                  width: 16,
                                                                  height: 16,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    image: DecorationImage(
                                                                      image: AssetImage('assets/imgs/icons/icon_list_scrap.png'),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                )
                                                                    : Container(
                                                                  width: 16,
                                                                  height: 16,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    image: DecorationImage(
                                                                      image: AssetImage('assets/imgs/icons/icon_list_scrap_my.png'),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                )
                                                                ,
                                                                SizedBox(width: 2,),
                                                                Text(
                                                                    '${data.favoriteCount.toString()}',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 13,
                                                                      color: SDSColor.gray500,
                                                                    )
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                        //TODO: 댓글수
                                                        if(data.commentCount!.toInt() != 0)
                                                          Padding(
                                                            padding: const EdgeInsets.only(left: 6),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              children: [
                                                                Container(
                                                                  width: 16,
                                                                  height: 16,
                                                                  decoration: BoxDecoration(
                                                                    shape: BoxShape.rectangle,
                                                                    borderRadius: BorderRadius.circular(8),
                                                                    image: DecorationImage(
                                                                      image: AssetImage('assets/imgs/icons/icon_list_reply.png'),
                                                                      fit: BoxFit.cover,
                                                                    ),
                                                                  ),
                                                                ),
                                                                SizedBox(width: 2,),
                                                                Text(
                                                                    '${data.commentCount.toString()}',
                                                                    style: SDSTextStyle.regular.copyWith(
                                                                      fontSize: 13,
                                                                      color: SDSColor.gray500,
                                                                    )
                                                                )
                                                              ],
                                                            ),
                                                          ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (_fleamarketListViewModel.fleamarketListTotal.length != index + 1)
                                        Divider(
                                          color: SDSColor.gray100,
                                          height: 32,
                                          thickness: 1,
                                        ),
                                    ],
                                  )
                              );
                            },
                            padding: EdgeInsets.only(bottom: 80),
                          ),
                        )
                    ),
                  ],
                ),
              ))),
        ),
      ),
    );
  }
}
