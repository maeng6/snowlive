import 'package:com.snowlive/viewmodel/vm_fleamarketList.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../model/m_fleamarket.dart';
import '../screens/snowliveDesignStyle.dart';
import '../util/util_1.dart';
import '../viewmodel/vm_user.dart';

class FleaMarketListView_board extends StatelessWidget {
  final f = NumberFormat('###,###,###,###');

  final FleamarketListViewModel _fleamarketViewModel = Get.find<FleamarketListViewModel>();
  final UserViewModel _userViewModel = Get.find<UserViewModel>();

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
          floatingActionButton: Stack(
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: _size.height - 308),
                  child: Visibility(
                    visible: _fleamarketViewModel.isVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 32),
                      child: Container(
                        width: 106,
                        child: FloatingActionButton(
                          heroTag: 'fleamarketList',
                          mini: true,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40)
                          ),
                          backgroundColor: Color(0xFF000000).withOpacity(0.8),
                          foregroundColor: Colors.white,
                          onPressed: () {
                            _fleamarketViewModel.scrollController.jumpTo(0);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_upward_rounded,
                                  color: Color(0xFFffffff),
                                  size: 16),
                              Padding(
                                padding: const EdgeInsets.only(left: 2, right: 3),
                                child: Text('최신글 보기',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFffffff).withOpacity(0.8),
                                      letterSpacing: 0
                                  ),),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                child: Transform.translate(
                  offset: Offset(18, 0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: AnimatedContainer(
                      width: _fleamarketViewModel.showAddButton ? 104 : 52,
                      height: 52,
                      duration: Duration(milliseconds: 200),
                      child: FloatingActionButton.extended(
                        elevation: 4,
                        heroTag: 'fleaListScreen',
                        onPressed: () async {

                        },
                        icon: Transform.translate(
                            offset: Offset(6,0),
                            child: Center(child: Icon(Icons.add))),
                        label: _fleamarketViewModel.showAddButton
                            ? Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text('글쓰기',
                            style: TextStyle(
                                letterSpacing: 0.5,
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                overflow: TextOverflow.ellipsis),
                          ),
                        )
                            : SizedBox.shrink(), // Hide the text when _showAddButton is false
                        backgroundColor: Color(0xFF3D6FED),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          backgroundColor: Colors.white,
          body: Obx(()=>Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 6),
            child: Column(
              children: [
                //TODO: 필터
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Container(
                        height: 56,
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
                                              height: MediaQuery.of(context).size.height * 0.4,
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
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.total.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );

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
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.deck.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.binding.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.boots.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.cloth.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.etc.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                        right: 30, left: 14, top: 8, bottom: 8),
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                    backgroundColor: SDSColor.gray50,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8))),
                                child:
                                Text('${_fleamarketViewModel.selectedCategory_sub_board}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF555555)))
                            ),
                            Positioned(
                              top: 12,
                              right: 6,
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
                                              height: MediaQuery.of(context).size.height * 0.4,
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
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.total.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        print('${_fleamarketViewModel.selectedCategory_spot_board }');
                                                        Navigator.pop(context);
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.deck.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        print('${_fleamarketViewModel.selectedCategory_spot_board }');
                                                        Navigator.pop(context);
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.binding.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        print('${_fleamarketViewModel.selectedCategory_spot_board }');
                                                        Navigator.pop(context);
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.boots.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        print('${_fleamarketViewModel.selectedCategory_spot_board }');
                                                        Navigator.pop(context);
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.cloth.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        print('${_fleamarketViewModel.selectedCategory_spot_board }');
                                                        Navigator.pop(context);
                                                        _fleamarketViewModel.changeCategory_sub_board('${FleamarketCategory_sub.etc.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub:_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot:
                                                          (_fleamarketViewModel.selectedCategory_spot_board == '전체 거래장소')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                child: Icon(
                                  Icons.arrow_drop_down_sharp,
                                  size: 24,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Container(
                        height: 56,
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.total.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.konjiam.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.muju.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.vivaldi.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.alphen.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.gangchon.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.oak.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.o2.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.yongpyong.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.welli.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.jisan.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.high1.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.phoenix.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.etc.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                        right: 30, left: 14, top: 8, bottom: 8),
                                    side: const BorderSide(
                                      width: 1,
                                      color: Color(0xFFF5F5F5),
                                    ),
                                    backgroundColor: SDSColor.gray50,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8))),
                                child:
                                Text('${_fleamarketViewModel.selectedCategory_spot_board}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF555555)))
                            ),
                            Positioned(
                              top: 12,
                              right: 6,
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.total.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.konjiam.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.muju.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.vivaldi.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.alphen.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.gangchon.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.oak.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.o2.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.yongpyong.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.welli.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.jisan.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.high1.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.phoenix.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                                        _fleamarketViewModel.changeCategory_spot_board('${FleamarketCategory_spot.etc.korean}');
                                                        await _fleamarketViewModel.fetchFleamarketData_board(
                                                          userId: _userViewModel.user.user_id,
                                                          categoryMain: '스노보드',
                                                          categorySub: (_fleamarketViewModel.selectedCategory_sub_board == '전체 카테고리')
                                                              ? null
                                                              :_fleamarketViewModel.selectedCategory_sub_board,
                                                          spot: _fleamarketViewModel.selectedCategory_spot_board,
                                                        );
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
                                child: Icon(
                                  Icons.arrow_drop_down_sharp,
                                  size: 24,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                //TODO: 리스트
                Expanded(
                    child: (_fleamarketViewModel.fleamarketListBoard.length == 0)
                        ? Transform.translate(
                      offset: Offset(0, -40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                                color: Color(0xFF949494)
                            ),
                          ),
                        ],
                      ),
                    )
                        : Scrollbar(
                      controller: _fleamarketViewModel.scrollController,
                      child: ListView.builder(
                        controller: _fleamarketViewModel.scrollController, // ScrollController 연결
                        itemCount: _fleamarketViewModel.fleamarketListBoard.length,
                        itemBuilder: (context, index) {
                          Fleamarket data = _fleamarketViewModel.fleamarketListBoard[index] ;
                          String _time = GetDatetime().getAgoString(data.uploadTime!);

                          return GestureDetector(
                              onTap: () async {

                              },
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.white,
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Stack(
                                              children: [
                                                if (data.photos!.length != 0)
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                                    child: ExtendedImage.network(data.photos!.first.urlFleaPhoto!,
                                                      cache: true,
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(width: 0.5, color: Color(0xFFdedede)),
                                                      width: 100,
                                                      height: 100,
                                                      cacheHeight: 250,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                if (data.photos!.length == 0)
                                                  Padding(
                                                    padding: EdgeInsets.only(top: 8, bottom: 8),
                                                    child: ExtendedImage
                                                        .asset(
                                                      'assets/imgs/profile/img_profile_default_.png',
                                                      shape: BoxShape.rectangle,
                                                      borderRadius: BorderRadius.circular(8),
                                                      width: 100,
                                                      height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                if (data.status == FleamarketStatus.soldOut.korean)
                                                  Positioned(
                                                    top: 8,
                                                    child: Stack(
                                                      children: [
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(8),
                                                            color: Color(0xFF000000).withOpacity(0.6),
                                                          ),
                                                          width: 100,
                                                          height: 100,
                                                        ),
                                                        Positioned(
                                                          top: 40,
                                                          left: 20,
                                                          child: Text('${FleamarketStatus.soldOut.korean}',
                                                            style: TextStyle(
                                                                color: Color(0xFFFFFFFF),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16
                                                            ),),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                if (data.status == FleamarketStatus.forSale.korean)
                                                  Positioned(
                                                    top: 20,
                                                    left: 20,
                                                    child: Text('${FleamarketStatus.forSale.korean}',
                                                      style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16
                                                      ),),
                                                  ),
                                                if (data.status == FleamarketStatus.onBooking.korean)
                                                  Positioned(
                                                    top: 20,
                                                    left: 20,
                                                    child: Text('${FleamarketStatus.onBooking.korean}',
                                                      style: TextStyle(
                                                          color: Color(0xFFFFFFFF),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 16
                                                      ),),
                                                  ),
                                              ],
                                            ),
                                            SizedBox(width: 16),
                                            Padding(
                                              padding:
                                              const EdgeInsets.symmetric(vertical: 6),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  //TODO: 타이틀
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Container(
                                                        constraints: BoxConstraints(maxWidth: _size.width - 170),
                                                        child: Text(
                                                          data.title!,
                                                          maxLines: 2,
                                                          overflow: TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              fontWeight: FontWeight.normal,
                                                              fontSize: 15,
                                                              color: Color(0xFF555555)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  //TODO: 시간
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '$_time',
                                                        style: TextStyle(
                                                            fontSize:
                                                            14,
                                                            color: Color(
                                                                0xFF949494),
                                                            fontWeight:
                                                            FontWeight
                                                                .normal),
                                                      ),
                                                      SizedBox(width: 10,),
                                                    ],
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
                                                            f.format(data.price) + ' 원',
                                                            maxLines:
                                                            1,
                                                            overflow:
                                                            TextOverflow.ellipsis,
                                                            style: TextStyle(
                                                                color: Color(0xFF111111),
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 16),
                                                          )
                                                      ),
                                                    ],
                                                  ),
                                                  SizedBox(
                                                    height: 10,
                                                  ),
                                                  //TODO: 거래장소
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(3),
                                                      color: Color(0xFFD5F7E0),
                                                    ),
                                                    padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                    child: Text(
                                                      data.spot!,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 12,
                                                          color: Color(0xFF17AD4A)),
                                                    ),
                                                  ),
                                                  //TODO: 조회수, 찜수, 댓글수
                                                  Row(
                                                    children: [
                                                      //TODO: 조회수
                                                      if(data.viewsCount!.toInt() != 0)
                                                        Padding(
                                                          padding: const EdgeInsets.only(bottom: 2),
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                            children: [
                                                              Icon(
                                                                Icons.remove_red_eye_rounded,
                                                                color: Color(0xFFc8c8c8),
                                                                size: 15,
                                                              ),
                                                              SizedBox(width: 4,),
                                                              Text(
                                                                  '${data.viewsCount}',
                                                                  style: TextStyle(
                                                                      fontSize: 13,
                                                                      color: Color(0xFF949494),
                                                                      fontWeight: FontWeight.normal)
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                      //TODO: 찜수
                                                      if(data.favoriteCount!.toInt() != 0)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Color(0xFFD5F7E0),
                                                          ),
                                                          padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                          child: Text(
                                                            data.favoriteCount.toString()!,
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Color(0xFF17AD4A)),
                                                          ),
                                                        ),
                                                      //TODO: 댓글수
                                                      if(data.commentCount!.toInt() != 0)
                                                        Container(
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(3),
                                                            color: Color(0xFFD5F7E0),
                                                          ),
                                                          padding: EdgeInsets.only(right: 6, left: 6, top: 2, bottom: 3),
                                                          child: Text(
                                                            data.commentCount.toString(),
                                                            style: TextStyle(
                                                                fontWeight: FontWeight.bold,
                                                                fontSize: 12,
                                                                color: Color(0xFF17AD4A)),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_fleamarketViewModel.fleamarketListBoard.length != index + 1)
                                    Divider(
                                      color: Color(0xFFDEDEDE),
                                      height: 16,
                                      thickness: 0.5,
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
          )),
        ),
      ),
    );
  }
}
